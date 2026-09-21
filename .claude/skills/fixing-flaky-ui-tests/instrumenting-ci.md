# Instrumenting CI when local runs stay green

Arm the diagnostic in the process and phase that fails - dumps armed per test miss hangs between tests, and a `conftest.py` under one test directory is not loaded for a pytest run collecting another directory.

| Want to know                                     | How                                                                                                                                                                                                                                                    |
| ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Which test each worker was running when one died | hook `pytest_runtest_protocol` and write `<epoch> <worker> start` and `end <nodeid>` lines to a dup of the real stderr (pytest captures `sys.stderr`); sort the lines across workers afterwards                                                        |
| How a crashed worker went down                   | controller-side `pytest_testnodedown`: read `node.gateway._io.popen`, report `killed by SIG...` (negative code) or `with exit code N`                                                                                                                  |
| Where a stuck process is                         | `faulthandler.dump_traceback_later(interval, repeat=True)` per test - repeated identical dumps mean frozen, moving dumps mean looping. `faulthandler_timeout` in the ini dumps once but covers every pytest run, including ones your conftest does not |
| Whether a worker was killed from outside         | `faulthandler.register(SIGTERM/SIGHUP/SIGQUIT)`, a wrapper around `os._exit`, and on Linux a post-failure step grepping `dmesg` for OOM kills                                                                                                          |

## Many CI runs of one change

Give each CI run its own concurrency group (e.g. append the commit sha) so pushes stop cancelling each other, then push one empty commit at a time, letting each run get its runners first; a dozen at once only saturates the runner quota. Drop the empty commits again (`git rebase --no-keep-empty --force-rebase --onto <base> <base>`) before the branch is reviewed.
