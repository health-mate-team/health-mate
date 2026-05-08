import 'package:flutter/widgets.dart';

/// Widget에 flutter_test [ValueKey] + Playwright Web semantics identifier를 동시 부착한다.
///
/// [id] 형식: '{screen}-{component}' (kebab-case)
/// - flutter_test: find.byKey(ValueKey(id))
/// - Playwright Web: [flt-semantics-identifier="{id}"]
Widget withTestId(String id, Widget child) {
  return Semantics(
    key: ValueKey(id),
    identifier: id,
    child: child,
  );
}
