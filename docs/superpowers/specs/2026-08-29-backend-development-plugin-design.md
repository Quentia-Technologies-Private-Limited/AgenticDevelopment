# Development Plugin — Design Document

**Date**: 2026-08-29
**Status**: Approved
**Author**: Brainstorming session with Claude Code

---

## Overview

A multi-agent development pipeline packaged as a Claude Code plugin (`dev-made-easy`). The plugin provides six coordinated agents that take a task description from ideation through planning, implementation, code review, testing, and documentation — producing structured artifacts at every stage.

Designed to be shared with the GitHub community as a self-contained, installable plugin.

---

## Goals

- Enforce consistent development practices (OOP, Factory Pattern, SOLID)
- Produce structured, version-controlled artifacts at every pipeline stage
- Reduce cognitive overhead by automating agent handoffs
- Be language-agnostic with sensible defaults (Python, Next.js, PostgreSQL, Redis)
- Be accessible to the GitHub community with a one-command install

---

## Non-Goals

- Does not manage deployment/infrastructure beyond Docker Compose setup
- Does not integrate with external project management tools (Jira, Linear) in v1
- Does not run agents in parallel (strict linear pipeline for v1)

---

## Architecture

### Pipeline

```
User → Orchestrator → Planning → [USER GATE] → Development → [USER GATE]
                   → Code Review → Testing → Documentation
```

- **User approval gates** after Planning and Development
- **Auto-chain** from Code Review through Documentation
- Each agent writes structured output to `docs/specs/{task_title}/`

### Agents

| # | Agent | Model | Gate |
|---|-------|-------|------|
| 0 | Orchestrator | claude-opus-4-6 | — |
| 1 | Planning | claude-opus-4-6 | USER APPROVAL |
| 2 | Development | claude-opus-4-6 | USER APPROVAL |
| 3 | Code Review | claude-opus-4-6 | auto-chain |
| 4 | Testing | claude-opus-4-6 | auto-chain |
| 5 | Documentation | claude-opus-4-6 | auto-chain |

### Orchestrator Responsibilities

- Accept task description from user
- Derive `task_title` slug from task description
- Create `docs/specs/{task_title}/` directory
- Invoke each agent in sequence via the Agent tool
- Display live pipeline status dashboard
- Pause at approval gates and resume on user confirmation
- Display final pipeline summary

---

## Artifact Structure

For each task, artifacts are written to:

```
docs/specs/{task_title}/
├── 01-product-spec.md          ← Planning Agent
├── 02-acceptance-criteria.md   ← Planning Agent
├── 03-db-schema.md             ← Planning Agent
├── 04-api-contracts.md         ← Planning Agent
├── 05-implementation-notes.md  ← Development Agent
├── 06-review-report.md         ← Code Review Agent
└── issues/
    ├── issue-001.md             ← Testing Agent (one per bug)
    ├── issue-002.md
    └── ...
```

Final documentation output:
- `README.md` — project root
- `docs/API.md` — full API reference
- `CHANGELOG.md` — versioned changelog
- Inline docstrings in all source files

---

## Technology Defaults

| Layer | Default | Alternatives |
|-------|---------|-------------|
| Backend Language | Python | Go, Node.js, Java, Ruby |
| Backend Framework | FastAPI | Django, Flask, Express, Gin, Spring Boot |
| Frontend | Next.js | React, Vue, None |
| Database | PostgreSQL | MySQL, MongoDB, SQLite |
| Cache | Redis | Memcached, None |
| Auth | JWT | OAuth2, API Key, Session |
| Containerisation | Docker Compose | None |

Development Agent asks the user to confirm or override defaults before writing code.

---

## Design Principles

All generated code must follow:

- **OOP with Factory Pattern**: All services created via factory methods, never directly instantiated in route handlers
- **SOLID Principles**: Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion
- **Repository Pattern**: All DB access through repositories; services contain business logic only
- **Layer Separation**: API → Service → Repository → Database
- **Naming Conventions**: snake_case (Python), camelCase (TypeScript/JS), PascalCase for classes in all languages

---

## Issue Triage Model

Testing Agent logs one file per issue scored across four dimensions (1–5):

| Dimension | High Score Means |
|-----------|-----------------|
| Impact | System broken or majorly degraded |
| Feasibility to Fix | Trivial or straightforward fix |
| Customer Experience Impact | Blocks or severely degrades user experience |
| Revenue Impact | Directly causes revenue loss |

**Priority Rules:**
- `MANDATORY` — Impact ≥ 4 AND Customer Experience ≥ 4, OR Revenue Impact ≥ 4
- `HIGH` — any single dimension ≥ 4
- `MEDIUM` — composite score ≥ 10
- `LOW` — composite score < 10

---

## Plugin Distribution

```
dev-made-easy/
├── README.md          ← Community install guide
├── install.sh         ← Copies agents to .claude/agents/
├── LICENSE            ← MIT
└── agents/
    ├── 00-orchestrator.md
    ├── 01-planning.md
    ├── 02-development.md
    ├── 03-code-review.md
    ├── 04-testing.md
    └── 05-documentation.md
```

---

## Future Work (v2)

- Deployment Agent (CI/CD pipeline generation)
- Security Agent (OWASP scanning, dependency vulnerability checks)
- Jira/Linear integration for issue logging
- Parallel agent execution for Code Review + Testing
