# Reference and example limitations

## SDK 1.0.5: explicit cursor over a sync generator

The language contract permits a sync generator's result to be assigned to
`Iterable<int32>`, followed by explicit `Enum`, `MoveNext` and `Current` calls.
The SDK 1.0.5 macOS arm64 compiler can reject that combination during lowering:

```text
missing checked interface implementation ...ArrayCursor$int32$MoveNext
```

The sync-generator lesson labels its manual-cursor protocol reference as affected. Direct
for-in consumption of a generator and manual iteration of an ordinary Array are
separate teaching paths; neither is a semantic replacement for the legal form.
Do not force a dummy provider reference or rewrite the language contract to hide
this defect. Keep the full reproducer and positive expected result for compiler
maintenance. Do not copy the affected example expecting it to build on 1.0.5.

## SDK 1.0.5: await inside an async generator

An async* producer may await a Future before yielding its next element. The
reference compiler can fail Core lowering with a high-level operation remaining
(tag 10) inside the generated async-star runner. The lesson labels this example
before its source. Ordinary async-await and bounded Flow collection without that
operation remain separate examples; they do not redefine the legal producer
contract. Keep the positive source and expected output for repair verification.

## Metadata lookup is not complete source documentation

The serialized public barrel provides useful public name/owner/result metadata,
but can omit interface-member rows and parameter details such as variadic flags.
The lookup tool labels its output accordingly. For exact signatures, defaults,
constraints and API comments, inspect the shipped exported declarations/open
recipes. Never infer arbitrary API absence from an index miss.

## Hosted asynchronous sequences

The reference SDK's AsyncFlow uses bounded materialization/collection. This is
not a claim of live unbounded streaming, backpressure, await-for support or a
cross-thread emitter. Flow and byte I/O Stream remain different contracts.
A ready queue becoming empty does not establish completion of external I/O.
