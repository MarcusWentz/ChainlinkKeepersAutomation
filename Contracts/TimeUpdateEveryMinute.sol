//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.14;

interface KeeperCompatibleInterface {
    function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);
    function performUpkeep(bytes calldata performData) external;
}

contract TimeUpdateEveryMinute is KeeperCompatibleInterface {

    uint256 public constant interval = 60; 
    uint256 public nextUpKeepTimeUnix = block.timestamp + interval;

    function checkUpkeep(bytes calldata checkData)  external view override returns (bool upkeepNeeded, bytes memory performData) {
        upkeepNeeded = (block.timestamp >= nextUpKeepTimeUnix);
    }

    function performUpkeep(bytes calldata performData) external override {
        nextUpKeepTimeUnix = block.timestamp + interval;
    }

}
