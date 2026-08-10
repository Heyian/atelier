# Skills, connectors, plugins

Three words executives often fold into one, but they name three different
things.

## Three different things

A **skill** is a folder of instructions and files you turn on for a role or
a recurring job — that's exactly what Atelier installs for you, one skill at
a time.

A **connector** hooks Claude up to an outside service — a mailbox, a CRM, a
file space — so it can read or write there directly, instead of waiting for
you to copy-paste.

> **Last verified 2026-08-10** — source: Anthropic help center, article 11176164
> ("Use connectors to extend Claude's capabilities"). Capabilities shift month
> to month: show the executive this date, and offer to re-verify against
> `references/sources.md` before they build anything on it.

A **plugin** is a bundle that packages several skills together — sometimes
with extra automation — so you install them all at once instead of one by
one.

> **Last verified 2026-08-10** — source: Anthropic help center, article 13837440
> ("Use plugins in Claude"). Capabilities shift month to month: show the
> executive this date, and offer to re-verify against `references/sources.md`
> before they build anything on it.

## What each surface runs

| Surface | Skills bundled in a plugin | Automation (hooks & sub-agents) |
|---|---|---|
| claude.ai (Chat, web) | Yes, on paid plans | No — greyed out |
| The Chat tab in Claude Desktop | Yes, on paid plans | No — greyed out |
| Cowork | Yes, on paid plans | Yes |

In practice: a plugin's skills show up everywhere, so pick the surface based
on the rest of the job — Chat for a quick question, Cowork if it needs
automation or several steps. Hooks and sub-agents only run in Cowork;
elsewhere they show up greyed out, not missing.

> **Last verified 2026-08-10** — source: Anthropic help center, article 13837440
> ("Use plugins in Claude"). Capabilities shift month to month: show the
> executive this date, and offer to re-verify against `references/sources.md`
> before they build anything on it.

## Try it on your own

Open your claude.ai account settings and find the skills and connectors
sections: which skills are turned on, which connectors are attached. That's
where you flip either one — mentor can't do it for you.
