---
name: sol-migration
description: Use when a founder or engineer asks whether to migrate an existing
  product to Solana, how to map their current stack to Solana equivalents, or
  wants a structured migration blueprint. Covers suitability scoring, architecture
  delta reports, decision cards, and Ethereum-to-Solana migration paths. The
  skill can also recommend NOT migrating when blockchain provides no advantage.
user-invocable: true
license: MIT
compatibility: Works with any Claude Code session. Context7 MCP optional.
metadata:
  version: 1.0.0
---

# Solana Migration Assessment Skill

Entry point for sol-migration-skill. Routes to focused modules.
Never load all modules at once.

## What This Skill Does

Answers three questions in sequence:
1. Should we migrate to Solana at all? (Phase 1 — always first)
2. What does our migration look like? (Phase 2 — only if warranted)
3. Why each decision, with alternatives. (Phase 3 — alongside Phase 2)

The skill's most important output is sometimes "don't migrate."

## Module Map

| Task                                    | Module                       |
|-----------------------------------------|------------------------------|
| Understand the user's app + goals       | 01-discovery.md              |
| Migration Readiness Score + verdict     | 02-suitability.md            |
| Architecture Delta Report               | 03-architecture-delta.md     |
| Decision cards with confidence levels   | 04-decision-cards.md         |
| Ethereum / EVM → Solana specifically    | 05-eth-to-sol.md             |

## Out of Scope → Route to Kit

- Writing Anchor code → solana-dev-skill
- Security audits → solana-auditor-skill
- DeFi positions → position-manager-skill
- Legal/compliance → crypto-legal-skill

## Context7 MCP

Optional. When available, fetch live docs for decision card confidence levels.
Modules that benefit: 04-decision-cards.md (highest), 05-eth-to-sol.md,
03-architecture-delta.md.