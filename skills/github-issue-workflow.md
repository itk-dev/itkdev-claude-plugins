---
name: github-issue-workflow
description: Work through GitHub issues following the ITK-dev workflow. Use this skill when you need to pick an issue, develop a solution, create a PR, review code, and merge. Handles the complete development lifecycle from issue selection to merge.
---

# GitHub Issue Workflow

You are working through GitHub issues following the ITK-dev workflow. Execute these steps:

## PHASE 1: Issue Selection
1. Run `gh issue list --state open --limit 20` to show open issues
2. Ask the user which issue to work on (or let them specify one)
3. Run `gh issue view <number>` to get full details
4. Summarize the issue and confirm understanding with the user

## PHASE 2: Development
1. Switch to main branch and pull latest: `git checkout main && git pull`
2. Create feature branch: `git checkout -b feature/issue-<number>-<short-description>`
3. Plan the implementation (use EnterPlanMode for non-trivial tasks)
4. Implement the solution following project guidelines in CLAUDE.md
5. Update CHANGELOG.md with the changes
6. Run `task ci` to verify all checks pass
7. Fix any issues until CI passes

## PHASE 3: Create PR
1. Commit changes with descriptive message referencing the issue
2. Push branch: `git push -u origin <branch-name>`
3. Create PR with `gh pr create` following this format:
   - Title: Brief description (Closes #<issue-number>)
   - Body: ## Summary (bullet points), ## Test plan (checkboxes)

## PHASE 4: UI Testing (if applicable)
1. Ask user if this change has UI components that need testing
2. If yes, use the dev-browser skill or browser-feedback tools to test
3. Document any UI issues found and fix them

## PHASE 5: Code Review
1. Use the Task tool with subagent_type='pr-review-toolkit:code-reviewer' to review the changes
2. Also run 'pr-review-toolkit:silent-failure-hunter' for error handling review
3. Present review findings to user
4. Fix any issues identified in review
5. Push fixes and re-run CI if needed

## PHASE 6: Merge
1. Confirm with user that PR is ready to merge
2. Run `gh pr merge --squash --delete-branch` to merge
3. Switch back to main: `git checkout main && git pull`

## PHASE 7: Next Issue
1. Ask user if they want to continue with another issue
2. If yes, return to Phase 1

## Important Guidelines
- Always follow CLAUDE.md guidelines
- Never commit directly to main
- Always run `task ci` before creating PR
- All user-facing text in Danish, code/commits in English
- Ask for clarification if requirements are unclear
