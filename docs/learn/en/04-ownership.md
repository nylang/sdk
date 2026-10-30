# 04: Borrowing, copying and moving

[中文](../04-ownership.md) · [Course index](README.md) · [Previous](03-structs.md) · [Next](05-collections.md)

Before discussing layouts, answer a practical question: can the original
variable still be used after passing its value to a function?

Cleanup definitions and a complete example: [operator drop and copying policy](reference-types.md#drop).

## 1. Who keeps the resource alive?

Integers usually hold their value directly. Strings and dynamic collections may
refer to separately allocated storage. Nyra uses ownership and scope to arrange
cleanup, so ordinary application values do not need manual free calls.
Borrow to inspect, explicitly copy for independent data, and move to transfer
your ownership. A borrower uses data temporarily without becoming its owner.

## 2. Read with ref

Complete program:

```nyra
import "stdlib:stdlib.ny";

func show_title(title: ref string) -> void {
  Console.Println("书名：{0}", title);
}

func main() -> int32 {
  let title: string = "Nyra".Concat(" 入门");
  show_title(title);
  Console.Println("原变量还可以用：{0}", title);
  return 0;
}
```

`ref string` borrows the caller's string. Call show_title(title), without an
extra ampersand. A temporary borrow is not a permanent resource; acquire an
appropriate owned value if the function needs to retain data.

## 3. Modify through ref mut

Complete program:

```nyra
import "stdlib:stdlib.ny";

struct Counter {
  value: int32;
}

func add_one(counter: ref mut Counter) -> void {
  counter.value = counter.value + 1;
}

func main() -> int32 {
  var counter: Counter = Counter { value: 41 };
  add_one(counter);
  Console.Println("{0}", counter.value);
  return 0;
}
```

Expected output: 42. A mutable borrow changes the caller's value; the caller
still owns its lifetime. Avoid conflicting accesses while that borrow is live.

## 4. An ordinary parameter is not an automatic deep copy

```nyra
func title_length(title: string) -> int32 {
  return title.length;
}
```

A string value can retain shared storage rather than copying every byte.
Integers copy their number; move-only types obey their own capability rules.
An implementation-level pointer is not the same as a language borrow. Use ref
when the API's intention is readonly borrowing.

## 5. Explicit copy and move

Complete program:

```nyra
import "stdlib:stdlib.ny";

func take_title(title: ref^ string) -> int32 {
  Console.Println("收到：{0}", title);
  return title.length;
}

func main() -> int32 {
  let original: string = "Nyra".Concat(" 入门");
  let independent: string = copy(original);
  let length: int32 = take_title(move(independent));
  Console.Println("原文：{0}，收到的字节数：{1}", original, length);
  return 0;
}
```

original owns a string. `copy(original)` invokes the string's explicit copying
operation, creating separate byte storage. `ref^ string` is a consuming
parameter: `move(independent)` transfers that binding's ownership to it. Do not
read independent afterwards. original was not moved and remains usable.

Despite its spelling, ref^ is consuming rather than temporarily borrowing.
Use it here on required positional parameters of synchronous functions. Moving
a shared value transfers this holder's ownership, not every other holder's.
For custom types, the copy operation defines what copying means; it is not a
universal recursive byte-copy rule.

## 6. Unique and shared owners

Complete program:

```nyra
import "stdlib:stdlib.ny";

struct Settings {
  port: int32;
}

func read_settings(settings: unique<Settings>) -> int32 {
  return settings.port;
}

func main() -> int32 {
  let exclusive: unique<Settings> = new unique<Settings> { port: 8080 };
  let port: int32 = read_settings(move(exclusive));

  let shared: rc<Settings> = new rc<Settings> { port: 9000 };
  let another: rc<Settings> = shared;
  Console.Println("独占端口：{0}，共享端口：{1}", port, another.port);
  return 0;
}
```

`unique<T>` expresses exclusive ownership, `rc<T>` non-atomic reference counting,
`arc<T>` atomic reference counting, and weak references avoid retaining an object
until upgraded. Atomic counts do not synchronize object-field mutations.
Strong reference cycles still require an ownership redesign or weak references.

## 7. Some types forbid copying

Advanced declaration outside a previously defined MyResource struct:

```nyra
method(MyResource) operator copy() -> MyResource = delete;
```

This is a restriction, not a constructor. FastArray/FastString emphasize explicit
transfer and cloning rather than shallow copies of owning pointers.

## Common mistakes

Retaining a borrow as though it were an owner, using a moved value, treating
assignment/copy/borrow as identical, or assuming arc synchronizes all field access.

## Exercises

Change `take_title(move(independent))` to `take_title(copy(original))`: a newly
copied temporary is consumed and original remains valid. Then change the
parameter to ref string and pass original directly: now it is only borrowed,
without a separate full-string copy for the call.
