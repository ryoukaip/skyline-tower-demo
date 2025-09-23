import 'package:flutter/material.dart';
import 'package:skyline_tower2/layouts/main_layout.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true; // Add this line for password visibility state
  final pb = PocketBase('http://192.168.1.4:8090');

  void _login() {
    String username = usernameController.text;
    String password = passwordController.text;

    if (username == "sample" && password == "1234") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainLayout()),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid credentials')));
    }
  }

  Future<void> _login1() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    // Temporary simple login - to be removed
    if (username == "sample" && password == "1234") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainLayout()),
      );
      return;
    }

    try {
      // Attempt auth (assuming "users" collection exists in PocketBase)
      final authData = await pb
          .collection("users")
          .authWithPassword(username, password);

      // Check success
      if (pb.authStore.isValid) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainLayout()),
        );
      } else {
        _showError("Login failed.");
      }
    } catch (e) {
      _showError("Invalid credentials or server error.");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _loginGoogle() async {
    try {
      // OAuth2 login with Google
      final authData = await pb.collection("users").authWithOAuth2("google", (
        url,
      ) async {
        // Open the browser to let the user log in with Google
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          throw Exception("Could not launch $url");
        }
      });

      if (pb.authStore.isValid) {
        // Navigate to main layout after success
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainLayout()),
        );
      } else {
        _showError("Google login failed.");
      }
    } catch (e) {
      _showError("Google login error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset('assets/logo.png', height: 100),
                const SizedBox(height: 10),
                Text("Skyline Tower", style: TextStyle(fontSize: 20)),
                const SizedBox(height: 40),

                // Username or Phone Number
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Phone number or username',
                    border: OutlineInputBorder(),
                    // prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Handle forgot password
                    },
                    child: Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 20),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _login1,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Login', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),

                // Login google
                // To be added
              ],
            ),
          ),
        ),
      ),
    );
  }
}
