# MotiMate - Flutter開発ガイドライン

## プロジェクト概要
MotiMateは、チームのモチベーション管理を行うFlutterアプリです。Firebaseをバックエンドとして使用し、認証、データベース、プッシュ通知機能を提供します。

## アーキテクチャ

### 推奨アーキテクチャパターン
Flutter公式ガイド（https://docs.flutter.dev/app-architecture/guide）に基づき、以下のアーキテクチャを採用しています：

#### レイヤー構成
```
├── presentation/     # UI層（Widgets、Screens）
├── application/      # アプリケーション層（ViewModels、UseCases）
├── domain/          # ドメイン層（Models、Repositories）
└── infrastructure/  # インフラ層（Services、DataSources）
```

#### 実際のディレクトリ構成
```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   ├── theme/
│   ├── error/
│   └── auth/
├── models/          # ドメインモデル
├── viewmodels/      # アプリケーション層
├── screens/         # プレゼンテーション層
├── widgets/         # 再利用可能なUIコンポーネント
├── services/        # インフラ層
├── providers/       # 依存性注入
├── routing/         # ナビゲーション
└── themes/          # UIテーマ
```

### 状態管理
- **Riverpod**: メイン状態管理ライブラリ
- **flutter_hooks**: UIロジックの簡素化
- **freezed**: イミュータブルなデータクラス生成

### 主要な設計原則
1. **単一責任の原則**: 各クラスは1つの責任のみを持つ
2. **依存性注入**: Riverpodを使用した疎結合な設計
3. **イミュータブル状態**: Freezedを使用した状態の不変性
4. **エラーハンドリング**: 一元化されたエラー処理システム

## コーディング規約

### Dart言語ガイドライン
Effective Dart（https://dart.dev/effective-dart）に従います：

#### Style（スタイル）
```dart
// ✅ 良い例: lowerCamelCase for variables, functions
var userName = 'john_doe';
void getUserData() { }

// ✅ 良い例: UpperCamelCase for classes, enums
class UserManager { }
enum AuthStatus { authenticated, unauthenticated }

// ✅ 良い例: lowercase_with_underscores for libraries, packages
import 'package:motimate/user_service.dart';

// ✅ 良い例: SCREAMING_CAPS for constants
const String API_KEY = 'your_api_key';
```

#### Documentation（ドキュメント）
```dart
/// ユーザーの認証状態を管理するクラス
/// 
/// このクラスはFirebase Authenticationと連携し、
/// ログイン、ログアウト、ユーザー情報の取得を行います。
class AuthManager {
  /// 指定されたメールアドレスとパスワードでログインを試行します
  /// 
  /// [email]にはユーザーのメールアドレスを指定
  /// [password]にはユーザーのパスワードを指定
  /// 
  /// 成功時は[User]オブジェクトを返し、失敗時は例外をスローします
  Future<User> signIn(String email, String password) async {
    // 実装
  }
}
```

#### Usage（使用法）
```dart
// ✅ 良い例: 型推論を活用
var items = <String>[];
final user = getCurrentUser();

// ✅ 良い例: カスケード記法の適切な使用
var button = ElevatedButton.icon(
  icon: Icon(Icons.add),
  label: Text('追加'),
)..onPressed = _handleAdd;

// ✅ 良い例: 条件演算子の使用
Text(user?.name ?? 'ゲスト')

// ✅ 良い例: Collection ifの使用
children: [
  Text('常に表示'),
  if (showDetail) Text('詳細情報'),
  ...additionalWidgets,
]
```

#### Design（設計）
```dart
// ✅ 良い例: async/awaitの使用
Future<List<User>> getUsers() async {
  try {
    final response = await apiClient.get('/users');
    return response.data.map((json) => User.fromJson(json)).toList();
  } catch (e) {
    throw UserFetchException('Failed to fetch users: $e');
  }
}

// ✅ 良い例: Streamの使用
Stream<List<Notification>> watchNotifications(String userId) {
  return FirebaseFirestore.instance
      .collection('notifications')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Notification.fromFirestore(doc))
          .toList());
}
```

## Flutter固有のベストプラクティス

### Widget設計
```dart
// ✅ 良い例: StatelessWidgetの優先使用
class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.user,
    this.onTap,
  });

  final User user;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(user.name),
        subtitle: Text(user.email),
        onTap: onTap,
      ),
    );
  }
}

// ✅ 良い例: HookConsumerWidgetの使用
class UserProfileScreen extends HookConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isEditing = useState(false);
    
    return Scaffold(
      appBar: AppBar(title: Text('プロフィール')),
      body: user.when(
        data: (userData) => _buildProfileContent(userData, isEditing),
        loading: () => const CircularProgressIndicator(),
        error: (error, stack) => ErrorWidget(error),
      ),
    );
  }
}
```

### 状態管理パターン
```dart
// ✅ 良い例: Freezedを使用したState定義
@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isLoading,
    User? user,
    String? error,
  }) = _AuthState;
}

// ✅ 良い例: StateNotifierの実装
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService) : super(const AuthState());

  final AuthService _authService;

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _authService.signIn(email, password);
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// ✅ 良い例: Provider定義
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
```

### エラーハンドリング
```dart
// ✅ 良い例: カスタム例外クラス
class AuthException implements Exception {
  const AuthException(this.message, [this.code]);
  
  final String message;
  final String? code;
  
  @override
  String toString() => 'AuthException: $message';
}

// ✅ 良い例: エラー境界の実装
class ErrorBoundary extends ConsumerWidget {
  const ErrorBoundary({super.key, required this.child});
  
  final Widget child;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = ref.watch(errorProvider);
    
    if (error != null) {
      return ErrorDialog(
        error: error,
        onRetry: () => ref.read(errorProvider.notifier).clearError(),
      );
    }
    
    return child;
  }
}
```

## テスト戦略

### テストの種類
1. **Unit Tests**: ビジネスロジック、ユーティリティ関数
2. **Widget Tests**: 個別Widget、UI状態
3. **Integration Tests**: 画面遷移、データフロー

### テストコード例
```dart
// ✅ 良い例: Unit Test
void main() {
  group('AuthNotifier', () {
    late AuthNotifier notifier;
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
      notifier = AuthNotifier(mockAuthService);
    });

    test('初期状態は空のAuthState', () {
      expect(notifier.state, const AuthState());
    });

    test('サインイン成功時にユーザーが設定される', () async {
      final user = User(id: '1', name: 'Test User');
      when(mockAuthService.signIn(any, any))
          .thenAnswer((_) async => user);

      await notifier.signIn('test@example.com', 'password');

      expect(notifier.state.user, user);
      expect(notifier.state.isLoading, false);
    });
  });
}
```

## パフォーマンス最適化

### 推奨プラクティス
```dart
// ✅ 良い例: constコンストラクターの使用
const Text('固定テキスト')

// ✅ 良い例: ListViewの適切な使用
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)

// ✅ 良い例: メモ化の使用
final expensiveData = useMemoized(() => 
  computeExpensiveValue(dependency), [dependency]);

// ✅ 良い例: 適切なキーの使用
ListView(
  children: items.map((item) => 
    ItemWidget(key: ValueKey(item.id), item: item)).toList(),
)
```

## セキュリティガイドライン

### 重要な原則
1. **機密情報の漏洩防止**: APIキー、パスワードをコードに含めない
2. **入力値検証**: ユーザー入力は必ず検証する
3. **認証・認可**: 適切な権限チェックを実装
4. **データ暗号化**: 機密データは暗号化して保存

```dart
// ✅ 良い例: 入力値検証
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'メールアドレスを入力してください';
  }
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return '正しいメールアドレスを入力してください';
  }
  return null;
}

// ✅ 良い例: 環境変数の使用
class Config {
  static const String apiKey = String.fromEnvironment('API_KEY');
  static const String apiUrl = String.fromEnvironment('API_URL');
}
```

## 開発ツール・コマンド

### よく使用するコマンド
```bash
# 依存関係の取得
flutter pub get

# コード生成（Freezed、JsonSerializable）
flutter packages pub run build_runner build

# 監視モードでコード生成
flutter packages pub run build_runner watch

# 静的解析
flutter analyze

# テスト実行
flutter test

# フォーマット
dart format lib/

# ビルド（Debug）
flutter build apk --debug

# ビルド（Release）
flutter build apk --release
```

### 推奨VS Code拡張機能
- Flutter
- Dart
- Awesome Flutter Snippets
- Flutter Widget Snippets
- Error Lens

## Git運用

### コミットメッセージ規約
```
type(scope): subject

feat(auth): add Google sign-in functionality
fix(home): resolve notification bell context issue
refactor(routing): migrate to Go Router navigation
docs(readme): update setup instructions
test(auth): add unit tests for AuthNotifier
```

### ブランチ命名規約
- `feature/機能名`: 新機能開発
- `fix/バグ名`: バグ修正
- `refactor/対象`: リファクタリング
- `docs/対象`: ドキュメント更新

このガイドラインに従って、保守性が高く、拡張しやすいFlutterアプリケーションを開発してください。