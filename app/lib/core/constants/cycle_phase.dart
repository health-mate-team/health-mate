enum CyclePhase {
  menstrual,
  follicular,
  ovulation,
  luteal;

  static CyclePhase parse(String value) {
    return CyclePhase.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CyclePhase.follicular,
    );
  }
}
