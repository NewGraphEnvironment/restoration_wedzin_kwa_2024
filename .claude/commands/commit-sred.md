Commit changes with SRED tracking linkage for this project.

## Steps

1. Run `git status` to see all changes (staged and unstaged)
2. Run `git diff` to see unstaged changes
3. Ask user which files to include if not already staged
4. Stage the selected files with `git add`
5. Run `git diff --cached` to see what will be committed
6. Draft a concise commit message summarizing the changes
7. Include in the commit message:
   - `Relates to NewGraphEnvironment/sred-2025-2026#4` (restoration report finalization)
   - `Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>`
8. Execute the commit using HEREDOC format for the message
9. Run `git status` to verify success

## Commit Message Format

```
<brief summary of changes>

<optional details if needed>

Relates to NewGraphEnvironment/sred-2025-2026#4

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

## Notes
- Keep commit messages focused on the "why" not just the "what"
- If changes span multiple concerns, consider separate commits
