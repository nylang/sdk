# Kernel manual

Import the public entry:

```nyra
import "kernel:kernel.ny";
```

Kernel owns freestanding capabilities. It does not depend on stdlib or expose OS
platform implementation calls. A particular API may still require an allocator,
provider, ABI or CPU feature; “kernel” is not blanket permission to execute on any
board. The installed SDK target profile must match the consumer.

## Find a capability in SDK 1.0.5

Read the named shipped public face under
`packages/kernel/targets/<profile>/sources/interface/`, or the matching exported
open recipe under `sources/public/`. Use [API lookup](../api-lookup.md) to confirm
public names in the selected SDK.

- Scalar widths/bounds, numeric operations: `integer.ni`, `math.ni`, `bit.ni`.
- Checked arithmetic/narrowing: `checked_integer.ni`; start with [uint64.TryAdd](uint64-try-add.md).
- Alignment and ranges: `align.ni`, `range.ni`; distinguish unchecked rounding from checked overflow.
- Bytes, spans/cursors and no-heap text: `bytes.ni`, `byte_cursor.ni`, `string.ni`, `text.ni`.
- Allocator contracts and raw memory: `alloc.ni`, `memory.ni`; read allocation failure and pointer lifetime.
- Iteration/results: `iteration.ni`, `result.ni` and their exported public recipes.
- Atomic operations: `atomic.ni`; check width, memory order, alignment and target support.
- Async protocols/drivers: `async.ni` and exported kernel async recipes; freestanding sugar requires an explicit allocator as well as an executor.
- Profiling/storage protocols: `profile.ni`, `profile_buffer.ni` and relevant open recipes.

This is a capability map, not a complete per-symbol manual. Choose API pages by
contract, not by searching private implementation names. Stdlib may re-export the
same canonical kernel types; that does not create a second owner. Planned future
container relocation must not change a 1.0.5 reference page silently.
