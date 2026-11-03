# 15 · 接口扩展、delegate 与组合边界

[English](../en/fundamentals/15-interface-design.md) · [上一课](14-interfaces.md) · [基础目录](README.md) · [下一课](../04-ownership.md)

## 本课目标

能写出单个接口后，再决定如何扩展合同、转交已有能力、保留调用者边界。这里分三步，不在一个程序里同时引入泛型、资源释放和多接口图。

## 先读语法，再看程序

接口 extends 扩展的是要求集合，不是结构体字段。`delegate field : Iface;` 在包装结构体内明确把接口操作转交某字段；字段必须存在并满足接口。显式实现可决定包装层自己的行为，歧义不能默默任选。

## 例 1：子接口包含父接口要求

[下载源码](../examples/fundamentals/interface-extends/main.ny) · [package.yaml](../examples/fundamentals/interface-extends/package.yaml) · [expected.txt](../examples/fundamentals/interface-extends/expected.txt)

```nyra
import "stdlib:stdlib.ny";

interface Scored {
  Score() -> int32;
}

interface Ranked extends Scored {
  Rank() -> int32;
}

struct ResultCard implements Ranked {
  points: int32;
}

method(ResultCard) Score() -> int32 {
  return self.points;
}

method(ResultCard) Rank() -> int32 {
  return 1;
}

func ranked_total(card: Ranked) -> int32 {
  return card.Score() + card.Rank();
}

func main() -> int32 {
  let card: ResultCard = ResultCard{ points: 41 };
  Console.Println("total={0}", ranked_total(card));

  return 0;
}
```

预期输出：

```text
total=42
```

Ranked 需要 Score 和 Rank，因此只实现 Rank 不够。不要把它与 struct ResultCard extends Scored 混写：Scored 是接口，不是字段基类。本课只使用单父接口。

## 例 2：包装类型显式委托

[下载源码](../examples/fundamentals/interface-delegate/main.ny) · [package.yaml](../examples/fundamentals/interface-delegate/package.yaml) · [expected.txt](../examples/fundamentals/interface-delegate/expected.txt)

```nyra
import "stdlib:stdlib.ny";

interface Scored {
  Score() -> int32;
}

struct ScoreCard implements Scored {
  points: int32;
}

method(ScoreCard) Score() -> int32 {
  return self.points;
}

struct ScorePanel {
  card: ScoreCard;
  delegate card : Scored;
}

func read_score(value: Scored) -> int32 {
  return value.Score();
}

func main() -> int32 {
  let panel: ScorePanel = ScorePanel{ card: ScoreCard{ points: 42 } };
  Console.Println("score={0}", read_score(panel));

  return 0;
}
```

预期输出：

```text
score=42
```

ScorePanel 选择把 Scored 转发给 card。不是把 card 所有字段与方法合并进包装布局，也不是 module 的 part。若两个字段都转发同名操作，要明确解决歧义。

## 例 3：包装层有不同规则时自己实现

[下载源码](../examples/fundamentals/interface-wrapper/main.ny) · [package.yaml](../examples/fundamentals/interface-wrapper/package.yaml) · [expected.txt](../examples/fundamentals/interface-wrapper/expected.txt)

```nyra
import "stdlib:stdlib.ny";

interface Scored {
  Score() -> int32;
}

struct ScoreCard implements Scored {
  points: int32;
}

method(ScoreCard) Score() -> int32 {
  return self.points;
}

struct BonusPanel implements Scored {
  card: ScoreCard;
  bonus: int32;
}

method(BonusPanel) Score() -> int32 {
  return self.card.Score() + self.bonus;
}

func read_score(value: Scored) -> int32 {
  return value.Score();
}

func main() -> int32 {
  let panel: BonusPanel = BonusPanel{ card: ScoreCard{ points: 40 }, bonus: 2 };
  Console.Println("score={0}", read_score(panel));

  return 0;
}
```

预期输出：

```text
score=42
```

这次不盲目委托，因为包装层需要加 bonus。调用者仍只知道 Scored。对比三种关系：struct extends 复用基础布局，interface extends 扩展合同，字段组合再委托／实现封装行为。

## 常见错误与边界

不要假定任意同名方法都自动转成接口实现；不要假定多父接口、菱形合并和开发中的继承符合性已经由这些例子覆盖。接口视图不会让局部资源永久存活；保存接口值仍需核对生命周期与所有权。

## 练习：先自己写，再看答案

为 BonusPanel 增加一个只返回 card.Score() 的 BaseScore()。解释它为何不必加入 Scored。再说明何时应该新建接口，而不是不断给 Scored 塞要求。

<details>
<summary>完整参考答案与解释</summary>

[下载源码](../examples/fundamentals/15-interface-design-answer/main.ny) · [package.yaml](../examples/fundamentals/15-interface-design-answer/package.yaml) · [expected.txt](../examples/fundamentals/15-interface-design-answer/expected.txt)

```nyra
import "stdlib:stdlib.ny";

interface Scored {
  Score() -> int32;
}

struct ScoreCard implements Scored {
  points: int32;
}

method(ScoreCard) Score() -> int32 {
  return self.points;
}

struct BonusPanel implements Scored {
  card: ScoreCard;
  bonus: int32;
}

method(BonusPanel) BaseScore() -> int32 {
  return self.card.Score();
}

method(BonusPanel) Score() -> int32 {
  return self.BaseScore() + self.bonus;
}

func main() -> int32 {
  let panel: BonusPanel = BonusPanel{ card: ScoreCard{ points: 40 }, bonus: 2 };
  Console.Println("base={0}, score={1}", panel.BaseScore(), panel.Score());

  return 0;
}
```

预期输出：

```text
base=40, score=42
```

只供具体包装类型使用的便利方法可留在该类型上。只有所有相应调用者和实现都需要的稳定能力才进入该接口；独立职责应设计独立接口。

</details>

## 读完应能回答

指出本课每个声明的类型、每次写入改变了谁、每个调用需要什么输入。解释例子中的输出，再用练习的边界输入验证自己的理解。若解释不清，回到本课第一例逐条跟踪，而不是直接加上下一课语法。

[上一课](14-interfaces.md) · [基础目录](README.md) · [下一课](../04-ownership.md)
