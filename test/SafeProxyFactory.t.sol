// SPDX-License-Identifier: MIT
pragma solidity <0.9.0;


import {Test, console2 as console, stdStorage, StdStorage} from "forge-std/Test.sol";

contract SafProxyFactoryTest is Test{
    uint256 internal bobPK = 0xB0B;
    uint256 internal carlaPK = 0xCA414;
    address public bob;
    address public carla;

    function setUp() public virtual{
        bob = vm.addr(bobPK);
        carla = vm.addr(carlaPK);
    }

    function _hashBytes(bytes memory data) private pure returns (bytes32 hash) {
        assembly {
            hash := keccak256(add(data, 0x20), mload(data))
        }
    }

    function testHash() public {
        bytes32 hash1 = _hashBytes(abi.encode(bob));
        bytes32 hash2 = keccak256(abi.encode(bob));
        assertEq(hash1, hash2);
        // console.log("Hash of bob:", hash);
    }
}
