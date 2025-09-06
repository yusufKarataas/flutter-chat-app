import 'package:chattingapp/pages/main_menu.dart';
import 'package:chattingapp/pages/register_screen.dart';
import 'package:chattingapp/service/auth_service.dart';
import 'package:chattingapp/widgets/custom_button.dart';
import 'package:chattingapp/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final name = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Tüm alanları doldurun")));
      return;
    }

    final response = await AuthService().login(name, password);

    if (response['error'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Giriş başarısız: ${response['error']}")),
      );
    } else {
      final userId = response['id']; // <- ID burada
      final userName = response['name'];

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Giriş başarılı: $userName")));

      // MainMenu’ye ID gönder
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainMenu(currentUserId: userId)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final _screenWidth = MediaQuery.of(context).size.width;
    final _screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 89, 30, 253),
      body: Center(
        child: Container(
          width: _screenWidth * 0.5,
          height: _screenHeight * 0.65,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(110, 0, 0, 0),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(4, 4),
              ),
            ],
            borderRadius: BorderRadius.circular(20),
            color: const Color.fromARGB(255, 56, 56, 56),
          ),
          padding: EdgeInsets.symmetric(
            vertical: _screenHeight * 0.06,
            horizontal: _screenHeight * 0.05,
          ),
          child: Column(
            children: [
              const Text(
                "Login",
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
              SizedBox(height: _screenHeight * 0.07),
              CustomTextfield(
                obscureText: false,
                hint: "Enter a Username",
                widget: const Icon(Icons.person),
                controller: usernameController,
              ),
              SizedBox(height: _screenHeight * 0.05),
              CustomTextfield(
                obscureText: true,
                hint: "Enter a password",
                widget: const Icon(Icons.remove_red_eye),
                controller: passwordController,
              ),
              SizedBox(height: _screenHeight * 0.04),
              CustomButton(text: "Login", onTap: _handleLogin),
              SizedBox(height: _screenHeight * 0.03),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text(
                  "Don't have an account?",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
