# Discovery Module

> Load this file when the user opens with a vague statement, when they
> say "should I migrate?", or when you don't yet have enough context to
> score the 8 suitability factors. Run this BEFORE loading 02-suitability.md.
>
> Goal: collect enough information across 6 questions to score all 8
> suitability factors accurately. Do not skip to scoring until Q0–Q5
> are answered.
>
> If running in an environment with filesystem access (e.g. Claude Code
> inside a project directory), this module includes an optional silent
> codebase scan between Q0 and Q1 — see "Codebase Scan" below. This is
> an enhancement, not a dependency: the module works identically without
> it, falling back to fully conversational discovery.

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

## Codebase Scan (Optional — Run Silently Between Q0 and Q1)

If this skill is running inside Claude Code with filesystem access, and a
real project exists in the current working directory (or one level below),
attempt a lightweight static scan before asking Q1. This makes Q1 a
confirmation instead of a cold question. If no project is detected, or the
scan finds nothing useful, skip this step entirely and fall through to the
original Q1 framing below — do not mention the attempt either way.

**This step is silent.** Do not announce "let me check your files first"
as a separate beat. Fold the result directly into how Q1 is phrased.

### What to look for

- Dependency manifests: `package.json`, `requirements.txt`, `go.mod`,
  `Cargo.toml`, `composer.json`, `Gemfile`
- README content, if present
- Schema/migration files: Prisma schema, SQL migration files, `models/`
  directory structure
- Config file *names* only — e.g. note that `.env.example` exists and
  list its key names, never its values
- Existing Solana/web3 dependencies, if any (changes framing — see below)

### Hard boundary — denylist, not judgment call

**Never read or open:**
- `.env`, `.env.local`, or any non-example env file
- `*.pem`, `*.key`, `*secret*`, `*credential*`, any filename pattern
  suggesting credentials
- Database contents (rows/records) — schema structure only, never data
- `.git` history, diffs, or commit logs unless the user explicitly asks
  for that context

**Never execute:**
- Do not run the application, start a server, or execute any script
  during this step. Static file inspection only.

If a denylisted file would need to be read to answer something, do not
read it — ask the user directly instead.

### Using the scan result

Build a short draft stack summary from what you found. Treat it as a
hypothesis, not a fact — code can be stale, half-migrated, or contain
abandoned integrations. Open Q1 with the draft and an explicit invitation
to correct it (see the revised Q1 framing below).

If the scan surfaces something that contradicts the Q0 answer — e.g. the
user described a marketplace but the schema shows no listing/transaction
tables — do not state this as a correction. Raise it as an open question
instead: "I don't see [X] in the schema yet — is that still being built,
or did I miss it?" Never imply the user described their own product
incorrectly.

---

### Q1 — Current Stack

**Purpose:** Understand migration complexity and effort. Feeds Factor 7
(team capacity) and sets up the architecture delta later.

**If the codebase scan above found something useful, lead with it as
confirmation instead of asking cold:**

> "Before I ask — I can see this is a [stack inferred from manifest/schema],
> with [notable schema tables/structures if found]. Is that the full
> picture, or is there more I wouldn't catch from dependencies alone —
> especially around auth and payments, since those are sometimes handled
> by services with no SDK installed?"

Always include the auth/payments caveat when leading with a scan result —
those are the categories most likely to be invisible to a static scan
(webhook-only integrations, server-side-only SDKs, etc.).

**If no scan result is available, use the original cold framing:**

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

**If the codebase scan found ownership-shaped schema** (e.g. tables with
fields like `owner_id`, `transfer`, `listing`, `inventory_item`), open
with that observation, then still ask the real question — schema shape
shows what's technically possible, not what users actually want:

> "I notice your schema has [observation, e.g. a `listings` table with
> a `seller_id` field] — that suggests some ownership/transfer model
> already exists. [Then continue into the question below.]"

This is context, not a substitute for the question. Business intent
can't be read from a schema.

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

**Factor mapping (use exact buckets from 02-suitability.md — 12/8/4/0 only):**
- Core product IS ownership → Factor 1: 12
- Ownership is a significant feature, not core → Factor 1: 8
- Ownership is minor/planned → Factor 1: 4
- No assets → Factor 1: 0
- Secondary market is core to the product → Factor 3: 12
- Secondary market is a natural extension → Factor 3: 8
- Secondary market possible but not a priority → Factor 3: 4
- No secondary market makes sense → Factor 3: 0

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

**Factor mapping (exact buckets from 02-suitability.md):**
- Core flow requires trustless settlement → Factor 2: 12
- Some flows benefit, most don't → Factor 2: 7
- Trust is fine / contractual → Factor 2: 0–3 (use 3 if explicitly acceptable, 0 if purely internal B2B)
- Decentralization is a core requirement → Factor 6: 12
- Decentralization is a strong differentiator → Factor 6: 8
- Decentralization appealing but not required → Factor 6: 4
- Centralized control fine, no demand → Factor 6: 1
- Centralization legally required → Factor 6: 0

---

### Q4 — The Scale Question

**Purpose:** Understand transaction volume, frequency, and state change
patterns. Feeds Factors 4 (volume) and 5 (state change frequency).

**If the codebase scan found cron jobs, queue configs, or relevant DB
indices**, mention them as color before asking, but still ask — code
structure hints at cadence, it doesn't give you real numbers:

> "I see [observation, e.g. a background job that processes orders
> hourly] — does that match your actual transaction pattern, or is
> real volume bursty/different from what the code suggests?"

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

**Factor mapping (exact buckets from 02-suitability.md):**
- High volume, high frequency (1000+ daily, microtransactions, real-time) → Factor 4: 12
- Medium volume (hundreds daily, periodic settlements) → Factor 4: 8
- Low volume but cost-sensitive (cross-border, B2B settlements) → Factor 4: 6
- Low volume, not cost-sensitive → Factor 4: 2
- Rarely transacts (monthly or less) → Factor 4: 0
- State changes rarely (ownership/settlement/milestone events) → Factor 5: 12 (inverse factor)
- State changes periodically (daily/batch) → Factor 5: 8
- State changes frequently (hourly/per session) → Factor 5: 4
- State changes constantly (every action, real-time) → Factor 5: 0

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
- Core product is real-time/live state at sub-minute granularity
  (live chat, real-time analytics dashboards, live collaborative editing) —
  this matches 02-suitability.md's hard rule that >1 state change/minute/user
  is an automatic Don't Migrate; no need to run full intake to confirm it

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
[Silent] Codebase scan if project files present in cwd
   (manifest, schema, README — denylist applies, never announced)
        │
        ▼
Q1: Current stack (confirmation if scan succeeded, else cold framing)
        │
        ▼
Q2: Asset question (tailored framing, scan evidence if available)
        │
        ▼
Q3: Trust question (tailored framing — no scan signal applies here)
        │
        ▼
Q4: Scale question (tailored framing, scan evidence if available)
        │
        ▼
Q5: Team + timeline + wallet readiness (generic — no scan signal applies here)
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