// 전역 DI 프로바이더 모음
// 각 Feature의 Repository, Service 프로바이더는 해당 feature/data/ 에 위치
// 이 파일에는 앱 전역 공유 프로바이더만 등록

import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: AppDatabase (Drift) 프로바이더
// TODO: ApiClient (Dio/Retrofit) 프로바이더
// TODO: AuthStateNotifier 프로바이더

export '../router/app_router.dart';
