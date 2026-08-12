# Trust and verification

Claude can be wrong in one particular way — worth learning to recognize
before deciding what to do about it.

## What a hallucination is

A hallucination is a fluent, plausible, wrong answer. It isn't a lie:
Claude doesn't "know" it's wrong — it produces the sentence that best
matches what a good answer looks like, based on what it learned, and that
sentence can be false without anything in its shape giving it away. It
isn't a bug you can see, either: nothing blinks, nothing turns red. The
sentence looks exactly as solid as a true one.

## Why tone carries no signal

The same machinery that lets Claude write well is the one that produces a
false sentence with the same confidence as a true one. Fluency and
accuracy come out of the same mechanism — not two separate ones, one for
sounding right and another for being right. So a confident tone tells you
nothing about whether it's correct. A hesitant answer isn't any more
likely to be wrong; a confident one isn't any more likely to be right.

## Where the risk concentrates

The risk isn't spread evenly. Numbers, names, dates, citations — anything
specific enough to sound authoritative — are where a hallucination is most
likely to slip past unnoticed, precisely because the precision itself
reads as proof.

## What to do about it

Recognizing a hallucination isn't enough to protect against it: that
takes concrete practices for checking what Claude asserts before you act
on it. Those practices live in `references/fact-checking.md` — ask me for
them as soon as a specific claim needs checking before you use it.

## Try it right now

Give me a specific claim — a number, a date, a name, a quote — that you
were about to use as-is. I'll check it with you, right now, instead of
just telling you how.
