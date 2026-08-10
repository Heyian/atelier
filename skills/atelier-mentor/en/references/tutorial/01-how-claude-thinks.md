# How Claude "thinks"

A conversation with Claude lives inside a space with a fixed size: the
**context window**. It's everything Claude can see at once when it writes
its next reply — your messages, its own past replies, the contents of any
file it read. Nothing outside that window exists for Claude at the moment
it answers, even if it was said earlier in the very same conversation.

What fills that window is measured in **tokens** — think of a token as a
small chunk of a word or phrase, the same unit for what you type, what
Claude replies, and what it reads out of a file. Every exchange adds more.
The window has a fixed size, and it eventually fills up.

That's exactly why a conversation that runs long starts to degrade: once
the window is full, the earliest turns have to give way — either they get
summarized, or they drop out of what Claude can see entirely. The thread
you assumed was still fully shared quietly isn't anymore; Claude is
answering from a trimmed or summarized version of what was said, not the
full memory of it.

A conversation that has just been compacted isn't the same as a fresh one,
either: it starts back up from a **summary** of everything before it, not
the original. A summary keeps whatever the summarizer judged essential — it
necessarily loses detail, nuance, the one carefully worded sentence you
wrote three turns back. A fresh conversation carries none of that weight:
it starts empty, holding only what you choose to put into it.

That's precisely the problem Atelier's practice is built to avoid. Instead
of letting a conversation stretch until it needs compacting, Atelier leans
on short, fresh conversations and on memory that lives in files rather than
in the chat thread: the **relay** to hand work from one conversation to the
next without re-explaining it, and **corporate memory** for what needs to
outlast a single session.

## Try it right now

Ask me for a relay, right now, on what we just did. You'll see the
mechanism I just described in action: what matters gets written into a
file, and the next conversation starts short instead of dragging this one
along.
