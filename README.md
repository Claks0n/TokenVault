# TokenVault

A secure token deposit and withdrawal management system built on the Stacks blockchain.

## Features
- Multi-currency token support (STX, USDA, ALEX, DIKO, XUSD, ARKADIKO)
- Tiered security levels for different risk profiles
- Transaction history with memos
- Real-time balance tracking
- Owner-authorized withdrawals

## Usage
Deploy on Testnet and interact with the following functions:
- `deposit-tokens`: Create a new vault and deposit tokens
- `withdraw-tokens`: Withdraw tokens from an existing vault
- `get-vault-details`: Retrieve vault information
- `get-vault-owner`: Get vault owner details

## Security
All transactions are owner-authorized with comprehensive validation.