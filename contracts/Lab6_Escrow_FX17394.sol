pragma solidity >=0.5.0 <0.9.0;

contract Escrow_FX17394 {
    address payable public buyer;
    address payable public seller;
    address public arbiter;
    mapping(address=>uint) TotalAmount;

    enum State{
        awate_payment, awate_delivery, complete
    }
    State public state;

    constructor(address payable _buyer, address payable _seller) public{
        arbiter = msg.sender;
        seller = _seller;
        buyer = _buyer;
        state = State.awate_payment;
    }

    modifier instate (State expectedState){
        require(state == expectedState , "Expected State note met");
        _;
    }

    modifier onlyBuyer(){
        require(msg.sender == buyer || msg.sender == arbiter, "You are not a buyer");
        _;
    }

    modifier onlySeller(){
        require(msg.sender == seller || msg.sender == arbiter, "You are not a seller");
        _;
    }

    function confirmPayment() public onlyBuyer instate(State.awate_payment){
        state = State.awate_delivery;
    }

    function confirmDelivery() public onlyBuyer instate(State.awate_delivery){
        seller.transfer(address(this).balance);
        state = State.complete;
    }

    function returnPayment () public onlySeller instate(State.awate_delivery){
        buyer.transfer(address(this).balance);
    }

}
