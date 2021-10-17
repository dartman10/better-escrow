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

;; constants

;; hardcoded Better Escrow as the contract owner for all instances of this smart contract
;;(define-constant better-escrow (as-contract "ST13PBS66J69XNSKNCXJBG821QKRS42NFMJXPEJ7F")) ;; Testnet
(define-constant better-escrow2 (as-contract "ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5")) ;; Clarinet
(define-data-var better-escrow1 principal 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5) ;; Clarinet
(define-constant better-escrow (as-contract 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)) ;; Clarinet


;; --------------------
;;  Constants
;; --------------------
(define-constant ERR_STX_TRANSFER u0)

;; --------------------
;;  Variables
;; --------------------
(define-data-var principal-seller   (optional principal) none)  ;; why do I need "optional" here?
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
   (ok shout-out)
 )

;; help function - return helpful tips and usage
;; make this part of trait
(define-read-only (help)
   (ok "help is on the way")
 )

;; about function - desribe this contract
;; make this part of trait
(define-read-only (about)
   (ok "better escrow is the escrow.com killer")
 )

;; To verify Better Escrow is indeed the contract owner of this instance of smart contract.
(define-read-only (get-contract-owner)
  (ok better-escrow)
)

(define-read-only (get-tx-sender)
  (ok tx-sender)
)

(define-read-only (get-contract-caller)
  (ok contract-caller)
)

(define-read-only (get-principal-seller)
  (ok (var-get principal-seller))
)

(define-read-only (get-principal-buyer)
  (ok (var-get principal-buyer))
)

(define-read-only (get-principal-mediator)
  (ok (var-get principal-mediator))
)

(define-read-only (get-price)
  (ok (var-get price))
)

;; Return status of contract
;; Question - how do I return all the variables? map? tuple? print?
(define-public (status-of-contract)
  (begin
    (ok (list (var-get state-seller) (var-get state-buyer) (var-get state-mediator) ))
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
                    (is-eq (var-get state-seller)  u0) 
                    (is-eq (var-get state-buyer)   u0)
                  ) 
                  (
                    is-eq (var-get state-mediator) u0
                  )
              )              
              (err "lol")
    ) ;; <asserts! end>
    (var-set principal-seller (some tx-sender))
    (var-set state-seller u1)
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
                    (is-eq (var-get state-seller)  u1) 
                    (is-eq (var-get state-buyer)   u0)
                  ) 
                  (
                    is-eq (var-get state-mediator) u0
                  )
              )              
              (err "lol")
    ) ;; /asserts!
    (var-set principal-buyer (some tx-sender))
    (var-set state-buyer u1)
    (ok "nice")
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
                    (is-eq (var-get state-seller)  u1) 
                    (is-eq (var-get state-buyer)   u1)
                  ) 
                  (
                    is-eq (var-get state-mediator) u0
                  )
              )              
              (err "lol")
    ) ;; /asserts!
    (asserts! (is-eq (some tx-sender) (var-get principal-seller)) (err "really?"))    
 ;;   (stx-transfer? u100 tx-sender (as-contract tx-sender))
    (transfer-me)
    (var-set state-seller u2)
    (ok "nice")
  ) ;; /begin
)

(define-private (transfer-me)
  ;;(as-contract (unwrap-panic (stx-transfer? u100 tx-sender tx-sender)))
  ;;(unwrap-panic (stx-transfer? u100 tx-sender better-escrow))
  (unwrap-panic (stx-transfer? u10 tx-sender better-escrow))
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
                    (is-eq (var-get state-seller)  u2) 
                    (is-eq (var-get state-buyer)   u1)
                  ) 
                  (
                    is-eq (var-get state-mediator) u0
                  )
              )              
              (err "lol")
    ) ;; /asserts!
    (var-set state-buyer u2)
    (ok "nice")
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
                    (is-eq (var-get state-seller)  u2) 
                    (is-eq (var-get state-buyer)   u2)
                  ) 
                  (
                    is-eq (var-get state-mediator) u0
                  )
              )              
              (err "lol")
    ) ;; /asserts!
    (var-set state-buyer u3)
    (ok "nice")
  ) ;; /begin
)

(define-public (create-bill-x (total-price uint))
  (begin
    (try! (stx-transfer? total-price tx-sender (as-contract contract-caller)))
    (ok true)
  )
)