# better-escrow
## The Better Escrow Service

Runs on Stacks blockchain, secured by Bitcoin.

![scenario_001.png](https://raw.githubusercontent.com/dartman10/better-escrow/develop/img/scenario_001.png)


![scenario_002.png]( https://raw.githubusercontent.com/dartman10/better-escrow/develop/img/scenario_002.png)


-------------------------------------------------------------
   better-escrow : The better escrow service.
-------------------------------------------------------------
 This escrow smart contract implementation solves some problems:

   1. Buyer takes advantage by claming item not received or item broken. 
      This is a common problem with Ebay. Ebay simply sides, to seller's dismays,
      with buyers in most cases without investigation.

   2. Seller posts item with no intention of selling.
      This is a common problem with Craiglist. Many sellers, for some reason,
      are fakes.  These fake sellers agree to meet up but never show up.

   3. Tedious and transaction delays.
      Real estate transaction is a good  example.
      Normally, a deposit is required when a builder and buyer agrees to transact.
      A real estate attorney will act as escrow, accepts deposit and hold in a bank account.
      Using better-escrow, transaction becomes simpler and less legal paperwork by eliminating a middleman.
      The builder is also incentivized to finish the job on time because he also needs to put up a collateral.  
      Delays in construction is very common and perhaps better-escrow may alleviate some of that.

;;   4. International retail mail orders are limited due to buyers tend to avoid sellers from out of the country.
;;      This maybe minimized if both the seller and the buyer has skin in the game.
;;      
;;
;; Possible solution to stated problems above:
;;   The main feature of this escrow smart contract is the collateral requirement.  It requires both the buyer
;;   and the seller to deposit funds into the smart contract.  Buyer deposits funds equal to twice the price of
;;   the product.  While the seller deposit funds equal to the product price.  This will, optimistically, discourage
;;   bad actors from participating in a transaction.  This will also incentivize all actors from getting things done
;;   quicker - seller delivers product faster, buyer provides confirmation sooner, mediator mediates without delay.
;;   
;;     
;; Actors : seller, buyer, mediator.
;;   1. Seller - creates a bill to be sent to buyer (creates an instance of escrow smart contract)
;;   2. Buyer - accepts the bill charges (in the smart contract)  and sends funds to escrow (into the same smart contract)
;;   3. Mediator - in case of dispute. A real estate attorney, for example . Or find one at https://www.aaamediation.org
;;
;;
;; To Dos:
;;   1. Add another actor, an Agent.  The person facilitating or assisting the seller and buyer with using 
;;      the escrow smart contract app.  This role is especially important for big ticket items.  May be important
;;      in early stages of app adoption.  This is also a possible job/gig creation opportunity.
;;   2. Handle multiple instances of live escrows.
;;   3. Create UI.
;;
;;
;; Some future practical features or use-cases:
;;   1. Escrow agents can utilize smart contract. To minimize paper work and to eliminate wiring funds thru banks.
;;   2. Mediators can enroll as service providers.  To help build trust in the system.
;;   3. Make fiat/STX/MIA transaction seamless and user friendly.
;;   4. Escrow API for third party integration.
;;


