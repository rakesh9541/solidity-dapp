//SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "./PriceConvertor.sol";

// error FundMe_NotOwner();  defining an error

/**
 * @title A contract for crowd funding
 * @author Rakesh
 * @notice This contract allows users to fund a project and the owner to withdraw funds
 * @dev This implements Chainlink price feeds as our library
 */

contract FundMe {
    using PriceConvertor for uint256; // This means that all the functions in the PriceConverter library are available to call on any uint256. But they have to be "internal functions" *(very important)

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    uint256 public constant MINIMUM_USD = 50 * 1e18; // constant --> those var which can be updated only once but has to initialized on declaration.
    address public immutable i_owner; // immutable --> those var which can be updated only once but can be initialized only inside constructor.
    address public immutable i_priceFeed;

    // both constant and immutable saves gas

    constructor(address _priceFeedAddress) {
        // constructor will run instantly as the contract is deployed
        i_owner = msg.sender; // msg.sender at deployement will be the addess of the person who deployed the contract
        i_priceFeed = _priceFeedAddress;
    }

    function fund() public payable {
        // payable specifier for specifying that the we can send money through this function
        // require (if false, then execute this and revert)
        require(
            msg.value.priceConvertor(i_priceFeed) >= MINIMUM_USD,
            "Insufficient funds sent"
        ); // msg.value --> returns how much "value" someone is sending through this function
        // the msg.value is considered as the first parameter that is passed in the priceConvertor function library
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        funders = new address[](0);

        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success, "Withdrawal failed");
    }

    modifier onlyOwner() {
        // anytime the onlyOwner specifier will be used in a function, it will jump to here and first complete all task here then move back to its function
        require(msg.sender == i_owner, "Caller is not the owner");

        // if (msg.sender != i_owner) revert FundMe_NotOwner();    another way to do the above and FundMe_NotOwner is an error defined at the top

        _; // move back to the fucntion and do the rest remaining in there
    }

    receive() external payable {
        // if you pay the contract without any msg.data (calldata) then receive() will run
        fund();
    }

    fallback() external payable {
        // if you pay the contract with some calldata but it does not point to any defined function in the contract, then fallback() will run
        fund();
    }

    // $4025.19569965
}



// Contract can also hold funds in their contract address just like a wallet address

/* What is Reverting?
    Undo any actions before, and send the remaining gas back */

// Interface github --> https://github.com/smartcontractkit/chainlink/blob/master/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol

/*
    Ether is send to contract->
       
       Is msg.data empty?
            /    \   
          yes     no
          /        \
    receive() ?   fallback()   
      /   \
    yes   no
    /       \
receive()   fallback()

*/
