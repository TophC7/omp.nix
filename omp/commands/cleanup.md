---
description: Review changed files for reuse, quality, and efficiency, then apply safe fixes.
---

Run the cleanup workflow against the current working tree.

Optional user focus: $ARGUMENTS
Treat an empty value as no additional focus.

1. Confirm the current directory is inside a Git repository. If not, stop with `/cleanup requires a git repository.`
2. Read `git status --porcelain`. If it is empty, stop with `/cleanup: no working-tree changes to review.`
3. Capture the exact, complete `git diff HEAD`. Do not summarize or truncate it. If it is empty, stop with `/cleanup: working tree changes produced an empty diff.`
4. Launch exactly one parallel `task` batch containing these three agents:
   - `cleanup-reuse-scout`
   - `cleanup-quality-scout`
   - `cleanup-efficiency-scout`
5. Give every scout the same full diff through one artifact or file path, plus the optional user focus. Each task must tell the scout to read that diff, inspect the repository where needed, and return findings only. Do not launch any other review agent.
6. Wait for all three scouts. If you created a temporary filesystem diff, remove it after every scout has finished.
7. Apply the combined findings directly to the working tree.

Apply rules:
1. Do not re-derive findings unless needed to verify safety.
2. Apply only findings that are clearly correct and worth doing now. Skip false positives without arguing.
3. Stay in lane: change only the lines a finding identifies; do not refactor surrounding code.
4. Preserve behavior, error handling, and existing abstraction boundaries.
5. Do not stage, commit, or push. The user reviews before committing.

After applying, return one tight summary block:
- **Applied:** one short bullet per fix with `file:line`.
- **Skipped:** one short bullet per skipped finding with the reason it was wrong or out of scope. Omit this section if empty.
- **Worth a look:** one short bullet per risky, ambiguous, or larger finding not applied. Omit this section if empty.

No narration or preamble.
