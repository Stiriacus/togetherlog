# Claude Code – Project Context & Operating Mode

This file defines how Claude Code must operate inside the TogetherLog monorepo when launched from the terminal or VS Code.

## 1. Project Purpose
TogetherLog is a Flutter + Supabase application with a backend-authoritative architecture and a milestone-based roadmap. All functional, architectural, and design rules are defined inside:
- docs/v1Spez.md
- docs/architecture.md
- CONTEXT.md
- docs/MILESTONES.md
- backend and app READMEs

Claude Code must ALWAYS interpret these as the single sources of truth.

## 2. Mandatory Tools Available
Claude Code may use the following tools exactly as a human engineer would:

- **Git** (commit, branch, diff, rebase, etc.)
- **Flutter CLI** (`flutter run`, `flutter build`, `flutter analyze`)
- **Supabase CLI**
- **Supabase MCP server** (for schema, RLS, API, DB inspection)
- **curl / REST API testing**
- **Dart & TypeScript compilers / formatters**

Claude Code must execute commands only after planning and verifying correctness.

## 3. Repository Knowledge
Before taking any action, Claude Code must read:
- README.md
- CONTEXT.md
- docs/v1Spez.md
- docs/architecture.md
- docs/v2optional.md
- docs/MILESTONES.md
- backend/* README files
- app/* README files

Claude must understand:
- Flutter folder structure under /app
- Supabase backend under /backend/supabase
- Edge Function layout and REST API routes
- Current milestone progress (8/12 complete)

## 4. Development Workflow (STRICT)
Claude Code must always follow:

READ → ANALYZE → PLAN → CODE → BACKTEST → FIX → COMMIT → NEXT

Detailed rules:

1. **READ**  
   Load all relevant docs and repo files for the milestone.

2. **ANALYZE**  
   Confirm repo structure, previous milestones, missing dependencies, and alignment with architecture.

3. **PLAN**  
   List the files to modify/create, expected logic, potential risks, and required CLI commands.

4. **CODE**  
   Modify files cleanly and deterministically.  
   Flutter = lean UI only.  
   Backend = authoritative logic only.

5. **BACKTEST**  
   - Validate imports and file paths  
   - Run flutter analyze (when applicable)  
   - Use Supabase MCP (schema checks, RLS validation)  
   - Test REST endpoints with curl  
   - Ensure the implementation matches v1Spez + architecture

6. **FIX**  
   Resolve issues before committing.

7. **COMMIT**  
   Commit only after a complete milestone or sub-milestone:  
   Format:
   `feat(milestone-X): completed tasks, backtested`

8. **NEXT**  
   Identify and prepare next milestone.

## 5. Architectural Rules (MANDATORY)
- Backend authoritative: all Smart Page logic, color engines, layouts, and image processing run server-side.
- Flutter is render-only: no Smart Page computation.
- No feature drift: implement only what’s inside docs/v1Spez.md and the active milestone.
- Clean architecture for Flutter (core / data / features).
- SQL migrations evolve schema; Edge Functions implement backend logic.

## 6. Allowed Automatic Behaviors
Claude Code may:
- generate/update files
- create missing folders
- run flutter/supabase/git/curl commands
- validate schemas or policies via Supabase MCP
- execute backtesting steps

Claude Code may NOT:
- invent new features
- modify concepts defined in v1Spez.md
- bypass architecture rules

## 7. Milestone Progress
Completed: 0–8  
Current: Milestone 9 (Flutter Logs feature)  
Next: Milestones 10–12

Claude must always:
- restate its understanding of the current milestone  
- produce a task breakdown  
- follow the milestone exactly as written in MILESTONES.md

---

This short description provides Claude Code the operational framework it needs to work reliably inside the TogetherLog repo.
