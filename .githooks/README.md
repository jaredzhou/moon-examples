# Git Hooks

Local git hooks, modeled on
[jaredzhou/moonbase](https://github.com/jaredzhou/moonbase).

## Pre-push Hook

`pre-push` runs the same four checks as
[`.github/workflows/ci.yml`](../.github/workflows/ci.yml):

1. `moon check --deny-warn`
2. `moon fmt --check`
3. `moon info` + `git diff --exit-code` (fails on public-API drift)
4. `moon test`

If any step fails the push is aborted; the agent (or you) should fix
the issue locally before re-pushing.

### Usage

```bash
git config core.hooksPath .githooks
```

To bypass once: `git push --no-verify`. Don't.
