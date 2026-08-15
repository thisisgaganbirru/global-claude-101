# Badges & Design Reference

Visual conventions, badge URL formulas, dark/light mode patterns, collapsible sections,
GitHub Alerts, and design decisions. Read this during Phase 5.

---

## Table of Contents

1. [Badge System](#1-badge-system)
2. [Dark / Light Mode Images](#2-dark--light-mode-images)
3. [GitHub Alerts](#3-github-alerts)
4. [Collapsible Sections](#4-collapsible-sections)
5. [Table of Contents Patterns](#5-table-of-contents-patterns)
6. [Emoji Conventions](#6-emoji-conventions)
7. [Typography & Structure Conventions](#7-typography--structure-conventions)
8. [Design Anti-Patterns](#8-design-anti-patterns)

---

## 1. Badge System

### Core Rules

- **5–8 badges maximum** — beyond this, visual noise hurts first impressions
- **Consistent style** — never mix `flat` and `for-the-badge` in the same row
  - `flat` → project READMEs (recommended default)
  - `for-the-badge` → profile READMEs, design-heavy landing pages
- **Order convention**: CI/CD → Coverage → Version → Downloads → License → Social
- Every badge must be clickable and link to its resource

### Badge URL Formula (Shields.io)

```
https://img.shields.io/badge/{LABEL}-{MESSAGE}-{HEX_COLOR}?style={STYLE}&logo={SLUG}&logoColor=white
```

- `{LABEL}` — left side text (leave empty for logo-only: use `badge/-MESSAGE-COLOR`)
- `{HEX_COLOR}` — without `#` prefix (e.g., `0078D7` not `#0078D7`)
- `{SLUG}` — from simpleicons.org (exact match required as of July 2024)
- `{STYLE}` — `flat`, `flat-square`, `plastic`, `for-the-badge`, `social`

### CI/CD Badges

**GitHub Actions:**
```markdown
[![CI](https://github.com/OWNER/REPO/actions/workflows/ci.yml/badge.svg)](https://github.com/OWNER/REPO/actions/workflows/ci.yml)
```

**With branch filter:**
```markdown
[![CI](https://github.com/OWNER/REPO/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/OWNER/REPO/actions/workflows/ci.yml)
```

### Coverage Badges

**Codecov:**
```markdown
[![Coverage](https://codecov.io/gh/OWNER/REPO/branch/main/graph/badge.svg)](https://codecov.io/gh/OWNER/REPO)
```

**Coveralls:**
```markdown
[![Coverage Status](https://coveralls.io/repos/github/OWNER/REPO/badge.svg?branch=main)](https://coveralls.io/github/OWNER/REPO)
```

### Version / Package Badges

**npm:**
```markdown
[![npm](https://img.shields.io/npm/v/PACKAGE?style=flat&logo=npm)](https://www.npmjs.com/package/PACKAGE)
```

**PyPI:**
```markdown
[![PyPI](https://img.shields.io/pypi/v/PACKAGE?style=flat&logo=pypi&logoColor=white)](https://pypi.org/project/PACKAGE)
```

**Crates.io (Rust):**
```markdown
[![Crates.io](https://img.shields.io/crates/v/CRATE?style=flat&logo=rust)](https://crates.io/crates/CRATE)
```

**Go module:**
```markdown
[![Go Reference](https://pkg.go.dev/badge/MODULE_PATH.svg)](https://pkg.go.dev/MODULE_PATH)
```

### Download / Popularity Badges

**npm weekly downloads:**
```markdown
[![npm downloads](https://img.shields.io/npm/dm/PACKAGE?style=flat)](https://www.npmjs.com/package/PACKAGE)
```

**PyPI monthly downloads:**
```markdown
[![Downloads](https://img.shields.io/pypi/dm/PACKAGE?style=flat)](https://pypi.org/project/PACKAGE)
```

**Bundle size (npm only):**
```markdown
[![Bundle Size](https://img.shields.io/bundlephobia/minzip/PACKAGE?style=flat)](https://bundlephobia.com/package/PACKAGE)
```

### License Badges

**Dynamic (reads from repo):**
```markdown
[![License](https://img.shields.io/github/license/OWNER/REPO?style=flat)](LICENSE)
```

**Static by SPDX identifier:**
```markdown
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
```

### Tech Stack Badges (for "Built With" sections)

Pattern: `logo` slug from simpleicons.org, `logoColor=white`, color from brand guidelines.

```markdown
[![TypeScript](https://img.shields.io/badge/TypeScript-3178C6?style=flat&logo=typescript&logoColor=white)](https://www.typescriptlang.org)
[![Next.js](https://img.shields.io/badge/Next.js-000000?style=flat&logo=nextdotjs&logoColor=white)](https://nextjs.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=flat&logo=postgresql&logoColor=white)](https://www.postgresql.org)
[![Redis](https://img.shields.io/badge/Redis-DC382D?style=flat&logo=redis&logoColor=white)](https://redis.io)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)](https://www.docker.com)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-06B6D4?style=flat&logo=tailwindcss&logoColor=white)](https://tailwindcss.com)
[![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)](https://python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=flat&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![React](https://img.shields.io/badge/React-61DAFB?style=flat&logo=react&logoColor=black)](https://react.dev)
[![Rust](https://img.shields.io/badge/Rust-000000?style=flat&logo=rust&logoColor=white)](https://www.rust-lang.org)
```

### GitHub-Specific Social Badges

```markdown
[![GitHub Stars](https://img.shields.io/github/stars/OWNER/REPO?style=social)](https://github.com/OWNER/REPO/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/OWNER/REPO?style=social)](https://github.com/OWNER/REPO/network/members)
[![GitHub Issues](https://img.shields.io/github/issues/OWNER/REPO?style=flat)](https://github.com/OWNER/REPO/issues)
[![GitHub PRs](https://img.shields.io/github/issues-pr/OWNER/REPO?style=flat)](https://github.com/OWNER/REPO/pulls)
```

### MSRV Badge (Rust)

```markdown
[![MSRV](https://img.shields.io/badge/MSRV-1.70.0-orange?style=flat&logo=rust)](https://blog.rust-lang.org/2023/06/01/Rust-1.70.0.html)
```

### HuggingFace Badges (ML Projects)

```markdown
[![Model on HF](https://huggingface.co/datasets/huggingface/badges/resolve/main/model-on-hf-sm.svg)](https://huggingface.co/OWNER/MODEL)
[![Dataset on HF](https://huggingface.co/datasets/huggingface/badges/resolve/main/dataset-on-hf-sm.svg)](https://huggingface.co/datasets/OWNER/DATASET)
[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/OWNER/REPO/blob/main/notebooks/quickstart.ipynb)
```

---

## 2. Dark / Light Mode Images

### Recommended: `<picture>` Element (Web Standard)

Works on GitHub and all other platforms. This is the canonical approach:

```html
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./docs/assets/logo-dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="./docs/assets/logo-light.svg">
  <img alt="ProjectName logo" src="./docs/assets/logo-light.svg" height="64">
</picture>
```

**Notes:**
- Use SVG for logos (scales cleanly at any size)
- `height` attribute controls display size; don't set both width and height (preserves aspect ratio)
- The final `<img>` is the fallback for platforms that don't support `<picture>`
- Path must be relative to README location

### Avoid: `#gh-dark-mode-only` / `#gh-light-mode-only` Fragments

```markdown
![logo](./logo-dark.png#gh-dark-mode-only)   ← GitHub-only, shows both on other platforms
![logo](./logo-light.png#gh-light-mode-only) ← Avoid for portability
```

These are GitHub-proprietary and render both images on GitLab, npm, and other platforms
that display README content. Use `<picture>` instead.

### Screenshots / Product Images

For screenshots that need dark/light variants (e.g., UI with dark mode):

```html
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./docs/assets/screenshot-dark.png">
  <source media="(prefers-color-scheme: light)" srcset="./docs/assets/screenshot-light.png">
  <img alt="App screenshot showing dashboard" src="./docs/assets/screenshot-light.png" width="800">
</picture>
```

---

## 3. GitHub Alerts

GitHub Alerts render with colored callout boxes in GitHub markdown (launched late 2023).
Use these instead of bold text or emoji for callouts.

### Syntax

```markdown
> [!NOTE]
> Useful information that users should know, even when skimming.

> [!TIP]
> Helpful advice for doing things better or more easily.

> [!IMPORTANT]
> Key information users need to know to achieve their goal.

> [!WARNING]
> Urgent info that needs immediate user attention to avoid problems.

> [!CAUTION]
> Advises about risks or negative outcomes of certain actions.
```

### When to Use Each Type

| Alert | Use for |
|---|---|
| `NOTE` | Version requirements, platform notes, optional context |
| `TIP` | Shortcut approaches, recommended patterns, power-user hints |
| `IMPORTANT` | Breaking changes, env var requirements, auth setup |
| `WARNING` | Deprecated features, security considerations, irreversible actions |
| `CAUTION` | Data loss risk, production-only behaviors, destructive commands |

### Usage Examples in READMEs

**Prerequisites warning:**
```markdown
> [!WARNING]
> This package requires Node.js ≥ 18.0. Node 16 is not supported and will produce
> cryptic errors. Run `node --version` before installing.
```

**Breaking change notice:**
```markdown
> [!IMPORTANT]
> **Breaking change in v2.0**: The `config.database` key has been renamed to
> `config.db`. Update your configuration file before upgrading.
```

**Security note:**
```markdown
> [!CAUTION]
> Never commit your `.env` file to version control. The API keys in `.env.example`
> are intentionally invalid placeholders.
```

---

## 4. Collapsible Sections

### Syntax

```markdown
<details>
<summary>Click to expand: Advanced Configuration</summary>

Content here renders as normal Markdown. **Bold works.** `code` works.

\```python
# Code blocks work too
config = {"key": "value"}
\```

</details>
```

**Critical requirement:** There must be a **blank line after `</summary>`** for Markdown
to render correctly inside the `<details>` block. Without it, content renders as raw HTML.

### What to Collapse vs. Keep Visible

**Always collapse:**
- Multi-platform installation alternatives (the primary platform is visible)
- Full API reference (show 2–3 examples visible, link or collapse full ref)
- Verbose configuration options (show essential ones visible)
- Changelog (link to CHANGELOG.md; never inline)
- Full troubleshooting guide (keep 2–3 most common issues visible)
- Advanced usage / edge cases

**Always keep visible:**
- Project description and value proposition
- Minimum viable installation (most common platform)
- Quick start / minimal usage example
- License
- Badge row

### Nested Collapsible Sections

Works on GitHub, but wrap inner `<details>` in a `<blockquote>` to improve reliability:

```html
<details>
<summary>Outer section</summary>

<blockquote>
<details>
<summary>Inner section</summary>

Content here.

</details>
</blockquote>

</details>
```

---

## 5. Table of Contents Patterns

### When to Add a Manual TOC

- README exceeds ~100 lines **or** has 5+ major sections
- GitHub's auto-generated TOC (hamburger icon, since March 2021) is sufficient for most
  READMEs — manual TOC is redundant for shorter files

### Format

Use anchor links. GitHub auto-generates anchors from headings (lowercase, spaces → dashes):

```markdown
## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
  - [Basic Usage](#basic-usage)
  - [Advanced Usage](#advanced-usage)
- [Configuration](#configuration)
- [API Reference](#api-reference)
- [Contributing](#contributing)
- [License](#license)
```

### Anchor Generation Rules (GitHub)

- Lowercase all characters
- Replace spaces with `-`
- Remove: `.`, `,`, `!`, `?`, `:`, `;`, `(`, `)`, `'`, `"`
- Example: `## API Reference (v2)` → `#api-reference-v2`

### Auto-generation Tools

```bash
# doctoc (npx, no install needed)
npx doctoc README.md --github

# markdown-toc
npx markdown-toc -i README.md
```

---

## 6. Emoji Conventions

### When to Use Emoji

Emoji in section headings aid visual scanning. Use them **only** when:
- The project is aimed at developers (not enterprise/corporate audience)
- They reinforce the section meaning (not purely decorative)
- Used sparingly — max one per heading

### Recommended Emoji per Section

| Section | Emoji |
|---|---|
| Installation / Quick Start | 🚀 |
| Features | ✨ or ⭐ |
| Configuration | 🔧 or ⚙️ |
| Usage / Examples | 💡 or 📖 |
| Contributing | 🤝 |
| Roadmap | 🗺️ or 📍 |
| Changelog | 📝 |
| Security | 🔒 |
| Performance | ⚡ |
| Requirements / Prerequisites | 📋 |
| License | 📄 |
| Community / Support | 💬 |

### In-line Emoji Usage

```markdown
- ✅ Feature that works as expected
- ❌ Feature not yet supported
- 🚧 Work in progress
- ⚠️ Requires attention
```

### When NOT to Use Emoji

- Enterprise / corporate internal tools
- Research / academic projects
- Security-focused tools
- Any audience where professional seriousness matters
- In code examples, API documentation, or technical specifications

---

## 7. Typography & Structure Conventions

### Heading Hierarchy

```markdown
# H1 — Project name only. One per README.
## H2 — Major sections (Installation, Usage, etc.)
### H3 — Sub-sections within a major section
#### H4 — Used sparingly; deeply nested content should be in a separate file
```

Never skip heading levels (don't go from H2 to H4).

### Code Block Language Hints

Always specify a language for syntax highlighting:

```markdown
\```bash      ← shell commands
\```sh        ← POSIX shell (use bash unless POSIX required)
\```python
\```typescript
\```javascript
\```json
\```yaml
\```toml
\```sql
\```markdown  ← for README-in-README examples
\```text      ← for plain output with no syntax
\```
           ← never leave blank — use \```text for unformatted output
```

### Link Conventions

- **Repo-internal links**: Always relative (`./docs/contributing.md`, not full GitHub URL)
  - Relative links work across forks, mirrors, and local clones
- **External links**: Full URL with HTTPS
- **Section links**: Lowercase anchor format (`[see configuration](#configuration)`)

### Tables

Use tables for: env vars, feature comparisons, API parameters, command references, ownership.
Do NOT use tables for: prose content, installation steps, code examples.

Alignment conventions:
```markdown
| Name | Type | Required | Description |
|---|---|---|---|          ← left-align all (most readable)
```

### Version Numbers

Always pin exact versions in prerequisites and requirements:
- ✅ `Node.js ≥ 18.0` / `Python ≥ 3.11` / `Rust ≥ 1.70`
- ❌ `Node.js` / `Python 3` / `recent Rust`

---

## 8. Design Anti-Patterns

These patterns are heavily criticized by the developer community and actively hurt
project perception. Never produce a README with these patterns.

### ❌ Marketing language
Never use: "easy", "simple", "blazing fast", "enterprise-grade", "cutting-edge",
"world-class", "powerful", "seamless", "intuitive", "just works", "obviously"

Senior engineers read these words and immediately trust the README less.

### ❌ Giant decorative GIFs above the fold
Animated GIFs as hero images that take 3+ seconds to load, consume the first screenful,
and contain no useful technical information. Show a terminal recording of the tool working,
or a product screenshot — not a design flourish.

### ❌ Auto-generated contributor walls
The `contrib.rocks` image or similar that fills half the README with avatar tiles.
Contributions are tracked in git history. This adds noise, not signal.

### ❌ Badge overload
More than 8–10 shields.io badges. Beyond this threshold, the badge row reads as status
anxiety, not signal. Projects with the most stars (Ollama, Turborepo) often have zero or
one badge.

### ❌ Inline changelog
Pasting the full changelog into the README. Changelogs belong in `CHANGELOG.md` (Keep a
Changelog format), linked from the README.

### ❌ README as marketing landing page
FAQs as social proof, testimonial quotes, competitor comparison tables framed as attack
ads, "Why choose us" sections. Engineers find these actively off-putting.

### ❌ Code examples without output
Showing 20 lines of code with no indication of what it produces. Always show expected
output — as a comment, a separate code block, or a screenshot.

### ❌ Stale version numbers
Installation commands showing an old version that returns 404 or installs deprecated code.
Always derive version numbers from the actual config files.

### ❌ Broken relative links
Links to `./CONTRIBUTING.md` when no such file exists, or links using absolute GitHub URLs
that break on forks. Validate all internal links before publishing.

### ❌ Inconsistent heading style
Mixing ATX (`# Heading`) and Setext (`Heading\n=======`) styles. Pick ATX (standard modern
practice) and use it throughout.
