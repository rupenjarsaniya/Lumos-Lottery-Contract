// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Lottery {
    address public owner;
    address payable[] public players;
    uint256 public eventId;
    bool public eventInProgress;
    mapping(uint256 => address payable) public lotteryHistory;

    constructor() {
        owner = msg.sender;
        eventId = 1;
    }

    modifier onlyowner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function alreadyEntered() private view returns (bool) {
        for (uint256 i = 0; i < players.length; i++) {
            if (players[i] == msg.sender) return true;
        }
        return false;
    }

    function randomNumber() private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.prevrandao,
                        block.gaslimit
                    )
                )
            );
    }

    function startLottery() public onlyowner {
        eventInProgress = true;
    }

    function enterLottery() public payable {
        require(
            eventInProgress,
            "Currently no any lottery event not in progress"
        );
        require(msg.value > 0.1 ether, "You should deposit atleast 0.1 Ether");
        require(msg.sender != owner, "Owner can't enter in the lottery event");
        require(
            alreadyEntered() == false,
            "You have already entered in the Lottery event"
        );
        require(players.length <= 10, "This event has maximum participation");
        players.push(payable(msg.sender));
    }

    function pickWinner() public onlyowner {
        require(
            eventInProgress,
            "Currently no any lottery event not in progress"
        );
        require(
            players.length > 0,
            "No one is participated in the lottery event"
        );
        uint256 index = randomNumber() % players.length;
        players[index].transfer(address(this).balance - 0.1 ether);
        lotteryHistory[eventId] = players[index];
        eventId++;
        eventInProgress = false;
        players = new address payable[](0);
    }

    function getWinnerByEventId(uint256 lottery)
        public
        view
        returns (address payable)
    {
        return lotteryHistory[lottery];
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    function numOfPlayers() public view returns (uint256) {
        return players.length;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance / (10**18);
    }
}
