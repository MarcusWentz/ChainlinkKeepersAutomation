// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

contract ERC20TokenContract is ERC20('Dummy ERC20', 'DERC20') {}

contract DEXOrderBookDAI {

    address public immutable Owner;
    uint public mockMATICpricefeedValue;
    AggregatorV3Interface internal priceFeedMATIC;

    constructor() {
        Owner = msg.sender;
        priceFeedMATIC = AggregatorV3Interface(0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada);
    }

    // function getLatestMATICPrice() public view returns (uint) {  // FOR PRODUCTION
    // (
    //     uint80 roundID, int price, uint startedAt, uint timeStamp, uint80 answeredInRound) = priceFeedMATIC.latestRoundData();
    //     return uint(price*(10**10));
    // }

    function setForBuyingMATIC() public {
        mockMATICpricefeedValue = 2;
    }

    function setForSellingMATIC() public {
        mockMATICpricefeedValue = 3;
    }

    function getLatestMATICPrice() public view returns (uint) {
         return mockMATICpricefeedValue;
    }

    modifier ContractOwnerCheck() {
        require(msg.sender == Owner, "Only contract owner (deployer) can access this function.");
        _;
    }

    address public DERC20TokenAddressMatic = 0xfe4F5145f6e09952a5ba9e956ED0C25e3Fa4c7F1; //LET 1 DERC20 = 1 DAI
    ERC20TokenContract tokenObject = ERC20TokenContract(DERC20TokenAddressMatic);

    function addDAIToPool() ContractOwnerCheck public {
        require(tokenObject.balanceOf(address(Owner)) >= 3, "Must have 3 LINK for pool creation!");
        require(tokenObject.allowance(Owner,address(this)) >= 3, "Must allow 3 tokens from your wallet in the ERC20 contract!");
        tokenObject.transferFrom(Owner, address(this), 3); //NEED TO APPROVE EVERY TIME BEFORE YOU SEND LINK FROM THE ERC20 CONTRACT!
    }
    function addMATICToPool() ContractOwnerCheck public payable{
        require(msg.value == 1, "You need to have msg.value as 1!"); //24 = (12 months * 2 time/month * 1 WEI/time)
    }

    function removeDAIFromPool() ContractOwnerCheck public {
        tokenObject.transfer(msg.sender, tokenObject.balanceOf(address(this))); // 2 LINK from contract to user
    }
    function removeMATICFromPool() ContractOwnerCheck public {
        payable(msg.sender).transfer(address(this).balance); 
    }

    function swapMATICforDAI() public payable{
        require(tokenObject.balanceOf(address(this)) >= 3, "Must have 3 DAI!");
        require(msg.value == 1, "MSG.VALUE ERROR");
        tokenObject.transfer(msg.sender, 3); // 2 LINK from contract to user
    }
    function swapDAIforMATIC() public {
        require(address(this).balance > 0,"No funds in contract yet from Owner.");
        require(tokenObject.balanceOf(address(msg.sender)) >= 2, "Must have 2 LINK for pool creation!");
        require(tokenObject.allowance(msg.sender,address(this)) >= 2, "Must allow 2 tokens from your wallet in the ERC20 contract!");
        tokenObject.transferFrom(msg.sender, address(this), 2); //NEED TO APPROVE EVERY TIME BEFORE YOU SEND LINK FROM THE ERC20 CONTRACT!
        payable(msg.sender).transfer(1); 
    }

    function getDAIBalance() public view returns (uint) {
        return tokenObject.balanceOf(address(this));
    }
    function getMaticBalance() public view returns (uint) {
        return address(this).balance;
    }

}

contract LimitOrdersMATIC_DAI is KeeperCompatibleInterface{

    address public immutable Owner;
    address public immutable addressdexOrderBookDAI;
    DEXOrderBookDAI public dexOrderBookDAI;

    address public DERC20TokenAddressMatic = 0xfe4F5145f6e09952a5ba9e956ED0C25e3Fa4c7F1; //LET 1 DERC20 = 1 DAI
    ERC20TokenContract tokenObject = ERC20TokenContract(DERC20TokenAddressMatic);

    fallback() external payable {} //NEEDED FOR ACCEPTING INCOMING MATIC.
    receive() external payable {}  //NEEDED FOR ACCEPTING INCOMING MATIC WITH EMPTY CALL DATA.

    constructor(address _dexOrderBookDAI) {
        addressdexOrderBookDAI= _dexOrderBookDAI;
        Owner = msg.sender;
        dexOrderBookDAI = DEXOrderBookDAI(_dexOrderBookDAI);
    }

    modifier ContractOwnerCheck() {
        require(msg.sender == Owner, "Only contract owner (deployer) can access this function.");
        _;
    }

    function LimitSellMATIC() public payable ContractOwnerCheck {
        require(msg.value == 1, "You need to have msg.value as 1!"); //24 = (12 months * 2 time/month * 1 WEI/time)
    }
    function LimitBuyMATIC() public ContractOwnerCheck {
        require(tokenObject.balanceOf(address(msg.sender)) >= 2, "Must have 2 LINK for pool creation!");
        require(tokenObject.allowance(msg.sender,address(this)) >= 2, "Must allow 2 tokens from your wallet in the ERC20 contract!");
        tokenObject.transferFrom(msg.sender, address(this), 2); //NEED TO APPROVE EVERY TIME BEFORE YOU SEND LINK FROM THE ERC20 CONTRACT!
        tokenObject.approve(addressdexOrderBookDAI,2);
    }

    function ClaimAllMATIC() public ContractOwnerCheck {
        require(address(this).balance > 0,"No MATIC in contract yet from Owner.");
        payable(msg.sender).transfer(1); 
    }
    function ClaimAllDAI() public ContractOwnerCheck{
        require(tokenObject.balanceOf(address(this)) > 0, "No DAI in contract yet from Owner.");
        tokenObject.transfer(msg.sender, 2); // 2 LINK from contract to user
    }

    function getMaticBalance() public view returns (uint) {
        return address(this).balance;
    }
    function getDAIBalance() public view returns (uint) {
        return tokenObject.balanceOf(address(this));
    }

    function checkUpkeep(bytes calldata) external override returns (bool upkeepNeeded, bytes memory) {
        require(address(this).balance > 0 || tokenObject.balanceOf(address(this)) > 0, "No DAI or MATIC limit order opened yet,");
        require(dexOrderBookDAI.getLatestMATICPrice() == 2 || dexOrderBookDAI.getLatestMATICPrice() == 3, "MATIC MUST BE 2 or 3 DAI TO DO THIS!");
        upkeepNeeded = true; 
    }
    function performUpkeep(bytes calldata) external override {
        if(dexOrderBookDAI.getLatestMATICPrice() == 2) {
            dexOrderBookDAI.swapDAIforMATIC();
        }
        if(dexOrderBookDAI.getLatestMATICPrice() == 3 ){
            dexOrderBookDAI.swapMATICforDAI{value: 1}();
        }
    }
}
