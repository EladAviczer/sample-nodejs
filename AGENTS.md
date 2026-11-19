<!-- TEAM_AI_DIRECTIVES START -->
# Team AI Directives

This project is bound by the team AI directives repository at `/Users/oren.sultan/refael/team-ai-directives`.

team-boot runs automatically at session start via the event hook (for agents with event support), injecting a lean orientation into the first user message with the team constitution, CDR index, Class Boots catalog, skills registry, and MCP servers.

If the team AI directives context is NOT in your system prompt or first user message (agent without event support), invoke the `team-boot` skill before responding to any task or question.

If team AI directives are unconfigured, invoke the `team-setup` skill.

Invoke the matching class boot when a task or decision matches a row — invoke it
at the START of the matching task, before planning the todo list and before
implementation, so the class context informs planning; never defer to session end
or post-hoc. When no local memory index exists in the current working directory
and the directory sits inside a workspace (detected via a `.gitmodules` marker
in an ancestor), the boot reads the workspace root's `docs/adlc/memory/` index
instead (the dual-read order applies: `docs/adlc/memory` first, legacy
`.adlc/memory` fallback).

## Class Boots

| Boot | Injects | Invoke When | Capture Via |
|--|--|--|--|
| architect-boot | ADR index (docs/adlc/memory/adr/ + legacy .adlc/memory/adr/) | architecture work; tech-stack/pattern choice | /architect-specify |
| product-boot | PDR index (docs/adlc/memory/pdr/ + legacy .adlc/memory/pdr/) | product/feature scope, personas, monetization | /product-specify |
| change-boot | ChDR index (docs/adlc/memory/chdr/chdr.md + legacy .adlc/memory/chdr.md) | change-history rationale, reverts, issue-linked commits, git commands w/ human-authored messages, authored PRs, CHANGELOG edits | /change-specify (mining: /change-init) |
| team-levelup | CDR module bodies (team-ai-directives) | CDR descriptor match; reusable team pattern | /team-levelup |
| tech-radar-boot | Tikal Tech Radar context | choosing/evaluating technology | radar context + /architect-specify |

Each class boot emits its class context section and its own searched line (_Searched N records, K matched._).

**Every response MUST include** a Team Context & Decisions section before the task answer (Status `in use` rows ground the session in accepted records; Status `pending` rows capture emerging decisions in the same table):

## Team Context & Decisions

| ID | Name | Type | Rel | Status | Clarify |
|--|--|--|--|--|--|
| CDR-YYYY-NNN | <name> | <type> | <relevance> | in use | — |
| — | <decision> | <ADR/PDR/CDR/ChDR/Eval> | <trigger> | pending | <clarify skill> |

Plus: `_Scope: N CDRs · A ADRs · P PDRs · C ChDRs · E evals · M skills — J rows shown · Unrecorded: N pending · Unclarified: M captured drafts._` — **J MUST equal the number of rows (any indexed type). Status `in use` + Clarify `—` = grounding context (accepted records only); Status `pending`/`captured`/`clarified`/`handed off` + Clarify skill = owed decisions. No draft row may carry Status `in use` — drafts appear only as pending decision rows. 0 rows matched → emit the section heading + the counts line only — no table. Zero rows means heading plus counts line only — never a table header. Emit one table row per line. (do not copy a hard-coded row or inflate the count).** Scope names the always-available layer and class indexes (counts only, never content) plus the session's open decisions; class boots append their own scope line when fired.

Render the section as markdown blocks — heading, table (when rows exist), and counts line each on their own lines. Before sending, if the section contains a pipe character but no newline, rewrite it.

## Decision Capture

Detect decisions as they emerge and suggest the matching capture skill — never write drafts or touch `.adlc/drafts/`; the capture skill writes the draft when the user runs it. Full detection and capture guidance lives in the matching class boot:

- Tech stack / pattern choice → ADR → /architect-specify (pull tech-radar-boot context first for tech selection)
- Feature scope / persona / monetization → PDR → /product-specify
- Reusable team rule / pattern → CDR → /team-levelup
- Revert/hotfix rationale / issue-linked commit → ChDR → /change-specify (mined history: /change-init)
- Eval criterion discovered → Eval → /evals-specify

Maintain the decision rows in the same table above (Status pending/captured/clarified/handed off + Clarify skill); with no pending decisions, emit the heading + the counts line only — no table.

At session end, deliver the clarify prompt naming each uncaptured decision (ID + capture skill) and each captured draft (ID + clarify skill); if the user defers clarify, mark those rows handed off. Only suggest capture when genuinely warranted.

Surface each detected decision as a task-list todo (suggest the capture skill — never write the draft yourself; the capture skill writes to `.adlc/drafts/{type}/` when the user runs it — then run the matching clarify skill at session end). After code-modifying tasks, add a trailing todo to sweep Team Context & Decisions until _Unrecorded: 0 pending · Unclarified: 0 drafts_ (a draft leaves Unclarified only via its clarify skill or an explicit user handoff to a named clarify or execute skill).
<!-- TEAM_AI_DIRECTIVES END -->
