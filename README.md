# MotiMate

**あらゆる活動サークルのモチベーション管理アプリ**

MotiMateは、スポーツ、文化活動、勉強会など、あらゆる種類のサークル活動をサポートする多機能アプリです。メンバーのモチベーション管理から実用的な機能まで、サークル運営に必要な全てを一つのアプリで提供します。

## 🚀 主な機能

### 📊 モチベーション管理
- **気分追跡**: 活動前後の気分をエモーション選択で記録
- **参加状況の可視化**: 個人とチーム全体の参加パターンを分析
- **モチベーショングラフ**: 時系列でのモチベーション変化を確認

### 🏀 活動管理
- **スケジュール管理**: 練習や活動の予定を一元管理
- **参加可否の確認**: メンバーの参加可能状況をリアルタイムで把握
- **活動履歴**: 過去の活動データを蓄積・分析

### 👥 メンバー管理
- **マルチサークル対応**: 複数のサークルに参加可能
- **権限管理**: 作成者、管理者、メンバー、ゲストの4段階権限
- **サークル切り替え**: 簡単なタップで所属サークルを切り替え

### 🔔 通知機能
- **プッシュ通知**: 重要な情報をリアルタイムで配信
- **サークル限定通知**: 各サークル専用の通知システム
- **カスタマイズ可能**: 通知設定を個人の好みに調整

### 🎨 カスタマイズ
- **テーマ設定**: ダークモード・ライトモード対応
- **サークルカスタマイズ**: アイコン、カラーテーマの選択
- **アクセシビリティ**: スクリーンリーダー対応、高コントラストモード

## 📱 対応プラットフォーム

- **Android**: Android 5.0 (API レベル 21) 以上
- **iOS**: iOS 12.0 以上
- **Web**: モダンブラウザ対応

## 🛠️ 技術スタック

### フロントエンド
- **Flutter**: 3.24.0+
- **Dart**: 3.5.0+
- **Riverpod**: 状態管理
- **Freezed**: イミュータブルデータクラス
- **Go Router**: ナビゲーション

### バックエンド
- **Firebase**:
  - Authentication (認証)
  - Firestore (データベース)
  - Cloud Functions (サーバーレス)
  - Cloud Messaging (プッシュ通知)
  - Analytics (分析)

### 開発ツール
- **VSCode**: 推奨エディタ
- **GitHub Actions**: CI/CD
- **Flutter DevTools**: デバッグ・プロファイリング

## 📋 セットアップ手順

### 前提条件
- Flutter SDK 3.24.0+
- Dart SDK 3.5.0+
- Android Studio / Xcode (プラットフォーム開発用)
- Firebase プロジェクト

### 1. リポジトリクローン
```bash
git clone https://github.com/your-username/motimate.git
cd motimate
```

### 2. 依存関係インストール
```bash
flutter pub get
```

### 3. Firebase設定
1. Firebase Console でプロジェクトを作成
2. `google-services.json` (Android) と `GoogleService-Info.plist` (iOS) をダウンロード
3. 所定の場所に配置

### 4. 環境変数設定
```bash
cp .env.example .env
# .env ファイルを編集して必要な値を設定
```

### 5. コード生成実行
```bash
flutter packages pub run build_runner build
```

### 6. アプリ起動
```bash
flutter run
```

## 🏗️ プロジェクト構成

```
lib/
├── main.dart                 # エントリーポイント
├── app.dart                  # アプリケーション設定
├── core/                     # コア機能
│   ├── constants/           # 定数
│   ├── theme/              # テーマ設定
│   └── auth/               # 認証関連
├── models/                  # データモデル
├── viewmodels/             # 状態管理・ビジネスロジック
├── screens/                # 画面
├── widgets/                # 再利用可能ウィジェット
├── services/               # 外部サービス連携
├── providers/              # Riverpod プロバイダー
├── routing/                # ナビゲーション
└── config/                 # 設定ファイル
```

## 🧪 テスト

### 単体テスト実行
```bash
flutter test
```

### ウィジェットテスト実行
```bash
flutter test test/widget_test/
```

### 統合テスト実行
```bash
flutter drive --target=test_driver/app.dart
```

## 📈 ビルド・デプロイ

### 開発ビルド
```bash
flutter build apk --debug
```

### リリースビルド
```bash
# 自動化スクリプト使用
dart run scripts/build_release.dart

# 手動ビルド
flutter build apk --release
flutter build appbundle --release
flutter build ipa --release
flutter build web --release
```

### Firebase デプロイ
```bash
firebase deploy
```

## 🔧 開発ガイドライン

### コーディング規約
- [Effective Dart](https://dart.dev/effective-dart) に準拠
- [Flutter公式ガイド](https://docs.flutter.dev/app-architecture/guide) に従ったアーキテクチャ
- 詳細は `CLAUDE.md` を参照

### Git ワークフロー
- `master`: 本番環境
- `develop`: 開発環境
- `feature/*`: 機能開発ブランチ

### コミットメッセージ
```
type(scope): subject

feat(auth): add Google sign-in functionality
fix(home): resolve notification badge issue
docs(readme): update setup instructions
```

## 🌟 主要機能詳細

### マルチサークル機能
複数のサークルへの同時参加が可能です：
- サークル作成・参加
- サークル間の簡単切り替え
- サークル別のデータ管理
- 権限ベースのアクセス制御

### パフォーマンス最適化
- 画像キャッシュシステム
- レイジーローディング
- メモリ効率的なアニメーション
- オフライン対応

### アクセシビリティ
- VoiceOver / TalkBack 対応
- 高コントラストモード
- 大きな文字サイズ対応
- キーボードナビゲーション

## 🛡️ セキュリティ

- Firebase Authentication による安全な認証
- Firestore Security Rules によるデータ保護
- SSL/TLS による通信暗号化
- 機密情報の環境変数管理

## 📊 分析・監視

- Firebase Analytics による使用状況分析
- Crashlytics によるクラッシュ監視
- Performance Monitoring によるパフォーマンス測定
- カスタムイベント追跡

## 🤝 コントリビューション

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 ライセンス

このプロジェクトは MIT License の下で公開されています。詳細は [LICENSE](LICENSE) ファイルを参照してください。

## 📞 サポート

- **バグ報告**: [GitHub Issues](https://github.com/your-username/motimate/issues)
- **機能要求**: [GitHub Discussions](https://github.com/your-username/motimate/discussions)
- **メール**: support@motimate.com

## 🎯 ロードマップ

### v1.1.0 (予定)
- [ ] ビデオ会議統合
- [ ] チャット機能
- [ ] カレンダー同期

### v1.2.0 (予定)
- [ ] AI駆動の分析機能
- [ ] 多言語対応
- [ ] Apple Watch / Wear OS 対応

### v2.0.0 (予定)
- [ ] 大規模組織対応
- [ ] 高度な分析ダッシュボード
- [ ] サードパーティ統合

## 🏆 使用例

### スポーツサークル
- 練習参加率の向上
- 試合前のモチベーション管理
- チーム一体感の醸成

### 勉強会・読書会
- 継続的な学習習慣の形成
- 知識共有の促進
- 学習進捗の可視化

### 文化サークル
- 活動への積極的参加
- 創作活動のモチベーション維持
- メンバー間のコミュニケーション向上

---

**Made with ❤️ by the MotiMate Team**