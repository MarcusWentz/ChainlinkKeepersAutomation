// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

contract ERC20TokenContract is ERC20('Chainlink', 'LINK') {}

contract DEXOrderBookDAI {

    address public immutable Owner;

    constructor() {
        Owner = msg.sender;
    }

    modifier ContractOwnerCheck() {
        require(msg.sender == Owner, "Only contract owner (deployer) can access this function.");
        _;
    }

    address public DERC20TokenAddressMatic = 0xfe4F5145f6e09952a5ba9e956ED0C25e3Fa4c7F1; //LET 1 DERC20 = 1 DAI
    ERC20TokenContract tokenObject = ERC20TokenContract(DERC20TokenAddressMatic);

    function addDAIToPool() ContractOwnerCheck public {
        require(tokenObject.balanceOf(address(Owner)) >= 3, "Must have 3*10^-18 LINK for pool creation!");
        require(tokenObject.allowance(Owner,address(this)) >= 3, "Must allow 3 tokens from your wallet in the ERC20 contract!");
        tokenObject.transferFrom(Owner, address(this), 3); //NEED TO APPROVE EVERY TIME BEFORE YOU SEND LINK FROM THE ERC20 CONTRACT!
    }
    function addMATICToPool() ContractOwnerCheck public payable{
        require(msg.value == 1, "You need to have msg.value as 2 to payout worker biweekly!"); //24 = (12 months * 2 time/month * 1 WEI/time)
    }

    function removeDAIFromPool() ContractOwnerCheck public {
         tokenObject.transfer(msg.sender, 3); // 2 LINK from contract to user
    }
    function removeMATICFromPool() ContractOwnerCheck public {
        payable(msg.sender).transfer(1); 
    }

    function swapMATICforDAI() public payable{
        require(tokenObject.balanceOf(address(this)) >= 3, "Must have 3*10^-18 DAI!");
        require(msg.value == 1, "MSG.VALUE ERROR");
        tokenObject.transfer(msg.sender, 3); // 2 LINK from contract to user
    }
    function swapDAIforMATIC() public {
        require(address(this).balance > 0,"No funds in contract yet from Owner.");
        require(tokenObject.balanceOf(address(Owner)) >= 3, "Must have 3*10^-18 LINK for pool creation!");
        require(tokenObject.allowance(Owner,address(this)) >= 3, "Must allow 3 tokens from your wallet in the ERC20 contract!");
        tokenObject.transfer(msg.sender, 3); // 2 LINK from contract to user
        payable(msg.sender).transfer(1); 
    }

    function getDAIBalance() public view returns (uint) {
        return tokenObject.balanceOf(address(this));
    }
    function getMaticBalance() public view returns (uint) {
        return address(this).balance;
    }

}

// contract LimitOrderMATICForDAI is KeeperCompatibleInterface {
contract LimitOrderMATICForDAI {

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

    modifier LimitOrderExists() {
        require(address(this).balance > 0,"No funds in contract yet from Owner.");
        _;
    }

    function CreateDAILimitOrder() public payable ContractOwnerCheck {
        require(msg.value == 1, "You need to have msg.value as 2 to payout worker biweekly!"); //24 = (12 months * 2 time/month * 1 WEI/time)
    }
    function CreateMATICLimitOrder() public ContractOwnerCheck {
        require(tokenObject.balanceOf(address(Owner)) >= 3, "Must have 3*10^-18 LINK for pool creation!");
        require(tokenObject.allowance(Owner,address(this)) >= 3, "Must allow 3 tokens from your wallet in the ERC20 contract!");
        tokenObject.transferFrom(Owner, address(this), 3); //NEED TO APPROVE EVERY TIME BEFORE YOU SEND LINK FROM THE ERC20 CONTRACT!
    }

    function CancelDAILimitOrder() public ContractOwnerCheck LimitOrderExists{
        payable(Owner).transfer(1); 
    }
    function CancelMATICLimitOrder() public ContractOwnerCheck LimitOrderExists{
        tokenObject.transfer(msg.sender, 2); // 2 LINK from contract to user
    }

    function SwapMATICforDAI() public ContractOwnerCheck {
        dexOrderBookDAI.swapMATICforDAI{value: 1}();
    }
    function SwapDAIforMATIC() public ContractOwnerCheck {
        tokenObject.approve(addressdexOrderBookDAI,3);
        dexOrderBookDAI.swapDAIforMATIC();
    }

    function getMaticBalance() public view returns (uint) {
        return address(this).balance;
    }
    function getDAIBalance() public view returns (uint) {
        return tokenObject.balanceOf(address(this));
    }

    // // function checkUpkeep(bytes calldata) LimitOrderExists external override returns (bool upkeepNeeded, bytes memory) {
    // //     require(true, "Value matches limit order.");
    // //     require(address(0x66C1d8A5ee726b545576A75380391835F8AAA43c).balance == 1*(10**18),"Not enough funds in pool to swap.");
    // //     upkeepNeeded = true; 
    // // }

    // function performUpkeep(bytes calldata) external override {
    //     swapContract.swapDAIforMATIC();
    // }
}
