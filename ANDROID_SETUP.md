# Android開発環境のセットアップガイド

## 問題の状況
flutter doctorの出力により、以下の問題が確認されました：

```
[!] Android toolchain - develop for Android devices (Android SDK version 35.0.1)
    X cmdline-tools component is missing.
    X Android license status unknown.
```

## 解決方法

### 1. Android Command Line Toolsのインストール

#### 方法A: Android Studioから設定
1. Android Studioを開く
2. File → Settings (またはAndroid Studio → Preferences on Mac)
3. Appearance & Behavior → System Settings → Android SDK
4. SDK Tools タブを選択
5. "Android SDK Command-line Tools (latest)" にチェックを入れる
6. "Apply" をクリック

#### 方法B: 手動でダウンロード
1. [Android Command Line Tools](https://developer.android.com/studio#command-line-tools-only)からダウンロード
2. `C:\Users\yudai\AppData\Local\Android\sdk\cmdline-tools\` フォルダに展開
3. 環境変数 `ANDROID_HOME` を設定（既に設定済みの可能性があります）

### 2. Android ライセンスの承認

```bash
flutter doctor --android-licenses
```

このコマンドを実行し、すべてのライセンスに "y" で同意してください。

### 3. 環境変数の確認

以下の環境変数が正しく設定されていることを確認：

```
ANDROID_HOME=C:\Users\yudai\AppData\Local\Android\sdk
PATH=%PATH%;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\cmdline-tools\latest\bin
```

### 4. 設定確認

```bash
flutter doctor -v
```

## Firebase / Googleログイン関連の確認事項

### 1. SHA-1フィンガープリントの設定

```bash
cd android
./gradlew signingReport
```

出力されたSHA-1を[Firebase Console](https://console.firebase.google.com/)の以下の場所に追加：
- プロジェクト設定 → 一般 → アプリ → Android → SHA証明書フィンガープリント

### 2. パッケージ名の確認

`android/app/build.gradle.kts`のapplicationIdと、Firebase Consoleで設定したパッケージ名が一致していることを確認。

### 3. google-services.jsonの配置

`android/app/google-services.json`が正しく配置されていることを確認。

## トラブルシューティング

### Googleログインエラーの場合
1. Firebase ConsoleでGoogle認証が有効になっていることを確認
2. SHA-1フィンガープリントが正しく設定されていることを確認
3. google-services.jsonが最新版であることを確認
4. アプリのクリーンビルドを実行：
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### デバッグ用コマンド
```bash
# プロジェクトのクリーン
flutter clean
flutter pub get

# キャッシュクリア
flutter pub cache repair

# 詳細な医師確認
flutter doctor -v
```