// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Casino {
    // всеки вкарва число[1-1000] и пари
    // вземаме тримата с най-близко число до избраното
    // числото = sum(numbers) / #участници
    // блокхеш, kaccak, mod 1000

    struct User {
        uint256 amount;
        uint16 num;
    }

    address admin;
    uint256 casinoBalance = 0;
    uint8 casinoLimit = 50;
    mapping(address => User) bets;
    address[] participants;

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
        require(hasBet(msg.sender), "You are yet tp bet");
        return bets[msg.sender];
    }

    function endBets() external isAdmin {
        // вика функциите отдолу
    }

    function getMagicNumber() private view returns (uint16) {
        // add functionality
        return 42;
    }

    function determineWinners() private view {}
    function payWinners() private {}

    function reset() private isAdmin {}

    function hasBet(address player) private view returns (bool) {
        uint256 num = participants.length;

        for (uint8 i = 0; i < num; ++i) {
            if (player == participants[i]) {
                return true;
            }
        }
        return false;
    }

    function acceptBet(uint16 _num) public payable {
        require(participants.length < casinoLimit, "Casino is full");
        require(!hasBet(msg.sender), "You already placed a bet!");
        require(_num > 0 && _num < 1000, "Number must be between 0 and 1000");
        require(msg.value > 100 gwei, "Bet amount must be at least 100 Gwei");

        participants.push(msg.sender);
        User memory user = User(msg.value, _num);
        bets[msg.sender] = user;
        casinoBalance += msg.value;
    }

    fallback() external {}
}
