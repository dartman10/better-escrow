;; better-escrow
;; The better escrow service.
;; Actors : seller, buyer, mediator.
;;   1. Seller - creates a bill to be sent to buyer (creates an instance of escrow smart contract)
;;   2. Buyer - accepts the bill charges (in the smart contract)  and sends funds to escrow (into the same smart contract)
;;   3. Mediator - needed in case of dispute. Not sure yet how to implement this.

;; constants
(define-constant contract-owner tx-sender)

;; data maps and vars
(define-data-var price uint u0)
(define-data-var buyer-funds uint u0)

;; private functions
;; 

;; public functions

;; echo function - to check if contract is reachable
(define-read-only (echo (shoutOut (string-ascii 100)))
   (ok shoutOut)
 )

;; Perhaps needed by UI
(define-read-only (get-contract-owner)
  (ok contract-owner)
)

(define-read-only (get-price)
  (ok (var-get price))
)

;; Seller creates a bill.  (Possibly then sends the bill to buyer via email.)
(define-public (create-bill (total-price uint))
  (begin
    (var-set price total-price)
    (ok true)
  )
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



;;ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.better-escrow