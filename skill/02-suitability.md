# Suitability Assessment Module

> Load this file when the user asks: "Should I migrate to Solana?",
> "Is Solana right for my product?", or after discovery reveals enough
> context to score. Run scoring BEFORE any migration planning.

---

## The Scoring Engine

Score the product across 8 factors. Each factor scores 0–12 points.
Maximum possible: 96. Normalize to 100 after totaling.

Do not skip factors. If genuinely unknown, score 0 and flag it as
an open question in the output.

---

### Factor 1 — Digital Asset Ownership (0–12)

Does the product involve assets that users own, trade, or transfer?

| Situation | Score |
|---|---|
| Core product IS digital asset ownership (NFTs, tokens, collectibles, in-game items) | 12 |
| Ownership is a significant feature but not the core product | 8 |
| Ownership is a minor or planned feature | 4 |
| No digital assets involved at all | 0 |

**Why it matters:** Solana's account model, SPL Token, and Metaplex are
purpose-built for ownership. If there's nothing to own, the foundation
of the value proposition is missing.

---

### Factor 2 — Settlement Trustlessness (0–12)

Does the product require parties to transact without trusting each other
or a central intermediary?

| Situation | Score |
|---|---|
| Core flow requires trustless settlement (escrow, royalties, P2P payments, auctions) | 12 |
| Some flows benefit from trustlessness but most don't | 7 |
| Trust is provided by a central party and users accept this | 3 |
| Purely internal B2B product — trust is contractual, not technical | 0 |

**Why it matters:** This is the foundational blockchain value proposition.
If users trust the company anyway, blockchain adds complexity without
removing the trust assumption.

---

### Factor 3 — Secondary Market Potential (0–12)

Could the product's assets or outputs be traded on a secondary market?

| Situation | Score |
|---|---|
| Secondary market is core to the product (marketplace, resale, trading) | 12 |
| Secondary market is a natural extension that would add clear value | 8 |
| Secondary market is possible but not a current priority | 4 |
| No secondary market makes sense for this product | 0 |

**Why it matters:** Solana's composability and Jupiter/Tensor/Magic Eden
ecosystem create secondary markets almost for free. Products that ignore
this leave significant value on the table — or don't need it at all.

---

### Factor 4 — Transaction Volume and Frequency (0–12)

How often does the product execute transactions, and at what scale?

| Situation | Score |
|---|---|
| High volume, high frequency (1000+ daily transactions, microtransactions, real-time) | 12 |
| Medium volume (hundreds of daily transactions, periodic settlements) | 8 |
| Low volume but cost-sensitive (cross-border payments, B2B settlements) | 6 |
| Low volume, not cost-sensitive | 2 |
| Rarely transacts (once a month or less) | 0 |

**Why it matters:** Solana's ~$0.00025 per transaction and 4000+ TPS
only matter if you're executing volume. For a SaaS with 10 daily
transactions, fee savings are irrelevant.

---

### Factor 5 — State Change Frequency (0–12)

How often does the core data model change?

> NOTE: This factor is INVERSE — frequent state changes push the score DOWN.

| Situation | Score |
|---|---|
| State changes rarely — ownership transfers, settlement events, milestone completions | 12 |
| State changes periodically — daily updates, batch settlements | 8 |
| State changes frequently — hourly, per user session | 4 |
| State changes constantly — every user action, real-time updates, live data | 0 |

**Why it matters:** On-chain writes cost money and take ~400ms per
confirmation. Products where state changes every second (live chat,
real-time analytics, CRM activity logs) should keep state off-chain.
Only move what benefits from immutability.

---

### Factor 6 — Decentralization Requirement (0–12)

Does the product genuinely require permissionless, censorship-resistant
operation? Or is centralized control acceptable?

| Situation | Score |
|---|---|
| Decentralization is a core product requirement — censorship resistance, permissionless access | 12 |
| Decentralization is a strong differentiator for the target market | 8 |
| Decentralization is appealing but not strictly required | 4 |
| Central control is fine — users don't demand or care about decentralization | 1 |
| Centralization is legally required (regulated financial product, enterprise compliance) | 0 |

**Why it matters:** If the answer is "our users don't care about
decentralization," that's not automatically disqualifying — but it
means the product is choosing Solana for performance/cost reasons,
not trustlessness. Score accordingly and be honest about it.

---

### Factor 7 — Team Migration Capacity (0–12)

Can this team realistically execute a Solana migration?

| Situation | Score |
|---|---|
| 3+ developers, 6+ months runway, prior blockchain experience | 12 |
| 2–3 developers, 3–6 months runway, willing to learn | 8 |
| 2 developers, 2–3 months runway, no blockchain experience | 4 |
| Solo developer or < 6 weeks runway | 1 |
| No technical team yet | 0 |

**Why it matters:** Solana migration is a 3–6 month effort minimum
for a real product. Anchor, PDAs, account model, testing — it's a
significant learning curve. A solo founder with 4 weeks of runway
who wants to "migrate to Solana" is setting themselves up for failure.

---

### Factor 8 — User Base Wallet Readiness (0–12)

Are the product's existing or target users capable of and willing to
use a Solana wallet?

| Situation | Score |
|---|---|
| Target users are crypto-native — already use wallets daily | 12 |
| Target users are tech-savvy and open to wallet onboarding | 8 |
| Mixed user base — some crypto-native, some Web2 | 5 |
| Primarily Web2 users — wallet onboarding is a significant friction risk | 2 |
| Enterprise or regulated users — wallets may be prohibited or impractical | 0 |

**Why it matters:** As of 2026, wallet UX has improved significantly
(embedded wallets, passkey signers), but it still adds friction vs.
email/password. A consumer product with millions of non-crypto users
faces a real adoption risk that must be accounted for.

---

## Scoring Calculation

```
Raw score = sum of all 8 factors (max 96)
Normalized score = round((raw / 96) * 100)
```

Present the normalized score as: **Migration Readiness Score: XX / 100**

---

## Verdict Thresholds

| Score | Verdict | Meaning |
|---|---|---|
| 0 – 30 | ❌ Don't Migrate | Blockchain provides no meaningful advantage. Proceeding would add cost and complexity with no user or business benefit. |
| 31 – 65 | ⚡ Hybrid | Partial migration recommended. Move specific components on-chain (payments, ownership, settlement) while keeping core infrastructure off-chain. |
| 66 – 100 | ✅ Migrate | Strong candidate. The product meaningfully benefits from Solana's ownership model, throughput, and/or cost structure. |

---

## Output Format

Always produce the score output in this exact structure:

```
Migration Readiness Score: [XX] / 100

[VERDICT EMOJI + VERDICT LABEL]

Scoring breakdown:
+ [Factor name]: [brief reason] ([points]/12)
+ [Factor name]: [brief reason] ([points]/12)
- [Factor name]: [brief reason — use - for low scores] ([points]/12)
[... all 8 factors]

Recommendation: [1–2 sentences. State the verdict and the single most
important reason for it.]

Estimated migration effort: [X–Y weeks/months]
Recommended approach: [Migrate / Hybrid with specific split / Don't Migrate]

Open questions: [List any factors scored 0 due to unknown info, not
confirmed weakness. These are things the user should resolve before
committing to a decision.]
```

---

## Worked Examples

Use these to calibrate scoring. If your output for a similar product
doesn't roughly match these, re-examine your factor scores.

---

### Example A — CRM for Dentists (Salesforce-based)

**Product:** Practice management SaaS. Appointment scheduling,
patient records, billing via Stripe. B2B. ~200 dental practices.

| Factor | Score | Reason |
|---|---|---|
| Digital asset ownership | 0 | No digital assets |
| Settlement trustlessness | 0 | B2B SaaS — trust is contractual |
| Secondary market potential | 0 | Patient records don't trade |
| Transaction volume/frequency | 2 | Low volume, not cost-sensitive |
| State change frequency | 0 | Patient data changes constantly |
| Decentralization requirement | 0 | Centralized control required (HIPAA) |
| Team migration capacity | 6 | Small team, short runway typical |
| User wallet readiness | 0 | Dentists are not crypto users |

**Raw: 8 / 96 → Normalized: 8 / 100**

```
Migration Readiness Score: 8 / 100

❌ Don't Migrate.

Blockchain provides no meaningful advantage for a dental practice
management system. Patient data changes constantly (wrong for on-chain),
trust is contractual between vendor and practice (no trustlessness need),
and HIPAA compliance makes permissionless access a liability not a feature.

Recommendation: Keep your current stack. If you want to accept crypto
payments, add a USDC payment option via a wallet adapter as a thin layer
on top of Stripe — do not migrate core infrastructure.

Confidence: Very High
```

---

### Example B — Ticketing Platform (StubHub Competitor)

**Product:** Event ticketing marketplace. Primary sales + secondary
resale. Currently: Next.js, Postgres, Stripe, centralized resale
with platform taking 25% fees. Problem: ticket fraud, scalping,
platform fee resentment.

| Factor | Score | Reason |
|---|---|---|
| Digital asset ownership | 12 | Tickets are digital assets that transfer |
| Settlement trustlessness | 10 | P2P resale without platform trust is core value prop |
| Secondary market potential | 12 | Secondary market IS the product |
| Transaction volume/frequency | 8 | High volume events, many transactions |
| State change frequency | 10 | Ticket state changes rarely (issued → transferred → redeemed) |
| Decentralization requirement | 8 | Permissionless resale is key differentiator |
| Team migration capacity | 8 | Assume funded startup, 3+ devs |
| User wallet readiness | 6 | Mixed — concert-goers not all crypto-native |

**Raw: 74 / 96 → Normalized: 77 / 100**

```
Migration Readiness Score: 77 / 100

✅ Strong candidate for Solana migration.

Tickets are digital assets with natural secondary markets. The core
problem (fraud, scalping, platform fee resentment) is exactly what
trustless on-chain ownership solves. Compressed NFTs via Metaplex make
mass-scale ticket issuance cheap. Royalty enforcement via transfer hooks
replaces platform fee extraction with protocol-level revenue.

Recommended approach: Hybrid.
- On-chain: Ticket issuance (cNFTs), ownership transfers, royalty enforcement
- Off-chain: Event metadata, seating maps, user accounts, email notifications

Open questions:
- Wallet onboarding strategy for non-crypto users (embedded wallets recommended)
- Jurisdiction-specific secondary market regulations

Estimated migration effort: 10–16 weeks
Confidence: High
```

---

### Example C — Gaming Platform with Tradeable In-Game Items

**Product:** Web-based RPG. Players earn weapons, armor, skins.
Currently: items stored in Postgres, no real ownership, no trading.
Considering Solana to add true ownership and a player-to-player
item marketplace.

| Factor | Score | Reason |
|---|---|---|
| Digital asset ownership | 12 | Items are digital assets — this is the whole request |
| Settlement trustlessness | 8 | P2P item trading without platform interference |
| Secondary market potential | 12 | Item marketplace is the intended feature |
| Transaction volume/frequency | 10 | Games generate high transaction volume |
| State change frequency | 6 | Item stats change in-game but ownership changes rarely |
| Decentralization requirement | 6 | Players want ownership guarantees, not full decentralization |
| Team migration capacity | 8 | Assume established game studio |
| User wallet readiness | 7 | Gaming audience increasingly crypto-familiar in 2026 |

**Raw: 69 / 96 → Normalized: 72 / 100**

```
Migration Readiness Score: 72 / 100

✅ Migrate — specifically for asset ownership layer.

True item ownership is a strong product differentiator for games.
Metaplex Core handles item NFTs efficiently. Jupiter provides
liquidity for item-to-token swaps. The key architectural decision:
keep gameplay state (item stats, player position, combat) off-chain
for speed, move ownership and trading on-chain only.

Recommended approach: Hybrid.
- On-chain: Item ownership (Metaplex Core NFTs), player-to-player trades,
  in-game currency (SPL Token)
- Off-chain: All gameplay state, item stat progression, matchmaking,
  analytics

Estimated migration effort: 12–20 weeks
Confidence: High
```

---

### Example D — B2B Payments SaaS (Stripe Competitor)

**Product:** Payment infrastructure for SMBs. Cross-border transfers,
multi-currency, invoicing. Stripe alternative targeting emerging
markets where Stripe fees are prohibitive.

| Factor | Score | Reason |
|---|---|---|
| Digital asset ownership | 4 | Stablecoins are digital assets but not owned in traditional sense |
| Settlement trustlessness | 10 | Cross-border settlement without correspondent banks is core value |
| Secondary market potential | 2 | Payments don't have secondary markets |
| Transaction volume/frequency | 12 | High volume is the entire value proposition |
| State change frequency | 8 | Settlement events are periodic, not continuous |
| Decentralization requirement | 7 | Permissionless access to global payments is the pitch |
| Team migration capacity | 8 | Assume funded fintech |
| User wallet readiness | 4 | SMB owners — not crypto-native, but USDC adoption growing |

**Raw: 55 / 96 → Normalized: 57 / 100**

```
Migration Readiness Score: 57 / 100

⚡ Hybrid recommended.

The high-volume cross-border settlement use case is a strong fit for
Solana's cost structure ($0.00025 vs Stripe's 2.9% + $0.30). USDC on
Solana with Token-2022 confidential transfers covers the compliance
angle. However: SMB users are not crypto-native, regulatory requirements
in target markets may mandate custodial solutions, and full decentralization
may create compliance exposure rather than removing it.

Recommended approach: Hybrid.
- On-chain: Settlement layer (USDC transfers, treasury management)
- Off-chain: User accounts, invoicing UI, KYC/AML, fiat on/off ramp,
  customer support

Do NOT replace your entire Stripe integration on day one. Run parallel
settlement rails and migrate volume progressively as you validate
regulatory compliance in each market.

Open questions:
- Regulatory status of USDC payments in target markets
- Custodial vs non-custodial wallet strategy for SMB users
- Fiat on/off ramp partnerships

Estimated migration effort: 16–24 weeks (compliance-gated)
Confidence: Medium — regulatory factors dominate this decision
```

---

## Edge Cases and Hard Rules

**Always Don't Migrate if:**
- Product stores health, legal, or financial records subject to data
  sovereignty laws (HIPAA, GDPR strict mode) that conflict with
  public ledger transparency
- State changes more than once per minute per user as a core feature
- User base is exclusively non-technical enterprise (procurement,
  legal, HR tooling) with no crypto exposure
- Solo founder, < 6 weeks runway, first product

**Always flag for legal review if:**
- Product involves securities, lending, or yield — regardless of score
- Product targets US retail users with token incentives
- Score is 31–65 (Hybrid) and payments are involved

**Hybrid almost always means:**
- Keep: database, auth, file storage, analytics, email, existing APIs
- Move: ownership records, settlement events, token balances, royalties
- Never move: real-time state, user preferences, session data, logs

---

## Confidence Level Guide

Always attach a confidence level to the verdict:

| Confidence | When to use |
|---|---|
| **Very High** | All 8 factors are clearly scoreable, verdict is unambiguous (score < 25 or > 75) |
| **High** | 7/8 factors clear, verdict band is obvious |
| **Medium** | 1–2 factors unclear or score is 45–65 (genuinely borderline) |
| **Low** | Multiple factors unknown, or legal/regulatory issues dominate |

When confidence is Medium or Low, explicitly list what information
would change the verdict and ask the user if they can provide it.

---

## Routing After This Module

| Verdict | Next step |
|---|---|
| ❌ Don't Migrate | Output complete. Ask if user wants to explore partial crypto integration as an add-on only. Do not load further modules unless asked. |
| ⚡ Hybrid | Load skill/03-architecture-delta.md. Focus delta on the specific components worth migrating. |
| ✅ Migrate | Load skill/03-architecture-delta.md for full stack mapping. |

For Ethereum/EVM products specifically (any score):
→ Also load skill/05-eth-to-sol.md alongside the delta report.