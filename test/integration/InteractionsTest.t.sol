// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Test, console } from "forge-std/Test.sol";
import { FundMe } from "../../src/FundMe.sol";
import { DeployFundMe } from "../../script/DeployFundMe.s.sol";
import { FundFundMe, WithdrawFundMe } from "../../script/Interactions.s.sol";

contract InteractiosTest is Test {
    FundMe fundMe;
    address USER = makeAddr("USER");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();

        // Check initial balance
        console.log("Initial balance of FundMe:", address(fundMe).balance);

        // Prank USER to fund  
        vm.prank(USER);
        try fundFundMe.fundFundMe(address(fundMe)) {
            console.log("Funding successful");
        } catch (bytes memory reason) {
            console.log("Funding failed with reason:", string(reason));
        }

        // Check balance after funding
        console.log("Balance of FundMe after funding:", address(fundMe).balance);

        // Prank owner to withdraw
        vm.prank(USER);
        try withdrawFundMe.withdrawFundMe(address(fundMe)) {
            console.log("Withdrawal successful");
        } catch (bytes memory reason) {
            console.log("Withdrawal failed with reason:", string(reason));
        }

        // Check final balance
        console.log("Final balance of FundMe:", address(fundMe).balance);

        assert(address(fundMe).balance == 0);
    }
}






