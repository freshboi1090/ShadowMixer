;; Privacy-Focused STX Transaction Mixer (Simplified)

;; Fixed deposit amount (e.g., 1 STX = 1_000_000 microSTX)
(define-constant DEPOSIT_AMOUNT u1000000)

;; Owner (contract deployer)
(define-data-var owner principal tx-sender)

;; Mapping: commitment hash (as buffer) -> withdrawn? (bool)
(define-map commitments
  { commitment: (buff 32) } ;; 32-byte hash commitment
  { withdrawn: bool }
)

;; Total STX pooled (microSTX)
(define-data-var pool-balance uint u0)

;; Errors
(define-constant ERR_ALREADY_WITHDRAWN (err u100))
(define-constant ERR_INVALID_COMMITMENT (err u101))
(define-constant ERR_INSUFFICIENT_FUNDS (err u102))
(define-constant ERR_DEPOSIT_AMOUNT_MISMATCH (err u103))
(define-constant ERR_NOT_OWNER (err u104))

;; Private: check owner
(define-private (is-owner (caller principal))
  (is-eq caller (var-get owner))
)

;; Deposit function
(define-public (deposit (commitment (buff 32)))
  (begin
    ;; Check commitment not used
    (asserts! (is-none (map-get? commitments { commitment: commitment })) ERR_INVALID_COMMITMENT)
    ;; Register commitment as not withdrawn
    (map-set commitments { commitment: commitment } { withdrawn: false })
    ;; Increase pool balance
    (var-set pool-balance (+ (var-get pool-balance) DEPOSIT_AMOUNT))
    (ok true)
  )
)

;; Withdraw function
(define-public (withdraw (secret (buff 32)))
  (let
    (
      ;; Compute commitment hash from secret
      (commitment (sha256 secret))
      (commitment-data (map-get? commitments { commitment: commitment }))
      (pool (var-get pool-balance))
    )
    (begin
      ;; Check commitment exists
      (asserts! (is-some commitment-data) ERR_INVALID_COMMITMENT)
      (let ((withdrawn (get withdrawn (unwrap-panic commitment-data))))
        ;; Ensure not withdrawn yet
        (asserts! (not withdrawn) ERR_ALREADY_WITHDRAWN)
        ;; Ensure contract has enough funds
        (asserts! (>= pool DEPOSIT_AMOUNT) ERR_INSUFFICIENT_FUNDS)
        ;; Mark commitment as withdrawn
        (map-set commitments { commitment: commitment } { withdrawn: true })
        ;; Decrease pool balance
        (var-set pool-balance (- pool DEPOSIT_AMOUNT))
        ;; Transfer STX to caller
        (try! (stx-transfer? DEPOSIT_AMOUNT (as-contract tx-sender) tx-sender))
        (ok true)
      )
    )
  )
)

;; View total pool balance
(define-read-only (get-pool-balance)
  (ok (var-get pool-balance))
)

;; View if a commitment is withdrawn
(define-read-only (is-withdrawn (commitment (buff 32)))
  (default-to false (get withdrawn (map-get? commitments { commitment: commitment })))
)

;; Change owner
(define-public (set-owner (new-owner principal))
  (begin
    (asserts! (is-owner tx-sender) ERR_NOT_OWNER)
    (var-set owner new-owner)
    (ok true)
  )
)

;; Initial owner set
(begin
  (var-set owner tx-sender)
)
