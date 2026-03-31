# General

- Always have temporary files located in a `./claude/` directory, you should
  never add these to git. Use a subdirectory with a good name for that session
- Only use `git add` with filename
- Always use the `gh` CLI for fetching
- Always cache fetched web results
- Treat `AGENTS.md` or `.github/AGENTS.md` as `CLAUDE.md`
- Don't start bash command with comment

# Python

- The correct python environment is always activated
- Never use `python -c` write it to a file in `./claude/` or `/tmp` and run it with `python filename`
- If you are creating new tests confirm it actual fails on main.
- Never write `TODO` comments for WIP use `NotImplementedError`
- `ty` check is a valid command, do not replace with `mypy`
- When writing tests only create a new file if there isn't any good file to put it in
