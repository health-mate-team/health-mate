import 'analytics_event.dart';

/// 분석 이벤트 기록 인터페이스.
/// 04_SUCCESS_METRICS data_storage_principles 준수:
///  - 디바이스 로컬 우선
///  - 서버 동기화는 별도(synced 플래그)
abstract class AnalyticsRecorder {
  Future<void> record(AnalyticsEvent event);
}
