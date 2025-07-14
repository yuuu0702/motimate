import { test, expect } from '@playwright/test';

test.describe('MotiMate Gymnasium Feature Tests', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await page.waitForSelector('flt-scene-host', { timeout: 30000 });
    await page.waitForTimeout(2000);
  });

  test('体育館画面に遷移できる', async ({ page }) => {
    const viewport = page.viewportSize();
    
    // バスケ会場タブをタップ（中央のナビゲーション）
    await page.click('body', { 
      position: { x: viewport.width * 0.5, y: viewport.height - 50 } 
    });
    
    await page.waitForTimeout(2000);
    
    // 体育館関連のテキストが表示されているかチェック
    const pageContent = await page.textContent('body');
    expect(pageContent).toMatch(/(体育館|バスケ|会場|検索)/);
  });

  test('体育館検索機能をテスト', async ({ page }) => {
    const viewport = page.viewportSize();
    
    // バスケ会場タブに移動
    await page.click('body', { 
      position: { x: viewport.width * 0.5, y: viewport.height - 50 } 
    });
    await page.waitForTimeout(2000);
    
    // 検索バーの位置をタップ（画面上部中央）
    await page.click('body', { 
      position: { x: viewport.width * 0.5, y: 120 } 
    });
    await page.waitForTimeout(1000);
    
    // 検索クエリを入力（仮想キーボード入力）
    await page.keyboard.type('体育館');
    await page.waitForTimeout(1000);
    
    // Enterキーで検索実行
    await page.keyboard.press('Enter');
    await page.waitForTimeout(2000);
    
    console.log('体育館検索テスト完了');
  });

  test('距離順ソート機能をテスト', async ({ page }) => {
    const viewport = page.viewportSize();
    
    // バスケ会場タブに移動
    await page.click('body', { 
      position: { x: viewport.width * 0.5, y: viewport.height - 50 } 
    });
    await page.waitForTimeout(2000);
    
    // 距離順ソートボタンをタップ（アプリバー右側）
    await page.click('body', { 
      position: { x: viewport.width - 60, y: 50 } 
    });
    await page.waitForTimeout(2000);
    
    // ソート状態の確認
    const pageContent = await page.textContent('body');
    expect(pageContent).toMatch(/(近い順|距離|ソート)/);
  });

  test('体育館リストが表示される', async ({ page }) => {
    const viewport = page.viewportSize();
    
    // バスケ会場タブに移動
    await page.click('body', { 
      position: { x: viewport.width * 0.5, y: viewport.height - 50 } 
    });
    await page.waitForTimeout(3000);
    
    // 体育館リストの内容をチェック
    const pageContent = await page.textContent('body');
    
    // 金沢市の体育館名が表示されているかチェック
    const gymnasiumNames = [
      '金沢市総合体育館',
      '城北市民体育館', 
      '西部市民体育館',
      '安原スポーツ広場',
      '健民海浜スポーツセンター'
    ];
    
    let foundGymnasiums = 0;
    for (const name of gymnasiumNames) {
      if (pageContent.includes(name)) {
        foundGymnasiums++;
      }
    }
    
    // 少なくとも1つの体育館が表示されていることを確認
    expect(foundGymnasiums).toBeGreaterThan(0);
    console.log(`${foundGymnasiums}個の体育館が見つかりました`);
  });

  test('体育館カードをタップして詳細を確認', async ({ page }) => {
    const viewport = page.viewportSize();
    
    // バスケ会場タブに移動
    await page.click('body', { 
      position: { x: viewport.width * 0.5, y: viewport.height - 50 } 
    });
    await page.waitForTimeout(3000);
    
    // 最初の体育館カードをタップ（リストの上部）
    await page.click('body', { 
      position: { x: viewport.width * 0.5, y: 250 } 
    });
    await page.waitForTimeout(2000);
    
    // 詳細情報が表示されているかチェック
    const pageContent = await page.textContent('body');
    expect(pageContent).toMatch(/(住所|電話|営業|時間|料金)/);
  });

  test('フィルター機能をテスト', async ({ page }) => {
    const viewport = page.viewportSize();
    
    // バスケ会場タブに移動
    await page.click('body', { 
      position: { x: viewport.width * 0.5, y: viewport.height - 50 } 
    });
    await page.waitForTimeout(2000);
    
    // フィルターボタンをタップ（アプリバー右側）
    await page.click('body', { 
      position: { x: viewport.width - 100, y: 50 } 
    });
    await page.waitForTimeout(1000);
    
    // フィルター関連のテキストが表示されているかチェック
    const pageContent = await page.textContent('body');
    expect(pageContent).toMatch(/(フィルター|設備|バスケ|駐車場)/);
  });

  test('位置情報権限が要求される', async ({ page, context }) => {
    // 位置情報権限の付与
    await context.grantPermissions(['geolocation']);
    
    const viewport = page.viewportSize();
    
    // バスケ会場タブに移動
    await page.click('body', { 
      position: { x: viewport.width * 0.5, y: viewport.height - 50 } 
    });
    await page.waitForTimeout(3000);
    
    // 位置情報が取得されているかの確認
    const pageContent = await page.textContent('body');
    expect(pageContent).toMatch(/(現在位置|取得済み|距離|km|m)/);
  });

  test('モバイル表示での体育館機能', async ({ page }) => {
    // モバイルサイズに設定
    await page.setViewportSize({ width: 375, height: 667 });
    await page.waitForTimeout(1000);
    
    // バスケ会場タブに移動
    await page.click('body', { 
      position: { x: 187, y: 617 } // モバイルサイズでの中央ボトム
    });
    await page.waitForTimeout(2000);
    
    // モバイル表示での体育館リストの確認
    const pageContent = await page.textContent('body');
    expect(pageContent).toMatch(/(体育館|バスケ)/);
    
    // モバイルでのスクロールテスト
    await page.mouse.wheel(0, 300);
    await page.waitForTimeout(1000);
    
    await page.mouse.wheel(0, -300);
    await page.waitForTimeout(1000);
  });
});