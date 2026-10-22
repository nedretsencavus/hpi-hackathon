# Synergy Report: Hackathon 2.0

Team [TEAM NAME] · Coordinator: [NAME] · Submitted [DATE]

<!-- One page maximum. Replace every [bracket]. Keep each section to 2-4 sentences.
     Cite commit hashes or PR numbers so the grader can match claims to the history. -->

## Who did what

| Member | Role | Delivered (files) | Evidence |
|---|---|---|---|
| [Coordinator] | Coordination, integration, website, slides assembly | repo scaffold, `R/theme.R`, `website/`, `SYNERGY.md` | PR #[n], commits [hash] |
| [Member A] | Data; Charts 9 and 18 | `data-raw/data_prep.R`, `data/hpi_clean.csv`, `R/chart_scatter.R`, `R/chart_bubble.R` | PR #[n], #[n] |
| [Member B] | App, reactivity, deployment; Chart 3 | `app.R`, `R/chart_bar.R`, `manifest.json`, Connect Cloud | PR #[n], #[n] |

## How the parts were combined

[Example: Each member owned separate files, so branches merged without conflicts. A single schema for `data/hpi_clean.csv` (README) and a shared `R/theme.R` let the three chart functions be written in parallel and dropped into `app.R`, where one `reactive()` (`hpi_view`) feeds all three charts. The coordinator merged PRs in dependency order: data, charts, app, manifest.]

## What we did better together than alone

[Example: Member A's data checks found that GDP was missing for [n] countries; Member B turned that into a caption showing n per chart. Linking the brush on Chart 9 to Charts 18 and 3 needed the data, chart and app owners to agree on the `iso3` key.]

## What we would do differently

[Example: Agree on the data schema before writing any chart; deploy a placeholder app on day one to surface Connect Cloud problems early; run an axe-core accessibility check before submission.]

## AI use

Generative AI (Claude) was used for the execution plan and starter code; see `AI_DISCLOSURE.md` for the full account required by the syllabus.
