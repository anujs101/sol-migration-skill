---
name: assess-migration
description: Run full 3-phase Solana migration assessment — discovery, suitability scoring, architecture delta, and decision cards
---

# /assess-migration

Trigger: User runs `/assess-migration` [optional: brief description of their product]

## Behavior

1. Load skill/01-discovery.md — begin structured intake (Q0–Q5, one at a time)
2. After Q5: load skill/02-suitability.md — score all 8 factors, produce verdict
3. If verdict is Don't Migrate: output reasoning + exit. Do not proceed.
4. If Migrate or Hybrid:
   - Load skill/03-architecture-delta.md — produce delta report
   - Load skill/04-decision-cards.md — produce cards for each key decision
5. If user mentioned Ethereum, EVM, Solidity, Hardhat, or any ERC standard:
   - Also load skill/05-eth-to-sol.md — append ETH overlay to delta
6. Compile full output as migration.md artifact

## Output Format

Single artifact in this order:
1. Migration Readiness Score + breakdown
2. Verdict (✅ / ⚡ / ❌) + reasoning
3. Architecture Delta Report (if Migrate or Hybrid)
4. Decision Cards (if Migrate or Hybrid)
5. ETH → SOL overlay (if applicable)

## Hard Rules

- Never skip discovery (Phase 1) even if the user provides their full stack upfront
- One question at a time during discovery
- Don't Migrate verdict exits here — do not push into Phase 2