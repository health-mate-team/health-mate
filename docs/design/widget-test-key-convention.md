# Widget Test Key 규약

> 최초 작성: 2026-05-08 (Phase D)
> 목적: Flutter widget test (ST selector) + Phase E Playwright Web selector 공유

---

## 1. 핵심 원칙

Flutter widget test의 `find.byKey()`와 Playwright Web의 `[flt-semantics-identifier="..."]`
셀렉터가 **동일한 문자열**을 사용하도록 단일 헬퍼로 통합한다.

```
ValueKey(id)            → flutter_test: find.byKey(ValueKey(id))
Semantics(identifier:)  → Playwright Web: [flt-semantics-identifier="{id}"]
```

> **Phase E 주의**: Playwright가 `flt-semantics-identifier`를 잡으려면
> `flutter web --renderer html` 빌드 + semantics 활성화(`SemanticsBinding.ensureSemantics()`)
> 필요. Phase E 진입 시 1회 sanity check 필수.

---

## 2. 헬퍼 함수

`app/lib/shared/utils/test_widget_key.dart`

```dart
/// Widget에 flutter_test key + Playwright Web semantics identifier를 동시 부착한다.
/// [id] = '{screen}-{component}' kebab-case (예: 'morning-mood-card-0')
Widget withTestId(String id, Widget child) {
  return Semantics(
    key: ValueKey(id),
    identifier: id,
    child: child,
  );
}
```

**사용 규칙**:
- `withTestId`는 **인터랙티브 위젯 또는 핵심 표시 위젯**에만 적용 (모든 위젯에 남발 금지)
- 헬퍼를 거치지 않고 `Key`를 직접 달면 Playwright 접근 불가 — 항상 `withTestId` 사용

---

## 3. 네이밍 규약

```
'{screen}-{component}'       기본 형식 (kebab-case)
'{screen}-{component}-{n}'   반복 위젯에 인덱스 추가 (0-based)
```

**screen 접두사 목록**:

| 화면 | 접두사 |
|---|---|
| MorningMoodPage | `morning-mood` |
| MorningPromisePage | `morning-promise` |
| EveningRitualPage | `evening` |
| HomeCharacterPage | `home` |
| OnboardingGoalPage | `onboarding-goal` |

---

## 4. 화면별 Key 카탈로그

### 4-1. MorningMoodPage (`/morning/mood`)

| Key | 위젯 | 설명 |
|---|---|---|
| `morning-mood-card-0` ~ `morning-mood-card-3` | OwnerMoodCard | 기분 선택 카드 (4개, 0-indexed) |

### 4-2. MorningPromisePage (`/morning/promise`)

| Key | 위젯 | 설명 |
|---|---|---|
| `morning-promise-text` | Text (promise) | 현재 약속 텍스트 |
| `morning-promise-commit-btn` | OwnerButton | 약속할게요 버튼 |
| `morning-promise-change-btn` | OwnerButton (text variant) | 다른 걸로 바꾸기 버튼 |

### 4-3. EveningRitualPage (`/evening/ritual`)

| Key | 위젯 | 설명 |
|---|---|---|
| `evening-promise-checkbox` | OwnerCheckbox | 오늘의 약속 체크박스 |
| `evening-mood-cell-0` ~ `evening-mood-cell-N` | _EveningMoodCell | 저녁 기분 선택 (코드 수 기반) |
| `evening-finish-btn` | OwnerButton | 오늘 마무리 버튼 |

### 4-4. HomeCharacterPage (`/home`)

| Key | 위젯 | 설명 |
|---|---|---|
| `home-water-btn` | OwnerQuickActionButton | + 물 한 컵 버튼 |
| `home-walk-btn` | OwnerQuickActionButton | + 산책 버튼 |
| `home-morning-ritual-link` | TextButton | 아침 의식 링크 |
| `home-evening-ritual-link` | TextButton | 저녁 의식 링크 |

---

## 5. Phase E Playwright 사용 가이드

> **Sanity check 결과 (2026-05-08)**: Flutter Web 3.41.9에서 `Semantics(identifier:)`는
> `flt-semantics-identifier` DOM 속성으로 노출되지 않음.
> 대신 Flutter Web이 자동 생성하는 ARIA 접근성 트리를 사용한다.

### Playwright 셀렉터 전략 (role + name 기반)

```typescript
// ✅ 동작하는 방식 — role + accessible name
page.getByRole('button', { name: '오늘 마무리' })    // evening-finish-btn
page.getByRole('button', { name: '약속할게요' })     // morning-promise-commit-btn
page.getByRole('checkbox')                           // promise-checkbox

// ✅ 텍스트 기반
page.getByText('오늘 마무리')

// ❌ 동작 안 함 — DOM에 속성 미노출
page.locator('[flt-semantics-identifier="..."]')
```

### YAML 카탈로그 셀렉터 형식

```yaml
# role + name 형식 (권장)
selector:
  role: button
  name: '오늘 마무리'

# 텍스트 형식 (대안)
selector:
  text: '오늘 마무리'

# role 단독 (인덱스 필요 시)
selector:
  role: checkbox
  index: 0
```

### flutter_test에서 Key 사용 (변경 없음)

```dart
// ValueKey는 widget tree에서 동작 — DOM 속성과 무관
find.byKey(const ValueKey('morning-mood-card-0'))
find.byKey(const ValueKey('evening-finish-btn'))
```

> `Semantics(identifier:)`는 미래 Flutter 버전에서 DOM attribute로 노출될 수 있으므로
> `withTestId` 코드는 유지한다. 단, Playwright 셀렉터는 role+name 방식을 사용한다.

---

## 6. flutter_test 사용 가이드

```dart
// widget test에서 key로 찾기
find.byKey(const ValueKey('morning-mood-card-0'))
find.byKey(const ValueKey('evening-finish-btn'))

// 예시
testWidgets('기분 카드 탭 시 제출됨', (tester) async {
  // ...
  await tester.tap(find.byKey(const ValueKey('morning-mood-card-0')));
  // ...
});
```

---

## 7. 변경 이력

| 날짜 | 변경 내용 |
|---|---|
| 2026-05-08 | 최초 작성 — MorningMood/MorningPromise/EveningRitual/Home 4화면 |
