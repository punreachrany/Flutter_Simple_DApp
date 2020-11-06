// Copy this to Remix.ethereum.org

pragma solidity 0.6.6;

contract PKCoin{
    int balance;
    string smartText;
    
    constructor() public {
        balance = 0;
        smartText = "Nothing";
    }
    
    function getBalance() view public returns(int) {
        return balance;
    }
    
    function depositBalance(int amount) public {
        balance = balance + amount;
    }
    
    function withdrawBalance(int amount) public {
        balance = balance - amount;
    }
    
    function getSmartText() view public returns (string memory){
        return smartText;
    }
    
    function setSmartText(string memory inputText) public {
        smartText = inputText;
    }
}