// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

import {ParkingSpotManagement} from "contracts/ParkingSpotManagement.sol";

contract Main {
    uint256 slotsAmount = 10;
    uint256 parkingFeePerMinute = 5;

    using ParkingSpotManagement for mapping(uint256 => ParkingSpotManagement.ParkingSpot);

    mapping(uint256 => ParkingSpotManagement.ParkingSpot) public parkingSpots;
    uint256[] private parkingSpotIds;

    constructor() {
        ParkingSpotManagement.generateParkingSpots(parkingSpots, parkingSpotIds, slotsAmount, parkingFeePerMinute);
    }

    function getParkingSpotIds() public view returns (uint256[] memory) {
        return parkingSpotIds;
    }

    function getOccupiedParkingSpots() public view returns (uint256[] memory) {
        return ParkingSpotManagement.getOccupiedParkingSpots(parkingSpots);
    }

    function signalOccupancy(uint256 parkingSpotId) public {
        parkingSpots.signalOccupancy(parkingSpotId);
    }

  function signalRelease(uint256 parkingSpotId) public {
    parkingSpots.signalRelease(parkingSpotId, parkingFeePerMinute);
}


    function getCurrentParkingFees(uint256 parkingSpotId) public view returns (uint256) {
        return parkingSpots.getCurrentParkingFees(parkingSpotId, parkingFeePerMinute);
    }

    function payAndReleaseParkingSpot(uint256 parkingSpotId) public payable {
        uint256 currentFees = getCurrentParkingFees(parkingSpotId);
        require(msg.value >= currentFees, "Insufficient payment");
        parkingSpots.releaseParkingSpot(parkingSpotId);
    }
}
