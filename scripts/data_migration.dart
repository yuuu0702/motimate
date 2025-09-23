import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// データ移行スクリプト
/// 既存のデータにcircleIdフィールドを追加してマルチサークル対応を完了します
///
/// 使用方法:
/// dart run scripts/data_migration.dart
///
/// 注意: バックアップを取ってから実行してください

class DataMigrationScript {
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  /// デフォルトサークルのID（既存ユーザーが所属するサークル）
  static const String defaultCircleId = 'default_basketball_circle';
  static const String defaultCircleName = 'バスケットボールサークル';

  static Future<void> main() async {
    print('🚀 データ移行スクリプトを開始します...');

    try {
      // Firebase初期化
      await Firebase.initializeApp();
      print('✅ Firebase接続完了');

      // 移行前の確認
      await _confirmMigration();

      // 1. デフォルトサークルの作成
      await _createDefaultCircle();

      // 2. ユーザーデータの移行
      await _migrateUsers();

      // 3. スケジュールデータの移行
      await _migrateSchedules();

      // 4. 練習決定データの移行
      await _migratePracticeDecisions();

      // 5. 通知データの移行
      await _migrateNotifications();

      // 6. サークルメンバーの作成
      await _createCircleMembers();

      print('🎉 データ移行が完了しました！');
      print('📊 移行結果の確認を行ってください');

    } catch (e, stackTrace) {
      print('❌ エラーが発生しました: $e');
      print('スタックトレース: $stackTrace');
      exit(1);
    }
  }

  /// 移行前の確認
  static Future<void> _confirmMigration() async {
    print('\n📋 移行前の確認を行います...');

    // 既存データの件数確認
    final usersCount = await _getCollectionCount('users');
    final schedulesCount = await _getCollectionCount('schedules');
    final practiceDecisionsCount = await _getCollectionCount('practice_decisions');
    final notificationsCount = await _getCollectionCount('notifications');

    print('👥 ユーザー: $usersCount件');
    print('📅 スケジュール: $schedulesCount件');
    print('🏃 練習決定: $practiceDecisionsCount件');
    print('🔔 通知: $notificationsCount件');

    // デフォルトサークルが既に存在するかチェック
    final circleDoc = await firestore.collection('circles').doc(defaultCircleId).get();
    if (circleDoc.exists) {
      print('⚠️  デフォルトサークルが既に存在します。既存のサークルを使用します。');
    }

    print('\n⚠️  この操作は元に戻せません。バックアップを取ってから実行してください。');
    print('続行しますか? (y/N): ');

    final input = stdin.readLineSync();
    if (input?.toLowerCase() != 'y') {
      print('移行をキャンセルしました。');
      exit(0);
    }
  }

  /// コレクションの件数を取得
  static Future<int> _getCollectionCount(String collectionName) async {
    final snapshot = await firestore.collection(collectionName).get();
    return snapshot.docs.length;
  }

  /// デフォルトサークルの作成
  static Future<void> _createDefaultCircle() async {
    print('\n🎯 デフォルトサークルを作成中...');

    final circleDoc = await firestore.collection('circles').doc(defaultCircleId).get();

    if (!circleDoc.exists) {
      await firestore.collection('circles').doc(defaultCircleId).set({
        'name': defaultCircleName,
        'description': '既存メンバーのためのデフォルトサークルです',
        'type': 'basketball',
        'isPublic': false,
        'createdBy': 'system_migration',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'memberCount': 0,
        'maxMembers': 100,
        'inviteCode': 'BASKETBALL2024',
        'settings': {
          'allowPublicJoin': false,
          'requireApproval': false,
          'allowMemberInvite': true,
        },
      });
      print('✅ デフォルトサークルを作成しました');
    } else {
      print('✅ デフォルトサークルは既に存在します');
    }
  }

  /// ユーザーデータの移行
  static Future<void> _migrateUsers() async {
    print('\n👥 ユーザーデータを移行中...');

    final usersSnapshot = await firestore.collection('users').get();
    final batch = firestore.batch();
    int processedCount = 0;

    for (final doc in usersSnapshot.docs) {
      final data = doc.data();

      // 既にcurrentCircleIdが設定されている場合はスキップ
      if (data.containsKey('currentCircleId')) {
        continue;
      }

      // currentCircleIdを追加
      batch.update(doc.reference, {
        'currentCircleId': defaultCircleId,
        'lastAccessByCircle': {
          defaultCircleId: FieldValue.serverTimestamp(),
        },
      });

      processedCount++;

      // バッチサイズ制限対応
      if (processedCount % 500 == 0) {
        await batch.commit();
        print('  処理済み: $processedCount件');
      }
    }

    if (processedCount % 500 != 0) {
      await batch.commit();
    }

    print('✅ ユーザーデータ移行完了: $processedCount件');
  }

  /// スケジュールデータの移行
  static Future<void> _migrateSchedules() async {
    print('\n📅 スケジュールデータを移行中...');

    final schedulesSnapshot = await firestore.collection('schedules').get();
    final batch = firestore.batch();
    int processedCount = 0;

    for (final doc in schedulesSnapshot.docs) {
      final data = doc.data();

      // 既にcircleIdが設定されている場合はスキップ
      if (data.containsKey('circleId')) {
        continue;
      }

      // circleIdを追加
      batch.update(doc.reference, {
        'circleId': defaultCircleId,
      });

      processedCount++;

      if (processedCount % 500 == 0) {
        await batch.commit();
        print('  処理済み: $processedCount件');
      }
    }

    if (processedCount % 500 != 0) {
      await batch.commit();
    }

    print('✅ スケジュールデータ移行完了: $processedCount件');
  }

  /// 練習決定データの移行
  static Future<void> _migratePracticeDecisions() async {
    print('\n🏃 練習決定データを移行中...');

    final practiceSnapshot = await firestore.collection('practice_decisions').get();
    final batch = firestore.batch();
    int processedCount = 0;

    for (final doc in practiceSnapshot.docs) {
      final data = doc.data();

      // 既にcircleIdが設定されている場合はスキップ
      if (data.containsKey('circleId')) {
        continue;
      }

      // circleIdを追加
      batch.update(doc.reference, {
        'circleId': defaultCircleId,
      });

      processedCount++;

      if (processedCount % 500 == 0) {
        await batch.commit();
        print('  処理済み: $processedCount件');
      }
    }

    if (processedCount % 500 != 0) {
      await batch.commit();
    }

    print('✅ 練習決定データ移行完了: $processedCount件');
  }

  /// 通知データの移行
  static Future<void> _migrateNotifications() async {
    print('\n🔔 通知データを移行中...');

    final notificationsSnapshot = await firestore.collection('notifications').get();
    final batch = firestore.batch();
    int processedCount = 0;

    for (final doc in notificationsSnapshot.docs) {
      final data = doc.data();

      // 既にcircleIdが設定されている場合はスキップ
      if (data.containsKey('circleId')) {
        continue;
      }

      // circleIdを追加
      batch.update(doc.reference, {
        'circleId': defaultCircleId,
      });

      processedCount++;

      if (processedCount % 500 == 0) {
        await batch.commit();
        print('  処理済み: $processedCount件');
      }
    }

    if (processedCount % 500 != 0) {
      await batch.commit();
    }

    print('✅ 通知データ移行完了: $processedCount件');
  }

  /// サークルメンバーの作成
  static Future<void> _createCircleMembers() async {
    print('\n👫 サークルメンバーを作成中...');

    // currentCircleIdがdefaultCircleIdのユーザーを取得
    final usersSnapshot = await firestore
        .collection('users')
        .where('currentCircleId', isEqualTo: defaultCircleId)
        .get();

    final batch = firestore.batch();
    int processedCount = 0;

    for (final userDoc in usersSnapshot.docs) {
      final userId = userDoc.id;
      final userData = userDoc.data();

      // サークルメンバーのドキュメントID生成
      final memberDocRef = firestore.collection('circle_members').doc();

      // サークルメンバーを作成
      batch.set(memberDocRef, {
        'id': memberDocRef.id,
        'circleId': defaultCircleId,
        'userId': userId,
        'role': 'member', // 既存ユーザーは全員メンバーとして設定
        'status': 'active',
        'joinedAt': FieldValue.serverTimestamp(),
        'invitedBy': 'system_migration',
        'permissions': {
          'canInviteMembers': true,
          'canManageSchedule': true,
          'canManagePractice': true,
          'canViewMembers': true,
        },
      });

      processedCount++;

      if (processedCount % 500 == 0) {
        await batch.commit();
        print('  処理済み: $processedCount件');
      }
    }

    if (processedCount % 500 != 0) {
      await batch.commit();
    }

    // サークルのメンバー数を更新
    await firestore.collection('circles').doc(defaultCircleId).update({
      'memberCount': processedCount,
    });

    print('✅ サークルメンバー作成完了: $processedCount件');
  }

  /// 移行結果の確認
  static Future<void> verifyMigration() async {
    print('\n📊 移行結果を確認中...');

    // circleIdを持つドキュメントの数を確認
    final schedulesWithCircle = await firestore
        .collection('schedules')
        .where('circleId', isEqualTo: defaultCircleId)
        .get();

    final practiceWithCircle = await firestore
        .collection('practice_decisions')
        .where('circleId', isEqualTo: defaultCircleId)
        .get();

    final notificationsWithCircle = await firestore
        .collection('notifications')
        .where('circleId', isEqualTo: defaultCircleId)
        .get();

    final membersCount = await firestore
        .collection('circle_members')
        .where('circleId', isEqualTo: defaultCircleId)
        .get();

    print('📅 移行済みスケジュール: ${schedulesWithCircle.docs.length}件');
    print('🏃 移行済み練習決定: ${practiceWithCircle.docs.length}件');
    print('🔔 移行済み通知: ${notificationsWithCircle.docs.length}件');
    print('👫 作成されたメンバー: ${membersCount.docs.length}件');
  }
}

void main() async {
  await DataMigrationScript.main();
}