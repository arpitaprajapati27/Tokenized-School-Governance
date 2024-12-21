// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenizedSchoolGovernance {
    struct Proposal {
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
        uint256 deadline;
    }

    address public admin;
    mapping(address => uint256) public tokens;
    Proposal[] public proposals;

    event ProposalCreated(uint256 proposalId, string description, uint256 deadline);
    event Voted(uint256 proposalId, address voter, bool support, uint256 tokens);
    event ProposalExecuted(uint256 proposalId, bool approved);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can execute this function");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    // Mint tokens for stakeholders
    function mintTokens(address to, uint256 amount) external onlyAdmin {
        tokens[to] += amount;
    }

    // Create a new governance proposal
    function createProposal(string memory description, uint256 votingDuration) external onlyAdmin {
        uint256 deadline = block.timestamp + votingDuration;

        proposals.push(Proposal({
            description: description,
            votesFor: 0,
            votesAgainst: 0,
            executed: false,
            deadline: deadline
        }));

        emit ProposalCreated(proposals.length - 1, description, deadline);
    }

    // Vote on a proposal
    function vote(uint256 proposalId, bool support) external {
        require(tokens[msg.sender] > 0, "You must have tokens to vote");
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp < proposal.deadline, "Voting period has ended");
        require(!proposal.executed, "Proposal already executed");

        if (support) {
            proposal.votesFor += tokens[msg.sender];
        } else {
            proposal.votesAgainst += tokens[msg.sender];
        }

        emit Voted(proposalId, msg.sender, support, tokens[msg.sender]);
    }

    // Execute a proposal
    function executeProposal(uint256 proposalId) external onlyAdmin {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp >= proposal.deadline, "Voting period is still active");
        require(!proposal.executed, "Proposal already executed");

        proposal.executed = true;

        bool approved = proposal.votesFor > proposal.votesAgainst;
        emit ProposalExecuted(proposalId, approved);

        // Add logic for executing approved proposals
    }

    // Get the total number of proposals
    function getProposalCount() external view returns (uint256) {
        return proposals.length;
    }

    // Get details of a proposal
    function getProposal(uint256 proposalId) external view returns (string memory, uint256, uint256, bool, uint256) {
        Proposal memory proposal = proposals[proposalId];
        return (proposal.description, proposal.votesFor, proposal.votesAgainst, proposal.executed, proposal.deadline);
    }
}

