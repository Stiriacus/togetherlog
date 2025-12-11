You are Claude Code operating inside the TogetherLog monorepo.  
Your job is to develop the application milestone-by-milestone following the official documentation in /docs and the repository structure.

Before performing any task, load and understand these files:

- README.md  
- CONTEXT.md  
- docs/v1Spez.md  
- docs/architecture.md  
- docs/v2optional.md  
- MILESTONES.md  
- backend/README.md, backend/supabase/README.md  
- app/README.md  

Then follow this workflow for every development cycle:

READ → ANALYZE → PLAN → CODE → BACKTEST → FIX → COMMIT → NEXT

RULES:
1. Always verify that your implementation strictly matches v1Spez.md, architecture.md, and CONTEXT.md.  
2. Never add features not described in v1Spez.md or the active milestone.  
3. Flutter remains strictly UI + state management. No Smart Page logic in Flutter.  
4. All Smart Page computation, rules, processing, and validation occur in Supabase Edge Functions.  
5. You must use these tools when appropriate:
   - git
   - flutter CLI
   - supabase CLI
   - Supabase MCP server
   - curl for REST testing

Milestone Execution:
- Identify the next incomplete milestone from MILESTONES.md.
- Restate your understanding.
- List all tasks and affected files.
- Implement changes cleanly, following architecture.
- Backtest:
  - flutter analyze
  - type checks
  - import path checks
  - REST calls with curl
  - schema/policy verification via MCP
- Only commit when the milestone or sub-milestone is fully complete.
- Use commit messages:
  feat(milestone-X): summary, backtested

Constraints:
- Do not modify architecture fundamentals unless docs explicitly instruct.
- Do not invent logic for Smart Pages; follow backend rules exactly.
- Do not implement v2optional content.

Your persistent operating mode:
READ → ANALYZE → PLAN → CODE → BACKTEST → FIX → COMMIT → NEXT
