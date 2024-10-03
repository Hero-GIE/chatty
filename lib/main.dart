import 'dart:convert';

import 'package:chatty/constant/app_color.dart';
import 'package:chatty/controllers/appwrite_controllers.dart';
import 'package:chatty/controllers/fcm_controllers.dart';
import 'package:chatty/controllers/local_saved_data.dart';
import 'package:chatty/firebase_options.dart';
import 'package:chatty/providers/chat_provider.dart';
import 'package:chatty/providers/user_data_provider.dart';
import 'package:chatty/views/about_page.dart';
import 'package:chatty/views/chat_page.dart';
import 'package:chatty/views/home.dart';
import 'package:chatty/views/login.dart';
import 'package:chatty/views/profile.dart';
import 'package:chatty/views/search_users.dart';
import 'package:chatty/views/splash_screen.dart';
import 'package:chatty/views/update_profile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();

// function to listen to background changes
Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print("Some notification Received in background...");
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    String currentUserId = Provider.of<UserDataProvider>(
            navigatorKey.currentState!.context,
            listen: false)
        .getUserId;
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        updateOnlineStatus(status: true, userId: currentUserId);
        print("app resumed");
        break;
      case AppLifecycleState.inactive:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("app inactive");

        break;
      case AppLifecycleState.paused:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("app paused");

        break;
      case AppLifecycleState.detached:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("app detached");

        break;
      case AppLifecycleState.hidden:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("app hidden");
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addObserver(LifecycleEventHandler());

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // await GetStorage.init();

  await LocalSavedData.init();

  // initialize firebase messaging
  await PushNotifications.init();

  // initialize local notifications
  await PushNotifications.localNotiInit();

  // Listen to background notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  // on background notification tapped
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.notification != null) {
      print("Background Notification Tapped");
      navigatorKey.currentState!.pushNamed("/message", arguments: message);
    }
  });

// to handle foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String payloadData = jsonEncode(message.data);
    print("Got a message in foreground");
    if (message.notification != null) {
      PushNotifications.showSimpleNotification(
          title: message.notification!.title!,
          body: message.notification!.body!,
          payload: payloadData);
    }
  });

  // for handling in terminated state
  final RemoteMessage? message =
      await FirebaseMessaging.instance.getInitialMessage();

  if (message != null) {
    print("Launched from terminated state");
    Future.delayed(Duration(seconds: 1), () {
      navigatorKey.currentState!.pushNamed(
        "/home",
      );
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserDataProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'JustLive .',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.backgroundColor),
          useMaterial3: true,
        ),
        builder: EasyLoading.init(),
        routes: {
          '/': (context) => SplashScreen(),
          '/session': (context) => CheckUserSessions(),
          "/login": (context) => Login(),
          "/home": (context) => HomePage(),
          "/chat": (context) => ChatPage(),
          "/profile": (context) => ProfilePage(),
          "/update": (context) => UpdateProfile(),
          "/search": (context) => SearchUsers(),
          "/about":(context) => AboutPage()
        },
      ),
    );
  }
}

class CheckUserSessions extends StatefulWidget {
  const CheckUserSessions({super.key});

  @override
  State<CheckUserSessions> createState() => _CheckUserSessionsState();
}

class _CheckUserSessionsState extends State<CheckUserSessions> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      Provider.of<UserDataProvider>(context, listen: false)
          .localDatafromLocal();
    });

    checkSessions().then((value) {
      final userName =
          Provider.of<UserDataProvider>(context, listen: false).getUserName;
      print("username :$userName");
      if (value) {
        if (userName != null && userName != "") {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, '/update', (route) => false,
              arguments: {"title": "add"});
        }
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.backgroundColor),
        ),
      ),
    );
  }
}
