// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

interface INOSTRATOOLS {
    function sendToTreasury() external returns (bool);
}

contract Treasury is Initializable{
    
    INOSTRATOOLS private _scissors;
    INOSTRATOOLS private _coffees;
    INOSTRATOOLS private _tomatoes;
    address public _manager;
    address public _competition_helper;

    //TODO: Add Events

    modifier onlyManagerOrHelper() {
        require( _manager == msg.sender || _competition_helper == msg.sender, "Caller is not the Manager or the Helper" );
        _;
    }
    modifier onlyManager() {
        require( _manager == msg.sender , "Caller is not the Manager" );
        _;
    }

    function initializer(address BarberShopNFT, 
                         address DinerNFT, 
                         address GroceriesNFT, 
                         address competition_helper, 
                         address manager)
                         public initializer{
        _scissors = INOSTRATOOLS(BarberShopNFT);
        _coffees = INOSTRATOOLS(DinerNFT);
        _tomatoes = INOSTRATOOLS(GroceriesNFT);
        _competition_helper = competition_helper;
        _manager = manager;
    }   

    function withdrawFromContracts() public onlyManagerOrHelper() {
        // EMIT EVENT
        _scissors.sendToTreasury();
        _coffees.sendToTreasury();
        _tomatoes.sendToTreasury();

    }

    function managePrize( address _token ) external onlyManager() {

        uint256 amount = (getTotalTreasuryValue()*20)/100;
        IERC20( _token ).transferFrom(address(this), _manager, amount);
       // emit PrizeManaged( _token, amount );
    }

    function manageAssets( address _token, uint256 _amount ) external onlyManager() {
        require(_amount <= getTotalTreasuryValue(), 'Not enough funds');
        IERC20( _token ).transferFrom(address(this), _manager, _amount);
       // emit TreasuryManaged( _token, _amount );
    }

    function setCompetitionHelper(address competition_helper) public onlyManager(){
        _competition_helper = competition_helper;

    }

    function setManager(address manager) public view {
        manager = _manager;

    }

    function getTotalTreasuryValue() public view returns (uint256){

        return address(this).balance;

    }

    

}