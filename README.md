# FinanceClub-Ledger

Finance Club: Verifiable Club Ledger

A public ledger for a student club's money, built on Base Sepolia.
Anyone can see every entry without a wallet. Only approved treasurers can
record entries, and mistakes are fixed with correction entries. Nothing is
edited or deleted.

**Track 4: Financial Transparency** | Fake data and test funds only

## Roles
- **Admin** (deployer wallet): approves and removes treasurers
- **Treasurer**: records income, expenses and corrections
- **Public reader**: views the ledger, no wallet needed

## How to run
1. Install MetaMask and add Base Sepolia (it adds itself when you click Connect).
2. Download this repo and open the folder in VS Code.
3. Install the Live Server extension, right-click `index.html`, and choose
   "Open with Live Server".
4. The ledger loads without a wallet. Click "Connect wallet" to record entries.

## What the contract refuses
- Anyone but the admin changing the treasurer list
- Any non-treasurer wallet recording an entry
- A zero amount
- A correction for an entry that doesn't exist
- An expense larger than the current balance


