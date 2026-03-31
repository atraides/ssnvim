---
name: commit
description: Create a new commit for all of our uncommitted changes.
---

Create a new commit for all of our uncommitted changes
run git status && git diff HEAD && git status --porcelain to see what files are uncommitted
add the untracked and changed files

Add an atomic commit message with an appropriate message

add a tag such as "feat", "fix", "docs", etc. using conventional commit format that reflects our work