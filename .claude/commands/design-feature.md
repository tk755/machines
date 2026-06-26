---
description: Create feature specs collaboratively
---

## Execution Process

For each phase, print the phase name and emoji, then execute the steps in order.

## 🔍 Phase 1: Contextualization

- Use an Explore agent to analyze the current codebase and understand what exists.
- Contextualize the user's feature request within the existing codebase: $ARGUMENTS

## 🛠️ Phase 2: Collaborative Refinement

Iterate on an implementation plan through theory-first collaborative dialogue with the user:
- Discuss high-level architecture before implementation details.
- Identify problems before proposing solutions.
- Present multiple approaches with trade-offs.
- Ask clarifying questions about ambiguous requirements and solution constraints.
- Use the Grep, Read, and Glob tools to refer to existing code and documentation.
- Think after each user response to discover new follow-up questions.

**Always Ask About:**
- **Multiple solution approaches**: "make a backup system" has dozens of implementations - ask about constraints, storage, scope, retention
- **Ambiguous requirements**: even if the user doesn't realize they're ambiguous - probe for the complete mental model
- **Missing requirements**: when implementation needs decisions not specified
- **Conflicting requirements**: when specifications contradict each other
- **Multi-file changes not discussed upfront**: if implementation scope grows beyond initial discussion
- **Purpose-unclear technical choices**: hash vs random vs uuid - ask about the underlying need
- **Enhancement/convenience dependencies**: tqdm, rich output, specialized libraries - even if safe

**Never Ask About:**
- **Anything covered in style guides**: naming, formatting, structure patterns, error handling approach
- **Functional dependency necessities**: pandas for CSV, requests for HTTP, pathlib for files, numpy, pytorch
- **Single-file focused changes** when scope matches expectations
- **Technical implementation details** when requirements and approach are clear

## 🧠 Phase 3: Deep Validation

Initiate **ultrathink** to enable deep-thinking exhaustive analysis:
- Consider every possible scenario where the refined approach could fail.
- Check for missing specifications, edge cases, and implementation flaws.
- Verify approach against current documentation to ensure nothing is outdated.
- Analyze whether the solution will actually work for both simple and complex cases.
- If validation finds issues, return to Phase 2 with specific problems identified.

## 🎯 Phase 4: User Validation

Present the validated implementation specification to the user in a well-structured format for approval:
- If approved by the user, proceed to Phase 5 for final specification generation.
- If changes are suggested by the user, return to Phase 2 for more iterative refinement.
DO NOT PROCEED TO PHASE 5 WITHOUT USER APPROVAL.

## 📐 Phase 5: Specification Generation 

Synthesize all dialogue reasoning and validation insights into comprehensive developer-ready implementation specification:
- Preserve decision lineage with alternatives considered and trade-offs made during refinement.
- Create actionable implementation guidance with specific steps adapted to this codebase.
- Document implementation challenges, edge cases, and integration context from validation.
- Write complete specification to ./.claude/features/[FEATURE-NAME].md with preserved reasoning and context.
