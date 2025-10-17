import 'package:flutter/material.dart';
import 'package:skyline_tower2/layouts/main_layout.dart';
import 'package:skyline_tower2/components/pocketbase_service.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final PocketBaseService _pbService = PocketBaseService();

  Future<void> _login() async {
    setState(() => _isLoading = true);

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
      await _pbService.login(username, password);

      if (_pbService.isLoggedIn) {
        await _pbService.debugPrintNews();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainLayout()),
          );
        }
      } else {
        _showError("Login failed.");
      }
    } catch (e) {
      _showError("Invalid credentials or server error.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginGoogle() async {
    try {
      await _pbService.loginWithGoogle((url) async {
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          throw Exception("Could not launch $url");
        }
      });

      if (_pbService.isLoggedIn) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainLayout()),
          );
        }
      } else {
        _showError("Google login failed.");
      }
    } catch (e) {
      _showError("Google login error: $e");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
                const Text("Skyline Tower", style: TextStyle(fontSize: 20)),
                const SizedBox(height: 40),

                // Username or Phone Number
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Phone number or username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
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
                      // TODO: Handle forgot password
                    },
                    child: const Text('Forgot Password?'),
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
                    onPressed: _login,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                'Login',
                                style: TextStyle(fontSize: 16),
                              ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Google Login Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _loginGoogle,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Login with Google'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
