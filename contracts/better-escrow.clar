;; -------------------------------------------------------------
;;    better-escrow : The better escrow service.
;; -------------------------------------------------------------
;;
;; This escrow smart contract implementation solves some problems:
;;
;;   1. Buyer takes advantage by claming item not received or item broken. 
;;      This is a common problem with Ebay. Ebay simply sides, to seller's dismays,
;;      with buyers in most cases without investigation.
;;
;;   2. Seller posts item with no intention of selling.
;;      This is a common problem with Craiglist. Many sellers, for some reason,
;;      are fakes.  These fake sellers agree to meet up but never show up.
;;
;;   3. Tedious and transaction delays.
;;      Real estate transaction is a good  example.
;;      Normally, a deposit is required when a builder and buyer agrees to transact.
;;      A real estate attorney will act as escrow, accepts deposit and hold in a bank account.
;;      Using better-escrow, transaction becomes simpler and less legal paperwork by eliminating a middleman.
;;      The builder is also incentivized to finish the job on time because he also needs to put up a collateral.  
;;      Delays in construction is very common and perhaps better-escrow may alleviate some of that.
;;
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
;;   1. Allow seller and buyer to cancel the escrow transaction at appropriate statuses.
;;   2. Add another actor, the Agent.  The person facilitating or assisting the seller and buyer 
;;      with escrow smart contract app.  This role may be import in early stages of adoption.
;;
;;
;; Some future practical features or use-cases:
;;   1. Escrow agents can utilize smart contract. To minimize paper work and to eliminate wiring funds thru banks.
;;   2. Mediators can enroll as service providers.  To help build trust in the system.
;;   3. Make fiat/STX blockchain transaction seamless and user friendly.
;;   4. Escrow API for third party integration.
;;
;;
;; --------------------
;;  Constants
;; --------------------

;; Statuses or life stages of an escrow contract.
(define-constant STATE-INITIAL            u6000)  ;; Day 0
(define-constant STATE-SELLER-INITIATED   u6100)  ;; Seller initiated an escrow contract.
(define-constant STATE-BUYER-ACCEPTED     u6110)  ;; Buyer accepted terms of contract.
(define-constant STATE-SELLER-BUYS-IN     u6210)  ;; Seller accepts the buyer and buys in with collateral.
(define-constant STATE-BUYER-BUYS-IN      u6220)  ;; Buyer buys in with the sum of price and collateral.
(define-constant STATE-BUYER-IS-HAPPY     u6230)  ;; Buyer receives the product in agreed condition and is happy with the transaction.
(define-constant STATE-MEDIATOR-REQUESTED u6221)  ;; 
(define-constant STATE-MEDIATOR-ACCEPTED  u6222)  ;; 
(define-constant STATE-SELLER-OK-MEDIATOR u6322)  ;; 
(define-constant STATE-BUYER-OK-MEDIATOR  u6332)  ;; 
(define-constant STATE-MEDIATOR-SAYS-GOOD u6333)  ;; 
(define-constant STATE-MEDIATOR-SAYS-BAD  u6334)  ;; 
(define-constant STATE-SELLER-CANCELLED   u6335)  ;;
(define-constant STATE-BUYER-CANCELLED    u6336)  ;;

;; Errors
(define-constant ERR-WRONG-STATE-7000 u7000)
(define-constant ERR-WRONG-STATE-7001 u7001)
(define-constant ERR-WRONG-STATE-7002 u7002)
(define-constant ERR-WRONG-STATE-7003 u7003)
(define-constant ERR-WRONG-STATE-7004 u7004)
(define-constant ERR-WRONG-STATE-7005 u7005)
(define-constant ERR-WRONG-STATE-7006 u7006)
(define-constant ERR-WRONG-STATE-7007 u7007)
(define-constant ERR-WRONG-STATE-7008 u7008)
(define-constant ERR-WRONG-STATE-7009 u7009)
(define-constant ERR-WRONG-STATE-7010 u7010)
(define-constant ERR-WRONG-STATE-7011 u7011)

(define-constant ERR-ACTOR-NOT-ALLOWED-8000 u8000)
(define-constant ERR-ACTOR-NOT-ALLOWED-8001 u8001)
(define-constant ERR-ACTOR-NOT-ALLOWED-8002 u8002)
(define-constant ERR-ACTOR-NOT-ALLOWED-8003 u8003)
(define-constant ERR-ACTOR-NOT-ALLOWED-8004 u8004)
(define-constant ERR-ACTOR-NOT-ALLOWED-8005 u8005)
(define-constant ERR-ACTOR-NOT-ALLOWED-8006 u8006)
(define-constant ERR-ACTOR-NOT-ALLOWED-8007 u8007)
(define-constant ERR-ACTOR-NOT-ALLOWED-8008 u8008)
(define-constant ERR-ACTOR-NOT-ALLOWED-8009 u8009)

;; --------------------
;;  Variables
;; --------------------
;;(define-data-var state-of-escrow uint u6000)             ;; deprecated . use escrow-status instead.
(define-data-var escrow-status uint u6000)               ;; current status of escrow contract
(define-data-var principal-seller   principal tx-sender) ;; initial value set to tx-sender, but will be overwritten later. to avoid "optional", "unwrap" and "some"
(define-data-var principal-buyer    principal tx-sender) ;; initial value set to tx-sender, but will be overwritten later.
(define-data-var principal-mediator principal tx-sender) ;; initial value set to tx-sender, but will be overwritten later.
(define-data-var price uint u0)                          ;; item price


;; ------------------
;; --- FUNCTIONS ----
;; ------------------

;; echo function - to check if contract is reachable. make this part of trait.
(define-read-only (echo (shout-out (string-ascii 100)))
   (ok shout-out))

;; help function - return helpful tips and usage. make this part of trait.
(define-read-only (help)
   (ok "help is on the way"))

;; about function - desribe this contract. make this part of trait.
(define-read-only (about)
   (ok "Just Another Escrow Application")
)

;;  --- Setters and Getters ---
(define-read-only (get-tx-sender)
  (ok tx-sender))

(define-read-only (get-contract-caller)
  (ok contract-caller))

(define-read-only (get-principal-contract)  ;; for Clarinet testing only
  (as-contract tx-sender)
)

(define-read-only (get-balance-contract)  ;; for Clarinet testing only
  (ok (stx-get-balance (get-principal-contract)))
)

(define-read-only (get-principal-seller)
  (var-get principal-seller))

(define-read-only (get-balance-seller)  ;; for Clarinet testing only
  (ok (stx-get-balance (get-principal-seller))) 
)

(define-private (set-principal-seller (principal-value principal)) 
  (var-set principal-seller principal-value))

(define-read-only (get-principal-buyer)
  (var-get principal-buyer))

(define-read-only (get-balance-buyer)  ;; for Clarinet testing only
  (ok (stx-get-balance (get-principal-buyer))))

(define-private (set-principal-buyer (principal-value principal))
  (var-set principal-buyer principal-value))

(define-read-only (get-principal-mediator)
  (var-get principal-mediator))

(define-private (set-principal-mediator (principal-value principal))
  (var-set principal-mediator principal-value)
)

(define-read-only (get-balance-mediator)  ;; for Clarinet testing only
  (ok (stx-get-balance (get-principal-mediator)))
)

(define-read-only (get-price)
  (var-get price)
)

(define-private (set-price (price-value uint))
  (var-set price price-value)
)

;; (define-public (status-of-contract)  ;; deprecated. use (get-status-of-escrow)
;;   (ok (var-get state-of-escrow))     ;; Return status of contract
;; )

(define-read-only (get-escrow-status)  ;; 
  (var-get escrow-status)     ;; Return status of escrow contract
)

(define-private (set-escrow-status (state-new uint))  
  (var-set escrow-status state-new)  ;; update status of contract
)

;; -- Escrow status inquiries --
(define-read-only (is-state-initial)
  (is-eq (get-escrow-status) STATE-INITIAL))

(define-read-only (is-state-buyer-happy)
  (is-eq (get-escrow-status) STATE-BUYER-IS-HAPPY))

(define-read-only (is-state-seller-initiated)
  (is-eq (get-escrow-status) STATE-SELLER-INITIATED))

(define-read-only (is-state-buyer-accepted)
  (is-eq (get-escrow-status) STATE-BUYER-ACCEPTED))

(define-read-only (is-state-seller-buys-in)
  (is-eq (get-escrow-status) STATE-SELLER-BUYS-IN))

(define-read-only (is-state-buyer-buys-in)
  (is-eq (get-escrow-status) STATE-BUYER-BUYS-IN))

(define-read-only (is-state-mediator-requested)
  (is-eq (get-escrow-status) STATE-MEDIATOR-REQUESTED))

(define-read-only (is-state-mediator-accepted)
  (is-eq (get-escrow-status) STATE-MEDIATOR-ACCEPTED))

(define-read-only (is-state-seller-ok-mediator)
  (is-eq (get-escrow-status) STATE-SELLER-OK-MEDIATOR))

(define-read-only (is-state-buyer-ok-mediator)
  (is-eq (get-escrow-status) STATE-BUYER-OK-MEDIATOR))

(define-read-only (is-state-mediator-says-good)
  (is-eq (get-escrow-status) STATE-MEDIATOR-SAYS-GOOD))

(define-read-only (is-state-mediator-says-bad)
  (is-eq (get-escrow-status) STATE-MEDIATOR-SAYS-BAD))

(define-read-only (is-state-seller-cancelled)
  (is-eq (get-escrow-status) STATE-SELLER-CANCELLED))

(define-read-only (is-state-ready-for-next-round)
  (or (is-state-initial)
      (is-state-buyer-happy)
      (is-state-mediator-says-good)
      (is-state-mediator-says-bad)
      (is-state-seller-cancelled)
  )
)
  


;; --------------------------------
;; -- MAIN PROCESS BEGINS HERE ---
;; --------------------------------

;; Seller initiates a bill, with specified price.
(define-public (bill-create (price-request uint))
  (begin
    (asserts! (is-state-ready-for-next-round) (err ERR-WRONG-STATE-7000)) ;; check if contract status is eligible for the next round
    (set-principal-seller tx-sender)
    (set-price price-request)
    (set-escrow-status STATE-SELLER-INITIATED)
    (ok (get-escrow-status))
  )
)

;; Buyer accepts terms of the bill, no sending of funds yet.
(define-public (bill-accept)
  (begin
    (asserts! (is-state-seller-initiated) (err ERR-WRONG-STATE-7001))  ;; check escrow status
    (set-principal-buyer tx-sender)
    (set-escrow-status STATE-BUYER-ACCEPTED)
    (ok (get-escrow-status))
  )
)

;; Seller accepts Buyer and confirm.  Sends fund to contract principal.
(define-public (fund-seller)
  (begin
    (asserts! (is-state-buyer-accepted) (err ERR-WRONG-STATE-7002)) ;; check escrow status
    (asserts! (is-eq tx-sender (get-principal-seller)) (err ERR-ACTOR-NOT-ALLOWED-8000))   
    (try! (transfer-to-contract (get-price))) 
    (set-escrow-status STATE-SELLER-BUYS-IN)
    (ok (get-escrow-status))
  ) ;; /begin
)

;; Buyer reviews seller fund and sends own fund. Contract becomes locked and loaded.
(define-public (fund-buyer)
  (begin
    (asserts! (is-state-seller-buys-in) (err ERR-WRONG-STATE-7003)) ;; check contract status
    (asserts! (is-eq tx-sender (get-principal-buyer)) (err ERR-ACTOR-NOT-ALLOWED-8001)) ;; make sure buyer is calling
    (try! (transfer-to-contract (* (get-price) u2)))   ;; Buyer sends twice as much as the seller's funds. Half for collateral, half for price of goods.
    (set-escrow-status STATE-BUYER-BUYS-IN)
    (ok (get-escrow-status))
  ) ;; /begin
)

;; Buyer confirms product received and acceptable. Releases payment.
(define-public (fund-release)
  (begin
    (asserts! (is-state-buyer-buys-in) (err ERR-WRONG-STATE-7004)) ;; check contract status first
    (asserts! (is-eq tx-sender (get-principal-buyer)) (err ERR-ACTOR-NOT-ALLOWED-8002)) ;; Only the buyer can release the funds.
    (try! (transfer-from-contract))   
    (set-escrow-status STATE-BUYER-IS-HAPPY)
    (ok (get-escrow-status))
  ) ;; /begin
)

;; Transfer funds into principal contract.
(define-private (transfer-to-contract (fund-amount uint))
  (begin
    (try! (stx-transfer? fund-amount tx-sender (as-contract tx-sender)))
    (ok u0)
  )
)

;; Transfer funds out from principal contract.
(define-private (transfer-from-contract)
  (begin
    (try! (as-contract (stx-transfer? (get-price) tx-sender (get-principal-buyer))))  ;; send funds to buyer
    (try! (as-contract (stx-transfer? (* (get-price) u2) tx-sender (get-principal-seller))))  ;; send funds to seller 
    (ok u0)
  )
)

;; ==============================================================
;;  Cancel Contract - seller or buyer cancels contract
;; ==============================================================

;; Seller cancels contract. No refund is needed because no locked funds yet.
(define-public (bill-cancel-seller-refund-no)
  (begin
    (asserts! (or (is-state-seller-initiated) (is-state-buyer-accepted)) 
              (err ERR-WRONG-STATE-7011)) ;; check contract status, if contract can be cancelled by seller
    (asserts! (is-eq tx-sender (get-principal-seller)) (err ERR-ACTOR-NOT-ALLOWED-8009)) ;; seller please
    (set-escrow-status STATE-SELLER-CANCELLED)  ;; cancel contract
    (ok (get-escrow-status))
  )
)

(is-state-seller-buys-in)
STATE-BUYER-CANCELLED


;; =============================
;;  MEDIATOR needed.  Oh boy.
;; =============================

;; Either the Seller or Buyer can request for a Mediator.
;; Once this happens:
;;   - Both Seller and Buyer has to sign if they like to cancel the mediator request;
;;   - The mediator has to sign contract as acceptance of responsibility.
;;   - The mediator has to lock funds too equal to the price. To motivate mediator to mediate without delay.
;; Question: How would I know who requested the Mediator? I can add a unique status combination, but for now just refer to blockchain history.

(define-public (request-mediator)
  (begin
    (asserts! (is-state-buyer-buys-in) (err ERR-WRONG-STATE-7005))
    (asserts! (or (is-eq tx-sender (get-principal-buyer)) (is-eq tx-sender (get-principal-seller)))  ;; cannot be the buyer nor the seller
              (err ERR-ACTOR-NOT-ALLOWED-8007))
    (set-escrow-status STATE-MEDIATOR-REQUESTED)
    (ok (get-escrow-status))
  )
)

;; Mediator accepts responsibility and buys in at set price. 
(define-public (mediate-accept)
  (begin
    (asserts! (is-state-mediator-requested) (err ERR-WRONG-STATE-7006))
    (asserts! (not  (or (is-eq tx-sender (get-principal-buyer))
                        (is-eq tx-sender (get-principal-seller))))
              (err ERR-ACTOR-NOT-ALLOWED-8008)  ;; error - neither buyer nor seller can be a mediator
    ) ;; /asserts!
    (set-principal-mediator tx-sender)         ;; the mediator is here. welcome sir.
    (try! (transfer-to-contract (get-price)))  ;; mediator buys in
    (set-escrow-status STATE-MEDIATOR-ACCEPTED)
    (ok (get-escrow-status))
  ) ;; /begin
)

;; Seller vets Mediator then confirms
(define-public (mediator-confirmation-seller)
  (begin
    (asserts! (is-eq tx-sender (get-principal-seller)) (err ERR-ACTOR-NOT-ALLOWED-8003))  ;; Check if tx-sender is Seller
    (asserts! (is-state-mediator-accepted) (err ERR-WRONG-STATE-7007)) ;; seller confirms ahead of buyer. refactor later to allow either buyer or seller to go ahead.
    (set-escrow-status STATE-SELLER-OK-MEDIATOR)
    (ok (get-escrow-status))
  ) ;; /begin
)

;; Buyer vets Mediator then confirms
(define-public (mediator-confirmation-buyer)
  (begin
    (asserts! (is-eq tx-sender (get-principal-buyer)) (err ERR-ACTOR-NOT-ALLOWED-8004)) ;; Check if tx-sender is Buyer
    (asserts! (is-state-seller-ok-mediator) (err ERR-WRONG-STATE-7008)) 
    (set-escrow-status STATE-BUYER-OK-MEDIATOR)
    (ok (get-escrow-status))
  ) ;; /begin
)

;; Mediator decides. Two possible outcomes:
;;  1. Mediator agrees with Seller, so contract will be exercised as agreed originally.
;;  2. Mediator agrees with Buyer, so contract will be nullified and return all money back.

(define-public (mediator-decides-good)
  (begin
    (asserts! (is-eq tx-sender (get-principal-mediator)) (err ERR-ACTOR-NOT-ALLOWED-8005)) ;; Check if tx-sender is Mediator
    (asserts! (is-state-buyer-ok-mediator) (err ERR-WRONG-STATE-7009)) ;; check if state is ready for this
    (try! (fund-disburse))
    (set-escrow-status STATE-MEDIATOR-SAYS-GOOD)
    (ok (get-escrow-status))
  ) ;; /begin
)

(define-public (mediator-decides-bad)
  (begin
    (asserts! (is-eq tx-sender (get-principal-mediator)) (err ERR-ACTOR-NOT-ALLOWED-8006)) ;; Check if tx-sender is Mediator
    (asserts! (is-state-buyer-ok-mediator) (err ERR-WRONG-STATE-7010)) ;; check if state is ready for this
    (try! (fund-refund))
    (set-escrow-status STATE-MEDIATOR-SAYS-BAD)
    (ok (get-escrow-status))
  ) ;; /begin
)

;; Mediator decided bad, so do refund.
;; Here's the deal:
;;  - Mediator gets paid commission, set percentage of sell price. half each from buyer and seller.
;;  - Seller gets all his money back minus half of mediator commission.
;;  - Buyer gets all his money back minus half mediator commission.
(define-private (fund-refund)
  (begin
    (try! (as-contract (stx-transfer? (+ (get-price) (get-mediator-commission)) tx-sender (get-principal-mediator))))  ;; send commission to mediator plus collateral
    (try! (as-contract (stx-transfer? (- (* (get-price) u2) (/ (get-mediator-commission) u2)) tx-sender (get-principal-buyer))))  ;; send collateral back to buyer minus half of mediator commission
    (try! (as-contract (stx-transfer? (- (get-price) (/ (get-mediator-commission) u2)) tx-sender (get-principal-seller))))  ;; send collateral back to seller minus half of mediator commission
    (ok u0)
  )
)

(define-private (get-mediator-commission)
  (/ (get-price) u10)  ;; mediator commission is hardcoded at 10%. improve later to allow buyer/seller to set dynamically.
)

;; Mediator decided good, so disburse funds appropriately.
(define-private (fund-disburse)
  (begin
    (try! (as-contract (stx-transfer? (+ (get-price) (get-mediator-commission)) tx-sender (get-principal-mediator))))  ;; send commission to mediator plus collateral/price
    (try! (as-contract (stx-transfer? (- (get-price) (/ (get-mediator-commission) u2)) tx-sender (get-principal-buyer))))  ;; send collateral/price back to buyer minus half of mediator commission, and minus the item price
    (try! (as-contract (stx-transfer? (- (* (get-price) u2) (/ (get-mediator-commission) u2)) tx-sender (get-principal-seller))))  ;; send collateral/price funds plus price to seller, minus half of mediator commission
    (ok u0)
  )
)
