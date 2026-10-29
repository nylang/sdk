# Package dependencies in the public SDK

[English course](learn/en/README.md) · [中文](package-management.md) · [Install](../INSTALL.md)

## SDK packages

The complete SDK 1.0.3 includes kernel, stdlib and ntest. A basic package needs:

```yaml
name: nyra_lessons
```

Source still imports each required surface. Compilation reads prepared dependencies;
it does not download missing packages.

## Independent ecosystem packages

JSON, YAML, networking, TLS and HTTP have separate repositories and versions.
Published dependencies use public Git URLs and existing version tags, with full
resolved commits in the generated lock. For example, JSON has this tagged form:

```yaml
name: json_lesson
dependencies:
  json:
    git: https://github.com/nylang/json.git
    rev: v0.19.0
```

Use the native nyra tool to run `nyra lock` and `nyra fetch --frozen` before compiling.
Follow the selected package version's README for SDK requirements and native
library construction. A pair of locally authored sibling packages may use a
workspace or relative path; that development layout is distinct from a published
Git declaration.

## The frozen 1.0.3 limitation

The [1.0.3 release notes](../RELEASE-1.0.3.md) disclose a compiler rejection of
an SDK-internal dependency when loading portable Git locks. The fix is assigned
to 1.0.4; this tutorial does not publish it. The manifest above illustrates a
dependency declaration, not blanket compatibility of ecosystem packages with
1.0.3. Begin with SDK packages and use a coherent, accepted toolchain providing
the required fixes before following affected ecosystem examples. Keep compiler,
runtime packages and native objects from compatible inputs.
