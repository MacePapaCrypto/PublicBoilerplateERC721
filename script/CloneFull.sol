//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from 'forge-std/Script.sol';
import {TestBoilerplateBase} from "contracts/ImplementBoilerplateBase.sol";
import {TestBoilerplateFull} from "contracts/ImplementBoilerplateFull.sol";
import {BoilerplateFactory} from "contracts/BoilerplateFactory.sol";
import {console} from "forge-std/console.sol";
import {InitializeParams} from "contracts/interfaces/IBoilerplateERC721.sol";

contract CloneFull is Script {

    TestBoilerplateFull fullBoilerplate;
    TestBoilerplateBase baseBoilerplate;
    BoilerplateFactory contractFactory;
    InitializeParams forFull = InitializeParams(
        "fullTest",
        "FTEST",
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
    function run() external returns (bool isSuccess) {
        vm.startBroadcast();
        BoilerplateFactory(0xb87b3eca1ae5639c2f61b0d47f62f837a38ded9e).createClone(1, forFull);
        vm.stopBroadcast();
    }
}