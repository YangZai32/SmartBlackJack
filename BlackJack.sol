//pragma solidity 0.5.1;
pragma solidity 0.5.16;
contract PlayBlackJack{

    mapping(address =>uint256) public playerBalance;
    address payable dealerWallet;
    address payable playerWallet = msg.sender;
    uint256 public playerScore;
    uint256 public dealerScore;
    uint256 internal betValue;
    uint internal insuranceValue;
    bool internal standFlag = false;
    bool internal betPlaced = false;
    bool internal gameInactive = false;
    bool internal insuranceAvailable = false;
    bool internal insurancePaid = false;
    uint internal randNonce = 0;
    
    event MoneyFlow(
        address _from,
        address _to,
        uint256 amount
    );

    event showFirstHand(
        uint playerFirstCard,
        uint playerSecondCard,
        uint dealerFirstCard
    );
    event showPlayerCard(
        uint playerCard,
        uint playerTotalScore
    );

    event showDealerCard(
        uint dealerCard,
        uint dealerTotalScore
    );

    event dealerBust(
        string status
    );

    event tie(
        string status
    );

    event dealerWon(
        string status
    );

    event playerWon(
        string status
    );
    event debug(
        bool betPlaced
    );

    modifier enoughBalance () {
        require(betValue<playerBalance[msg.sender],"You don't have enough balance.");
        _;
    }

    modifier gameActive (){
        require(gameInactive == false, "Current game is ended, place bet to start a new game.");
        _;
    }

    modifier notBust () {
        require(playerScore < 21, "Already busted, do not hit");
        _;
    }

    modifier nonStand (){
        require(standFlag == false, "You already standed, cannot hit.");
        _;
    }

    modifier betNotPlaced (){
        require(betPlaced == false, "You haven't placed a bet");
        _;
    }

  

    // constructor(address payable _dealerWallet) public{
    //     dealerWallet = _dealerWallet;
    // }
    constructor() public {
        dealerWallet = msg.sender;
    }
    
    function payInsurance() public {
        require(insuranceAvailable == true,"Insurance not available now");
        require(insurancePaid == false, "Insurance is already paid.");
        if (betValue%2 ==0){
            insuranceValue = betValue/2;
        } 
        else{
            insuranceValue = (betValue+1)/2;
        }
        playerBalance[msg.sender] -= insuranceValue;
        insurancePaid = true;
    }

    function randomNumber() internal returns(uint){
        randNonce++; 
        uint temp = uint(keccak256(abi.encodePacked(now,msg.sender,randNonce)))%13;
        temp += 1;
        if (temp>=10){
            return 10;
        } 
        else{
            return temp;
        }
 
    }

    function placeDeposit() public payable {
        // buy number of tokens equal to the number of ethers sent
        playerBalance[msg.sender] += msg.value/1000000000000000000;
        // send ethers to dealer's wallet
        dealerWallet.transfer(msg.value);
        emit MoneyFlow(msg.sender, dealerWallet, msg.value/1000000000000000000);
    }




    function setBetValue(uint256 _betValue) public {
        betValue = _betValue;
    }

    function placeBet() public enoughBalance betNotPlaced returns(uint256, uint256, uint256){
        gameInactive = false;
        betPlaced = true;
        playerBalance[msg.sender] -= betValue;
        uint temp1 = playerDrawCard();
        uint temp2 = playerDrawCard();
        uint temp3 = dealerDrawCard();
        emit showFirstHand(temp1, temp2, temp3);

        if ((temp1 == 1 && temp2 == 10)||(temp1==10 && temp2 == 1) ){
            emit playerWon("Player Black Jack, 3 times bet value transferred to balance");
            playerBalance[msg.sender] += 3*betValue;
            // initialize the game
            gameInactive = true;
            betPlaced = false;
            playerScore = 0;
            dealerScore = 0;
            standFlag = false;
        }
        else if (temp3 == 1){
        insuranceAvailable = true;
        }
 
        return (playerBalance[msg.sender],playerScore, dealerScore);

    }

    function playerDrawCard() internal notBust returns(uint){
        uint score = randomNumber();
        playerScore += score;
        return score;
    }

    function dealerDrawCard() internal notBust returns(uint){
        uint score = randomNumber();
        dealerScore += score;
        return score;
    }

    function hit() public notBust nonStand gameActive returns(uint256){
        uint temp = playerDrawCard();
        emit showPlayerCard(temp,playerScore);

        if (playerScore>21){
            emit dealerWon("Player busted");
            gameInactive = true;
            betPlaced = false;
            playerScore = 0;
            dealerScore = 0;
            standFlag = false;
            insurancePaid = false;
            insuranceAvailable = false; 
            emit debug(betPlaced);
        }
  
    }

    function stand() public gameActive {
        standFlag = true;
        uint dealerSecondCard = dealerDrawCard();
        emit showDealerCard(dealerSecondCard,dealerScore);
        if (dealerSecondCard ==10 && insurancePaid == true ){
            playerBalance[msg.sender] += 2 * insuranceValue;
            gameInactive = true;
            betPlaced = false;
            playerScore = 0;
            dealerScore = 0;
            standFlag = false;
            insurancePaid = false;
            insuranceAvailable = false; 
        }

        while (dealerScore < 17){
            uint temp = dealerDrawCard();
            emit showDealerCard(temp,dealerScore);
        }
        while (dealerScore < playerScore){
            uint temp = dealerDrawCard();
            emit showDealerCard(temp,dealerScore);
        }
        if (dealerScore > 21) {
            emit dealerBust("Dealer busted, 2 times bet value transferred to balance");
            gameInactive = true;
            betPlaced = false;
            playerScore = 0;
            dealerScore = 0;
            standFlag = false;
            insurancePaid = false;
            insuranceAvailable = false; 
            // 最后 cash out 按照balance余额退还
            playerBalance[msg.sender] += 2 * betValue;
            emit debug(betPlaced);
        } else if (dealerScore == playerScore) {
            emit tie("Tie, bet value transferred to balance");
            gameInactive = true;
            betPlaced = false;
            playerScore = 0;
            dealerScore = 0;
            standFlag = false;
            insurancePaid = false;
            insuranceAvailable = false; 
            // 最后 cash out 按照balance余额退还
            playerBalance[msg.sender] += betValue;
            
        } else if (dealerScore > playerScore){
            emit dealerWon("Dealer won");
            gameInactive = true;
            betPlaced = false;
            playerScore = 0;
            dealerScore = 0;
            standFlag = false;
            insurancePaid = false;
            insuranceAvailable = false; 
            
        }


    }
    function cashOut(address payable _cashOutAddress) payable public {
        require(gameInactive == true,"Plase end this game first, then cash out");
        // this balance is checked by dealer by calling playerBalance
        _cashOutAddress.transfer(msg.value);
    }


    
}

