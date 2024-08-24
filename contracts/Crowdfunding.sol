// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    // Struct to represent a campaign
    struct Campaign {
        string title;
        string description;
        address payable benefactor;
        uint256 goal;
        uint256 deadline;
        uint256 amountRaised;
        bool ended;
    }

    // Array to store all campaigns
    Campaign[] public campaigns;

    // Contract owner
    address public owner;

    // Reentrancy guard
    bool private locked;

    // Events
    event CampaignCreated(
        uint256 campaignId,
        string title,
        address benefactor,
        uint256 goal,
        uint256 deadline
    );
    event DonationReceived(uint256 campaignId, address donor, uint256 amount);
    event CampaignEnded(
        uint256 campaignId,
        uint256 amountRaised,
        bool goalReached
    );

    // Modifiers
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function"
        );
        _;
    }

    //Prevent reentrancy
    modifier noReentrant() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    //Assign the owner variable to the person that deploys the contract
    constructor() {
        owner = msg.sender;
    }

    // Function to create a new campaign
    function createCampaign(
        string memory _title,
        string memory _description,
        address payable _benefactor,
        uint256 _goal,
        uint256 _duration
    ) public {
        require(_goal > 0, "Goal must be greater than zero");
        require(_duration > 0, "Duration must be greater than zero");
        require(_benefactor != address(0), "Invalid benefactor address");

        //Adding the duration to the current timestamp when this function is called
        uint256 deadline = block.timestamp + _duration;

        campaigns.push(
            Campaign({
                title: _title,
                description: _description,
                benefactor: _benefactor,
                goal: _goal,
                deadline: deadline,
                amountRaised: 0,
                ended: false
            })
        );

        uint256 campaignId = campaigns.length - 1;
        emit CampaignCreated(campaignId, _title, _benefactor, _goal, deadline);
    }

    // Function to donate to a campaign
    function donate(uint256 _campaignId) public payable noReentrant {
        Campaign storage campaign = campaigns[_campaignId];
        require(!campaign.ended, "Campaign has ended");
        require(
            block.timestamp < campaign.deadline,
            "Campaign deadline has passed"
        );
        require(msg.value > 0, "Donation amount must be greater than zero");

        campaign.amountRaised += msg.value;

        // Emit event when donated
        emit DonationReceived(_campaignId, msg.sender, msg.value);

        if (campaign.amountRaised >= campaign.goal) {
            endCampaign(_campaignId);
        }
    }

    // Function to end a campaign and transfer funds
    function endCampaign(uint256 _campaignId) public noReentrant {
        Campaign storage campaign = campaigns[_campaignId];
        require(!campaign.ended, "Campaign has already ended");
        require(
            block.timestamp >= campaign.deadline ||
                campaign.amountRaised >= campaign.goal,
            "Campaign cannot be ended yet"
        );

        // Effects
        campaign.ended = true;
        bool goalReached = campaign.amountRaised >= campaign.goal;
        uint256 amountToTransfer = campaign.amountRaised;
        campaign.amountRaised = 0; // Reset before transfer
        address benefactor = campaigns[_campaignId].benefactor;

       
        payable(benefactor).transfer(amountToTransfer);

        emit CampaignEnded(_campaignId, amountToTransfer, goalReached);
    }

    // Function for the owner to withdraw any leftover funds
    function withdrawLeftoverFunds() public onlyOwner noReentrant {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

               payable(owner).transfer(balance);

    }

    // Function to get campaign details
    function getCampaign(
        uint256 _campaignId
    )
        public
        view
        returns (
            string memory title,
            string memory description,
            address benefactor,
            uint256 goal,
            uint256 deadline,
            uint256 amountRaised,
            bool ended
        )
    {
        require(_campaignId < campaigns.length, "Invalid campaign ID");
        Campaign storage campaign = campaigns[_campaignId];
        return (
            campaign.title,
            campaign.description,
            campaign.benefactor,
            campaign.goal,
            campaign.deadline,
            campaign.amountRaised,
            campaign.ended
        );
    }

    // Receive function to receive direct transfers
    receive() external payable {}
}
