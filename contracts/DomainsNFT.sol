// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

// We first import some OpenZeppelin Contracts.
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import {StringUtils} from "./libraries/StringUtils.sol";
// We import another help function
import {Base64} from "./libraries/Base64.sol";

import "hardhat/console.sol";

error NotOwner();
error AlreadyRegistered();
error InvalidName(string name);

// We inherit the contract we imported. This means we'll have access
// to the inherited contract's methods.
contract Domains is ERC721URIStorage {
    // Magic given to us by OpenZeppelin to help us keep track of tokenIds.
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address public immutable i_owner;
    string public tld;
    // We'll be storing our NFT images on chain as SVGs
    string svgPartOne =
        '<svg xmlns="http://www.w3.org/2000/svg" width="270" height="270" fill="none"><path fill="url(#B)" d="M0 0h270v270H0z"/><defs><filter id="A" color-interpolation-filters="sRGB" filterUnits="userSpaceOnUse" height="270" width="270"><feDropShadow dx="0" dy="1" stdDeviation="2" flood-opacity=".225" width="200%" height="200%"/></filter></defs><path fill="none" stroke="#1DD4FF" stroke-width="6" stroke-miterlimit="10" d="M28.925,63.961 c0-19.375,15.708-35.083,35.082-35.083"/><path fill="none" stroke="#59FF22" stroke-width="6" stroke-miterlimit="10" d="M22.965,63.958 c0-22.662,18.373-41.036,41.035-41.036"/><path fill="none" stroke="#FFED12" stroke-width="6" stroke-miterlimit="10" d="M17.381,63.958c0-25.746,20.874-46.62,46.619-46.62"/><path fill="none" stroke="#FF9F2C" stroke-width="6" stroke-miterlimit="10" d="M11.548,63.958c0-28.969,23.484-52.453,52.452-52.453"/><path fill="none" stroke="#FF2929" stroke-width="7" stroke-miterlimit="10" d="M5.298,63.958C5.298,31.537,31.58,5.255,64,5.255" /><path fill="none" stroke="#E31FFF" stroke-width="6" stroke-miterlimit="10" d="M40.134,64c0-13.244,10.737-23.982,23.981-23.982" /><path fill="none" stroke="#3131FF" stroke-width="6" stroke-miterlimit="10" d="M34.322,64c0-16.455,13.339-29.794,29.793-29.794" /><defs><linearGradient id="B" x1="0" y1="0" x2="270" y2="270" gradientUnits="userSpaceOnUse"><stop stop-color="#c5eee"/><stop offset="1" stop-color="#0cd7f4" stop-opacity=".99"/></linearGradient></defs><text x="32.5" y="231" font-size="27" fill="#fff" filter="url(#A)" font-family="Plus Jakarta Sans,DejaVu Sans,Noto Color Emoji,Apple Color Emoji,sans-serif" font-weight="bold">';
    string svgPartTwo = "</text></svg>";

    mapping(string => address) public domainToOwner;
    mapping(address => string) public ownerToDomain;
    mapping(uint256 => string) public names;
    mapping(address => string[]) public ownerToDomains;

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }

    constructor(string memory _tld)
        payable
        ERC721("Bitcoinera Name Service", "BNS")
    {
        i_owner = msg.sender;
        tld = string(abi.encodePacked(".", _tld));
        console.log("%s name service deployed", _tld);
    }

    function register(string calldata name) public payable {
        if (domainToOwner[name] != address(0)) revert AlreadyRegistered();
        if (!valid(name)) revert InvalidName(name);
        uint256 _price = price(name);
        require(msg.value >= _price, "Not enough Matic paid");

        // Combine the name passed into the function  with the TLD
        string memory _name = string(abi.encodePacked(name, tld));
        // Create the SVG (image) for the NFT with the name
        string memory finalSvg = string(
            abi.encodePacked(svgPartOne, _name, svgPartTwo)
        );
        uint256 newTokenId = _tokenIds.current();
        uint256 length = StringUtils.strlen(name);
        string memory strLen = Strings.toString(length);

        console.log(
            "Registering %s%s on the contract with tokenID %d",
            name,
            tld,
            newTokenId
        );

        // Create the JSON metadata of our NFT. We do this by combining strings and encoding as base64
        string memory json = Base64.encode(
            abi.encodePacked(
                '{"name": "',
                _name,
                '", "description": "A domain on the BNS (Bitcoinera Name Service)", "image": "data:image/svg+xml;base64,',
                Base64.encode(bytes(finalSvg)),
                '","length":"',
                strLen,
                '"}'
            )
        );

        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log(
            "\n--------------------------------------------------------"
        );
        console.log("Final tokenURI", finalTokenUri);
        console.log(
            "--------------------------------------------------------\n"
        );

        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, finalTokenUri);
        domainToOwner[name] = msg.sender;
        ownerToDomain[msg.sender] = name;
        ownerToDomains[msg.sender].push(name);

        _tokenIds.increment();
        names[newTokenId] = name;
    }

    function withdraw() public onlyOwner {
        uint amount = address(this).balance;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Failed to withdraw Matic");
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

    function getAddress(string calldata name) public view returns (address) {
        // Check that the owner is the transaction sender
        return domainToOwner[name];
    }

    function setDomain(string calldata _oldName, string calldata _newName)
        public
        payable
    {
        string[] memory allDomains = ownerToDomains[msg.sender];
        for (uint256 i = 0; i < allDomains.length; i++) {
            if (
                keccak256(abi.encodePacked(allDomains[i])) ==
                keccak256(abi.encodePacked(_oldName))
            ) {
                console.log("Changing domain %s to %s", _oldName, _newName);
                allDomains[i] = _newName;
                ownerToDomains[msg.sender] = allDomains;
                break;
            }
        }
    }

    function getDomain() public view returns (string memory) {
        return string(abi.encodePacked(ownerToDomain[msg.sender], tld));
    }

    function getDomains() public view returns (string[] memory) {
        return ownerToDomains[msg.sender];
    }

    function getAllNames() public view returns (string[] memory) {
        console.log("Getting all names from contract");
        string[] memory allNames = new string[](_tokenIds.current());
        for (uint256 i = 0; i < _tokenIds.current(); i++) {
            allNames[i] = names[i];
            console.log("Name for token %d is %s", i, allNames[i]);
        }

        return allNames;
    }

    // check if the domain is too long for the contract to handle
    function valid(string calldata name) public pure returns (bool) {
        return StringUtils.strlen(name) >= 3 && StringUtils.strlen(name) <= 10;
    }
}
