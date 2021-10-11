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

;; Question again. Is NFT better for this escrow application?
;; Why do you ask?  Because I think it's good for tracking all live contracts.
;; I mean, how do I do it with no NFT?
;; Like all pending funds are in the same one contract?  Accumulated?
;; Doesn't that open up a potential crack for hacks?
;; So I'm thinking an NFT is created everytime a seller creates a bill.
;; -> Hmmm, how do I handle it then to make sure the seller has no unfair advantage over the buyer?
;; -> Then finally burn the NFT once transaction complete.
;; -> Will this NFT process be expensive and will not make sense?  I don't think so.  But we'll see.

;; The HOWs:
;;  1. Once a buyer principal is present, the NFT becomes a multisig contract.
;;  2. When adding an Arbiter principal, both the seller and buyer should accept and sign the contract.

;; constants

;; hardcoded Better Escrow as the contract owner for all instances of this smart contract
(define-constant contract-owner (as-contract "STNHKEPYEPJ8ET55ZZ0M5A34J0R3N5FM2CMMMAZ6"))
;; error consts
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
  (ok contract-owner)
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