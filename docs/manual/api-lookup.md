# Find an API in an installed SDK

Select the complete SDK and the exact profile directory first. This guide uses
SDK 1.0.5 / `darwin-arm64` as an example; replace both for your installed product.
An absent profile is an error, not a reason to substitute host artifacts.

## 1. Query exported names offline

From this documentation repository:

```sh
python3 tools/query_api.py --sdk "$NYRA_SDK" \
  --package stdlib --profile darwin-arm64 --query AsyncFlow
python3 tools/query_api.py --sdk "$NYRA_SDK" \
  --package stdlib --profile darwin-arm64 --query Console.Println --exact
python3 tools/query_api.py --sdk "$NYRA_SDK" \
  --package kernel --profile darwin-arm64 --query uint64.TryAdd --exact --json
```

Partial name lookup is case-insensitive; `--exact` matches the canonical public
name case-sensitively. Exit status is 0 for matches, 1 for no matches, 2 for bad
arguments/input. The script is read-only and needs Python, not a compiler build
or network access. It reads the public barrel's serialized `names` only; it does
not merge all private provider faces into a fake public surface.

The output is a **metadata index**, not a reconstructed source declaration.
For example, a face may encode Console's pack target as `enable<string>` while
omitting variadic flags; the actual source declaration still has
`parts: ...enable<string>`. Interface members can also be absent as standalone
barrel names. A missing `Flow.Collect` search row is not proof the interface has
no Collect method. Use source navigation next.

## 2. Read the exact public declaration and comments

These are installed runtime-package files, not compiler sources:

```text
packages/<package>/targets/<profile>/sources/<package>.ny
packages/<package>/targets/<profile>/sources/interface/*.ni
packages/<package>/targets/<profile>/sources/public/**/*.ny
```

Start at the barrel and follow its **exports**. An import retained for linking is
not itself a public export. Stdlib re-exports kernel, so check the canonical owner
rather than duplicating an API under two independent definitions.

If ripgrep is installed, locate a concrete operation in shipped public sources:

```sh
rg -n 'Collect\(|interface Flow' \
  "$NYRA_SDK/packages/stdlib/targets/darwin-arm64/sources/public/async"
rg -n 'TryAdd\(' \
  "$NYRA_SDK/packages/kernel/targets/darwin-arm64/sources/interface/checked_integer.ni"
```

Without rg, open the category's named face in an editor and search there. The
query script does not require rg. Read the documentation block, surrounding type,
parameter modes and relevant error enum; finding a same-named provider function
is not sufficient.

## 3. Check the contract before writing the call

- Is it an instance method, static method, factory, property, interface member or builtin?
- Does a value copy, borrow, mutate or transfer? Is the return a view or owner?
- Can it return nil/Err/false, remain pending, abort, block or invalidate another view?
- What executor/thread/allocator/provider/target is required?
- Is the declaration part of this published SDK, or only a development design?

Use the [kernel](kernel/README.md) and [stdlib](stdlib/README.md) category maps and
[API page format](api-page-format.md). Search coverage is deliberately narrower
than a complete language-aware documentation extractor; detailed per-member
manual coverage is expanded independently of this initial lookup utility.
