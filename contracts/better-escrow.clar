;; better-escrow
;; The better escrow service.
;; Actors : seller, buyer, mediator.
;;   1. Seller - creates a bill to be sent to buyer (creates an instance of escrow smart contract)
;;   2. Buyer - accepts the bill charges (in the smart contract)  and sends funds to escrow (into the same smart contract)
;;   3. Mediator - needed in case of dispute. Not sure yet how to implement this.

;; Is the contract deployer the contract owner?
;; Always set owner of smart contract instance to the transaction sender?

;; Hmmm, just realized that it will not be fair to buyer if the seller is the
;; contract owner, because the seller has the power over the transaction.
;; Therefore, 'Better Escrow' should be the owner.  This means the contract
;; owner is constant for all instances of this smart contract.  Later on, this
;; could be delegated to an Arbiter (which is needed in case of )  For now,
;; the Better Escrow is the Arbiter.  So yeah, its fully decentralized when there is
;; no dispute.  But switches to centralized in case of dispute. 

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

;; Seller creates a bill.
;; Possibly then sends the bill to buyer via email.
;; Technically, seller creates an instance of smart
;; contract and sends STX to the contract at the same time.
;; How does try! work again?
(define-public (create-bill (total-price uint))
  (begin
    (var-set price total-price)
    (try! (stx-transfer? total-price tx-sender (as-contract tx-sender)))
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