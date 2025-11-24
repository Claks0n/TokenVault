;; TokenVault: Secure Token Deposit and Withdrawal Management System
;; Version: 1.0.0

(define-constant ERR-UNAUTHORIZED (err u1))
(define-constant ERR-VAULT-NOT-FOUND (err u2))
(define-constant ERR-INSUFFICIENT-BALANCE (err u3))
(define-constant ERR-INVALID-AMOUNT (err u4))
(define-constant ERR-INVALID-CURRENCY-TYPE (err u5))
(define-constant ERR-INVALID-WALLET-ADDRESS (err u6))
(define-constant ERR-TRANSACTION-FAILED (err u7))
(define-constant ERR-INVALID-MEMO (err u8))

(define-constant MIN-DEPOSIT-AMOUNT u100)

(define-data-var next-vault-id uint u1)

(define-map vault-accounts
    uint
    {
        owner: principal,
        wallet-label: (string-utf8 50),
        transaction-memo: (string-utf8 200),
        currency-type: (string-utf8 15),
        security-level: (string-utf8 10),
        account-status: (string-utf8 15),
        token-balance: uint
    }
)

(define-private (validate-currency-type (currency-type (string-utf8 15)))
    (or 
        (is-eq currency-type u"STX")
        (is-eq currency-type u"USDA")
        (is-eq currency-type u"ALEX")
        (is-eq currency-type u"DIKO")
        (is-eq currency-type u"XUSD")
        (is-eq currency-type u"ARKADIKO")
    )
)

(define-private (validate-security-level (security-level (string-utf8 10)))
    (or 
        (is-eq security-level u"Standard")
        (is-eq security-level u"Enhanced")
        (is-eq security-level u"Premium")
        (is-eq security-level u"Institutional")
        (is-eq security-level u"VIP")
    )
)

(define-private (validate-text-input (text (string-utf8 200)) (min-length uint) (max-length uint))
    (let 
        (
            (text-length (len text))
        )
        (and 
            (>= text-length min-length)
            (<= text-length max-length)
        )
    )
)

(define-public (deposit-tokens 
    (wallet-label (string-utf8 50))
    (transaction-memo (string-utf8 200))
    (currency-type (string-utf8 15))
    (security-level (string-utf8 10))
    (token-balance uint)
)
    (let
        (
            (vault-id (var-get next-vault-id))
        )
        (asserts! (validate-text-input wallet-label u3 u50) ERR-INVALID-WALLET-ADDRESS)
        (asserts! (validate-text-input transaction-memo u10 u200) ERR-INVALID-MEMO)
        (asserts! (>= token-balance MIN-DEPOSIT-AMOUNT) ERR-INVALID-AMOUNT)
        (asserts! (validate-currency-type currency-type) ERR-INVALID-CURRENCY-TYPE)
        (asserts! (validate-security-level security-level) ERR-TRANSACTION-FAILED)
        
        (map-set vault-accounts vault-id {
            owner: tx-sender,
            wallet-label: wallet-label,
            transaction-memo: transaction-memo,
            currency-type: currency-type,
            security-level: security-level,
            account-status: u"active",
            token-balance: token-balance
        })
        (var-set next-vault-id (+ vault-id u1))
        (ok vault-id)
    )
)

(define-public (withdraw-tokens (vault-id uint) (withdrawal-amount uint))
    (let
        (
            (vault (unwrap! (map-get? vault-accounts vault-id) ERR-VAULT-NOT-FOUND))
        )
        (asserts! (is-eq tx-sender (get owner vault)) ERR-UNAUTHORIZED)
        (asserts! (>= (get token-balance vault) withdrawal-amount) ERR-INSUFFICIENT-BALANCE)
        (asserts! (is-eq (get account-status vault) u"active") ERR-INVALID-AMOUNT)
        (ok (map-set vault-accounts vault-id (merge vault { token-balance: (- (get token-balance vault) withdrawal-amount) })))
    )
)

(define-read-only (get-vault-details (vault-id uint))
    (ok (map-get? vault-accounts vault-id))
)

(define-read-only (get-vault-owner (vault-id uint))
    (ok (get owner (unwrap! (map-get? vault-accounts vault-id) ERR-VAULT-NOT-FOUND)))
)