# General

- Always have temporary files located in a `claude/` directory, you should
  never add these to git. I also would like a subdir with a good name and use
  that for the session. <!-- - If you are on a branch except `main`. Add and
  commit after each step is completed.  -->
- Only use `git add` with filename.
- Try to use the `gh` cli instead of looking up webpage directly
- You should cache web results.
- Treat `AGENTS.md` or `.github/AGENTS.md` as `CLAUDE.md`

# Python

- The correct python environment is always activated
- Prefer one off python code use `python -c`
- Run failing tests one at a time, if needed run all test at once and then use
  `pytest --last-failed --collect-only -q` to collect them.
- If you are creating a new test(s) confirm it actual fails on main.
- If something is not currently being supported raise NotImplementedError, so
  we don't forget about it, do not only write a `TODO` comment
