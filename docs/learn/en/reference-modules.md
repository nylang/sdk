# Modules: import, export, module and part

[中文](../reference-modules.md) · [Course index](README.md) · [Dictionary](reference-keywords.md)

## 1. Design boundaries before splitting files

A package is identified by `package.yaml`, manages dependencies and may contain
multiple modules. **One module is one TU (translation unit)**. Its `part` files
are compiled together. `import`/`export` connect different TUs without merging ASTs.
`module Prices;` names this TU; it does not place the whole package inside it.
A single-file module may omit an explicit name. A main using `part` must declare
the corresponding `module` name.

Each module needs one responsibility: state its owned data, invariants, operations,
exclusions and dependency direction. More part files do not reduce total TU size
or fix mixed responsibilities. Do not combine unrelated modules into one large TU
just to shorten files, or create a module for every tiny helper.

## 2. Comparison

| Form | Does | Does not |
|---|---|---|
| `module ShopApp;` | Names this TU | Search a matching directory or discover files |
| `part "private/discount.ny";` | Explicitly adds a file to this TU | Create a separate public boundary |
| `part of ShopApp;` | Names the child's owning TU; names must match | Permit module/part/import/export directives in the child |
| `import "prices.ny";` | Makes the target public surface available here | Automatically expose it to importers of this module |
| `export "prices.ny";` | Re-exports the target public surface | Export a C ABI / DLL symbol |
| `pub` | Adds this declaration to the public surface | Make every declaration public |
| `as prices` | Qualifies names such as `prices.Price` | Infer a qualifier from the path without `as` |
| `show Price` | Includes listed public top-level names | Remove modules from the link graph |
| `hide InternalTool` | Excludes listed public top-level names | Name something absent from the public surface |

A show/hide list must be nonempty, use existing names and contain no duplicates.
One directive cannot mix show and hide. Filter the top-level type, not a member
path such as `Price.Total`. Member access still follows the member's visibility.

## 3. Complete five-file example

Create these files in a fresh `module-lesson/` directory, outside another package root:

```text
module-lesson/
  package.yaml
  main.ny
  shop.ny
  prices.ny
  private/
    discount.ny
```

### `package.yaml`

```yaml
name: module_lesson
```

### `prices.ny`

```nyra
module Prices;

/** @brief A quantity and its unit price; owns pricing arithmetic only. */
pub struct Price {
  unit: int32;
}

/** @brief Calculate the undiscounted total for a quantity. */
pub method(Price) Total(quantity: int32) -> int32 {
  return self.unit * quantity;
}
```

### `shop.ny`

```nyra
module Shop;

// Stable public entry; pricing remains a separate TU.
export "prices.ny" show Price;
```

### `private/discount.ny`

```nyra
part of ShopApp;

// App-specific policy; not part of the reusable pricing API.
func discounted(total: int32, discount: int32) -> int32 {
  if discount >= total {
    return 0;
  }

  return total - discount;
}
```

### `main.ny`

```nyra
module ShopApp;
part "private/discount.ny";

import "shop.ny" as shop show Price;

func main() -> int32 {
  let price: shop.Price = shop.Price{ unit: 12 };
  let total: int32 = discounted(price.Total(4), 6);
  if total != 42 {
    return 1;
  }

  return 0;
}
```

Run with the Lesson 00 environment:

```sh
"$NYRAC" check "$NYRA_WORK/module-lesson/main.ny"
"$NYRAC" run "$NYRA_WORK/module-lesson/main.ny" \
  --out-dir "$NYRA_WORK/out/module-lesson"
```

On Windows, use `& $env:NYRAC` and environment-variable paths as in the setup lesson.
Success returns 0: `12 * 4 - 6 = 42`. This example prints no text.

There are three TUs: `ShopApp` (main plus discount part), `Shop`, and `Prices`.
The main imports only `shop.ny` and obtains `Price` through its export. Replacing
that export with an ordinary import stops exposing `Price` through this entry.
Discounting is application policy in the application TU; reusable price arithmetic
belongs to the TU owning `Price`.

## 4. Visibility and name conflicts

A flat import brings public names into the current scope. Conflicting top-level
names from two flat imports are errors. Qualify them with aliases. These are
**directive fragments** requiring the named files to exist:

```nyra
import "retail.ny" as retail show Price;
import "wholesale.ny" as wholesale show Price;
```

Then use `retail.Price` and `wholesale.Price`. `namespace` organizes names; it does
not replace module/dependency design. A dependency key such as `stdlib` does not
automatically authorize `stdlib.Console` without an alias declaration.

## 5. Cross-package imports and Git versions

In `import "json:json.ny";`, the left side is the dependency key; the right side
is its entry path. `package.yaml` chooses where to acquire the package; `import`
chooses the surface used by this TU. Published dependency declarations use Git URLs
and version tags, with exact commits in the lockfile. Local workspace/path wiring
is not a distributable address on another machine.
See the [package-management guide](../../package-management.en.md) for Git/tag/lock examples.
SDK kernel/stdlib/ntest packages follow the selected version's implicit SDK lookup;
source imports remain explicit. Check the public starting version's
[Git lock limitation](../../../RELEASE-1.0.3.md).

## 6. File extensions are not module keywords

| Extension | Purpose | Boundary |
|---|---|---|
| `.ny` | Ordinary application/library implementation | May contain non-public helpers |
| `.ni` | Public API declarations and inline/generic faces | Top-level declarations require pub; ordinary non-generic structs do not expose field layouts here; function bodies follow inline rules |
| `.nk` | Restricted kernel/driver mode | Not a normal hosted program importing stdlib |

Minimal `.ni` declaration fragment, requiring implementation and link organization:

```nyra
pub struct Counter;

pub method(Counter) Read() -> int32;
```

Renaming a `.ny` extension does not hide an existing field layout or generate an
implementation. Main files must explicitly list their parts. Never import a
`part of` file directly.
