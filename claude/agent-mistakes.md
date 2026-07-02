# Agent Mistakes — Global

Cross-cutting lessons (non-research). Read before non-trivial work; append a generalized one-liner when corrected. Research-methodology lessons → research-collaborator skill's `agent-mistakes.md`. Format: `- **[Name.]** [what not to do; do instead]`.

---

## Repo & File Hygiene
- **Public-repo leak past a keyword scan.** Grepping names/paths misses leaks in example strings (experiment codenames, output-folder names in "e.g." snippets); diff vs the prior/template version and genericize every concrete example.

## Git
- **Committing flagged content as "not pushed yet."** A commit is permanent history a later cleanup commit won't purge (only a rewrite does); sanitize flagged/sensitive content before staging, not before push.
