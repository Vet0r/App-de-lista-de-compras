import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:shoppinglistapp/consts/app_theme.dart';
import 'package:shoppinglistapp/shopping_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _fbApp = Firebase.initializeApp();
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('pt', 'BR'),
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: _fbApp,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Erro");
          } else if (snapshot.hasData) {
            return MyHomePage(title: 'Flutter Demo Home Page');
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});
  String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return MaterialApp(
            locale: const Locale('pt', 'BR'),
            theme: darkThemeDataCustom,
            home: SignInScreen(
              providers: [
                EmailAuthProvider(),
              ],
            ),
          );
        }
        return ShoppingList();
      },
    );
  }
}

final ThemeData darkThemeDataCustom = _buildDarkTheme();

ThemeData _buildDarkTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(
          const EdgeInsets.all(24),
        ),
        backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
      ),
    ),
  );
}

var darkColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: AppTheme.azul,
  onPrimary: AppTheme.azul1,
  secondary: AppTheme.verde,
  onSecondary: AppTheme.verde1,
  error: Color(0xFF690005),
  onError: Color(0xFF690005),
  background: AppTheme.amarelo,
  onBackground: AppTheme.amarelo,
  surface: AppTheme.verde1,
  onSurface: AppTheme.verde1,
);
