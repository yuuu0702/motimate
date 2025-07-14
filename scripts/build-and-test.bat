@echo off
REM MotiMate Flutter Web E2E Test Build Script for Windows
REM このスクリプトはFlutter Webアプリをビルドし、Playwrightテストを実行します

setlocal enabledelayedexpansion

echo 🚀 MotiMate E2E Test Build Script (Windows)
echo ==========================================

REM 変数初期化
set SKIP_BUILD=false
set SKIP_INSTALL=false
set HEADLESS=true
set SERVER_PID=

REM オプション解析
:parse_args
if "%~1"=="--skip-build" (
    set SKIP_BUILD=true
    shift
    goto parse_args
)
if "%~1"=="--skip-install" (
    set SKIP_INSTALL=true
    shift
    goto parse_args
)
if "%~1"=="--headed" (
    set HEADLESS=false
    set PLAYWRIGHT_HEADLESS=false
    shift
    goto parse_args
)
if "%~1"=="--help" goto show_help
if "%~1"=="-h" goto show_help
if not "%~1"=="" (
    echo [ERROR] 不明なオプション: %~1
    exit /b 1
)

REM メイン実行
echo [INFO] 開始時刻: %date% %time%

call :check_prerequisites
if errorlevel 1 exit /b 1

if "%SKIP_INSTALL%"=="false" (
    call :install_flutter_dependencies
    if errorlevel 1 exit /b 1
    
    call :install_node_dependencies
    if errorlevel 1 exit /b 1
    
    call :install_playwright_browsers
    if errorlevel 1 exit /b 1
)

if "%SKIP_BUILD%"=="false" (
    call :build_flutter_web
    if errorlevel 1 exit /b 1
)

call :start_test_server
if errorlevel 1 exit /b 1

call :run_playwright_tests
set test_result=!errorlevel!

call :stop_test_server
call :show_test_report

echo [INFO] 終了時刻: %date% %time%

if !test_result! equ 0 (
    echo [SUCCESS] 🎉 すべての処理が正常に完了しました！
) else (
    echo [WARNING] ⚠️  テストで問題が見つかりました。レポートを確認してください。
)

exit /b !test_result!

REM 関数定義

:check_prerequisites
echo [INFO] 前提条件をチェック中...

REM Flutter CLIの確認
flutter --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Flutter CLIが見つかりません。Flutterをインストールしてください。
    exit /b 1
)

REM Node.jsの確認
node --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Node.jsが見つかりません。Node.jsをインストールしてください。
    exit /b 1
)

REM Pythonの確認
python --version >nul 2>&1
if errorlevel 1 (
    python3 --version >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Pythonが見つかりません。Pythonをインストールしてください。
        exit /b 1
    )
)

echo [SUCCESS] 前提条件チェック完了
exit /b 0

:install_flutter_dependencies
echo [INFO] Flutter依存関係を取得中...
flutter pub get
if errorlevel 1 (
    echo [ERROR] Flutter依存関係の取得に失敗しました
    exit /b 1
)
echo [SUCCESS] Flutter依存関係取得完了
exit /b 0

:install_node_dependencies
echo [INFO] Node.js依存関係を取得中...

if not exist package.json (
    echo [ERROR] package.jsonが見つかりません。
    exit /b 1
)

npm install
if errorlevel 1 (
    echo [ERROR] Node.js依存関係のインストールに失敗しました
    exit /b 1
)
echo [SUCCESS] Node.js依存関係取得完了
exit /b 0

:install_playwright_browsers
echo [INFO] Playwrightブラウザをインストール中...
npx playwright install
if errorlevel 1 (
    echo [ERROR] Playwrightブラウザのインストールに失敗しました
    exit /b 1
)
echo [SUCCESS] Playwrightブラウザインストール完了
exit /b 0

:build_flutter_web
echo [INFO] Flutter Webアプリをビルド中...

REM 既存のビルドディレクトリを削除
if exist build\web (
    rmdir /s /q build\web
)

REM HTMLレンダラーでビルド（Playwrightテスト用）
flutter build web --web-renderer html --release --dart-define=FLUTTER_WEB_AUTO_DETECT=true
if errorlevel 1 (
    echo [ERROR] Flutter Webビルドが失敗しました。
    exit /b 1
)

if not exist build\web (
    echo [ERROR] Flutter Webビルドが失敗しました。
    exit /b 1
)

echo [SUCCESS] Flutter Webビルド完了
exit /b 0

:start_test_server
echo [INFO] テストサーバーを起動中...

cd build\web

REM Pythonバージョンチェックと適切なコマンドの選択
python --version >nul 2>&1
if errorlevel 1 (
    start /b python3 -m http.server 8080
) else (
    start /b python -m http.server 8080
)

cd ..\..

REM サーバーが起動するまで待機
echo [INFO] サーバーの起動を待機中...
set /a attempts=0
:wait_server
set /a attempts+=1
if !attempts! gtr 30 (
    echo [ERROR] テストサーバーの起動に失敗しました
    exit /b 1
)

curl -s http://localhost:8080 >nul 2>&1
if errorlevel 1 (
    timeout /t 1 /nobreak >nul
    goto wait_server
)

echo [SUCCESS] テストサーバーが起動しました
exit /b 0

:run_playwright_tests
echo [INFO] Playwrightテストを実行中...

npx playwright test --reporter=html,line
set test_exit_code=!errorlevel!

if !test_exit_code! equ 0 (
    echo [SUCCESS] すべてのテストが成功しました！
) else (
    echo [WARNING] 一部のテストが失敗しました (終了コード: !test_exit_code!)
)

exit /b !test_exit_code!

:stop_test_server
echo [INFO] テストサーバーを停止中...

REM Pythonサーバープロセスを終了
taskkill /f /im python.exe /fi "windowtitle eq http.server" >nul 2>&1
taskkill /f /im python3.exe /fi "windowtitle eq http.server" >nul 2>&1

echo [SUCCESS] テストサーバーを停止しました
exit /b 0

:show_test_report
echo [INFO] テストレポートを確認してください:
echo   - HTMLレポート: playwright-report\index.html
echo   - スクリーンショット: test-results\
echo   - ビデオ: test-results\

REM HTMLレポートを自動で開く（オプション）
if exist playwright-report\index.html (
    start playwright-report\index.html
)
exit /b 0

:show_help
echo 使用方法: %~n0 [オプション]
echo.
echo オプション:
echo   --skip-build    Flutterビルドをスキップ
echo   --skip-install  依存関係インストールをスキップ
echo   --headed        ブラウザを表示モードで実行
echo   --help, -h      このヘルプを表示
exit /b 0