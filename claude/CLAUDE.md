# Global Preferences

These rules bias toward rigor over speed. For trivial tasks, use judgment and skip the ceremony. The rules are working if: diffs contain only lines that trace to the ask, ambiguity surfaces before implementation rather than after, and I rarely have to ask you to redo something.

## Identity
## Write about yourself, your active research interests, and the projects you are working on

## Environment
## HPC cluster paths, package-manager conventions, and anything specific to your working environment: @~/.claude/ENV.md

## Git Workflow
- Never add "Co-Authored-By: Claude" attribution in commits
- Never add "Generated with Claude Code" messages anywhere
- Keep commit messages clean and professional

## Destructive Operations — Always Confirm First
- Never run `rm -rf` without explicit confirmation, even on paths I appear to have specified
- Never run `git reset --hard` without explicit confirmation — it discards uncommitted work silently

## Code Style
- Only add comments where logic isn't self-evident
- argparse for all scripts with sensible defaults
- Always set random seeds for reproducibility
- Use `skip-if-exists` pattern for long-running batch jobs

## Communication
- Be concise. No recaps, no pleasantries
- Ask clarifying questions when the ask itself is ambiguous — unclear scope, multiple reasonable interpretations, unstated constraints. Surface the ambiguity before implementing, don't silently pick
- Don't ask for permission ("want me to run it?", "should I proceed?") — mode shortcuts below cover that
- Don't use emojis
- Focus on technical accuracy over validation
- One response per action — don't split into multiple messages
- Don't paraphrase what you just did — I saw it happen

## Subagent Policy
- Offload ALL script execution, testing, and analysis to subagents
- Main agent only: planning, dispatching to subagents, orchestrating loops/workflows, quick bash checks (job status, ls, git), and bookkeeping edits (trackers, notes). NEVER edit code directly — every code change routes to `opus-implementer` (important/production code) or `sonnet-implementer` (one-off scripts, small changes).
- Anything that loads models, processes data, or takes >10s → subagent (background when possible)
- Launch multiple subagents in parallel for independent checks
- Keep main context clean and responsive — never block on long-running commands

### Model Routing — always delegate via an explicit `subagent_type`
- The default/`Explore`/`Plan` agents have no pinned model and inherit the MAIN model, so un-typed delegation just clones the main and skips the tiers. Every delegation must name a tier:
  - plan / decompose → `planner-fable`
  - important/production code, hard logic, edge cases, architecture → `opus-implementer` (when stuck, ask `codex:codex-rescue` with a focused problem — it advises, you own the call — not a redundant re-implementer)
  - one-off scripts, small changes, mechanical fully-specified edits → `sonnet-implementer`
  - audits, code exploration/search, web research, gathering info from sources → `sonnet-scout`
- Never set `CLAUDE_CODE_SUBAGENT_MODEL` to a concrete model — it overrides every agent's `model:` and flattens all tiers to one. Leave it unset.
- The MAIN model (set by `/model`, not any agent file) is what the orchestrator's own turns and any un-typed agent run on — keep it cheap; the locked tiers above do the heavy work.

## When I Paste an Error
- Diagnose root cause and apply fix immediately
- Don't ask clarifying questions — read the traceback and relevant code
- Show the fix, suggest the re-run command

## When I Say "Run It"
- Execute the script, capture full output, analyze results
- Don't ask for confirmation — just run
- If it fails, diagnose and fix without waiting for me

## When I Say "Check Results"
- Read metrics.json (or equivalent) from all relevant subdirs
- Generate a comparison table
- Identify best/worst, flag anomalies

## Documentation
- Never create unsolicited READMEs, architecture diagrams, or summary docs
- Never create "quick start" or "cheat sheet" files unless asked
- Don't create test files or example usage files unprompted
- Don't create wrapper scripts unless they add real value

## Research Conventions
- Output folder names MUST start with `MMDD_` prefix (e.g. `outputs/0308_baseline/`)
- Save metrics as `metrics.json` in output folders
- Log to wandb during training
- Compare against baselines before declaring success
- Document what DOESN'T work as thoroughly as what does
- Failed experiments: move to `failed/` subdirectory, don't delete
- Exploration scripts go in `explore/`, promoted to main modules when validated

## Token Conservation
- Don't repeat yourself — no recap messages after completing work
- Don't write test files unless explicitly requested
- Skip status updates — be direct
- Don't create README files for simple implementations
- Use TodoWrite efficiently — don't update for every tiny step
- When inspecting images visually, always downscale first (e.g. ~512px on the long side) and read the low-res copy; only read full-res if low-res leaves a question unanswered

## Workflow

### Plan Before Build
- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately — don't keep pushing
- Use plan mode for verification steps, not just building
- Write detailed specs upfront to reduce ambiguity

### Subagent Strategy
- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One task per subagent for focused execution

### Surgical Changes
- Touch only what the request requires — every changed line should trace back to the ask
- Don't "improve" adjacent code, comments, or formatting in unrelated files
- Don't refactor what isn't broken; match existing style even if you'd write it differently
- Only remove imports/vars/functions that YOUR changes orphaned — leave pre-existing dead code alone (mention it, don't delete it)
- If multiple reasonable interpretations exist, name them and pick one explicitly — don't silently choose and proceed

### Verification Before Done
- Never mark a task complete without proving it works
- Transform vague asks into verifiable goals before starting: "fix the bug" → "write a test that reproduces it, then make it pass"; "add validation" → "tests for invalid inputs pass"
- Diff behavior between main and your changes when relevant
- Run tests, check logs, demonstrate correctness

### Demand Elegance, Find Root Causes
- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: step back and implement the clean solution
- No temporary patches that paper over a root cause — senior-engineer standards
- Skip the elegance pass for simple, obvious fixes — don't over-engineer

### Learn From Corrections
- After ANY correction: internalize the pattern, don't repeat the mistake
- Write rules for yourself that prevent the same class of error
- Ruthlessly iterate until mistake rate drops
- Log the generalized lesson (strip all project-specific details) to the mistakes file matching its scope:
  - General/operational — repo & file hygiene, git, tooling, communication → `~/.claude/agent-mistakes.md` (create if missing)
  - Research methodology — experiment design, result interpretation, scientific reasoning → `~/.claude/skills/research-collaborator/agent-mistakes.md`
  - Format: `- **[Pattern name.]** [what not to do and why; what to do instead]`, one line per entry

Global mistakes log (auto-loaded before work): @~/.claude/agent-mistakes.md

### Autonomous Bug Fixing
- When given a bug report: just fix it. Don't ask for hand-holding
- Point at logs, errors, failing tests — then resolve them
- Zero context switching required from the user
- Go fix failing CI tests without being told how

