# General

- Always have temporary files located in a `claude/` directory, you should
  never add these to git. Use a subdir with a good name for that session
- Only use `git add` with filename.
- Use the `gh` cli instead of looking up webpage directly
- You should cache web results.
- Treat `AGENTS.md` or `.github/AGENTS.md` as `CLAUDE.md`
- Don't start bash command with comment

# Python

- The correct python environment is always activated
- For Python code write a test file and run with use `python`
- Run failing tests one at a time, if needed run all test at once and then use
  `pytest --last-failed --collect-only -q` to collect them.
- If you are creating a new test(s) confirm it actual fails on main.
- If something is not currently being supported raise `NotImplementedError`, so
  we don't forget about it, do not only write a `TODO` comment
- `ty` check is a valid command, do not replace with `mypy`
- When writing test(s) only create a new file if there isn't any good file to put it int
