import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppError {
  final String message;
  final String code;
  final ErrorType type;
  final dynamic originalError;

  const AppError({
    required this.message,
    required this.code,
    required this.type,
    this.originalError,
  });

  factory AppError.fromException(dynamic error) {
    if (error is FirebaseAuthException) {
      return AppError._fromFirebaseAuthException(error);
    } else if (error is FirebaseException) {
      return AppError._fromFirebaseException(error);
    } else {
      return AppError(
        message: error.toString(),
        code: 'unknown_error',
        type: ErrorType.unknown,
        originalError: error,
      );
    }
  }

  factory AppError._fromFirebaseAuthException(FirebaseAuthException error) {
    String message;
    switch (error.code) {
      case 'user-not-found':
        message = 'ユーザーが見つかりません';
        break;
      case 'wrong-password':
        message = 'パスワードが間違っています';
        break;
      case 'invalid-email':
        message = 'メールアドレスの形式が正しくありません';
        break;
      case 'user-disabled':
        message = 'このアカウントは無効化されています';
        break;
      case 'too-many-requests':
        message = 'リクエストが多すぎます。しばらく時間をおいてから再試行してください';
        break;
      case 'operation-not-allowed':
        message = 'この操作は許可されていません';
        break;
      case 'network-request-failed':
        message = 'ネットワーク接続を確認してください';
        break;
      default:
        message = '認証エラーが発生しました';
    }

    return AppError(
      message: message,
      code: error.code,
      type: ErrorType.auth,
      originalError: error,
    );
  }

  factory AppError._fromFirebaseException(FirebaseException error) {
    String message;
    switch (error.code) {
      case 'permission-denied':
        message = 'アクセス権限がありません';
        break;
      case 'not-found':
        message = 'データが見つかりません';
        break;
      case 'already-exists':
        message = 'データがすでに存在します';
        break;
      case 'resource-exhausted':
        message = 'リソースの上限に達しました';
        break;
      case 'failed-precondition':
        message = '操作の前提条件が満たされていません';
        break;
      case 'aborted':
        message = '操作が中断されました';
        break;
      case 'out-of-range':
        message = '範囲外の値です';
        break;
      case 'unimplemented':
        message = 'この機能はまだ実装されていません';
        break;
      case 'internal':
        message = 'サーバー内部エラーが発生しました';
        break;
      case 'unavailable':
        message = 'サービスが利用できません';
        break;
      case 'data-loss':
        message = 'データの損失が発生しました';
        break;
      case 'unauthenticated':
        message = '認証が必要です';
        break;
      default:
        message = 'エラーが発生しました';
    }

    return AppError(
      message: message,
      code: error.code,
      type: ErrorType.network,
      originalError: error,
    );
  }
}

enum ErrorType {
  auth,
  network,
  validation,
  unknown,
}

class ErrorNotifier extends StateNotifier<AppError?> {
  ErrorNotifier() : super(null);

  void showError(AppError error) {
    state = error;
    if (kDebugMode) {
      debugPrint('Error: ${error.message} (${error.code})');
      if (error.originalError != null) {
        debugPrint('Original error: ${error.originalError}');
      }
    }
  }

  void showErrorFromException(dynamic error) {
    showError(AppError.fromException(error));
  }

  void clearError() {
    state = null;
  }
}

final errorProvider = StateNotifierProvider<ErrorNotifier, AppError?>((ref) {
  return ErrorNotifier();
});

class GlobalErrorHandler {
  static void handleError(dynamic error, StackTrace? stackTrace) {
    if (kDebugMode) {
      debugPrint('Global Error: $error');
      debugPrint('Stack Trace: $stackTrace');
    }
  }

  static Widget errorWidgetBuilder(FlutterErrorDetails details) {
    if (kDebugMode) {
      return ErrorWidget(details.exception);
    }
    
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'アプリケーションエラーが発生しました',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('アプリを再起動してください'),
              const SizedBox(height: 16),
              if (kDebugMode)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    details.exception.toString(),
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}