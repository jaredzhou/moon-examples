# moon-examples

A MoonBit **workspace** for collecting small, runnable example modules.

## Layout

A `moon.work` file makes this a workspace that can contain multiple
member modules. Each member is its own module (with its own
`moon.mod`) listed in `members`.

```
moon-examples/                # the workspace (this repo)
├── moon.work                 # workspace manifest, lists members
└── <member>/                 # each member is a self-contained module
    ├── moon.mod              # the member's module metadata
    └── ...                   # packages inside the member
```

Members are added with `moon work use <path>`.

## Usage

```sh
moon check          # type-check the whole workspace
moon test           # run all tests in every member
moon run cmd/main   # run a package whose `is-main` is set
```

## Adding a new example module

1. Create a directory (e.g. `hello/`) for the new member.
2. Inside it, run `moon new <name>` (or hand-write a `moon.mod`).
3. From the workspace root, register it:
   ```sh
   moon work use hello
   ```
   This appends `"hello"` to `members` in `moon.work`.
4. Import it from other members by the member's own module name.
