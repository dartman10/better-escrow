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

(define-read-only (is-state-buyer-buys-in )
  (is-eq (var-get state-of-escrow) state-buyer-buys-in))

(define-read-only (is-state-mediator-requested )
  (is-eq (var-get state-of-escrow) state-mediator-requested))

(define-read-only (is-state-mediator-accepted )
  (is-eq (var-get state-of-escrow) state-mediator-accepted))

(define-read-only (is-state-seller-ok-mediator )
  (is-eq (var-get state-of-escrow) state-seller-ok-mediator))

(define-read-only (is-state-buyer-ok-mediator )
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

;; refactor. do this later.
;;(define-private (is-state-ready)
;;(begin
;;  ;; check if contract status is eligible for the next round
;;  (asserts! (or (and (is-eq (get-state-seller)   u0) 
;;                     (is-eq (get-state-buyer)    u0)
;;                     (is-eq (get-state-mediator) u0))
;;                (and (is-eq (get-state-seller)   u2) 
;;                     (is-eq (get-state-buyer)    u3)
;;                     (is-eq (get-state-mediator) u0)))         
;;            (err "lol")
;;  ) ;; <asserts! end>
;;)


;; Seller sends a bill.
;; Before state : [0][0][0] or [u2, u3, u0] DO THIS!!!
;; After  state : [1][0][0]
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
;; Before state : [1][0][0]
;; After  state : [1][1][0]
(define-public (bill-accept)
  (begin
    (asserts! (is-state-seller-initiated) (err "no way"))
    (set-principal-buyer tx-sender)
    (set-escrow-status state-buyer-accepted)
    (ok (status-of-contract))
  )
)

;; Seller accepts Buyer and confirm.  Sends fund and locked.
;; Before state : [1][1][0]
;; After  state : [2][1][0]
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
;; Before state : [2][1][0]
;; After  state : [2][2][0]
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
;; Before state : [2][2][0]
;; After  state : [2][3][0]
(define-public (fund-release)
  (begin
    (asserts! (is-state-buyer-buys-in) (err u111)) ;; check first 
    (asserts! (is-eq tx-sender (get-principal-buyer)) (err u112)) ;; Only the buyer can release the funds.
    (try! (transfer-from-contract))     ;; try! returns a uint. try! is needed for intermediate blah blah
    (set-escrow-status state-buyer-is-happy)
    (ok (status-of-contract))
  ) ;; /begin
)

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
;; Before state : [>=1][>=1][0] or [>=1][>=1][0] 
;; After  state : [>=1][>=1][1] or [>=1][>=1][1]
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
;; Before state : [>=1][>=1][1]
;; After  state : [>=1][>=1][2]
(define-public (mediate-accept)
  (begin
    (asserts! (and (>=    (get-state-seller)   u1)
                   (>=    (get-state-buyer)    u1)
                   (is-eq (get-state-mediator) u1))
              (err u141)
    ) ;; /asserts!

    (asserts! (not  (or (is-eq tx-sender (get-principal-buyer))
                        (is-eq tx-sender (get-principal-seller))))
              (err u131)
    ) ;; /asserts!

    (set-principal-mediator tx-sender)
    (try! (transfer-to-contract (get-price)))  ;; mediator buys in
    (set-state-mediator u2)
    (ok (status-of-contract))
  ) ;; /begin
)

;; Now that a Mediator accepted, both Seller and Buyer needs to signoff on acceptance
;; Before state : [>=1 and <5][>=1][2]
;; After  state : [5][>=1][2]
(define-public (mediator-confirmation-seller)
  (begin

    ;; Check if tx-sender is Seller
    (asserts! (is-eq tx-sender (get-principal-seller))
              (err u1001)
    ) ;; /asserts!

    ;; Check contract state
    (asserts! (and (>=    (get-state-seller)   u1)
                   (<     (get-state-seller)   u5)
                   (>=    (get-state-buyer)    u1)
                   (is-eq (get-state-mediator) u2))
              (err u142)
    ) ;; /asserts!

    (set-state-seller u5)
    (ok (status-of-contract))
  ) ;; /begin
)

;; Now that a Mediator accepted, both Seller and Buyer needs to signoff on acceptance
;; Before state : [>=1][>=1 and <5][2]
;; After  state : [>=][5][2]
(define-public (mediator-confirmation-buyer)
  (begin
    ;; Check if tx-sender is Buyer
    (asserts! (is-eq tx-sender (get-principal-buyer))
              (err u1011)
    ) ;; /asserts!

    ;; Check contract state
    (asserts! (and (>=    (get-state-seller)   u1)
                   (>=    (get-state-buyer)    u1)
                   (<     (get-state-buyer)    u5)
                   (is-eq (get-state-mediator) u2))
              (err u1012)
    ) ;; /asserts!

    (set-state-buyer u5)
    (ok (status-of-contract))
  ) ;; /begin
)

;; Mediator decides. Two possible outcomes (for now):
;;  1. Mediator agrees with Seller, so contract will be exercised as agreed originally.
;;  2. Mediator agrees with Buyer, so contract will be nullified and give all money back.
;; Question is, who will sign?
;; Before state : [5][5][2]
;; After  state : [>=][5][3]
(define-public (mediator-decides-good)
  (begin
    ;; Check if tx-sender is Mediator
    (asserts! (is-eq tx-sender (get-principal-mediator))
              (err u1021)
    ) ;; /asserts!

    ;; Check contract state
    (asserts! (and (is-eq (get-state-seller)   u5)
                   (is-eq (get-state-buyer)    u5)
                   (is-eq (get-state-mediator) u2))
              (err u1022)
    ) ;; /asserts!

    (set-state-mediator u3)
    (ok (status-of-contract))
  ) ;; /begin
)

;; Mediator decides. Two possible outcomes (for now):
;;  1. Mediator agrees with Seller, so contract will be exercised as agreed originally.
;;  2. Mediator agrees with Buyer, so contract will be nullified and give all money back.
;; Question is, who will sign? I think either for now is okay.
;; Before state : [5][5][2]
;; After  state : [5][5][4]
(define-public (mediator-decides-bad)
  (begin
    ;; Check if tx-sender is Mediator
    (asserts! (is-eq tx-sender (get-principal-mediator))
              (err u1031)
    ) ;; /asserts!

    ;; Check contract state
    (asserts! (and (is-eq (get-state-seller)   u5)
                   (is-eq (get-state-buyer)    u5)
                   (is-eq (get-state-mediator) u2))
              (err u1032)
    ) ;; /asserts!

    (set-state-mediator u4)
    (ok (status-of-contract))
  ) ;; /begin
)

;; Mediator decided bad, so do refund.
;; Before state : [5][5][4]
;; After  state : [6][6][4]
(define-public (fund-refund)
  (begin
    ;; Buyer or Seller only
    (asserts! (or
                (is-eq tx-sender (get-principal-buyer))
                (is-eq tx-sender (get-principal-seller))
              )
              (err u2121)
    ) ;; /asserts!
    ;; check first the status of escrow contract
    (asserts! (and  (is-eq (get-state-seller)   u5) 
                    (is-eq (get-state-buyer)    u5)
                    (is-eq (get-state-mediator) u4))
              (err u2111)
    ) ;; /asserts!

    (try! (as-contract (stx-transfer? u10 tx-sender (get-principal-buyer))))  ;; send funds to buyer
    (try! (as-contract (stx-transfer? u10 tx-sender (get-principal-seller))))  ;; send funds to seller 
    (set-state-seller u6)
    (set-state-buyer  u6)
    (ok (status-of-contract))
  )
)

;; Mediator decided good, so disburse funds appropriately.
;; Before state : [5][5][3]
;; After  state : [7][7][3]
(define-public (fund-disburse)
  (begin
    ;; Buyer or Seller only
    (asserts! (or
                (is-eq tx-sender (get-principal-buyer))
                (is-eq tx-sender (get-principal-seller))
              )
              (err u3121)
    ) ;; /asserts!
    ;; check first the status of escrow contract
    (asserts! (and  (is-eq (get-state-seller)   u5) 
                    (is-eq (get-state-buyer)    u5)
                    (is-eq (get-state-mediator) u3))
              (err u3111)
    ) ;; /asserts!

    (try! (as-contract (stx-transfer? (get-price) tx-sender (get-principal-buyer))))  ;; send collateral funds to buyer
    (try! (as-contract (stx-transfer? (* (get-price) u2) tx-sender (get-principal-seller))))  ;; send collateral funds plus price to seller
    (set-state-seller u7)
    (set-state-buyer  u7)
    (ok (status-of-contract))
  )
)
