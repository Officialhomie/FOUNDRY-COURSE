// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import { FundMe } from "../../src/FundMe.sol";
import { DeployFundMe } from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    FundMe fundMe;
    address USER = makeAddr("USER");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;


    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedConversionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailedWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund();
       
    }

    function testFundUpdatesFundedDataStructure() public funded {



        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER); 
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddressFunderToArrayofFunders() public funded{

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);     // The next tx will be done by the USER
        vm.expectRevert();  // expect that the next line should revert 
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        uint256 gasStart = gasleft();

        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner()); // owner of the contract wants to call the next line
        fundMe.withdraw();

        uint256 gasEnd = gasleft();

        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange

        // We are using uint160 to represent numbers as addresses
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; // we are using 1 because the address 0 may or may not revert the txn

        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // we are using a cheatcode called hoax to emulate the prank and deal cheatcodes

            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;


        // ACT
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // ASSERT 
        assertEq(address(fundMe).balance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, fundMe.getOwner().balance);
    }


    function testWithdrawFromMultipleFundersCheperWithdraw() public funded {
        // Arrange

        // We are using uint160 to represent numbers as addresses
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; // we are using 1 because the address 0 may or may not revert the txn

        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // we are using a cheatcode called hoax to emulate the prank and deal cheatcodes

            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;


        // ACT
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // ASSERT 
        assertEq(address(fundMe).balance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, fundMe.getOwner().balance);
    }
    


}


 