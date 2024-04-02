// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Casino {
    struct User {
        uint256 amount;
        uint16 num;
    }

    address admin;
    uint256 casinoBalance = 0; // добра практика, за избягвaне на неискано получаване
    uint8 casinoLimit = 50;
    uint8 minimumBets = 10;
    mapping(address => User) bets;

    address[] participants;
    address[] currentWinners;

    event sentToWinner(address _addr, uint256 _amount, uint256 _number);
    event revealAdmin(address _admin, uint256 _amount, uint256 _magic_number);

    modifier isAdmin() {
        require(
            msg.sender == admin,
            "You must be admin in order to perform this operation"
        );
        _;
    }

    constructor() {
        admin = msg.sender; // този, който деплойва казиното
        //if(address(this).balance > 0) {
        //    payable(admin).transfer(address(this).balance);
        //}
    }

    function getBalance() public view returns (uint256) {
        return casinoBalance;
    }

    function numOfBets() public view returns (uint256) {
        return participants.length;
    }

    function getCasinoLimit() public view returns (uint8) {
        return casinoLimit;
    }

    function getMyBet() public view returns (User memory) {
        require(hasBet(msg.sender), "You are yet to bet");
        return bets[msg.sender];
    }

    function endBets() external isAdmin {
        require(minimumBets <= participants.length, "Not enough players");
        require(currentWinners.length == 0, "Winners already selected!");

        uint8 winnersCount = uint8(participants.length) / 10;

        uint16 magicNumber = getMagicNumber();

        sort(magicNumber);

        for (uint256 i = 0; i < winnersCount; ++i) {
            currentWinners.push(participants[i]);
        }

        payWinners(magicNumber);
        reset();
    }

    function getMagicNumber() private view returns (uint16) {
        // block number -- контекстна информация, свързана с текущия блок, т.е. последният mine-ат блок
        bytes memory encoded_data = abi.encode(
            participants,
            casinoBalance,
            block.number
        );
        uint16 magicNumber = abi.decode(encoded_data, (uint16));

        return magicNumber % 1000;
    }

    function sort(uint16 magicNumber) private {
        for (uint256 i = 0; i < participants.length; ++i) {
            for (uint256 j = i + 1; j < participants.length; ++j) {
                uint16 deltai = magicNumber > bets[participants[i]].num
                    ? magicNumber - bets[participants[i]].num
                    : bets[participants[i]].num - magicNumber;

                uint16 deltaj = magicNumber > bets[participants[j]].num
                    ? magicNumber - bets[participants[j]].num
                    : bets[participants[j]].num - magicNumber;
                if (deltai > deltaj) {
                    address temp = participants[i];
                    participants[i] = participants[j];
                    participants[j] = temp;
                }
            }
        }
    }

    function payWinners(uint16 magic_number) private {
        require(currentWinners.length != 0, "No winners selected. Cannot pay!");

        // избираме transfer за по-просто, тъй като rever-ва
        // транзакциите са атомарни

        uint256 winPot = casinoBalance;
        uint256 totalWinnersBets = 0;

        for (uint256 i = 0; i < currentWinners.length; ++i) {
            winPot -= bets[currentWinners[i]].amount;
        }
        totalWinnersBets = casinoBalance - winPot;
        winPot = (winPot * 9) / 10;

        uint256 amount = 0;

        for (uint256 i = 0; i < currentWinners.length; ++i) {
            amount =
                bets[currentWinners[i]].amount +
                (bets[currentWinners[i]].amount / totalWinnersBets) *
                winPot;
            payable((currentWinners[i])).transfer(amount);
            emit sentToWinner(
                (currentWinners[i]),
                amount,
                bets[currentWinners[i]].num
            );
        }

        amount = address(this).balance;
        payable(admin).transfer(address(this).balance);
        emit revealAdmin(admin, amount, magic_number);
    }

    function reset() private {
        while (currentWinners.length != 0) {
            currentWinners.pop();
            participants.pop();
        }
        while (participants.length != 0) {
            participants.pop();
        }

        // по-дорбре с delete
        // delete currentWinners;
        // delete participants;

        casinoBalance = 0;
    }

    function hasBet(address player) private view returns (bool) {
        uint256 num = participants.length;

        for (uint8 i = 0; i < num; ++i) {
            if (player == participants[i]) {
                return true;
            }
        }
        return false;
    }

    function placeBet(uint16 _num) public payable {
        require(participants.length < casinoLimit, "Casino is full");
        require(!hasBet(msg.sender), "You already placed a bet!");
        require(_num > 0 && _num < 1000, "Number must be between 0 and 1000");
        require(msg.value > 100 gwei, "Bet amount must be over 100 Gwei");

        User memory user = User(msg.value, _num);
        participants.push(msg.sender);
        bets[msg.sender] = user;
        casinoBalance += msg.value;
    }

    fallback() external {}
}
