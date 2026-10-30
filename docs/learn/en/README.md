# Learn Nyra

[中文](../README.md) · [Course index](README.md)

This course starts with your first program and builds toward a small tool split
into clear modules. No language-design background is required. Start with lesson
00 for your platform, even if you already know another programming language.

## Language reference: look up definitions and complete examples

- [Keyword and type dictionary](reference-keywords.md): each word's purpose, position and contextual distinctions.
- [Types and behavior](reference-types.md): structs, extends, instance/static methods, factories, get/set, interfaces, delegation, drop and duplicate-name rules.
- [Modules and visibility](reference-modules.md): import/export/module/part, as/show/hide, a complete five-file project and responsibility boundaries.
- [Metadata dictionary](reference-metadata.md): valid targets, arguments, effects, restrictions and complete examples.

These four references are available throughout the course. Lessons 03, 04, 07, 08
and 10 link directly to their relevant companion.

The nine complete program groups and one test file added in these references were checked and run on macOS arm64 with the native 1.0.3 seed compiler: two tests passed and one was ignored as declared. This focused example check is not a rerun of the other lessons or SDK release acceptance.

## How to use the course

Read one lesson at a time: run a complete example, change one or two things,
observe the result, then try the exercise.

- A **complete program** replaces the entire practice `main.ny`.
- A **fragment** belongs in the indicated function or declaration location.
- An **intentionally invalid example** teaches a diagnostic; keep it separate.
- Expected output is a learning target, not a new execution acceptance report.

Start with the [SDK 1.0.3 installation guide](../../../INSTALL.md). The public
setup needs no compiler implementation checkout. These lessons were adapted
from development-era material; not every example was rerun for this translation.
JSON/YAML consumers must account for the [1.0.3 Git-lock issue](../../../RELEASE-1.0.3.md).
The mobile lessons retain integration references using development tools that
are not distributed in the public SDK. Candidate 1.0.4 commands are labelled;
do not assume they exist in 1.0.3.

Examples retain some Chinese strings and expected output as intentional UTF-8
test data. The surrounding explanations, setup and navigation are in English.

After setup, save the lesson's program as `playground/main.ny`, then run:

```sh
"$NYRAC" check "$NYRA_WORK/playground/main.ny"
"$NYRAC" run "$NYRA_WORK/playground/main.ny" \
  --out-dir "$NYRA_WORK/out/current"
```

Windows PowerShell:

```powershell
& $env:NYRAC check "$env:NYRA_WORK/playground/main.ny"
& $env:NYRAC run "$env:NYRA_WORK/playground/main.ny" --out-dir "$env:NYRA_WORK/out/current"
```

Use a lesson's own directory when it introduces a separate package. Run complete
programs separately rather than combining multiple `main` functions. Stop after
a failed build; do not accidentally run an executable left by an earlier build.

## Choose your platform

Start at [00: platform selection](00-start.md):

- [macOS](00-macos-start.md): Apple silicon or the matching Intel SDK.
- [Windows](00-windows-start.md): x86_64, developer PowerShell and command syntax.
- [Linux](00-linux-start.md): x86_64, native development dependencies and Bash.

The Nyra source is the same; use the shell syntax for your host.

## Stage 1: small programs

1. [00: setup and first program](00-start.md)
2. [01: values, types and output](01-values.md)
3. [02: conditions, loops and functions](02-control-functions.md)
4. [03: structs and methods](03-structs.md)

You can now calculate prices, make decisions and organize related data.

## Stage 2: data, ownership and projects

5. [04: borrowing, copying and moving](04-ownership.md)
6. [05: strings, arrays and maps](05-collections.md)
7. [06: optional values and errors](06-errors.md)
8. [07: files, modules and packages](07-packages.md)
9. [08: generics, interfaces and callbacks](08-generics.md)

The goal is to explain who owns each value and divide code by responsibility.

## Stage 3: a working tool

10. [09: Unicode, files, JSON and YAML](09-text-files.md)
11. [10: tests and the analyzer](10-tests-analyzer.md)
12. [11: task-report project](11-task-report.md)

Combine input, processing, output and failure handling before moving on.

## Stage 4: optional systems topics

13. [12: async functions, generators and threads](12-concurrency.md)
14. [13: pointers, allocators and kernel code](13-systems.md)
15. [14: compiler views and profiling](14-compiler-tools.md)

Ordinary applications do not require manual pointer management or allocators.

## Stage 5: C and mobile integration

16. [15: calling between Nyra and C](15-c-interop.md)
17. [16: iOS integration reference](16-ios.md)
18. [17: Android integration reference](17-android.md)

Mobile lessons start with dependency-free integer logic and describe runtime
integration separately. Library builds, app packaging and device execution are
separate steps; expected UI output does not establish device acceptance.

## When something goes wrong

Check the platform setup, environment variables, file path, fragment placement,
`{0}`/`{1}` output placeholders and required semicolons. Keep practice source and
build outputs in your `NYRA_WORK` directory, outside SDK implementation files.

[Begin with lesson 00](00-start.md).
