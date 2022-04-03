pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfETH, uint256 amountOfTokens);


  YourToken public yourToken;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  uint256 public constant tokensPerEth = 100;

  // ToDo: create a payable buyTokens() function:
  function buyTokens() public payable {
    require(msg.sender > address(0), "Invalid ADDRESS");
    
    uint256 tokensToTransfer = msg.value * tokensPerEth;
    yourToken.transfer(msg.sender, tokensToTransfer);

    emit BuyTokens(msg.sender, msg.value, tokensToTransfer);
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
    function withdraw() public onlyOwner  {
      uint256 ownerBalance = address(this).balance;
      require(ownerBalance > 0, "Owner has no balance to withdraw");

      (bool sent,) = msg.sender.call{value : ownerBalance}("");
      require(sent, "Failed to send");
    }


  // ToDo: create a sellTokens() function:

  function sellTokens(uint256 amount) public {
    require(amount > 0, "Amount has to be > 0");
    
    uint256 userBalance = yourToken.balanceOf(msg.sender);
    require(userBalance >= amount, "Insufficient Tokens");

    uint256 ownerBalance = address(this).balance;
    uint256 ethToTrsf = amount/tokensPerEth;
    require(ownerBalance >= ethToTrsf, "Owner doesn't have enough tokens balance");


    yourToken.transferFrom(msg.sender, address(this), amount);

    (bool sent,) = msg.sender.call{value : ethToTrsf}("");
    require(sent, "Failed to send eth to the user");

    emit SellTokens(msg.sender, ethToTrsf, amount);
  }

}