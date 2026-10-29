# 07: Files, modules and packages

[中文](../07-packages.md) · [Course index](README.md) · [Previous](06-errors.md) · [Next](08-generics.md)

Split growing programs by responsibility rather than collecting all behavior in main.

## 1. Distinguish the boundaries

A file is a disk artifact. A module is one translation unit (TU) with a public
boundary. A package is identified by package.yaml, manages dependencies and
contains modules. A module can contain a main file and explicitly affiliated
parts; adding parts does not create independent TUs.

## 2. Import another module

Create a complete `playground/prices.ny`:

```nyra
pub func PriceFor(quantity: int32) -> int32 {
  return quantity * 12;
}
```

Replace main.ny:

```nyra
import "stdlib:stdlib.ny";
import "prices.ny";

func main() -> int32 {
  Console.Println("总价：{0}", PriceFor(3));
  return 0;
}
```

Directory:

```text
playground/
  package.yaml
  main.ny
  prices.ny
```

Keep compiling the entry:

```sh
"$NYRAC" run "$NYRA_WORK/playground/main.ny" \
  --out-dir "$NYRA_WORK/out/lesson07"
```

Expected total: 36. pub exposes the function to importers. Importing does not
merge two source modules into one TU.

## 3. Add a part to the same module

Replace the module main:

```nyra
module ShopApp;
part "private/helpers.ny";

import "stdlib:stdlib.ny";
import "prices.ny";

func main() -> int32 {
  let total: int32 = PriceFor(3);
  Console.Println("优惠后：{0}", apply_discount(total, 6));
  return 0;
}
```

Create its private directory:

```sh
mkdir -p "$NYRA_WORK/playground/private"
```

Create `private/helpers.ny`:

```nyra
part of ShopApp;

func apply_discount(total: int32, discount: int32) -> int32 {
  return total - discount;
}
```

Expected discounted total: 30. The helper and main belong to ShopApp, so the
helper need not be pub. prices remains a separate module. A part file must not
introduce import/export/module/part directives; those belong in its module main.

## 4. Re-export a surface

Organization fragment for a library entry shop.ny:

```nyra
export "prices.ny";
```

Its importers can see the prices module's public declarations. This is re-export,
not AST merging. Prefer a few stable public entries over dependencies on internals.

## 5. Declare package dependencies

SDK 1.0.2/1.0.3 locate their kernel, stdlib and ntest packages implicitly:

```yaml
name: hello
```

The source still imports the surface:

```nyra
import "stdlib:stdlib.ny";
```

NYRA_SDK_ROOT can select a complete SDK explicitly. A missing target runtime
remains an error. Explicit same-name dependency declarations take precedence;
ecosystem packages still require declarations. Account for the
[1.0.3 lock limitation](../../../RELEASE-1.0.3.md).

For two locally authored packages, use sibling directories:

```text
workspace/
  app/
    package.yaml
    main.ny
    private/
  price_library/
    package.yaml
    price_library.ny
    interface/
    public/
    private/
```

Application dependency fragment:

```yaml
dependencies:
  price_library:
    path: ../price_library
```

Merge it into the existing dependencies mapping rather than duplicating that
YAML key. Library package.yaml:

```yaml
name: price_library
```

Library entry:

```nyra
pub func PriceFor(quantity: int32) -> int32 {
  return quantity * 12;
}
```

Application import:

```nyra
import "price_library:price_library.ny";
```

The text before the colon is the dependency key; the rest is its entry path.
A local path is appropriate for this local exercise. Published ecosystem
requirements use actual Git version tags, with resolved commits in the lock.

## 6. Place files deliberately

A small application can stay simple:

```text
my_app/
  package.yaml
  main.ny
  private/
    helpers.ny
```

Reusable libraries introduce interface declarations, open templates under
public/, closed implementation under private/, and a root assembly entry when
those roles are needed. Do not create empty directories just for appearance.
package.yaml manages dependencies, not an exhaustive module list.

A module should have one cohesive responsibility and explicit exclusions,
state ownership and operations. Keep dependencies directed through those
operations; do not expose a mutable state bag to make a split easier.

## Common mistakes

Mismatched module/part names, importing from a part, calling non-pub declarations
across modules, treating export as merging, or nesting independent implementation
packages merely to store examples.

## Exercise

Change the unit price to 15 while buying 3 and discounting by 6. Expected result:
39. Only the price module needs changing; the discount helper stays the same.

## Workspaces and publishing

The 1.0.3 native nyra tool manages packages; nyrac compiles. A shared workspace.yaml
can map local package identities, with workspace:true on local requirements.
Existing published declarations retain their origins while development maps to
local copies. Use nyra pack --check before distributing a package; do not ship
machine-specific absolute dependency paths. See the
[public package guide](../../package-management.en.md).
