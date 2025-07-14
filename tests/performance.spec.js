import { test, expect } from '@playwright/test';

test.describe('MotiMate Performance Tests', () => {
  test('ページ読み込みパフォーマンス測定', async ({ page }) => {
    // パフォーマンス測定開始
    const startTime = Date.now();
    
    await page.goto('/');
    
    // Flutter Webアプリの完全な読み込みを待機
    await page.waitForSelector('flt-scene-host', { timeout: 30000 });
    await page.waitForLoadState('networkidle');
    
    const loadTime = Date.now() - startTime;
    
    console.log(`ページ読み込み時間: ${loadTime}ms`);
    
    // パフォーマンス要件
    expect(loadTime).toBeLessThan(15000); // 15秒以内
    
    // Web Vitals的な測定
    const performanceMetrics = await page.evaluate(() => {
      const navigation = performance.getEntriesByType('navigation')[0];
      return {
        domContentLoaded: navigation.domContentLoadedEventEnd - navigation.domContentLoadedEventStart,
        loadComplete: navigation.loadEventEnd - navigation.loadEventStart,
        ttfb: navigation.responseStart - navigation.requestStart, // Time to First Byte
      };
    });
    
    console.log('パフォーマンスメトリクス:', performanceMetrics);
    
    // TTFB（Time to First Byte）は1秒以内であることが望ましい
    expect(performanceMetrics.ttfb).toBeLessThan(1000);
  });

  test('メモリ使用量監視', async ({ page }) => {
    await page.goto('/');
    await page.waitForSelector('flt-scene-host', { timeout: 30000 });
    
    // ページの基本的な操作を実行
    const viewport = page.viewportSize();
    
    // 各ナビゲーションタブを操作
    const navPositions = [
      { x: viewport.width * 0.1 },
      { x: viewport.width * 0.3 },
      { x: viewport.width * 0.5 },
      { x: viewport.width * 0.7 },
      { x: viewport.width * 0.9 }
    ];

    for (const position of navPositions) {
      await page.click('body', { 
        position: { x: position.x, y: viewport.height - 50 } 
      });
      await page.waitForTimeout(2000);
    }
    
    // メモリ使用量を測定
    const memoryUsage = await page.evaluate(() => {
      if ('memory' in performance) {
        return {
          usedJSHeapSize: performance.memory.usedJSHeapSize,
          totalJSHeapSize: performance.memory.totalJSHeapSize,
          jsHeapSizeLimit: performance.memory.jsHeapSizeLimit
        };
      }
      return null;
    });
    
    if (memoryUsage) {
      console.log('メモリ使用量:', {
        used: `${Math.round(memoryUsage.usedJSHeapSize / 1024 / 1024)}MB`,
        total: `${Math.round(memoryUsage.totalJSHeapSize / 1024 / 1024)}MB`,
        limit: `${Math.round(memoryUsage.jsHeapSizeLimit / 1024 / 1024)}MB`
      });
      
      // メモリ使用量が過度に高くないことを確認（100MB以内）
      expect(memoryUsage.usedJSHeapSize).toBeLessThan(100 * 1024 * 1024);
    }
  });

  test('大量データ処理のパフォーマンス', async ({ page }) => {
    await page.goto('/');
    await page.waitForSelector('flt-scene-host', { timeout: 30000 });
    
    const viewport = page.viewportSize();
    
    // 体育館リストページに移動
    await page.click('body', { 
      position: { x: viewport.width * 0.5, y: viewport.height - 50 } 
    });
    await page.waitForTimeout(2000);
    
    const startTime = Date.now();
    
    // スクロールパフォーマンステスト
    for (let i = 0; i < 10; i++) {
      await page.mouse.wheel(0, 300);
      await page.waitForTimeout(100);
    }
    
    const scrollTime = Date.now() - startTime;
    console.log(`スクロール処理時間: ${scrollTime}ms`);
    
    // スクロールが滑らかであることを確認（3秒以内）
    expect(scrollTime).toBeLessThan(3000);
  });

  test('ネットワーク効率性テスト', async ({ page }) => {
    // ネットワーク要求を監視
    const networkRequests = [];
    
    page.on('request', request => {
      networkRequests.push({
        url: request.url(),
        method: request.method(),
        size: request.postData()?.length || 0
      });
    });
    
    await page.goto('/');
    await page.waitForSelector('flt-scene-host', { timeout: 30000 });
    await page.waitForLoadState('networkidle');
    
    console.log(`総ネットワーク要求数: ${networkRequests.length}`);
    
    // 過度なネットワーク要求がないことを確認
    expect(networkRequests.length).toBeLessThan(50);
    
    // 主要なリソース種別の確認
    const resourceTypes = {};
    networkRequests.forEach(req => {
      const url = new URL(req.url);
      const extension = url.pathname.split('.').pop()?.toLowerCase();
      resourceTypes[extension] = (resourceTypes[extension] || 0) + 1;
    });
    
    console.log('リソース種別別要求数:', resourceTypes);
  });

  test('レスポンス時間測定', async ({ page }) => {
    const responseTimings = [];
    
    page.on('response', response => {
      const timing = response.request().timing();
      if (timing) {
        responseTimings.push({
          url: response.url(),
          status: response.status(),
          timing: timing.responseEnd - timing.requestStart
        });
      }
    });
    
    await page.goto('/');
    await page.waitForSelector('flt-scene-host', { timeout: 30000 });
    await page.waitForLoadState('networkidle');
    
    // 平均レスポンス時間を計算
    const averageResponseTime = responseTimings.reduce((sum, r) => sum + r.timing, 0) / responseTimings.length;
    
    console.log(`平均レスポンス時間: ${Math.round(averageResponseTime)}ms`);
    console.log(`最大レスポンス時間: ${Math.max(...responseTimings.map(r => r.timing))}ms`);
    
    // 平均レスポンス時間が合理的であることを確認（2秒以内）
    expect(averageResponseTime).toBeLessThan(2000);
  });

  test('異なるネットワーク条件でのテスト', async ({ page, context }) => {
    // ネットワーク条件をシミュレート（遅い3G）
    await context.route('**/*', async route => {
      await new Promise(resolve => setTimeout(resolve, 500)); // 500ms遅延
      await route.continue();
    });
    
    const startTime = Date.now();
    
    await page.goto('/');
    await page.waitForSelector('flt-scene-host', { timeout: 45000 });
    
    const loadTimeSlowNetwork = Date.now() - startTime;
    
    console.log(`低速ネットワークでの読み込み時間: ${loadTimeSlowNetwork}ms`);
    
    // 低速ネットワークでも30秒以内に読み込まれることを確認
    expect(loadTimeSlowNetwork).toBeLessThan(30000);
  });

  test('バッテリー効率性テスト', async ({ page }) => {
    await page.goto('/');
    await page.waitForSelector('flt-scene-host', { timeout: 30000 });
    
    // CPU集約的な操作をシミュレート
    const startTime = Date.now();
    const viewport = page.viewportSize();
    
    // 60秒間継続的に操作を実行
    const endTime = startTime + 60000;
    let operationCount = 0;
    
    while (Date.now() < endTime) {
      // ナビゲーション操作
      await page.click('body', { 
        position: { x: viewport.width * 0.5, y: viewport.height - 50 } 
      });
      await page.waitForTimeout(100);
      
      // スクロール操作
      await page.mouse.wheel(0, 100);
      await page.waitForTimeout(100);
      
      operationCount++;
      
      if (operationCount >= 100) break; // 最大100操作で制限
    }
    
    const actualDuration = Date.now() - startTime;
    const operationsPerSecond = operationCount / (actualDuration / 1000);
    
    console.log(`操作効率: ${Math.round(operationsPerSecond)}操作/秒`);
    
    // 基本的なパフォーマンス要件を満たしていることを確認
    expect(operationsPerSecond).toBeGreaterThan(1);
  });
});