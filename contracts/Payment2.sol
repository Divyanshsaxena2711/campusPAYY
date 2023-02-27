// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BITScoin.sol";
import "@openzeppelin/contracts/utils/Create2.sol";

contract PaymentSystem {
    address[] public sellers;
    mapping(address => bool) public buyers;

    event SellerRegistered(address indexed seller);
    event BuyerRegistered(address indexed buyer, address indexed wallet);

    function registerSeller(address seller) public {
        sellers.push(seller);
        emit SellerRegistered(seller);
    }

    function registerBuyer(string memory walletName, string memory password) public {
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, block.timestamp));
        address payable buyer = payable(Create2.deploy(
            0, 
            keccak256(abi.encodePacked(salt, walletName)), 
            type(BITScoin).creationCode
        ));
        BITScoin(buyer).transfer(msg.sender, 1000 * 10 ** 18);
        buyers[buyer] = true;
        emit BuyerRegistered(msg.sender, buyer);
    }
}
