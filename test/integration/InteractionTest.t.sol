// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import{Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interaction.s.sol";

contract InteractionsTest is Test {

    FundMe fundMe;
    uint256 constant SEND_VALUE = 10 ether;
    uint256 constant STARTING_BAL = 0.1 ether;
    uint256 constant GAS_PRICE = 1;
    address USER = makeAddr("USER");

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, STARTING_BAL);
    }

    function testUserCanFundInteractions() public {
        
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
        // address funder = fundMe.s_funders(0);
        // assertEq(funder, USER);
    }
}