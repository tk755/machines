---
name: deep-research
description: |
  Multi-agent deep research for thorough, evidence-based answers. Use this when the user
  needs more than surface-level knowledge — when they need real-world evidence, practitioner
  experience, and authoritative sources synthesized into a definitive answer. Trigger when
  the user asks "should I use X or Y?", "what's the best approach for...", "how should I
  configure...", "what packages/tools do I need for...", "what's the best practice for...",
  or any question where you'd otherwise give a generic answer without strong evidence. Also
  trigger proactively when you catch yourself listing pros/cons without a position, giving
  theoretical advice without real-world backing, or flip-flopping based on the user's tone.
---

## Why this exists

Surface-level answers are easy but often wrong or incomplete. The failure modes are:
- **Yes-manning** — agreeing with whatever the user last said
- **Generic advice** — listing theoretical pros/cons without real-world evidence
- **Shallow confidence** — stating something definitively based on vibes, not data
- **False balance** — presenting options as equally valid when evidence favors one

The fix is gathering evidence from multiple independent angles simultaneously. When
unrelated sources converge, the answer is strong. When they diverge, the uncertainty
is genuine and worth surfacing honestly.

## When to use this

- The user needs a well-researched answer and you lack strong evidence
- The question depends on real-world experience, not just theory
- You're about to give generic advice without empirical backing
- You've changed your position twice based on the user's reactions
- The topic has multiple valid approaches and the right one depends on context

## When NOT to use this

- You already know the answer with high confidence from direct knowledge
- The question is simple and factual (not requiring multi-source research)
- The user has already decided and just needs help implementing
- The topic is purely subjective with no objective tradeoffs

## Process

### 1. Frame the question

Before launching research, clarify:
- What exactly does the user need to know?
- What's their specific context and constraints?
- What would a complete, useful answer look like?

If the question is vague, ask the user to narrow it before researching. Good research
starts with a good question.

### 2. Select and launch research agents

Spawn 2-4 Task agents simultaneously via the Task tool. Each agent has a specific
mandate and returns findings — synthesis happens after all agents report back.

Choose agents based on what the question actually needs. Below is the toolkit of
agent types. Not every question needs all of them — pick the ones that will produce
useful, independent angles on the specific topic.


#### Authority agent
What do established projects, organizations, and official sources actually do?
Not what they recommend in the abstract — what they chose for their own systems.

When to use: almost always. Knowing what major players actually shipped is one of
the strongest signals available.

Prompt pattern:
```
Research what major projects and organizations actually do regarding [TOPIC].
Look at the most established players in this space.

Find:
- What do 3-5 major projects/distros/companies actually implement?
- Did any switch approaches? Why?
- What's the current trajectory — what's gaining or losing adoption?
- What do official docs, release notes, and migration guides say?

Focus on what they DO, not what they tell others to do.
```

#### Practitioner agent
What do real users report after living with this in practice? The most valuable
evidence is long-term experience, regrets, and gotchas — not first impressions.

When to use: almost always. Real-world experience reports are the best predictor
of what the user will actually encounter.

Prompt pattern:
```
Search forums, Reddit, Hacker News, Stack Overflow, and blogs for real-world
experience with [TOPIC]. I need evidence from people who actually did this,
not theoretical advice.

Search for:
- Regrets: "I wish I had...", "don't bother with...", "my mistake was..."
- Gotchas: problems people hit that aren't obvious upfront
- Long-term reports: people who've lived with this for 1+ years
- Things people say DON'T matter (overblown concerns)
- Common configurations/setups people actually use in practice

Prioritize recent posts (last 2-3 years). Quote specific findings with sources.
```

#### Devil's advocate agent
What's the strongest case against the obvious answer? What could go wrong?

When to use: when there's a "default" answer that feels too easy, when the user
is leaning somewhere and might have confirmation bias, or when the stakes of
being wrong are high.

Prompt pattern:
```
Regarding [TOPIC], challenge the conventional wisdom. Build the strongest case
against [OBVIOUS APPROACH].

For each commonly recommended approach:
- What's the worst realistic scenario?
- What breaks or becomes painful long-term?
- What do critics say, and are they right?
- What hidden costs or complexity emerges over time?

Be genuinely adversarial, then assess: how strong is each counter-argument
in practice? Theoretical concern or real-world problem?
```

#### Quantitative agent
What are the actual measurable differences? Numbers, benchmarks, real data.

When to use: when the topic involves performance, resource usage, costs, or
any measurable dimension where "it depends" can be resolved with data.

Prompt pattern:
```
Research the actual measurable real-world impact of [OPTIONS/APPROACHES].

Find:
- Published benchmarks or comparisons with methodology
- Real measurements people have shared (not synthetic tests)
- Order-of-magnitude context (is this a 50% difference or 0.5%?)
- Whether the difference matters at [USER'S SCALE/CONTEXT]

I need numbers with context, not vague "X is better than Y."
```

#### Technical deep-dive agent
How does this actually work under the hood? What are the mechanisms?

When to use: when the user needs to understand how something works to make
a good decision, or when surface-level docs are insufficient.

Prompt pattern:
```
Research the technical details of [TOPIC]. Go beyond surface documentation.

Find:
- How does this actually work internally?
- What are the key mechanisms, algorithms, or design decisions?
- What are the technical constraints or limitations?
- What does the source code, kernel docs, or spec actually say?
- What do the maintainers/developers say about design choices?

I need technical accuracy, not marketing or simplified explanations.
```

### 3. Adapt agents to the question type

The prompt patterns above are starting points. Adapt them to fit the actual
question. The pacstrap example illustrates this well — the "authority agent"
wasn't asked "which package manager is best?" but rather "what do archinstall,
Fedora, and openSUSE actually include in their default installs?"

Good agent prompts are:
- **Specific** to the actual question, not generic templates with blanks filled in
- **Concrete** about what to search for and where
- **Clear** about what format of evidence is useful

### 4. Synthesize

After all agents return, assess the evidence:

- **Strong convergence** — independent angles agree. State the answer with
  confidence and lead with it.
- **Partial convergence** — mostly agreement with a genuine counterpoint.
  State the answer, acknowledge the exception, explain why the weight of
  evidence still supports the conclusion.
- **Genuine divergence** — angles disagree meaningfully. Surface the real
  tradeoff, explain which factors matter most for the user's specific
  context, and still take a position.
- **Insufficient evidence** — agents didn't find much. Say so honestly.
  Recommend the simpler or more reversible path as a reasonable default.

### 5. Present the answer

Lead with the answer, not the research process. Structure depends on what
the user asked:

**For decisions** ("should I use X or Y?"):
1. The recommendation — one clear sentence
2. Key evidence — 2-3 most compelling findings
3. What you'd lose — honest about the tradeoff
4. When you'd choose differently — conditions that flip the answer

**For "how should I configure/set up X?"**:
1. The recommended configuration — concrete and specific
2. Why each choice — evidence backing each element
3. What's optional vs essential — clearly distinguished
4. Common mistakes to avoid — from practitioner evidence

**For "what are my options for X?"**:
1. The recommended approach — lead with your position
2. The landscape — what exists and who uses what
3. When alternatives make sense — specific conditions, not generic hedging

**For "how does X work?"**:
1. The clear explanation — direct and accurate
2. Key mechanisms — how it actually works, not marketing
3. Practical implications — what this means for the user's situation

## Anti-patterns

- **Process over substance**: Don't narrate the research methodology to the user.
  They want the answer, not a tour of how you found it.
- **Pros/cons without a position**: Take a stance. If you can't after multi-angle
  research, explain which angle you weigh most and why.
- **Yes-manning**: If you've changed your answer twice based on the user's tone,
  stop talking and launch research.
- **Theory over evidence**: "X should be better" is weaker than "users report X
  is better" is weaker than "benchmarks show X is 40% better."
- **False balance**: If evidence clearly favors one answer, don't artificially
  balance the presentation. Being definitive is the service.
- **Researching the obvious**: Don't launch 4 agents for questions you can
  answer confidently. This is for genuine uncertainty where evidence matters.
- **Over-researching narrow questions**: A question with a clear, well-known
  answer doesn't need multi-agent research. Use judgment about when depth
  adds value vs when it's overkill.
