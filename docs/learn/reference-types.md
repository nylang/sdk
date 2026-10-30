# 类型详解：struct、方法、工厂、属性、接口与 drop

[English](en/reference-types.md) · [教程目录](README.md) · [语言字典](reference-keywords.md)

本页每个“完整程序”独立替换 `main.ny`，按第 00 课命令检查和运行。
成功返回 0；非零表示例子中的检查失败。代码中的 `...` 不作为实现占位符。

## 1. 定义位置与调用形式

| 目的 | 定义形式 | 调用形式 | 有没有 `self` |
|---|---|---|---|
| 数据 | `struct Counter { current: int32; }` | `Counter{ current: 0 }` | 无方法体 |
| 实例行为 | `method(Counter) Add(n: int32) -> void` | `counter.Add(2)` | 有 |
| 类型级操作 | `static method(Counter) Zero() -> Counter` | `Counter.Zero()` | 无 |
| 拥有对象的创建 | `factory(Counter) Make(n: int32) -> unique<Counter>` | `Counter.Make(42)` | 无 |
| 读取属性 | `method(Counter) get value -> int32` | `counter.value` | 有 |
| 写入属性 | `method(Counter) set value(next: int32)` | `counter.value = 42` | 有 |
| 自动清理 | `method(Ticket) operator drop() -> void` | 编译器插入 | 有，不能当普通方法手调 |

方法、工厂、属性都写在结构体定义外面。接口成员是签名例外：直接写在接口体内。
跨模块公开使用时，相应类型和提供的操作都要有 `pub`；本页单模块程序省略它。

## 2. 一份完整程序：方法、静态方法、工厂、get/set、接口

```nyra
interface CounterView {
  Read() -> int32;
  get value -> int32;
  set value(next: int32) -> void;
}

struct Counter implements CounterView {
  current: int32;
}

method(Counter) Read() -> int32 {
  return self.current;
}

method(Counter) Add(amount: int32) -> void {
  self.current = self.current + amount;
}

method(Counter) get value -> int32 {
  return self.current;
}

method(Counter) set value(next: int32) {
  // Keep the property's invariant in one place.
  if next < 0 {
    self.current = 0;
    return;
  }

  self.current = next;
}

static method(Counter) Zero() -> Counter {
  return Counter{ current: 0 };
}

factory(Counter) Make(initial: int32) -> unique<Counter> {
  var result: unique<Counter> = new unique<Counter>{ current: 0 };
  result.value = initial;

  return move(result);
}

func read_counter(counter: CounterView) -> int32 {
  return counter.Read();
}

func main() -> int32 {
  var counter: Counter = Counter.Zero();
  counter.value = 40;
  counter.Add(2);

  if counter.value != 42 {
    return 1;
  }

  if read_counter(counter) != 42 {
    return 2;
  }

  let owned_counter: unique<Counter> = Counter.Make(42);
  if owned_counter.Read() != 42 {
    return 3;
  }

  return 0;
}
```

这里的检查分别说明：

- `Counter` 是字段布局；`current` 是后备字段，`value` 是带逻辑的属性，名字刻意不同，避免递归调用属性自身。
- `Add` 操作一个已有对象，`self` 是调用点左侧的 `counter`。修改值的调用者使用 `var`。
- `Counter.Zero()` 是静态方法，返回普通 `Counter` 值；它不能读取某个不存在的 `self`。
- `Counter.Make()` 是命名工厂，返回 `unique<Counter>`。它先创建对象，再经 setter 建立不变量，最后转移结果。
- 工厂允许的拥有结果是 `unique`／`rc`／`arc`。返回普通值的类型级创建便利函数用 `static method`，不要写 `static factory`。
- `get` 没有参数括号；`set` 接受一个值。属性访问不是 `counter.value()`，setter 也不是手调 `set`。
- `CounterView` 明确写出方法、getter 和 setter 的完整类型。结构体用 `implements` 声明契约；接口调用 `read_counter` 使用该契约。

字段公开和封装是不同问题：setter 并不自动禁止同一布局可见处直接写 `current`。
需要严格隐藏布局的库还应设计 `.ni` 公开声明与私有实现，见[模块详解](reference-modules.md)。

## 3. 同名、重载和命名

同一接收类型的普通方法名必须唯一，不能只靠参数个数、参数类型或返回类型区分。
静态方法和实例方法也不要用同一个普通方法名。改用表达意图的名字，如 `Add`、`AddWide`。
不同类型可以各自拥有 `Read`，不是全局禁止一切同名。
getter 与 setter 可以配对使用同一属性名，它们是分开的访问器，不是两个普通方法重载。
工厂也应使用不同的命名入口，例如 `Make`、`FromBytes`，不要按参数签名重载。

故意写错的声明片段（不能和完整程序一起使用）：

```nyra
// Intentionally invalid: parameter types do not create overload slots.
method(Counter) Add(amount: int32) -> void {
  self.current = self.current + amount;
}

method(Counter) Add(amount: int64) -> void {
  self.current = self.current + (amount as int32);
}
```

方法／工厂用 `UpperCamelCase`；字段、参数、局部变量、属性用 `snake_case`。
操作符保留语言拼写，如 `operator drop`，不是 `Drop` 方法的替代拼法。

## 4. `extends`：结构体布局扩展

完整程序：

```nyra
struct Position {
  x: int32;
  y: int32;
}

struct ColoredPosition extends Position {
  color: int32;
}

method(ColoredPosition) Sum() -> int32 {
  return self.x + self.y;
}

func main() -> int32 {
  let point: ColoredPosition = ColoredPosition{ x: 20, y: 22, color: 7 };
  if point.Sum() != 42 {
    return 1;
  }

  return 0;
}
```

派生布局包含基础字段，因此 `x`、`y` 仍存在；`color` 是新增字段。
一个结构体最多有一个结构体基类。这里不是 C++／Java 的虚函数对象模型，
不要推断虚方法、构造函数链或任意子类型转换。需要运行时行为契约时用接口；
仅想复用一个成员时，组合一个字段通常更清晰。

结构体字面量中省略的字段按零／空初始化，不等于工厂自动执行。
`Counter{}` 不会调用 `Counter.Make()`，也不会自动运行名为 `Init` 的方法。

## 5. `interface` 与接口扩展

完整程序：

```nyra
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

func total(card: Ranked) -> int32 {
  return card.Score() + card.Rank();
}

func main() -> int32 {
  let card: ResultCard = ResultCard{ points: 41 };
  if total(card) != 42 {
    return 1;
  }

  return 0;
}
```

`Ranked extends Scored` 继承接口要求；`ResultCard implements Ranked` 必须提供两项操作。
接口体只有签名，没有方法实现，也不是一个字段布局。
属性契约的写法已经在第 2 节给出；不能省略属性类型而让使用者猜。
这里演示单父接口，不承诺多父／菱形接口模型。

## 6. `delegate`：显式转发一个字段的行为

完整程序：

```nyra
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
  if read_score(panel) != 42 {
    return 1;
  }

  return 0;
}
```

`ScorePanel` 把 `Scored` 操作交给 `card`，不是把整个 `ScoreCard` 的 API 全部继承进来。
字段必须存在并满足该接口。包装类型自己显式定义的同名方法优先；
多个字段转发同一个操作时必须消除歧义。不要把 `delegate` 当成无约束的文本复制。

<a id="drop"></a>
## 7. `drop`：语言触发清理

完整程序：

```nyra
static gDropCount: int32 = 0;

struct Ticket {
  id: int32;
}

method(Ticket) operator drop() -> void {
  // Observe cleanup without introducing a manual heap API.
  gDropCount = gDropCount + 1;
}

func use_ticket() -> void {
  let ticket: Ticket = Ticket{ id: 42 };
  assert(ticket.id == 42);
}

func main() -> int32 {
  use_ticket();
  if gDropCount != 1 {
    return 1;
  }

  return 0;
}
```

`use_ticket` 结束后，局部 `ticket` 的清理由编译器插入，计数变为 1。
示例用单线程全局计数观察清理，不是建议业务代码使用共享可变全局状态。

`drop` 在拥有值生存期结束等清理点运行；`move` 转走拥有权后，源值不再作为旧拥有者清理。
用户 drop 返回后，字段仍按语言规则逆序清理；不要在用户 drop 中再次释放同一个拥有字段。
普通 `string`、容器、`unique`／`rc`／`arc` 依赖语言清理，不要求使用者额外 `Free`。
禁止把 `operator drop` 当普通方法直接调用；`delete` 也不是手动释放语句。

资源类型设计时还要考虑复制／移动策略。禁用复制的声明片段是：

```nyra
method(Ticket) operator copy() -> Ticket = delete;
```

它只禁用复制，不代替清理实现；不要在不理解转移协议时随意定义 copy/move 操作符。

## 练习

在第 2 节给 `Counter` 加一个 `Reset()`，通过 `self.value = 0` 复用 setter；
再检查 `Counter.Make(-1)` 的读取值为 0。解释为什么 `Zero()`、`Make()` 都从类型调用，
却有不同的返回契约。最后把接口拆成独立模块，给公开声明补上 `pub`。
