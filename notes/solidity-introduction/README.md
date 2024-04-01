## Увод в Solidity

- [Документация](https://docs.soliditylang.org/en/v0.8.25/)

- Solidity е език за имплементиране на Smart Contracts.

* OOP формат на контракти
* the native Ethereum(EVM) language
* Turing complete
* High-level language
* constantly being updated/changed
* compiled to bytecode
* **bytecode** is executed by the Ethereum Virtual Machine(**EVM**)

### Въпроси и бележки

- Няма `float`, съответно integer операциите truncate-ват integers

- Транзакция vs. call - транзакцията се приема като множество от действия, които променят ledger-a, съотв. има и такси, изразходва се газ, докато при call се извършва само четене.

- В Solidity можем да overload-ваме само нормалните функции, но не и конструктора

* Конструкторът е единствен

- рядко използваме низове и не можем да сравняваме низове

* mappings, т.е. хеш-таблиците нямат `size` или `length`

* трябва да внимаваме с циклите, т.к. потенциално може да изхабим повече газ, отколкото очакваме

* 3 вида памет - storage, memory, calldata/callstack

* ❗❗❗ Когато пишем smart contracts, които комуникират с други, комуникацията се случва със серия от байтове

- ограничаване на размера на елементите; overload се handle-ва, т.е. имплицитно
  - експлицитно с counter

#### Модификатори

##### Модификатори за достъп

- `public`, `private` - както от ООП

* `internal` - както protected от ООП

* `external` - може да се достъпва само от външен smart contract, има значение от страна на бизнес логиката, напр. ако имаме конкретна функция и няма логика да има действие без други smart contracts
  - достъпът към нея може да се осъществи само отвън

##### Модификатори на компилатора

- `view` - компилаторът ни позволява само да четем от състоянието, т.е. call
- `pure` - нито чете от ledger-a, нито модифицира ledger-a, т.е. прилича на статична функция, но не е точно
- `payable`- тези функции, които могат да получават крипто
  - представлява начин да контролираме входните точки

* `constant`

Ако изпуснем модификатор, се приема by default модификаторът с най-висок приоритет

#### Restrictors and function modifiers

##### Restrictors(require statements)

Инструментариум, с който ограничаваме поведението на функцията, за да можем да осигурим по-високо ниво на точност на изпълнението на бизнес логиката

```sol
require(<boolean expression>, "string message to display if expression is false")
```

Ако булевият израз се оцени до лъжа, то се връща газта до момента и се дава причината.

Обикновено се поставят в началото на функциите с цел потенциално спестяване на газ.

##### Модификатори(restrictor modifiers)

```solidity
    modifier isHigher5(uint256 _val) {
        require(_val > 5, "Number must be higher than 5");
        _; // placeholder, взема се кода на функцията и се продължава
    }

    function setValue(uint256 _val) public isHigher5(_val) {
        num = _val;
    }
```

- Използваме за по-чист код, изнасяме require statements в преизползваем модификатор

### Пример

```solidity

//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract HelloContract {
    // uint256 private num = 0; // можем да укажем модификатор за достъп на полетата
    uint256 num = 0;

    constructor() {
    }

    modifier isHigher5(uint256 _val) {
        require(_val > 5, "Number must be higher than 5");
        _;
    }

    function setValue(uint256 _val) public isHigher5(_val) {
        num = _val;
    }

    // модификатор за достъп, модификатор за компилатор, модификатор за requirements, тип върнатата стойност
    function getValue() public view returns(uint256, uint256) {
        // по дефиниция само четат
        return (num, num + 1);
    }

    function divTest(uint v1, uint v2) public pure returns(uint256) {

        return v1 / v2;
    }
}

```

### Наследяване

- поддържа се и множествено наследяване

```solidity
    contract A {
        uint256 internal  num = 10;
    }

    contract B is A {
        function getNum() public view returns(uint256) {

            return num;
        }
    }

    contract C is A, B {

    }
```

### Типове данни

- **storage** - всичко, което е маркирано със storage казва, че промеливите отиват директно в ledger-a, state fields са storage variables

- **memory** - живее само по време на изпълнение на smart contract-а, динамична памет, която заделяме

- **calldata/stack** - сходно на memory, разликата е, че е immutable, оптимизира първите 2, особено когато smart contract-а се пуска отвън, нещо като const reference параметър на функция; изобщо се позволява само като параметър на функция

**Всички state fields by default са storage.**  
**Всичко извън state fields по конвенция е memory или calldata/stack**

#### Работа с масиви и памет

```solidity

//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract NewContract {
    uint32[] private array;

    function setArray(uint32[] calldata arr) public {
        delete array;
        require(array.length == 0, "This ain't working");
        for(uint256 i = 0; i < arr.length; ++i) {
            array.push(arr[i]);
        }
    }

    function getArray() public view returns(uint32[] memory) {
        return array;
    }

    function setLocalArray(uint256 _size) public pure returns(uint256[] memory) {
        uint256[] memory arr = new uint256[](_size);
        // заделяме памет
        // ако не използваме new, arr има стойност подобна на null

        for(uint256 i = 0; i < _size; ++i) {
            arr[i] = i;
            // няма .push(i) метод, масивът не се преоразмерява
        }
        return arr;
    }
}

```

### Сравняване на низове и масиви

- Понеже циклите и обикалянето на памет считаме за скъпи операции, сравняваме масиви и низове като сравняваме хешовете им.

```solidity
    function comparestr(string calldata str1,
                        string calldata str2) public pure returns(bool) {

        return keccak256(abi.encode(str1)) == keccak256(abi.encode(str2));
    }

    function comparearr() public pure returns(bool) {
        uint8[5] memory arr1 = [1, 2, 3, 4, 5];
        uint8[5] memory arr2 = [1, 2, 3, 4, 5];
        //arr2[2] = 7;

        return keccak256(abi.encode(arr1)) == keccak256(abi.encode(arr2));
    }

```

- `abi.encode` vs `abi.encodePacked`  
  `encode` добавя padding, докато `encodePacked` не, по-сигурен вариант при работа с низове е `encode`.

### Mappings

- mapping променливите са само storage

* нямат `size` или `length` атрибути
  - на EVM не й трябват ключовете, тя ги смята динамично
  * често пъти пазим масив с ключовете
* ключове могат да бъдат само вградените типове, т.е. референтни типове не могат да бъдат ключове

```solidity
contract NewContract {
    uint32[] private array;
    mapping(uint32 => address) mapp;
    uint32[] keys;
    ...
```

### Remix Specific

- всяка транзакция е в отделен блок
- Color coding
  - червено -- получават се пари, payable
  - променящи state-а -- оранжево
  - светлосиньо -- pure
  - тъмносиньо -- view
