pragma solidity >=0.4.22 <0.7.0;
pragma experimental ABIEncoderV2;
import 'DistributeFunding.sol';
import 'OwnerProperty.sol';

contract CrowdFunding is OwnerProperty {
    
    uint fundingGoal;
    uint currentFunds;
    bool campaignEnded; //by default initialized with false
    mapping (address => Contributor) donors;
    DistributeFunding distributeFunding;
    
    struct Contributor{
        string name;
        string countryCode;
        uint donatedSum;
        bool exists;
    }
    
    event newDonation (Contributor _contributor);
    event checkStatus (uint _currentFunds, string message);
    event donationRetracted(address _contributorAddress, uint _retractedSum);
    event endCampaign ();
   
    constructor (uint _fundingGoal) public {
        fundingGoal = _fundingGoal;
        currentFunds = 0;
    }
    
    function donate(string memory _name, string memory _countryCode ) payable public {
        
        Contributor memory currentContributor = donors[msg.sender];
        
        require(
            campaignEnded != true,
            "Our Campaign has ended but thank you very much for your intent!"
            );
        
        if(currentContributor.exists == false) {  //new donor - does not exist in the mapping
            currentContributor = Contributor({
                name: _name,
                countryCode: _countryCode,
                donatedSum: msg.value,
                exists: true
            });
        }
        else {
            currentContributor.donatedSum += msg.value;   //if an already existing contributor makes another donation, just increase the sum
        }
        
        currentFunds += msg.value;
        donors[msg.sender] = currentContributor;
        emit newDonation(currentContributor);
        
        if(currentFunds > fundingGoal){
            campaignEnded = true;
            emit endCampaign();
        }
    }
    
    function retract (uint amount) public {
        Contributor memory currentContributor = donors[msg.sender];
        
        require( 
            currentContributor.exists == true,
            "I'm sorry but it looks like you are not part of our list of contributors."
            );
        
        require(
            campaignEnded != true,
            "Sorry but our campaign has ended. You can no longer retract your donation."
            );
        
        
        currentFunds -= amount;
        currentContributor.donatedSum -= amount;
        
        if(currentContributor.donatedSum == 0) {
            delete donors[msg.sender];
        }
        
        emit donationRetracted(msg.sender, amount);
        
        msg.sender.transfer(amount);
    }
    
    function sent2distribute () public onlyOwner {
        
        require(
            campaignEnded == true,
            "Sorry but you cannot distribute the funds until the campaign has ended."
            );
        
        distributeFunding.receiveFunds{value:currentFunds};
        currentFunds = 0;
    }
    
    function campaignStatus() public {
        if (currentFunds < fundingGoal)
            emit checkStatus(currentFunds, "We have not reached our Goal yet");
        else
            emit checkStatus(currentFunds, "We have reached our goal :D");
    }

}
