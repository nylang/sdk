import "stdlib:stdlib.ny";

func log_line(format: ref string, parts: ...enable<string>) -> void {
  Console.Println(format, parts);
}

func main() -> int32 {
  log_line("value={0}, language={1}", 42, "Nyra");

  return 0;
}
