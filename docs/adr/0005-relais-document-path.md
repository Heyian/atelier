# 0005 — The relais document path

**Status:** Accepted — 2026-07-21

## Context

The relay (« relais ») is a document, not just a memory write: `atelier`
delivers it in Cowork (AC9), and `atelier-boussole` hands off through the
same mechanism (AC40). The spec fixes canonical homes for the Company
Profile, the decision journal and the per-role memory directory, but names
no home for relais documents. Left unfixed, each author who writes a relais
would invent their own path — `atelier` first, then `atelier-boussole`
independently — and the two would very likely disagree.

## Decision

The canonical path, in both locales, is:

```
{root}/docs/atelier/relais/YYYY-MM-DD-<subject>.md
```

(`{racine}/docs/atelier/relais/AAAA-MM-JJ-<sujet>.md` in the French skill's
own placeholder spelling — same directory, same file-naming shape, only the
locale's own tokens for root/date/subject differ.)

The directory segment stays `relais/` in **both** locales, never translated
to `relay/`. This is the same reasoning already applied to the memory file's
canonical-French key (ADR 0004): one spelling, so an executive switching
locale does not orphan documents already on disk. It also matches the
product's own vocabulary — the shared EN glossary names the concept "Relay
(relais)" rather than picking one term and dropping the other.

Both `atelier` (AC9) and `atelier-boussole` (AC40) write relais documents to
this one path; neither invents its own. In Cowork, the skill writes the file
there and gives its path. In a Desktop chat session, with no folder access,
the skill cannot write it at all — it delivers the relais as a downloadable
file instead, or shows it in full in the conversation when file creation
isn't available, and says so plainly rather than implying a write happened.

## Consequences

- One path every skill that hands off through the relais can name, without
  reconciling two conventions after the fact.
- Consistent with the documentation convention that all skill output lives
  under `{root}/docs/`.
- Desktop-chat relais deliveries never populate `relais/` directly; the file
  only lands there once a Cowork session saves the download, same as the
  Company Profile and the role registry.
