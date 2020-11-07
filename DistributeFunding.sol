pragma solidity >=0.4.22 <0.7.0;

contract DistributeFunding {
    
   struct Beneficiary{
        string name;
        uint256 percentage;
    }
    
    event fundsReceived(uint256 _funds);
   
   function receiveFunds(uint256 _funds) public {
        emit fundsReceived(_funds);
    }
   
}
