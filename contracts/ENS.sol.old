// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

import {StringUtils} from "./libraries/StringUtils.sol";
import "hardhat/console.sol";

contract Domains {
    // Here's our domain TLD!
    string public tld;

    mapping(string => address) public domains;
    mapping(address => string) public ownerToDomain;

    // We make the contract "payable" by adding this to the constructor
    constructor(string memory _tld) payable {
        tld = string(abi.encodePacked(".", _tld));
        console.log("%s name service deployed", _tld);
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

    // This function will give us the price of a domain based on length
    function price(string calldata name) public pure returns (uint) {
        uint len = StringUtils.strlen(name);
        require(len > 0);
        if (len == 3) {
            return 5 * 10**17; // 5 MATIC = 5 000 000 000 000 000 000 (18 decimals). We're going with 0.5 Matic cause the faucets don't give a lot
        } else if (len == 4) {
            return 3 * 10**17; // To charge smaller amounts, reduce the decimals. This is 0.3
        } else {
            return 1 * 10**17;
        }
    }

    function register(string calldata _domain) public payable {
        // Check that the name is unregistered (explained in notes)
        require(domains[_domain] == address(0));

        uint _price = price(_domain);

        // Check if enough Matic was paid in the transaction
        require(msg.value >= _price, "Not enough Matic paid");

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
        return string(abi.encodePacked(ownerToDomain[msg.sender], tld));
    }
}
