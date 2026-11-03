# uint64.TryAdd

**Owner:** kernel, uint64 instance method. **Reference:** SDK 1.0.5.
Import `kernel:kernel.ny`; the declaration is in `interface/checked_integer.ni`.
Stdlib re-exports this canonical kernel operation.

```nyra
pub method(uint64) TryAdd(other: uint64, result: ref mut uint64) -> bool;
```

Add only if the mathematical unsigned sum fits in uint64. The receiver and other
are inputs. Result is a mutable borrow: success writes the exact sum and returns
true; overflow returns false and **preserves the previous result**. It does not
return a wrapped sum, allocate storage, or release caller-owned resources.
Do not consume result as a new answer after false.

The operation performs bounded scalar work, does not allocate or block, and has
no shared-state synchronization. Callers must still satisfy mutable-borrow and
target/provider obligations; importing kernel does not choose a board runtime.

Complete program, returning 0 on success and a distinct nonzero code on failure:

```nyra
import "kernel:kernel.ny";

func main() -> int32 {
  let base: uint64 = 40u64;
  var result: uint64 = 7u64;
  if !base.TryAdd(2u64, result) {
    return 1;
  }

  if result != 42u64 {
    return 2;
  }

  let maximum: uint64 = 0xffffffffffffffffu64;
  if maximum.TryAdd(1u64, result) {
    return 3;
  }

  if result != 42u64 {
    return 4;
  }

  return 0;
}
```

The second call demonstrates failure preservation. Ordinary `+` is a different
contract; the Try prefix must not be interpreted as a compiler exception handler.
Related: TrySubtract, TryMultiply, TryAlignUp and TryDivideRoundUp on the selected
shipped scalar faces; read each operation's own range/zero preconditions.

[Complete source](../../learn/examples/manuals/checked-add/main.ny) · [package.yaml](../../learn/examples/manuals/checked-add/package.yaml)
