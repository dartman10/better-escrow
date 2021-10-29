;; --------------------------------------------
;; better-escrow : The better escrow service.
;; --------------------------------------------
;;
;; Actors : seller, buyer, mediator.
;;   1. Seller - creates a bill to be sent to buyer (creates an instance of escrow smart contract)
;;   2. Buyer - accepts the bill charges (in the smart contract)  and sends funds to escrow (into the same smart contract)
;;   3. Mediator - needed in case of dispute. An actual real attorney, maybe.
;;
;; The HOWs:
;;  1. Once a buyer principal is present, the contract instance becomes a multisig contract.
;;  2. When adding a mediator principal, both the seller and buyer should accept and sign the contract.
;;  3. tbd
;;
;; Short term tactical solution, due to 3-week hackathon limit:
;; - Only one active smart contract at any given time.  Meaning, others have to wait until live contract is done.
;; - Use variables all over the place, but refactor later once everything is working.
;; - Write separate functions for individual scenarios. Refactor later to remove duplicate codes.
;;
;; Future enhancements:
;; - Use GAIA off-chain storage for persistent data.
;; - Enabling several instances of active escrow contracts.
;; - Allow participants to set collateral percentage, perhaps DAO enabled.
;;
;; ------------------------------------------
;; Enough talk.  Let's do this.
;; ------------------------------------------


;; --------------------
;;  Constants
;; --------------------
(define-constant ERR_STX_TRANSFER u0)

;; Statuses or life stages of an escrow contract.
(define-constant state-initial           u6000)  ;; Day 0
(define-constant state-seller-initiated  u6100)  ;; Seller initiated an escrow contract.
(define-constant state-buyer-accepted    u6110)  ;; Buyer accepted terms of contract.
(define-constant state-seller-buys-in    u6210)  ;; Seller accepts the buyer and buys in with collateral.
(define-constant state-buyer-buys-in     u6220)  ;; Buyer buys in with the sum of price and collateral.
(define-constant state-buyer-is-happy    u6230)  ;; Buyer receives the product in agreed condition and is happy with the transaction.

(define-constant state-mediator-requested u6221)  ;; 
(define-constant state-mediator-accepted  u6222)  ;; 
(define-constant state-seller-ok-mediator u6322)  ;; 
(define-constant state-buyer-ok-mediator  u6332)  ;; 
(define-constant state-mediator-says-good u6333)  ;; 
(define-constant state-mediator-says-bad  u6334)  ;; 


(define-data-var state-of-escrow uint u6000)

;; --------------------
;;  Variables
;; --------------------
(define-data-var principal-seller   principal tx-sender)  ;; initial value set to tx-sender, but will be overwritten later. to avoid "optional", "unwrap" and "some"
(define-data-var principal-buyer    principal tx-sender)  ;; initial value set to tx-sender, but will be overwritten later.
(define-data-var principal-mediator principal tx-sender) ;; initial value set to tx-sender, but will be overwritten later.

(define-data-var state-seller   uint u0)  ;; seller status - 0, 1, 2, 3, 4
(define-data-var state-buyer    uint u0)
(define-data-var state-mediator uint u0)

(define-data-var price uint u0)
(define-data-var buyer-funds uint u0)

;; private functions
;; 

;; -- Escrow status inquiries --
(define-read-only (is-state-initial)
  (is-eq (var-get state-of-escrow) state-initial))

(define-read-only (is-state-buyer-happy)
  (is-eq (var-get state-of-escrow) state-buyer-is-happy))

(define-read-only (is-state-seller-initiated)
  (is-eq (var-get state-of-escrow) state-seller-initiated))

(define-read-only (is-state-buyer-accepted)
  (is-eq (var-get state-of-escrow) state-buyer-accepted))

(define-read-only (is-state-seller-buys-in)
  (is-eq (var-get state-of-escrow) state-seller-buys-in))

(define-read-only (is-state-buyer-buys-in)
  (is-eq (var-get state-of-escrow) state-buyer-buys-in))

(define-read-only (is-state-mediator-requested)
  (is-eq (var-get state-of-escrow) state-mediator-requested))

(define-read-only (is-state-mediator-accepted)
  (is-eq (var-get state-of-escrow) state-mediator-accepted))

(define-read-only (is-state-seller-ok-mediator)
  (is-eq (var-get state-of-escrow) state-seller-ok-mediator))

(define-read-only (is-state-buyer-ok-mediator)
  (is-eq (var-get state-of-escrow) state-buyer-ok-mediator))

(define-read-only (is-state-mediator-says-good)
  (is-eq (var-get state-of-escrow) state-mediator-says-good))

(define-read-only (is-state-mediator-says-bad)
  (is-eq (var-get state-of-escrow) state-mediator-says-bad))


;; --- Status setters --
(define-private (set-escrow-status (state-new uint))
  (var-set state-of-escrow state-new)
)

;; echo function - to check if contract is reachable
(define-read-only (echo (shout-out (string-ascii 100)))
   (ok shout-out))

;; help function - return helpful tips and usage
;; make this part of trait
(define-read-only (help)
   (ok "help is on the way"))

;; about function - desribe this contract
;; make this part of trait
(define-read-only (about)
   (ok "Just Another Escrow Application"))

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
  (begin
    (var-set principal-mediator principal-value)
  )
)

(define-read-only (get-balance-mediator)  ;; for Clarinet testing only
  (ok (stx-get-balance (get-principal-mediator))))

(define-read-only (get-state-seller)
  (var-get state-seller))

(define-private (set-state-seller (state-value uint ))
  (var-set state-seller state-value))

(define-read-only (get-state-buyer)
  (var-get state-buyer))

(define-private (set-state-buyer (state-value uint ))
  (var-set state-buyer state-value))

(define-read-only (get-state-mediator)
  (var-get state-mediator))

(define-private (set-state-mediator (state-value uint ))
  (var-set state-mediator state-value))

(define-read-only (get-price)
  (var-get price))

(define-private (set-price (price-value uint))
  (var-set price price-value))

;; Return status of contract
(define-public (status-of-contract)
  (ok (var-get state-of-escrow))
)

;; Seller sends a bill.
(define-public (bill-create (price-request uint))
  (begin
    (asserts! (or (is-state-initial) (is-state-buyer-happy)) (err "lol")) ;; check if contract status is eligible for the next round
    (set-principal-seller tx-sender)
    (set-price price-request)
    (set-escrow-status state-seller-initiated)
    (ok (status-of-contract))
  )
)

;; Buyer accepts terms of the bill, no sending of funds yet.
(define-public (bill-accept)
  (begin
    (asserts! (is-state-seller-initiated) (err "no way"))
    (set-principal-buyer tx-sender)
    (set-escrow-status state-buyer-accepted)
    (ok (status-of-contract))
  )
)

;; Seller accepts Buyer and confirm.  Sends fund and locked.
(define-public (fund-seller)
  (begin
    (asserts! (is-state-buyer-accepted) (err u2)) ;; check escrow status
    (asserts! (is-eq tx-sender (get-principal-seller)) (err u1))   
    (try! (transfer-to-contract (get-price)))  ;; too many try!s
    (set-escrow-status state-seller-buys-in)
    (ok (status-of-contract))
  ) ;; /begin
)

;; Buyer reviews seller fund and send own fund. Contract now locked and loaded.
(define-public (fund-buyer)
  (begin
    (asserts! (is-state-seller-buys-in) (err u777)) ;; check contract status
    (asserts! (is-eq tx-sender (get-principal-buyer)) (err u666)) ;; make sure buyer is calling
    (try! (transfer-to-contract (* (get-price) u2)))   ;; Buyer puts in funds twice as much as the seller's funds. Half for collateral, half for price of goods.
    (set-escrow-status state-buyer-buys-in)
    (ok (status-of-contract))
  ) ;; /begin
)

;; Buyer signals product received and good condition.
;; Buyer release payment to seller.
;; Contract releases collaterals too.
(define-public (fund-release)
  (begin
    (asserts! (is-state-buyer-buys-in) (err u111)) ;; check first 
    (asserts! (is-eq tx-sender (get-principal-buyer)) (err u112)) ;; Only the buyer can release the funds.
    (try! (transfer-from-contract))     ;; try! returns a uint. try! is needed for intermediate blah blah
    (set-escrow-status state-buyer-is-happy)
    (ok (status-of-contract))
  ) ;; /begin
)

;; Transfer funds into principal contract.
(define-private (transfer-to-contract (fund-amount uint))
  (begin
    (try! (stx-transfer? fund-amount tx-sender (as-contract tx-sender)))
    (ok u0)
  )
)

(define-private (transfer-from-contract)
  (begin
    ;; as-contract replaces tx-sender inside the closure. get it? lol. easy-peasy.
    (try! (as-contract (stx-transfer? (get-price) tx-sender (get-principal-buyer))))  ;; send funds to buyer
    (try! (as-contract (stx-transfer? (* (get-price) u2) tx-sender (get-principal-seller))))  ;; send funds to seller 
    (ok "po")
  )
)

;; =============================
;;  MEDIATOR needed.  Oh boy.
;; =============================

;; Either the Seller or Buyer can request for a Mediator.
;; Once this happens:
;;   - Both Seller and Buyer has to sign if they like to cancel the mediator request;
;;   - The mediator has to sign contract as acceptance of responsibility.
;;   - The mediator has to lock funds too equal to the price. To motivate mediator to mediate without delay.
;; Question: How would I know who requested the Mediator? I need to add a unique status combination.

(define-public (request-mediator)
  (begin
    (asserts! (is-state-buyer-buys-in) (err u121))
    (asserts! (or (is-eq tx-sender (get-principal-buyer))
                  (is-eq tx-sender (get-principal-seller)))
              (err u121))
    (set-escrow-status state-mediator-requested)
    (ok (status-of-contract))
  )
)

;; Mediator accepts responsibility and buys in at set price. 
(define-public (mediate-accept)
  (begin
    (asserts! (is-state-mediator-requested) (err u141))
    (asserts! (not  (or (is-eq tx-sender (get-principal-buyer))
                        (is-eq tx-sender (get-principal-seller))))
              (err u131)  ;; error - neither buyer nor seller can be a mediator
    ) ;; /asserts!

    (set-principal-mediator tx-sender)  ;; the mediator is here. welcome sir.
    (try! (transfer-to-contract (get-price)))  ;; mediator buys in
    (set-escrow-status state-mediator-accepted)
    (ok (status-of-contract))
  ) ;; /begin
)

;; Seller vets Mediator then confirms
(define-public (mediator-confirmation-seller)
  (begin
    (asserts! (is-eq tx-sender (get-principal-seller)) (err u1001))  ;; Check if tx-sender is Seller
    (asserts! (is-state-mediator-accepted) (err u1002)) ;; seller confirms ahead of buyer. refactor later to allow either buyer or seller to go ahead.
    (set-escrow-status state-seller-ok-mediator)
    (ok (status-of-contract))
  ) ;; /begin
)

;; Buyer vets Mediator then confirms
(define-public (mediator-confirmation-buyer)
  (begin
    (asserts! (is-eq tx-sender (get-principal-buyer)) (err u1011)) ;; Check if tx-sender is Buyer
    (asserts! (is-state-seller-ok-mediator) (err u1012)) 
    (set-escrow-status state-buyer-ok-mediator)
    (ok (status-of-contract))
  ) ;; /begin
)

;; Mediator decides. Two possible outcomes (for now):
;;  1. Mediator agrees with Seller, so contract will be exercised as agreed originally.
;;  2. Mediator agrees with Buyer, so contract will be nullified and give all money back.
;; Question is, do we need signoff from either seller or buyer? Or mediator decision is final and immediately deliver the locked funds?

(define-public (mediator-decides-good)
  (begin
    (asserts! (is-eq tx-sender (get-principal-mediator)) (err u1021)) ;; Check if tx-sender is Mediator
    (asserts! (is-state-buyer-ok-mediator) (err u1022)) ;; check if state is ready for this
    (try! (fund-disburse))
    (set-escrow-status state-mediator-says-good)
    (ok (status-of-contract))
  ) ;; /begin
)

(define-public (mediator-decides-bad)
  (begin
    (asserts! (is-eq tx-sender (get-principal-mediator)) (err u1031)) ;; Check if tx-sender is Mediator
    (asserts! (is-state-buyer-ok-mediator) (err u1032)) ;; check if state is ready for this
    (try! (fund-refund))
    (set-escrow-status state-mediator-says-bad)
    (ok (status-of-contract))
  ) ;; /begin
)


;; Mediator decided bad, so do refund.
;; Here's the deal:
;;  - Mediator gets paid commission, 10% of sell price. 5% each from buyer and seller.
;;  - Seller gets all his money back minus 5% (for mediator commission).
;;  - Buyer gets all his money back minus 5% (for mediator commission).
(define-private (fund-refund)
  (begin
    (try! (as-contract (stx-transfer? (+ (get-price) (get-mediator-commission)) tx-sender (get-principal-mediator))))  ;; send commission to mediator plus collateral
    (try! (as-contract (stx-transfer? (- (* (get-price) u2) (/ (get-mediator-commission) u2)) tx-sender (get-principal-buyer))))  ;; send collateral back to buyer minus half of mediator commission
    (try! (as-contract (stx-transfer? u10 tx-sender (get-principal-seller))))  ;; send collateral back to seller minus half of mediator commission
    (ok u0)
  )
)

(define-private (get-mediator-commission)
  (/ (get-price) u10)
)

;; Mediator decided good, so disburse funds appropriately.
(define-private (fund-disburse)
  (begin
    (try! (as-contract (stx-transfer? (+ (get-price) (get-mediator-commission)) tx-sender (get-principal-mediator))))  ;; send commission to mediator plus collateral
    (try! (as-contract (stx-transfer? (- (get-price) (/ (get-mediator-commission) u2)) tx-sender (get-principal-buyer))))  ;; send collateral back to buyer minus half of mediator commission, and minus the item price
    (try! (as-contract (stx-transfer? (- (* (get-price) u2) (/ (get-mediator-commission) u2)) tx-sender (get-principal-seller))))  ;; send collateral funds plus price to seller, minus half of mediator commission
    (ok u0)
  )
)
