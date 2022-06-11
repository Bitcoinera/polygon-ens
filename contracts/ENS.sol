// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

import "hardhat/console.sol";

contract Domains {
    mapping(string => address) public domains;
    mapping(address => string) public ownerToDomain;

    constructor() {
        console.log("Domains contract is here.");
    }

    modifier onlyOwner(address _sender) {
        // Check that the owner is the transaction sender
        if (
            keccak256(abi.encodePacked(ownerToDomain[_sender])) ==
            keccak256(abi.encodePacked(""))
        ) {
            revert("Not the owner of this domain");
        }
        _;
    }

    function register(string calldata _domain) public {
        // Check that the name is unregistered (explained in notes)
        require(domains[_domain] == address(0));
        domains[_domain] = msg.sender;
        ownerToDomain[msg.sender] = _domain;
    }

    function setRecords(string calldata _domain) public onlyOwner(msg.sender) {
        console.log(
            "Modifying domain",
            ownerToDomain[msg.sender],
            "for",
            _domain
        );
        // set new domain
        domains[_domain] = msg.sender;
        ownerToDomain[msg.sender] = _domain;
    }

    function getAddress(string calldata _domain) public view returns (address) {
        return domains[_domain];
    }

    function getDomain() public view returns (string memory) {
        return ownerToDomain[msg.sender];
    }
}
