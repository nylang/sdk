# 基础课程：从语句到类型设计

[English](../en/fundamentals/README.md) · [教程总目录](../README.md)

先完成[系统起步课](../00-start.md)，再按下列顺序学习。这里的“C 语言级别”指先掌握语句、数据和函数，并不是把 C 的拼写搬进 Nyra。
前八课建立基础，随后逐步学习数据建模与行为契约。不需要先读语言参考表，也不需要提前懂泛型、分配器或异步。

## 怎么使用每一课

1. 先读本课目标和语法解释，再预测第一份程序的输出。
2. 每个“完整程序”独立替换练习包的整个 main.ny；保留第 00 课建立的 package.yaml 和环境变量。
3. 按下列命令检查并运行；失败后先修正当前源码，不运行以前留下的可执行文件。
4. 对照预期输出，再读“为什么”；每次只改一个输入，观察变化。
5. 尝试练习，再展开完整参考答案。参考答案也可独立编译，不要求猜出缺失的声明。

```sh
"$NYRAC" check "$NYRA_WORK/playground/main.ny"
"$NYRAC" run "$NYRA_WORK/playground/main.ny" \
  --out-dir "$NYRA_WORK/out/fundamentals"
```

Windows PowerShell：

```powershell
& $env:NYRAC check "$env:NYRA_WORK/playground/main.ny"
& $env:NYRAC run "$env:NYRA_WORK/playground/main.ny" --out-dir "$env:NYRA_WORK/out/fundamentals"
```

每份例子也提供 main.ny、package.yaml 与 expected.txt，可从课程链接分别取得。
需要独立运行时，把这三个文件放在一个单独目录，再对它的 main.ny 执行同样命令。
源码链接的文件不是要合并到同一个模块的 part。

本路线以完整的已发布 SDK 1.0.5 为运行起点，讲解基础语法，不要求开发期 init、super、@override、级联或编译期方法。
编译器版本号和可用语法不是一回事；不要把开发设计当成所有旧 SDK 都已提供的能力。
输出块是预期行为，不是 SDK 发行验收记录。不要将 C 的指针所有权或 Java 的虚方法模型直接套用。

## 第一阶段：语句、数据与函数

1. [01 · 从一行输出读懂程序](01-program.md)
2. [02 · 变量、类型、赋值与作用域](02-values.md)
3. [03 · 运算、比较与表达式](03-operators.md)
4. [04 · if、else、switch 与早返回](04-conditions.md)
5. [05 · 循环、范围、break 与 continue](05-loops.md)
6. [06 · 函数、参数、返回值与借用](06-functions.md)
7. [07 · 本地数组、下标与字符串](07-arrays.md)
8. [08 · 借用、地址与 unsafe 的边界](08-addresses.md)

## 第二阶段：结构体、方法与布局扩展

9. [09 · struct：字段、字面量、嵌套与值](09-struct-data.md)
10. [10 · 实例方法：把行为放回数据类型](10-methods.md)
11. [11 · 静态方法、普通值与命名工厂](11-creation.md)
12. [12 · get/set：字段访问与受控属性](12-properties.md)
13. [13 · struct extends：布局扩展与父类型方法](13-extends.md)

## 第三阶段：接口与组合

14. [14 · interface：先定义能力，再提供实现](14-interfaces.md)
15. [15 · 接口扩展、delegate 与组合边界](15-interface-design.md)

## 下一阶段

完成基础后，再学习[所有权](../04-ownership.md)、[动态容器](../05-collections.md)、[错误处理](../06-errors.md)、[模块与包](../07-packages.md)、[泛型与回调](../08-generics.md)。

需要查一个词时使用[字典](../reference-keywords.md)，需要复习组合语法时使用[类型参考](../reference-types.md)。参考表不代替这里的逐步课程。
