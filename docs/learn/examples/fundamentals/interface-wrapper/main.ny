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
