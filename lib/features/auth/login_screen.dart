import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:structure_mobile/core/routes/app_router.dart';
import 'package:structure_mobile/core/providers/auth_provider.dart';
import 'package:structure_mobile/themes/app_theme.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  final bool isAdmin;
  final bool isSuperAdmin;

  const LoginScreen({
    super.key,
    this.onLoginSuccess,
    this.isAdmin = false,
    this.isSuperAdmin = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Redirection après connexion selon le rôle
  void _handleLoginSuccess() {
    if (widget.onLoginSuccess != null) {
      widget.onLoginSuccess!();
      return;
    }
    if (!context.mounted) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    debugPrint('Connecté: ${auth.user?.email} | Rôle: ${auth.user?.role}');

    if (auth.isSuperAdmin || auth.isAdmin) {
      context.go(AppRouter.adminHome);
    } else {
      context.go(AppRouter.home);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().login(
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (mounted) _handleLoginSuccess();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // Pré-remplissage dev
    if (widget.isSuperAdmin) {
      _emailController.text = 'superadmin@example.com';
      _passwordController.text = 'password';
    } else if (widget.isAdmin) {
      _emailController.text = 'admin1@structureA.com';
      _passwordController.text = 'password';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isSuperAdmin
        ? 'Connexion Super Admin'
        : widget.isAdmin
            ? 'Connexion Admin'
            : 'Connexion';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRouter.welcome),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withAlpha(26),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.isSuperAdmin
                            ? Icons.admin_panel_settings
                            : widget.isAdmin
                                ? Icons.manage_accounts
                                : Icons.account_circle,
                        size: 60,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Connectez-vous pour accéder à votre espace',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Adresse email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Entrez votre email';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(v)) return 'Email invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Entrez votre mot de passe';
                    if (v.length < 6) return 'Minimum 6 caractères';
                    return null;
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Mot de passe oublié ?'),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Se connecter'),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
