import 'package:health_mate/features/cycle/domain/entities/cycle_input.dart';

abstract class CycleRepository {
  Future<CycleInput?> read();
  Stream<CycleInput?> watch();
  Future<void> save(CycleInput input);
}
