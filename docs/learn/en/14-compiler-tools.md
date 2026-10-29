# 14: Compiler views and profiling

[中文](../14-compiler-tools.md) · [Course index](README.md) · [Previous](13-systems.md) · [Next](15-c-interop.md)

You do not need IR for everyday programming. These tools help distinguish source,
lowering, native linking and runtime issues. Use capabilities actually provided
by your installed SDK and its release notes.

## 1. Follow the compilation pipeline

```text
Your source
  -> lexing, parsing, name and type checks
Nyra AST
  -> generic expansion and source lowering
Core AST
  -> instruction generation
LLVM IR
  -> optimization and machine-code generation
Object files
  -> dependency linking
Executable
```

An AST represents program structure. IR is closer to generated instructions.
Linking connects object files and library definitions.

## 2. Start with a small program

Replace playground/main.ny:

```nyra
func add(left: int32, right: int32) -> int32 {
  return left + right;
}

func main() -> int32 {
  let result: int32 = add(20, 22);
  if result != 42 { return 1; }
  return 0;
}
```

Success is exit code zero; there is no console output. Small inputs make the
structure easier to inspect than dumping the compiler itself.

## 3. Export four views

```sh
mkdir -p "$NYRA_WORK/dumps"

"$NYRAC" dump-nyra-ast "$NYRA_WORK/playground/main.ny" \
  -o "$NYRA_WORK/dumps/nyra"

"$NYRAC" dump-core-ast "$NYRA_WORK/playground/main.ny" \
  -o "$NYRA_WORK/dumps/core" \
  --out-dir "$NYRA_WORK/out/dump-core"

"$NYRAC" dump-c "$NYRA_WORK/playground/main.ny" \
  -o "$NYRA_WORK/dumps/c" \
  --out-dir "$NYRA_WORK/out/dump-c"

"$NYRAC" -O0 --ir-stage raw dump-ir "$NYRA_WORK/playground/main.ny" \
  -o "$NYRA_WORK/dumps/ir" \
  --out-dir "$NYRA_WORK/out/dump-ir"
```

Inspect language AST, Core AST, C projection and LLVM IR separately. Outputs may
be per TU; concatenating .ll files is not a linking strategy. dump-c is an
inspection/reference view; the normal native path lowers Core to LLVM directly.

## 4. Observe progress with verbose

```sh
"$NYRAC" --verbose build "$NYRA_WORK/playground/main.ny" --link \
  --out-dir "$NYRA_WORK/out/verbose" \
  -o "$NYRA_WORK/out/verbose/program"
```

Progress and stage timings help locate work in a large TU. A temporary lack of
output alone does not establish deadlock.

## 5. Measure compiler work

```sh
"$NYRAC" --profile cpu,memory -O0 --ir-stage raw \
  dump-ir "$NYRA_WORK/playground/main.ny" \
  -o "$NYRA_WORK/dumps/profile-ir" \
  --out-dir "$NYRA_WORK/out/profile-ir" \
  2> "$NYRA_WORK/dumps/compiler-profile.log"

cat "$NYRA_WORK/dumps/compiler-profile.log"
```

This profiles compilation, not execution of the compiled application. Read the
raw stage log; private development report scripts are not SDK tools. Distinguish
elapsed time, CPU time, allocation count, cumulative bytes, live bytes, peak
usage and RSS. Parallel CPU time can exceed elapsed time, instrumentation has
cost, and custom allocators may not enter every default heap counter.

## 6. Measure a synchronous user function

Complete program:

```nyra
import "stdlib:stdlib.ny";

@profile(cpu, memory, tag = "lesson.message")
func make_message() -> string {
  var buffer: StringBuffer = StringBuffer.NewWithCapacity(64);
  buffer.Append("你好");
  buffer.Append("，Nyra");
  return buffer.Take();
}

func main() -> int32 {
  var sink: BoundedProfileSink =
    BoundedProfileSink.New(CreateAllocator(0i64, 8i64), 32);
  if !HostedProfileCaptureStart(&mut sink) {
    sink.Release();
    return 1;
  }
  let message: string = make_message();
  if !HostedProfileCaptureStop() {
    sink.Release();
    return 2;
  }
  Console.Eprintln("生成结果：{0}", message);
  let writer: HostedProfileTextWriter = HostedProfileTextWriter.New();
  ProfileExportText(&sink, writer, false, false, ProfileRcUnboundEventCount());
  sink.Release();
  return 0;
}
```

Build and run:

```sh
"$NYRAC" --profile cpu,memory build "$NYRA_WORK/playground/main.ny" --link \
  --out-dir "$NYRA_WORK/out/user-profile" \
  -o "$NYRA_WORK/out/user-profile/program"

"$NYRA_WORK/out/user-profile/program" \
  > "$NYRA_WORK/dumps/user-profile.stdout" \
  2> "$NYRA_WORK/dumps/user-profile.stderr"
```

Probe records go to user-profile.stdout and explanatory messages to stderr.
Inspect the captured output:

```sh
cat "$NYRA_WORK/dumps/user-profile.stdout"
```

Site IDs can require matching IR metadata. Check buffer capacity, dropped events,
unbound events and export completeness. Incomplete records cannot prove absence
of leaks. This example does not establish async/generator or all-allocator coverage.

## 7. Compare optimization consistently

Use O0 for inspection and O2 for an optimized build:

```sh
"$NYRAC" -O2 build "$NYRA_WORK/playground/main.ny" --link \
  --out-dir "$NYRA_WORK/out/release" \
  -o "$NYRA_WORK/out/release/program"
```

The option uses the letter O, not zero. Keep compiler, input, optimization/debug
settings and cache conditions comparable. Cross-target builds also need correct
runtime packages and host system tools, not just a target name.

## Exercise

Export the small program at O0 and O2 into different directories. See whether add
remains a call or becomes inlined/constant-folded; actual output is authoritative.
