pragma solidity >=0.4.22 <0.7.0;
pragma experimental ABIEncoderV2;

contract CrowdFunding {
    
    uint256 fundingGoal;
    uint256 currentFunds;
    bool campaignEnded; //by default initialized with false
    mapping (uint256 => Contributor) donors;
    uint256 dIndex;
    
    struct Contributor{
        string name;
        uint256 donation;
    }
    
    event newDonation (Contributor _contributor);
    event checkStatus (uint256 _currentFunds, string message);
    event donationRetracted(uint256 _contributorAddress, uint256 _retractedSum);
    event endCampaign ();
   
    constructor (uint256 _fundingGoal) public {
        fundingGoal = _fundingGoal;
        currentFunds = 0;
        dIndex = 0; 
    }
    
    
    function donate(Contributor memory _contributor) public {
        
        require(
            campaignEnded != true,
            "Our Campaign has ended but thank you very much for your intent!"
            );
        
        donors[dIndex] = _contributor;
        dIndex += 1;
        currentFunds += _contributor.donation;
        emit newDonation(_contributor);
        
        if(currentFunds > fundingGoal){
            campaignEnded = true;
            emit endCampaign();
        }
    }
    
    function retract (uint256 _contributorAddress) public {
        require(
            campaignEnded != true,
            "Sorry but our campaign has ended. You can no longer retract your donation."
            );
        
        emit donationRetracted(_contributorAddress, donors[_contributorAddress].donation);
        currentFunds -= donors[_contributorAddress].donation;    
        delete donors[_contributorAddress];
    }
    
    function sent2distribute (address payable _distributeFunding) public {
        
        _distributeFunding.send(currentFunds);
        
    }
    
    function campaignStatus() public {
        if (currentFunds < fundingGoal)
            emit checkStatus(currentFunds, "We have not reached our Goal yet");
        else
            emit checkStatus(currentFunds, "We have reached our goal :D");
    }

}

