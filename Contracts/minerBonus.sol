// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

contract minerBonus is KeeperCompatibleInterface{

    address public immutable Owner; 
    uint public newBlockNumber = block.number + 1;

    constructor() {
        Owner = msg.sender;
    }

    modifier senderIsOwner() {
        require(Owner == msg.sender, "Only the Owner can access this function.");
        _;
    }

    modifier newBlockCreated() {
        require(block.number >= newBlockNumber, "Need to wait for new block before donating bonus to miner.");
        _;
    }

    modifier validDeposit() {
        require(msg.value > 0, "MSG.VALUE must be greater than 0.");
        _;
    }

    modifier contractFunded() {
        require(address(this).balance > 0, "Contract balance must be greater than 0.");
        _;
    }

    function validUpKeep() public view returns(bool) {
        return (block.number >= newBlockNumber) && (address(this).balance > 0);
    }

    function deposit() public payable senderIsOwner validDeposit {}

    function withdraw() public payable senderIsOwner contractFunded { 
        payable(msg.sender).transfer(address(this).balance); 
    }

    function minerBonusEveryBlock() public newBlockCreated contractFunded {
        newBlockNumber = block.number + 1;
        payable(block.coinbase).transfer(1);
    }

    function checkUpkeep(bytes calldata) external override returns (bool upkeepNeeded, bytes memory) {
        upkeepNeeded = validUpKeep();
    } 

    function performUpkeep(bytes calldata) external override {
        minerBonusEveryBlock();
    }

}
