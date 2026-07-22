# Installing Atelier

This guide walks you through installing Atelier on your claude.ai
account — even if you've never installed anything on a computer before.
No technical knowledge required, no terminal, nothing to configure by
hand. Everything happens in your browser.

Budget about ten minutes for the first skill.

## 1. What you need

- A [claude.ai](https://claude.ai) account (free or paid, both work).
- The **Claude Desktop** app or **Claude Cowork**, open in your browser or
  installed on your machine. If you're not sure which one you have, don't
  worry — the steps below are the same for both.

That's it. No developer account, no extra credit card, nothing to install
besides Claude itself.

## 2. Turn on capabilities

Atelier needs two capabilities switched on for your account: **code
execution** and **file creation**. These are what let Claude produce your
documents (company profile, meeting notes, and so on).

1. Open Claude's **Settings** (the icon at the top, or your account menu).
2. Go to **Capabilities**.
3. Make sure both **code execution** and **file creation** are turned on.

![Settings → Capabilities, with code execution and file creation turned on](screenshots/capabilities-toggle.png)

If both switches are already on, great — move to the next step.

## 3. Download the skills

Atelier is a set of seven skills. Each one downloads as a **ZIP file** — a
single attachment that bundles everything the skill needs. You do **not**
need to open it or unzip it — Claude handles that on its own once you
hand it the file, unopened, in the next step.

**To start, one skill is enough: `atelier-en.zip`.** It's the heart of
Atelier — it walks you through an onboarding interview and suggests the
other skills exactly when you need them. No need to download everything
at once.

Click a link below to download the matching ZIP.

| Skill | What it does | Download |
|---|---|---|
| `atelier` | The hub: onboarding interview, company profile | [atelier-en.zip](https://github.com/Heyian/atelier/releases/latest/download/atelier-en.zip) |
| `atelier-mentor` | The guide: routes you to the right skill | [atelier-mentor-en.zip](https://github.com/Heyian/atelier/releases/latest/download/atelier-mentor-en.zip) |
| `atelier-compass` | The thinking process for hard decisions | [atelier-compass-en.zip](https://github.com/Heyian/atelier/releases/latest/download/atelier-compass-en.zip) |
| `atelier-forge` | Builds your own custom skills | [atelier-forge-en.zip](https://github.com/Heyian/atelier/releases/latest/download/atelier-forge-en.zip) |
| `atelier-marketing` | Content, campaigns, brand voice | [atelier-marketing-en.zip](https://github.com/Heyian/atelier/releases/latest/download/atelier-marketing-en.zip) |
| `atelier-sales` | Pipeline, follow-ups, proposals, CRM | [atelier-sales-en.zip](https://github.com/Heyian/atelier/releases/latest/download/atelier-sales-en.zip) |
| `atelier-meetings` | Prep, minutes, decision logs | [atelier-meetings-en.zip](https://github.com/Heyian/atelier/releases/latest/download/atelier-meetings-en.zip) |

The file lands in your usual downloads folder — like any other
attachment.

## 4. Upload a skill

1. In Claude, open **Customize**.
2. Go to **Skills**.

![Customize → Skills](screenshots/customize-skills.png)

3. Click the button to upload a new skill.
4. Pick the ZIP file you just downloaded (for example `atelier-en.zip`) —
   **without unzipping it first.**

![The upload dialog, with the ZIP file selected](screenshots/upload-zip.png)

5. Confirm. Claude imports the skill in a few seconds.

Repeat these steps for any additional skill you want to add, whenever you
need it.

## 5. Check that it works

Open a **new conversation** and type:

> I just installed Atelier, where do I start?

![An Atelier skill showing as enabled in the skills list](screenshots/skill-enabled.png)

If everything's working, Claude responds with a short onboarding
interview: a few questions about your company and your role, then it
puts together your company profile. That interview is your proof the
skill is installed and active.

## 6. Updating

When a new version of Atelier ships:

1. Download the new ZIP for the same skill (same link as in step 3).
2. Re-upload it under **Customize → Skills**, just like in step 4.

That's it — the new version replaces the old one. To see what changed
between versions, check the repo's `CHANGELOG.md`: it lists what's new in
plain language, no technical jargon.

## 7. If it doesn't work

Three causes cover most cases:

1. **Capabilities are off.** Go back to step 2 and confirm code execution
   and file creation are both turned on.
2. **The skill isn't enabled on your account.** Go back to **Customize →
   Skills** and confirm it appears in the list, enabled (as in step 5).
3. **The ZIP was unzipped before uploading.** If your computer
   automatically extracted the ZIP (some browsers and operating systems
   do this), you end up with a folder instead of a ZIP, or a ZIP with a
   folder nested inside it. Claude expects the skill's contents right at
   the top level of the ZIP. Re-download the original file and upload it
   as-is — don't open it, don't rename it.

If the problem persists after checking these three, try closing the
conversation, opening a new one, and asking the step 5 question again.
