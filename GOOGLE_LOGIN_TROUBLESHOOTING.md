# Googleログイン トラブルシューティングガイド

## 🚨 現在の問題

Googleログインが失敗している原因は以下の可能性があります：

### 1. Android開発環境の問題
```
[!] Android toolchain - develop for Android devices (Android SDK version 35.0.1)
    X cmdline-tools component is missing.
    X Android license status unknown.
```

### 2. Firebase設定の問題
- 以前にFirebase設定ファイルがGitから削除された
- SHA-1フィンガープリントが未設定または不正

## 🔧 解決手順

### ステップ1: Android開発環境の修正

1. **Android Command Line Toolsのインストール**
   ```bash
   # Android Studioを開き、SDK Managerから以下をインストール：
   # - Android SDK Command-line Tools (latest)
   ```

2. **Androidライセンスの承認**
   ```bash
   flutter doctor --android-licenses
   # すべてのライセンスに "y" で同意
   ```

3. **環境変数の確認**
   ```
   ANDROID_HOME=C:\Users\yudai\AppData\Local\Android\sdk
   ```

### ステップ2: Firebase Console設定

1. **[Firebase Console](https://console.firebase.google.com/) にアクセス**

2. **プロジェクト選択**: `motimate-eca55`

3. **Google認証の有効化**
   - Authentication → Sign-in method
   - Google プロバイダーを有効にする
   - サポートメールを設定

### ステップ3: SHA-1フィンガープリントの設定

1. **SHA-1の取得**
   ```bash
   cd android
   ./gradlew signingReport
   ```
   
   または
   
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

2. **Firebase Consoleに追加**
   - プロジェクト設定 → 一般
   - アプリ → Android アプリ
   - SHA証明書フィンガープリント → 追加
   - 取得したSHA-1を入力

### ステップ4: 設定ファイルの更新

1. **google-services.jsonの再ダウンロード**
   - Firebase Console → プロジェクト設定 → 一般
   - Android アプリ → google-services.json をダウンロード
   - `android/app/google-services.json` に配置

2. **パッケージ名の確認**
   ```kotlin
   // android/app/build.gradle.kts
   applicationId = "com.example.motimate"
   ```
   Firebase Consoleの設定と一致していることを確認

### ステップ5: アプリのリビルド

```bash
# プロジェクトクリーン
flutter clean
flutter pub get

# 依存関係の修復
flutter pub cache repair

# 開発環境確認
flutter doctor -v

# アプリ実行
flutter run --debug
```

## 🐛 デバッグ方法

### 1. 詳細なエラーログの確認
アプリを実行中に、Android Studioの Logcat または以下のコマンドでログを確認：
```bash
flutter logs
```

### 2. よくあるエラーと対処法

**エラー**: `PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10: , null, null)`
- **原因**: SHA-1フィンガープリントが未設定
- **対処**: SHA-1をFirebase Consoleに追加

**エラー**: `ERROR_INVALID_CUSTOM_TOKEN`
- **原因**: Firebase設定の不整合
- **対処**: google-services.jsonを再ダウンロード

**エラー**: `operation-not-allowed`
- **原因**: Firebase ConsoleでGoogle認証が無効
- **対処**: Authentication設定でGoogleプロバイダーを有効化

### 3. テスト手順

1. **匿名ログインのテスト**
   - まず匿名ログインが動作するか確認
   - Firebase接続の基本動作を確認

2. **メール/パスワードログインのテスト**
   - Googleログイン前に基本認証を確認

3. **Googleログインのテスト**
   - 上記が動作する場合のみGoogleログインをテスト

## 📞 サポート

### 確認事項チェックリスト
- [ ] `flutter doctor` ですべて ✓ が付いている
- [ ] Firebase ConsoleでGoogle認証が有効
- [ ] SHA-1フィンガープリントが設定済み
- [ ] google-services.jsonが最新
- [ ] パッケージ名が一致している
- [ ] アプリをクリーンビルドした

### ログ収集
問題が解決しない場合、以下の情報を収集：
1. `flutter doctor -v` の出力
2. `flutter logs` のエラーメッセージ
3. Android Studioの Logcat出力
4. Firebase Consoleの設定画面のスクリーンショット