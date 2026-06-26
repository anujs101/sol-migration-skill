# Discovery Module

> Load this file when the user opens with a vague statement, when they
> say "should I migrate?", or when you don't yet have enough context to
> score the 8 suitability factors. Run this BEFORE loading 02-suitability.md.
>
> Goal: collect enough information across 6 questions to score all 8
> suitability factors accurately. Do not skip to scoring until Q0–Q5
> are answered.

---

## The 6-Question Intake Flow

Questions are asked one at a time. Never combine. Never list them.
Wait for the user's full answer before asking the next question.

After Q0, read the answer carefully and identify the product domain
before proceeding. The domain determines how Q1–Q4 are worded.

---

### Q0 — The Opener (Fixed, Always Identical)

Ask this exact question regardless of what the user has said so far:

> "What does your product do, and what's making you consider Solana?"

**What you're listening for:**
- Product domain (ticketing, gaming, payments, SaaS, DeFi, marketplace, etc.)
- Motivation (performance, cost, ownership, "heard it's good", investor pressure, competitor doing it)
- Whether they already have a live product or are pre-launch
- Any signals about user type (B2B vs B2C, crypto-native vs Web2)

**Motivation signals and what they mean:**

| User says... | Signal | Note |
|---|---|---|
| "We need true ownership for users" | Strong YES signal | Factor 1 + 2 likely high |
| "Stripe fees are killing us" | Possible YES (payments) | Score carefully — regulatory risk |
| "Our investors want blockchain" | Weak signal | Don't Migrate likely unless product fits |
| "Competitors are doing it" | Weak signal | Probe further — may not fit |
| "We need to be decentralized" | Strong YES signal | Factor 6 high |
| "We want to add NFTs" | Moderate signal | Depends on product fit |
| "We process a lot of transactions" | Moderate YES signal | Factor 4 likely high |
| "I just think blockchain is cool" | Red flag | Likely Don't Migrate |

After Q0, internally map the product to one of these domain archetypes
to guide tailoring of Q1–Q4:

- **Marketplace** (goods, tickets, collectibles, NFTs trading)
- **Gaming** (in-game items, player progression, economies)
- **Payments / Fintech** (transfers, settlements, cross-border)
- **Identity / Access** (credentials, memberships, loyalty)
- **SaaS** (B2B tools, dashboards, CRMs, productivity)
- **DeFi / Protocol** (swaps, lending, staking, yield)
- **Unknown** (use generic framing below)

---

### Q1 — Current Stack

**Purpose:** Understand migration complexity and effort. Feeds Factor 7
(team capacity) and sets up the architecture delta later.

**Generic framing:**
> "What does your current tech stack look like? For example — what are
> you using for your backend, database, auth, and payments today?"

**Tailored framing by domain:**

| Domain | Ask instead |
|---|---|
| Marketplace | "What's your current stack? Specifically how do you handle listings, payments, and user accounts today?" |
| Gaming | "What does your current game backend look like — how do you store player data, handle purchases, and manage game state?" |
| Payments / Fintech | "What's your current payment infrastructure — which providers, currencies, and settlement methods are you using today?" |
| Identity / Access | "How do you currently handle user identity, credentials, or membership verification?" |
| SaaS | "What's your tech stack? Backend, database, auth, billing — what are you running today?" |
| DeFi / Protocol | "Are you already on another chain, or is this a new protocol? What's your current implementation?" |

**What you're listening for:**
- Specific technologies (Next.js, Postgres, Stripe, Firebase, AWS, etc.)
- Complexity of existing system (monolith vs microservices, team size implied)
- Any existing blockchain components
- Signs of technical debt or constraints

**Factor mapping:** Informs Factor 7 (migration capacity) and will
directly feed the Architecture Delta in Phase 2.

---

### Q2 — The Asset Question

**Purpose:** Determine whether digital assets exist or could exist in
this product. Feeds Factors 1 (ownership) and 3 (secondary market).

**Generic framing:**
> "What do users get or earn in your product — is there anything they
> own, collect, or could potentially sell or transfer to others?"

**Tailored framing by domain:**

| Domain | Ask instead |
|---|---|
| Marketplace | "What are users buying and selling on your platform — physical goods, digital items, tickets, something else? Can they currently resell to each other?" |
| Gaming | "Do players currently own their in-game items, characters, or currency — or are those locked to your platform? Can they trade with other players?" |
| Payments / Fintech | "Are users moving money between each other, or is it always user-to-business? Is there any asset they accumulate or hold?" |
| Identity / Access | "What does a user get when they verify their identity or earn a credential — is it something they could share, transfer, or prove to a third party?" |
| SaaS | "Is there anything in your product that a user would consider 'theirs' — data exports, reports, credits, entitlements?" |
| DeFi / Protocol | "What assets does the protocol handle — tokens, LP positions, yield? Who controls them?" |

**What you're listening for:**
- Clear YES: tickets, items, collectibles, tokens, credentials, memberships
- Clear NO: pure data products, service subscriptions with no transferable value
- Secondary market potential: "can they sell/trade it?" is the key question
- Whether ownership is already a pain point for users

**Factor mapping:**
- Clear owned assets → Factor 1: 8–12
- No assets → Factor 1: 0–2
- Natural secondary market → Factor 3: 8–12
- No secondary market makes sense → Factor 3: 0–2

---

### Q3 — The Trust Question

**Purpose:** Determine whether trustless settlement is a genuine
product need. Feeds Factors 2 (trustlessness) and 6 (decentralization).

**Generic framing:**
> "When your users transact with each other — or with you — who do they
> have to trust today? Is that trust ever a problem or a friction point?"

**Tailored framing by domain:**

| Domain | Ask instead |
|---|---|
| Marketplace | "When a buyer pays a seller on your platform, who holds the money in between? Do users ever complain about platform fees or dispute resolution?" |
| Gaming | "When players trade items or earn rewards, who controls whether that transaction happens? Can you as the platform reverse it or take a cut?" |
| Payments / Fintech | "Who settles the transactions — do you hold funds in escrow, or does a bank/payment processor sit in the middle? What's the failure mode if that intermediary fails?" |
| Identity / Access | "When someone presents a credential from your platform, does the verifying party have to trust you specifically — or is there a way to verify it independently?" |
| SaaS | "Do your customers have to trust you with their data or funds in a way that creates friction — compliance audits, vendor lock-in concerns, escrow disputes?" |
| DeFi / Protocol | "Is the protocol currently custodial or non-custodial? Who controls the keys?" |

**What you're listening for:**
- Platform as intermediary holding funds → strong trustlessness signal
- User complaints about platform fees/control → strong signal
- "We hold the money until..." → escrow use case
- "Users just trust us" with no friction → weak signal
- Regulatory requirement for central control → negative signal

**Factor mapping:**
- Core flow requires trustless settlement → Factor 2: 10–12
- Some flows benefit → Factor 2: 5–8
- Trust is fine / contractual → Factor 2: 0–3
- Decentralization demanded by users → Factor 6: 8–12
- Centralized control acceptable → Factor 6: 1–4

---

### Q4 — The Scale Question

**Purpose:** Understand transaction volume, frequency, and state change
patterns. Feeds Factors 4 (volume) and 5 (state change frequency).

**Generic framing:**
> "How often do transactions or meaningful state changes happen in your
> product — and roughly how many users or events per day are we talking about?"

**Tailored framing by domain:**

| Domain | Ask instead |
|---|---|
| Marketplace | "How many listings go live and how many purchases happen per day on average? During peak events — like a concert sale — what does volume look like?" |
| Gaming | "How many players are active daily, and how often does game state change — is it every second during gameplay, or at checkpoints like level completion?" |
| Payments / Fintech | "How many transactions do you process per day, and what's the average value? Is volume consistent or are there spikes?" |
| Identity / Access | "How often are credentials issued or verified — is this a one-time event per user, or something that happens repeatedly?" |
| SaaS | "How often does the core data in your product change — is it users actively editing data all day, or periodic updates like daily reports?" |
| DeFi / Protocol | "What's your expected TPS at launch and at scale? Is state updated on every trade or periodically?" |

**What you're listening for:**
- High volume + cost sensitivity → strong YES (Factor 4: 10–12)
- Low volume + not cost-sensitive → weak YES (Factor 4: 0–3)
- State changes every second → on-chain is wrong (Factor 5: 0–2)
- State changes at events/milestones → on-chain is right (Factor 5: 10–12)
- "During peak events" → interesting for burst capacity argument

**Factor mapping:**
- 1000+ daily transactions, cost-sensitive → Factor 4: 10–12
- Hundreds of daily transactions → Factor 4: 6–8
- Dozens or fewer → Factor 4: 0–4
- State changes per-second → Factor 5: 0–2 (inverse)
- State changes per-event → Factor 5: 8–12

---

### Q5 — Team and Timeline

**Purpose:** Assess migration capacity and user wallet readiness.
Feeds Factors 7 (capacity) and 8 (wallet readiness). This question
is roughly the same across all domains.

> "Last question: how many developers do you have working on this,
> what's your runway or timeline for this migration, and are your
> current users already familiar with crypto wallets — or would
> this be new for them?"

**What you're listening for:**

*Team signals:*
- 3+ devs + 6 months runway → Factor 7: 10–12
- 2 devs + 3 months → Factor 7: 6–8
- 1 dev + 6 weeks → Factor 7: 1–3
- "We're pre-team" → Factor 7: 0

*Wallet readiness signals:*
- "Our users are already on Phantom/Solflare" → Factor 8: 12
- "They're in crypto but not Solana specifically" → Factor 8: 8
- "Some are, some aren't" → Factor 8: 5
- "They're mostly Web2 users" → Factor 8: 2
- "Enterprise / regulated users" → Factor 8: 0

**Wallet readiness context (2026):**
Embedded wallets (Privy, Dynamic, Turnkey) and passkey signers have
significantly reduced wallet friction vs 2023. Factor this in — a
"Web2 users" answer today is less severe than it would have been two
years ago, but still a real consideration. Score conservatively.

---

## After Q5 — Inference Pass Before Scoring

Before loading 02-suitability.md, do a quick internal inference pass.
Fill in any factors that can be inferred from context without asking
another question:

| If you know... | You can infer... |
|---|---|
| Product is B2B enterprise SaaS | Factor 6 (decentralization): likely 0–2 |
| Product involves health/legal records | Hard rule: flag regulatory blocker |
| User said "we process payments across borders" | Factor 2 (trustlessness): likely 8+ |
| User mentioned "we already have NFTs on Ethereum" | Load 05-eth-to-sol.md after scoring |
| User said "I just started building this" | Factor 7 (capacity): adjust down — no existing system to migrate |
| Stack is entirely Firebase/Google | Factor 5 (state change): likely high-frequency — probe before scoring |
| User mentioned securities, lending, yield | Flag for legal review regardless of score |

If a factor genuinely cannot be inferred or scored from Q0–Q5 answers,
score it 0 and list it as an open question in the output. Do not ask
a 7th question — proceed to scoring with the open question flagged.

---

## Hard Stops — Ask No More Questions If:

These situations are scoreable immediately after Q0. Do not run the
full intake if any of these apply:

**Immediate Don't Migrate signals (stop after Q0, score and exit):**
- Product is a CRM, HR tool, or internal enterprise dashboard with
  no financial or ownership component
- User explicitly says "we store patient records / medical data"
- User says "I just think blockchain is cool" with no product fit signal
- User has no product yet ("I have an idea") — advise them to validate
  the idea first, then return for migration assessment

**Immediate Migrate signals (still run full intake, but signal is strong):**
- "We run a secondary market for [anything]"
- "We need royalties enforced automatically"
- "We process cross-border payments and fees are killing us"
- "We want players to truly own their items"

---

## Transition to Scoring

After Q5 (or after an early exit inference), say:

> "Thanks — I have what I need. Let me score this against Solana's
> strengths and give you a Migration Readiness assessment."

Then load **02-suitability.md** and score all 8 factors using the
answers collected. Map each answer to its factor using the factor
mapping notes above.

Do not show the user the factor-by-factor scoring process.
Show only the final output format defined in 02-suitability.md.

---

## Full Flow Summary

```
User opens conversation
        │
        ▼
Q0: "What does your product do and why Solana?"
        │
        ├── Hard stop signal detected? → Score immediately → Exit or continue
        │
        ▼
Read domain archetype from answer
        │
        ▼
Q1: Current stack (tailored framing)
        │
        ▼
Q2: Asset question (tailored framing)
        │
        ▼
Q3: Trust question (tailored framing)
        │
        ▼
Q4: Scale question (tailored framing)
        │
        ▼
Q5: Team + timeline + wallet readiness (generic)
        │
        ▼
Inference pass — fill gaps without asking more
        │
        ▼
"Thanks — I have what I need."
        │
        ▼
Load 02-suitability.md → Score → Output verdict
```