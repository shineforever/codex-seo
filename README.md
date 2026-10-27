<!--
  Codex SEO (codex-seo): free, open-source SEO audit skill suite for OpenAI Codex CLI.
  A Codex CLI port of claude-seo by Agrici Daniel.
  Technical SEO, Core Web Vitals, E-E-A-T, Schema.org, AI search (GEO), local SEO, e-commerce and international SEO.
  26 sub-skills and 19 specialist role playbooks. MIT licensed.
-->

<img src="assets/readme/v3/hero.svg" width="1200" height="420" alt="Codex SEO: rank in Google, get cited by AI. Three bots climb from #48 to #1 by fixing crawl, speed, schema, AI access and authority, then Google, ChatGPT, Perplexity, Gemini and Claude cite the site." />

<h1 align="center">Codex SEO</h1>

<p align="center">
  <b>Free, open-source SEO audits inside <a href="https://developers.openai.com/codex">OpenAI Codex CLI</a>.</b><br />
  Rank higher in Google and get cited by AI search.
</p>

<p align="center">
  <a href="#install">Install</a> ·
  <a href="#see-it-in-action">Demo</a> ·
  <a href="#real-results">Results</a> ·
  <a href="#meet-the-team">Team</a> ·
  <a href="#commands">Commands</a> ·
  <a href="#pricing">Pricing</a> ·
  <a href="#faq">FAQ</a>
</p>

<p align="center">
  <a href="https://github.com/zhtyyx/codex-seo/actions/workflows/ci.yml"><img src="https://github.com/zhtyyx/codex-seo/actions/workflows/ci.yml/badge.svg" alt="CI" /></a>
  <a href="https://developers.openai.com/codex"><img src="https://img.shields.io/badge/Codex%20CLI-Skills-blue" alt="Codex CLI skills" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT" /></a>
  <a href="tests/"><img src="https://img.shields.io/badge/tests-1000%2B%20passing-brightgreen" alt="Tests" /></a>
  <a href="https://github.com/AgriciDaniel/claude-seo"><img src="https://img.shields.io/badge/port%20of-claude--seo-8A2BE2" alt="Port of claude-seo" /></a>
</p>

**Codex SEO is a free SEO skill suite for OpenAI Codex CLI.** Give it any website and it runs a full SEO audit, then hands you a clear action plan, sorted by what matters most.

It checks everything a good SEO consultant would:

- **Technical SEO.** Crawlability, indexing, sitemaps, robots.txt, redirects, page speed and Core Web Vitals.
- **Content quality.** E-E-A-T (experience, expertise, authority and trust), thin pages and topic coverage.
- **Structured data.** Finds, validates and writes Schema.org markup for rich results.
- **AI search (GEO).** How likely Google AI Overviews, AI Mode, ChatGPT, Perplexity and Gemini are to cite your pages.
- **Local and e-commerce SEO.** Google Business Profile, reviews, map pack, product pages and international sites.

Codex SEO is built from 26 sub-skills and 19 specialist role playbooks: a full audit walks through every analyst role (technical, content, schema, speed, AI search and more), persisting each role's findings along the way. Every recommendation explains why it matters and how you will know it worked.

## See it in action

Type `/seo` in Codex CLI to see every command (or mention a skill directly, like `$seo audit`):

![Codex SEO /seo command demo](screenshots/seo-command-demo.gif)

(Demos above are from the upstream claude-seo project; the workflow is identical in Codex CLI.)

## Real results

The upstream project's site, [claude-seo.md](https://claude-seo.md), audited with Claude SEO from day one: 10.8K Search Console clicks in its first 12 weeks and a 99 mobile PageSpeed score.

<img src="assets/readme/screen.svg" width="1200" height="751" alt="Real results: Google Search Console showing 10.8K clicks and 324K impressions for a new site between 23 March and 12 June 2026, next to a PageSpeed Insights report scoring 99 for performance and 100 for SEO." />

## Meet the team

<img src="assets/readme/v3/team.svg" width="1200" height="420" alt="The Codex SEO team: 19 specialist roles on a website, each standing on the part it checks, shown one at a time with its role and command." />

<details>
<summary><b>All 19 agents</b></summary>
<br />

| Agent | Role | Model | Command |
|---|---|---|---|
| `seo-technical` | Technical SEO Lead | default | `/seo technical` |
| `seo-content` | Content Editor | default | `/seo content` |
| `seo-schema` | Structured Data Engineer | default | `/seo schema` |
| `seo-sitemap` | Sitemap Architect | default | `/seo sitemap` |
| `seo-performance` | Performance Engineer | default | `/seo audit` |
| `seo-visual` | Visual QA | default | `/seo audit` |
| `seo-geo` | AI Search Analyst | default | `/seo geo` |
| `seo-agentic` | Agent Readiness Analyst | default | `/seo agentic` |
| `seo-local` | Local SEO Specialist | default | `/seo local` |
| `seo-maps` | Maps Analyst | default | `/seo maps` |
| `seo-google` | Google Data Analyst | default | `/seo google` |
| `seo-backlinks` | Link Analyst | default | `/seo backlinks` |
| Live data (extension) | Live Data Analyst | default | `/seo audit` |
| `seo-image-gen` | Image Producer (extension) | default | `/seo image-gen` |
| `seo-cluster` | Topic Strategist | default | `/seo cluster` |
| `seo-sxo` | Search Experience Designer | default | `/seo sxo` |
| `seo-drift` | Change Monitor | default | `/seo drift` |
| `seo-ecommerce` | E-commerce Specialist | default | `/seo ecommerce` |
| `seo-flow` | FLOW Strategist | default | `/seo flow` |

</details>

**Built for:**

- **SEO agencies** that want weekly audits for every client instead of quarterly ones, with change monitoring to catch problems in between.
- **In-house SEO teams** at SaaS, publishing and e-commerce companies that want a second pair of eyes before every review, AI search included.
- **Freelance SEO consultants** who want to run an audit on the first call and show a real score and the top fixes before writing a proposal.

## Commands

<img src="assets/readme/v3/map.svg" width="1200" height="420" alt="The six groups of SEO commands on a map: audits, technical SEO, content, schema and AI search, local and commerce, and extensions. The crew walks the path and each of the 30 commands is ticked off." />

30 core and extension commands in six groups. Open one to see what is inside; a few more extension commands are in the [full command reference](docs/COMMANDS.md).

<details>
<summary><b>Audits and Planning</b> (5 commands)</summary>
<ul><li><code>/seo setup</code>: Create or refresh the isolated Python runtime and Chromium</li><li><code>/seo doctor</code>: Check runtime readiness without changing the system</li><li><code>/seo audit &lt;url&gt;</code>: Full website audit with parallel agents</li><li><code>/seo page &lt;url&gt;</code>: Deep single-page analysis</li><li><code>/seo plan &lt;type&gt;</code>: Strategic SEO planning (saas, local, ecommerce, publisher, agency)</li></ul>
</details>
<details>
<summary><b>Technical SEO</b> (7 commands)</summary>
<ul><li><code>/seo technical &lt;url&gt;</code>: Technical SEO audit across 9 categories</li><li><code>/seo sitemap &lt;url | generate&gt;</code>: Analyze or generate XML sitemaps</li><li><code>/seo images &lt;url&gt;</code>: Image optimization analysis</li><li><code>/seo hreflang &lt;url&gt;</code>: Hreflang and i18n SEO audit and generation</li><li><code>/seo programmatic &lt;url&gt;</code>: Programmatic SEO analysis and planning</li><li><code>/seo google [command]</code>: Google SEO APIs: GSC, PageSpeed, CrUX, Indexing, GA4, PDF reports</li><li><code>/seo drift baseline | compare | history &lt;url&gt;</code>: SEO drift monitoring with SQLite snapshots</li></ul>
</details>
<details>
<summary><b>Content and E-E-A-T</b> (6 commands)</summary>
<ul><li><code>/seo content &lt;url&gt;</code>: E-E-A-T and content quality analysis</li><li><code>/seo content-brief &lt;topic&gt;</code>: Content brief: target keywords, outline, internal links</li><li><code>/seo cluster &lt;keyword&gt;</code>: SERP-based semantic clustering</li><li><code>/seo sxo &lt;url&gt;</code>: Search Experience Optimization: page type, user stories, personas</li><li><code>/seo flow [stage]</code>: FLOW framework prompts (CC BY 4.0, evidence-led)</li><li><code>/seo competitor-pages &lt;url&gt;</code>: Competitor comparison page generation</li></ul>
</details>
<details>
<summary><b>Schema and AI Search</b> (3 commands)</summary>
<ul><li><code>/seo schema &lt;url&gt;</code>: Detect, validate and generate Schema.org markup</li><li><code>/seo geo &lt;url&gt;</code>: AI Overviews and Generative Engine Optimization</li><li><code>/seo agentic &lt;url&gt;</code>: Agent readiness: Lighthouse Agentic Browsing X/N, AI agent access, llms.txt, Markdown, WebMCP</li></ul>
</details>
<details>
<summary><b>Local, Links, Commerce</b> (4 commands)</summary>
<ul><li><code>/seo local &lt;url&gt;</code>: Local SEO: GBP, citations, reviews, map pack</li><li><code>/seo maps [command]</code>: Maps intelligence: geo-grid, GBP audit, reviews, competitors</li><li><code>/seo backlinks &lt;url&gt;</code>: Backlink profile analysis (Moz, Bing, Common Crawl)</li><li><code>/seo ecommerce &lt;url&gt;</code>: E-commerce SEO and marketplace intelligence</li></ul>
</details>
<details>
<summary><b>Extensions</b> (5 commands)</summary>
<ul><li><code>/seo image-gen [use-case]</code>: AI image generation for SEO assets</li><li><code>/seo seranking [command]</code>: AI Share-of-Voice across ChatGPT, Gemini, Perplexity, AI Overviews, AI Mode</li><li><code>/seo profound [command]</code>: LLM citation tracking with time-series data</li><li><code>/seo bing [command] &lt;url&gt;</code>: Bing Webmaster Tools + IndexNow URL submission</li><li><code>/seo unlighthouse &lt;url&gt;</code>: Multi-page Lighthouse runner, runs locally</li></ul>
</details>

## Pricing

<img src="assets/readme/v3/shop.svg" width="1200" height="420" alt="Same items, two shops: an agency charges for an SEO audit, reporting, calls and a retainer while Codex SEO charges nothing. Over year one the agency total reaches $106,500. Illustrative pricing." />

<details>
<summary><b>The full comparison</b></summary>
<br />

| | Doing it by hand | Hiring an agency | SEO audit software | **Codex SEO** |
|---|---|---|---|---|
| **Time per audit** | 4 to 8 hours | 1 to 3 weeks | 10 to 45 minutes | **10 to 15 minutes** |
| **Cost** | Billable hours | $2k to $15k+ per project | $99 to $999 a month | **Free, with your Codex CLI plan** |
| **Consistent checks** | Depends on who does it | Depends on the team | Yes | **Same checklist every time** |
| **What you get** | A spreadsheet or PDF | A slide deck | A dashboard and CSV exports | **Markdown, PDF and JSON files you keep** |
| **Your data stays with you** | Yes | No | No | **Yes, it runs on your machine** |
| **Covers AI search** | Depends | Depends | Often months behind | **Yes, follows Google's latest guidance** |
| **Each fix comes with a way to check it worked** | Sometimes | Sometimes | Rarely | **Yes** |

> Typical market prices, for illustration. Your numbers may differ.

</details>

## How an audit works

1. **It learns your site.** Codex SEO detects the type of business (SaaS, local, e-commerce, publisher or agency) and adjusts its checks.
2. **The team lines up.** Up to 17 specialist roles audit the site in sequence: technical, content, schema, speed, AI search and more, each writing its findings as it finishes.
3. **You get a plan, not a pile of warnings.** Findings are scored and sorted into a prioritized action plan. Each recommendation says what it is based on, what it depends on and how you will know it worked.

Reports are saved as Markdown, and `/seo google report` turns them into a polished PDF.

<details>
<summary><b>See a real report</b>: the start of a schema audit</summary>

```markdown
# Schema Markup Report: rankenstein.pro/about

| Metric              | Value                                       |
|---------------------|---------------------------------------------|
| JSON-LD Blocks      | 3                                           |
| Schema Types        | Organization, WebSite, SoftwareApplication  |
| Critical Issues     | 2                                           |
| Warnings            | 5                                           |
| Passed Checks       | 18                                          |
| Overall Grade       | B+ (solid foundation, actionable gaps)      |

**Critical Issue:** The `founder` property only includes Daniel Agrici.
Benjamin Samar (Co-Founder and Technical Director) is displayed on the page
but absent from the schema. This content-schema mismatch can confuse search engines.
```

</details>

Want the details? Read the [methodology](skills/seo/references/thinking-framework.md) and the [architecture](docs/ARCHITECTURE.md).

## Install

<img src="assets/readme/v3/install.svg" width="1200" height="420" alt="Installing Codex SEO: add the marketplace, install the plugin, 26 skills and 19 agents arrive, /seo setup readies the browser, then /seo audit starts the first level." />

You need [OpenAI Codex CLI](https://developers.openai.com/codex) with skills support. Codex SEO installs as user-level skills plus a `/seo` custom prompt:

```bash
git clone --depth 1 https://github.com/zhtyyx/codex-seo.git
bash codex-seo/install.sh
```

The installer copies the 26 skills to `~/.agents/skills/` (where Codex discovers user skills), the `/seo` prompt to `~/.codex/prompts/seo.md`, and creates an isolated Python runtime. Then start Codex and run `/seo setup`, which prepares everything Codex SEO needs (its own Python environment and a headless browser) without touching the rest of your system. Run `/seo doctor` any time to check it.

Prefer to work from the repo? Codex also discovers skills from `.agents/skills` in a project: symlink or copy `skills/*` there and export nothing else.

<details>
<summary><b>Manual install: macOS and Linux</b></summary>
<br />

<img src="assets/readme/v3/plat-unix.svg" width="1200" height="260" alt="Manual install: macOS and Linux: the install typed out in a terminal" />

```bash
git clone --depth 1 https://github.com/zhtyyx/codex-seo.git
bash codex-seo/install.sh
```


</details>

<details>
<summary><b>Manual install: Windows (PowerShell)</b></summary>
<br />

<img src="assets/readme/v3/plat-win.svg" width="1200" height="260" alt="Manual install: Windows (PowerShell): the install typed out in a terminal" />

```powershell
git clone --depth 1 https://github.com/zhtyyx/codex-seo.git
powershell -ExecutionPolicy Bypass -File codex-seo\install.ps1
```

> **Why `git clone` instead of `irm | iex`?** Downloading and executing remote code without verification is a supply chain risk. The `git clone` approach lets you inspect `codex-seo\install.ps1` before running it.

</details>

**Your first audit:**

```bash
codex                                    # start Codex CLI

/seo audit https://example.com           # full site audit with a prioritized plan
#   or: $seo audit https://example.com   # mention the skill directly
/seo page https://example.com/pricing    # one page, in depth
/seo geo https://example.com             # how ready you are for AI search
/seo schema https://example.com          # check and generate structured data
/seo local https://example.com           # local SEO and Google Business Profile
```

## FAQ

<details>
<summary><b>What is Codex SEO?</b></summary>
<br />

A free, open-source SEO audit tool that runs inside Codex CLI. It checks technical SEO, Core Web Vitals, content quality, Schema.org structured data, AI search readiness, local SEO, e-commerce and international SEO, then gives you a prioritized action plan. It follows Google's own documentation, including the [AI Optimization Guide](https://developers.google.com/search/docs/fundamentals/ai-optimization-guide).

</details>

<details>
<summary><b>Is it really free?</b></summary>
<br />

Yes. It is MIT licensed, with no per-site pricing, no usage limits and no tracking. You only need Codex CLI. A few optional extensions connect to paid services where you bring your own account, but everything works without them.

</details>

<details>
<summary><b>Do I need API keys?</b></summary>
<br />

No. Codex SEO works out of the box. If you want real field data, you can connect free Google APIs (PageSpeed Insights, Chrome UX Report, Search Console and Google Analytics 4) with `/seo google setup`. Your keys stay on your machine.

</details>

<details>
<summary><b>How does it help with AI search like Google AI Overviews and ChatGPT?</b></summary>
<br />

Google says optimizing for AI search is still SEO, so Codex SEO starts with the basics that AI answers rely on: being indexed, fast and clear. Then `/seo geo` scores how easy your pages are to quote, checks that AI crawlers can reach them and looks at your brand's presence on Wikipedia, Reddit, YouTube and LinkedIn. `/seo agentic` checks how well AI agents can use your site.

</details>

<details>
<summary><b>Does it work on JavaScript sites like Next.js, React or Vue?</b></summary>
<br />

Yes. When a page needs JavaScript to show its content, Codex SEO opens it in a headless browser automatically, so single-page apps are audited as visitors see them.

</details>

<details>
<summary><b>How is it different from Screaming Frog or other SEO tools?</b></summary>
<br />

Crawlers like Screaming Frog crawl faster and deeper, and big SEO suites have their own backlink databases. Codex SEO does something else: it explains what it finds, sorts it by impact, covers AI search in depth and lets you ask follow-up questions in plain English. Many people use both.

</details>

<details>
<summary><b>Does my data leave my computer?</b></summary>
<br />

Codex SEO runs inside Codex CLI, so the pages and data it analyzes are sent to the OpenAI model backing your Codex session, the same as anything else you work on in Codex CLI. Reports are saved as files on your machine. No SEO service or other third party sees your data unless you connect an extension or API yourself. Besides the site you audit, some checks read public sources such as Wikipedia, Reddit and Common Crawl. See [PRIVACY.md](PRIVACY.md) for the full list.

</details>

<details>
<summary><b>Good to know: requirements, limits and uninstall</b></summary>
<br />

**Requirements.** OpenAI Codex CLI and Python 3.11 to 3.14. `/seo setup` installs the headless browser for you.

**Cost of a full audit.** A full `/seo audit` runs 17 specialist role passes in the main session, so it uses more tokens than a single-page check. Everything runs on the model your Codex session is configured with.

**Limits.** Without Google API keys, Core Web Vitals are lab estimates and indexing is inferred from the page. Pages that load key content only after scrolling or clicking can give noisy results.

**Uninstall.**

```bash
bash uninstall.sh        # from a clone; removes skills and the /seo prompt
```

</details>

## Extensions

Optional add-ons that bring in more data. Codex SEO works fully without them.

- **Banana:** AI images for SEO, from social previews to blog heroes ([Claude Banana](https://github.com/AgriciDaniel/banana-claude))
- **SE Ranking:** your share of voice in ChatGPT, Gemini, Perplexity and Google AI answers
- **Profound:** tracks when AI models cite your site
- **Bing Webmaster:** Bing data plus instant IndexNow submission
- **Unlighthouse:** Lighthouse scores for every page of your site

Setup guides live in [`extensions/`](extensions/).

## Star history

<a href="https://www.star-history.com/#zhtyyx/codex-seo&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=zhtyyx/codex-seo&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=zhtyyx/codex-seo&type=Date" />
    <img alt="Codex SEO GitHub stars over time" src="https://api.star-history.com/svg?repos=zhtyyx/codex-seo&type=Date" width="720" />
  </picture>
</a>

**Docs:** [Installation](docs/INSTALLATION.md) · [Commands](docs/COMMANDS.md) · [Architecture](docs/ARCHITECTURE.md) · [Troubleshooting](docs/TROUBLESHOOTING.md) · [Extensions setup](docs/MCP-INTEGRATION.md) · [Security](SECURITY.md) · [Privacy](PRIVACY.md) · [Contributors](CONTRIBUTORS.md)

## License and contributing

MIT License, see [LICENSE](LICENSE). Contributions are welcome: read [CONTRIBUTING.md](CONTRIBUTING.md) first and mention the checks you ran in your pull request.

## Credits

Codex SEO is a port of [Claude SEO](https://github.com/AgriciDaniel/claude-seo) by Agrici Daniel (MIT). See [LICENSE](LICENSE) and [CONTRIBUTORS.md](CONTRIBUTORS.md) for the full copyright and contributor notices.

