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

## Member A (Eric Huang): further AI use

- **Tool:** Claude (Anthropic), claude.ai app, used on 22-23 Oct 2026. Transcript: https://claude.ai/share/0541ec1f-3800-4813-aedb-b4d0ef022590
- **How:**
  - Step-by-step guidance on cloning the repo, branching, and committing only my own files.
  - Diagnosing why `data_prep.R` failed on the real workbook; I then edited it:
    - wellbeing pattern -> `^life_satisfaction$` (it had matched "CoV adjusted ladder");
    - footprint pattern -> `^ecological_footprint$` (it matched three columns);
    - skip chart-only sheets with `tryCatch()`;
    - relaxed the life-expectancy check to 10-95 after confirming CAR 2009 = 14.665 in the official file.
  - Suggesting chart customizations, which I added and tested: labels for the 3 highest and 3 lowest HPI countries (Chart 9); a dotted median-HPI reference line (Chart 18).
  - Drafting text for slides 2-3; the figures were computed from `data/hpi_clean.csv`.
- **Why:** to finish the data and chart work on time under the 31-hour deadline, and to debug unfamiliar Git and workbook issues quickly.
- **Verification:** ran `data_prep.R` (2,666 rows, 2006-2025, 134 countries in 2025); tested both chart functions in RStudio with the 2025 data before committing.

### Member B (Anu) — AI Use Disclosure

**AI tool:** OpenAI ChatGPT (GPT-6)

**Purpose:** I used ChatGPT to guide me through my assigned tasks for Hackathon 2.0, including understanding the Shiny application, testing interactive visualizations, GitHub collaboration, deployment, and presentation preparation.

**How AI was used:**

- Interpreting the assignment instructions and coordinator's framework.
- Setting up the GitHub repository and RStudio environment.
- Understanding `app.R`, `chart_bar.R`, Shiny reactivity, and linked brushing.
- Testing the scatter, bubble, and ranked bar charts.
- Troubleshooting GitHub permissions, branches, commits, and pull requests.
- Generating and deploying the application manifest on Posit Connect Cloud.
- Drafting Slides 4 and 5 and explaining visualization design principles.

**Verification:** The starter code was provided by the coordinator. I personally ran the application, tested the controls and linked brushing, completed GitHub commits, and verified that the published Shiny application was publicly accessible.

**AI conversation transcript:** [Insert full ChatGPT conversation link or transcript file link]

**Member B GitHub contribution:** https://github.com/nedretsencavus/hpi-hackathon/pull/3

**Published Shiny application:** https://01a16b64-521e-cc41-bb42-bf74300c9d4d.share.connect.posit.cloud
