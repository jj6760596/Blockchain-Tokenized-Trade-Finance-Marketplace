;; Bank Verification Contract
;; This contract validates financial institutions in the trade finance marketplace

(define-data-var admin principal tx-sender)

;; Map to store verified banks
(define-map verified-banks principal
  {
    bank-name: (string-utf8 100),
    license-number: (string-utf8 50),
    country: (string-utf8 50),
    verification-date: uint,
    status: bool
  }
)

;; Public function to verify a bank
(define-public (verify-bank (bank principal) (bank-name (string-utf8 100)) (license-number (string-utf8 50)) (country (string-utf8 50)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1)) ;; Only admin can verify
    (map-set verified-banks bank {
      bank-name: bank-name,
      license-number: license-number,
      country: country,
      verification-date: block-height,
      status: true
    })
    (ok true)
  )
)

;; Public function to revoke verification
(define-public (revoke-bank (bank principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1)) ;; Only admin can revoke
    (asserts! (is-some (map-get? verified-banks bank)) (err u2)) ;; Bank must exist
    (map-delete verified-banks bank)
    (ok true)
  )
)

;; Read-only function to check if a bank is verified
(define-read-only (is-verified-bank (bank principal))
  (match (map-get? verified-banks bank)
    bank-data (ok (get status bank-data))
    (ok false)
  )
)

;; Read-only function to get bank details
(define-read-only (get-bank-details (bank principal))
  (map-get? verified-banks bank)
)

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1)) ;; Only current admin can transfer
    (var-set admin new-admin)
    (ok true)
  )
)
