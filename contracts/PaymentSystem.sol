pragma solidity ^0.8.0;

import "./MyToken.sol";

contract PaymentSystem {
    MyToken private token;

    // Struct for representing a payment
    struct Payment {
        uint256 amount;
        address buyer;
        address seller;
        uint256 timestamp;
    }

    // Mapping of seller addresses to their name
    mapping(address => string) public sellers;

    // Mapping of buyer addresses to their name
    mapping(address => string) public buyers;

    // Mapping of buyer addresses to their payments
    mapping(address => Payment[]) public paymentsByBuyer;

    // Mapping of seller addresses to their payments
    mapping(address => Payment[]) public paymentsBySeller;

    // Event for recording new buyer registration
    event NewBuyerRegistered(address buyer, string name);

    // Event for recording new payment
    event NewPayment(address indexed buyer, address indexed seller, uint256 amount, uint256 timestamp);

    constructor(address _tokenAddress) {
        token = MyToken(_tokenAddress);
    }

    // Function to register a new buyer
    function registerBuyer(string memory _name) public {
        buyers[msg.sender] = _name;
        emit NewBuyerRegistered(msg.sender, _name);
    }

    // Function to register a new seller
    function registerSeller(string memory _name) public {
        sellers[msg.sender] = _name;
    }

    // Function to make a payment to a seller
    function makePayment(address _seller, uint256 _amount) public {
        require(token.allowance(msg.sender, address(this)) >= _amount, "Insufficient allowance");
        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");

        Payment memory payment = Payment(_amount, msg.sender, _seller, block.timestamp);
        paymentsByBuyer[msg.sender].push(payment);
        paymentsBySeller[_seller].push(payment);

        emit NewPayment(msg.sender, _seller, _amount, block.timestamp);
    }

    // Function to view all payments made by a buyer
    function viewPaymentsByBuyer(address _buyer) public view returns (Payment[] memory) {
        require(msg.sender == _buyer || msg.sender == address(this), "Unauthorized");

        return paymentsByBuyer[_buyer];
    }

    // Function to view all payments received by a seller
    function viewPaymentsBySeller(address _seller) public view returns (Payment[] memory) {
        require(msg.sender == _seller || msg.sender == address(this), "Unauthorized");

        return paymentsBySeller[_seller];
    }

    // Function to view all payments made on the system
    function viewAllPayments() public view returns (Payment[] memory) {
        require(msg.sender == address(this), "Unauthorized");

        uint256 numPayments;
        for (uint256 i = 0; i < paymentsBySeller[msg.sender].length; i++) {
            numPayments += paymentsBySeller[msg.sender][i].amount;
        }

        Payment[] memory allPayments = new Payment[](numPayments);
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < paymentsBySeller[msg.sender].length; i++) {
            Payment[] memory sellerPayments = paymentsBySeller[msg.sender];

            for (uint256 j = 0; j < sellerPayments.length; j++) {
                allPayments[currentIndex] = sellerPayments[j];
                currentIndex++;
            }
        }

        return allPayments;
    }
}
