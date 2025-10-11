import 'dart:io';

/// リリースビルド自動化スクリプト
class ReleaseBuildScript {
  static const String version = '1.0.0';
  static const String buildNumber = '1';

  static Future<void> main() async {
    print('🚀 MotiMate リリースビルド開始...');
    print('バージョン: $version');
    print('ビルド番号: $buildNumber');
    print('');

    try {
      // 1. 事前チェック
      await _preflightChecks();

      // 2. 依存関係更新
      await _updateDependencies();

      // 3. コード生成
      await _generateCode();

      // 4. テスト実行
      await _runTests();

      // 5. 静的解析
      await _runAnalysis();

      // 6. Android APK ビルド
      await _buildAndroidApk();

      // 7. Android App Bundle ビルド
      await _buildAndroidAppBundle();

      // 8. iOS ビルド (Macでのみ)
      if (Platform.isMacOS) {
        await _buildIos();
      }

      // 9. Web ビルド
      await _buildWeb();

      // 10. ビルド成果物の確認
      await _verifyBuildArtifacts();

      print('');
      print('🎉 リリースビルドが正常に完了しました！');
      print('');
      print('📱 ビルド成果物:');
      print('  Android APK: build/app/outputs/flutter-apk/app-release.apk');
      print('  Android AAB: build/app/outputs/bundle/release/app-release.aab');
      if (Platform.isMacOS) {
        print('  iOS: build/ios/ipa/motimate.ipa');
      }
      print('  Web: build/web/');

    } catch (e, stackTrace) {
      print('❌ ビルドエラー: $e');
      print('スタックトレース: $stackTrace');
      exit(1);
    }
  }

  /// 事前チェック
  static Future<void> _preflightChecks() async {
    print('📋 事前チェック実行中...');

    // Flutter SDKの確認
    final flutterResult = await Process.run('flutter', ['--version']);
    if (flutterResult.exitCode != 0) {
      throw Exception('Flutter SDKが見つかりません');
    }

    // Git の状態確認
    final gitResult = await Process.run('git', ['status', '--porcelain']);
    if (gitResult.stdout.toString().trim().isNotEmpty) {
      print('⚠️  未コミットの変更があります。継続しますか? (y/N)');
      final input = stdin.readLineSync();
      if (input?.toLowerCase() != 'y') {
        throw Exception('ビルドがキャンセルされました');
      }
    }

    print('✅ 事前チェック完了');
  }

  /// 依存関係更新
  static Future<void> _updateDependencies() async {
    print('📦 依存関係更新中...');

    final result = await Process.run('flutter', ['pub', 'get']);
    if (result.exitCode != 0) {
      throw Exception('依存関係の更新に失敗: ${result.stderr}');
    }

    print('✅ 依存関係更新完了');
  }

  /// コード生成
  static Future<void> _generateCode() async {
    print('🔧 コード生成中...');

    final result = await Process.run(
      'flutter',
      ['packages', 'pub', 'run', 'build_runner', 'build', '--delete-conflicting-outputs'],
    );

    if (result.exitCode != 0) {
      print('⚠️  コード生成でエラーが発生しましたが、ビルドを続行します');
      print(result.stderr);
    } else {
      print('✅ コード生成完了');
    }
  }

  /// テスト実行
  static Future<void> _runTests() async {
    print('🧪 テスト実行中...');

    final result = await Process.run('flutter', ['test']);
    if (result.exitCode != 0) {
      throw Exception('テストが失敗しました: ${result.stderr}');
    }

    print('✅ テスト実行完了');
  }

  /// 静的解析
  static Future<void> _runAnalysis() async {
    print('🔍 静的解析実行中...');

    final result = await Process.run('flutter', ['analyze']);
    if (result.exitCode != 0) {
      print('⚠️  静的解析で警告がありますが、ビルドを続行します');
      print(result.stdout);
    } else {
      print('✅ 静的解析完了');
    }
  }

  /// Android APK ビルド
  static Future<void> _buildAndroidApk() async {
    print('📱 Android APK ビルド中...');

    final result = await Process.run(
      'flutter',
      [
        'build',
        'apk',
        '--release',
        '--build-name=$version',
        '--build-number=$buildNumber',
        '--dart-define=ENVIRONMENT=production',
      ],
    );

    if (result.exitCode != 0) {
      throw Exception('Android APK ビルドに失敗: ${result.stderr}');
    }

    print('✅ Android APK ビルド完了');
  }

  /// Android App Bundle ビルド
  static Future<void> _buildAndroidAppBundle() async {
    print('📦 Android App Bundle ビルド中...');

    final result = await Process.run(
      'flutter',
      [
        'build',
        'appbundle',
        '--release',
        '--build-name=$version',
        '--build-number=$buildNumber',
        '--dart-define=ENVIRONMENT=production',
      ],
    );

    if (result.exitCode != 0) {
      throw Exception('Android App Bundle ビルドに失敗: ${result.stderr}');
    }

    print('✅ Android App Bundle ビルド完了');
  }

  /// iOS ビルド
  static Future<void> _buildIos() async {
    print('🍎 iOS ビルド中...');

    final result = await Process.run(
      'flutter',
      [
        'build',
        'ipa',
        '--release',
        '--build-name=$version',
        '--build-number=$buildNumber',
        '--dart-define=ENVIRONMENT=production',
      ],
    );

    if (result.exitCode != 0) {
      throw Exception('iOS ビルドに失敗: ${result.stderr}');
    }

    print('✅ iOS ビルド完了');
  }

  /// Web ビルド
  static Future<void> _buildWeb() async {
    print('🌐 Web ビルド中...');

    final result = await Process.run(
      'flutter',
      [
        'build',
        'web',
        '--release',
        '--dart-define=ENVIRONMENT=production',
        '--web-renderer=canvaskit',
      ],
    );

    if (result.exitCode != 0) {
      throw Exception('Web ビルドに失敗: ${result.stderr}');
    }

    print('✅ Web ビルド完了');
  }

  /// ビルド成果物の確認
  static Future<void> _verifyBuildArtifacts() async {
    print('📋 ビルド成果物確認中...');

    final artifacts = [
      'build/app/outputs/flutter-apk/app-release.apk',
      'build/app/outputs/bundle/release/app-release.aab',
      'build/web/index.html',
    ];

    if (Platform.isMacOS) {
      artifacts.add('build/ios/ipa/motimate.ipa');
    }

    for (final artifact in artifacts) {
      final file = File(artifact);
      if (!file.existsSync()) {
        print('⚠️  $artifact が見つかりません');
      } else {
        final size = file.lengthSync();
        final sizeInMB = (size / (1024 * 1024)).toStringAsFixed(2);
        print('✅ $artifact (${sizeInMB}MB)');
      }
    }

    print('✅ ビルド成果物確認完了');
  }

  /// APKサイズ分析
  static Future<void> analyzeApkSize() async {
    print('📊 APK サイズ分析中...');

    final result = await Process.run(
      'flutter',
      ['build', 'apk', '--analyze-size'],
    );

    if (result.exitCode == 0) {
      print(result.stdout);
    } else {
      print('APK サイズ分析に失敗: ${result.stderr}');
    }
  }
}

void main() async {
  await ReleaseBuildScript.main();
}