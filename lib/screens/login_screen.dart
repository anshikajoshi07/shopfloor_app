import 'package:flutter/material.dart';
import '../models/user_session.dart';
import '../services/session_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  String _role = 'Operator';

  Future<void> _login() async {
    final jwt = 'mock-jwt-${DateTime.now().millisecondsSinceEpoch}';
    final session = UserSession(
      email: _emailController.text.isEmpty
          ? 'test@mail.com'
          : _emailController.text,
      role: _role,
      tenantId: 'tenant_001',
      mockJwt: jwt,
    );

    // persist session
    await SessionService.saveSession(session);
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardScreen(session: session),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            elevation: 1,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.factory, size: 48, color: Colors.blueAccent),
                  const SizedBox(height: 8),
                  const Text('Shop Floor Lite', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
                  const SizedBox(height: 12),

                  TextField(
                    key: const Key('login-email-field'),
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'you@company.com',
                      prefixIcon: const Icon(Icons.email),
                      suffixIcon: _emailController.text.isNotEmpty
                          ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _emailController.clear()))
                          : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300, width: 1)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300, width: 1)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.blue.shade200, width: 1.2)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 12),

                  const Text('Role', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          key: const Key('role-operator'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: _role == 'Operator' ? Colors.blue.shade200 : Colors.grey.shade300),
                            backgroundColor: _role == 'Operator' ? Colors.blue.shade50 : Colors.transparent,
                            foregroundColor: _role == 'Operator' ? Colors.blue : Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => setState(() => _role = 'Operator'),
                          child: const Text('Operator'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          key: const Key('role-supervisor'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: _role == 'Supervisor' ? Colors.blue.shade200 : Colors.grey.shade300),
                            backgroundColor: _role == 'Supervisor' ? Colors.blue.shade50 : Colors.transparent,
                            foregroundColor: _role == 'Supervisor' ? Colors.blue : Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => setState(() => _role = 'Supervisor'),
                          child: const Text('Supervisor'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      key: const Key('login-button'),
                      style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.blue.shade200), backgroundColor: Colors.blue.shade50, foregroundColor: Colors.blue),
                      onPressed: _login,
                      child: const Text('Login'),
                    ),
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
