// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

import {PriceConverter} from "contracts/PriceCalculator.sol";

library ParkingSpotManagement {
    using PriceConverter for uint256;

    struct ParkingSpot {
        bool isOccupied;
        uint256 occupancyStartTime;
        address vehicleOwner;
        uint256 parkingFees;
    }

    function generateParkingSpots(
        mapping(uint256 => ParkingSpot) storage parkingSpots,
        uint256[] storage parkingSpotIds,
        uint256 numParkingSpots,
        uint256 parkingFeePerMinute
    ) internal {
        require(numParkingSpots > 0, "Number of parking spots must be greater than zero");

        for (uint256 i = 0; i < numParkingSpots; i++) {
            addParkingSpot(parkingSpots, i);
            parkingSpotIds.push(i);
            parkingSpots[i].parkingFees = parkingFeePerMinute;
        }
    }

    function addParkingSpot(
        mapping(uint256 => ParkingSpot) storage parkingSpots,
        uint256 parkingSpotId
    ) internal {
        require(!parkingSpots[parkingSpotId].isOccupied, "Parking spot is already occupied");
        parkingSpots[parkingSpotId] = ParkingSpot(false, 0, address(0), 0);
    }

    function getParkingSpotIds(mapping(uint256 => ParkingSpot) storage parkingSpots) internal view returns (uint256[] memory) {
    uint256 count = 0;
    for (uint256 i = 0; i < 256; i++) {
        if (parkingSpots[i].isOccupied) {
            count++;
        }
    }

    uint256[] memory spotIds = new uint256[](count);
    uint256 index = 0;
    for (uint256 i = 0; i < 256; i++) {
        if (parkingSpots[i].isOccupied) {
            spotIds[index] = i;
            index++;
        }
    }

    return spotIds;
}

    function occupyParkingSpot(
        mapping(uint256 => ParkingSpot) storage parkingSpots,
        uint256 parkingSpotId,
        address vehicleOwner
    ) internal {
        require(!parkingSpots[parkingSpotId].isOccupied, "Parking spot is already occupied");
        ParkingSpot storage parkingSpot = parkingSpots[parkingSpotId];
        parkingSpot.isOccupied = true;
        parkingSpot.occupancyStartTime = block.timestamp;
        parkingSpot.vehicleOwner = vehicleOwner;
    }

    function getCurrentParkingFees(mapping(uint256 => ParkingSpot) storage parkingSpots, uint256 parkingSpotId , uint256 parkingFeePerMinute) internal view returns (uint256) {
        ParkingSpot storage parkingSpot = parkingSpots[parkingSpotId];
        require(parkingSpot.isOccupied, "Parking spot is not occupied");

        uint256 parkingDuration = block.timestamp - parkingSpot.occupancyStartTime;
        uint256 feePerMinute = parkingFeePerMinute;

        if (parkingDuration >= 20 seconds) {
            uint256 additionalFees = (parkingDuration / 20 seconds) * feePerMinute;
            return parkingSpot.parkingFees + additionalFees;
        }

        return parkingSpot.parkingFees;
    }

    function releaseParkingSpot(
        mapping(uint256 => ParkingSpot) storage parkingSpots,
        uint256 parkingSpotId,
        uint256 parkingFeePerMinute,
        address payable parkingOperator
    ) internal {
        ParkingSpot storage parkingSpot = parkingSpots[parkingSpotId];
        require(parkingSpot.isOccupied, "Parking spot is not occupied");
        require(msg.sender == parkingSpot.vehicleOwner, "Only the vehicle owner can release the parking spot");

        uint256 parkingDuration = block.timestamp - parkingSpot.occupancyStartTime;
        uint256 feePerMinute = parkingFeePerMinute;
        uint256 parkingFeeInDollar = parkingDuration * feePerMinute;

        if (parkingDuration >= 20 seconds) {
            uint256 additionalFees = (parkingDuration / 20 seconds) * feePerMinute;
            parkingFeeInDollar += additionalFees;
        }

        delete parkingSpots[parkingSpotId];
        parkingOperator.transfer(parkingFeeInDollar);
    }
}
