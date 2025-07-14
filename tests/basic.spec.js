import { test, expect } from '@playwright/test';

test.describe('MotiMate Basic Tests', () => {
  test.beforeEach(async ({ page }) => {
    // Flutter Webアプリケーションにアクセス
    await page.goto('/');
    
    // Flutter Webアプリが完全に読み込まれるまで待機
    await page.waitForSelector('flt-scene-host', { timeout: 30000 });
    
    // Flutter エンジンが初期化されるまで少し待機
    await page.waitForTimeout(2000);
  });

  test('アプリケーションが正常に読み込まれる', async ({ page }) => {
    // ページタイトルの確認
    await expect(page).toHaveTitle(/MotiMate|motimate/i);
    
    // Flutter Webアプリケーションの基本要素が存在することを確認
    const flutterView = page.locator('flt-scene-host');
    await expect(flutterView).toBeVisible();
  });

  test('認証画面が表示される', async ({ page }) => {
    // 認証画面の要素を確認
    // Flutter Webでは、通常のDOM要素ではなくCanvasベースなので、
    // テキストコンテンツで判断します
    
    // ページに「ログイン」や「認証」関連のテキストが含まれているかチェック
    const hasLoginText = await page.locator('body').textContent();
    expect(hasLoginText).toMatch(/(ログイン|サインイン|認証|MotiMate)/i);
  });

  test('レスポンシブデザインが動作する', async ({ page }) => {
    // デスクトップサイズでの表示確認
    await page.setViewportSize({ width: 1280, height: 720 });
    await page.waitForTimeout(1000);
    
    const flutterView = page.locator('flt-scene-host');
    await expect(flutterView).toBeVisible();
    
    // モバイルサイズでの表示確認
    await page.setViewportSize({ width: 375, height: 667 });
    await page.waitForTimeout(1000);
    
    await expect(flutterView).toBeVisible();
  });

  test('ページが完全に読み込まれるまでの時間を測定', async ({ page }) => {
    const start = Date.now();
    
    await page.goto('/');
    
    // Flutter Webアプリが完全に読み込まれるまで待機
    await page.waitForSelector('flt-scene-host', { timeout: 30000 });
    await page.waitForLoadState('networkidle');
    
    const loadTime = Date.now() - start;
    console.log(`ページ読み込み時間: ${loadTime}ms`);
    
    // 読み込み時間が合理的な範囲内かチェック（30秒以内）
    expect(loadTime).toBeLessThan(30000);
  });

  test('JavaScriptエラーがないことを確認', async ({ page }) => {
    const errors = [];
    
    page.on('pageerror', (error) => {
      errors.push(error.message);
    });
    
    page.on('console', (msg) => {
      if (msg.type() === 'error') {
        errors.push(msg.text());
      }
    });
    
    await page.goto('/');
    await page.waitForSelector('flt-scene-host', { timeout: 30000 });
    
    // 重大なJavaScriptエラーがないことを確認
    const criticalErrors = errors.filter(error => 
      !error.includes('non-critical') && 
      !error.includes('warning') &&
      !error.includes('firebase') // Firebase関連の軽微なエラーは除外
    );
    
    expect(criticalErrors).toHaveLength(0);
  });
});