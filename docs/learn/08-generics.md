# 08 · 泛型、接口和回调

[English](en/08-generics.md)

[上一课](07-packages.md) · [教程目录](README.md) · [下一课](09-text-files.md)

这一课解决三种重复：相同的计算只是类型不同；不同的数据提供同一种能力；同一个算法需要换一步操作。

## 1. 一个函数处理多种数字

完整程序：

```nyra
import "stdlib:stdlib.ny";

func larger<T: num>(left: T, right: T) -> T {
  if left > right { return left; }
  return right;
}

func main() -> int32 {
  let integer: int32 = larger<int32>(12, 30);
  let decimal: float64 = larger<float64>(1.5, 2.5);
  Console.Println("整数：{0}", integer);
  Console.Println("小数比较正确：{0}", decimal == 2.5);
  return 0;
}
```

`T` 是类型参数，使用时可以变成 `int32` 或 `float64`。
`T: num` 限定它用于数字类型，让函数里的数值操作有明确前提。
泛型不是把任何类型都当成同一段未检查的数据。

## 2. 泛型也可以定义结构体

完整程序：

```nyra
import "stdlib:stdlib.ny";

struct Box<T> {
  value: T;
}

method(Box<T>) Get() -> T {
  return self.value;
}

func main() -> int32 {
  let number: Box<int32> = Box<int32> { value: 42 };
  let word: Box<string> = Box<string> { value: "Nyra" };
  Console.Println("{0}：{1}", word.Get(), number.Get());
  return 0;
}
```

`Box<int32>` 和 `Box<string>` 是不同的具体类型。
前面学过的 `Array<int32>`、`HashMap<string, int32>` 就是这种“带类型参数”的写法。

## 3. 用接口描述一种能力

完整程序：

```nyra
import "stdlib:stdlib.ny";

interface Scored {
  Score() -> int32;
}

struct Quiz implements Scored {
  correct: int32;
}

method(Quiz) Score() -> int32 {
  return self.correct * 10;
}

func show_score(item: Scored) -> void {
  Console.Println("得分：{0}", item.Score());
}

func main() -> int32 {
  let quiz: Quiz = Quiz { correct: 8 };
  show_score(quiz);
  return 0;
}
```

预期得分 80。`Scored` 只说明“有一个 `Score()` 方法”。
`Quiz implements Scored` 明确声明自己提供这个能力，并在结构体外实现方法。
以后增加另一种评分对象，只要实现同样接口，`show_score` 就可以复用。

接口不是把整个标准库类型写死进编译器。自定义类型也能遵守同样的公开约定。

## 4. 把函数当成参数

完整程序：

```nyra
import "stdlib:stdlib.ny";

func add_one(value: int32) -> int32 {
  return value + 1;
}

func apply_twice(value: int32, transform: (int32) -> int32) -> int32 {
  return transform(transform(value));
}

func main() -> int32 {
  Console.Println("{0}", apply_twice(40, add_one));
  return 0;
}
```

结果是 42。`(int32) -> int32` 表示接收一个整数、返回一个整数的函数类型。

## 5. 需要临时小函数时用 `lambda`

在上一节 `main` 里面可以改用：

```nyra
let step: int32 = 1;
let transform: (int32) -> int32 = lambda [copy step] (value: int32) -> int32 {
  return value + step;
};
Console.Println("{0}", apply_twice(40, transform));
```

`[copy step]` 明确把需要的外部值捕获进来。
不要写成只有 `[step]`，也不要假设所有借用捕获形式都已支持。
先使用具名函数或显式 `copy` 捕获，生命周期更容易看清。

## 6. 编译时分支和运行时分支

定义片段，放在 `main` 外面：

```nyra
func layout_size<T>() -> uintptr {
  if constexpr (sizeof(T) <= 8up) {
    return 8up;
  } else {
    return sizeof(T);
  }
}
```

`if constexpr` 根据编译时已知条件选择分支。
普通 `if` 根据程序运行时的数据决定走哪条路。
不要把所有判断都改成 `if constexpr`：用户输入的数字不是编译时就知道的。

## 练习

增加一个 `Homework implements Scored`，字段是 `points: int32`，`Score()` 直接返回它。
调用 `show_score(Homework { points: 95 })`。

参考新增定义：

```nyra
struct Homework implements Scored {
  points: int32;
}

method(Homework) Score() -> int32 {
  return self.points;
}
```

输出应为 `得分：95`，`show_score` 不需要改动。
