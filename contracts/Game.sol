// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Game is ERC20, Ownable {

    address[] players;

    bytes32 mystery;

    event GamePlayed(string result);
    event GameWOn(address winner, uint256 amount);

    mapping (address => uint256) public playerWins;

    struct WinInfo {
        address player;
        uint256 amountWon;
    }

    constructor(address[] memory _players) ERC20("Game", "GAME") Ownable(msg.sender) {
        mintToPlayers(_players);
    }

    function mintToPlayers(address[] memory _players) private {
        _mint(owner(), 10000);
        for (uint256 i = 0; i < _players.length; i++) {
            players.push(_players[i]);
            _mint(_players[i], 1000);
        }
    }

    function setMystery(string memory _mystery) external onlyOwner returns(bool) {

        mystery = keccak256(abi.encodePacked(_mystery));
        return true;
    }

    function playGame(uint256 _amount, string memory _guess) external {
        require(msg.sender != owner(), "OWNER_CANNOT_PLAY!");
        require(balanceOf(msg.sender) >= _amount, "INSUFFICIENT BALANCE");

        bytes32 result = keccak256(abi.encodePacked(_guess));

        uint256 _perc = (_amount * 10) / 100;
        string memory message;

        if (result == mystery) {

            playerWins[msg.sender] += _perc;

            message = "You Won!";

            emit GameWOn(msg.sender, _perc);
            
        } else {
            transfer(owner(), _amount);
            message = "You lost!";
        }

        emit GamePlayed(message);

    }

    function disburseWIns() external onlyOwner returns(bool) {
        address[] memory winners = players;

        for (uint256 i = 0; i < winners.length; i++) {

            address player = winners[i];
            if (player == address(0)) continue;

            if (playerWins[player] == 0) continue;

            uint256 amount = playerWins[player];
            playerWins[player] = 0;

            if (!transfer(player, amount)) 
                revert("Transfer failed!");
        }
        
        return true;
    }
}