# Addresses

Верифицирането на транзакциите става чрез математика вместо чрез central authorities.

- asymmetric cryptography and digital signatures(криптиране с частен ключ, подписване)

* [Elliptic Curve Cryptography](https://medium.com/coinmonks/introduction-to-blockchains-bedrock-the-elliptic-curve-secp256k1-e4bd3bc17d)

  - подобно на RSA, но ползва elliptic крива над крайни полета, по-кратки ключове

* операцията по генериране на публичен от частен ключ е необратима

![img](./img/eec.webp)

## Public/Private key addresses (creation)

- **a cryptographically secured source of entropy** $\to$ **private key** $\to$ **elliptic curve multiplication** $\to$ **public key** $\to$ **hashing encoding; trimming** $\to$ **address**

- **портфейл** vs **акаунт** vs **адрес**
- частният ключ се държи в портфейла, това е основният смисъл на портфейла

- **tx** object
- получателят трябва да докаже, че той е собственикът на адреса, посочен в транзакцията
  - проверка с private ключ подписване

**_Bitcoin -> UTXO_**  
**_Ethereum -> Account balance model_**

- пак имаме адрес и свойства, които го правят акаунт,
- разликата е, че имаме едно число за баланс

❗ How are addresses added to the protocol -- не се добавят, те са числа, протокола не го интересува, стига да са валидни, приемат се  
❗ Можем да пратим транзакция на адрес, който не съществува, транзакцията е валидна; при положение, че се появи такъв адрес, ще получи ресурса

- Транзакциите са повече като udp, отколото като tcp, няма handshake

## Типове акаунти в Ethereum

#### Externally Owned Account(външни акаунти, човешки акаунти)

Външен за самата мрежа, генериран от частен ключ. В Ethereum към този момент само този тип може да инициират транзакции.  
Всяко update-ване на ledger-а се случва от такъв акаунт.

- акаунт, който се контролира от частен ключ

* може да инициира транзакции
* транзакции между EOAs могат да бъдат eth/token транзакции
* няма такси за създаване, не струват нищо

* Създава се като генерираме частен ключ

$Address(Key_{pb}) = Bits_{96..255}(Keccak(ECDSA(Key_{pr})))$

1. Randomly create a $Key_{pr}$ - 32 bytes, hex-encoded 64 characters
2. Perform ECDSA(elliptic curve digital signature algorithm)(using ECM) on the **secp256k1** elliptic curve $Key_{pr}$ times $\to$ results in a $Key_{pb}$ - 64 bytes, hex encoded 128 characters
3. Hash the $Key_{pb}$ using keccak256 $\to$ results in 64 characters, 32 bytes hash code
4. Take the last 20 bytes of the has code $\to$ results in an address(account) - 40 character, 20 bytes
5. Put **Ox** prefix in front of the address for readability

- Хората се идентифицират с 20 байта в Ethereum.

#### Contract Account

(междинни връзки, не могат да бъдат в краищата)

- няма частен ключ, контролира се от код(smart contract)
  - не може да подписва и съотв. не може да инициира транзакции
- може само да праща транзакции като отговор към получаването на транзакция
- транзакциите от EOA към CA могат да задействат код, който прави много действия, включително създаването на нов контракт

* получаваме адреса като функция на externally owned account, няма ентропия, не ни и трябва

$Address_{contr}(Address_{sender}, Nonce_{sender}) = Bits_{96..255}(keccak256(RLPEncode([Address_{sender}, Nonce_{sender}])))$

- sender -- този, който деплойва

1. Take (externally owned account) $Address_{sender}$ that deploys the contract
2. Take that Address's $Nonce_{sender}$
3. Encode in RLP(recursive length prefix) both fields as an array [$Address_{sender}$, $Nonce_{sender}$]
4. Hash the serialized resilt with keccak256
5. Take tha last 20 bytes of the hash
6. Put **Ox** prefix for readability

- на smart контракта не му трябва частен ключ

Понеже това е детерминистичен процес, можем да определим как nonce ще се увеличи, можем да пратим крипто на следващите адреси.

- противникът ни разчита, че баланса в началото е 0
- добрата практика е, че ако ще деплойваме нов smart контракт, е да го деплойваме от чисто нов адрес

---

`Side note`

- helium мрежа - 3 в 1 консенсусен механизъм

* helium map

- [Update on the helium networks migration to solana](https://blog.helium.com/an-update-on-the-helium-networks-migration-to-solana-4550e20552a9)

- proof of position -- първоначален вариант на консенсус на helium

![img](./img/trilemma.png)

---

`Side note` P2PKH format

транзакция, в която има smart contract -- internal transaction

- за различните протоколи има различни начини за осигуряването на ентропията

---
