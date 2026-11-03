# string.Concat

**Owner:** stdlib, string instance method. **Reference:** SDK 1.0.5.
Import `stdlib:stdlib.ny`; read `interface/string.ni` and its comments.

```nyra
pub method(string) Concat(other: ref string) -> string;
```

Concatenate this string and the borrowed other string, in order, into a returned
string value. It does not overwrite the receiver or hand the caller a raw C
buffer. Ordinary language ownership manages the returned allocation; do not add
a separate caller Free protocol. The other borrow is used for the call, not
retained as an arbitrary escaped reference.

This byte-oriented operation does not normalize Unicode or insert separators.
Appending an empty string leaves the text unchanged. It is not a fallible Result
API, so do not invent an Err alternative. Allocation failures follow the runtime
policy rather than a per-call error value. There is no promise that repeated
concatenation in a loop is free: copying work grows with combined byte length.
Use the shipped StringBuffer API for incremental construction when appropriate.
Concurrent mutation of external backing memory is outside a string value's safe
contract; Concat is not a synchronization primitive.

Complete program:

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  let prefix: string = "Hello";
  let message: string = prefix.Concat(", Nyra");
  Console.Println("{0}", message);
  Console.Println("{0}", prefix);

  return 0;
}
```

Expected lines are `Hello, Nyra` then `Hello`. The receiver remains usable. For C
interop, read the explicit byte pointer/length/terminator/lifetime contract;
string values are not interchangeable with char pointers.

[Complete source](../../learn/examples/manuals/string-concat/main.ny) · [package.yaml](../../learn/examples/manuals/string-concat/package.yaml)
