# Fallen Haven III — Agent Rules

## Code Changes Require Approval

**Always present an implementation plan and wait for explicit user approval before modifying any source files.**

- Use the `implementation_plan.md` artifact with `RequestFeedback: true` for any non-trivial change.
- For trivial one-liners (e.g. fixing a typo or a syntax error), a brief inline description is sufficient, but still ask before applying if it touches logic.
- Never use `run_command` with file-writing commands (Set-Content, Out-File, etc.) or file-editing tools (`replace_file_content`, `multi_replace_file_content`, `write_to_file`) without the user having approved the change first.
