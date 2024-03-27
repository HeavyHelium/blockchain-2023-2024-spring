// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Send {
    event MoneyReceived(string _function, uint256, address _sender);
    event MoneySent(address _receiver, uint256 _amount);
    event ReturnedData(bool _success, bytes _data);

    constructor() payable {}

    receive() external payable {
        emit MoneyReceived("receive", msg.value, msg.sender);
    }

    fallback() external payable {
        emit MoneyReceived("fallback", msg.value, msg.sender);
    }

    function sendTransfer(address payable _to, uint256 _amount) external {
        _to.transfer(_amount);
        emit MoneySent(_to, _amount);
    }

    function sendSend(
        address payable _to,
        uint256 _amount
    ) external returns (bool) {
        bool success = _to.send(_amount);
        if (success) {
            emit MoneySent(_to, _amount);
        } else {
            require(success, "wubba lubba dub dub");
        }
        return success;
    }

    function callSC(address payable _to, uint256 _amount, uint256 _gas) public {
        // можем да контролираме точно количестовто газ, което искаме да пуснем
        (bool success, bytes memory data) = _to.call{value: _amount, gas: _gas}(
            abi.encodeWithSignature("increment()")
        );
        // всеки вход и изход на VM е bytes
        emit ReturnedData(success, data);
        // call отново е функция от ниско ниво
        // data е върнятият резултат от call
        // call може да вика конкретна функция
        // ако не посочим количество газ, call взема цялото количество налична газ
        // gasleft()
    }

    function callFunc(
        address payable _to,
        uint256 _gas,
        uint256 _a,
        uint256 _b
    ) public {
        // можем да контролираме точно количестовто газ, което искаме да пуснем
        (bool success, bytes memory data) = _to.call{gas: _gas}(
            abi.encodeWithSignature("sum(uint256,uint256)", _a, _b) // важно е да няма whitespace, заради encode-ването
        );
        // всеки вход и изход на VM е bytes
        emit ReturnedData(success, data);
        // call отново е функция от ниско ниво
        // data е върнятият резултат от call
        // call може да вика конкретна функция
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

contract Receiver {
    uint256 number = 0;
    event Log(uint256 func, uint256 amount, address sender);
    //   event MoneyReceived(string, uint256 _val);

    receive() external payable {
        emit Log(1, msg.value, msg.sender);
    }

    fallback() external payable {
        emit Log(2, msg.value, msg.sender);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function increment() public payable {
        ++number;
    }

    function getnum() public view returns (uint256) {
        return number;
    }

    function sum(uint256 a, uint256 b) public pure returns (uint256) {
        return a + b;
    }
}
