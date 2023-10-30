import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  bool _signInLoading = false;
  bool _signUpLoading = false;
  bool _googleSignInLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // sign up functionality
  // supabase.auth.signup(email, pass)

  void _onSignUp() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid != true) {
      return;
    }
    setState(() {
      _signUpLoading = true;
    });
    try {
      await supabase.auth.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Success! Confirmation Email Sent '),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _signUpLoading = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sign up Failed"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _signUpLoading = false;
      });
    }
  }

  // sign in functionality
  // supabase.auth.signin(email, pass)

  void _onSignIn() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid != true) {
      return;
    }
    setState(() {
      _signInLoading = true;
    });
    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sign in Failed"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _signInLoading = false;
      });
    }
  }

  void _onGoogleSignIn() async {
    setState(() {
      _googleSignInLoading = true;
    });

    try {
      await supabase.auth.signInWithOAuth(Provider.google,
          redirectTo: kIsWeb ? null : 'io.superbase.kazanaapp://login-callback');
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sign up Failed"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.network(
                    "https://seeklogo.com/images/S/supabase-logo-DCC676FFE2-seeklogo.com.png",
                    height: 150,
                  ),
                  // email form
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Field is required';
                      }
                      return null;
                    },
                  ),
                  // password form
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                    controller: _passwordController,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _signInLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _onSignIn,
                          child: const Text('Sign in'),
                        ),
                  _signUpLoading
                      ? const CircularProgressIndicator()
                      : OutlinedButton(
                          onPressed: _onSignUp,
                          child: const Text('Sign up'),
                        ),

                  const Row(
                    children: [
                      Expanded(
                        child: Divider(),
                      ),
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: Text('OR'),
                      ),
                      Expanded(
                        child: Divider(),
                      ),
                    ],
                  ),
                  _googleSignInLoading
                      ? const CircularProgressIndicator()
                      : OutlinedButton.icon(
                          onPressed: _onGoogleSignIn,
                          icon: Image.network(
                            "https://www.freepnglogos.com/uploads/google-logo-png/google-logo-png-webinar-optimizing-for-success-google-business-webinar-13.png",
                            height: 30,
                          ),
                          label: const Text('Continue with Google'),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
