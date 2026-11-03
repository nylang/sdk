# Language continuation: generics through Flow

[中文](../../intermediate/README.md) · [Course index](../README.md)

Finish foundations 01–15 first. Use the complete SDK 1.0.5 and the same playground/environment commands, replacing main.ny with one program at a time. Each lesson has three examples plus one independent answer: 32 mainline programs, plus two clearly labelled SDK-limited protocol references. Never combine their mains.

Lessons 16–18 build on functions/interfaces; 19–20 cover synchronous sequences. Review [Result and errors](../06-errors.md) before 21–23. Each source package provides package.yaml and expected.txt. See [foundation setup](../fundamentals/README.md) for execution commands.

16. [16 · Generics: type parameters, inference and constraints](16-generics.md)
17. [17 · Function values, lambdas and captures](17-lambda.md)
18. [18 · Variadics: enable channels, access and forwarding](18-variadics.md)
19. [19 · Iterable and Iterator: the cursor protocol](19-iterators.md)
20. [20 · Sync generators: iterables with yield](20-sync-generators.md)
21. [21 · Async/await: one result and an explicit executor](21-async-await.md)
22. [22 · Futures, promises and asynchronous errors](22-future-errors.md)
23. [23 · Async generators and Flow: sequences and collection boundaries](23-async-flow.md)

Continue with [files/JSON/YAML](../09-text-files.md), [testing](../10-tests-analyzer.md), and the [project](../11-task-report.md). For lookup use the [dictionary](../reference-keywords.md) and [help manuals](../../../manual/README.md).

Availability: lesson 20’s protocol reference is labelled with a SDK 1.0.5 compiler defect. Its expected protocol result is not a claim that the SDK runs that form. Keep the remaining examples’ tools and libraries coherent too.

Lesson 23’s protocol reference has a second known limitation: lowering await inside async*. See the notice before its code. Neither defect changes the language contract.
