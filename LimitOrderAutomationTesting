// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

// import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

contract DEXOrderBookDAI {

    function addDAIToPool() public payable{
        require(msg.value == 2*(10**18), "ERROR");
    }

    function swapDAIforETH() public payable{
        // require(address(this).balance > 0,"No funds in contract yet from Owner.");
        //require DAI from Contract External
        // msg.sender.transfer(100);
        require(msg.value == 1*(10**18), "MSG.VALUE ERROR");
        payable(msg.sender).transfer(2 ether); 
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

}

// contract LimitOrderETHForDAI is KeeperCompatibleInterface {
contract LimitOrderETHForDAI {

    uint public lastTimeStamp;
    address public immutable Owner;
    DEXOrderBookDAI public dexOrderBookDAI;

    // Fallback is called when EtherStore sends Ether to this contract.
    fallback() external payable {}

    constructor(address _dexOrderBookDAI) {
        Owner = msg.sender;
        dexOrderBookDAI = DEXOrderBookDAI(_dexOrderBookDAI);
    }

    modifier ContractOwnerCheck() {
        require(msg.sender == Owner, "Only contract owner (deployer) can access this function.");
        _;
    }

    modifier LimitOrderExists() {
        require(address(this).balance > 0,"No funds in contract yet from Owner.");
        _;
    }

    function CreateLimitOrder() public payable ContractOwnerCheck {
        require(msg.value == 1*(10**18), "You need to have msg.value as 2 to payout worker biweekly!"); //24 = (12 months * 2 time/month * 1 WEI/time)
    }

    function swap() public payable ContractOwnerCheck {
        dexOrderBookDAI.swapDAIforETH{value: 1 ether }();
        // dexOrderBookDAI.addDAIToPool{value: 1 ether }();
    }

    function CancelLimitOrder() public ContractOwnerCheck LimitOrderExists{
        payable(Owner).transfer(1*(10**18)); 
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    // // function checkUpkeep(bytes calldata) LimitOrderExists external override returns (bool upkeepNeeded, bytes memory) {
    // //     require(true, "Value matches limit order.");
    // //     require(address(0x66C1d8A5ee726b545576A75380391835F8AAA43c).balance == 1*(10**18),"Not enough funds in pool to swap.");
    // //     upkeepNeeded = true; 
    // // }

    // function performUpkeep(bytes calldata) external override {
    //     swapContract.swapDAIforETH();
    // }
}
