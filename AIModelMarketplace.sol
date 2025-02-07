// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract AIModelMarketplace is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public paymentToken;

    struct Model {
        string name;
        string description;
        uint256 price;
        address creator;
        bool isSold;
    }

    Model[] public models;
    mapping(uint256 => mapping(address => bool)) public hasPurchased;

    event ModelListed(uint256 indexed modelId, string name, uint256 price, address indexed creator);
    event ModelPurchased(uint256 indexed modelId, address indexed buyer);

    constructor(address _tokenAddress) Ownable(msg.sender) {
        paymentToken = IERC20(_tokenAddress);
    }

    function listModel(string memory name, string memory description, uint256 price) public {
        require(price > 0, "Price must be > 0");
        models.push(Model(name, description, price, msg.sender, false));
        emit ModelListed(models.length - 1, name, price, msg.sender);
    }

    function purchaseModel(uint256 modelId) public {
        require(modelId < models.length, "Invalid model ID");
        require(!hasPurchased[modelId][msg.sender], "Already purchased");
        Model storage model = models[modelId];
        require(!model.isSold, "Model already sold");

        paymentToken.safeTransferFrom(msg.sender, model.creator, model.price);
        hasPurchased[modelId][msg.sender] = true;
        model.isSold = true;

        emit ModelPurchased(modelId, msg.sender);
    }

    function getUserBalance(address user) public view returns (uint256) {
        return paymentToken.balanceOf(user);
    }

    function getModelCount() public view returns (uint256) {
        return models.length;
    }
}
