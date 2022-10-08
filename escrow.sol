//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract EscrowERC721 {

  address public owner;
  uint counter;
  IERC721 token;

  struct ERC721Item {
      address seller;
      address buyer;
      uint256 item;
  }

  mapping(uint256 => ERC721Item) public erc721Items;

  event Deposited(address indexed payee, address tokenAddress, uint256 item);
  event Withdrawn(address indexed payee, address tokenAddress, uint256 item);

  constructor(IERC721 _token) {
      owner = payable(msg.sender);
      token = _token;
      counter = 0;
  }


  modifier onlyOwner() {
      require(msg.sender == owner, "Must be an owner.");
        _;
  }


  function deposit(address _buyer,  uint256 _item) public payable {
      require(msg.sender == token.ownerOf(_item), "Sender is not a token owner.") ;
      token.transferFrom(msg.sender, address(this), _item);
      //uint256 id = counter;
      erc721Items[_item] = ERC721Item({
        seller: msg.sender,
        buyer: _buyer,
        item: _item
      });

      emit Deposited(_buyer, address(token), _item);
  }

  function withdraw(uint256 _item) public {
      address buyer = erc721Items[_item].buyer;
      uint256 item = erc721Items[_item].item;
      delete(erc721Items[_item]);
      IERC721(address(token)).transferFrom(address(this), buyer, item);
      emit Withdrawn(buyer, address(token), item);
  }

}