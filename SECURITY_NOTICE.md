# Firebase セキュリティ通知

## ⚠️ 重要なセキュリティ対策実施済み

このリポジトリでは、Firebase設定ファイルがGitから除外されるようセキュリティ対策を実施しました。

## 除外された機密ファイル

以下のFirebase設定ファイルは`.gitignore`に追加され、今後Gitで管理されません：

- `android/google-services.json`
- `android/app/google-services.json`
- `ios/GoogleService-Info.plist`
- `lib/firebase_options.dart`

## 開発者向け設定手順

### 1. Firebase設定ファイルの取得

プロジェクトを初回セットアップする際は、以下の手順でFirebase設定ファイルを取得してください：

1. [Firebase Console](https://console.firebase.google.com/) にアクセス
2. `motimate-eca55` プロジェクトを選択
3. 各プラットフォーム用の設定ファイルをダウンロード：
   - **Android**: `google-services.json` を `android/app/` に配置
   - **iOS**: `GoogleService-Info.plist` を `ios/` に配置
   - **Flutter**: Firebase CLI で `firebase_options.dart` を生成

### 2. Firebase CLI での設定ファイル生成

```bash
# Firebase CLI をインストール
npm install -g firebase-tools

# ログイン
firebase login

# プロジェクトを選択
firebase use motimate-eca55

# Flutter用設定ファイルを生成
flutterfire configure
```

## セキュリティ上の注意事項

- 設定ファイルは絶対にGitにコミットしない
- チーム内でファイル共有する際は、安全な方法（暗号化、秘密管理サービス等）を使用
- APIキーが漏洩した場合は即座にFirebase Consoleで無効化

## 追加のセキュリティ対策

1. **Firebase Security Rules** の確認・強化
2. **App Check** の実装検討
3. **API制限** の設定（HTTPリファラー、IPアドレス制限等）

## 緊急時の対応

APIキーが漏洩した場合：
1. Firebase ConsoleでAPIキーを即座に無効化
2. 新しいキーを生成
3. 影響範囲の調査・対応

---

このセキュリティ対策により、機密情報の漏洩リスクが大幅に軽減されます。