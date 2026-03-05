// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import { GnosisSafeProxy } from "safe-smart-account/contracts/proxies/GnosisSafeProxy.sol";
import { GnosisSafeL2 } from "safe-smart-account/contracts/GnosisSafeL2.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract SafeProxyFactory {
    event ProxyCreation(GnosisSafeL2 proxy, address owner);

    address public masterCopy;

    address public fallbackHandler;

    /* EIP712 */

    bytes32 public domainSeparator;

    // The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,uint256 chainId,address verifyingContract)"
    );

    // The EIP-712 typehash for the deposit id struct
    bytes32 public constant CREATE_PROXY_TYPEHASH = keccak256(
        "CreateProxy(address paymentToken,uint256 payment,address paymentReceiver)"
    );

    string public constant NAME = "Goldex Contract Proxy Factory";

    /* STRUCTS */

    struct Sig {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    /* CONSTRUCTOR */

    constructor(address _masterCopy, address _fallbackHandler) {
        masterCopy = _masterCopy;
        fallbackHandler = _fallbackHandler;

        domainSeparator = keccak256(abi.encode(
            DOMAIN_TYPEHASH,
            keccak256(bytes(NAME)),
            _getChainIdInternal(),
            address(this)
        ));
    }

    function proxyCreationCode() public pure returns (bytes memory) {
        return type(GnosisSafeProxy).creationCode;
    }

    function getContractBytecode() public view returns (bytes memory) {
       return abi.encodePacked(proxyCreationCode(), abi.encode(masterCopy));
    }

    function getSalt(address user) public pure returns (bytes32) {
        return _hashBytes(abi.encode(user));
    }

    function computeProxyAddress(address user) external view returns (address) {
        bytes32 salt = getSalt(user);
        bytes32 bytecodeHash = _hashBytes(getContractBytecode());
        bytes32 _data = _hashBytes(abi.encodePacked(bytes1(0xff), address(this), salt, bytecodeHash));

        return address(uint160(uint256(_data)));
    }

    function createProxy(
        address paymentToken,
        uint256 payment,
        address payable paymentReceiver,
        Sig calldata createSig
    )
        external
    {
        address owner = _getSigner(paymentToken, payment, paymentReceiver, createSig);

        GnosisSafeL2 proxy; 
        bytes memory deploymentData = getContractBytecode();
        bytes32 salt = getSalt(owner);
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            proxy := create2(0x0, add(0x20, deploymentData), mload(deploymentData), salt)
        }
        require(address(proxy) != address(0), "create2 call failed");
        

        {
            address[] memory owners = new address[](1);
            owners[0] = owner;
            proxy.setup(owners, 1, address(0), "", fallbackHandler, paymentToken, payment, paymentReceiver);
        }

        emit ProxyCreation(proxy, owner);
   }

   function _hashBytes(bytes memory data) private pure returns (bytes32 hash) {
        assembly {
            hash := keccak256(add(data, 0x20), mload(data))
        }
    }

   function _getSigner(address paymentToken, uint256 payment, address payable paymentReceiver, Sig calldata sig) internal view returns (address) {
       bytes32 structHash = _hashBytes(abi.encode(CREATE_PROXY_TYPEHASH, paymentToken, payment, paymentReceiver));
       bytes32 digest = _hashBytes(abi.encodePacked("\x19\x01", domainSeparator, structHash));

       return ECDSA.recover(digest, sig.v, sig.r, sig.s);
   }

   function _getChainIdInternal() internal view returns (uint) {
       uint256 chainId;
       assembly { chainId := chainid() }
       return chainId;
   }
}