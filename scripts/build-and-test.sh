#!/bin/bash

# MotiMate Flutter Web E2E Test Build Script
# このスクリプトはFlutter Webアプリをビルドし、Playwrightテストを実行します

set -e  # エラー時に停止

echo "🚀 MotiMate E2E Test Build Script"
echo "=================================="

# 色付きログのための関数
log_info() {
    echo -e "\033[36m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[32m[SUCCESS]\033[0m $1"
}

log_error() {
    echo -e "\033[31m[ERROR]\033[0m $1"
}

log_warning() {
    echo -e "\033[33m[WARNING]\033[0m $1"
}

# 前提条件のチェック
check_prerequisites() {
    log_info "前提条件をチェック中..."
    
    # Flutter CLIの確認
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter CLIが見つかりません。Flutterをインストールしてください。"
        exit 1
    fi
    
    # Node.jsの確認
    if ! command -v node &> /dev/null; then
        log_error "Node.jsが見つかりません。Node.jsをインストールしてください。"
        exit 1
    fi
    
    # Pythonの確認（HTTPサーバー用）
    if ! command -v python &> /dev/null && ! command -v python3 &> /dev/null; then
        log_error "Pythonが見つかりません。Pythonをインストールしてください。"
        exit 1
    fi
    
    log_success "前提条件チェック完了"
}

# Flutter依存関係の取得
install_flutter_dependencies() {
    log_info "Flutter依存関係を取得中..."
    flutter pub get
    log_success "Flutter依存関係取得完了"
}

# Node.js依存関係の取得
install_node_dependencies() {
    log_info "Node.js依存関係を取得中..."
    
    if [ ! -f "package.json" ]; then
        log_error "package.jsonが見つかりません。"
        exit 1
    fi
    
    npm install
    log_success "Node.js依存関係取得完了"
}

# Playwrightブラウザのインストール
install_playwright_browsers() {
    log_info "Playwrightブラウザをインストール中..."
    npx playwright install
    log_success "Playwrightブラウザインストール完了"
}

# Flutter Webアプリのビルド
build_flutter_web() {
    log_info "Flutter Webアプリをビルド中..."
    
    # 既存のビルドディレクトリを削除
    if [ -d "build/web" ]; then
        rm -rf build/web
    fi
    
    # HTMLレンダラーでビルド（Playwrightテスト用）
    flutter build web \
        --web-renderer html \
        --release \
        --dart-define=FLUTTER_WEB_AUTO_DETECT=true
    
    if [ ! -d "build/web" ]; then
        log_error "Flutter Webビルドが失敗しました。"
        exit 1
    fi
    
    log_success "Flutter Webビルド完了"
}

# テストサーバーの起動
start_test_server() {
    log_info "テストサーバーを起動中..."
    
    cd build/web
    
    # Pythonバージョンチェックと適切なコマンドの選択
    if command -v python3 &> /dev/null; then
        python3 -m http.server 8080 &
    else
        python -m http.server 8080 &
    fi
    
    SERVER_PID=$!
    cd ../..
    
    # サーバーが起動するまで待機
    log_info "サーバーの起動を待機中..."
    for i in {1..30}; do
        if curl -s http://localhost:8080 > /dev/null 2>&1; then
            log_success "テストサーバーが起動しました (PID: $SERVER_PID)"
            echo $SERVER_PID > .server.pid
            return 0
        fi
        sleep 1
    done
    
    log_error "テストサーバーの起動に失敗しました"
    kill $SERVER_PID 2>/dev/null || true
    exit 1
}

# Playwrightテストの実行
run_playwright_tests() {
    log_info "Playwrightテストを実行中..."
    
    # テスト実行
    npx playwright test --reporter=html,line
    
    local test_exit_code=$?
    
    if [ $test_exit_code -eq 0 ]; then
        log_success "すべてのテストが成功しました！"
    else
        log_warning "一部のテストが失敗しました (終了コード: $test_exit_code)"
    fi
    
    return $test_exit_code
}

# テストサーバーの停止
stop_test_server() {
    log_info "テストサーバーを停止中..."
    
    if [ -f ".server.pid" ]; then
        SERVER_PID=$(cat .server.pid)
        kill $SERVER_PID 2>/dev/null || true
        rm -f .server.pid
        log_success "テストサーバーを停止しました"
    fi
}

# テストレポートの表示
show_test_report() {
    log_info "テストレポートを確認してください:"
    echo "  - HTMLレポート: playwright-report/index.html"
    echo "  - スクリーンショット: test-results/"
    echo "  - ビデオ: test-results/"
    
    # HTMLレポートを自動で開く（オプション）
    if command -v xdg-open &> /dev/null; then
        xdg-open playwright-report/index.html
    elif command -v open &> /dev/null; then
        open playwright-report/index.html
    fi
}

# クリーンアップ関数
cleanup() {
    log_info "クリーンアップ中..."
    stop_test_server
    
    # 一時ファイルの削除
    rm -f .server.pid
}

# Ctrl+C時のクリーンアップ
trap cleanup EXIT

# メイン実行フロー
main() {
    echo "開始時刻: $(date)"
    
    check_prerequisites
    install_flutter_dependencies
    install_node_dependencies
    install_playwright_browsers
    build_flutter_web
    start_test_server
    
    # テスト実行
    run_playwright_tests
    test_result=$?
    
    stop_test_server
    show_test_report
    
    echo "終了時刻: $(date)"
    
    if [ $test_result -eq 0 ]; then
        log_success "🎉 すべての処理が正常に完了しました！"
    else
        log_warning "⚠️  テストで問題が見つかりました。レポートを確認してください。"
    fi
    
    exit $test_result
}

# オプション解析
SKIP_BUILD=false
SKIP_INSTALL=false
HEADLESS=true

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        --skip-install)
            SKIP_INSTALL=true
            shift
            ;;
        --headed)
            HEADLESS=false
            export PLAYWRIGHT_HEADLESS=false
            shift
            ;;
        --help|-h)
            echo "使用方法: $0 [オプション]"
            echo ""
            echo "オプション:"
            echo "  --skip-build    Flutterビルドをスキップ"
            echo "  --skip-install  依存関係インストールをスキップ"
            echo "  --headed        ブラウザを表示モードで実行"
            echo "  --help, -h      このヘルプを表示"
            exit 0
            ;;
        *)
            log_error "不明なオプション: $1"
            exit 1
            ;;
    esac
done

# メイン実行
main