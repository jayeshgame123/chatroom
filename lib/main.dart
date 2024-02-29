import 'package:chat_app/Models/Helper/FirebaseHelper.dart';
import 'package:chat_app/Models/UserModel.dart';
import 'package:chat_app/Provider/ReplyProvider.dart';
import 'package:chat_app/Provider/ThemeProvider.dart';
import 'package:chat_app/Screens/HomeScreen.dart';
import 'package:chat_app/Screens/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    UserModel? currentUserModel =
        await FirebaseHelper.getUserModelById(currentUser.uid);
    if (currentUserModel != null) {
      runApp(MyAppLoggedIn(
          userModel: currentUserModel, firebaseUser: currentUser));
    }
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => ReplyProvider()),
        ],
        child: Builder(
          builder: ((context) {
            final themeProvider = Provider.of<ThemeProvider>(context);
            return MaterialApp(
              title: 'Flutter Demo',
              debugShowCheckedModeBanner: false,
              themeMode: themeProvider.themeMode,
              theme: ThemeData(
                brightness: Brightness.light,
                primarySwatch: Colors.blue,
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                appBarTheme: const AppBarTheme(color: Colors.black54),
              ),
              home: const LoginScreen(),
            );
          }),
        ));
  }
}

class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  // MaterialColor mycolor = MaterialColor(0xFF4002A9, <int, Color>{
  //     50: Color(0xFF4002A0),
  //     100: Color(0xFF4002A0),
  //     200: Color(0xFF4002A0),
  //     300: Color(0xFF4002A0),
  //     400: Color(0xFF4002A0),
  //     500: Color(0xFF4002A0),
  //     600: Color(0xFF4002A0),
  //     700: Color(0xFF4002A0),
  //     800: Color(0xFF4002A0),
  //     900: Color(0xFF4002A0),
  //   },
  // );

  MyAppLoggedIn(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => ReplyProvider()),
        ],
        child: Builder(builder: ((context) {
          final themeProvider = Provider.of<ThemeProvider>(context);
          return MaterialApp(
              title: 'Flutter Demo',
              debugShowCheckedModeBanner: false,
              themeMode: themeProvider.themeMode,
              theme: ThemeData(
                brightness: Brightness.light,
                primarySwatch: Colors.blue,
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                appBarTheme: const AppBarTheme(color: Colors.black54),
              ),
              home: HomeScreen(
                userModel: userModel,
                firebaseUser: firebaseUser,
              ));
        })));
  }
}
