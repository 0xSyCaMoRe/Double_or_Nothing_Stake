//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 < 0.9.0;
contract myDapp{
    address payable public owner;
    address payable public ca;
    uint public tbal = ca.balance;

    mapping(address => uint) plus;
    address[] addPlus;
    uint public totalPlus=0;

    mapping(address => uint) minus;
    address[] addMinus;
    uint public totalMinus=0;

    uint public deadline = block.timestamp;
    bool public button = false;

    constructor() {
        owner = payable(msg.sender);
        ca = payable(address(this));
        
    }

    function isPassed() public view returns(bool){
        if(deadline < block.timestamp){
            return true;
        }
        else{
            return false;
        }
    }

    function doPlus() payable public{      
        require(msg.value >= 0.05 ether,"bring 0.05 ether minimum");
        
        if(button==false && totalPlus==0 && totalMinus==0){
            button=true;
            deadline = block.timestamp + 30 seconds;
        }
        
        if(block.timestamp < deadline && button==true){
        addPlus.push(msg.sender);
        plus[msg.sender] = msg.value;
        totalPlus += msg.value;
        ca.call{value:msg.value};
        tbal = ca.balance;
        }

        else if(block.timestamp > deadline && (totalPlus!=0 || totalMinus!=0) ){
            packUp();
            doMinus();
        }
    }

    function doMinus() payable public{
        require(msg.value >= 0.05 ether,"bring 0.05 ether minimum");
        
        if(button==false && totalPlus==0 && totalMinus==0){
            button=true;
            deadline = block.timestamp + 30 seconds;
        }

        if(block.timestamp < deadline && button==true){      
        addMinus.push(msg.sender);
        minus[msg.sender] = msg.value;
        totalMinus += msg.value;
        ca.call{value:msg.value};
        tbal = ca.balance;
        }
        
        else if(block.timestamp > deadline && (totalPlus!=0 || totalMinus!=0) ){
            packUp();
            doMinus();
        }
    }

    function packUp() public{
        require(totalPlus > 0 || totalMinus>0,"everything is empty");
        require(deadline < block.timestamp,"time to hone de");
        
        if(totalPlus > totalMinus){
            for(uint i=0; i < addMinus.length; i++){
                payable(addMinus[i]).send(((7 * minus[addMinus[i]])/4));
                minus[addMinus[i]]=0;
            }
            owner.send((totalMinus/5));

            for(uint i=0; i < addMinus.length; i++){
                addMinus.pop();
            }
        }

        if(totalPlus < totalMinus){
            for(uint i=0; i < addPlus.length; i++){
                payable(addPlus[i]).send(((7 * plus[addPlus[i]])/4));
                plus[addPlus[i]]=0;
            }
            owner.send((totalMinus/5));
            for(uint i=0; i < addPlus.length; i++){
                addPlus.pop();
            }
        }

        totalMinus=0;
        totalPlus=0;
        button=false;
        tbal = ca.balance;
    }

    function withdraw(uint give) public{
        require(msg.sender == owner);
        payable(owner).transfer(give * 1000000000000000000);
        tbal = ca.balance;
    }
}

