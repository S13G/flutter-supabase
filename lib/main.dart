import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pabase/pages/homepage.dart';
import 'package:pabase/pages/startpage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // load env
  await dotenv.load();

  // initialize supabase
  String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  String supabasekey = dotenv.env['SUPABASE_KEY'] ?? '';

  await Supabase.initialize(url: supabaseUrl, anonKey: supabasekey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Supabase',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  User? _user;

  @override
  void initState() {
      _getAuth();
      super.initState();
  }

  // to get current user: supabase.auth.currentUser
  // or use the session function to get the user from the session

  Future<void> _getAuth() async {
    setState(() {
      _user = supabase.auth.currentUser;
    });

    supabase.auth.onAuthStateChange.listen((event) {
      setState(() {
        _user = event.session?.user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _user == null ? const StartPage() : const HomePage();
  }
}
