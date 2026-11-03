import "stdlib:stdlib.ny";

func main() -> int32 {
  var scores: <int32>[] = { 10, 20, 30 };
  scores[1] = 42;

  Console.Println("first={0}, second={1}, last={2}", scores[0], scores[1], scores[2]);

  return 0;
}
