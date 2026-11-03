# Stdlib manual

Import the public entry:

```nyra
import "stdlib:stdlib.ny";
```

Stdlib depends on kernel and re-exports its public face. It adds hosted ownership,
collections and system capabilities. It is not an acceptable dependency for `.nk`
freestanding source. Read the selected target's actual runtime/provider contract.

## Capability map for SDK 1.0.5

The public declarations live under
`packages/stdlib/targets/<profile>/sources/interface/`. Exported generic bodies
and protocols also live in `sources/public/`; not every API is in a `.ni` file.

- Console and formatting: `console.ni`; Console Print/Println/Eprint/Eprintln use the defined string-enable channel.
- Strings, Unicode/text and encoding: `string.ni`, `text.ni`, `encoding.ni`; start with [string.Concat](string-concat.md).
- Collections: exported `public/collection/` recipes for Array, HashMap/HashSet, Map/Set, queues, stacks and deques. Check borrowing, growth and shared-write rules.
- Files and byte streams: `io.ni`, `io_error.ni`; File/FileStream and byte-oriented Stream are distinct from async Flow.
- Paths/directories/links: `fs.ni`; Path and filesystem owners supply these operations, not a byte buffer.
- Process/environment/system: `process.ni`, `system.ni`; distinguish exit status, subprocess errors and system failures.
- Time: `time.ni`; distinguish duration, monotonic timing and wall-clock time.
- Threads/synchronization: `threading.ni`; read ownership, lock scope, deadlock and blocking obligations.
- Async: `async.ni` plus exported `public/async/` recipes; Future/Promise, explicit executors, local versus concurrent types, [AsyncFlow.Collect](async-flow-collect.md).
- Hashing, FFI and hosted profiling: `sha256.ni`, `ffi.ni`, `profile_host.ni`, `profile_writer.ni`.

The `_nyra_malloc` / `_nyra_realloc` / `_nyra_free` hazard trio is deliberately
raw and manually owned; it does not redefine ordinary string/container cleanup.
Do not recommend private `nyra_plat_*` calls as public APIs. JSON, YAML, networking,
TLS and HTTP are independent ecosystem packages, not assumed stdlib modules.
