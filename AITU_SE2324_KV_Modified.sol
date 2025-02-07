// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AITU_SE2324_KV_Modified is ERC20, Ownable {
    struct TransactionInfo {
        address sender;
        address receiver;
        uint256 amount;
        uint256 timestamp;
    }

    TransactionInfo public latestTransaction;

    event TransactionRecorded(address indexed sender, address indexed receiver, uint256 amount, uint256 timestamp);

    constructor(uint256 _initialSupply, address _owner) ERC20("AITU_SE2324_KV", "AITU") Ownable(_owner) {
        _mint(_owner, _initialSupply * 10 ** decimals());
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        bool success = super.transfer(to, amount);
        if (success) _updateTransaction(msg.sender, to, amount);
        return success;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        bool success = super.transferFrom(from, to, amount);
        if (success) _updateTransaction(from, to, amount);
        return success;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function _updateTransaction(address from, address to, uint256 amount) internal {
        latestTransaction = TransactionInfo({
            sender: from,
            receiver: to,
            amount: amount,
            timestamp: block.timestamp
        });
        emit TransactionRecorded(from, to, amount, block.timestamp);
    }

    function getLatestTransactionTimestamp() public view returns (uint256) {
        return latestTransaction.timestamp;
    }
}
