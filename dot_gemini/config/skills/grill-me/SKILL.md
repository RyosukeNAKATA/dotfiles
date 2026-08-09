---
name: grill-me
description: >-
  Conduct an interactive, deep-dive interview with the user to refine requirements,
  architectural decisions, edge cases, and design trade-offs before implementation.
  Use this skill when the user asks to be "grilled", wants to refine a plan, or invokes /grill-me.
---

# Grill-Me (Interactive Alignment & Interview Workflow)

Use this skill to rigorously test assumptions, surface edge cases, and align on technical decisions with the user through an interactive, multi-turn interview.

## Objectives
- Uncover hidden requirements, unstated assumptions, and ambiguous specs.
- Identify edge cases, failure modes, scalability issues, and UX nuances.
- Force explicit choices on trade-offs (e.g., performance vs. maintainability, convenience vs. security).
- Produce a crystal-clear, finalized specification or implementation plan upon conclusion.

---

## Interview Execution Guidelines

### 1. Preparation & Scope Analysis
Before starting the interview:
- Analyze the user's initial prompt, plan, or codebase context.
- Identify missing details across these dimensions:
  - **Functionality**: Core behavior, expected inputs/outputs, validation.
  - **Edge Cases**: Empty states, invalid data, boundary limits, race conditions.
  - **Architecture & Design**: API contracts, state management, file structure, dependencies.
  - **User Experience (UX)**: UI flow, error messaging, responsiveness.
  - **Operations & Safety**: Backward compatibility, testing strategy, rollback plan.

### 2. Conducting the Interview
- **Incremental Questioning**: Ask 1–3 focused questions per turn. Never overwhelm the user with a massive list of questions at once.
- **Provide Options & Guidance**: When asking open-ended questions, offer 2–3 plausible solutions or trade-off choices to make answering easier.
- **Challenge Assumptions**: Respectfully push back on contradictory, overly complex, or underspecified requirements.
- **Adapt Dynamically**: Follow up on the user's answers. Adjust subsequent questions based on new information.

### 3. Concluding the Session
Once all critical details are resolved:
1. Summarize the agreed-upon requirements and decisions in a structured summary.
2. Outline the finalized step-by-step implementation plan.
3. Ask for final confirmation before proceeding with execution.
