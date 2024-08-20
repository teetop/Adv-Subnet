# Game

Game is a simple guessing game platform that rewards players for participating in the game. Players stake to guess a particular mystery letter and is rewarded 10% of their stake if guessed right but lost their stake is guessed wrongly.

## Description

This is a smart contract is written in Solidity programming language. The main goal of this contract is to show the power of Avalanche custom subnet.

The contract has just 3 functions.

- setMystery: This function allows the contract owner to pre-add players to the game. These players get tokens minted to them, these tokens are used to participate in the game. Any players without this token cannot participate in the game.

- playGame: This players participate in the game using this funtion. They input their stake amount and their guess. If they guessed right, 10% of their stake is added to their balance, if otherwise they lose their entire stake.

- disburseWIns: The contract owner disburse to the winners their winning token. Only player who have won get token.


# Getting Started

## Executing Program

- First thing is to visit ```https://docs.avax.network/tooling/guides/get-avalanche-cli``` to install avalanche CLI on your computer.

- When the CLI is installed, type ```avalanche subnet create mySubnet``` and follow the instruction on your terminal to create your subnet. NOTE: Instead of the mySubnet, you can choose your subnet name.

- Deploy your subnet by typing ```avalanche subnet deploy mySubnet``` and follow the instruction.

- When your subnet is deployed, use the information thereof to set up your metamask network.

- To run this program, you can use Remix, an online Solidity IDE. To get started, go to the Remix website at https://remix.ethereum.org/.

- Once you are on the Remix website, create a new file by clicking on the "+" icon in the left-hand sidebar. Save the file with a .sol extension (e.g., DegenGame.sol). Copy and paste the following code into the file:

```javascript
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
```

- To compile the code, click on the "Solidity Compiler" tab in the left-hand sidebar. Make sure the "Compiler" option is set to "0.8.24" (or another compatible version), and then click on the "Compile Game.sol" button.
 
- Change the Environment from the "Remix VM" to Injected Provider - Metamask to be able to deploy to your deployed subnet. On your metamask, make sure the selected network is the subnet.
 
- Once you have sorted your environment, you can deploy the contract by clicking the "Deploy & Run Transactions" tab in the left-hand sidebar. Select the "Game" contract from the dropdown menu, and then click on the "Deploy" button.
 
- Once the contract is deployed, you can interact with it the contract.

- When you are done with everything, including interacting with the contract, type  ```avalanche network stop ``` in your terminal to shut the subnet down.

## Authors
Temitope Taiwo

## License
This project is licensed under the MIT License - see the LICENSE.md file for details
