// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract RandomToken is ERC20 {
    constructor() ERC20("", "") {}

    function freeMint(uint256 amount) public {
        _mint(msg.sender, amount);
    }
}



contract TokenSender {
    using ECDSA for bytes32;

    // new mapping
    mapping(bytes32 => bool) executed;

    function transfer(
        address sender,
        uint256 amount,
        address recepient,
        address tokenContract,
        uint nonce,
        bytes memory signature
    ) public {
        // calculate the hash for all requisite values
        bytes32 messageHash = getHash(sender, amount, recepient, tokenContract, nonce);

        // convert it into signed message hash
        bytes32 signedMessageHash = messageHash.toEthSignedMessageHash();

        // require that this signature hasn't already been executed
        require(!executed[signedMessageHash],'Already Executed!');

        // Extract the original signers's address
        address signer = signedMessageHash.recover(signature);

        // make sure signer is the person on whose behalf we're executing transaction
        require(signer == sender, "Signature does not come from sender");

        // mark this signature as having been executed now and transfer tokens from sender(signer) to recepient
        executed[signedMessageHash] = true;
        bool sent = ERC20(tokenContract).transferFrom(sender, recepient, amount);

        require(sent,'Transfer failed');
    }

    // function to calculate keccak256 hash
    function getHash (
        address sender,
        uint256 amount,
        address recepient,
        address tokenContract,
        uint nonce
    ) public pure returns (bytes32) {
        return
        keccak256(
            abi.encodePacked(sender,amount,recepient,tokenContract, nonce)
        );
    }
}
