# 进阶语言课程：从泛型到 Flow

[English](../en/intermediate/README.md) · [教程目录](../README.md)

先完成基础第 01–15 课。这里沿用完整 SDK 1.0.5、同一个 playground 目录和起步课命令；每份程序单独替换 main.ny。每课 3 个完整例子加 1 份独立练习答案，共 32 份主线程序，另保留 2 份显著标注 SDK 限制的协议参考源码。不要把多个 main 合并。

第 16–18 课依赖函数和接口；第 19–20 课解释同步序列；第 21–23 课依赖 Result 错误分支，可先复习[错误处理](../06-errors.md)。每个源码目录都提供 package.yaml 与 expected.txt。运行方式见[基础课程入口](../fundamentals/README.md)。

16. [16 · 泛型：类型参数、推导与约束](16-generics.md)
17. [17 · 函数值、lambda 与捕获](17-lambda.md)
18. [18 · 变参：enable 通道、访问与转发](18-variadics.md)
19. [19 · Iterable 与 Iterator：游标状态协议](19-iterators.md)
20. [20 · sync*：用 yield 编写可迭代序列](20-sync-generators.md)
21. [21 · async/await：单个结果与显式执行器](21-async-await.md)
22. [22 · Future、Promise 与异步错误](22-future-errors.md)
23. [23 · async* 与 Flow：异步序列及收集边界](23-async-flow.md)

继续工程实践：[文件、JSON、YAML](../09-text-files.md) → [测试](../10-tests-analyzer.md) → [综合练习](../11-task-report.md)。查语法时用[语言字典](../reference-keywords.md)；查 API 时用[帮助手册](https://github.com/nylang/sdk/blob/main/docs/manual/README.md)。

版本提示：第 20 课协议补充 标明 SDK 1.0.5 的编译器缺陷；不要把该协议示例的预期结果当作该 SDK 已经支持的运行结果。其他例子也应保持完整工具／库版本一致。

第 23 课协议补充 另有 async* 内 await 的已知降级缺陷，详见代码前的版本提示。两项缺陷都不改变语言合同。
