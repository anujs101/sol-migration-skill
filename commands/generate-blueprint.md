---
name: generate-blueprint
description: Generate Architecture Delta Report and Decision Cards — skips suitability assessment, assumes migration decision is already made
---

# /generate-blueprint

Trigger: User runs `/generate-blueprint` [optional: brief stack description]

## When to Use

User already knows they want to migrate to Solana and explicitly wants to skip
the suitability phase. Use this when:
- Suitability was assessed in a previous session
- User is an experienced Solana builder who needs the blueprint only
- User explicitly says "skip the assessment, just give me the architecture"

Do NOT use this as a shortcut around discovery. If the user is uncertain
whether to migrate, route to /assess-migration instead.

## Behavior

1. If running with filesystem access and a project exists in the current
   directory: silently scan dependency manifests, schema/migration files,
   and README for stack signals (same denylist as 01-discovery.md's
   Codebase Scan — never read `.env`, secrets, credentials, or DB contents;
   never execute anything). Do not announce this scan separately.
2. If no stack info provided:
   - If the scan above found something: ask once, as confirmation —
     "I can see this is a [stack inferred from scan] — is that accurate,
     and is there anything missing, especially auth/payments?"
   - If the scan found nothing or filesystem access isn't available:
     ask once — "What's your current stack?"
   Wait for answer either way. Do not ask more than one question.
3. Load skill/03-architecture-delta.md — produce delta report
4. Load skill/04-decision-cards.md — produce decision cards for each key decision
5. If user mentions Ethereum, EVM, Solidity, Hardhat, or any ERC standard:
   also load skill/05-eth-to-sol.md — append ETH overlay to delta
6. Compile output as migration.md artifact

## Output Format

Single artifact in this order:
1. Architecture Delta Report
2. Decision Cards
3. ETH → SOL overlay (if applicable)

## Hard Rules

- Skip suitability scoring — this command assumes Migrate or Hybrid verdict
- One question maximum if stack is unknown
- Do not generate code — route to solana-dev-skill for implementation