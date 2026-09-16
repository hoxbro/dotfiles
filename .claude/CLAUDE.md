# General

- Always have temporary files (scripts, outputs, fetched pages) in `.scraith/<task>/`, where `<task>` is a short name for the current task
- To run ad-hoc code, write it to a file in `.scraith/<task>/` with the Write tool, then run the file. Never pass code inline (`python -c`).
- Always cache fetched web results in `.scraith/cache`, and use them for future reference
- Treat `AGENTS.md` or `.github/AGENTS.md` as `CLAUDE.md`
- Don't start bash command with comment
- Do not run linter, formatter, and type checking, unless I ask.
- Only add short comments explaining why, never what the code does or used to do. No comment is the default.
- When giving me a script to run, give the complete file, not fragments or diffs.

# Git

- Only use `git add` with filename
- Attribution must follow this format: `Assisted-by: AGENT_NAME:MODEL_VERSION` instead of `Co-Authored-By`
- When committing make sure to use backtick-quote for code. Pass the message with `git commit -F- <<'EOF'`

# GitHub

- Fetch GitHub content with `gh` CLI
- Never open an issue, PR, or comment without my explicit approval
- Do not look at PRs unless asked.
- Write issue and PR numbers as Markdown links, e.g. `[#123](https://github.com/owner/repo/pull/123)`.

# Python

- The correct environment is already active. Don't install packages; if one is missing, stop, and tell me its name.
- Never write `TODO` comments for WIP use `NotImplementedError`
- `ty` is a valid command, do not replace with `mypy`

## Tests

- If you are creating new tests confirm it actually fails on main.
- When writing tests only create a new file if there isn't any good file to put it in
- UI tests need `--ui` CLI flag
- tests do not need docstrings
