/// 호르몬 주기 4단계.
/// 02_CYCLE_OS.json phases[*].id 와 1:1 매핑된다 — 추가/삭제 시 SOURCE OF TRUTH도 함께 변경할 것.
enum CyclePhase {
  menstrual,
  follicular,
  ovulatory,
  luteal,
}

/// 황체기 내부의 세부 단계. 02_CYCLE_OS.json phases[luteal].sub_phases.
enum LutealSubPhase {
  early,
  late,
}

extension CyclePhaseDisplay on CyclePhase {
  String get id {
    switch (this) {
      case CyclePhase.menstrual:
        return 'menstrual';
      case CyclePhase.follicular:
        return 'follicular';
      case CyclePhase.ovulatory:
        return 'ovulatory';
      case CyclePhase.luteal:
        return 'luteal';
    }
  }

  String get koreanName {
    switch (this) {
      case CyclePhase.menstrual:
        return '월경기';
      case CyclePhase.follicular:
        return '난포기';
      case CyclePhase.ovulatory:
        return '배란기';
      case CyclePhase.luteal:
        return '황체기';
    }
  }

  String get metaphor {
    switch (this) {
      case CyclePhase.menstrual:
        return '겨울';
      case CyclePhase.follicular:
        return '봄';
      case CyclePhase.ovulatory:
        return '여름';
      case CyclePhase.luteal:
        return '가을';
    }
  }

  String get emoji {
    switch (this) {
      case CyclePhase.menstrual:
        return '🌑';
      case CyclePhase.follicular:
        return '🌱';
      case CyclePhase.ovulatory:
        return '☀️';
      case CyclePhase.luteal:
        return '🍂';
    }
  }
}

CyclePhase? cyclePhaseFromId(String id) {
  for (final p in CyclePhase.values) {
    if (p.id == id) return p;
  }
  return null;
}
