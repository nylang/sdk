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
