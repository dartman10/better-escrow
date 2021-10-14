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
;;(define-constant dartman (as-contract "ST13PBS66J69XNSKNCXJBG821QKRS42NFMJXPEJ7F")) ;; Testnet
(define-constant dartman (as-contract "ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5")) ;; Clarinet
;; error constants
(define-constant ERR_STX_TRANSFER u0)
;; data maps and vars
;;(define-data-var seller (principal-of? public-key))
(define-data-var price uint u0)
(define-data-var buyer-funds uint u0)

;; private functions
;; 

;; public functions

;; echo function - to check if contract is reachable
(define-read-only (echo (shoutOut (string-ascii 100)))
   (ok shoutOut)
 )

;; To verify Better Escrow is indeed the contract owner of this instance of smart contract.
(define-read-only (get-contract-owner)
  (ok dartman)
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

;; Buyer accepts the bill, by sending funds to escrow. (Technically, sends STX to smart contract and locked)
(define-public (accept-bill (funding uint))
  (begin
    (var-set buyer-funds funding)
    (ok true)
  )
)

;; Return status of contract
;; Question - how do I return all the variables? map? tuple? print?
(define-public (status-of-contract)
  (begin
    (ok (var-get buyer-funds))
)
)
;; Seller creates a bill.
;; Possibly then sends the bill to buyer via email.
;; Technically, seller creates an instance of smart
;; contract and sends STX to the contract at the same time.
;; How does try! work again?
(define-public (create-bill (total-price uint))
(begin
(try! (stx-transfer? total-price tx-sender (as-contract contract-caller)))
(ok true)
)
)