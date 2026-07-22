# Screenshots needed for the install guides

`docs/INSTALL.fr.md` and `docs/INSTALL.en.md` reference four PNG files
that live in this folder. They are not included in the repo yet — capture
them and drop them in here with the exact filenames below.

| File | What to capture |
|---|---|
| `capabilities-toggle.png` | Claude Settings → Capabilities, showing **code execution** and **file creation** both turned on. |
| `customize-skills.png` | Claude Customize → Skills, the skills list/landing panel. |
| `upload-zip.png` | The skill upload dialog, mid-flow (e.g. a ZIP file picked/selected). |
| `skill-enabled.png` | A skill (e.g. `atelier` / `atelier-fr`) showing as enabled in the skills list. |

## Rules before you commit them

- **Crop to the relevant panel.** Don't ship a full-browser or full-desktop
  screenshot — crop tightly to the Settings/Customize panel being
  illustrated so the reader's eye lands on the right control immediately.
- **Redact any personal account details.** This repo is public. Before
  saving, cover or crop out your email address, account name, avatar,
  organization name, billing details, or any other identifying
  information visible in the UI chrome.
- Keep the four filenames exactly as listed above — both install guides
  reference these paths directly (`screenshots/<file>.png`, relative to
  `docs/`).
- PNG format, reasonable size (a few hundred KB each is plenty — no need
  for full-resolution captures).

Once the four files are in place, re-run the asset-existence check from
the install-guide verification steps to confirm both guides resolve
cleanly.
