# 14 · interface：先定义能力，再提供实现

[English](../en/fundamentals/14-interfaces.md) · [上一课](13-extends.md) · [基础目录](README.md) · [下一课](15-interface-design.md)

## 本课目标

当调用者只关心“能读一个分数”，不关心字段布局时，用接口表达能力。本课先写一个类型的契约，再让两个无继承关系的类型满足同一契约，最后展示属性签名。

## 先读语法，再看程序

`interface Scored { Score() -> int32; }` 内只有签名，不写方法体。结构体显式写 implements Scored，再在 struct 外提供方法。接口类型的参数经接口契约调用；这才是方法表多态，不是 struct extends 的虚方法。

## 例 1：一个契约与一个实现

[下载源码](../examples/fundamentals/interface-one/main.ny) · [package.yaml](../examples/fundamentals/interface-one/package.yaml) · [expected.txt](../examples/fundamentals/interface-one/expected.txt)

```nyra
import "stdlib:stdlib.ny";

interface Scored {
  Score() -> int32;
}

struct Exam implements Scored {
  points: int32;
}

method(Exam) Score() -> int32 {
  return self.points;
}

func read_score(value: Scored) -> int32 {
  return value.Score();
}

func main() -> int32 {
  let exam: Exam = Exam{ points: 42 };
  Console.Println("score={0}", read_score(exam));

  return 0;
}
```

预期输出：

```text
score=42
```

read_score 只知道 Scored，不知道 Exam.points。implements 声明契约，方法体完成契约；光有同名方法不能代替明确的接口声明。拥有局部 exam 的作用域覆盖了接口调用。

## 例 2：同一调用者接受两个无关类型

[下载源码](../examples/fundamentals/interface-two/main.ny) · [package.yaml](../examples/fundamentals/interface-two/package.yaml) · [expected.txt](../examples/fundamentals/interface-two/expected.txt)

```nyra
import "stdlib:stdlib.ny";

interface Scored {
  Score() -> int32;
}

struct Exam implements Scored {
  points: int32;
}

struct Bonus implements Scored {
  base: int32;
  extra: int32;
}

method(Exam) Score() -> int32 {
  return self.points;
}

method(Bonus) Score() -> int32 {
  return self.base + self.extra;
}

func read_score(value: Scored) -> int32 {
  return value.Score();
}

func main() -> int32 {
  let exam: Exam = Exam{ points: 40 };
  let bonus: Bonus = Bonus{ base: 20, extra: 2 };

  Console.Println("exam={0}, bonus={1}", read_score(exam), read_score(bonus));

  return 0;
}
```

预期输出：

```text
exam=40, bonus=22
```

Exam 与 Bonus 没有 extends 关系，仍能满足同一行为合同。Score 是各自类型上的方法，名字相同合法。read_score 不需要写 if 判断具体类型，也不需要读它们的字段。

## 例 3：接口里的属性要有完整类型

[下载源码](../examples/fundamentals/interface-properties/main.ny) · [package.yaml](../examples/fundamentals/interface-properties/package.yaml) · [expected.txt](../examples/fundamentals/interface-properties/expected.txt)

```nyra
import "stdlib:stdlib.ny";

interface ValueView {
  get value -> int32;
  set value(next: int32) -> void;
}

struct Counter implements ValueView {
  current: int32;
}

method(Counter) get value -> int32 {
  return self.current;
}

method(Counter) set value(next: int32) {
  self.current = next;
}

func read_value(view: ValueView) -> int32 {
  return view.value;
}

func main() -> int32 {
  var counter: Counter = Counter{ current: 42 };
  Console.Println("value={0}", read_value(counter));

  return 0;
}
```

预期输出：

```text
value=42
```

接口 getter 声明返回类型；setter 声明参数类型及 void，末尾都是分号。实现中的后备字段 current 不出现在接口里。接口本身不存一份 current，也不自动生成 getter/setter。

## 常见错误与边界

方法参数和返回类型必须匹配接口签名，不能把 Score() -> int32 实现成 Score(n: int32)。接口体不能放 Console.Println 等实现语句。这些完整例子使用已发布 1.0.x 基础接口拼写；开发期 @override 迁移不作为本课前提。

## 练习：先自己写，再看答案

定义 Named 接口，要求 Name() -> string。让 Book 和 Person 各自实现；用同一个输出函数接受两种值。

<details>
<summary>完整参考答案与解释</summary>

[下载源码](../examples/fundamentals/14-interfaces-answer/main.ny) · [package.yaml](../examples/fundamentals/14-interfaces-answer/package.yaml) · [expected.txt](../examples/fundamentals/14-interfaces-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

interface Named {
  Name() -> string;
}

struct Book implements Named {
  title: string;
}

struct Person implements Named {
  name: string;
}

method(Book) Name() -> string {
  return self.title;
}

method(Person) Name() -> string {
  return self.name;
}

func print_name(value: Named) -> void {
  Console.Println("name={0}", value.Name());
}

func main() -> int32 {
  let book: Book = Book{ title: "Guide" };
  let person: Person = Person{ name: "Ada" };
  print_name(book);
  print_name(person);

  return 0;
}
```

预期输出：

```text
name=Guide
name=Ada
```

分别用字段 title 和 name 保存数据，两个 method 各返回自己的字段；调用者参数为 Named，只调用 value.Name()。不要为了共享接口强造 Book extends Person。

</details>

## 读完应能回答

指出本课每个声明的类型、每次写入改变了谁、每个调用需要什么输入。解释例子中的输出，再用练习的边界输入验证自己的理解。若解释不清，回到本课第一例逐条跟踪，而不是直接加上下一课语法。

[上一课](13-extends.md) · [基础目录](README.md) · [下一课](15-interface-design.md)
