# sol-migration-skill

**A Solana AI Kit skill that tells you whether to migrate — and sometimes tells you not to.**

> Give me your current stack and your reason for considering Solana. You get a Migration Readiness Score, a clear recommendation, and — if warranted — a production-ready Architecture Delta and decision-by-decision rationale.

---

## The Problem

Most AI agents, when asked "should I migrate to Solana?", immediately start generating Anchor code. They skip the most expensive decision layer entirely:

- Should we move to Solana at all?
- Which parts of our product belong on-chain?
- What stays off-chain?
- What does the migration actually look like?
- How long will it take and what are the real risks?

This skill addresses that decision layer systematically — before a single line of code is written.

---

## What It Produces

### Phase 1 — Migration Readiness Score

A structured discovery conversation (one question at a time) followed by a scored verdict:

```
Migration Readiness Score: 82 / 100

✅ Strong candidate for Solana migration.

Scoring breakdown:
+ Ownership model: Strong (digital assets with transferability needs)
+ Trust requirements: High (escrow, royalties)
+ Transaction frequency: Moderate
- Compliance readiness: Weak (no wallet UX in current product)
- Team Solana experience: Low

Estimated migration effort: 6–10 weeks
Recommended approach: Hybrid (keep Postgres, move ownership + payments on-chain)
```

The skill can also tell you not to migrate — and that's a complete, valuable output:

```
Migration Readiness Score: 18 / 100

❌ Do NOT migrate.

Your CRM SaaS derives no meaningful benefit from blockchain.
Blockchain would add: wallet friction, higher complexity, regulatory surface.
Stripe is the correct payment layer for your use case.
```

**Codebase-aware discovery.** This skill runs inside Claude Code, where the
typical session has an actual project open — not a blank chat. When that's
the case, discovery silently checks your project's dependency manifest,
schema, and README before asking about your stack, then opens that
question as a confirmation instead of a cold ask:

> "I can see this is a Next.js app using Supabase and Stripe, with a
> Postgres schema that has `users`, `orders`, and `tickets` tables — is
> that the full picture, or is there more I wouldn't catch from
> dependencies alone, especially around auth and payments?"

This doesn't reduce the number of questions asked — discovery is still
six questions, always. What it changes is speed and accuracy on the
question code can actually answer. Business-context questions (whether
trust is a pain point, team capacity, wallet readiness) stay fully
conversational, because no codebase can answer those. The scan never
reads `.env` files, secrets, credentials, or database contents, and
never executes anything — static inspection only, and every result is
offered as something to confirm, never asserted as fact. Falls back to
fully conversational discovery automatically if no project is present.

### Phase 2 — Architecture Delta Report

A structured, scannable table mapping your current stack to its Solana target — what moves on-chain, what stays off-chain, what gets removed, what's new, and what the real risks are. Built to hand to an engineering team.

### Phase 3 — Decision Cards

One card per significant architectural decision. Each card names the alternative, explains why it was rejected, and assigns a confidence level. Teaches migration judgment, not just stack translation.

### Bonus — Ethereum → Solana Path

A dedicated module for EVM teams. Full concept mapping (ERC-20 → SPL, Hardhat → Anchor, Ethers.js → `@solana/kit`, etc.), 10 mental model corrections that cause production bugs, and an ETH-specific delta overlay.

---

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/sol-migration-skill
cd sol-migration-skill
chmod +x install.sh
./install.sh
```

Restart Claude Code. That's it.

---

## Usage

**Full assessment (recommended):**
```
/assess-migration
```
Runs all three phases in sequence. Start here if you're not sure whether to migrate.

**Blueprint only (skip suitability):**
```
/generate-blueprint
```
Jumps straight to Architecture Delta + Decision Cards. Use this if you've already decided to migrate.

**Or just ask:**
```
I have a ticketing platform built on Next.js and Stripe. Should I move to Solana?
```
The skill runs discovery and produces a scored recommendation automatically.

---

## Context7 MCP (Optional)

When the [Context7 MCP server](https://context7.com) is available in your environment, this skill automatically fetches live documentation before generating technology recommendations. This keeps decision card confidence levels accurate as the Solana ecosystem evolves.

Without Context7, the skill falls back to its pinned Q2 2026 knowledge base and flags affected recommendations with a staleness disclaimer.

To enable: install Context7 and ensure `mcp__context7` is available in your Claude Code environment.

---

## What Makes This Different

- **Only skill that recommends against Solana when appropriate** — builds trust, not hype
- **Migration Readiness Score** — quantified, scannable, shareable signal
- **Codebase-aware discovery** — confirms your stack instead of asking cold, when run inside an actual project
- **Architecture Delta Report** — artifact a CTO can hand to their engineering team
- **Decision cards with confidence levels** — teaches judgment, not just stack translation
- **Dedicated Ethereum migration path** — addresses the largest pool of evaluating teams
- **Category-level mapping** — handles arbitrary Web2 stacks gracefully
- **Context7 integration** — decision cards grounded in live docs, not static training data

---

## Skill Structure

```
sol-migration-skill/
├── CLAUDE.md                       ← Agent identity + routing
├── skill/
│   ├── SKILL.md                    ← Entry point, module routing
│   ├── 01-discovery.md             ← Structured intake (6 questions, codebase-aware)
│   ├── 02-suitability.md           ← Migration Readiness Score engine
│   ├── 03-architecture-delta.md    ← Delta report generator
│   ├── 04-decision-cards.md        ← 10 pre-built cards + generation logic
│   └── 05-eth-to-sol.md            ← Ethereum → Solana dedicated path
├── agents/
│   └── migration-advisor.md        ← Full assessment agent (Opus)
├── commands/
│   ├── assess-migration.md         ← /assess-migration
│   └── generate-blueprint.md       ← /generate-blueprint
└── rules/                          ← Reserved for future path-scoped rules.
                                       Currently unused.
```

---

## Part of the Solana AI Kit

This skill routes out-of-scope requests to other kit skills:

- Writing Anchor programs → `solana-dev-skill`
- Security audits → `solana-auditor-skill`
- DeFi positions → `position-manager-skill`
- Legal / compliance → `crypto-legal-skill`

---

## License

MIT