import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  bool isLogin = true;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      isLogin = !isLogin;
      _fadeController.reset();
      _slideController.reset();
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFED8B00).withOpacity(0.95),
              const Color(0xFFE67E22).withOpacity(0.90),
              const Color(0xFF1a1a1a),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeController,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
                  ),
                  child: Column(
                    children: [
                      // LOGO & BRANDING
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.visibility_outlined,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Burnham Eye',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isLogin ? 'Welcome Back' : 'Join Our Platform',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // FORM CONTAINER (GLASSMORPHISM - FIXED FOR WEB)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: isLogin ? _loginForm() : _registerForm(),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // TOGGLE BUTTON
                      Text(
                        isLogin ? "Don't have an account?" : "Already have an account?",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _toggleMode,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Text(
                            isLogin ? 'Create Account' : 'Login',
                            style: const TextStyle(
                              color: Color(0xFFED8B00),
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginForm() {
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Form(
      key: formKey,
      child: Column(
        children: [
          _modernTextField(
            label: 'Email Address',
            hint: 'your@email.com',
            icon: Icons.mail_outline,
            controller: emailCtrl,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Email is required';
              if (!value!.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 18),
          _modernTextField(
            label: 'Password',
            hint: '••••••••',
            icon: Icons.lock_outline,
            controller: passwordCtrl,
            obscure: true,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Password is required';
              if ((value?.length ?? 0) < 6) return 'Min 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 32),
          _modernButton(
            label: 'Login',
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _registerForm() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Form(
      key: formKey,
      child: Column(
        children: [
          _modernTextField(
            label: 'Full Name',
            hint: 'John Doe',
            icon: Icons.person_outline,
            controller: nameCtrl,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Name is required';
              return null;
            },
          ),
          const SizedBox(height: 18),
          _modernTextField(
            label: 'Email Address',
            hint: 'your@email.com',
            icon: Icons.mail_outline,
            controller: emailCtrl,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Email is required';
              if (!value!.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 18),
          _modernTextField(
            label: 'Password',
            hint: '••••••••',
            icon: Icons.lock_outline,
            controller: passwordCtrl,
            obscure: true,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Password is required';
              if ((value?.length ?? 0) < 6) return 'Min 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 18),
          _modernTextField(
            label: 'Confirm Password',
            hint: '••••••••',
            icon: Icons.lock_outline,
            controller: confirmCtrl,
            obscure: true,
            validator: (value) {
              if (value != passwordCtrl.text) return 'Passwords must match';
              return null;
            },
          ),
          const SizedBox(height: 32),
          _modernButton(
            label: 'Create Account',
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _modernTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7), size: 22),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.6), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }

  Widget _modernButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFED8B00).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFED8B00), Color(0xFFF5A623)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}