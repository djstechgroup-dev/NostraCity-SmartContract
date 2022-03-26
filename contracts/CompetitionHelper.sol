// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;


import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract CompetitionHelper is Initializable{

    INOSTRATOOLS _scissors;
    INOSTRATOOLS _coffees;
    INOSTRATOOLS _tomatoes;
    ITreasury _vault;
    address public _winner;

    modifier onlyManager() {
        require( _manager == msg.sender , "Caller is not the Manager" );
        _;
    }

	mapping(address => uint256) public businessToScore;
    mapping(address => bool) public businessIsWinner;

    function initializer(address BarberShop, 
                         address Diner, 
                         address GroceryStore, 
                         address treasury) 
                         public initializer{
       _scissors = BarberShop;
       _coffees =  Diner;
       _tomatoes = GroceryStore;
       _vault = treasury;
    }
    /**
     */
    function finishSeasonCleanUp() public onlyManager(){
        //Pause NFTs
        _scissors.pause();
        _coffees.pause();
        _tomatoes.pause();
        //Run the Treasury Function to retrieve the Balance fromm the NFTs
        _vault.withdrawFromContracts();
        //Calculate Winner
        _winner = calculateWinner();
        //TODO: Emit event.
    }
    /**
     */
    function calculateWinner() public view {
        businessToScore[_scissors.address] = INOSTRATOOLS(_scissors.getCurrentScore());
        businessToScore[_coffees.address] = INOSTRATOOLS(_coffees.getCurrentScore());
        businessToScore[_tomatoes.address] = INOSTRATOOLS(_tomatoes.getCurrentScore());
        //Find if there are three way tie
        if (businessToScore[_scissors.address] 
            == businessToScore[_coffees.address] 
            ==  businessToScore[_tomatoes.address] ){
            businessIsWinner[_scissors.address] = true;
            businessIsWinner[_coffees.address] = true;
            businessIsWinner[_tomatoes.address] = true;
        }
        else{
        //Find the winner and ties
         if(businessToScore[_scissors.address] > businessToScore[_coffees.address] ) {
            if(businessToScore[_scissors.address] > businessToScore[_tomatoes.address]){
                businessIsWinner[_scissors.address] = true;
            }
            else if (businessToScore[_scissors.address] == businessToScore[_tomatoes.address]){
                businessIsWinner[_scissors.address] = true;
                businessIsWinner[_tomatoes.address] = true;
            }
            else{
               businessIsWinner[_tomatoes.address] = true;
               }
        } 
        else if (businessToScore[_scissors.address] == businessToScore[_coffees.address]
                && businessToScore[_scissors.address] > businessToScore[_tomatoes.address] ){
                    businessIsWinner[_scissors.address] = true;
                    businessIsWinner[_coffees.address] = true;
        }
        else {
            if(businessToScore[_coffees.address] > businessToScore[_tomatoes.address]){
                businessIsWinner[_coffees.address] = true;
                }
            else if (businessToScore[_coffees.address] == businessToScore[_tomatoes.address]){
                    businessIsWinner[_coffees.address] = true;
                    businessIsWinner[_tomatoes.address] = true;
            }
            else{ 
                businessIsWinner[_tomatoes.address]= true;
            }
               
        }
        }

    }

    
    /**
     */
    function isAddressWinner(address business) returns (bool){
        return businessIsWinner[business]:
    }
   
}