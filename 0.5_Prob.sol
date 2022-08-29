//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 < 0.9.0;
contract myDapp{

    address payable public owner;
    address payable public ca;          //address of the contract
    uint public tbal = ca.balance;         //contract balance

    mapping(address => uint) stakers;       //mapping for stakers
    
    address[] addPlus;                      //addresses of the people
    uint public totalPlus=0;                //total ether put to stake for plus

    address[] addMinus;                     //addresses of the people
    uint public totalMinus=0;               //total ether put to stake for minus           

    uint public deadline = block.timestamp;     //the deadline after which no staking happens but only results arrive
    bool public button = false;                 //whether deadline has approached or not

    constructor() public{
        owner = payable(msg.sender);
        ca = payable(address(this));
        
    }

    // function isPassed() public view returns(bool){       //this function finds whether the deadline has passed or not
    //     if(deadline < block.timestamp){
    //         return true;
    //     }
    //     else{
    //         return false;
    //     }
    // }

    function doPlus() payable public{                   //function to stake ether on "plus"
        require(msg.value >= 0.006 ether,"bring 0.05 ether minimum");
        
        if(button==false && totalPlus==0 && totalMinus==0){     //if deadline has crossed and there was nothing on stake
            button=true;
            deadline = block.timestamp + 30 seconds;
        }
        
        if(block.timestamp < deadline && button==true){         //if the deadline has not reached but the staking status was "on"
        addPlus.push(msg.sender);                               // push the address of the person to the list
        stakers[msg.sender] = msg.value;                        // also put it inside the mapping 
        totalPlus += msg.value;                                 // increase the total stake put for "plus"
        ca.call{value:msg.value};                                  // send money to the contract 
        tbal = ca.balance;                                      // update the balance of the contract
        }

        else if(block.timestamp > deadline && (totalPlus!=0 || totalMinus!=0) ){
            packUp();               // if this function is called after the deadline and the previous results were not accomplished then those will be declared first
            doMinus();                  // after previous results were declared, then this function will be recalled
        }
    }

    function doMinus() payable public{              // same as the upper function but for people who have staked for "minus"
        require(msg.value >= 0.006 ether,"bring 0.05 ether minimum");
        
        if(button==false && totalPlus==0 && totalMinus==0){
            button=true;
            deadline = block.timestamp + 30 seconds;
        }

        if(block.timestamp < deadline && button==true){      
        addMinus.push(msg.sender);
        stakers[msg.sender] = msg.value;
        totalMinus += msg.value;
        ca.call{value:msg.value};
        tbal = ca.balance;
        }
        
        else if(block.timestamp > deadline && (totalPlus!=0 || totalMinus!=0) ){
            packUp();
            doMinus();
        }
    }

    function packUp() public{                       // this function is made to give results 
        require(totalPlus > 0 || totalMinus>0,"everything is empty");           //something must have been put to the stake
        require(deadline < block.timestamp,"time to hone de");                  // deadline must have reached
        
        if(totalPlus > totalMinus){             // if the "plus" stakes are more than the "minus"
            for(uint i=0; i < addMinus.length; i++){
                payable(addMinus[i]).send(((7 * stakers[addMinus[i]])/4));      // send all the people who have staked on "minus" after doing 1.75 times their ether
                stakers[addMinus[i]]=0;             // update their staked ether to zero in the mapping
            }
            owner.send((totalMinus/5));      // send owner the left over amount, leaving only some amount for gas fees

            //also popping the addresses of the people from the list
            for(uint i=0; i < addMinus.length; i++){
                addMinus.pop();
            }
            for(uint i=0; i < addPlus.length; i++){
                addPlus.pop();
            }
        }

        if(totalPlus < totalMinus){     // same as above but if the "minus" stakes are more than the "plus"
            for(uint i=0; i < addPlus.length; i++){
                payable(addPlus[i]).send(((7 * stakers[addPlus[i]])/4));
                stakers[addPlus[i]]=0;
            }
            owner.send((totalMinus/5));
            for(uint i=0; i < addPlus.length; i++){
                addPlus.pop();
            }
            for(uint i=0; i < addMinus.length; i++){
                addMinus.pop();
            }
        }
        // resetting the state variables 
        totalMinus=0;
        totalPlus=0;
        button=false;
        tbal = ca.balance;
    }
 
    // function for the owner to withdraw amount from the contract
    function withdraw(uint give) public{
        require(msg.sender == owner);
        payable(owner).transfer(give * 1000000000000000000);
        tbal = ca.balance;
    }
}
