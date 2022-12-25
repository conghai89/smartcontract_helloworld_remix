pragma solidity >=0.5.0 <0.9.0;

contract Lottery_FX17394{
    address public manager;
    address payable[] public players;

    constructor (){
        manager = msg.sender;
    }

    // receive value from sender and store value in to balance address(this).balance
    receive () payable external{
        require(msg.value == 0.1 ether);
        players.push(payable(msg.sender));
    }

    // get Balance of contract (wei)
    function getBalance() public view returns(uint){
        require (msg.sender == manager);
        return address(this).balance;
    }

    function random () internal view returns (uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    function pickWinner() public returns(address) {
        require (msg.sender == manager);
        require (players.length>=3);

        uint r = random();
        address payable winner;

        uint index = r % players.length;
        winner = players[index];

        // Transfer contract blance to winner;
        winner.transfer(getBalance());

        players = new address payable[](0);

        return winner;
    }
}

