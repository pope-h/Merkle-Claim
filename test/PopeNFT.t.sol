// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, stdJson} from "forge-std/Test.sol";
import {PopeNFT} from "../src/PopeNFT.sol";

contract PopeNFTTest is Test {
    using stdJson for string;
    PopeNFT public popeNFT;
    struct Result {
        bytes32 leaf;
        bytes32[] proof;
    }

    struct User {
        address user;
        uint256 tokenId;
        uint256 amount;
    }
    Result public result;
    User public user;
    bytes32 root = 0x6adc511d98afd6a47fe0a19f2bdd346e2b935c7b4c7bcb421e0e8f4bd957ca5e;
    address user1 = 0x2D5f8CF3B35276190Cd421Bf038C96Fdfa5Cf780;

    function setUp() public {
        // Ensure the URI is valid and accessible
        // string memory uri = "https://ipfs.io/ipfs/bafybeiclbmtydqja2tskwur6xvrdfutd6t7f4bqyy6fnysszc4mtjem344/0";
        popeNFT = new PopeNFT(root);
        string memory _root = vm.projectRoot();
        string memory path = string.concat(_root, "/merkle_tree.json");

        string memory json = vm.readFile(path);
        string memory data = string.concat(_root, "/address_data.json");

        string memory dataJson = vm.readFile(data);

        bytes memory encodedResult = json.parseRaw(
            string.concat(".", vm.toString(user1))
        );
        user.user = vm.parseJsonAddress(
            dataJson,
            string.concat(".", vm.toString(user1), ".address")
        );
        user.tokenId = vm.parseJsonUint(
            dataJson,
            string.concat(".", vm.toString(user1), ".tokenId")
        );
        user.amount = vm.parseJsonUint(
            dataJson,
            string.concat(".", vm.toString(user1), ".amount")
        );
        result = abi.decode(encodedResult, (Result));
        console2.logBytes32(result.leaf);
    }

    function testClaimed() public {
        bool success = popeNFT.claim(user.user, user.tokenId, user.amount, result.proof);
        assertTrue(success);
    }

    function testAlreadyClaimed() public {
        popeNFT.claim(user.user, user.tokenId, user.amount, result.proof);
        vm.expectRevert("already claimed");
        popeNFT.claim(user.user, user.tokenId, user.amount, result.proof);
    }

    function testIncorrectProof() public {
        bytes32[] memory fakeProof = new bytes32[](0);

        vm.expectRevert("not whitelisted");
        popeNFT.claim(user.user, user.tokenId, user.amount, fakeProof);
    }
}