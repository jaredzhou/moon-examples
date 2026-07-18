# moon-examples

A MoonBit **workspace** for collecting small, runnable example modules
vendored from [jaredzhou/moonbase](https://github.com/jaredzhou/moonbase).

The first member is `todo/` — TinyTodo, a Cedar policy-based
authorization demo over a tiny HTTP API. See
[`todo/README.md`](./todo/README.md) and the moonbase repo for the
upstream source.

## Layout

```
moon-examples/                  # the workspace (this repo)
├── moon.work                   # workspace manifest: members = ["./todo"]
├── AGENTS.md                   # guide for AI agents / humans
├── README.mbt.md               # this file
├── .github/workflows/ci.yml    # CI: check / fmt / info / test
├── .githooks/pre-push          # local hook mirroring CI (4 steps)
└── todo/                       # the vendored member
    ├── moon.mod                # module metadata (jaredzhou/todo)
    ├── main.mbt                # entry point: pony.start(...)
    ├── policies.cedar          # Cedar policies
    ├── entities.json           # seed entities
    ├── auth/                   # @auth.try_authorize(...)
    ├── store/                  # in-memory state + Cedar entity sync
    ├── handler/                # HTTP handlers (list, task)
    ├── client/                 # sample client
    └── tests/                  # black-box integration tests
```

## Usage

From the repository root.

```bash
moon check            # type-check the whole workspace
moon test             # run all tests in every member
moon run todo         # start the TinyTodo HTTP server on :3000
moon fmt              # format everything
moon info             # regenerate .mbti interfaces
```

The TinyTodo server listens on `http://127.0.0.1:3000`. Sample
requests:

```bash
# create a list
curl -X POST -H "X-User: emina" -H "Content-Type: application/json" \
  -d '{"name":"Shopping"}' http://127.0.0.1:3000/lists

# read it back
curl -H "X-User: emina" http://127.0.0.1:3000/lists/0

# add a task
curl -X POST -H "X-User: emina" -H "Content-Type: application/json" \
  -d '{"name":"Buy milk"}' http://127.0.0.1:3000/lists/0/tasks
```

Without an `X-User` header the server returns 401; with the wrong
user, 403. Invalid IDs return 400; missing lists/tasks return 404.

## CI and pre-push

`.github/workflows/ci.yml` runs on every push and PR:

1. `moon check --deny-warn`
2. `moon fmt --check`
3. `moon info` + `git diff --exit-code`
4. `moon test`

`.githooks/pre-push` runs the same four checks locally. Install it
once so a broken push is caught before it leaves the machine:

```bash
git config core.hooksPath .githooks
```

Agents (and humans) should also see [`AGENTS.md`](./AGENTS.md) for the
full pre-push workflow and module conventions.

## Adding a new example module

1. Create a directory at the workspace root (e.g. `hello/`) and put a
   `moon.mod` inside (`moon new <name>` or hand-written).
2. From the workspace root, register it:
   ```bash
   moon work use hello
   ```
   This appends `"hello"` to `members` in `moon.work`.
3. Develop inside the member. Import from other members by the
   member's own module name (`@<author>/<module-name>`).
4. Before pushing, run the four pre-push checks (locally via the
   hook, or manually) so CI stays green.
