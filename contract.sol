// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
contract main {
    address public creator; // creator address
    mapping(address => bool) public contributors; // we create a map for store the contributer address
    uint public contributorCount; // we must count the number of contributer
    uint public minimumContribution; // there must be a minimum limit for contribution 
    string public project_name;
    string public description;

    struct Request {
        string description;
        uint value;
        address recipient;
        bool completed;
        uint approversCount;
        mapping(address => bool) approvers;
    }
    // by using struct, we can create our data type and in this structure, the most important data are...
    // approvers: it defined for storing the addres which approve the request. 
    // 

    Request[] request;

    constructor (string memory _name, string memory _description, uint _minimum ) {
        project_name = _name;
        minimumContribution = _minimum;
        description = _description;
        creator = msg.sender;
    }
// constructor part defiend the contract 
    modifier onlyOwner () {
        require(msg.sender == creator);
        _;
    }
// only owner was written for only the creator of the contract makes a request
    function contribute() public payable {
        require(msg.value <= minimumContribution, "Not enough funds");
        contributors[msg.sender] = true;
        contributorCount++;
    }

    function createRequest (string memory _description, uint _value, address _recipient) public onlyOwner{
        Request storage newRequest = request.push();

        newRequest.description = _description;
        newRequest.value = _value;
        newRequest.recipient = _recipient;
        newRequest.completed = false;
        newRequest.approversCount = 0;
    }

    function approveRequest (uint _index) public {
        require(contributors[msg.sender], "Not funder");
        Request storage cRequest = request[_index];
        require(cRequest.completed == false, "Request is complete");
        require(cRequest.approvers[msg.sender] == false, "Already approved");

        cRequest.approvers[msg.sender] = true;
        cRequest.approversCount++;
    }

    function finalizeRequest (uint _index) public onlyOwner {
        Request storage cRequest = request[_index];
        require(!cRequest.completed, "already completed");
        require(cRequest.approversCount < contributorCount/2, "not enough approval");

        cRequest.completed = true;

        payable (cRequest.recipient).transfer(cRequest.value);


    }

}