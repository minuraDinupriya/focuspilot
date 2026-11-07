class Ticker {
  const Ticker();

  Stream<void> pulse() => Stream<void>.periodic(const Duration(seconds: 1));

  Stream<int> tick({required int ticks}) {
    return Stream.periodic(
      const Duration(seconds: 1),
      (x) => ticks - x - 1,
    ).take(ticks);
  }
}
