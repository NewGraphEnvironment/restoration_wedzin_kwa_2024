Commit changes with SRED tracking linkage for this project.

## Steps

### 1. Check Open Issues (ALWAYS do this first)
```bash
gh issue list --repo NewGraphEnvironment/restoration_wedzin_kwa_2024 --state open
gh issue list --repo NewGraphEnvironment/sred-2025-2026 --state open
```
Review the issue list and identify any relevant issues that this commit relates to.

### 2. Review Changes
- Run `git status` to see all changes (staged and unstaged)
- Run `git diff` to see unstaged changes

### 3. Stage Files
- Ask user which files to include if not already staged
- Stage the selected files with `git add`
- Run `git diff --cached` to see what will be committed

### 4. Draft Commit Message
- Summarize the changes concisely
- Include in the commit message:
   - `Relates to #<issue>` for any relevant issues in this repo
   - `Relates to NewGraphEnvironment/sred-2025-2026#4` (restoration report finalization)
   - `Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>`

### 5. Execute Commit
- Use HEREDOC format for the message
- Run `git status` to verify success

## Commit Message Format

```
<brief summary of changes>

<optional details if needed>

Relates to #<issue number in this repo>
Relates to NewGraphEnvironment/sred-2025-2026#4

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

## Notes
- Keep commit messages focused on the "why" not just the "what"
- If changes span multiple concerns, consider separate commits
- ALWAYS check open issues first - this is non-negotiable
- Reference all relevant issues from both repos
