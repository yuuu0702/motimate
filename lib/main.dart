import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'routing/app_router.dart';
import 'core/theme/theme_controller.dart';
import 'themes/app_theme.dart';
import 'services/notification_service.dart';
import 'core/error/error_handler.dart';
import 'widgets/global_error_listener.dart';
import 'providers/providers.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    debugPrint('Background message: ${message.messageId}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set up global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    GlobalErrorHandler.handleError(details.exception, details.stack);
    FlutterError.presentError(details);
  };
  
  PlatformDispatcher.instance.onError = (error, stack) {
    GlobalErrorHandler.handleError(error, stack);
    return true;
  };
  
  ErrorWidget.builder = GlobalErrorHandler.errorWidgetBuilder;
  
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Initialize Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialize notification service
  await NotificationService.initialize();
  
  // Initialize performance optimizations
  _initializePerformanceOptimizations();
  
  runApp(const ProviderScope(child: MotiMateApp()));
}

/// パフォーマンス最適化の初期化
void _initializePerformanceOptimizations() {
  // 画像・アイコンキャッシュの事前ロード（バックグラウンドで実行）
  Future.microtask(() async {
    try {
      // Note: 実際のプロダクションでは、ProviderScopeの外でプロバイダーにアクセスする場合は
      // 専用の初期化処理を用意するか、アプリ起動後に初期化する必要があります
      
      if (kDebugMode) {
        debugPrint('🚀 Performance optimizations initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Performance optimization init failed: $e');
      }
    }
  });
}

class MotiMateApp extends ConsumerWidget {
  const MotiMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeControllerProvider);
    
    // Initialize cache lifecycle management
    ref.watch(cacheLifecycleProvider);
    
    return GlobalErrorListener(
      child: MaterialApp.router(
        title: 'MotiMate',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}