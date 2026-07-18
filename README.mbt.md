# moon-examples

A MoonBit workspace collecting small, runnable example modules.

## Modules

- **[`todo/`](./todo/README.md)** — TinyTodo: Cedar policy-based
  authorization over a tiny HTTP API (vendored from
  [jaredzhou/moonbase](https://github.com/jaredzhou/moonbase)).

See [`AGENTS.md`](./AGENTS.md) for build commands, conventions, and the
pre-push checklist.

## Upstream libraries these examples build on

- [jaredzhou/pony](https://github.com/jaredzhou/pony) — HTTP web
  framework for MoonBit.
- [jaredzhou/moonpg](https://github.com/jaredzhou/moonpg) — pure
  MoonBit PostgreSQL client.
- [jaredzhou/moonbase](https://github.com/jaredzhou/moonbase) — the
  source monorepo from which these examples are vendored.
- [jaredzhou/mooncedar](https://github.com/jaredzhou/moonbase/tree/main/mooncedar) — Cedar policy engine
  (in moonbase).
- [jaredzhou/libs](https://github.com/jaredzhou/moonbase/tree/main/libs) — shared
  libraries (URL, JWT, …) (in moonbase).
