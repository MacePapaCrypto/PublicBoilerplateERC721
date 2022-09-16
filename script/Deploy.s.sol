//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from 'forge-std/Script.sol';
import {TestBoilerplateBase} from "contracts/ImplementBoilerplateBase.sol";
import {TestBoilerplateFull} from "contracts/ImplementBoilerplateFull.sol";
import {BoilerplateFactory} from "contracts/BoilerplateFactory.sol";
import {console} from "forge-std/console.sol";
import {InitializeParams} from "contracts/interfaces/IBoilerplateERC721.sol";

contract Deploy is Script {

    address mintCurrency = 0x04068DA6C83AFCFA0e13ba15A6696662335D5B75; //USDC
    uint mintPrice = 250000000;

    function run() external returns (TestBoilerplateFull fullBoilerplate, TestBoilerplateBase baseBoilerplate, BoilerplateFactory contractFactory) {
        vm.startBroadcast();
        console.log("Initializing new base contract");
        baseBoilerplate = new TestBoilerplateBase();
        console.log("Initializing new full contract");
        fullBoilerplate = new TestBoilerplateFull();
        console.log("Initializing new factory contract");
        address[2] memory boilerplateAddresses = [address(baseBoilerplate), address(fullBoilerplate)];
        contractFactory = new BoilerplateFactory(boilerplateAddresses);
        /*InitializeParams memory forBase = InitializeParams(
            "baseTest",
            "BTEST",
            "",
            0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13,
            500,
            1000,
            5,
            0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13,
            0x2b4C76d0dc16BE1C31D4C1DC53bF9B45987Fc75c,
            100,
            payable(0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83),
            0x962A2880Eb188AB4C2Cfe9874247fCC60a243d13
        );
        console.log("Call Create Clone");
        address deployedAddress = contractFactory.createClone(0, forBase);
        console.log("Clone Address: ", deployedAddress);*/
        console.log("Deployment Done");
        vm.stopBroadcast();
    }
}