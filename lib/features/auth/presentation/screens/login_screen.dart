import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isRegisterMode = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Preencha todos os campos');
      return;
    }

    if (_isRegisterMode && name.isEmpty) {
      setState(() => _errorMessage = 'Informe seu nome');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final viewModel = InjectionContainer.instance.authViewModel;

    final result = _isRegisterMode
        ? await viewModel.register(name, email, password)
        : await viewModel.login(email, password);

    if (!mounted) return;

    result.when(
      onSuccess: (_) => context.go('/inicio'),
      onFailure: (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = failure.message;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.green, AppColors.greenDeep],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.emoji_events_rounded,
                    color: AppColors.gold, size: 38),
              ),
              const SizedBox(height: 24),
              Text(
                _isRegisterMode ? 'Criar conta' : 'Entrar',
                style: AppTextStyles.sora(
                    fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'PiramidGame · IFPR Paranaguá',
                style: AppTextStyles.jakarta(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(height: 32),

              if (_isRegisterMode) ...[
                _InputField(
                  controller: _nameController,
                  placeholder: 'Seu nome',
                  icon: Icons.person_rounded,
                ),
                const SizedBox(height: 12),
              ],

              _InputField(
                controller: _emailController,
                placeholder: 'Email',
                icon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              _InputField(
                controller: _passwordController,
                placeholder: 'Senha',
                icon: Icons.lock_rounded,
                obscureText: true,
              ),
              const SizedBox(height: 12),

              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.red.withOpacity(.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: AppTextStyles.jakarta(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.red,
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isRegisterMode ? 'Criar conta' : 'Entrar',
                          style: AppTextStyles.jakarta(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isRegisterMode = !_isRegisterMode;
                      _errorMessage = null;
                    });
                  },
                  child: Text(
                    _isRegisterMode
                        ? 'Já tem conta? Entrar'
                        : 'Não tem conta? Criar',
                    style: AppTextStyles.jakarta(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withOpacity(.7),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;

  const _InputField({
    required this.controller,
    required this.placeholder,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: AppTextStyles.jakarta(fontSize: 15, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: placeholder,
        prefixIcon: Icon(icon, color: AppColors.green, size: 20),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: theme.dividerColor, width: 1.5),
        ),
      ),
    );
  }
}