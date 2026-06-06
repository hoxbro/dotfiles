# General

- Always have temporary files located in a `claude/{SESSION_NAME}` directory, you should
  never add these to git.
- Only use `git add` with filename
- Always use the `gh` CLI for fetching
- Always cache fetched web results, and use them for future reference
- Treat `AGENTS.md` or `.github/AGENTS.md` as `CLAUDE.md`
- Don't start bash command with comment
- Attribution must follow this format: `Assisted-by: AGENT_NAME:MODEL_VERSION`

# Python

- The correct python environment is always activated, never install packages.
- Never use `python -c` write it to a file in `claude/{SESSION_NAME}` and run it with `python filename`
- If you are creating new tests confirm it actual fails on main.
- Never write `TODO` comments for WIP use `NotImplementedError`
- `ty` is a valid command, do not replace with `mypy`
- When writing tests only create a new file if there isn't any good file to put it in
- UI tests needs `--ui` CLI flag
