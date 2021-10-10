
;; better-escrow
;; The better escrow service.
;; Actors : seller, buyer, mediator.
;;   1. Seller - creates a bill to be sent to buyer (creates an instance of escrow smart contract)
;;   2. Buyer - accepts the bill charges (in the smart contract)  and sends funds to escrow (into the same smart contract)
;;   3. Mediator - needed in case of dispute. Not sure yet how to implement this.

;; constants
(define-constant contract-owner tx-sender)

;; data maps and vars
;;

;; private functions
;; 

;; public functions

;; echo function - to check if contract is reachable
(define-read-only (echo (shoutOut (string-ascii 100)))
   (ok shoutOut)
 )

(define-read-only (get-contract-owner)
  (ok contract-owner)
)





;;ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.better-escrow