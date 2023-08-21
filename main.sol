// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

import {ParkingSpotManagement} from "contracts/ParkingSpotManagement.sol";
import {PriceConverter} from "contracts/PriceCalculator.sol";
//import {APIConsumer} from "contracts/APIConsumer.sol";

contract Main {
    uint256 slotsAmount = 20;
    uint256 parkingFeePerMinute = 5;
    bool priceconverter = true;
    

    using ParkingSpotManagement for mapping(uint256 => ParkingSpotManagement.ParkingSpot);
    using PriceConverter for uint256;

    mapping(uint256 => ParkingSpotManagement.ParkingSpot) public parkingSpots;
    uint256[] private  parkingSpotIds;
    uint256 public EthInUSD;

    constructor() {
         ParkingSpotManagement.generateParkingSpots(parkingSpots, parkingSpotIds, slotsAmount, parkingFeePerMinute);
        if(priceconverter){
           EthInUSD = PriceConverter.getConversionRate(1);
        }

    }
    
    function getParkingSpotIds() public view returns (uint256[] memory) {
        return parkingSpotIds;
    }

    function occupyParkingSpot(uint256 parkingSpotId) public {
        parkingSpots.occupyParkingSpot(parkingSpotId, msg.sender);
    }

    function getCurrentParkingFees(uint256 parkingSpotId) public view returns (uint256) {
        return parkingSpots.getCurrentParkingFees(parkingSpotId, parkingFeePerMinute );
    }
   // function ETHParkingFees(uint256 parkingSpotId) public view returns (uint256) {
    //    return PriceConverter.getEthAmount(getCurrentParkingFees(parkingSpotId));
   // }

    function releaseParkingSpot(uint256 parkingSpotId) public payable {
        parkingSpots.releaseParkingSpot(parkingSpotId, parkingFeePerMinute, payable(msg.sender));
    }
}
