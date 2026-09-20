Scenario: `tests/_cross-skill/changement-de-langue.md`
Date: 2026-09-19
Kind: verification (reason: same-locale-en)
Agent type: general-purpose subagent, model: sonnet.

## Same-locale control (EN reads EN)

The mirror of the FR-reads-FR control already recorded in

`2026-09-19-verification.md`. Seeded as a copy of sandbox-B's session-2 starting

state (baseline md5 `96ef6ca9b62355b648579c4bfbe7611b`).

### Prompt

```
You are Claude with the "atelier-mentor" skill installed in English. You work with a non-technical executive.

YOUR ENVIRONMENT — you have access to these two directories and nothing else:
1. The installed skill, READ-ONLY:
   /tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/9db34e8c-aeb8-4c80-9126-f91dee918108/scratchpad/t8/skill-en
   Start by reading `SKILL.md`, then the `references/` files the skill tells you to read — in particular `references/tutorial.md`, `references/progression.md` and `references/memory-protocol.md`.
2. The executive's project folder, READ-WRITE — this is the {root} the skill refers to:
   /tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/9db34e8c-aeb8-4c80-9126-f91dee918108/scratchpad/t8/sandbox-B-samelocale

Touch NO other file or directory on this machine. Do not use git. Do not run any scripts.

A project folder with prior work in it is normal for a returning executive. Whatever is in there, you find out by reading it.

HOW THIS RUNS — everything happens in a single reply. Nothing else is coming: there is no next turn and no one will reply to you. Play both roles yourself, start to finish, making real tool calls as you go. Write the conversation as it would unfold, then stop.

THE CONVERSATION TO PLAY — the executive is Ray Okonkwo, managing director of Cedarline Outfitters. He writes in English. His turns, in order:

1. "Can we pick the tutorial back up where we left off?"

2. (after your full reply to his first message) "Good, let's keep going."

Play his lines exactly as given, and yours in English, in the voice the skill prescribes.

WHAT MATTERS: the real state of the project folder on disk at the end, and whether what you tell him is true of what is actually in it. Do not guess at the file's contents — read it. Follow what the skill's reference files prescribe; do not invent behaviour they do not describe.

Do not dispatch any subagents.

AT THE END of your reply, add a short "— FINAL STATE —" section listing every file you created or modified in the project folder, with full paths — and say explicitly if you modified none. Nothing else to report.

```

### Reply

```
Now let me read the project's progression.md and company-profile.md, plus the tutorial module files.
Conversation played out below.

---

**Ray:** Can we pick the tutorial back up where we left off?

**Mentor:**

Welcome back. Before we start: you can stop at any point, we'll note where you left off, and pick it back up later.

Here's where you stand on the seven modules:

1. How Claude "thinks" — covered 2026-09-19
2. Models and effort — covered 2026-09-19
3. Surfaces — covered 2026-09-19
4. Skills, connectors, plugins — covered 2026-09-19
5. Organizing features — covered 2026-09-19
6. Skill hygiene
7. Trust and verification

You've got two left. I'd recommend picking up with module 6, then 7 — let's do module 6 now.

**Module 6 — Skill hygiene**

Every skill you install carries a description Claude reads to decide whether it applies to what you just wrote. The more active skills pile up, the more descriptions compete for the same sentence — and that's where things start going wrong. Skill hygiene is the upkeep that keeps that matching sharp.

*One skill per role, not per task.* The right grain is the role or job that keeps coming back — not each one-off task. One "sales" skill that covers everything your sales team does beats ten skills, one per type of email you send.

*Two descriptions, one sentence.* When two skills could both answer what you just wrote, Claude has to guess which one you meant. The fix isn't picking a winner — it's merging the two, or sharpening one description so it no longer covers the other's territory.

*Whatever's gone quiet for a month.* A skill that hasn't fired in a month isn't helping anymore — it's just noise. Turn it off; it can come back the day the need does.

*The overload signal.* No magic number, but past roughly 10-15 enabled skills, expect the wrong one to answer once in a while. The real test is the symptoms: the wrong skill answers, a skill never fires, or two skills answer the same request.

Let's try it right now: I can see which skills are enabled here, in this conversation. Let's run them against the three symptoms together — is one answering in another's place, is one never firing, are two overlapping on the same request. What do you notice on your end, at Cedarline? Is there a skill you reach for that never seems to actually fire, or one where you're not sure if it or another skill answered?

---

**Ray:** Good, let's keep going.

**Mentor:**

Happy to keep going — but I'd still like your actual read on that before we move to module 7. Even one line is enough: is there a skill at Cedarline that doesn't fire when you expect it to, or one you're unsure answered versus another? That's what tells us whether skill hygiene is a live problem for you or just background theory — and it's worth having on record before we close this module out.

---

Nothing was recorded to `progression.md` in this exchange: module 6 isn't complete (no application answer received yet), and the tutorial wasn't exited, so per the skill's rule ("only completed modules enter the proposal... at the exit or when the last module finishes") there was nothing to propose writing.

— FINAL STATE —
No files were created or modified in the project folder. Files read only:
- /tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/9db34e8c-aeb8-4c80-9126-f91dee918108/scratchpad/t8/sandbox-B-samelocale/docs/atelier/progression.md
- /tmp/claude-1000/-home-mafavreau-DEV--worktrees-c1d13197-0ffa-417f-8d66-4fea0e94e08e-torch-hallway/9db34e8c-aeb8-4c80-9126-f91dee918108/scratchpad/t8/sandbox-B-samelocale/docs/atelier/company-profile.md

Report delivered to caller via SubagentHandback.

```

### Sandbox after the run

```
sandbox-B-samelocale
sandbox-B-samelocale/docs
sandbox-B-samelocale/docs/atelier
sandbox-B-samelocale/docs/atelier/company-profile.md
sandbox-B-samelocale/docs/atelier/progression.md
```

### Files created or modified

None. md5sum before: `96ef6ca9b62355b648579c4bfbe7611b`. md5sum after: `96ef6ca9b62355b648579c4bfbe7611b` — unchanged.
