// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

contract PayrollContractOneYear is KeeperCompatibleInterface {

    uint public lastTimeStamp;
    address public immutable Owner;

    constructor() {
      Owner = msg.sender;
      lastTimeStamp = block.timestamp; //Deployment Epoch timestamp.
    }

    modifier ContractOwnerCheck() {
        require(msg.sender == Owner, "Only contract owner (deployer) can access this function.");
        _;
    }

    function OwnerAddFundsEveryYear() public payable ContractOwnerCheck {
        require(msg.value == 2, "You need to have msg.value as 2 to payout worker biweekly!"); //112 = (56 weeks * 2 weeks/month * 1 WEI/month)
    }

    function checkUpkeep(bytes calldata) external override returns (bool upkeepNeeded, bytes memory) {
        require(address(this).balance > 0,"No funds in contract yet from Owner.");
        upkeepNeeded = (block.timestamp - lastTimeStamp) > 30; //Block every 30 seconds minimum. Full year: 1209600 = (14 days*86400 seconds)
    }

    function performUpkeep(bytes calldata) external override {
        lastTimeStamp = block.timestamp;
        payable(0x66C1d8A5ee726b545576A75380391835F8AAA43c).transfer(1); 
    }
}
