;; Importer Verification Contract
;; This contract validates legitimate buyers in the trade finance marketplace

(define-data-var admin principal tx-sender)

;; Map to store verified importers
(define-map verified-importers principal
  {
    company-name: (string-utf8 100),
    registration-number: (string-utf8 50),
    country: (string-utf8 50),
    verification-date: uint,
    status: bool
  }
)

;; Public function to verify an importer
(define-public (verify-importer (importer principal) (company-name (string-utf8 100)) (registration-number (string-utf8 50)) (country (string-utf8 50)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1)) ;; Only admin can verify
    (map-set verified-importers importer {
      company-name: company-name,
      registration-number: registration-number,
      country: country,
      verification-date: block-height,
      status: true
    })
    (ok true)
  )
)

;; Public function to revoke verification
(define-public (revoke-importer (importer principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1)) ;; Only admin can revoke
    (asserts! (is-some (map-get? verified-importers importer)) (err u2)) ;; Importer must exist
    (map-delete verified-importers importer)
    (ok true)
  )
)

;; Read-only function to check if an importer is verified
(define-read-only (is-verified-importer (importer principal))
  (match (map-get? verified-importers importer)
    importer-data (ok (get status importer-data))
    (ok false)
  )
)

;; Read-only function to get importer details
(define-read-only (get-importer-details (importer principal))
  (map-get? verified-importers importer)
)

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1)) ;; Only current admin can transfer
    (var-set admin new-admin)
    (ok true)
  )
)
