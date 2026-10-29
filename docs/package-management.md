# 公开 SDK 的包依赖说明

[English](package-management.en.md)

[教程目录](learn/README.md) · [安装指南](../INSTALL.md)

## SDK 自带的包

完整 SDK 1.0.3 包含 kernel、stdlib 和 ntest。一个基础练习包只需：

```yaml
name: nyra_lessons
```

源码仍需使用相应 import。编译器只负责读取已有依赖，不会在编译时下载它们。

## 独立生态包

JSON、YAML、网络、TLS 和 HTTP 包在 nylang 组织的各自仓库维护，使用各自版本。
发布依赖使用公开 Git 地址和确实存在的版本 tag；完整 commit 固定在生成的 lock 文件中。
例如 JSON 仓库已有的版本声明形状为：

```yaml
name: json_lesson
dependencies:
  json:
    git: https://github.com/nylang/json.git
    rev: v0.19.0
```

用 SDK 的原生 nyra 工具执行 `nyra lock`、`nyra fetch --frozen` 后再编译。
具体包的构建方法、原生库和 SDK 要求以该版本仓库 README 为准。
本地自己编写的两个包可以使用工作区或相对 path；它们与公开分发的 Git 依赖是不同场景。

## 1.0.3 的已知限制

[1.0.3 发行说明](../RELEASE-1.0.3.md)已披露：portable Git lock 的 SDK 内部依赖
加载可能被编译器误拒绝。修复安排在 1.0.4，尚未由本教程发布。
因此上述 Git 声明是依赖配置说明，不是全部生态包已在 1.0.3 可用的承诺。
基础课程先使用 SDK 自带的包；生态例子须等待或选用具有相应修复且经过验收的完整工具链。

不要为解决版本问题混用不同 SDK 的编译器、运行库和对象文件。
