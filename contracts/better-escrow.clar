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
(define-constant better-escrow (as-contract "ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5")) ;; Clarinet

;; error constants
(define-constant ERR_STX_TRANSFER u0)

;; data maps and vars
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

;; Seller creates a bill.
;; Possibly then sends the bill to buyer via email.
;; Technically, seller creates an instance of smart
;; contract and sends STX to the contract at the same time.
;; How does try! work again?
(define-public (create-bill)
  (begin
    ;; check first the status of escrow contract
    ;; (asserts! (is-eq (var-get state-seller) u0) (err "omg"))
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
    ) ;; /asserts!
    (var-set state-seller u1)
    (ok "nice")
  ) ;; /begin
)

;; Buyer accepts terms of the bill, no sending funds yet.
(define-public (accept-bill)
  (begin
    ;; check first the status of escrow contract
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
    (var-set state-buyer u1)
    (ok "nice")
  ) ;; /begin
)

(define-public (create-bill-x (total-price uint))
  (begin
    (try! (stx-transfer? total-price tx-sender (as-contract contract-caller)))
    (ok true)
  )
)


;; https://discord.com/channels/621759717756370964/872124843225653278/894763920252870707
;; https://discord.com/channels/621759717756370964/831629305573408828/851534492980346911 