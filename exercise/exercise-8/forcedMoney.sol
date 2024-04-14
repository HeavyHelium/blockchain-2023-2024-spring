// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;


contract A {
    uint256 number = 10;

    constructor() payable {}

    function getNum() public view returns(uint256) {
        return number;
    }

    function destroySC(address payable _addr) public { 
        selfdestruct(_addr);
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function receive() external payable { }
    function fallback() external payable { }

}

contract B {

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
}


