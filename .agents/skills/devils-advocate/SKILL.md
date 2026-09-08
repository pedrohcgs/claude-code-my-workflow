---
name: devils-advocate
description: "Adversarial 5-7 question challenge to a deck's presentation-design choices — ordering, prerequisites, cognitive load, motivation. Use when user says \"devil's advocate\", \"poke holes in this deck\", \"push back on my slides\", \"stress-test the design\", \"what would a skeptical audience member ask?\". Read-only; surfaces questions to force rethinking. Lighter than `-excellence`."
---



# Devil's Advocate Review

Critically examine a slide deck and challenge its design with 5-7 specific presentation-design questions.

**Philosophy:** "We arrive at the best possible presentation through active dialogue."

---

## Setup

1. **Read the target file** (the research presentation being challenged)
2. **Read the knowledge base** in `.codex/guidance/` for notation conventions and narrative arc
3. If applicable, **read adjacent research presentations** for narrative continuity

---

## Challenge Categories

Generate 5-7 challenges from these categories:

### 1. Ordering Challenges
> "Could audience understand this better if we showed X before Y?"

### 2. Prerequisite Challenges
> "Do audience have the background for this notation at this point?"

### 3. Gap Challenges
> "Should we include an intuitive example before this formal proof?"

### 4. Alternative Presentation Challenges
> "Here are 2 other ways to visualize/present this concept."

### 5. Notation Conflict Challenges
> "This symbol conflicts with earlier research presentation usage."

### 6. Cognitive Load Challenges
> "This slide has too many new symbols. Can we split?"

### 7. Book Vision Challenges
> "If this becomes a book chapter, does this section stand alone?"

---

## Output Format

```markdown
# Devil's Advocate: [Presentation Title]

## Challenges

### Challenge 1: [Category] — [Short title]
**Question:** [The specific presentation-design question]
**Why it matters:** [What could go wrong]
**Suggested resolution:** [Specific action]
**Slides affected:** [Numbers or titles]
**Severity:** [High / Medium / Low]

[Repeat for 5-7 challenges]

## Summary Verdict
**Strengths:** [2-3 things done well]
**Critical changes:** [0-2 changes before presenting]
**Suggested improvements:** [2-3 nice-to-have changes]
```

---

## Principles

- **Be specific:** Reference exact slides and notation
- **Be constructive:** Every challenge has a suggested resolution
- **Be honest:** If the deck is good, say so
- **Prioritize:** Notation conflicts > missed metaphors
- **Think like a audience member:** Where do they get lost?

