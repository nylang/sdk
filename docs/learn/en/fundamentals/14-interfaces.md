# 14 · Interfaces: define a capability, then implement it

[中文](../../fundamentals/14-interfaces.md) · [Previous](13-extends.md) · [Foundation index](README.md) · [Next](15-interface-design.md)

## Goals

Use an interface when callers need a capability, such as reading a score, without knowing field layout. Start with one implementation, then two unrelated types, then fully typed property requirements.

## Read the syntax first

An interface body contains signatures, not implementations. A struct explicitly declares implements Scored and defines methods outside its body. An interface-typed call uses the contract’s dispatch; struct extends does not create virtual methods.

## Example 1: one contract and implementation

[Source](../../examples/fundamentals/interface-one/main.ny) · [package.yaml](../../examples/fundamentals/interface-one/package.yaml) · [expected.txt](../../examples/fundamentals/interface-one/expected.txt)

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

Expected output:

```text
score=42
```

Read_score knows Scored, not Exam.points. Implements declares the contract and the body fulfills it. A matching name alone does not replace the explicit declaration. The local exam remains alive throughout the call.

## Example 2: one caller, two unrelated types

[Source](../../examples/fundamentals/interface-two/main.ny) · [package.yaml](../../examples/fundamentals/interface-two/package.yaml) · [expected.txt](../../examples/fundamentals/interface-two/expected.txt)

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

Expected output:

```text
exam=40, bonus=22
```

Exam and Bonus need no extends relationship. Each owns a method named Score; same names on different receivers are legal. The caller needs neither concrete-type tests nor field access.

## Example 3: fully typed interface properties

[Source](../../examples/fundamentals/interface-properties/main.ny) · [package.yaml](../../examples/fundamentals/interface-properties/package.yaml) · [expected.txt](../../examples/fundamentals/interface-properties/expected.txt)

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

Expected output:

```text
value=42
```

The getter declares its result; the setter declares its value parameter and void result. Both signatures end in semicolons. Current is implementation storage, absent from the contract. The interface does not generate accessors or own a duplicate field.

## Common mistakes and boundaries

Implementation parameter/result types must match: Score(n: int32) does not fulfill Score() -> int32. Interface bodies cannot contain implementation statements. These examples use released 1.0.x interface forms; development @override migration is outside their prerequisites.

## Exercise: try before opening the answer

Define Named requiring Name() -> string. Implement it for Book and Person, then print both through one caller.

<details>
<summary>Complete answer and explanation</summary>

[Source](../../examples/fundamentals/14-interfaces-answer/main.ny) · [package.yaml](../../examples/fundamentals/14-interfaces-answer/package.yaml) · [expected.txt](../../examples/fundamentals/14-interfaces-answer/expected.txt)

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

Expected output:

```text
name=Guide
name=Ada
```

Book stores title and Person stores name; each Name method reads its own field. The caller takes Named and invokes value.Name(). Do not invent Book extends Person to share a contract.

</details>

## Check your understanding

Identify each declared type, the value changed by each write, and the inputs required by each call. Explain the output and use exercise boundaries to challenge your explanation. If unclear, trace the first example before adding the next lesson’s syntax.

[Previous](13-extends.md) · [Foundation index](README.md) · [Next](15-interface-design.md)
