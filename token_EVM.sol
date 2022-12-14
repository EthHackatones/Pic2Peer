//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC721TestToken is ERC721, Ownable{
    constructor ()ERC721("ENEFTI", "NFT") {}

    function mint(address _to, uint256 _tokenId) external onlyOwner {
    super._mint(_to, _tokenId);
  }

}
