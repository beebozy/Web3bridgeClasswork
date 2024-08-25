// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

contract CrowdFunding {
    address public owner;

    struct Campaign {
        string title;
        string description;
        address payable benefactor;
        uint256 goal;
        uint256 deadline;
        uint256 amountRaised;
        bool isActive;
    }

    uint256 public campaignCounter;
    mapping(uint256 => Campaign) public campaigns;

    event CampaignCreated(
        uint256 indexed campaignId,
        string title,
        address benefactor
    );
    event DonationReceived(
        uint256 indexed campaignId,
        address donor,
        uint256 amount
    );
    event CampaignEnded(
        uint256 indexed campaignId,
        address benefactor,
        uint256 amountRaised
    );

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Create a new campaign
    function createCampaign(
        string memory _title,
        string memory _description,
        address payable _benefactor,
        uint256 _goal,
        uint256 _deadline // Deadline in seconds since the epoch
    ) external onlyOwner {
        require(_deadline > block.timestamp, "Deadline must be in the future");

        campaignCounter++;
        campaigns[campaignCounter] = Campaign({
            title: _title,
            description: _description,
            benefactor: _benefactor,
            goal: _goal,
            deadline: _deadline,
            amountRaised: 0,
            isActive: true
        });

        emit CampaignCreated(campaignCounter, _title, _benefactor);
    }

    // Donate to a campaign
    function donateToCampaign(uint256 _campaignId) external payable {
        Campaign storage campaign = campaigns[_campaignId];
        require(campaign.isActive, "Campaign is not active");
        require(block.timestamp < campaign.deadline, "Campaign has ended");
        require(msg.value > 0, "Donation must be greater than zero");

        campaign.amountRaised += msg.value;

        emit DonationReceived(_campaignId, msg.sender, msg.value);
    }

    // End a campaign and transfer funds to the benefactor
    function endCampaign(uint256 _campaignId) external onlyOwner {
        Campaign storage campaign = campaigns[_campaignId];
        require(
            block.timestamp >= campaign.deadline,
            "Campaign has not reached its deadline yet"
        );
        require(campaign.isActive, "Campaign has already been ended");

        campaign.isActive = false;
        campaign.benefactor.transfer(campaign.amountRaised);

        emit CampaignEnded(
            _campaignId,
            campaign.benefactor,
            campaign.amountRaised
        );
    }

    // Get the balance of the contract (all campaigns)
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
