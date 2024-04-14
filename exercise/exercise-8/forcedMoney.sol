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


/*
В момента, в който деполойнем нещо на мрежа, всички записи са immutable
Не можем да го манипулираме, но можем да го блокираме

* хората продължават да работят на стария контракт, това е начин да го предотвратим
* всеки път, когато блокираме smart контракт, парите остават заключени
* с аргумент selfdestruct, изпраща му всички налични ресурси на този адерс, дори и да няма посочения fallback и receive
* предпазваме се с допълнителна променлива 
*/