# Decision Cards

> Module 04 of the Solana Migration Assessment Skill.
> Load this after 03-architecture-delta.md, or when a user challenges a recommendation and wants explicit rationale.

---

## Purpose

Decision cards explain *why* each architectural choice was made — not just what to build.
Every card names an alternative, explains why it was rejected, and assigns a confidence level.

This module teaches migration judgment, not just stack translation.

---

## Context7 Integration

**This module has the highest Context7 priority in the skill.**

Before generating or updating any card that involves a technology recommendation:

```
IF context7 available:
  → append "use context7" to fetch live docs for the relevant library/standard
  → assign confidence level based on current API maturity
  → cite the doc source in the card

IF context7 unavailable:
  → use Q2 2026 pinned knowledge
  → append to every affected card:
    ⚠ Based on Q2 2026 docs — verify against current source before implementing.
  → NEVER silently omit this disclaimer
```

Technologies that MUST trigger a Context7 fetch when available:
- `@solana/kit` or `@solana/web3.js` (API surface shifts frequently)
- `metaplex/core` (active development)
- `spl/token-2022` (extension list growing)
- `helius-labs/helius-sdk` (indexer/RPC API changes)
- `anchor-lang` (major version changes)
- `irys` (formerly Bundlr — naming and API shifted)

---

## Card Format

Every decision card follows this exact structure:

```
---
Decision: [What was decided — specific and actionable]
Reason: [Why this is the right call for this product]
Alternative: [The most credible thing someone might do instead]
Why rejected: [Concrete reason the alternative loses here — not generic]
Confidence: [Very High / High / Medium / Low]
Context7: [library fetched, if applicable] / [N/A]
---
```

**Confidence level definitions:**

| Level | Meaning |
|---|---|
| Very High | Stable recommendation — multiple production examples, low ecosystem churn |
| High | Strong signal — well-established pattern, minor API variance possible |
| Medium | Directionally correct — check current docs before implementing |
| Low | Evolving rapidly — fetch live docs before committing; alternative may now be valid |

---

## Pre-Built Cards (10 Core Decisions)

These cover the decisions that arise in ~80% of migration assessments.
Generate additional cards from the architecture delta for decisions not covered here.

---

### Card 01 — Authentication

---
**Decision:** Keep existing auth (Supabase Auth / Auth0 / Clerk / JWT) for user identity. Use wallet only as an optional identity layer or for on-chain interactions.

**Reason:** Wallets are not a substitute for traditional auth in products with non-crypto-native users. Mandatory wallet-first UX creates abandonment. Most products benefit from web2 auth for login + wallet for ownership/signing.

**Alternative:** Replace all auth with wallet-based login (Sign-In With Solana / SIWS).

**Why rejected:** SIWS is production-ready, but requires users to have a wallet and understand signing. Unless 100% of your users are crypto-native, forcing SIWS raises onboarding friction significantly. Embedded wallets (Privy, Dynamic, Turnkey) reduce this — but add a dependency and cost layer. Hybrid is almost always correct here.

**Confidence:** High

**Context7:** N/A (auth decision is product logic, not library-specific)

---

### Card 02 — Token Standard Selection

---
**Decision:** Use Token-2022 (Token Extensions Program) for new fungible tokens that require programmable transfer logic, royalties, interest-bearing behavior, or transfer restrictions.

**Reason:** Token-2022 is the current standard for programmable fungible tokens on Solana. Extensions like TransferHook, InterestBearing, and NonTransferable cover cases that previously required custom programs.

**Alternative:** Use the original SPL Token program.

**Why rejected:** Original SPL Token is simpler but has no extension surface. If you need any programmable behavior on transfers, you would build a custom program to wrap it — defeating the purpose. Use SPL Token only for simple, non-programmable fungible tokens (e.g., governance tokens with no transfer logic).

**Confidence:** High

**Context7:** `spl/token-2022` — fetch to confirm current extension list and any deprecated extensions.

---

### Card 03 — NFT Standard Selection

---
**Decision:** Use Metaplex Core for new NFT collections in 2026. Use compressed NFTs (cNFT via Bubblegum) for collections above ~10,000 items where per-mint cost matters.

**Reason:** Metaplex Core is the current recommended standard — it replaced Metaplex Legacy (Token Metadata) as the primary NFT program. It is simpler, cheaper per-asset, and actively maintained. cNFT dramatically reduces storage cost for high-volume collections by batching state into a Merkle tree on-chain.

**Alternative:** Use Metaplex Legacy (Token Metadata + Token standard).

**Why rejected:** Metaplex Legacy still works and has broad marketplace support, but Core is the forward path. New collections built on Legacy today take on migration debt. Exception: if you need immediate secondary market support on platforms not yet supporting Core, check current marketplace compatibility before committing.

**Confidence:** Medium

**Context7:** `metaplex/core` — fetch to confirm current marketplace integrations, as support has been expanding rapidly.

---

### Card 04 — Database and Off-Chain Storage

---
**Decision:** Keep PostgreSQL (or equivalent) off-chain for all transactional business data. Only move ownership records, settlement logic, and trust-critical state on-chain.

**Reason:** On-chain storage on Solana costs rent (SOL locked per byte). It is also slower to query, harder to aggregate, and subject to program upgrade complexity. Business data that changes frequently (user profiles, analytics, logs, CRM data) has no trust benefit from being on-chain — and significant cost and performance downsides.

**Alternative:** Store all application state on-chain in program accounts.

**Why rejected:** This is the most common over-engineering mistake in Solana migrations. On-chain state is for data that needs trustless verification, composability, or immutability. A user's display name, their purchase history, or app preferences gain nothing from on-chain storage. Costs escalate, query complexity increases, and iteration speed drops dramatically.

**Confidence:** Very High

**Context7:** N/A

---

### Card 05 — Payment Rails

---
**Decision:** Use USDC (SPL Token) via wallet adapter for on-chain payments. Retain Stripe or existing processor for users who cannot or will not use wallets.

**Reason:** USDC on Solana settles in seconds, is near-zero cost, eliminates chargeback risk, and enables composability (payments that trigger on-chain logic). For products where some users are crypto-native and some are not, a hybrid approach retains conversion for both cohorts.

**Alternative:** Replace Stripe entirely with on-chain USDC payments.

**Why rejected:** Full replacement only makes sense when 100% of your users have wallets and your product's trust model requires on-chain settlement. Most products in 2026 still have a significant percentage of non-crypto users. Removing Stripe entirely before crypto UX is proven in your product risks conversion loss.

**Confidence:** High

**Context7:** N/A (USDC and wallet adapter pattern is stable)

---

### Card 06 — RPC Provider

---
**Decision:** Use Helius as primary RPC provider. Do not use the public Solana mainnet RPC endpoint for production.

**Reason:** The public mainnet RPC has rate limits, no SLA, and no enhanced APIs. Helius provides production-grade RPC with DAS API (Digital Asset Standard), webhooks, priority fee estimation, and a generous free tier. For indexing-heavy use cases, Helius Enhanced Transactions API reduces the need for a separate indexer.

**Alternative:** QuickNode or self-hosted RPC node.

**Why rejected:** QuickNode is a valid alternative with good Solana support — use it if you have an existing relationship or specific tooling preference. Self-hosted is only justified for very high-volume, latency-sensitive applications (most products should not self-host). The primary reason to default to Helius: its DAS API and Enhanced APIs are Solana-native, not a generic multi-chain product.

**Confidence:** High

**Context7:** `helius-labs/helius-sdk` — fetch to confirm current API endpoints and Enhanced Transaction API surface.

---

### Card 07 — Indexing Strategy

---
**Decision:** Use Helius DAS API and Enhanced APIs as primary indexer for token and NFT queries. Add a lightweight off-chain database layer (Postgres/Redis) to cache aggregated query results your app queries frequently.

**Reason:** On-chain data is not structured for application queries. Fetching all token accounts for a user, computing totals, or filtering by attribute requires either an indexer or expensive RPC iteration. DAS API handles NFT/token queries. For custom program state, a simple event-listener + Postgres write model covers most needs without the complexity of a full custom indexer.

**Alternative:** Build a custom Geyser plugin indexer or use Yellowstone gRPC.

**Why rejected:** Geyser + Yellowstone is the right choice for settlement-critical, real-time event pipelines (e.g., a DEX liquidation monitor). For most application-layer indexing needs (NFT ownership, token balances, activity feeds), DAS API + a lightweight cache is simpler, cheaper, and faster to ship. Use Yellowstone only when you genuinely need sub-second on-chain event delivery at scale.

**Confidence:** High

**Context7:** `helius-labs/helius-sdk` — same fetch as Card 06.

---

### Card 08 — File and Metadata Storage

---
**Decision:** Use Irys (formerly Bundlr) for permanent on-chain metadata and asset storage. Use existing CDN (S3, Cloudflare R2) for mutable or large-volume assets.

**Reason:** Irys writes data permanently to Arweave via a developer-friendly API with one-time payment model. It is the current standard for NFT metadata and assets requiring permanence. Mutable or high-volume assets (user-generated content, video, app media) belong on your existing CDN — permanence is not a requirement there, and cost would be prohibitive.

**Alternative:** Use IPFS / Pinata for metadata storage.

**Why rejected:** IPFS pinning is not permanent by default — if the pin lapses, the asset disappears. For NFT metadata, this is a known failure mode in older collections. Arweave via Irys guarantees permanence with a one-time fee. Note: if you are migrating from Ethereum with IPFS-hosted metadata, plan a metadata migration to Irys as part of the move.

**Confidence:** Medium

**Context7:** `irys` — fetch to confirm current upload API and pricing model. This ecosystem has shifted significantly (Bundlr → Irys rename + API changes).

---

### Card 09 — Access Control and Treasury Management

---
**Decision:** Use PDAs (Program Derived Addresses) with a multisig (Squads Protocol) for treasury and governance access control. Keep application-level role management (admin, editor, viewer) in your off-chain database.

**Reason:** On-chain access control via PDAs is correct for funds, mint authorities, and governance — where you need trustless, auditable control that no single key can override. Application-level roles (who can edit a post, who has admin access) have no trust benefit from being on-chain and are expensive and slow to update there.

**Alternative:** Use a single keypair for treasury authority; manage all roles on-chain.

**Why rejected:** Single keypair treasury is an operational security risk — key compromise = full fund loss with no recourse. Multisig (Squads is the current production standard) requires M-of-N signers for treasury operations. Application roles on-chain add cost and query complexity for zero trust benefit.

**Confidence:** Very High

**Context7:** N/A (Squads multisig pattern is stable; verify Squads SDK version if implementing)

---

### Card 10 — Session Management and Wallet UX

---
**Decision:** Use embedded wallet providers (Privy, Dynamic, or Turnkey) if your users are not crypto-native. Use Wallet Adapter directly if targeting developers or existing crypto users.

**Reason:** In 2026, embedded wallet providers create wallets silently via email/social login, abstracting seed phrases entirely. This closes the largest onboarding gap for non-crypto users. Wallet Adapter remains the correct choice for products targeting users who already have Phantom, Solflare, or hardware wallets.

**Alternative:** Require users to install a browser extension wallet (Phantom / Solflare).

**Why rejected:** Requiring extension wallet installation as the *only* path creates a hard drop-off for non-crypto users. Extension wallets are appropriate as an *option* — but not as the sole requirement unless 100% of your users are crypto-native. The embedded wallet space has matured significantly; the 2021-era "install Metamask" UX is no longer the only path.

**Confidence:** High

**Context7:** N/A (embedded wallet provider choice is product/vendor decision, not a Solana library)

---

## Generating Additional Cards

When the architecture delta identifies decisions not covered by the 10 pre-built cards above, generate new cards using this process:

1. Identify each significant architectural decision in the delta (anything in NEW COMPONENTS or REMOVED)
2. For each: apply the card format exactly
3. If the decision involves a specific Solana library or standard → trigger Context7 fetch if available
4. Assign confidence based on: ecosystem maturity + recency of your knowledge source
5. Never mark a fast-changing technology as "Very High" or "High" without either a live Context7 source or an explicit Q2 2026 knowledge pin

**Trigger phrases that signal a new card is needed:**
- "Why did you recommend X over Y?"
- "We were thinking of using Z instead"
- "What if we kept [component] instead of replacing it?"
- "Can you explain the [decision] recommendation?"

When a user challenges a recommendation, do not simply defend it — generate or update the relevant card with the alternative they've proposed as the "Alternative" field and evaluate it fairly.

---

## Routing After Decision Cards

Once decision cards are complete:

- Full output is ready → compile as `migration.md` artifact (Score → Verdict → Delta Report → Decision Cards)
- User mentions Ethereum, EVM, Solidity, Hardhat, ERC standards → load `05-eth-to-sol.md`
- User wants code → route to `solana-dev-skill`
- User asks about security of program design → route to `solana-auditor-skill`