//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract EscrowERC721 {

  address public owner;
  address seller;
  address buyer;
  uint counter;
  uint settlement;
  IERC721 token;

  struct ERC721Item {
      address seller;
      address buyer;
      uint256 item;
  }


  // enum for correct order of transactions
  enum State {AWAITING_PAYMENT, AWATING_DELIVERY, COMPLETE}
  State public currentState;

  // Modifiers
  modifier buyerOnly() { require(msg.sender == buyer); _; }
  modifier sellerOnly() { require(msg.sender == seller); _; }
  modifier settleSeller() { require(settlement == 0); _; }
  modifier inState(State state) { require(currentState == state); _; }

  mapping(uint256 => ERC721Item) public erc721Items;

  event Deposited(address indexed payee, address tokenAddress, uint256 item);
  event Withdrawn(address indexed payee, address tokenAddress, uint256 item);

  constructor(IERC721 _token) {
      owner = payable(msg.sender);
      token = _token;
      settlement = 2;
      counter = 0;
  }


  modifier onlyOwner() {
      require(msg.sender == owner, "Must be an owner.");
        _;
  }


  function deposit(address _buyer,  uint256 _item) public payable {
      seller = msg.sender;
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

  function modifySettlement (uint _value) public {
      settlement = _value;
  }

  function withdraw_seller(uint256 _item) sellerOnly public {
      buyer = erc721Items[_item].buyer;
      uint256 item = erc721Items[_item].item;
      delete(erc721Items[_item]);
      IERC721(address(token)).transferFrom(address(this), buyer, item);
      emit Withdrawn(buyer, address(token), item);
  }

  function resolve_seller(uint256 _item) settleSeller sellerOnly public {
      seller = erc721Items[_item].seller;
      uint256 item = erc721Items[_item].item;
      delete(erc721Items[_item]);
      IERC721(address(token)).transferFrom(address(this), seller, item);
      emit Withdrawn(seller, address(token), item);
  }

}
