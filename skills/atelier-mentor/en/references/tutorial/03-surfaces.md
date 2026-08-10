# Surfaces

Claude shows up in more than one place, and picking the right one changes
what's actually possible in the conversation — not just how it looks.

## Chat vs. the Cowork tab

**Chat** is a conversation: you write, Claude answers, and the back-and-forth
is the whole of it. The **Cowork tab** is built for a different kind of job —
something with several steps, that touches files, or that keeps running after
you've looked away.

## claude.ai web vs. Desktop, and what each can reach

Separately from Chat vs. Cowork, there's where you're working from:
**claude.ai** in a browser tab, or the **Claude Desktop** app installed on
your computer. Cowork itself is reachable from all three — claude.ai on the
web, the Desktop app, and mobile. And once you're in a Cowork session, folder
access follows one rule: it can read and write files in folders you've
connected on your computer, but only while the Claude Desktop app is open and
running on that computer. Close Desktop, and that reach closes with it — no
matter whether you started the session from web, Desktop, or your phone.

> **Last verified 2026-08-10** — source: Anthropic help center, article 15520349
> ("Use Claude Cowork on web, desktop, and mobile"). Capabilities shift month
> to month: show the executive this date, and offer to re-verify against
> `references/sources.md` before they build anything on it.

Whether the **Chat tab** in Desktop has that same folder access, or none at
all, isn't settled by the sources mentor checked — the question is open, not
answered "no." If it matters for what you're about to do, ask mentor to
re-verify before you rely on either answer.

## Connector reach

Web and remote connectors work from claude.ai, Cowork, Claude Desktop, and
Claude Mobile, for every plan, with no plan restriction noted. Desktop
extensions only work inside the Claude Desktop app. Custom connectors — the
ones you set up yourself, pointing at a server you specify — work from
claude.ai, Cowork, and Desktop, on the Free, Pro, Max, Team, and Enterprise
plans; Free is capped at one custom connector. Inside a Cowork session
specifically, a connector reaches the outside world through Anthropic's
cloud, not your local network, so a custom connector has to point to a
server reachable over the public internet.

> **Last verified 2026-08-10** — source: Anthropic help center, article 11176164
> ("Use connectors to extend Claude's capabilities"). Capabilities shift month
> to month: show the executive this date, and offer to re-verify against
> `references/sources.md` before they build anything on it.

## Try it on your own

Open claude.ai on the web and, separately, the Claude Desktop app if you have
it installed. Compare what each shows under Connectors, and, if you use
Cowork, check whether Desktop is open before you ask it to touch a local
folder — that's the condition the folder-access answer above depends on.
