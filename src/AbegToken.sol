// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "solmate/utils/MerkleProofLib.sol";
import "solmate/tokens/ERC20.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Merkle is ERC20 {
    bytes32 root;

    constructor(bytes32 _root) ERC20("ABEG", "ABG", 18) {
        root = _root;
    }

    mapping(address => bool) public hasClaimed;

    function claim(
        address _claimer,
        uint _amount,
        bytes32[] calldata _proof
    ) external returns (bool success) {
        require(!hasClaimed[_claimer], "already claimed");
        bytes32 leaf = keccak256(abi.encodePacked(_claimer, _amount));
        bool verificationStatus = MerkleProofLib.verify(_proof, root, leaf);
        require(verificationStatus, "not whitelisted");
        hasClaimed[_claimer] = true;
        _mint(_claimer, _amount);
        success = true;
    }
}
