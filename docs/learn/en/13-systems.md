# 13: Pointers, allocators and kernel code

[中文](../13-systems.md) · [Course index](README.md) · [Previous](12-concurrency.md) · [Next](14-compiler-tools.md)

This chapter is for lower-level work. Ordinary applications can keep using
standard-library operations and language-owned values.

## 1. A pointer holds an address

Complete userspace program:

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  var value: int32 = 40;
  let address: *mut int32 = &mut value;
  unsafe {
    *address = *address + 2;
  }
  Console.Println("结果：{0}", value);
  return 0;
}
```

&mut value obtains a writable address. Dereferencing *mut int32 accesses the
pointed-to integer and requires unsafe. unsafe does not validate the address;
you must ensure lifetime, alignment, bounds and compatible concurrent access.

## 2. Call a simple C function

Complete macOS example:

```nyra
import "stdlib:stdlib.ny";

@extern("C") func abs(value: int32) -> int32;

func main() -> int32 {
  Console.Println("绝对值：{0}", abs(-42));
  return 0;
}
```

Expected result: 42. The declaration selects C linkage and calling convention.
Do not use the minimum signed integer to demonstrate abs. A Nyra string is not
a C char pointer, and a view need not end with NUL. Specify encoding, lengths,
termination and ownership at every text boundary.

## 3. Select an allocation lifetime

CreateAllocator uses the process heap. A MemStack can serve short-lived scratch
allocations; an arena can group allocations sharing a lifetime. Complete
userspace example using a local backing buffer:

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  var storage: <uint8>[] = <uint8>[256]{0u8};
  var stack: MemStack = MemStack{};
  stack.Init((&mut storage[0]) as *mut uint8, 256up);

  let mark: uintptr = stack.Mark();
  let memory: *mut uint8 = stack.Alloc(16up, align: 8up);
  if memory == (0 as *mut uint8) {
    Console.Eprintln("临时缓冲区容量不够");
    return 1;
  }
  unsafe {
    *memory = 42u8;
    Console.Println("临时数据：{0}", *memory);
  }
  stack.Reset(mark);
  return 0;
}
```

Mark records position, Alloc advances it and Reset restores it. Do not use an
allocation after reset. The backing storage must outlive the allocator and all
results. The fixed-length construction expression and the variable's slice-like
type have different syntax in this example.

## 4. Reset through scope

After stack.Init, replace the manual Mark/Reset region with this fragment:

```nyra
scope (stack) {
  let memory: *mut uint8 = stack.Alloc(16up, align: 8up);
  if memory == (0 as *mut uint8) { return 1; }
  unsafe { *memory = 42u8; }
}
```

The marking protocol resets when leaving scope. A view into that region still
cannot escape. Ensure object cleanup precedes reclaiming its backing bytes;
resetting allocation state does not substitute for arbitrary destructors.

## 5. A growable arena

Fragment showing setup order:

```nyra
var backing: Allocator = CreateAllocator(0i64, 8i64);
var provider: MemoryChunkProvider = MemoryChunkProviderFromAllocator(&mut backing);
var arena: MemArena = MemArena{};
if !arena.InitGrowable(&mut provider, 65536up) { return 1; }

let memory: *mut uint8 = arena.Alloc(128up, align: 8up);
if memory == (0 as *mut uint8) {
  arena.Release();
  return 2;
}
unsafe { *memory = 7u8; }

arena.Release();
```

Initialize the backing allocator, then provider, then arena. Their addresses and
lifetimes remain stable while in use. Blocks can grow without moving earlier
blocks. Successful InitGrowable establishes configuration, not unlimited future
memory; allocations may fail. Release returns provider blocks. Do not make a
provider allocate from its own arena recursively, or keep pointers after Release
or ResetAll.

## 6. Freestanding .nk code

.nk does not import stdlib or assume a console, filesystem or process heap.
Standalone declaration fragment for integration into a kernel project:

```nyra
import "kernel:kernel.ny";

struct Node {
  value: int32;
}

func create_node(allocator: Allocator) -> unique<Node> {
  return new(allocator) unique<Node> { value: 42 };
}
```

Permitted owned-object forms require an explicit allocator through new(allocator).
This is not an operating system that run can launch. Real kernels also need boot
code, linker scripts, memory maps, board support and target runtime artifacts.
Changing a suffix or producing a RISC-V object supplies none of those by itself.

## Exercises

Request 1024up bytes from the 256-byte buffer: handle insufficient capacity rather
than dereferencing nil. Is a ViewFrom result into scope(stack) storage safe after
scope exit? No: copy it into sufficiently long-lived storage before reset.
