// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import {ReentrancyGuard} from "openzeppelin-contracts/security/ReentrancyGuard.sol";
import {Address} from "openzeppelin-contracts/utils/Address.sol";

/**
 * @title NaiveReceiverLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract NaiveReceiverLenderPool is ReentrancyGuard {
    using Address for address;

    uint256 private constant FIXED_FEE = 1 ether; // not the cheapest flash loan

    error BorrowerMustBeADeployedContract();
    error NotEnoughETHInPool();
    error FlashLoanHasNotBeenPaidBack();

    function fixedFee() external pure returns (uint256) {
        return FIXED_FEE;
    }

    function flashLoan(address borrower, uint256 borrowAmount) external nonReentrant {
        // 10 balance, 1 borrow
        uint256 balanceBefore = address(this).balance;
        if (balanceBefore < borrowAmount) revert NotEnoughETHInPool();
        if (!borrower.isContract()) revert BorrowerMustBeADeployedContract();

        // 1 fee + 1 borrow
        // borrower.fu
        borrower.functionCallWithValue(abi.encodeWithSignature("receiveEther(uint256)", FIXED_FEE), borrowAmount);

        // 1 fee goes missing
        // balanceBefore = 10, balanceNow = 10
        if (address(this).balance < balanceBefore + FIXED_FEE) {
            revert FlashLoanHasNotBeenPaidBack();
        }
    }

    // Allow deposits of ETH
    receive() external payable {}
}
