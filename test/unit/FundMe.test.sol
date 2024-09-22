// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import{Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    uint256 constant SEND_VALUE = 2 ether;
    uint256 constant STARTING_BAL = 10 ether;
    uint256 constant GAS_PRICE = 1;
    address USER = makeAddr("USER");

    modifier funded(){
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function setUp() external {
        // fundMe = new FundMe(0xa0Ee7A142d267C1f36714E4a8F75612F20a79720);
        DeployFundMe deployfundme = new DeployFundMe();
        fundMe = deployfundme.run();
        vm.deal(USER, STARTING_BAL);
    }

//what can we do to work with address outside our system?
// 1. uint- Testing a specific part of our code
// 2. Integration- Testing how our code works with other parts os our code
// 3. Forked- Testing our code on simulated real environment
// 4. Staging- Testing our code in a real environment that is not prod.


    function testMinimumDollarIsFive() public view {
        console.log("MINIMUM_USD:", fundMe.MINIMUM_USD());
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function fundMeFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public  funded {
        assertEq(fundMe.s_addressToAmountFunded(USER), SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public  funded{
       address funder = fundMe.s_funders(0);
       assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
      // Arrange
      uint256 startingOwnerBalance = fundMe.i_owner().balance;
      uint256 startingFundMeBalance = address(fundMe).balance;

      // Act
      vm.prank(fundMe.i_owner());
      fundMe.withdraw();
      // assert
      uint256 endingOwnerBalance = fundMe.i_owner().balance;
      uint256 endingFundMeBalance = address(fundMe).balance;
      assertEq(endingFundMeBalance, 0);
      assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i= startingFunderIndex; i< numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.i_owner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.i_owner());
        fundMe.withdraw();

        assert(address(fundMe).balance == 0);
        assert(startingOwnerBalance + startingFundMeBalance == fundMe.i_owner().balance);

    }
}

