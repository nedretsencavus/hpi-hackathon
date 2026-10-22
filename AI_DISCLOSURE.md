# Generative AI Disclosure: Hackathon 2.0

Required by the EPPS 6356 AI policy (syllabus, "AI Policy"): the full exchange, which tools, how, and why. Each member adds any further AI use under their own name.

## 1. The entire exchange

- Coordinator's planning conversation with Claude, [DATE]: [paste the share link or attach the exported transcript as `ai/claude_planning_transcript.pdf`].
- Most relevant parts: the task delegation, the Git workflow, and the starter code for `app.R`, `R/*.R`, `data-raw/data_prep.R`.
- [Member A: add any further exchanges.]
- [Member B: add any further exchanges.]

## 2. Which AI tools

- Claude (Anthropic), model Claude Opus 5.5, in the claude.ai web app, [plan: Free / Pro / UTD license].
- [Any other tool, with version and plan.]

## 3. How the tools were used

- Generated the team execution plan (roles, timeline, Git workflow, coordinator checklist).
- Generated starter code: data cleaning script, three chart functions, the Shiny app shell, the manifest script, and templates for this file, `SYNERGY.md`, and the website page.
- Team members then [describe: ran, debugged, changed, rewrote; list concrete changes, e.g. "rewrote column patterns in data_prep.R after inspecting the workbook", "changed bubble y-variable"].

## 4. Why the tools were used

[Example: to save time under a 31-hour deadline, to get a working reactive skeleton the team could test early, and to check chart choices against course readings.]

## Verification protocol

- Ran `data-raw/data_prep.R` and compared five countries' values with happyplanetindex.org by hand: [countries checked].
- Checked every chart title against the plotted data for at least two years.
- Confirmed bar axes start at zero and the bubble legend states that area encodes the size variable.
- Ran the deployed app at its public link from a logged-out browser.
