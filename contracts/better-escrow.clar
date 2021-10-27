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

;; --------------------
;;  Variables
;; --------------------
(define-data-var principal-seller   (optional principal) none)  ;; why do I need "optional" here? so i can set to "none"?
(define-data-var principal-buyer    (optional principal) none)
(define-data-var principal-mediator (optional principal) none)

(define-data-var state-seller   uint u0)  ;; seller status - 0, 1, 2, 3, 4
(define-data-var state-buyer    uint u0)
(define-data-var state-mediator uint u0)

(define-data-var price uint u0)
(define-data-var buyer-funds uint u0)

;; private functions
;; 

;; public functions

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
  ;;(ok (stx-get-balance (unwrap! (get-principal-contract) (err u73215))))
  (ok (stx-get-balance (get-principal-contract)))
)

(define-read-only (get-principal-seller)
  (var-get principal-seller))

(define-read-only (get-balance-seller)  ;; for Clarinet testing only
  (ok (stx-get-balance (unwrap! (get-principal-seller) (err u73211))))
)

(define-private (set-principal-seller (principal-value (optional principal)))
  (var-set principal-seller principal-value))

(define-read-only (get-principal-buyer)
  (var-get principal-buyer))

(define-read-only (get-balance-buyer)  ;; for Clarinet testing only
  (ok (stx-get-balance (unwrap! (get-principal-buyer) (err u73212)))))

(define-private (set-principal-buyer (principal-value (optional principal)))
  (var-set principal-buyer principal-value))

(define-read-only (get-principal-mediator)
  (var-get principal-mediator))

(define-private (set-principal-mediator (principal-value (optional principal)))
  (begin
    (var-set principal-mediator principal-value)
  )
)

(define-read-only (get-balance-mediator)  ;; for Clarinet testing only
  (ok (stx-get-balance (unwrap! (get-principal-mediator) (err u73219)))))

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
  (begin
    (ok (list (get-state-seller) 
              (get-state-buyer) 
              (get-state-mediator)
        )
    )
  )
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
    ;; check if contract status is eligible for the next round
    (asserts! (or (and (is-eq (get-state-seller)   u0) 
                       (is-eq (get-state-buyer)    u0)
                       (is-eq (get-state-mediator) u0))
                  (and (is-eq (get-state-seller)   u2) 
                       (is-eq (get-state-buyer)    u3)
                       (is-eq (get-state-mediator) u0)))         
              (err "lol")
    ) ;; <asserts! end>

    (set-principal-seller (some tx-sender))
    (set-state-seller   u1)
    (set-state-buyer    u0)
    (set-state-mediator u0)
    (set-price price-request)
    (ok (status-of-contract))
  ) ;; <begin end>
)

;; Buyer accepts terms of the bill, no sending of funds yet.
;; Before state : [1][0][0]
;; After  state : [1][1][0]
(define-public (bill-accept)
  (begin
    (asserts! (and (is-eq (get-state-seller)   u1) 
                   (is-eq (get-state-buyer)    u0)
                   (is-eq (get-state-mediator) u0))              
              (err "lol")
    ) ;; /asserts!
    (set-principal-buyer (some tx-sender))
    (set-state-buyer u1)
    (ok (status-of-contract))
  ) ;; /begin
)

;; Seller accepts Buyer and confirm.  Sends fund and locked.
;; Before state : [1][1][0]
;; After  state : [2][1][0]
(define-public (fund-seller)
  (begin
    ;; check first the status of escrow contract
    (asserts! (and (is-eq (get-state-seller)   u1) 
                   (is-eq (get-state-buyer)    u1) 
                   (is-eq (get-state-mediator) u0))              
              (err u2)
    ) ;; /asserts!
    (asserts! (is-eq (some tx-sender) (get-principal-seller)) (err u1))    
    (try! (transfer-to-contract (get-price)))  ;; too many try!s
    (set-state-seller u2)
    (ok (status-of-contract))
  ) ;; /begin
)

;; Buyer reviews seller fund and send own fund. Contract now locked and loaded.
;; Before state : [2][1][0]
;; After  state : [2][2][0]
(define-public (fund-buyer)
  (begin
    ;; check first the status of escrow contract
    (asserts! (and (is-eq (get-state-seller)   u2) 
                   (is-eq (get-state-buyer)    u1)
                   (is-eq (get-state-mediator) u0))
              (err u777)
    ) ;; /asserts!
    (asserts! (is-eq (some tx-sender) (get-principal-buyer)) (err u666)) 
    (try! (transfer-to-contract (* (get-price) u2)))   ;; Buyer puts in funds twice as much as the seller's funds. Half for collateral, half for price of goods.
    (set-state-buyer u2)
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
    ;; check first the status of escrow contract
    (asserts! (and (is-eq (get-state-seller)   u2) 
                   (is-eq (get-state-buyer)    u2)
                   (is-eq (get-state-mediator) u0))              
              (err u111)
    ) ;; /asserts!

    ;; Only the buyer can release the funds.
    ;; unwrap is required for optional principal --> Analysis error: expecting expression of type '(optional principal)', found 'principal'
    (asserts! (is-eq tx-sender (unwrap! (get-principal-buyer) (err u113))) (err u112))
    (try! (transfer-from-contract))     ;; try! returns a uint. try! is needed for intermediate blah blah
    (set-state-buyer u3)
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
    (try! (as-contract (stx-transfer? (get-price) tx-sender (unwrap! (get-principal-buyer) (err u727)))))  ;; send funds to buyer
    (try! (as-contract (stx-transfer? (* (get-price) u2) tx-sender (unwrap! (get-principal-seller) (err u728)))))  ;; send funds to seller
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
    (asserts! (and (>=    (get-state-seller)   u1) 
                   (>=    (get-state-buyer)    u1)
                   (is-eq (get-state-mediator) u0))              
              (err u121)
    ) ;; /asserts!

    (asserts! (or (is-eq tx-sender (unwrap! (get-principal-buyer)  (err u118)))
                  (is-eq tx-sender (unwrap! (get-principal-seller) (err u119))))
              (err u121)
    ) ;; /asserts!

    (set-state-mediator u1)
    (ok (status-of-contract))
  ) ;; /begin
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

    (asserts! (not  (or (is-eq tx-sender (unwrap! (get-principal-buyer)  (err u128)))
                        (is-eq tx-sender (unwrap! (get-principal-seller) (err u129)))))
              (err u131)
    ) ;; /asserts!

    (set-principal-mediator (some tx-sender))
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
    (asserts! (is-eq tx-sender (unwrap! (get-principal-seller)  (err u1000)))
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
    (asserts! (is-eq tx-sender (unwrap! (get-principal-buyer)  (err u1010)))
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
    (asserts! (is-eq tx-sender (unwrap! (get-principal-mediator)  (err u1020)))
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
    (asserts! (is-eq tx-sender (unwrap! (get-principal-mediator)  (err u1030)))
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
                (is-eq tx-sender (unwrap! (get-principal-buyer)  (err u2118)))
                (is-eq tx-sender (unwrap! (get-principal-seller) (err u2119)))
              )
              (err u2121)
    ) ;; /asserts!
    ;; check first the status of escrow contract
    (asserts! (and  (is-eq (get-state-seller)   u5) 
                    (is-eq (get-state-buyer)    u5)
                    (is-eq (get-state-mediator) u4))
              (err u2111)
    ) ;; /asserts!

    (try! (as-contract (stx-transfer? u10 tx-sender (unwrap! (get-principal-buyer) (err u2727)))))  ;; send funds to buyer
    (try! (as-contract (stx-transfer? u10 tx-sender (unwrap! (get-principal-seller) (err u2728)))))  ;; send funds to seller
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
                (is-eq tx-sender (unwrap! (get-principal-buyer)  (err u3118)))
                (is-eq tx-sender (unwrap! (get-principal-seller) (err u3119)))
              )
              (err u3121)
    ) ;; /asserts!
    ;; check first the status of escrow contract
    (asserts! (and  (is-eq (get-state-seller)   u5) 
                    (is-eq (get-state-buyer)    u5)
                    (is-eq (get-state-mediator) u3))
              (err u3111)
    ) ;; /asserts!

    (try! (as-contract (stx-transfer? (get-price) tx-sender (unwrap! (get-principal-buyer) (err u3727)))))  ;; send collateral funds to buyer
    (try! (as-contract (stx-transfer? (* (get-price) u2) tx-sender (unwrap! (get-principal-seller) (err u3728)))))  ;; send collateral funds plus price to seller
    (set-state-seller u7)
    (set-state-buyer  u7)
    (ok (status-of-contract))
  )
)
