# Tutorial Corpus — Source Outline

Source material for `atelier-mentor`'s tutorial — the seven modules shipped as
`references/tutorial/` in each locale. Sibling of `docs/mentor-corpus.md`, same
pattern: this file is maintainer-facing and single-source; implementation
localizes each section into a shipped module file per locale.

**This is a living document.** It has a decent day-1 body and is meant to grow:
new modules, sharper explanations, and — above all — re-verified capability
claims. Nothing here is finished, and the `Claims to re-verify` index at the
bottom exists because parts of it go stale on a monthly clock.

Placement is settled by ADR-0012 (teaching capability lives in mentor). The
dated-claim gate is settled by ADR-0011.

## Module 01 — How Claude "thinks"

- The context window: everything Claude can see at once in this conversation —
  your messages, its replies, the files it read.
- Tokens as the unit that fills it, in plain terms; no version-specific numbers.
- Why a long conversation degrades: the window fills, older turns get compacted
  or drop out, and the thread you thought was shared quietly is not.
- Why a compacted conversation degrades differently from a fresh one: what
  survives compaction is a summary, not the original.
- Atelier's answer: short, fresh conversations plus memory in files — the relay
  and corporate memory — instead of one conversation that keeps stretching.

## Module 02 — Models & effort

- Model families as tiers, by shape: a fast tier, a balanced tier, a deep tier.
  Teach the shape, not a version list.
- What an effort level changes: how much thinking Claude does before answering.
- The speed/depth trade-off, and how to pick: the deepest tier for a decision
  you will act on, the fastest for a throwaway rewrite.
- Where the pickers live in the interface, so the executive can find them.

## Module 03 — Surfaces

- Chat vs the Cowork tab: what each is for.
- claude.ai web vs Desktop.
- What each can and cannot do — folder access and connector reach in
  particular, since that is what decides whether Atelier can write files.
- Every claim in this section is capability-sensitive: dated and sourced.

## Module 04 — Skills, connectors, plugins

- What a skill is, what a connector is, what a plugin is — three different
  things executives routinely merge into one.
- The per-surface support matrix, dated and sourced.
- What that means practically: which surface to open for which job.

## Module 05 — Organizing features

- Projects: standing instructions and knowledge for one department.
- Artifacts: a produced document you can keep and share.
- Scheduled: recurring work that runs without you opening a conversation.
- Dispatch: handing a job off to run on its own.
- Availability and plan eligibility here are capability-sensitive: dated and
  sourced.

## Module 06 — Skill hygiene

- One skill per role or recurring job — not one per task.
- If two descriptions could fire on the same phrase, merge them or sharpen one.
- Disable anything unused for a month. It can come back.
- The soft ceiling: past roughly 10–15 enabled skills, expect wrong-skill
  firings. **A smell, never a law** — some rosters are fine at twenty.
- The symptoms, so the executive can self-diagnose: the wrong skill answering,
  a skill that never fires, two skills that answer the same request.

## Module 07 — Trust & verification

- What a hallucination is: a fluent, plausible, wrong answer — not a lie and
  not a bug the executive can see.
- Why Claude sounds confident when it is wrong: fluency and accuracy are
  produced by the same machinery, so tone carries no signal about correctness.
- Which kinds of claim are most at risk: numbers, names, dates, citations,
  anything specific enough to sound authoritative.
- **Concepts only.** The practices — the approved-facts registry, separating
  producing from checking, red-teaming a big decision — live in
  `references/fact-checking.md` and are cross-referenced, never restated here
  or in the module.

## Claims to re-verify

Questions, not answers — deliberately. Answers live in the module files, each
carrying its own last-verified date and source. This list exists so a
re-verification pass reads one page instead of fourteen module files.

- Which surfaces run skills bundled in a plugin, and on which plans? — feeds
  modules 03, 04
- Do hooks and sub-agents run everywhere, or only in Cowork? — feeds module 04
- Which surfaces reach local folders? — feeds modules 03, 04
- Does the Desktop Chat tab have the same local-folder access as Cowork, or
  none at all? Neither cited source makes the comparison. — feeds modules 03,
  04
- Which surfaces reach connectors, and which connectors? — feeds modules 03, 04
- What are Claude's French interface labels for skills, connectors, plugins,
  Projects and Artifacts? — feeds modules 03, 04, 05
- Which organizing features exist, under which names, on which plans? — feeds
  module 05
- Do the model tiers and effort levels still work the way module 02 describes
  their shape? — feeds module 02

## Verified 2026-08-10

**Source:** Anthropic help center, article 13837440, "Use plugins in Claude"
(primary source for the per-surface support matrix); supporting claims below
cite their own article where they come from a different page. All pages
fetched 2026-08-10, later than issue #9's 2026-07-21 verification.

- **Skills bundled in a plugin:** claude.ai web chat, the Chat tab in Claude
  Desktop, and Claude Cowork — all three surfaces, for all paid plans (Pro,
  Max, Team, Enterprise). Verbatim: "Plugins are available to all paid plans
  (Pro, Max, Team, Enterprise)." / "You can install and use plugins in chat on
  the web, the Chat tab in Claude Desktop, and Claude Cowork. The skills
  bundled in a plugin work across all three." (article 13837440) — matches
  issue #9's answer, no divergence.
- **Hooks and sub-agents:** Cowork only; greyed out in chat on the other
  surfaces. Verbatim: "Hooks and sub-agents run only in Cowork, so they appear
  grayed out in chat." (article 13837440) — matches issue #9's answer, no
  divergence.
- **Local folder access:** requires the Claude Desktop app open and connected
  on that computer — a cloud session (including one reached from web or
  mobile) can reach local folders solely through the running Desktop app, and
  solely for folders you've connected. Documented as a Cowork capability.
  Verbatim: "A session in the cloud can read and write files in folders
  you've connected on your computer only while the desktop app is open on
  that computer." (Anthropic help center, article 15520349, "Use Claude
  Cowork on web, desktop, and mobile"; consistent with article 13345190, "Get
  started with Claude Cowork"). **Neither article states whether the Desktop
  Chat tab has the same access or lacks it** — that comparison is not made in
  either source, so it is not asserted here; see the `Claims to re-verify`
  index. This claim was not in issue #9's verified set; no prior answer to
  compare against.
- **Connector reach:** web/remote connectors are available on claude.ai,
  Claude Cowork, Claude Desktop, and Claude Mobile, for all users, no plan
  restriction noted. Desktop extensions are Claude Desktop only. Custom
  connectors over remote MCP are available on claude.ai, Cowork, and Claude
  Desktop for Free, Pro, Max, Team, and Enterprise plans, with Free limited to
  one custom connector. Inside a Cowork session specifically, connectors reach
  external services through Anthropic's cloud, not the local network; a
  custom connector must point to a server reachable over the public internet
  from Anthropic's IP ranges. (Anthropic help center, article 11176164, "Use
  connectors to extend Claude's capabilities"; article 13837440.) Not in issue
  #9's verified set; no prior answer to compare against.
- **Organizing features and plan eligibility:**
  - Projects: persistent, self-contained workspaces with their own files,
    context, instructions, and memory. Verbatim: "Projects in Claude Cowork
    let you group related tasks into dedicated workspaces with their own
    files, context, instructions, and memory." Cowork projects are
    desktop-only, without qualification: "Projects are desktop-only and
    stored locally. There's no cloud sync for project data at this time."
    (Article 14116274, "Organize your tasks with projects in Claude Cowork".)
  - Artifacts: available on Claude (web), Claude Desktop, and Claude Code.
    Sidebar access and Claude-powered artifacts are supported on Free, Pro,
    Max, Team, and Enterprise plans; Artifacts in Claude Code is Team and
    Enterprise only. (Article 9487310, "What are artifacts and how do I use
    them?")
  - Scheduled (recurring tasks): available in Cowork for all paid plans (Pro,
    Max, Team, Enterprise); Cowork itself was noted as "in beta on web and
    mobile, and rolling out over the next several weeks starting with the Max
    plan, with more plans to follow." (Article 13854387, "Schedule recurring
    tasks in Claude Cowork".)
  - Dispatch: message Claude from your phone to run a task on your desktop
    computer using your local files, connectors, plugins, and apps; the
    desktop computer must be awake with the Claude Desktop app open while
    Claude works. (Article 13947068, "Assign tasks from anywhere in Claude
    Cowork".)
  - None of the organizing-feature detail above was in issue #9's verified
    set; no prior answer to compare against.

**French interface labels** (source: the French-language Anthropic help
center, `support.claude.com/fr`, fetched 2026-08-10 — article number per row
below):

| Concept | Claude's French label | OQLF gloss, if the label is an anglicism |
|---|---|---|
| skill | Compétences (menu path: Personnaliser > Compétences; article 12512180, "Utiliser les compétences dans Claude") | — (already French, no gloss needed) |
| connector | Connecteurs (menu path: Personnaliser > Connecteurs; article 11176164, "Use connectors to extend Claude's capabilities") | — (already French, no gloss needed) |
| plugin | Plugins (article 13837440, "Use plugins in Claude") | plugiciel |
| Project | Projets (article 14116274, "Organize your tasks with projects in Claude Cowork") | — (already French, no gloss needed) |
| Artifact | Artefacts (article 9487310, "What are artifacts and how do I use them?") | — (already French, no gloss needed) |
