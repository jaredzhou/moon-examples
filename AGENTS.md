# moon-examples — Agent Guide

A [MoonBit](https://www.moonbitlang.com/) workspace for collecting small,
runnable example modules vendored from [jaredzhou/moonbase](https://github.com/jaredzhou/moonbase).

## Workspace Overview

Defined in `moon.work`:

```
members = ["./todo"]
```

The `todo/` member is the TinyTodo demo (Cedar policy-based authorization
over a tiny HTTP API, built on `jaredzhou/pony`). It is a self-contained
module that can also be developed independently from the moonbase source.

## Common Commands

Run from the repository root.

```bash
# Type-check the entire workspace, warnings as errors
moon check --deny-warn

# Run all tests across all members
moon test

# Update snapshot tests when behaviour changes intentionally
moon test --update

# Format everything, then verify no diff
moon fmt
moon fmt --check

# Regenerate .mbti interface files and confirm no public-API drift
moon info
git diff --exit-code

# Fetch latest compatible versions of all deps
moon update
```

## Pre-push

`.github/workflows/ci.yml` runs four steps on every push and PR. The
local `.githooks/pre-push` hook runs the same checks so a broken push
gets caught before leaving the machine. Install the hook once:

```bash
git config core.hooksPath .githooks
```

The hook runs, in order:

1. `moon check --deny-warn` — type-check the workspace, warnings as errors
2. `moon fmt --check` — fail on unformatted code
3. `moon info` + `git diff --exit-code` — fail on public-API drift
4. `moon test` — run all tests

Both an AI agent and a human should run these locally (or rely on the
hook) before `git push`. If CI is red, the push is bad — fix it locally
first, do not push to "see what happens".

## Module: `jaredzhou/todo`

**External deps:** `jaredzhou/pony@0.3.0`, `jaredzhou/mooncedar@0.1.1`,
`moonbitlang/async@0.19.4`, `moonbitlang/x@0.4.45`.

**Sub-packages:**

| Package | Purpose |
|---------|---------|
| `todo/store` | In-memory state + Cedar entity sync |
| `todo/auth`  | Authorization (calls into `jaredzhou/mooncedar`) |
| `todo/handler` | HTTP handlers (routes use `jaredzhou/pony` Context API) |
| `todo/client` | Sample client |
| `todo/tests` | Black-box integration tests |

```bash
# Run only todo's tests
moon test --package jaredzhou/todo

# Run a single test file
moon test todo/handler/list_wbtest.mbt
```

**`pony` API conventions used here:**

- `let user : String = ctx.header("X-User")` — raise on missing header,
  middleware turns it into 401
- `let id : Int = ctx.param("id")` — `ctx.param` is generic over
  `FromStr`, so the type annotation picks `T = Int`; raise covers both
  missing param and bad parse, middleware turns either into 400
- `ctx.reply_error(@pony.PonyError::Variant(msg))` — never use the
  old `(Int, String)` form
- Handler bodies use `ctx => { ... }` (arrow); `next(ctx)` is the inner
  handler in a middleware

## Adding a New Example

1. Create a directory at the workspace root (e.g. `hello/`) and put a
   `moon.mod` inside (run `moon new <name>` or hand-write).
2. From the workspace root, register it:
   ```bash
   moon work use hello
   ```
3. Develop inside the member. Import it from other members by the
   member's own module name.
4. Before pushing, run the four pre-push checks above.

## Conventions

- **Block syntax**: separate top-level items with `///|`. The current
  formatter handles this.
- **Handler style**: prefer arrow lambdas (`ctx => { ... }`) over
  `async fn(ctx) { ... }`; the async effect is inferred from the body.
- **Error handling**: use `PonyError` variants, never raw integers.
  Raise from handlers; the `pony_error_middleware` in `todo/main.mbt`
  converts to HTTP responses.
- **`.mbti` files**: generated interface files are committed. If
  `moon info` produces no diff, the change has no public-API impact.
- **Snapshot tests**: prefer `inspect(value)` / `debug_inspect(value)`;
  run `moon test --update` to refresh.
- **Formatting**: always run `moon fmt` before committing.
