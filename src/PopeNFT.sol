// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "solmate/tokens/ERC1155.sol";
import "solmate/utils/MerkleProofLib.sol";

contract PopeNFT is ERC1155 {
    bytes32 public root;
    mapping(address => bool) public hasClaimed;

    constructor(bytes32 _root) {
        root = _root;
    }

    function uri(uint256 id) public view virtual override returns (string memory) {
        return "";
    }

    // function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {
    //     if (_i == 0) {
    //         return "0";
    //     }
    //     uint256 j = _i;
    //     uint256 len;
    //     while (j != 0) {
    //         len++;
    //         j /= 10;
    //     }
    //     bytes memory bstr = new bytes(len);
    //     uint256 k = len - 1;
    //     while (_i != 0) {
    //         bstr[k] = byte(uint8(48 + _i % 10));
    //         k--;
    //         _i /= 10;
    //     }
    //     return string(bstr);
    // }

    function claim(
        address _claimer,
        uint256 _tokenId,
        uint256 _amount,
        bytes32[] calldata _proof
    ) external returns (bool success) {
        require(!hasClaimed[_claimer], "already claimed");
        bytes32 leaf = keccak256(abi.encodePacked(_claimer, _tokenId, _amount));
        bool verificationStatus = MerkleProofLib.verify(_proof, root, leaf);
        require(verificationStatus, "not whitelisted");
        hasClaimed[_claimer] = true;
        _mint(_claimer, _tokenId, _amount, "");
        success = true;
    }
}