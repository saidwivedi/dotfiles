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
- argparse for all scripts with sensible defaults
- Always set random seeds for reproducibility
- Use `skip-if-exists` pattern for long-running batch jobs

## Communication
- One response per task: outcome first, then only detail that changes what I'd do next. No play-by-play during work, no filler, no pleasantries, no emojis
- Ask clarifying questions when the ask itself is ambiguous — unclear scope, multiple reasonable interpretations, unstated constraints. Surface the ambiguity before implementing, don't silently pick
- Don't ask for permission ("want me to run it?", "should I proceed?") — mode shortcuts below cover that
- Focus on technical accuracy over validation

## Subagent Policy
- Offload ALL script execution, testing, analysis, research, and exploration to subagents — use them liberally
- Main agent only: planning, decomposition, dispatching, judging results, quick bash checks (job status, ls, git), and bookkeeping edits (trackers, notes, config files). Never implement — delegate for context isolation; only conclusions return to main
- Micro-edit exception: file already fully in main context and the fix is a few unambiguous lines → main edits directly
- Anything that loads models, processes data, or takes >10s → subagent (background when possible); never block main on long-running commands
- Independent checks → parallel subagents in one dispatch; hard problems → more agents (independent attempts, adversarial verification), not longer thought
- One task per subagent. A subagent's "done" is a claim — verify against the completion artifact (diff, test output, on-disk file)

### Model Routing — every dispatch names a tier deliberately
- plan / decompose → `planner-fable`
- production code, hard logic, edge cases, architecture (spec complete) → `opus-implementer`
- one-off scripts, mechanical fully-specified edits → `sonnet-implementer`
- audits, code search, web research, info gathering → `sonnet-scout` (trust positives with file:line, never negatives)
- stuck / second opinion → `codex:codex-rescue` — it diagnoses, you own the call; not a re-implementer
- implementation where the hard part IS the implementation → un-typed `general-purpose` (inherits the MAIN model — the top tier; deliberate use only, never a lazy default)
- Escalation on failure: opus attempt 1 → opus with the failure folded into a sharper spec → un-typed (main-model) with full history → last resort: main itself, in a worktree
- The MAIN model (set by `/model`, not any agent file) runs the orchestrator and any un-typed agent — keep it strong (Fable-class): judgment compounds in main, cost lives in the tiers
- Never set `CLAUDE_CODE_SUBAGENT_MODEL` to a concrete model — it overrides every agent's `model:` and flattens all tiers to one. Leave it unset

## Mode Shortcuts
- Errors, logs, failing tests, or CI I point at: diagnose root cause and fix immediately — no clarifying questions; suggest the re-run command
- "Check results": read metrics.json (or equivalent) from all relevant subdirs, build a comparison table, flag best/worst and anomalies

## Documentation
- Never create unsolicited READMEs, architecture diagrams, or summary docs
- Never create "quick start" or "cheat sheet" files unless asked
- Don't create test files or example usage files unprompted
- Don't create wrapper scripts unless they add real value

## Research Conventions
- Output folder names MUST start with `MMDD_` prefix (e.g. `outputs/0308_baseline/`); never overwrite an existing dated folder — bump the date or add a suffix
- Save metrics as `metrics.json` in output folders
- Log to wandb during training
- Compare against baselines before declaring success
- Document what DOESN'T work as thoroughly as what does
- Failed experiments: move to `failed/` subdirectory, don't delete
- Exploration scripts go in `explore/`, promoted to main modules when validated

## Token Conservation
- Use TodoWrite efficiently — don't update for every tiny step
- When inspecting images visually, always downscale first (e.g. ~512px on the long side) and read the low-res copy; only read full-res if low-res leaves a question unanswered

## Workflow

- Non-trivial work (3+ steps, open design decisions, failed first fix, fuzzy scope) → enter plan mode before building
- If something goes sideways mid-task, STOP and re-plan immediately — don't keep pushing

### Surgical Changes
- Touch only what the request requires — every changed line should trace back to the ask
- Don't "improve" adjacent code, comments, or formatting in unrelated files
- Don't refactor what isn't broken; match existing style even if you'd write it differently
- Only remove imports/vars/functions that YOUR changes orphaned — leave pre-existing dead code alone (mention it, don't delete it)
- If multiple reasonable interpretations exist, name them and pick one explicitly — don't silently choose and proceed

### Learn From Corrections
- After ANY correction: internalize the pattern, don't repeat the mistake
- Write rules for yourself that prevent the same class of error
- Ruthlessly iterate until mistake rate drops
- Log the generalized lesson (strip all project-specific details) to the mistakes file matching its scope:
  - General/operational, cross-cutting — repo & file hygiene, git, communication → `~/.claude/agent-mistakes.md`
  - Domain-specific operational → a per-domain file in `~/.claude/mistakes/` (created as lessons accumulate), indexed from `agent-mistakes.md`
  - Research methodology — experiment design, result interpretation, scientific reasoning → `~/.claude/skills/research-collaborator/agent-mistakes.md`
  - Format: `- **[Pattern name.]** [what not to do and why; what to do instead]`, one line per entry
- Boundary vs auto-memory: mistakes files hold generalized behavioral rules (how to work, project-stripped); auto-memory holds facts and project state (what is true). A correction that only makes sense inside one project → auto-memory; one that generalizes → mistakes file. Never both

Global mistakes log (auto-loaded before work): @~/.claude/agent-mistakes.md

