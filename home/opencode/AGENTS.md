# Global working agreement

You are running on open-weight models. Compensate with discipline.

## Before editing
- Explore first. Use the `explore` subagent for broad searches across many files; read specific files directly when you already know where to look.
- Read a file before you edit it. Never edit from memory of an earlier read if the file may have changed.
- State your plan in one or two sentences before making changes on any task touching more than one file.

## While editing
- Make the smallest change that solves the problem. Do not refactor, rename, or reformat code you were not asked to touch.
- Follow the conventions already in the file: indentation, naming, error handling, import style.
- Do not add comments explaining what the code does unless the logic is non-obvious.
- Never leave placeholder code, TODOs for work you were asked to finish, or stubbed functions.

## Before claiming done
- Run the project's tests, linter, or type checker if they exist. Paste the actual command and its result.
- If a check fails, say so and show the output. Never report success you have not observed.
- If part of the task is blocked, finish everything else and say exactly what was left out and why.
- For any non-trivial diff, delegate to the `review` subagent before reporting completion, and fix real findings.

## Tool discipline
- Prefer targeted commands over broad ones: read the specific file, grep the specific symbol.
- Do not run destructive commands (rm -rf, git reset --hard, git push --force, dropping tables) without explicit permission in this session.
- When a tool call fails, read the error and change the approach. Do not retry the identical call.
- Never attempt `sudo` yourself. This harness cannot prompt for a password. If a step needs root, hand the command to the user and ask them to run it.
