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
import 'package:motimate/providers/theme_provider.dart';
import 'package:motimate/theme/app_theme.dart';
import 'package:dynamic_color/dynamic_color.dart';

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

class MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {
      // システムテーマが変更された時に自動更新
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Motimate',
          theme: AppTheme.getLightTheme(dynamicColorScheme: lightDynamic),
          darkTheme: AppTheme.getDarkTheme(dynamicColorScheme: darkDynamic),
          themeMode: themeMode,
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
                loading: () => Scaffold(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  body: const Center(child: CircularProgressIndicator()),
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
                        return Scaffold(
                          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                          body: const Center(child: CircularProgressIndicator()),
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
      },
    );
  }
}
