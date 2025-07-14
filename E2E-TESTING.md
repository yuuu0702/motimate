# MotiMate E2E Testing with Playwright

このドキュメントは、MotiMate Flutter WebアプリケーションのEnd-to-End（E2E）テストのセットアップと実行方法について説明します。

## 📋 目次

- [前提条件](#前提条件)
- [セットアップ](#セットアップ)
- [テストの実行](#テストの実行)
- [テストケース](#テストケース)
- [CI/CD](#cicd)
- [トラブルシューティング](#トラブルシューティング)

## 🔧 前提条件

以下のツールがインストールされている必要があります：

- **Flutter SDK** (3.24.x以上)
- **Node.js** (18.x以上)
- **Python** (3.8以上) - HTTPサーバー用
- **Git**

### OS別の追加要件

#### Windows
- PowerShell 5.1以上またはPowerShell Core
- Visual Studio Build Tools (オプション)

#### macOS
- Xcode Command Line Tools
- Homebrew (推奨)

#### Linux
- 必要なシステム依存関係は自動でインストールされます

## 🚀 セットアップ

### 1. リポジトリのクローン

```bash
git clone https://github.com/your-username/motimate.git
cd motimate
```

### 2. Flutter依存関係のインストール

```bash
flutter pub get
```

### 3. Node.js依存関係のインストール

```bash
npm install
```

### 4. Playwrightブラウザのインストール

```bash
npx playwright install
```

## 🧪 テストの実行

### 自動ビルド&テスト実行

#### Linux/macOS
```bash
chmod +x scripts/build-and-test.sh
./scripts/build-and-test.sh
```

#### Windows
```cmd
scripts\build-and-test.bat
```

### 手動実行

#### 1. Flutter Webアプリのビルド
```bash
flutter build web --web-renderer html --release
```

#### 2. テストサーバーの起動
```bash
cd build/web
python -m http.server 8080
```

#### 3. 別ターミナルでテスト実行
```bash
# すべてのテストを実行
npx playwright test

# 特定のブラウザのみ
npx playwright test --project=chromium

# UIモードで実行
npx playwright test --ui

# デバッグモード
npx playwright test --debug
```

### コマンドラインオプション

```bash
# ヘッドフルモード（ブラウザ表示）
npx playwright test --headed

# 特定のテストファイル
npx playwright test tests/gymnasium.spec.js

# 並列実行数の指定
npx playwright test --workers=2

# リポーター指定
npx playwright test --reporter=html,line
```

## 📝 テストケース

### 基本テスト (`tests/basic.spec.js`)
- ✅ アプリケーションの基本読み込み
- ✅ 認証画面の表示確認
- ✅ レスポンシブデザイン
- ✅ JavaScript エラーチェック
- ✅ 読み込み時間測定

### ナビゲーションテスト (`tests/navigation.spec.js`)
- ✅ ボトムナビゲーションの表示
- ✅ 画面遷移のシミュレーション
- ✅ アプリバーの確認
- ✅ キーボードナビゲーション
- ✅ 画面回転対応

### 体育館機能テスト (`tests/gymnasium.spec.js`)
- ✅ 体育館画面への遷移
- ✅ 検索機能
- ✅ 距離順ソート
- ✅ 体育館リスト表示
- ✅ 詳細表示
- ✅ フィルター機能
- ✅ 位置情報権限
- ✅ モバイル表示

### パフォーマンステスト (`tests/performance.spec.js`)
- ✅ ページ読み込み時間
- ✅ メモリ使用量監視
- ✅ 大量データ処理
- ✅ ネットワーク効率性
- ✅ レスポンス時間測定
- ✅ バッテリー効率性

## 🔄 CI/CD

### GitHub Actions

プルリクエストやプッシュ時に自動でE2Eテストが実行されます。

```yaml
# .github/workflows/e2e-tests.yml
- デスクトップブラウザテスト (Chrome, Firefox, Safari)
- モバイルブラウザテスト
- パフォーマンステスト
- アクセシビリティテスト
```

### 手動実行

GitHub Actionsの「Actions」タブから手動でワークフローを実行できます。

## 📊 テストレポート

テスト実行後、以下のレポートが生成されます：

### HTMLレポート
```bash
npx playwright show-report
```

### ファイル構成
```
playwright-report/
├── index.html          # メインレポート
├── data/               # テストデータ
└── assets/             # スタイルシート等

test-results/
├── [test-name]/
│   ├── test-failed-1.png    # 失敗時のスクリーンショット
│   ├── test-failed-1.webm   # 失敗時のビデオ
│   └── trace.zip            # トレースファイル
```

## 🐛 トラブルシューティング

### よくある問題

#### 1. テストサーバーが起動しない
```bash
# ポート8080が使用中の場合
lsof -ti:8080 | xargs kill -9  # macOS/Linux
netstat -ano | findstr :8080   # Windows
```

#### 2. Flutter Webビルドが失敗する
```bash
# キャッシュクリア
flutter clean
flutter pub get
rm -rf build/
```

#### 3. Playwrightブラウザが見つからない
```bash
# ブラウザを再インストール
npx playwright install --force
```

#### 4. 権限エラー (macOS/Linux)
```bash
# スクリプトに実行権限を付与
chmod +x scripts/build-and-test.sh
```

#### 5. 位置情報テストが失敗する
```javascript
// 位置情報権限を付与
await context.grantPermissions(['geolocation']);
```

### パフォーマンス最適化

#### テスト実行速度向上
```bash
# 並列実行数を増やす
npx playwright test --workers=4

# 特定のプロジェクトのみ実行
npx playwright test --project=chromium

# ビデオ録画を無効化
npx playwright test --config=playwright-fast.config.js
```

#### メモリ使用量削減
```javascript
// playwright.config.js
export default defineConfig({
  use: {
    video: 'retain-on-failure', // 失敗時のみ
    screenshot: 'only-on-failure',
  },
  workers: process.env.CI ? 1 : undefined, // CI環境では並列度を下げる
});
```

### デバッグのヒント

#### 1. ステップバイステップ実行
```bash
npx playwright test --debug
```

#### 2. スクリーンショット付きテスト
```javascript
await page.screenshot({ path: 'debug.png' });
```

#### 3. ページコンテンツの確認
```javascript
console.log(await page.textContent('body'));
```

#### 4. ネットワーク要求の監視
```javascript
page.on('request', request => console.log(request.url()));
page.on('response', response => console.log(response.status()));
```

## 📚 参考資料

- [Playwright公式ドキュメント](https://playwright.dev/)
- [Flutter Web公式ガイド](https://docs.flutter.dev/platform-integration/web)
- [GitHub Actions公式ドキュメント](https://docs.github.com/en/actions)
- [E2Eテストベストプラクティス](https://docs.cypress.io/guides/references/best-practices)

## 🤝 コントリビューション

新しいテストケースを追加する場合：

1. `tests/`ディレクトリに新しい`.spec.js`ファイルを作成
2. テストケースを記述
3. ローカルでテスト実行して確認
4. プルリクエストを作成

### テスト命名規約

```javascript
test.describe('機能名 Tests', () => {
  test('具体的な動作や期待結果', async ({ page }) => {
    // テスト内容
  });
});
```

### コミットメッセージ規約

```
test: 新しいE2Eテストケースを追加
test: パフォーマンステストを改善
fix: テストの不安定性を修正
docs: E2Eテストドキュメントを更新
```

---

## 📞 サポート

問題が発生した場合は、以下の情報を含めてIssueを作成してください：

- OS とバージョン
- Flutter バージョン (`flutter --version`)
- Node.js バージョン (`node --version`)
- エラーメッセージの全文
- 再現手順
- スクリーンショットまたはビデオ（可能であれば）