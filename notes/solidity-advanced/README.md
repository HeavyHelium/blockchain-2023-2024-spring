## Solidity Advanced

❗ chrome има много проблеми с remix

### `fallback` и `receive`

#### `fallback`

- Може да имаме най-много една `fallback` функция и тя трябва да е `external`, т.е. вика се само отвън

- by default **_не е_** дефинирана

* Когато направим заявка към даден contract се минава през всички видими дефинирани функции и се търси такава, която е подходяща за обработка на текущата заявка

  - съотв. ако не се намери такава, като last-resort се избира `fallback`

* Обикновено, когато се стигне до `fallback`, не се интересуваме от конкретна бизнес логика

#### `receive`

Tранзацията освен `from` и `to`, носи и метаданни, сред които е и количеството крипто.

- **_metadata, message object, т.е. msg_**, properties от контекста на една транзакция

* метаданните се overwrite-ват при изпълняването на транзакции

```solidity
msg.value
msg.sender
msg.data
msg.sig
msg.gas
msg.gasprice
```

В зависимост от присъствието на крипто и допълнителни данни, като last resort, се стига до `fallback` или `receive`. Иначе всичко за `fallback` важи и за `receive`.

- само крипто $\to$ `receive`
- else $\to$ `fallback`

### Events & event emitting

- Събитията се пазят в структура около ledger-а,
  - за имплементиране на някаква външна логика?

* Когато `emit`-нем event, съотв. данни се логват в блокчейна.

### address, contract calling

- с `msg.sender` вземаме адреса на изпращача

- `address(this)` - вземаме адреса на текущия contract

```solidity

//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;



contract contractThree {
    // events се пазят в структура около ledger-а
    event MoneyReceived(string _function, uint256 _amount, address _sender);
    uint256 contrBalance = 0;

    fallback() external payable {
        emit MoneyReceived("fallback", msg.value, msg.sender);
    }

    receive() external payable {
        emit MoneyReceived("receive", msg.value, msg.sender);
    }


    function getAddress() public view returns(address, uint256) {
        return (address(this), address(this).balance);
    }
}

```

#### Properties и methods на `address` типа

- `.balance`
- `transfer()`
- `send()`

### Транзакции между два контракта, `transfer` и `send`

- `send` е low level функция, връща булева стойност, може да добавим конкретна логика след приключването на функцията с успех или неуспех.

- `transfer` директно revert-ва при провал

- и двете вземат по 2300 газ, което е съществено за избягването на reentrancy condition vulnerabilities.

```solidity
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Sender {
    event MoneyReceived(string _function, uint256 _amount, address _sender);
    event MoneySent(address _receiver, uint256 _amount);

    fallback() external payable {
        emit MoneyReceived("fallback", msg.value, msg.sender);
    }

    receive() external payable {
        emit MoneyReceived("receive", msg.value, msg.sender);
    }

    function transferMoney(address payable _receiverAddr, uint256 _amount) external {
        //.transfer sends 2300 gas
        // terminates execution in case of error, cascades exceptions
        _receiverAddr.transfer(_amount); // Transfer Ether to the receiver address
        emit MoneySent(_receiverAddr, _amount);
    }

    function sendMoney(address payable _receiverAddr, uint256 _amount) public returns(bool) {
        bool success = _receiverAddr.send(_amount); // Send Ether to the receiver address using low-level call
        if (success) {
            emit MoneySent(_receiverAddr, _amount);
        } else {
            require(false, "s4upi se");
        }
        return success;
    }
}

contract Receiver {
    event MoneyReceived(string _function, uint256 _amount, address _sender);

    fallback() external payable {
        emit MoneyReceived("fallback", msg.value, msg.sender);
    }

    receive() external payable {
        emit MoneyReceived("receive", msg.value, msg.sender);
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
}


```

### Транзакции между два контракта, `call` и `delegatecall`

#### `call`

- Подобна на send, но позволява изпълняването на допълнителна логика под формата на функция, която можем да извикаме.
- Можем да посочим количеството газ, което искаме да пуснем за изчислението
- Подобно на `send` е функция от ниско ниво, т.е. връща bool
- връща и резултатa от извиканата функция под формата на байтове
- ако не посочим количество газ, `call` взема цялото количество налична газ

* Т.к. виртуалната машина работи с поток от байтове, трябва да encode-нем сигнатурата

```solidity
    function callFunc(
        address payable _to,
        uint256 _gas,
        uint256 _a,
        uint256 _b
    ) public {
        (bool success, bytes memory data) = _to.call{gas: _gas}(
            abi.encodeWithSignature("sum(uint256,uint256)", _a, _b) // важно е да няма whitespace, заради encode-ването
        );
        emit ReturnedData(success, data);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

```

- Ако искаме да пращаме крипто, трябва функцията, която викаме да бъде `payable`, в противен случай ще отидем във `fallback` или `receive`(на получателя), понеже няма да бъде подходяща.

#### `delegatecall`

- Подобна е на `call`, но само по това, че се използва логиката на посочена функция, но **в контекста на текущия contract**.

* идеята е code reusability, ползва се в библиотеки

```solidity
    contract Sender {
    event MoneyReceived(string _function, uint256, address _sender);
    event MoneySent(address _receiver, uint256 _amount);
    event ReturnedData(bool _success, bytes _data);

    uint256 number = 0; // ако имаме 2 или повече от съотвения тип, delegatecall избира първoто
    // дори и да има едноименно, ако не е първо, се взема първото

    //...
    //...
    //...

    function dcall(address payable _to) public {
        (bool success, bytes memory data) = _to.delegatecall(
            abi.encodeWithSignature("increment()")
        );
        emit ReturnedData(success, data);
    }

    //...
    //...
    //...
}

```

##### `tx` обект

- tx носи информация за целия **callchain**
- tx.origin - адреса на този, който е започнал цялата верига

* tx не бива да се ползва като начин за валидация на потребители

```solidity

contract Receiver {
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
        emit TxContext(gasleft(), msg.sender, tx.origin, address(this));

        return a + b;
    }
}


```

#### `namedcall`

- cascades exceptions

* revert - ва при неуспех

```solidity

    function namedCall(address payable _to) public pure returns(uint8) {
        Receiver receiver = Receiver(_to);
        // през обекта ще ползваме функции от този smart contract, на този адрес
        // автоматично си смята газта

        //uint256 balance = receiver.getBalance();
        ///receiver.increment();
        return receiver.exampleOverflow();
    }


```

### Структури

```solidity
contract someContract {
    struct Student {
        uint8 age;
        string name;
    }

    // ...
    // ...
    // ...

    function someFunction() public returns (uint8) {
        Student memory std = Student(25, "Alex");

        return std.age;
    }
}

```

### Other related

- DAO hack - базира се на цикъл от call-ове м/у `fallback` функции на два smart contract-а, **reentrancy condition**.

- пазене на баланса в property - добра практика, контрол върху това да не ни пращат неискани пари

- `gasleft()` - можем да вземем количеството останала газ, но най-коректно е да проверяваме количеството газ на тестова мрежа

```solidity
abi.decode(data, (uint256)) // ако данните са в hex и са цели числа и ги искаме в decimal
```

- обикновено от всички методи ползваме `call` най-много, понеже можем да специфицираме точното количество газ

* `send` и `transfer` работят само с native криптото за дадения протокол, в случая ether.
