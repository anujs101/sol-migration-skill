# Ethereum → Solana Migration Path

> Module 05 of the Solana Migration Assessment Skill.
> Load when the user mentions: Ethereum, EVM, Solidity, Hardhat, Foundry, Truffle, ERC-20, ERC-721, ERC-1155, OpenZeppelin, Metamask, Infura, Alchemy, or any EVM chain (Polygon, Arbitrum, Base, Optimism, Avalanche, BSC).
> Run alongside or after 02-suitability.md. This module supplements — does not replace — the standard 3-phase assessment.

---

## Purpose

Teams migrating from Ethereum carry specific mental models that cause bugs and architecture mistakes on Solana. This module:

1. Maps every major Ethereum concept to its Solana equivalent
2. Flags the mental model shifts that are non-obvious and dangerous
3. Provides a library migration table (SDK / tooling names have changed)
4. Gives an ETH-specific architecture delta overlay

---

## Context7 Integration

This module has **high** Context7 priority — second only to `04-decision-cards.md`.

Library names and SDK APIs are the fastest-changing content here.

```
IF context7 available:
  → fetch "@solana/kit" or "@solana/web3.js" docs before generating library recommendations
  → fetch "anchor-lang" docs to confirm current version and API surface
  → fetch "metaplex/core" docs if NFT migration is in scope
  → cite fetched version in the library table

IF context7 unavailable:
  → use Q2 2026 pinned knowledge
  → append to library table and all SDK recommendations:
    ⚠ Based on Q2 2026 docs — SDK names and APIs shift frequently. Verify before implementing.
```

---

## Concept Mapping: Ethereum → Solana

### Core Architecture

| Ethereum Concept | Solana Equivalent | Critical Difference |
|---|---|---|
| Smart Contract | Anchor Program | Programs are **stateless** — no storage inside the program. All state lives in separate accounts. |
| Contract storage (`mapping`, `uint256`) | PDA-indexed accounts | Storage is explicit accounts with rent. You pay per byte, not per computation. |
| Contract deployment | Program deployment + `programId` | Programs are upgradeable by default. Upgrade authority must be secured (multisig or burned). |
| `msg.sender` | Instruction signer account | The signer must be **explicitly passed** as an account in every instruction. Nothing is implicit. |
| `address(this)` | Program's `programId` | Programs don't hold funds. Use a PDA as a vault account instead. |
| Constructor | `initialize` instruction | Anchor programs have no constructor. First instruction initializes state accounts. |
| Events (`emit`) | Program logs + Yellowstone gRPC | Logs are not indexed by default. Use Helius webhooks or Yellowstone for event-driven pipelines. |
| `require()` / `revert()` | `require!()` macro / Anchor error codes | Anchor has typed errors. Define an `#[error_code]` enum — don't use raw string panics. |
| Modifiers | Anchor constraints (`#[account(...)]`) | Access control is declared in account validation structs, not function modifiers. |
| `payable` | Lamport transfer instructions | SOL transfers are explicit CPI calls to the System Program. No `payable` keyword. |
| Gas | Compute Units (CUs) + Priority Fees | Budget CUs per transaction. Priority fee is separate from base fee. |
| Gas estimation | `getRecentPrioritizationFees` | Priority fee market is dynamic. Use Helius priority fee API for accurate estimates. |
| Block | Slot | ~400ms slots. Finality (~32 slots) ≠ confirmation (1 slot). Know which you need. |
| Transaction receipt | Transaction signature | Use `getTransaction` with `commitment: "confirmed"` or `"finalized"` depending on trust requirement. |
| Nonce / replay protection | Recent blockhash | Transactions expire if not landed within ~150 slots (~60s). Handle expiry in your retry logic. |

---

### Token Standards

| Ethereum Standard | Solana Equivalent | Notes |
|---|---|---|
| ERC-20 | SPL Token (original) | Use for simple fungible tokens with no transfer logic |
| ERC-20 + hooks | Token-2022 (Token Extensions Program) | TransferHook, TransferFee, InterestBearing, NonTransferable, ConfidentialTransfer |
| ERC-721 | Metaplex Core | Current standard in 2026. Simpler and cheaper than Legacy. |
| ERC-721 (high volume) | Compressed NFT (cNFT) via Bubblegum | For collections > ~10k items. 100–1000x cheaper per mint via Merkle tree. |
| ERC-1155 | SPL Token + Token-2022 extensions | No direct 1:1 equivalent; model as multiple token mints |
| ERC-721 (Metaplex Legacy) | Metaplex Core | If migrating old ETH NFTs that mapped to Legacy — move to Core for new mints |
| `approve` / `transferFrom` | Token account + `transfer` instruction | Token delegation is modeled as a separate `approve` instruction on the token account |
| Token URI / metadata | Metaplex metadata account | Metadata is a separate on-chain account linked to the mint. URI points to Irys/Arweave JSON. |
| OpenSea royalties (ERC-2981) | Metaplex Core royalty enforcement | On-chain royalties; enforcement depends on marketplace compliance — same caveat as Ethereum |

---

### Access Control and Governance

| Ethereum Pattern | Solana Equivalent | Notes |
|---|---|---|
| `Ownable` (OpenZeppelin) | `authority` field in state account | Store an authority pubkey in your state account. Check it in instruction constraints. |
| `AccessControl` roles | Authority PDAs per role | Model each role as a PDA. Check PDA existence as the permission gate. |
| Multisig (Gnosis Safe) | Squads Protocol | Squads is the production standard for Solana multisig in 2026. |
| Timelock | Custom Anchor program logic | No standard timelock library — implement as a PDA with `unlock_at` timestamp |
| DAO voting (Governor Bravo) | Realms (SPL Governance) | Realms is the standard on-chain governance program for Solana DAOs |
| `pause()` / `unpause()` | `is_paused` flag in state account | Store a boolean in your program state account; check in all instruction constraints |

---

### Development Tooling

| Ethereum Tool | Solana Equivalent | Notes |
|---|---|---|
| Hardhat | Anchor | Framework for Solana programs. Rust-based. Handles build, test, deploy. |
| Foundry | Anchor + Bankrun | Bankrun is the fast in-process test framework — closer to Foundry's speed model than `anchor test` |
| Truffle | Anchor (Truffle is deprecated) | Do not use Truffle patterns as reference |
| Solidity | Rust (with Anchor macros) | Anchor reduces boilerplate significantly. Still Rust — expect a learning curve. |
| Ethers.js | `@solana/kit` (current) or `@solana/web3.js` (legacy) | `@solana/kit` is the current recommended SDK. `web3.js` still works but is in maintenance mode. |
| Viem | `@solana/kit` | No direct equivalent — `@solana/kit` covers the same client-side interaction layer |
| Metamask | Phantom / Solflare / Backpack | Browser extension wallets. Wallet Adapter abstracts across all. |
| WalletConnect | Wallet Adapter (Mobile Wallet Adapter for mobile) | Wallet Adapter is the standard multi-wallet connection library |
| Infura / Alchemy | Helius | Production RPC + DAS API. QuickNode is a valid alternative. |
| The Graph | Helius Enhanced APIs + off-chain DB | DAS API covers NFT/token indexing. Custom program state needs event listener + Postgres. |
| OpenZeppelin | No direct equivalent | Anchor has built-in SPL token CPI helpers. Security patterns are manual — no standard library. |
| Remix IDE | Solana Playground (https://beta.solpg.io) | Browser-based Anchor development environment |
| IPFS / Pinata | Irys (Arweave) | Permanent storage. Irys replaced Bundlr — same underlying Arweave network, new API. |
| Etherscan | Solscan / Solana Explorer / SolanaFM | Block explorers. Helius also provides transaction parsing via Enhanced APIs. |
| `console.log` (Hardhat) | `msg!()` macro | Solana program logs. View with `solana logs` CLI or in explorer. |

---

## Mental Model Corrections

These are the mistakes Ethereum developers make on Solana. Every item here has caused production bugs.

---

### 1. Global state does not exist

**Ethereum mental model:** A contract has storage variables accessible from any function.

**Solana reality:** Programs have no storage. Every piece of state lives in a separate account passed into the instruction. If you forget to pass an account, the instruction cannot access that data.

**Correction:** Design your account structure first. Draw every account that every instruction needs before writing a single line of Rust.

---

### 2. Account ownership is enforced by the runtime

**Ethereum mental model:** Any function can read any contract's storage if it has the address.

**Solana reality:** Every account has an `owner` field. Only the owning program can modify an account's data. If your program doesn't own the account, it cannot write to it — even if it has the address.

**Correction:** When designing PDAs, verify that your program ID is the expected owner. Account ownership mismatches cause silent failures or panics.

---

### 3. PDA derivation replaces mappings

**Ethereum mental model:** `mapping(address => uint256) public balances;`

**Solana reality:** Mappings don't exist. Derive a PDA for each key using `[seed, user_pubkey]`. Each mapping "entry" is a separate account with its own rent.

**Correction:** Design seeds carefully. Collisions are silent bugs. Use deterministic, unique seed combinations. Document every PDA derivation in your program.

---

### 4. Rent is real money

**Ethereum mental model:** Storage costs gas once at write time.

**Solana reality:** Every account must maintain a minimum SOL balance (rent-exempt amount, ~0.002 SOL per account at typical sizes). If balance drops below minimum, the account can be garbage collected. Your program or your users fund this.

**Correction:** Calculate rent-exempt minimums before designing account structures. For programs that create many accounts (e.g., per-user state), decide upfront who pays rent — and handle the case where the account doesn't exist yet.

---

### 5. Transaction atomicity works differently

**Ethereum mental model:** A failed transaction reverts all state changes. Partial execution is impossible.

**Solana reality:** Solana transactions are atomic — if an instruction fails, the transaction fails and no state changes. But Solana also has **versioned transactions** and **Address Lookup Tables** which affect how you pack multiple instructions. Cross-program invocations (CPI) are synchronous and atomic within a transaction.

**Correction:** You can pack multiple instructions into one Solana transaction (up to compute limit). Design flows to batch where possible — each transaction has a base fee, so fewer transactions = lower cost.

---

### 6. There is no `msg.value` equivalent

**Ethereum mental model:** Send SOL (ETH) with a function call using `payable`.

**Solana reality:** SOL transfers are explicit System Program CPI calls. To accept SOL in an instruction, you must explicitly transfer lamports from the signer's account to a destination account via a `system_program::transfer` CPI.

**Correction:** Always make SOL flow explicit in your account structs. Document which instructions move lamports and in which direction.

---

### 7. Upgradeability is opt-out, not opt-in

**Ethereum mental model:** Contracts are immutable by default. Upgradeability requires proxy pattern.

**Solana reality:** Programs are upgradeable by default — whoever holds the upgrade authority can replace the program binary at any time. This is more powerful and more dangerous than Ethereum proxies.

**Correction:** Transfer upgrade authority to a multisig (Squads) before mainnet launch. If the program should be immutable, burn the upgrade authority explicitly. Never launch with a hot wallet as upgrade authority.

---

### 8. Confirmation ≠ finality

**Ethereum mental model:** Waiting for N block confirmations = transaction is safe.

**Solana reality:** Solana has three commitment levels:
- `processed` — seen by the node, may be forked
- `confirmed` — voted on by supermajority, very unlikely to fork
- `finalized` — permanently committed, cannot be rolled back

For payments and ownership transfers: use `finalized`. For UX feedback: use `confirmed`. Never use `processed` for trust-critical operations.

**Correction:** Explicitly set `commitment` on every `getTransaction` and `getSignatureStatus` call. Do not rely on defaults.

---

### 9. Failed transactions still cost fees

**Ethereum mental model:** Reverted transactions still cost gas (the computation happened).

**Solana reality:** Same — failed transactions on Solana still pay the base transaction fee and any priority fee. Compute Units are consumed up to the point of failure.

**Correction:** Simulate transactions before sending (`simulateTransaction`). Catch failures before they hit mainnet and cost the user fees.

---

### 10. Program logs are not event subscriptions

**Ethereum mental model:** `emit Transfer(...)` creates an indexed event that off-chain code subscribes to via `eth_getLogs`.

**Solana reality:** `msg!("Transfer: ...")` writes to program logs, but logs are not indexed, not searchable by default, and not subscription-friendly. To build event-driven pipelines, use Helius webhooks (transaction webhooks) or Yellowstone gRPC (real-time stream).

**Correction:** Design your off-chain event pipeline before writing program code. If you need event-driven behavior (e.g., "when NFT is transferred, update leaderboard"), plan the indexing layer first.

---

## ETH-Specific Architecture Delta Overlay

When a user is migrating from Ethereum, append this section to the standard Architecture Delta:

```
ETH → SOL MIGRATION NOTES
────────────────────────────────────────────────
CONTRACT MIGRATION
  [Contract name] → [Anchor program name]
  State variables → [List PDA accounts with seed patterns]
  Mappings → [List PDA derivations replacing each mapping]

LIBRARY SWAPS
  Ethers.js / Viem → @solana/kit
  Hardhat → Anchor + Bankrun
  OpenZeppelin → [manual implementations — note which patterns needed]
  Infura / Alchemy → Helius
  IPFS / Pinata → Irys

MENTAL MODEL FLAGS (confirm team is aware)
  □ Programs are stateless — all state in accounts
  □ Upgrade authority transferred to multisig before launch
  □ PDA derivations documented and collision-checked
  □ Rent-exempt minimums calculated for all new accounts
  □ Commitment levels set explicitly on all reads
  □ SOL transfers are explicit CPI — no payable equivalent
────────────────────────────────────────────────
```

---

## EVM Chain Notes

If the user is migrating from a non-mainnet EVM chain, apply these adjustments:

| Source Chain | Additional Notes |
|---|---|
| Polygon | Gas cost comparison is less compelling — Solana's primary advantage is throughput and ecosystem, not just fees |
| Arbitrum / Optimism / Base | L2 teams often have stronger composability expectations — Solana's composability model (CPI) is different but equivalent in power |
| Avalanche | Subnet model has no Solana parallel — map Subnet logic to a standalone Anchor program with its own authority model |
| BSC | Likely cost-motivated — Solana's fee structure is genuinely lower; emphasize throughput as secondary benefit |
| Any EVM chain | All mental model corrections above apply equally — the EVM model is consistent across chains |

---

## Routing After ETH → SOL Module

- Library swaps confirmed + user wants to start building → route to `solana-dev-skill`
- Architecture delta not yet generated → load `03-architecture-delta.md` with ETH overlay
- Decision cards not yet generated → load `04-decision-cards.md`
- Security of program design → route to `solana-auditor-skill`
- Full output ready → compile as `migration.md` artifact