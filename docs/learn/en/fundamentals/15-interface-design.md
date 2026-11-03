# 15 · Interface extension, delegation and composition

[中文](../../fundamentals/15-interface-design.md) · [Previous](14-interfaces.md) · [Foundation index](README.md) · [Next](../04-ownership.md)

## Goals

After a single interface, learn to extend its contract, forward an existing capability and keep caller boundaries clear. Separate these steps without adding generics, resource cleanup or complex interface graphs.

## Read the syntax first

Interface extends adds requirements, not fields. Delegate explicitly forwards an interface operation to a named field that must exist and satisfy the interface. Explicit implementations select wrapper behavior; ambiguous forwarding cannot silently pick one.

## Example 1: include parent interface requirements

[Source](../../examples/fundamentals/interface-extends/main.ny) · [package.yaml](../../examples/fundamentals/interface-extends/package.yaml) · [expected.txt](../../examples/fundamentals/interface-extends/expected.txt)

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

Expected output:

```text
total=42
```

Ranked requires both Score and Rank. Providing only Rank is insufficient. Scored is an interface, not a struct-layout base. This course uses one parent interface.

## Example 2: explicit delegation by a wrapper

[Source](../../examples/fundamentals/interface-delegate/main.ny) · [package.yaml](../../examples/fundamentals/interface-delegate/package.yaml) · [expected.txt](../../examples/fundamentals/interface-delegate/expected.txt)

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

Expected output:

```text
score=42
```

ScorePanel forwards Scored to card. It does not merge every field/method into the wrapper, nor act like a module part. Multiple fields forwarding the same operation need an explicit ambiguity resolution.

## Example 3: implement different wrapper policy explicitly

[Source](../../examples/fundamentals/interface-wrapper/main.ny) · [package.yaml](../../examples/fundamentals/interface-wrapper/package.yaml) · [expected.txt](../../examples/fundamentals/interface-wrapper/expected.txt)

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

Expected output:

```text
score=42
```

Do not blindly delegate when the wrapper adds bonus policy. The caller still knows only Scored. Compare layout extension, interface-contract extension, and composition with forwarding or explicit behavior.

## Common mistakes and boundaries

Do not infer structural conformance from matching names, or assume these examples cover multiple parents, diamonds or development inherited-conformance rules. An interface view does not keep every local resource alive indefinitely; retained values need a deliberate lifetime/ownership design.

## Exercise: try before opening the answer

Add BonusPanel.BaseScore() returning card.Score(). Explain why it need not belong to Scored, and when a new interface is preferable to growing Scored.

<details>
<summary>Complete answer and explanation</summary>

[Source](../../examples/fundamentals/15-interface-design-answer/main.ny) · [package.yaml](../../examples/fundamentals/15-interface-design-answer/package.yaml) · [expected.txt](../../examples/fundamentals/15-interface-design-answer/expected.txt)

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

Expected output:

```text
base=40, score=42
```

A concrete wrapper convenience can stay on its type. Add an interface requirement only for a stable shared capability; separate responsibilities warrant separate interfaces.

</details>

## Check your understanding

Identify each declared type, the value changed by each write, and the inputs required by each call. Explain the output and use exercise boundaries to challenge your explanation. If unclear, trace the first example before adding the next lesson’s syntax.

[Previous](14-interfaces.md) · [Foundation index](README.md) · [Next](../04-ownership.md)
