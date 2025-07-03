import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motimate/app.dart';
import 'package:motimate/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:motimate/screens/auth_screen.dart';
import 'package:motimate/screens/schedule_screen.dart';
import 'package:motimate/screens/user_registration_screen.dart';
import 'package:motimate/screens/notifications_screen.dart';
import 'package:motimate/screens/feedback_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motimate/providers/providers.dart';

// バックグラウンドメッセージハンドラ
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
  // ここで通知の表示などを行う
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // FCM設定
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ユーザーログイン状態の監視（通知許可は設定画面で個別に管理）
  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    if (user != null) {
      // ログイン時刻のみ記録（FCMトークンは通知許可時に保存）
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  });

  // フォアグラウンドメッセージのハンドリング
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      // ここでフォアグラウンド通知の表示などを行う
      ScaffoldMessenger.of(navigatorKey.currentState!.context).showSnackBar(
        SnackBar(
          content: Text(
            message.notification!.title ?? ': ${message.notification!.body}',
          ),
        ),
      );
    }
  });

  runApp(const ProviderScope(child: MyApp()));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  static MyAppState? of(BuildContext context) => 
      context.findAncestorStateOfType<MyAppState>();

  @override
  ConsumerState<MyApp> createState() => MyAppState();
}

class MyAppState extends ConsumerState<MyApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    // ダークテーマは準備中のため、常にライトテーマ
    _isDarkMode = false;
  }

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  bool get isDarkMode => _isDarkMode;

  ThemeData get lightTheme => ThemeData(
    fontFamily: 'MPLUSRounded1c',
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF667eea),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF1E293B),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'MPLUSRounded1c',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E293B),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF667eea),
      unselectedItemColor: Color(0xFF64748B),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF667eea),
      foregroundColor: Colors.white,
      elevation: 8,
    ),
  );

  ThemeData get darkTheme => ThemeData(
    fontFamily: 'MPLUSRounded1c',
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF667eea),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E293B),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'MPLUSRounded1c',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E293B),
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E293B),
      selectedItemColor: Color(0xFF667eea),
      unselectedItemColor: Color(0xFF94A3B8),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF667eea),
      foregroundColor: Colors.white,
      elevation: 8,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Motimate',
      theme: lightTheme,
      // ダークテーマは準備中のため、常にライトテーマを使用
      themeMode: ThemeMode.light,
      routes: {
        '/schedule': (context) => const ScheduleScreen(),
        '/registration': (context) => const UserRegistrationScreen(),
        '/home': (context) => const App(),
        '/notifications': (context) => const NotificationsScreen(),
        '/feedback': (context) => const FeedbackScreen(),
      },
      home: Consumer(
        builder: (context, ref, child) {
          final authState = ref.watch(authStateProvider);
          
          return authState.when(
            loading: () => const Scaffold(
              backgroundColor: Color(0xFFF8FAFC),
              body: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => const AuthScreen(),
            data: (user) {
              if (user == null) {
                return const AuthScreen();
              }
              
              // User is logged in, check if profile is set up
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .snapshots(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      backgroundColor: Color(0xFFF8FAFC),
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  
                  if (userSnapshot.hasError) {
                    return const AuthScreen();
                  }
                  
                  final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
                  final hasProfileSetup = userData?['profileSetup'] == true;
                  
                  if (hasProfileSetup) {
                    return const App(); // Profile is set up, go to app
                  } else {
                    return const UserRegistrationScreen(); // Profile needs setup
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
