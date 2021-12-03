//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.2;

import "hardhat/console.sol";

contract DarkIce {
    string public name = "Winter Fate: Dark Ice";
    string public symbol = "DARKICE";
    address public contractAddress = address(this);
    uint256 public decimals = 4;
    uint256 public totalSupply = 1000000 * (10**decimals);
    address public founderAddress = msg.sender;
    uint256 public currentServerDay;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;

    mapping(address => Player) public players;
    mapping(address => uint256) public accumulatedRewards;

    struct Player {
        uint32 level;
        uint32 economicLevel;
        uint256 lastWorked;
    }

    // Events declarations
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Work(address indexed from, address indexed to, uint256 reward);

    constructor() {
        emit Transfer(address(0x0), address(this), (totalSupply * 100) / 100);
        balances[address(this)] = (totalSupply * 100) / 100;

        emit Transfer(address(0x0), founderAddress, 1000);
        balances[founderAddress] = 1000;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return balances[owner];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(balanceOf(msg.sender) >= value, "Not enough balance.");
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool) {
        require(balanceOf(from) >= value, "balance too low");
        require(allowance[from][msg.sender] >= value, "allowance too low");
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function getUnixDay() public view returns (uint256) {
        // Returns unix days since 1970 Jan 01 in an integer, rounded.
        uint256 currentBlockTime = block.timestamp;
        uint256 remainder = currentBlockTime % 86400;
        uint256 roundTime = currentBlockTime - remainder;
        return roundTime / 86400;
    }

    function canWork(address playerAddress) public view returns (bool) {
        uint256 todayDay = getUnixDay();
        if (players[playerAddress].lastWorked < todayDay) {
            return true;
        } else {
            return false;
        }
    }

    function work() public returns (bool) {
        address playerAddress = msg.sender;
        if (players[playerAddress].level == 0) {
            players[playerAddress] = Player(1, 1, 0);
        }

        if (canWork(playerAddress)) {
            // uint256 reward = 25 * (10**decimals) * playerEconomicLevel;
            uint256 reward = 150;
            accumulatedRewards[playerAddress] += reward;
            players[playerAddress].lastWorked = getUnixDay();
            return true;
        } else {
            return false;
        }
    }

    function claimReward() public returns (bool) {
        address playerAddress = msg.sender;
        uint256 payout = accumulatedRewards[playerAddress];
        // Verify if contract has enough balance to pay the user
        require(balanceOf(address(this)) >= payout, "reserves too low");

        balances[address(this)] -= payout;
        balances[playerAddress] += payout;
        emit Transfer(address(this), playerAddress, payout);

        accumulatedRewards[playerAddress] = 0;

        return true;
    }

    function devResetWork() public returns (bool) {
        address playerAddress = msg.sender;

        if (playerAddress == founderAddress) {
            uint256 yesterday = getUnixDay() - 1;
            players[playerAddress].lastWorked = yesterday;
            return true;
        } else {
            return false;
        }
    }

    function selfDestroy() public {
        if (msg.sender == founderAddress) {
            selfDestroy();
        }
    }
}
