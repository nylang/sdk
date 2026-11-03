# 08 · Borrows, addresses and unsafe boundaries

[中文](../../fundamentals/08-addresses.md) · [Previous](07-arrays.md) · [Foundation index](README.md) · [Next](09-struct-data.md)

## Goals

Explain addresses for readers with C experience without making raw pointers the default application interface. Compare values and borrows before one controlled pointer example. Manual allocation, release and pointer arithmetic can wait.

## Read the syntax first

Ref T and ref mut T are borrowing parameter contracts. *mut T is a raw mutable pointer type, &mut value obtains an address, and *address dereferences it. Syntax position distinguishes pointer * from multiplication.

## Example 1: borrow for reading

[Source](../../examples/fundamentals/read-borrow/main.ny) · [package.yaml](../../examples/fundamentals/read-borrow/package.yaml) · [expected.txt](../../examples/fundamentals/read-borrow/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func print_title(title: ref string) -> void {
  Console.Print("borrowed=");
  Console.Println(title);
}

func main() -> int32 {
  let title: string = "Nyra";
  print_title(title);
  Console.Println("still={0}", title);

  return 0;
}
```

Expected output:

```text
borrowed=Nyra
still=Nyra
```

A read borrow does not transfer the caller’s ownership. Title remains usable afterward. Borrowing does not imply copying all bytes.

## Example 2: access a live local through a pointer

[Source](../../examples/fundamentals/raw-address/main.ny) · [package.yaml](../../examples/fundamentals/raw-address/package.yaml) · [expected.txt](../../examples/fundamentals/raw-address/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  var value: int32 = 40;
  let address: *mut int32 = &mut value;
  unsafe {
    *address = *address + 2;
  }

  Console.Println("value={0}", value);

  return 0;
}
```

Expected output:

```text
value=42
```

The pointer targets a live, aligned local. Dereference occurs only inside unsafe. Unsafe does not validate the address, and the local address is not returned to an external caller.

## Example 3: explicit copying versus reading

[Source](../../examples/fundamentals/explicit-copy/main.ny) · [package.yaml](../../examples/fundamentals/explicit-copy/package.yaml) · [expected.txt](../../examples/fundamentals/explicit-copy/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let original: string = "Nyra".Concat(" language");
  let saved: string = copy(original);

  Console.Println("original={0}", original);
  Console.Println("saved={0}", saved);

  return 0;
}
```

Expected output:

```text
original=Nyra language
saved=Nyra language
```

Copy requests the type’s copy operation, not necessarily a deeply independent object graph. Move transfers ownership and is taught later. Language cleanup owns ordinary strings; callers do not add manual Free.

## Common mistakes and boundaries

Never return an address to a dead local. Address-of, a borrowing contract and dereference are different operations. Avoid conflicting mutation through multiple access paths; unsafe does not remove that obligation.

## Exercise: try before opening the answer

Start at 10 and add 2 twice through the pointer. Express the same calculation with a mutable-borrow function and compare caller obligations.

<details>
<summary>Complete answer and explanation</summary>

[Source](../../examples/fundamentals/08-addresses-answer/main.ny) · [package.yaml](../../examples/fundamentals/08-addresses-answer/package.yaml) · [expected.txt](../../examples/fundamentals/08-addresses-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

func add_two(value: ref mut int32) -> void {
  value = value + 2;
}

func main() -> int32 {
  var value: int32 = 10;
  add_two(value);
  add_two(value);

  Console.Println("value={0}", value);

  return 0;
}
```

Expected output:

```text
value=14
```

Both produce 14. Call the Lesson 06 add_two helper twice without explicit pointer dereferencing in the caller.

</details>

## Check your understanding

Identify each declared type, the value changed by each write, and the inputs required by each call. Explain the output and use exercise boundaries to challenge your explanation. If unclear, trace the first example before adding the next lesson’s syntax.

[Previous](07-arrays.md) · [Foundation index](README.md) · [Next](09-struct-data.md)
