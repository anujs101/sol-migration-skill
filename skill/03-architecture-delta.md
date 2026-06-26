# Architecture Delta Report

> Module 03 of the Solana Migration Assessment Skill.
> Load this after 02-suitability.md returns a Migrate or Hybrid verdict.
> Do NOT load for Don't Migrate verdicts.

---

## Purpose

Produce a structured, scannable delta between the user's current stack and their target Solana architecture. This is the primary shareable artifact — the document a CTO hands to their engineering team.

The delta does not prescribe a full system design. It answers:
- What moves on-chain?
- What stays off-chain?
- What gets removed?
- What new components are needed?
- What are the real risks?

---

## Context7 Integration

This module has **medium** Context7 priority.

Fetch live docs only for RPC provider and indexer recommendations:

```
IF context7 available AND generating RPC/indexer recommendation:
  → append "use context7" for helius-labs/helius-sdk
  → verify current Enhanced API surface before recommending specific endpoints

IF context7 unavailable:
  → use Q2 2026 pinned knowledge
  → append to RPC/indexer section:
    ⚠ Based on Q2 2026 docs — verify Helius API surface before implementing.
```

Do NOT trigger Context7 for the structural delta itself (categories, off-chain decisions) — that logic is stable.

---

## Delta Format

Every Architecture Delta Report follows this exact structure:

```
ARCHITECTURE DELTA REPORT
════════════════════════════════════════════════

CURRENT STACK
  [List user's existing components, comma-separated or one per line]

────────────────────────────────────────────────
TARGET STACK (ON-CHAIN COMPONENTS)
  [What moves on-chain — be specific]

────────────────────────────────────────────────
UNCHANGED (KEEP OFF-CHAIN)
  [What stays exactly as-is — with one-line reason]

────────────────────────────────────────────────
NEW COMPONENTS NEEDED
  [Net-new infrastructure the user doesn't currently have]

────────────────────────────────────────────────
REMOVED
  [What gets eliminated — with one-line reason]

────────────────────────────────────────────────
RISKS
  [3–5 real risks, specific to this stack — not generic warnings]

────────────────────────────────────────────────
Migration Complexity: X / 10
Estimated Timeline: X–Y weeks
────────────────────────────────────────────────
```

**Complexity scoring guide:**

| Score | Meaning |
|---|---|
| 1–3 | Low — additive only, no rearchitecting. One dev, < 3 weeks. |
| 4–6 | Moderate — some existing flows change, new infra needed. Small team, 4–8 weeks. |
| 7–8 | High — significant rearchitecting, multiple integration points, team needed. 8–14 weeks. |
| 9–10 | Very high — core product restructure, high risk of regression. 3+ months, senior team. |

**Timeline rules:**
- Always a range, never a point estimate
- State assumptions inline (e.g., "assuming 2 Solana-experienced devs")
- Hybrid migrations are generally lower complexity than full migrations
- Never give a timeline shorter than 3 weeks for any on-chain work

---

## Category-Level Mapping (Reference)

Use this table to map any user stack to Solana equivalents. This covers categories — not exhaustive tool lists — so it handles arbitrary stacks gracefully.

| Category | Keep Off-Chain | Move On-Chain | New Component Needed |
|---|---|---|---|
| Authentication | ✅ Always (unless 100% crypto-native users) | Wallet as optional identity layer | Wallet Adapter + optionally embedded wallet provider (Privy / Dynamic) |
| Payments | ✅ Keep Stripe for non-crypto users | USDC settlement for crypto-native flows | SPL Token transfer instructions, wallet adapter |
| Database | ✅ Always (PostgreSQL / MySQL / MongoDB) | Ownership records, settlement state only | RPC + indexer for on-chain queries |
| File / Media Storage | ✅ CDN for mutable/large assets (S3, R2) | Permanent metadata only | Irys for Arweave uploads |
| Identity / Access | ✅ App-level roles stay in DB | Treasury authority, mint authority, governance | Authority PDAs + Squads multisig |
| Analytics / Metrics | ✅ Always (Mixpanel, Segment, custom) | — | Helius Enhanced APIs to feed off-chain analytics |
| Session Management | ✅ Redis / JWTs for app sessions | — | Wallet signatures replace server-side signing |
| Real-time Events | ✅ WebSockets for app events | Settlement-critical events only | Yellowstone gRPC (only if sub-second delivery needed) |
| NFT Ownership | — | Metaplex Core (< 10k items) or cNFT via Bubblegum (> 10k) | RPC + DAS API for queries |
| Fungible Tokens | — | SPL Token (simple) or Token-2022 (programmable) | Token mint authority PDA |
| Smart Contract Logic | — | Anchor program | Program keypair, upgrade authority |
| Indexing | ✅ Off-chain DB for aggregated queries | — | Helius DAS API + lightweight Postgres cache |

---

## Worked Examples

### Example A — SaaS with Digital Marketplace
**Profile:** Next.js frontend, Supabase Auth, PostgreSQL, Stripe payments, S3 assets. Selling digital goods (art, templates). Wants creator royalties + secondary market.

```
ARCHITECTURE DELTA REPORT
════════════════════════════════════════════════

CURRENT STACK
  Next.js | Supabase Auth | PostgreSQL | Stripe | S3 | REST APIs | JWT sessions

────────────────────────────────────────────────
TARGET STACK (ON-CHAIN COMPONENTS)
  Metaplex Core (NFT ownership per digital asset)
  SPL Token / USDC (primary + secondary market payments)
  Anchor Program (royalty enforcement, escrow logic)
  Wallet Adapter (Phantom / Solflare + Privy for non-crypto users)

────────────────────────────────────────────────
UNCHANGED (KEEP OFF-CHAIN)
  Next.js — frontend unchanged
  Supabase Auth — keep for non-wallet users; wallet becomes optional second identity
  PostgreSQL — product catalog, user profiles, order history, analytics
  S3 — asset delivery (mutable, high-volume); Irys only for NFT metadata
  CI/CD, monitoring, analytics tooling

────────────────────────────────────────────────
NEW COMPONENTS NEEDED
  Helius RPC — production RPC + DAS API for NFT queries
  Irys — permanent metadata storage for minted assets
  Treasury PDA — holds escrow funds during secondary sales
  Squads Multisig — protects mint authority and treasury
  Privy or Dynamic — embedded wallets for non-crypto buyers (optional but recommended)

────────────────────────────────────────────────
REMOVED
  Stripe for primary purchases — replaced by USDC wallet payments
  Server-side royalty enforcement logic — moved to Anchor program
  JWT-based ownership records — replaced by on-chain token ownership

────────────────────────────────────────────────
RISKS
  Wallet onboarding friction — buyers must acquire USDC before purchasing; embedded wallets mitigate but don't eliminate
  Metadata permanence dependency — Irys upload must complete before NFT is valid; handle upload failures gracefully
  Royalty enforcement only works on compliant marketplaces — off-marketplace P2P transfers bypass on-chain royalties
  DAS API query latency — freshly minted NFTs may not appear in DAS for 1–3 seconds; build polling or webhook fallback
  Anchor program upgrade authority — must be secured via multisig from day one; not retroactively fixable without migration

────────────────────────────────────────────────
Migration Complexity: 6 / 10
Estimated Timeline: 7–10 weeks
(Assumes 2 devs, one with Solana experience; Stripe retained for non-crypto users during transition)
────────────────────────────────────────────────
```

---

### Example B — Gaming Platform with In-Game Items
**Profile:** Unity game, Node.js backend, MySQL, Firebase Auth, custom item database. Wants true player ownership of items + secondary market.

```
ARCHITECTURE DELTA REPORT
════════════════════════════════════════════════

CURRENT STACK
  Unity client | Node.js backend | MySQL | Firebase Auth | Custom item DB | WebSockets

────────────────────────────────────────────────
TARGET STACK (ON-CHAIN COMPONENTS)
  Metaplex Core or cNFT via Bubblegum (item ownership — use cNFT if > 10k item types)
  SPL Token (in-game currency if applicable)
  Anchor Program (item transfer rules, loot drop logic, crafting)
  Wallet Adapter — Unity SDK or mobile wallet adapter

────────────────────────────────────────────────
UNCHANGED (KEEP OFF-CHAIN)
  Unity client — game logic unchanged; wallet interaction is additive
  Node.js backend — game state, matchmaking, leaderboards, session management
  MySQL — player progression, game state, non-ownership data
  Firebase Auth — keep for player login; wallet optional second identity
  WebSockets — real-time game events; Yellowstone not needed for game state

────────────────────────────────────────────────
NEW COMPONENTS NEEDED
  Helius RPC + DAS API — item ownership queries, collection-level analytics
  Anchor Program — item transfer validation, crafting recipes, loot rules
  Squads Multisig — protects item mint authority (prevents rug of item supply)
  Irys — item metadata storage (images, attributes, rarity)
  Merkle tree account (if using cNFT) — pre-allocated tree for compressed minting

────────────────────────────────────────────────
REMOVED
  Custom item ownership DB tables — replaced by on-chain token ownership
  Server-side item transfer validation — moved to Anchor program
  Centralized item minting logic — replaced by on-chain mint authority

────────────────────────────────────────────────
RISKS
  Mobile wallet UX — in-game wallet signing adds latency and UX friction on mobile; evaluate session keys or delegated signing
  cNFT Merkle tree sizing — tree must be pre-allocated with correct depth; resizing requires migration; overestimate initial tree size
  Item metadata immutability — once on Irys/Arweave, metadata is permanent; design metadata schema carefully before minting
  Backend / on-chain state sync — game backend must reconcile on-chain ownership with game state; build idempotent sync layer
  Anchor program upgrade authority — same risk as Example A; multisig from day one

────────────────────────────────────────────────
Migration Complexity: 7 / 10
Estimated Timeline: 9–13 weeks
(Assumes 2–3 devs; game logic migration adds complexity beyond standard SaaS migration; mobile wallet UX is the longest-tail risk)
────────────────────────────────────────────────
```

---

### Example C — Hybrid B2B Payments (Partial Migration)
**Profile:** B2B SaaS, React frontend, Django backend, PostgreSQL, Stripe. Cross-border payouts to contractors. Wants to reduce fees + settlement time. Verdict: Hybrid.

```
ARCHITECTURE DELTA REPORT
════════════════════════════════════════════════

CURRENT STACK
  React | Django | PostgreSQL | Stripe (payments + payouts) | Redis | REST APIs

────────────────────────────────────────────────
TARGET STACK (ON-CHAIN COMPONENTS)
  USDC (SPL Token) — contractor payout rail only
  Wallet Adapter — contractor-side only (payers stay on Stripe)

────────────────────────────────────────────────
UNCHANGED (KEEP OFF-CHAIN)
  React frontend — no changes for payer-side flows
  Django backend — all business logic unchanged
  PostgreSQL — all data; add wallet_address column to contractor table
  Stripe — retained for all client-side billing; removed only from payout leg
  Redis — unchanged
  Auth, session management, analytics — all unchanged

────────────────────────────────────────────────
NEW COMPONENTS NEEDED
  Helius RPC — USDC transfer submission + confirmation monitoring
  USDC treasury wallet — company-controlled wallet funded for payouts
  Squads Multisig — treasury protection (required if > $50k monthly payout volume)
  Contractor wallet onboarding flow — email-triggered wallet creation (Privy recommended)

────────────────────────────────────────────────
REMOVED
  Stripe Connect payouts — replaced by USDC transfers for contractor leg only
  Payout reconciliation webhooks from Stripe — replaced by on-chain confirmation polling

────────────────────────────────────────────────
RISKS
  Contractor wallet adoption — contractors must create/provide a Solana wallet address; expect 10–30% initial resistance; build fallback to Stripe ACH
  USDC liquidity management — company treasury must maintain USDC balance; add automated low-balance alerts
  Regulatory exposure — cross-border USDC payouts may trigger MSB or local payment regulations depending on jurisdictions; obtain legal review before launch
  Confirmation monitoring — Django must poll or webhook for USDC transfer finality; build retry + idempotency layer
  Tax reporting — USDC payouts are taxable income in most jurisdictions; ensure 1099/local equivalent reporting is preserved

────────────────────────────────────────────────
Migration Complexity: 4 / 10
Estimated Timeline: 3–5 weeks
(Hybrid scope — only payout leg changes; payer-side entirely unchanged; legal review may extend timeline)
────────────────────────────────────────────────
```

---

## Generating the Delta for a User's Stack

When a user's stack doesn't match the worked examples above, follow this process:

**Step 1 — Classify each component by category**
Map every component the user named to a row in the Category-Level Mapping table.
Components that don't map cleanly → flag as "out of scope for migration assessment" and note it in the delta.

**Step 2 — Apply the Hybrid constraint if applicable**
If the verdict was Hybrid (not full Migrate), scope the on-chain components conservatively:
- Only move what has a direct trust or ownership benefit
- Default to "keep off-chain" for any ambiguous component
- State the Hybrid constraint explicitly at the top of the delta

**Step 3 — Populate the six sections**
Fill each section using only what was confirmed in discovery (01-discovery.md). Do not invent stack components. If a component is unknown, write `[unknown — confirm with team]`.

**Step 4 — Write risks specific to this stack**
Do not copy generic risks. Each risk must reference a specific component or decision from this delta.
Minimum 3 risks, maximum 6. If you cannot write 3 specific risks, the delta is not specific enough.

**Step 5 — Score complexity and timeline**
Apply the complexity scoring guide. State timeline assumptions explicitly.
If discovery did not surface team Solana experience → add 2–3 weeks to timeline and note it.

---

## Routing After Architecture Delta

- Delta complete + user wants rationale for each decision → load `04-decision-cards.md`
- User mentions Ethereum, EVM, Solidity, Hardhat → load `05-eth-to-sol.md`
- User asks how to build the Anchor program → route to `solana-dev-skill`
- User asks about security of the program design → route to `solana-auditor-skill`
- Full output ready → compile as `migration.md` artifact (Score → Verdict → Delta → Decision Cards)