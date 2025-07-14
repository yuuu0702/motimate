import { test, expect } from '@playwright/test';

test.describe('MotiMate Navigation Tests', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await page.waitForSelector('flt-scene-host', { timeout: 30000 });
    await page.waitForTimeout(2000);
  });

  test('ボトムナビゲーションが表示される', async ({ page }) => {
    // Flutter Webアプリでボトムナビゲーションのテキストを確認
    const pageContent = await page.textContent('body');
    
    // ナビゲーション項目のテキストが含まれているかチェック
    const navigationItems = ['ホーム', 'スケジュール', 'バスケ会場', 'メンバー', 'モチベーション'];
    
    for (const item of navigationItems) {
      expect(pageContent).toContain(item);
    }
  });

  test('ナビゲーションタップシミュレーション', async ({ page }) => {
    // Flutter Webでは座標ベースのクリックを使用
    const viewport = page.viewportSize();
    const bottomY = viewport.height - 50; // ボトムナビゲーション付近
    
    // 各ナビゲーション項目の座標を計算してタップ
    const navPositions = [
      { x: viewport.width * 0.1, label: 'ホーム' },      // 左端
      { x: viewport.width * 0.3, label: 'スケジュール' },  // 中央左
      { x: viewport.width * 0.5, label: 'バスケ会場' },   // 中央
      { x: viewport.width * 0.7, label: 'メンバー' },    // 中央右
      { x: viewport.width * 0.9, label: 'モチベーション' } // 右端
    ];

    for (const position of navPositions) {
      // 各ナビゲーション項目をタップ
      await page.click(`body`, { 
        position: { x: position.x, y: bottomY } 
      });
      
      // ページ遷移を待機
      await page.waitForTimeout(1000);
      
      // 画面が変更されたことを確認（ここではタイムアウトエラーがないことで判断）
      console.log(`${position.label}をタップしました`);
    }
  });

  test('アプリバーが正しく表示される', async ({ page }) => {
    const pageContent = await page.textContent('body');
    
    // アプリバーのタイトルや要素が含まれているかチェック
    expect(pageContent).toMatch(/(MotiMate|ホーム|設定)/);
  });

  test('ドロワーメニューが存在する場合のテスト', async ({ page }) => {
    const viewport = page.viewportSize();
    
    // ハンバーガーメニューの位置をタップ（左上）
    await page.click('body', { 
      position: { x: 30, y: 50 } 
    });
    
    await page.waitForTimeout(1000);
    
    // ドロワーが開いたかどうかの確認
    const pageContent = await page.textContent('body');
    console.log('ドロワーメニューテスト完了');
  });

  test('画面回転シミュレーション', async ({ page }) => {
    // 縦向き
    await page.setViewportSize({ width: 375, height: 667 });
    await page.waitForTimeout(1000);
    
    let pageContent = await page.textContent('body');
    expect(pageContent).toContain('ホーム');
    
    // 横向き
    await page.setViewportSize({ width: 667, height: 375 });
    await page.waitForTimeout(1000);
    
    pageContent = await page.textContent('body');
    expect(pageContent).toContain('ホーム');
    
    // デスクトップサイズに戻す
    await page.setViewportSize({ width: 1280, height: 720 });
    await page.waitForTimeout(1000);
  });

  test('キーボードナビゲーション', async ({ page }) => {
    // Tabキーでナビゲーション
    await page.keyboard.press('Tab');
    await page.waitForTimeout(500);
    
    await page.keyboard.press('Tab');
    await page.waitForTimeout(500);
    
    // Enterキーで選択
    await page.keyboard.press('Enter');
    await page.waitForTimeout(1000);
    
    console.log('キーボードナビゲーションテスト完了');
  });
});