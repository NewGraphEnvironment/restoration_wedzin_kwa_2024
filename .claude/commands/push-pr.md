Push current branch and create a pull request with standard template.

## Steps

1. Run `git status` to check current state
2. Run `git log origin/main..HEAD --oneline` to see commits to be pushed
3. Run `git branch --show-current` to confirm current branch

4. If on `main`:
   - Ask user if they want to create a feature branch first
   - Or proceed with push to main (if appropriate)

5. Push to remote:
   ```
   git push -u origin <branch-name>
   ```

6. Create PR using `gh pr create` with this template:

```
gh pr create --title "<descriptive title>" --body "$(cat <<'EOF'
## Summary
<1-3 bullet points describing changes>

## Related Issues
- Relates to NewGraphEnvironment/sred-2025-2026#4

## Test plan
- [ ] Report builds successfully with `scripts/run.R`
- [ ] No rendering errors in gitbook output
- [ ] Cross-references resolve correctly

## Notes
<any additional context>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

7. Return the PR URL to user

## Notes
- Ensure all changes are committed before creating PR
- PR title should be concise but descriptive
- Link to SRED issue for R&D tracking
