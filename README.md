# SmartBlackJack
A smart contract written in Solidity to play BlackJack


For a easier implementation:
1. Copy the solidity file into Remix.  
2. Compile using 0.5.16 version compiler.  
3. Select an account as the dealer account.  
4. Click deploy to deploy the contract.  
5. Switch to another player account, and copy its address.  
6. Under the deployed contracts section, click on BlackJack.  
7. In the "Value" text box, enter a value of deposit (switch unit to Ether) you want to place.  
8. Click "placeDeposit" button to place deposit.  
9. Paste the player's address into the text box next to "playerBalance" button. Click it, you should be able to see your balance.
10. Enter a value in the text box next to the "setBetValue" button, and click it.  
11. Click the "placeBet" button to start the game.  
12. To see your first two cards and the dealer's first card, expand the transaction and see the log.  
13. Now, you can hit, stand, or buy insurance. (click the "buyInsurance" button if the dealer's first card is an A)  
14. After you stand, the dealer draws card. And you can look at each draw in the log.  
15. At each stage of the game, you can click on "playerScore" or "dealerScore" to see the current scores.  
16. After each game ends, your balance changes accordingly.  
17. Place bet to start another game.  
18. If you want to cash out, enter an account that you want to cash out to in the text box next to the "cashOut" button. Do NOT hit the button!  
19. Switch to the dealer account, and check the player's balance. Enter the number into the "Value" box, and click "cashOut".  
