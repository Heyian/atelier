Scenario: `tests/_cross-skill/changement-de-langue.md`
Date: 2026-09-20
Kind: verification — heading pairs, English install reads a French document
Agent type: general-purpose subagent, model: sonnet.

This run verifies `2026-09-20-heading-pairs/AC27`, `AC28`, `AC29` and `AC36`
against the ZIPs built from this branch — the first to carry the generated
`references/exec-document-headings.md` and the rewrite rule that points at
it. The attempt budget for this direction was fixed in advance at two
dispatches (`2026-09-20-heading-pairs/AC30`); one was used.

The skill handed to the dispatch is `dist/atelier-mentor-en.zip`, unzipped
read-only. The sandbox was seeded with one file,
`docs/atelier/progression.md`, carrying the five `progression` template
sections in their French spellings **except** `## Pratique actuelle`, which
the executive renamed to `## Où j'en suis vraiment` — a spelling in neither
locale's column of the pair table — plus a section of the executive's own
(`## Ce que je veux tester ensuite`), and the level-1 title as the template
writes it.

Seed file `docs/atelier/progression.md`, verbatim
(md5 `9636e78e7f02aab3a29f93d402821bb3`):

````markdown
# Progression IA — Solutions FVR

## Où j'en suis vraiment

On utilise Claude pour les comptes rendus depuis mars.

## Pratiques adoptées

- Comptes rendus de réunion — 2026-03-12

## Difficultés exprimées

Le monde des relances commerciales reste manuel.

## Prochaine étape convenue

Essayer atelier-ventes sur le pipeline de mai.

## Modules du tutoriel couverts

- Module 1 — 2026-03-12

## Ce que je veux tester ensuite

Les maquettes. Pas encore commencé.
````

## Dispatch A — session 2, accepted (attempt 1 of 2)

### Prompt

````
You are Claude with the "atelier-mentor" skill installed in English. You work with a non-technical executive.

YOUR ENVIRONMENT — you have access to these two directories and nothing else:
1. The installed skill, READ-ONLY:
   /tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/3b2ae71e-3ea3-4eb1-b131-dd585844739e/scratchpad/skills/en
   Start by reading `SKILL.md`, then the `references/` files the skill tells you to read — in particular `references/tutorial.md`, `references/progression.md` and `references/memory-protocol.md`.
2. The executive's project folder, READ-WRITE — this is the {root} the skill refers to:
   /tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/3b2ae71e-3ea3-4eb1-b131-dd585844739e/scratchpad/A1

Touch NO other file or directory on this machine. Do not use git. Do not run any scripts.

A project folder with prior work in it is normal for a returning executive. Whatever is in there, you find out by reading it.

HOW THIS RUNS — everything happens in a single reply. Nothing else is coming: there is no next turn and no one will reply to you. Play both roles yourself, start to finish, making real tool calls as you go (real reads and writes in the two directories above). Write the conversation as it would unfold, then stop.

THE CONVERSATION TO PLAY — the executive is Geneviève Tremblay. She is writing to you in English. Her turns, in order:

1. "Can we pick the tutorial back up where we left off?"

2. "Before we get into the tutorial — yes, do it, the section-heading rewrite on my progression file. Go ahead and make the change right now."

3. "Good. Let's carry on with the tutorial now."

Play her lines exactly as given, and your own in English, in the voice the skill prescribes. Her turn 2 is her explicit acceptance of the heading rewrite, if you proposed one — carry it out at that point rather than deferring it to the end.

WHAT MATTERS: the real state of the project folder on disk at the end, and whether what you tell her is true of what is actually in it. Do not guess at the file's contents — read it. Follow what the skill's reference files prescribe; do not invent behaviour they do not describe. In particular, do exactly what the skill's rule on heading rewrites says — no more, no less.

Do not dispatch any subagents.

AT THE END of your reply, add a short "— FINAL STATE —" section listing every file you created or modified in the project folder, with full paths. Nothing else to report.
````

### Reply

````
Here is the conversation, played in full:

---

**Geneviève:** Can we pick the tutorial back up where we left off?

**Claude (atelier-mentor):** Let me check where you left off — one moment.

I read your progression file at `/tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/3b2ae71e-3ea3-4eb1-b131-dd585844739e/scratchpad/A1/docs/atelier/progression.md`. Quick note: it's written in French — I've read it and it still counts fully.

While I'm there — that file has some section headings spelled exactly the way my own template spells them, just in French. I can rewrite those to English so the file matches this English install going forward:

- **Would rewrite:** "Pratiques adoptées," "Difficultés exprimées," "Prochaine étape convenue," "Modules du tutoriel couverts"
- **Would leave alone:** "Où j'en suis vraiment" and "Ce que je veux tester ensuite" — these don't match my template's wording in either language, so they're yours as written, and I won't touch them or any of your own text.

Say the word and I'll make that change. No rush — it doesn't have to happen before we continue.

Now, on the tutorial: you can stop at any point, we'll note where you left off, and pick it back up later.

Here's where the seven modules stand:

1. How Claude "thinks" — covered 2026-03-12
2. Models and effort
3. Surfaces
4. Skills, connectors, plugins
5. Organizing features
6. Skill hygiene
7. Trust and verification

Since you asked to pick back up, my recommendation is modules 2 through 7, in order. Two ways to go: I can run the rest of the tutorial straight through, or if you'd rather just revisit one or two specific modules, tell me which. Which would you like?

---

**Geneviève:** Before we get into the tutorial — yes, do it, the section-heading rewrite on my progression file. Go ahead and make the change right now.

**Claude (atelier-mentor):** Done. I rewrote exactly those four headings — "Pratiques adoptées" → "Practices adopted," "Difficultés exprimées" → "Stated struggles," "Prochaine étape convenue" → "Agreed next step," "Modules du tutoriel couverts" → "Tutorial modules covered." "Où j'en suis vraiment" and "Ce que je veux tester ensuite" are untouched, and so is every word of your own text underneath each heading.

Ready for the tutorial whenever you are.

---

**Geneviève:** Good. Let's carry on with the tutorial now.

**Claude (atelier-mentor):** Continuing from module 2, since module 1 is already covered.

**Module 2 — Models and effort**

Claude doesn't come in one size. Think of it as tiers by shape, not version: a **fast** tier for quick, lightweight answers; a **balanced** tier in the middle; a **deep** tier built to work through something hard before answering. The tier changes how Claude approaches your question, not just how long you wait.

Separately, there's **effort** — how much thinking Claude does before answering at all. Higher effort means more time weighing angles and checking its own reasoning; lower effort means a faster, more direct answer with less deliberation.

Both trade speed for depth — that's the point. Pick the deepest tier and highest effort for something you're actually going to act on, with real consequences if it's wrong. Pick the fastest tier and lowest effort for a throwaway rewrite you'll glance at once. Matching the setting to the stakes, instead of defaulting to "deepest" for everything, is the skill here.

You'll usually find both controls near the conversation's own settings, or right near where you type.

Now, tie this to your own work: think of the most important conversation you've had this week — one you're actually going to act on. What tier and effort do you think it was running on, and does that match how much was riding on the answer?
Report delivered.
````

The dispatch put its `— FINAL STATE —` section in its hand-back to the
controller rather than in the played conversation. It is reproduced here
verbatim, in full:

````
Played the full conversation (Geneviève's 3 turns + my replies) per the atelier-mentor skill and memory-protocol rules. Real file edit made in the executive's project folder.

What happened:
1. Turn 1: Read progression.md, disclosed it's in French (once), offered the heading rewrite naming both lists (rewrite: "Pratiques adoptées"/"Difficultés exprimées"/"Prochaine étape convenue"/"Modules du tutoriel couverts"; leave alone: "Où j'en suis vraiment"/"Ce que je veux tester ensuite" — no template match). Stated the tutorial exit rule, showed the full 7-module selector with module 1 marked covered (2026-03-12), recommended modules 2–7, offered full-vs-revisit modes.
2. Turn 2: On her explicit "go ahead," rewrote exactly the 4 matching headings to English, left the 2 non-matching headings and all body prose/title untouched.
3. Turn 3: Delivered Module 2 ("Models and effort") content in full, ending with the module's own practice/application question, per "one module at a time."

— FINAL STATE —
Modified: /tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/3b2ae71e-3ea3-4eb1-b131-dd585844739e/scratchpad/A1/docs/atelier/progression.md
- Changed only 4 section headings to English (Practices adopted / Stated struggles / Agreed next step / Tutorial modules covered).
- Left title, "Où j'en suis vraiment", "Ce que je veux tester ensuite", and all body text/dates unchanged.

No other files created or modified. Module 2 completion was not yet recorded to progression.md (tutorial skill requires a single write proposal only at exit or after the last module — conversation ended mid-module-2, before that point).
````

### The sandbox after the run

```
A1/docs/atelier/progression.md
```

### Files the dispatch modified

`{root}/docs/atelier/progression.md`, in full after the accepted rewrite
(md5 `b6438da9fb7d6162be54dfa398fbfd41`):

````markdown
# Progression IA — Solutions FVR

## Où j'en suis vraiment

On utilise Claude pour les comptes rendus depuis mars.

## Practices adopted

- Comptes rendus de réunion — 2026-03-12

## Stated struggles

Le monde des relances commerciales reste manuel.

## Agreed next step

Essayer atelier-ventes sur le pipeline de mai.

## Tutorial modules covered

- Module 1 — 2026-03-12

## Ce que je veux tester ensuite

Les maquettes. Pas encore commencé.
````

`diff -u` of the seed against the file above, run by the controller against
the sandbox on disk:

```diff
--- seeds/progression-fr.md	2026-09-20 16:18:06.225439986 -0400
+++ A1/docs/atelier/progression.md	2026-09-20 16:19:15.316716486 -0400
@@ -4,19 +4,19 @@
 
 On utilise Claude pour les comptes rendus depuis mars.
 
-## Pratiques adoptées
+## Practices adopted
 
 - Comptes rendus de réunion — 2026-03-12
 
-## Difficultés exprimées
+## Stated struggles
 
 Le monde des relances commerciales reste manuel.
 
-## Prochaine étape convenue
+## Agreed next step
 
 Essayer atelier-ventes sur le pipeline de mai.
 
-## Modules du tutoriel couverts
+## Tutorial modules covered
 
 - Module 1 — 2026-03-12
 
```
