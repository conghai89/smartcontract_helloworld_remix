pragma solidity >=0.5.0 <0.9.0;

contract CrowdFunding_FX17394 {
    address public admin;
    mapping(address => uint) public contributors;
    uint public noOfContributors;
    uint public minimumContribution;
    uint public deadline;
    uint public goal;
    uint public raisedAmount;

    struct Request {
        string discription;
        address payable recipient;
        uint value;
        bool complete;
        uint noOfVote;
        mapping(address => bool) voters;
    }

    mapping(uint => Request) public requests;
    uint public numRequests;

    constructor(uint _goal, uint _deadline) {
        admin = msg.sender;
        goal = _goal;
        deadline = block.timestamp + _deadline;
        minimumContribution = 100 wei;
    }

    modifier onlyAdmin(){
        require (msg.sender == admin, "Only admin can execute this");
        _;
    }

    function Contributer() public payable{
        require (block.timestamp < deadline, "The Deadline Has Passed");
        require (msg.value >= minimumContribution, "The minimum contribution not met.");

        if(contributors[msg.sender] == 0){
            noOfContributors ++;
        }
        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;

        emit ContributeEvent(msg.sender, msg.value);
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    // When contributor want to get back money
    function getRefund() public payable{
        require (block.timestamp > deadline, "Deadline has not passed."); // can't not Refun when deadline not Passed
        require (raisedAmount < goal, "The Goal Was Met."); // can't not Refun when contribution money met Goal
        require (contributors[msg.sender] > 0, "You are not any contribute"); // Not contribution => Not Refund
        address payable recipient = payable(msg.sender);        
        recipient.transfer(contributors[msg.sender]);
        contributors[msg.sender] = 0;
    }

    function createRequest(string memory _discription, address payable _recipient, uint _value) public onlyAdmin{
        Request storage newRequest = requests[numRequests];
        numRequests ++;

        newRequest.discription = _discription;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.complete = false;
        newRequest.noOfVote = 0;

        emit CreateRequestEvent(_discription, _recipient , _value);
    }

    function voteRequest(uint _requestNo) public{
        require (contributors[msg.sender]>0, "You Must be contributor to vote.");
        Request storage request = requests[_requestNo];

        require (request.voters[msg.sender] ==false, "You have already voted");
        request.voters[msg.sender] = true;        
        request.noOfVote ++;
    }

    function makePayment(uint _requestNo) public onlyAdmin{
        Request storage request = requests[_requestNo];

        require (request.complete == false, "This request hasbeen Complete");
        require (request.noOfVote > noOfContributors/2, "The request need more 50% of the Contributors");
        
        request.recipient.transfer(request.value);
        request.complete = true;
        emit MakePaymentEvent(request.recipient,request.value);
    }

    event ContributeEvent(address _sender, uint _value);
    event CreateRequestEvent(string _discription, address _recipient, uint _value);
    event MakePaymentEvent (address _recipient, uint _value);

}
