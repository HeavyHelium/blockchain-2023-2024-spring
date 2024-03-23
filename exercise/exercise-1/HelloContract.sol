
//SPDX-License-Identifier: GPL-3.0

// function userVoted(address _user, uint256 _value) private view isVoter returns bool {}

pragma solidity >=0.7.0 <0.9.0;

contract HelloContract {
    uint256 num = 0;


    constructor(uint256 _value) {
        num = _value;
    }

    function setValue(uint256 _val) public {
        num = _val;
    }

    function getValue() public view returns(uint256, uint256) { // view -> getter?
        return (num, num + 1);
    }


}

// Deployed, unpinned contracts after compilation
// транзакция vs call -- транзакцията се приема се е множество от действия, които променят ledger-a, съотв. има такси
// при call се извършва само четене

// тук всяка транзакция е в отделен блок
