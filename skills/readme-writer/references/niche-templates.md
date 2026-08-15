# Niche Templates Reference

Deep structural guidance for each project niche. Read the relevant section(s) during Phase 6.
A project may belong to multiple niches — apply all relevant sections.

---

## Table of Contents

1. [OSS Libraries & CLI Tools](#1-oss-libraries--cli-tools)
2. [SaaS / Web Applications](#2-saas--web-applications)
3. [AI / ML Projects](#3-ai--ml-projects)
4. [Internal Tooling / Monorepos](#4-internal-tooling--monorepos)

---

## 1. OSS Libraries & CLI Tools

### Required Sections (in order)

```
Badges             ← ecosystem-specific badges (see below)
# Name
Description
Installation       ← ALL supported package managers
Usage              ← three-tier progressive complexity
API Reference      ← or link to full docs
Configuration      ← flags, options, config file
Examples           ← link to /examples dir
Contributing
Changelog          ← link to CHANGELOG.md (Keep a Changelog format)
License
```

### Badge Row — Ecosystem Specifics

**Node.js / npm packages:**
```markdown
[![npm](https://img.shields.io/npm/v/PACKAGE-NAME?style=flat&logo=npm)](https://www.npmjs.com/package/PACKAGE-NAME)
[![npm downloads](https://img.shields.io/npm/dm/PACKAGE-NAME?style=flat)](https://www.npmjs.com/package/PACKAGE-NAME)
[![Bundle Size](https://img.shields.io/bundlephobia/minzip/PACKAGE-NAME?style=flat)](https://bundlephobia.com/package/PACKAGE-NAME)
[![Build](https://github.com/OWNER/REPO/actions/workflows/ci.yml/badge.svg)](https://github.com/OWNER/REPO/actions/workflows/ci.yml)
[![Coverage](https://codecov.io/gh/OWNER/REPO/branch/main/graph/badge.svg)](https://codecov.io/gh/OWNER/REPO)
[![License](https://img.shields.io/github/license/OWNER/REPO?style=flat)](LICENSE)
```

**Python packages (PyPI):**
```markdown
[![PyPI](https://img.shields.io/pypi/v/PACKAGE-NAME?style=flat&logo=pypi&logoColor=white)](https://pypi.org/project/PACKAGE-NAME)
[![Python](https://img.shields.io/pypi/pyversions/PACKAGE-NAME?style=flat&logo=python&logoColor=white)](https://pypi.org/project/PACKAGE-NAME)
[![Build](https://github.com/OWNER/REPO/actions/workflows/ci.yml/badge.svg)](https://github.com/OWNER/REPO/actions/workflows/ci.yml)
[![Coverage](https://codecov.io/gh/OWNER/REPO/branch/main/graph/badge.svg)](https://codecov.io/gh/OWNER/REPO)
[![License](https://img.shields.io/github/license/OWNER/REPO?style=flat)](LICENSE)
```

**Rust crates:**
```markdown
[![Crates.io](https://img.shields.io/crates/v/CRATE-NAME?style=flat&logo=rust)](https://crates.io/crates/CRATE-NAME)
[![Crates.io Downloads](https://img.shields.io/crates/d/CRATE-NAME?style=flat)](https://crates.io/crates/CRATE-NAME)
[![docs.rs](https://img.shields.io/docsrs/CRATE-NAME?style=flat&logo=docs.rs)](https://docs.rs/CRATE-NAME)
[![MSRV](https://img.shields.io/badge/MSRV-1.70-orange?style=flat&logo=rust)](https://www.rust-lang.org)
[![Build](https://github.com/OWNER/REPO/actions/workflows/ci.yml/badge.svg)](https://github.com/OWNER/REPO/actions/workflows/ci.yml)
[![License](https://img.shields.io/crates/l/CRATE-NAME?style=flat)](LICENSE)
```

### Installation Section — All Package Manager Paths

Show every installation path in separate, independently copy-pasteable fenced blocks:

```markdown
## Installation

**npm / Node.js**
\```bash
npm install package-name
\```

**yarn**
\```bash
yarn add package-name
\```

**pnpm**
\```bash
pnpm add package-name
\```

**bun**
\```bash
bun add package-name
\```

For global install (CLI tools only):
\```bash
npm install -g package-name
# or run without installing:
npx package-name
\```
```

**Python equivalent:**
```markdown
\```bash
pip install package-name
# or with uv (recommended):
uv add package-name
# or with pipx (CLI tools):
pipx install package-name
\```
```

### Usage — Three-Tier Progressive Complexity

**Tier 1 — Minimal hello world** (inline, ≤10 lines, shows expected output):

```markdown
## Usage

\```python
from mylib import Client

client = Client(api_key="...")
result = client.process("hello")
print(result)  # → "HELLO (processed)"
\```
```

**Tier 2 — Common real-world scenario** (show what 90% of users actually need):

```markdown
### Common Usage: Batch Processing

\```python
from mylib import Client, BatchOptions

client = Client(api_key=os.environ["API_KEY"])
results = client.batch(
    items=["a", "b", "c"],
    options=BatchOptions(parallel=True, timeout=30)
)
# results → [ProcessedItem(id=0, ...), ...]
\```
```

**Tier 3 — Advanced / Edge cases** (collapse or link to examples):

```markdown
<details>
<summary>Advanced: Custom middleware, retry logic, streaming</summary>

See [`/examples`](./examples) for:
- [Custom retry policies](./examples/retry.py)
- [Streaming responses](./examples/streaming.py)
- [Webhook integration](./examples/webhooks.py)

</details>
```

### CLI Tool Specifics

For CLI tools, immediately after installation show:
1. `--help` output (or a subset)
2. The single most useful command with real arguments
3. Subcommand tree if complex

```markdown
## Usage

\```
$ mytool --help
Usage: mytool [OPTIONS] COMMAND [ARGS]...

  One-line description of what mytool does.

Options:
  --config PATH  Config file path  [default: ~/.mytool.yml]
  --verbose      Enable verbose output
  --help         Show this message and exit.

Commands:
  run     Execute a job
  init    Initialize a new project
  status  Check job status
\```

**Quick start:**
\```bash
mytool init my-project
mytool run --input data.csv --output results/
# → Processing 1,042 rows... done in 2.3s
\```
```

### Contributing Section Template

```markdown
## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](./CONTRIBUTING.md) for the full
guide. Quick summary:

1. Fork the repository and create a branch: `git checkout -b feat/your-feature`
2. Make your changes and add tests
3. Run the test suite: `npm test` (all tests must pass)
4. Open a pull request against `main`

For bugs, open an [issue](../../issues) before submitting a PR.
```

---

## 2. SaaS / Web Applications

### Required Sections (in order)

```
Badges             ← build, coverage, deploy status
Hero header        ← centered logo + tagline + product screenshot
Action links       ← View Demo · Documentation · Report Bug
Features           ← 4–6 bullet points, value-first
Tech Stack         ← explicit, linked, version-pinned
Prerequisites      ← exact versions + system requirements
Installation       ← Docker (recommended) + manual
Environment Vars   ← full .env table
Running Locally    ← numbered steps to get to a running state
Deployment         ← Docker Compose / Vercel / Railway / self-hosted
Architecture       ← Mermaid diagram + component descriptions
API Reference      ← or link to Swagger/Postman docs
Contributing
License
```

### Hero Header Pattern (Supabase/Cal.com style)

```markdown
<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="./docs/assets/logo-dark.svg">
    <source media="(prefers-color-scheme: light)" srcset="./docs/assets/logo-light.svg">
    <img alt="ProjectName logo" src="./docs/assets/logo-light.svg" width="200">
  </picture>

  <h3>Project Name</h3>
  <p>One-line description. What it does and why it exists.</p>

  [![Build](https://github.com/OWNER/REPO/actions/workflows/ci.yml/badge.svg)](...)
  [![License](https://img.shields.io/github/license/OWNER/REPO)](LICENSE)

  <p>
    <a href="https://demo.yourapp.com">View Demo</a>
    ·
    <a href="https://docs.yourapp.com">Documentation</a>
    ·
    <a href="../../issues/new?template=bug.md">Report Bug</a>
    ·
    <a href="../../issues/new?template=feature.md">Request Feature</a>
  </p>
</div>

---

![Product Screenshot](./docs/assets/screenshot.png)
```

### Environment Variables Table

Group by service category. Mark required fields clearly.

```markdown
## Environment Variables

Copy `.env.example` to `.env` and populate the following:

### Database
| Variable | Required | Default | Description |
|---|---|---|---|
| `DATABASE_URL` | ✅ | — | PostgreSQL connection string |
| `DATABASE_POOL_SIZE` | ❌ | `10` | Connection pool size |
| `DATABASE_SSL` | ❌ | `false` | Enable SSL for DB connections |

### Authentication
| Variable | Required | Default | Description |
|---|---|---|---|
| `AUTH_SECRET` | ✅ | — | JWT signing secret (min 32 chars) |
| `AUTH_EXPIRY` | ❌ | `7d` | JWT expiry duration |
| `GOOGLE_CLIENT_ID` | ❌ | — | Google OAuth client ID |

### Email
| Variable | Required | Default | Description |
|---|---|---|---|
| `SMTP_HOST` | ✅ | — | SMTP server hostname |
| `SMTP_PORT` | ❌ | `587` | SMTP port |
| `SMTP_FROM` | ✅ | — | Sender email address |

> [!IMPORTANT]
> Never commit `.env` to version control. The `.env.example` file is safe to commit.
```

### Installation — Docker-First Pattern

```markdown
## Installation

### Docker (recommended)

Prerequisites: Docker ≥ 24.0, Docker Compose ≥ 2.20

\```bash
git clone https://github.com/OWNER/REPO.git
cd REPO
cp .env.example .env          # edit with your values
docker compose up -d
\```

The app will be available at http://localhost:3000.

### Manual Setup

Prerequisites: Node.js ≥ 20 LTS, PostgreSQL ≥ 15, Redis ≥ 7

\```bash
git clone https://github.com/OWNER/REPO.git
cd REPO
npm install
cp .env.example .env          # edit with your values
npm run db:migrate
npm run db:seed               # optional: load sample data
npm run dev
\```
```

### One-Click Deploy Buttons

```markdown
## Deployment

[![Deploy to Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/OWNER/REPO)
[![Deploy to Railway](https://railway.app/button.svg)](https://railway.app/new/template?template=https://github.com/OWNER/REPO)
[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/OWNER/REPO)
```

### Architecture Diagram (SaaS)

Include a system architecture diagram using C4Context or flowchart TD. See
`mermaid-patterns.md` for exact syntax. Example structure to document:

- Client (browser / mobile)
- Load balancer / CDN
- API gateway / BFF
- Core application services
- Background job workers
- Database layer (primary + replica)
- Cache layer (Redis)
- External integrations (auth, email, payments, storage)

---

## 3. AI / ML Projects

### Required Sections (in order)

```
Badges             ← build, HuggingFace hub link, license, arxiv
Model Card Header  ← YAML frontmatter (see below)
Description        ← what the model does, not how it works
Quick Start        ← pipeline-first, highest abstraction first
Hardware Req       ← explicit table, minimum + recommended
Benchmarks         ← table with datasets, metrics, comparisons
Training / Fine-tuning  ← how to retrain/adapt
Dataset            ← provenance, license, access instructions
Reproducibility    ← exact seed, hardware, command, expected output
Model Architecture ← Mermaid diagram of pipeline
Citation           ← BibTeX block
License
Ethics / Limitations
```

### HuggingFace YAML Metadata Header

Place at the very top of README.md (before any other content) for HF Hub integration:

```markdown
---
language:
  - en
license: apache-2.0
tags:
  - text-classification
  - transformers
  - pytorch
datasets:
  - squad
  - common_crawl
metrics:
  - f1
  - accuracy
model-index:
  - name: model-name
    results:
      - task:
          type: text-classification
          name: Text Classification
        dataset:
          type: squad
          name: SQuAD
          split: validation
        metrics:
          - type: f1
            value: 91.2
            name: F1
          - type: accuracy
            value: 88.7
            name: Accuracy
---
```

### Quick Start — Pipeline-First Pattern (Transformers style)

```markdown
## Quick Start

\```python
# Highest-level API first — most users only need this
from transformers import pipeline

classifier = pipeline("text-classification", model="owner/model-name")
result = classifier("This is a test sentence.")
# → [{'label': 'POSITIVE', 'score': 0.9987}]
\```

<details>
<summary>Advanced: Direct model loading, custom tokenizer, batching</summary>

\```python
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch

tokenizer = AutoTokenizer.from_pretrained("owner/model-name")
model = AutoModelForSequenceClassification.from_pretrained("owner/model-name")

inputs = tokenizer("Hello world", return_tensors="pt")
with torch.no_grad():
    outputs = model(**inputs)
logits = outputs.logits
\```

</details>
```

### Hardware Requirements Table

```markdown
## Hardware Requirements

| Component | Minimum | Recommended |
|---|---|---|
| GPU | RTX 3080 (10GB VRAM) | A100 (40GB VRAM) |
| RAM | 16 GB | 64 GB |
| Storage | 10 GB | 50 GB NVMe SSD |
| Training time (1 epoch) | ~8 hours | ~45 minutes |

> [!NOTE]
> CPU-only inference is supported but ~50x slower. Set `device="cpu"` in the pipeline call.

**Software prerequisites:**
- Python ≥ 3.11
- PyTorch ≥ 2.1 with CUDA 11.8+
- Transformers ≥ 4.36
```

### Benchmark Table

```markdown
## Benchmarks

Results are zero-shot unless noted. Eval code: [`scripts/eval.py`](./scripts/eval.py)

| Dataset | Task | Metric | **This Model** | GPT-4o | Llama-3-70B | Previous SOTA |
|---|---|---|---|---|---|---|
| SQuAD 2.0 | QA | F1 | **91.2** | 92.1 | 88.4 | 90.7 |
| MMLU | MC | Accuracy | **76.4** | 87.2 | 79.3 | 74.0 |
| HellaSwag | Completion | Accuracy | **83.1** | 95.3 | 87.7 | 81.9 |

Bold = this model's result. All comparisons use identical prompts and eval protocol.
```

### Reproducibility Section

```markdown
## Reproducibility

All results were produced with this exact command:

\```bash
python train.py \
  --dataset squad \
  --model-name bert-large-uncased \
  --seed 42 \
  --epochs 3 \
  --batch-size 16 \
  --lr 2e-5
\```

**Environment:**
- Hardware: 2x A100 80GB, Ubuntu 22.04
- PyTorch 2.1.0, CUDA 11.8, transformers 4.36.2
- Full pinned dependencies: [`requirements-lock.txt`](./requirements-lock.txt)

Expected F1: 91.2 ± 0.3 (variance across 3 seeds: 42, 123, 456)
```

### Citation Block

```markdown
## Citation

\```bibtex
@misc{authorname2024modelname,
  title         = {Model Name: Description of Paper},
  author        = {Last, First and Last, First},
  year          = {2024},
  eprint        = {2401.00000},
  archivePrefix = {arXiv},
  primaryClass  = {cs.CL},
  url           = {https://arxiv.org/abs/2401.00000}
}
\```
```

### Ethics / Limitations Section

Required for any public ML model:

```markdown
## Limitations & Ethics

**Known limitations:**
- Performance degrades on low-resource languages (< 0.1% of training data)
- Exhibits recency bias: events after [CUTOFF DATE] are not reflected
- Not evaluated for medical, legal, or financial advice use cases

**Out-of-scope use:**
This model should not be used for surveillance, generating disinformation,
or any application that affects high-stakes decisions without human oversight.

**Bias and fairness:**
Evaluated on [DATASET]. Gender and racial bias metrics: see [`eval/bias_report.md`](./eval/bias_report.md).
```

---

## 4. Internal Tooling / Monorepos

### Required Sections (in order)

```
# Repo Name
Status + ownership badges (internal CI link)
One-line description + team scope
Repository overview (what lives here)
Getting Started (zero to productive ≤ 15 min)
Directory Structure (code tree + descriptions)
Packages / Apps index
Architecture Diagram
Development Workflow (commands table)
Ownership Table
ADR Index
Operations (runbooks + dashboards)
Contributing
```

### Directory Structure Block

```markdown
## Repository Structure

\```
monorepo/
├── apps/
│   ├── web/          # Next.js customer-facing app (@acme/web)
│   ├── api/          # Express REST API (@acme/api)
│   └── admin/        # Internal admin dashboard (@acme/admin)
├── packages/
│   ├── ui/           # Shared React component library (@acme/ui)
│   ├── config/       # Shared ESLint/TS/Prettier configs (@acme/config)
│   ├── database/     # Prisma schema + migrations (@acme/database)
│   └── utils/        # Shared utility functions (@acme/utils)
├── infra/            # Terraform + Kubernetes configs
├── .github/
│   ├── workflows/    # CI/CD pipelines
│   └── CODEOWNERS    # Package ownership
└── docs/             # Architecture docs + ADRs
\```
```

### Packages / Apps Index Table

```markdown
## Packages & Apps

| Package | Version | Description | Docs |
|---|---|---|---|
| `@acme/web` | 2.4.1 | Customer-facing Next.js application | [README](apps/web/README.md) |
| `@acme/api` | 1.8.0 | Core REST API, Express + Fastify | [README](apps/api/README.md) |
| `@acme/ui` | 3.1.0 | Shared design system components | [Storybook](https://ui.acme.com) |
| `@acme/database` | 1.2.0 | Prisma ORM, migrations, seeds | [README](packages/database/README.md) |
| `@acme/config` | 1.0.0 | Shared tooling configs | [README](packages/config/README.md) |
```

### Getting Started — Zero to Productive

Target: any new team member running for the first time. Number every step.

```markdown
## Getting Started

**Prerequisites:** Node.js 20 LTS, Docker ≥ 24.0, pnpm ≥ 8.0

\```bash
# 1. Clone and install
git clone https://github.com/org/repo.git && cd repo
pnpm install

# 2. Set up environment
cp .env.example .env.local      # fill in required values (see .env.example comments)

# 3. Start infrastructure
docker compose up -d            # starts postgres, redis, localstack

# 4. Set up database
pnpm db:migrate                 # run migrations
pnpm db:seed                    # load dev fixture data

# 5. Start all apps
pnpm dev
\```

Apps available at:
- Web: http://localhost:3000
- API: http://localhost:4000
- Admin: http://localhost:3001
- API Docs: http://localhost:4000/docs

**First tasks for new team members:**
- [ ] Read [ADR-001: Monorepo Decision](./docs/adr/001-monorepo.md)
- [ ] Read [Architecture Overview](./docs/architecture.md)
- [ ] Pick a [`good-first-issue`](../../labels/good-first-issue) ticket
- [ ] Join #eng-team-name on Slack
```

### Development Commands Table

```markdown
## Development Commands

| Command | Description |
|---|---|
| `pnpm dev` | Start all apps in development mode |
| `pnpm build` | Build all packages and apps |
| `pnpm test` | Run all tests |
| `pnpm test --filter=@acme/api` | Run tests for a specific package |
| `pnpm lint` | Lint all packages |
| `pnpm db:migrate` | Run pending database migrations |
| `pnpm db:seed` | Seed development database |
| `pnpm db:studio` | Open Prisma Studio (visual DB browser) |
| `pnpm changeset` | Create a changeset for versioning |
| `pnpm release` | Publish changed packages to npm |
```

### Ownership Table

```markdown
## Ownership

| Package / Area | Team | Slack | CODEOWNERS |
|---|---|---|---|
| `apps/web` | Frontend | `#team-frontend` | [`@org/frontend`](../.github/CODEOWNERS) |
| `apps/api` | Platform | `#team-platform` | `@org/platform` |
| `packages/database` | Platform | `#team-platform` | `@org/platform` |
| `packages/ui` | Design Systems | `#team-design-systems` | `@org/design-systems` |
| `infra/` | Infrastructure | `#team-infra` | `@org/infra` |
| CI/CD | Infrastructure | `#team-infra` | `@org/infra` |
```

### ADR Index Table

```markdown
## Architecture Decisions

| ADR | Decision | Status | Date |
|---|---|---|---|
| [ADR-001](./docs/adr/001-monorepo.md) | Use Turborepo for monorepo tooling | Accepted | 2023-09 |
| [ADR-002](./docs/adr/002-database.md) | PostgreSQL + Prisma as primary data layer | Accepted | 2023-10 |
| [ADR-003](./docs/adr/003-auth.md) | Auth.js for authentication | Accepted | 2024-01 |
| [ADR-004](./docs/adr/004-api-versioning.md) | URL-based API versioning (/v1/, /v2/) | Proposed | 2024-03 |

Full list: [`docs/adr/`](./docs/adr/)
```

### Operations Section

```markdown
## Operations

| Service | Runbook | Dashboard | On-Call |
|---|---|---|---|
| API | [Runbook](./docs/runbooks/api.md) | [Datadog](https://app.datadoghq.com/...) | `#oncall-platform` |
| Database | [Runbook](./docs/runbooks/database.md) | [RDS Console](https://console.aws.amazon.com/...) | `#oncall-platform` |
| Web | [Runbook](./docs/runbooks/web.md) | [Vercel](https://vercel.com/...) | `#oncall-frontend` |
| Infra | [Runbook](./docs/runbooks/infra.md) | [Grafana](https://grafana.acme.com) | `#oncall-infra` |
```
