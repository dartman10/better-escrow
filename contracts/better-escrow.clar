;; ------------------------------------------
;; better-escrow : The better escrow service.
;; ------------------------------------------
;;
;; Actors : seller, buyer, mediator.
;;   1. Seller - creates a bill to be sent to buyer (creates an instance of escrow smart contract)
;;   2. Buyer - accepts the bill charges (in the smart contract)  and sends funds to escrow (into the same smart contract)
;;   3. Mediator - needed in case of dispute. Not sure yet how to implement this.
;;
;; The HOWs:
;;  1. Once a buyer principal is present, the contract instance becomes a multisig contract.
;;  2. When adding a mediator principal, both the seller and buyer should accept and sign the contract.
;;
;; Short term tactical solution, due to 3-week hackathon limit:
;; - For now, use a map to keep track of active escrow contracts.
;; Will wait for Stacks team to focus on GAIA off-chain storage in 2021 Q4.
;; And because map is not iterable, limit one escrow per principal.
;;
;; ------------------------------------------
;; Enough talk.  Let's do this.
;; ------------------------------------------


;; --------------------
;;  Constants
;; --------------------
(define-constant ERR_STX_TRANSFER u0)

;; hardcoded Better Escrow as the contract owner for all instances of this smart contract
;;(define-constant better-escrow (as-contract "ST13PBS66J69XNSKNCXJBG821QKRS42NFMJXPEJ7F")) ;; Testnet
;;(define-constant better-escrow2 (as-contract "ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5")) ;; Clarinet
;;(define-data-var better-escrow1 principal 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5) ;; Clarinet
;;(define-data-var better-escrow (optional principal) none)
;;(define-constant better-escrow (as-contract 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)) ;; Clarinet

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
;; make this part of trait
(define-read-only (echo (shout-out (string-ascii 100)))
   (ok shout-out))

;; help function - return helpful tips and usage
;; make this part of trait
(define-read-only (help)
   (ok "help is on the way"))

;; about function - desribe this contract
;; make this part of trait
(define-read-only (about)
   (ok "better escrow is the escrow.com killer"))

(define-read-only (get-tx-sender)
  (ok tx-sender))

(define-read-only (get-contract-caller)
  (ok contract-caller))

(define-read-only (get-principal-seller)
  (var-get principal-seller))

(define-private (set-principal-seller (principal-value (optional principal)))
  (var-set principal-seller principal-value))

(define-read-only (get-principal-buyer)
  (var-get principal-buyer))

(define-private (set-principal-buyer (principal-value (optional principal)))
  (var-set principal-buyer principal-value))

(define-read-only (get-principal-mediator)
  (var-get principal-mediator))

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

;; Return status of contract
;; Question - how do I return all the variables? map? tuple? print?
(define-public (status-of-contract)
  (begin
    (ok (list (get-state-seller) 
              (get-state-buyer) 
              (get-state-mediator)
        )
    )
  )
)

;; Seller sends a bill.
;; Before state : [0][0][0]
;; After  state : [1][0][0]
(define-public (bill-create)
  (begin
    (asserts! (and 
                  (
                    and 
                    (is-eq (get-state-seller)  u0) 
                    (is-eq (get-state-buyer)   u0)
                  ) 
                  (
                    is-eq (get-state-mediator) u0
                  )
              )              
              (err "lol")
    ) ;; <asserts! end>

    ;;(var-set better-escrow (as-contract "ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5"))
    (set-principal-seller (some tx-sender))
    (set-state-seller u1)
    (ok (status-of-contract))
  ) ;; <begin end>
)

;; Buyer accepts terms of the bill, no sending of funds yet.
;; Before state : [1][0][0]
;; After  state : [1][1][0]
(define-public (bill-accept)
  (begin
    (asserts! (and    
                  (
                    and 
                    (is-eq (get-state-seller)  u1) 
                    (is-eq (get-state-buyer)   u0)
                  ) 
                  (
                    is-eq (get-state-mediator) u0
                  )
              )              
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
    (asserts! (and 
                  (
                    and 
                    (is-eq (get-state-seller)  u1) 
                    (is-eq (get-state-buyer)   u1)
                  ) 
                  (
                    is-eq (get-state-mediator) u0
                  )
              )              
              (err u2)
    ) ;; /asserts!
    ;;(asserts! (is-eq (some tx-sender) (var-get principal-seller)) (err u1))
    (asserts! (is-eq (some tx-sender) (get-principal-seller)) (err u1))    
    (try! (transfer-me))  ;; too many try!s
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
    (asserts! (and 
                  (
                    and 
                    (is-eq (get-state-seller)  u2) 
                    (is-eq (get-state-buyer)   u1)
                  ) 
                  (
                    is-eq (get-state-mediator) u0
                  )
              )              
              (err u777)
    ) ;; /asserts!
    (asserts! (is-eq (some tx-sender) (get-principal-buyer)) (err u666)) 
    (try! (transfer-me))  ;; how can i lessen the try!?
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
    (asserts! (and 
                  (
                    and 
                    (is-eq (get-state-seller)  u2) 
                    (is-eq (get-state-buyer)   u2)
                  ) 
                  (
                    is-eq (get-state-mediator) u0
                  )
              )              
              (err u111)
    ) ;; /asserts!

    ;; Only the buyer can release the funds.
    (asserts! (is-eq tx-sender 
                     (unwrap! (get-principal-buyer)
                              (err u113)
                     )
              ) ;; unwrap is required for optional principal --> Analysis error: expecting expression of type '(optional principal)', found 'principal'
              (err u112)
    )

    ;; hmmm, try! returns a uint. what's the value then?
    ;; as-contract replaces tx-sender inside the closure. get it? lol. easy-peasy.

    ;; This one works because DURING stx-transfer execution, it replaces tx-sender to contract principal.
    (try! (as-contract (stx-transfer? u10 tx-sender (unwrap! (get-principal-buyer) (err u727)))))  ;; send funds to buyer
    (try! (as-contract (stx-transfer? u10 tx-sender (unwrap! (get-principal-seller) (err u728)))))  ;; send funds to seller

    ;; This returns an err u4 because as-contract converts tx-sender to contract principal prior to executing stx-transfer, so stx-transfer naturally fails
    ;;(try! (stx-transfer? u10 (as-contract tx-sender) (unwrap! (var-get principal-buyer) (err u727)))) ;; 
 
    (set-state-buyer u3)
    (ok (status-of-contract))

  ) ;; /begin
)

(define-private (transfer-me)
  (begin
    ;;(try! (stx-transfer? u10 tx-sender better-escrow))  ;; hmmm, try! returns a uint. what's the value then?
    (try! (stx-transfer? u10 tx-sender (as-contract tx-sender)))  ;; hmmm, try! returns a uint. what's the value then?

    (ok u0)
  )
)

(define-private (transfer-you)
  (begin
  ;;(as-contract (unwrap-panic (stx-transfer? u100 tx-sender tx-sender)))
  ;;(unwrap-panic (stx-transfer? u100 tx-sender better-escrow))
  ;;  (unwrap-panic (stx-transfer? u10 better-escrow (var-get principal-buyer)))
  ;;(unwrap-panic (stx-transfer? u10 (some better-escrow) (unwap-panic (var-get principal-seller))))
  (ok "po")
  )
)
