// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Send {
    event MoneyReceived(string _function, uint256, address _sender);
    event MoneySent(address _receiver, uint256 _amount);
    event ReturnedData(bool _success, bytes _data);

    uint256 number = 0; // ако имаме 2 или повече uint256 избира първия
    // дори и едното да има съотв. име, ако не е първо, се взема първото

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

    function getNumber() public view returns (uint256) {
        return number;
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

    function callFunc(address payable _to, uint256 _a, uint256 _b) public {
        // можем да контролираме точно количестовто газ, което искаме да пуснем
        (bool success, bytes memory data) = _to.call(
            abi.encodeWithSignature("sum(uint256,uint256)", _a, _b)
        );
        // всеки вход и изход на VM е bytes
        emit ReturnedData(success, data);
        // call отново е функция от ниско ниво
        // data е върнятият резултат от call
        // call може да вика конкретна функция
    }

    function dcall(address payable _to) public {
        (bool success, bytes memory data) = _to.delegatecall(
            abi.encodeWithSignature("increment()")
        );
        emit ReturnedData(success, data);
        // логиката на функцията се делегира в текущия контекст, не в този на _to
        // идеята е code reusability
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function namedCall(address payable _to) public pure returns (uint8) {
        Receiver receiver = Receiver(_to);
        // през обкета ще ползваме функции от този smart contract,
        // на този адрес
        // автоматично си смята газта
        // cascades exceptions
        // revert - ва при неуспех

        //uint256 balance = receiver.getBalance();
        ///receiver.increment();
        return receiver.exampleOverflow();
    }
}

contract Receiver {
    struct Student {
        uint8 age;
        string name;
    }

    uint256 number = 0;
    event Log(uint256 func, uint256 amount, address sender);
    // event GasLeft(uint256 _left);
    event TxContext(
        uint256 _gasLeft,
        address _sender,
        address _origin,
        address _current
    );
    // event MoneyReceived(string, uint256 _val);

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
        emit TxContext(gasleft(), msg.sender, tx.origin, address(this));
        ++number;
    }

    function getnum() public view returns (uint256) {
        return number;
    }

    function sum(uint256 a, uint256 b) public returns (uint256) {
        // emit GasLeft(gasleft()); // най-коректно е да проверяваме количеството газ на тестова мрежа
        emit TxContext(gasleft(), msg.sender, tx.origin, address(this));
        // tx.origin -- адреса на този, който е започнал цялата верига
        // tx ни дава целия callchain
        // tx не бива да се ползва като начин за валидация на потребители

        //Student memory std = Student(25, "Alex");

        return a + b;
    }

    function exampleOverflow() public pure returns (uint8) {
        uint8 overflowNum = 255;

        return overflowNum++;
    }
}
