// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

  /**
   * @title ContractName
   * @dev ContractDescription
   * @custom:dev-run-script ./scripts/deploy_with_web3.ts
   */
contract Ballot_FX17394{
    
    // Struct của cử tri
    struct Voter{
        uint weight; // Trọng số của phiếu bầu, tùy vào vai trò của cử tri thi trọng số này có thể khác nhau, nhưng hầu hết đều bằng nhau.
        bool voted; // Phân biệt cử tri đã vote hay chưa. {true: "Đã vote rồi", false:"Chưa vote"}
        address delegate; // địa chỉ của người được ủy quyền vote thay cho user
        uint vote; // vote cho ứng cử viên nào (index của Proposals)
    }

    // Struct của ứng cử viên
    struct Proposal{
        bytes32 name; // Tên của ứng cử viên
        uint voteCount; // Tổng số phiếu được bầu (vote)
    }

    // Người khởi tạo hợp đồng này, có thể là đại diện cho chính phủ hoặc tổ chức
    address chairPerson;
    
    // Mapping lưu trữ người người tham gia bỏ phiếu (người dân OR thành viên trong tổ chức)
    mapping (address => Voter) voters;
    
    // Danh sách các ứng cử viên
    Proposal[] proposals;

    // Contructer, các sử lý sẽ thực hiện khi hợp đồng được tạo.
    // Với giá trị khởi tạo là tên của các ứng cử viên
    constructor (bytes32[] memory proposalNames){
        // Thiết lập chairPerson = Account hiện tại.    
        chairPerson = msg.sender;
        
        // Thiết lập trọng số cho chairPerson
        voters[chairPerson].weight =1;
        
        // Khởi tạo danh sách các ứng cử viên từ danh sách proposalNames
        for(uint i = 0; i<proposalNames.length; i++){
            proposals.push(Proposal({
                name:proposalNames[i],
                voteCount:0
            }));
        }
    }

    // Phương thức thêm cử tri(Address) vào hợp đồng. Có thể là tất cả người dân hoặc tất cả các thành viên trong tổ chức
    function giveRightToVote(address voter) public{
        // Kiểm tra người thực hiện phương thức có phải là chairPerson hay không? Chỉ chairPerson mới có thể thêm cử tri vào hợp đồng
        require(msg.sender == chairPerson, "Only chairPerson can give right to vote.");
        // Kiểm tra cử tri đã vote hay chưa?
        require(voters[voter].voted == false,"The voter is already voted.");
        // Kiểm tra cử tri đã tồn tại hay chưa (weight = 0)
        require(voters[voter].weight == 0);

        // Thêm vote vào hợp đồng
        voters[voter].weight=1;
        voters[voter].vote=0;
        voters[voter].voted=false;
    }

    // Phương thức ủy quyền bỏ phiếu
    function delegate(address to) public{
        // Lấy Voter từ msg.address (Người thực thi hàm)
        Voter storage sender = voters[msg.sender];

        // Kiểm tra ứng cử viên đã vote chưa?
        require(sender.voted==false, "You already voted.");
        // Kiêm tra có đang ủy quyền cho chính mình hay không?
        require(to != msg.sender,"Self-delegate is not disalowed.");
        // kiểm tra người thực hiện ủy quyền, có đang được ủy quyền từ 1 voter khác hay không?
        while(voters[to].delegate != address(0)){
            to = voters[to].delegate;
            require(to !=msg.sender, "You are delegated from order voter");
        }

        // Cập nhật trạng thái cho ngươi ủy quyền
        sender.voted=true;
        sender.delegate=to;

        // Cập nhật thông tin cho người được ủy quyền 
        Voter storage delegated_ = voters[to];
        if(delegated_.voted == true){ // Nếu người được ủy quyền đã vote
            // Tăng voteCount cho ứng cử viên mà người được ủy quyền đã vote
            proposals[delegated_.vote].voteCount += sender.weight;

        }else{ // Nếu người được ủy quyền chưa vote
            // Tăng trọng số cho người được ủy quyền
            delegated_.weight += sender.weight;
        }
    }

    // Phương thức bỏ phiếu
    function vote(uint proposal) public{
        Voter storage voter = voters[msg.sender];
        // Kiểm tra tư cách cử tri (đã được thêm vào smartcontract chưa?)
        require(voter.weight !=0 , "Has no right to vote");
        // Kiểm tra cử tri đã vote chưa?
        require(voter.voted==false, "You already voted.");
        // Cập nhật trạng thái vote cho cử tri.
        voter.voted = true;
        voter.vote = proposal;

        // Cập voteCounted cho proposal
        proposals[proposal].voteCount += voter.weight;
    }

    // Phương thức kiểm phiếu
    function winningProposal() public view returns (uint winningProposal_){        
        uint voteMax = 0;
        for(uint i=0; i<proposals.length; i++){
            if(proposals[i].voteCount>voteMax){
                voteMax = proposals[i].voteCount;
                winningProposal_ = i;
            }
        }
    }

    // Phương thức hiển thị tên người đắc cử
    function winnerName() public view returns (bytes32){
        return proposals[winningProposal()].name;
    }
}
