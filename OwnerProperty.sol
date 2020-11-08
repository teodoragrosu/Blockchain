pragma solidity >=0.4.22 <0.7.0;

contract OwnerProperty {
    
   address payable public owner;
   
   constructor() public {
      owner = msg.sender;
   }
   
   modifier onlyOwner {
      require(msg.sender == owner, "I'm sorry but you are not the owner of this contract");
      _;
   }
}
