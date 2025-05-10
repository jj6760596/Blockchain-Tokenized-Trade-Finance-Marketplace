;; Exporter Verification Contract
;; This contract validates legitimate sellers in the trade finance marketplace

(define-data-var admin principal tx-sender)

;; Map to store verified exporters
(define-map verified-exporters principal
  {
    company-name: (string-utf8 100),
    registration-number: (string-utf8 50),
    country: (string-utf8 50),
    verification-date: uint,
    status: bool
  }
)

;; Public function to verify an exporter
(define-public (verify-exporter (exporter principal) (company-name (string-utf8 100)) (registration-number (string-utf8 50)) (country (string-utf8 50)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1)) ;; Only admin can verify
    (map-set verified-exporters exporter {
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
(define-public (revoke-exporter (exporter principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1)) ;; Only admin can revoke
    (asserts! (is-some (map-get? verified-exporters exporter)) (err u2)) ;; Exporter must exist
    (map-delete verified-exporters exporter)
    (ok true)
  )
)

;; Read-only function to check if an exporter is verified
(define-read-only (is-verified-exporter (exporter principal))
  (match (map-get? verified-exporters exporter)
    exporter-data (ok (get status exporter-data))
    (ok false)
  )
)

;; Read-only function to get exporter details
(define-read-only (get-exporter-details (exporter principal))
  (map-get? verified-exporters exporter)
)

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1)) ;; Only current admin can transfer
    (var-set admin new-admin)
    (ok true)
  )
)
