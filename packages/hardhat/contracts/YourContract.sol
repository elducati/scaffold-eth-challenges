pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";

// import "@openzeppelin/contracts/access/Ownable.sol";
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract YourContract {
    // event SetPurpose(address sender, string purpose);
    event Deposit(address indexed sender, uint256 amount, uint256 balance);
    event SubmitTransaction(
        address indexed owner,
        uint256 indexed txIndex,
        address indexed to,
        uint256 value,
        bytes data
    );
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public numConfirmationRequired;

    struct Transaction {
      address to;
      uint value;
      bytes data;
      bool executed;
      uint numConfirmations;
    }
    // mapping from tx index => owner => bool
    mapping(uint => mapping(address => bool)) public isConfirmed;
    Transaction[] public transactions;

    modifier onlyOwner() {
      require(isOwner[msg.sender], "not owner");
      _;
    }
    modifier txExists(uint _txIndex) {
      require(_txIndex < transactions.length, "tx does not exist");
      _;
    }
    modifier notExecuted(uint _txIndex) {
      require(!transactions[_txIndex].executed,"tx already executed");
      _;
    }
    modifier notConfirmed(uint _txIndex) {
      require(!isConfirmed[_txIndex][msg.sender],"tx already confirmed");
      _;
    }

    string public purpose = "Building Multi-sig Apps!!!";

    constructor(address[] memory _owners, uint _numConfirmationsRequired) {
        // what should we do on deploy?
        require(_owners.length > 0, "owners required");
        require(
          _numConfirmationsRequired > 0 &&
          _numConfirmationsRequired <= owners.length,
          "invalid number of required confirmations"
        );
        for (uint i = 0; i < _owners.length; i++) {
          address owner = _owners[i];

          require(owner != address(0), "invalid owner");
          require(!isOwner[owner], "owner not unique");

          isOwner[owner] = true;
          owners.push(owner);
        }
        numConfirmationRequired = _numConfirmationsRequired;
    }

    function setPurpose(string memory newPurpose) public {
        purpose = newPurpose;
        console.log(msg.sender, "set purpose to", purpose);
        // emit SetPurpose(msg.sender, purpose);
    }
}
