# MotiMate マルチサークル機能 - 技術仕様書

## 概要
バスケサークル専用アプリから汎用マルチサークル対応アプリへの完全転換を実現する機能仕様書

## 目次
1. [プロジェクト概要](#プロジェクト概要)
2. [データモデル設計](#データモデル設計)
3. [権限管理システム](#権限管理システム)
4. [API設計](#api設計)
5. [UI/UX設計](#uiux設計)
6. [実装ロードマップ](#実装ロードマップ)
7. [セキュリティ要件](#セキュリティ要件)

---

## プロジェクト概要

### 現在の状況
- 単一バスケサークル専用アプリ
- 固定メンバー構成
- バスケ特有のUI/文言

### 目標
- 複数サークルの作成・参加機能
- サークル種別の汎用化（スポーツ、文化、勉強会等）
- 権限ベースの機能制御
- 独立したサークル間データ管理

### 主要機能
1. **サークル管理**: 作成、参加、設定変更
2. **メンバー管理**: 招待、承認、権限管理
3. **権限制御**: 4段階権限システム
4. **データ分離**: サークル別完全分離

---

## データモデル設計

### Firestoreコレクション構造

#### 1. circles
```json
{
  "id": "circle_uuid",
  "name": "バスケットボール同好会",
  "description": "毎週楽しくバスケをしています",
  "category": "sports",
  "creatorId": "user_uuid",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "settings": {
    "iconType": "basketball",
    "colorTheme": "blue",
    "activityName": "練習"
  },
  "privacy": {
    "isPublic": true,
    "searchable": true,
    "requiresApproval": false,
    "showMemberCount": true,
    "showActivity": true
  },
  "stats": {
    "memberCount": 12,
    "activityCount": 45,
    "lastActivityAt": "timestamp"
  },
  "inviteCode": "ABC123",
  "isActive": true
}
```

#### 2. circle_members
```json
{
  "id": "circle_uuid_user_uuid",
  "circleId": "circle_uuid",
  "userId": "user_uuid",
  "role": "creator", // creator, admin, member, guest
  "status": "active", // pending, active, inactive, banned
  "joinedAt": "timestamp",
  "approvedAt": "timestamp",
  "approvedBy": "user_uuid",
  "joinMessage": "よろしくお願いします",
  "stats": {
    "participationCount": 10,
    "motivationAverage": 4.2,
    "lastActiveAt": "timestamp"
  }
}
```

#### 3. activity_decisions (拡張)
```json
{
  "id": "decision_uuid",
  "circleId": "circle_uuid", // 新規追加
  "decidedBy": "user_uuid",
  "decidedAt": "timestamp",
  "activityDate": "timestamp", // practiceDate から変更
  "dateKey": "2025-01-15",
  "availableMembers": ["user1", "user2"],
  "status": "pending",
  "responses": {"user1": "join", "user2": "skip"},
  "memo": "活動に関するメモ",
  "actualParticipants": ["user1"]
}
```

#### 4. users (拡張)
```json
{
  "uid": "user_uuid",
  "name": "田中太郎",
  "email": "tanaka@example.com",
  "circleIds": ["circle1", "circle2"], // 新規追加
  "currentCircleId": "circle1", // 新規追加
  "lastAccessByCircle": { // 新規追加
    "circle1": "timestamp",
    "circle2": "timestamp"
  },
  // 既存フィールドは維持
  "createdAt": "timestamp",
  "isActive": true
}
```

---

## 権限管理システム

### 権限レベル
```dart
enum MemberRole {
  creator,  // 作成者：全権限
  admin,    // 管理者：メンバー管理、設定変更
  member,   // メンバー：基本機能利用
  guest     // ゲスト：閲覧のみ
}
```

### 権限マトリックス
| 機能 | Creator | Admin | Member | Guest |
|------|---------|--------|--------|-------|
| サークル情報編集 | ✅ | ✅ | ❌ | ❌ |
| サークル削除 | ✅ | ❌ | ❌ | ❌ |
| メンバー招待 | ✅ | ✅ | ✅ | ❌ |
| 参加申請承認 | ✅ | ✅ | ❌ | ❌ |
| メンバー除名 | ✅ | ✅ | ❌ | ❌ |
| 権限変更 | ✅ | 🔶* | ❌ | ❌ |
| 活動日程決定 | ✅ | ✅ | ❌ | ❌ |
| 活動参加回答 | ✅ | ✅ | ✅ | ❌ |
| モチベーション更新 | ✅ | ✅ | ✅ | ❌ |

*Admin は Member/Guest レベルの権限変更のみ可能

---

## API設計

### サークル管理API
```dart
// サークル作成
Future<String> createCircle({
  required String name,
  required String description,
  required String category,
  required CircleSettings settings,
  required PrivacySettings privacy,
});

// サークル参加
Future<void> joinCircle({
  required String circleId,
  String? inviteCode,
  String? joinMessage,
});

// サークル検索
Future<List<CircleModel>> searchCircles({
  String? keyword,
  String? category,
  bool publicOnly = true,
});

// メンバー管理
Future<void> approveMember(String circleId, String userId);
Future<void> updateMemberRole(String circleId, String userId, MemberRole role);
Future<void> removeMember(String circleId, String userId);
```

### 権限チェックAPI
```dart
Future<bool> hasPermission(String circleId, String permission);
Future<MemberRole> getUserRole(String circleId);
Future<bool> canAccessCircle(String circleId);
```

---

## UI/UX設計

### 新規画面
1. **サークル選択画面** (`CircleSelectionScreen`)
2. **サークル作成画面** (`CircleCreationScreen`)
3. **サークル参加画面** (`CircleJoinScreen`)
4. **サークル設定画面** (`CircleSettingsScreen`)
5. **メンバー管理画面** (`MemberManagementScreen`)

### 既存画面の拡張
1. **ホーム画面**: サークル切り替えUI追加
2. **スケジュール画面**: サークル別データ表示
3. **履歴画面**: サークル別履歴
4. **設定画面**: サークル管理メニュー追加

### ナビゲーション構造
```
/circle-selection     # サークル選択画面
/circle/create        # サークル作成
/circle/join          # サークル参加
/circle/settings/{id} # サークル設定
/circle/members/{id}  # メンバー管理
```

---

## 実装ロードマップ

### フェーズ1: 基盤構築（5週間）
1. **Week 1-2**: データモデル実装
   - `CircleModel`, `CircleMemberModel` 作成
   - Freezed, JsonSerializable 対応
   - Firestore変換メソッド実装

2. **Week 3-4**: サービス層実装
   - `CircleService`, `CircleMemberService` 作成
   - 権限チェック機能実装
   - 既存サービスのマルチサークル対応

3. **Week 5**: データ移行準備
   - 既存データの「デフォルトサークル」化
   - 移行スクリプトの作成

### フェーズ2: サークル管理機能（4週間）
1. **Week 6-7**: サークル作成・参加機能
2. **Week 8-9**: サークル管理画面

### フェーズ3: 既存機能統合（3週間）
1. **Week 10-11**: 既存画面のマルチサークル対応
2. **Week 12**: データ移行実行

### フェーズ4: リリース準備（2週間）
1. **Week 13-14**: テスト、最適化、リリース

---

## セキュリティ要件

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // サークル情報
    match /circles/{circleId} {
      allow read: if resource.data.privacy.isPublic == true
        || isCircleMember(circleId);
      allow write: if isCircleAdmin(circleId);
      allow delete: if isCircleCreator(circleId);
    }

    // サークルメンバー
    match /circle_members/{memberId} {
      allow read: if isCircleMember(resource.data.circleId);
      allow create: if request.auth != null;
      allow update: if isCircleAdmin(resource.data.circleId)
        || (request.auth.uid == resource.data.userId && onlyUpdatingOwnData());
      allow delete: if isCircleAdmin(resource.data.circleId)
        || request.auth.uid == resource.data.userId;
    }

    // 活動決定（サークル別）
    match /activity_decisions/{decisionId} {
      allow read, write: if isCircleMember(resource.data.circleId);
    }
  }

  // ヘルパー関数
  function isCircleMember(circleId) {
    return exists(/databases/$(database)/documents/circle_members/$(circleId + '_' + request.auth.uid));
  }

  function isCircleAdmin(circleId) {
    let membership = get(/databases/$(database)/documents/circle_members/$(circleId + '_' + request.auth.uid));
    return membership.data.role in ['creator', 'admin'];
  }

  function isCircleCreator(circleId) {
    let membership = get(/databases/$(database)/documents/circle_members/$(circleId + '_' + request.auth.uid));
    return membership.data.role == 'creator';
  }

  function onlyUpdatingOwnData() {
    return request.resource.data.diff(resource.data).affectedKeys()
      .hasOnly(['stats', 'lastActiveAt']);
  }
}
```

### データ検証
- 入力値の適切な検証
- SQLインジェクション対策
- XSS対策
- 権限チェックの多層化

---

## パフォーマンス考慮事項

### インデックス設計
```json
{
  "indexes": [
    {
      "collectionGroup": "circles",
      "fields": [
        {"fieldPath": "category", "order": "ASCENDING"},
        {"fieldPath": "privacy.isPublic", "order": "ASCENDING"},
        {"fieldPath": "createdAt", "order": "DESCENDING"}
      ]
    },
    {
      "collectionGroup": "circle_members",
      "fields": [
        {"fieldPath": "userId", "order": "ASCENDING"},
        {"fieldPath": "status", "order": "ASCENDING"}
      ]
    },
    {
      "collectionGroup": "activity_decisions",
      "fields": [
        {"fieldPath": "circleId", "order": "ASCENDING"},
        {"fieldPath": "activityDate", "order": "DESCENDING"}
      ]
    }
  ]
}
```

### キャッシュ戦略
- サークル情報のローカルキャッシュ
- メンバー一覧の効率的な取得
- 権限情報のキャッシュ化

---

## エラーハンドリング

### カスタム例外
```dart
class CircleException implements Exception {
  final String message;
  final String code;
  const CircleException(this.message, this.code);
}

// 具体的な例外クラス
class CircleNotFound extends CircleException {
  const CircleNotFound() : super('サークルが見つかりません', 'CIRCLE_NOT_FOUND');
}

class PermissionDenied extends CircleException {
  const PermissionDenied() : super('権限がありません', 'PERMISSION_DENIED');
}

class CircleFull extends CircleException {
  const CircleFull() : super('サークルの定員に達しています', 'CIRCLE_FULL');
}
```

---

## テスト戦略

### ユニットテスト
- データモデルのシリアライゼーション
- サービス層のビジネスロジック
- 権限チェック機能

### インテグレーションテスト
- Firestore操作
- 権限システムの統合動作
- データ移行プロセス

### E2Eテスト
- サークル作成～参加フロー
- 権限による機能制限
- マルチサークル切り替え

---

## 監視・ロギング

### メトリクス
- サークル作成数/日
- 参加申請数/承認率
- アクティブサークル数
- エラー発生率

### ログ設計
- ユーザー操作ログ
- 権限チェック結果
- データアクセスログ
- エラー詳細ログ

---

このドキュメントは実装進行と共に更新されます。
最終更新: 2025-01-22