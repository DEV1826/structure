import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:structure_mobile/core/routes/app_router.dart';
import 'package:structure_mobile/features/auth/providers/auth_provider.dart';
import 'package:structure_mobile/features/structures/providers/structures_provider.dart';
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

  // Gestion de la navigation après connexion réussie
  void _handleLoginSuccess() {
    if (widget.onLoginSuccess != null) {
      widget.onLoginSuccess!();
      return;
    }

    if (!context.mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Debug log pour vérifier les informations de l'utilisateur
    debugPrint('Utilisateur connecté: ${authProvider.user?.email}');
    debugPrint('Rôle: ${authProvider.user?.role}');
    debugPrint('Structure ID: ${authProvider.user?.structureId}');

    // Redirection en fonction du rôle de l'utilisateur
    if (authProvider.isSuperAdmin) {
      // Super admin : accès complet au dashboard admin
      debugPrint('Redirection Super Admin vers le dashboard');
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.adminHome);
      }
    } else if (authProvider.isAdmin) {
      // Admin standard : accès limité à sa structure
      if (authProvider.user?.structureId != null) {
        final structureId = authProvider.user!.structureId!;
        debugPrint('Redirection Admin vers la structure: $structureId');

        // Vérifier si la structure existe avant la redirection
        final structuresProvider = context.read<StructuresProvider>();
        final structure = structuresProvider.getStructureById(structureId);

        if (structure != null) {
          // Redirection vers le dashboard admin avec filtre sur la structure
          debugPrint(
            'Redirection vers le dashboard avec structureId=$structureId',
          );
          if (context.mounted) {
            Navigator.pushReplacementNamed(
              context,
              '${AppRouter.adminHome}?structureId=$structureId',
            );
          }
        } else {
          // Si la structure n'existe pas, on redirige vers le dashboard avec un message d'erreur
          debugPrint('La structure $structureId n\'existe pas');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'La structure associée à votre compte est introuvable',
              ),
              backgroundColor: Colors.red,
            ),
          );
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, AppRouter.adminHome);
          }
        }
      } else {
        // Si aucune structure n'est associée, on redirige vers le dashboard admin avec un message
        debugPrint('Aucune structure associée à cet admin');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Aucune structure associée à votre compte administrateur',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, AppRouter.adminHome);
        }
      }
    } else {
      // Utilisateur standard : accès à l'accueil public
      debugPrint('Redirection utilisateur standard vers l\'accueil');
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.home);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        isAdmin: widget.isAdmin || widget.isSuperAdmin,
        isSuperAdmin: widget.isSuperAdmin,
      );

      if (mounted) {
        _handleLoginSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Pré-remplir avec les bons identifiants en mode développement
    if (widget.isSuperAdmin) {
      _emailController.text = 'superadmin@example.com';
      _passwordController.text = 'password';
    } else if (widget.isAdmin) {
      // Par défaut, on pré-remplit avec le premier admin
      // L'utilisateur pourra le changer s'il est admin d'une autre structure
      _emailController.text = 'admin1@structureA.com';
      _passwordController.text = 'password';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Suppression de la variable inutilisée
    // final isAdminLogin = widget.isAdmin || widget.isSuperAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
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
                // Logo et titre
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withAlpha(
                          26,
                        ), // Équivalent à 0.1 d'opacité
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_circle,
                        size: 60,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Connexion',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Connectez-vous pour accéder à votre compte',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Champ email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Adresse email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Veuillez entrer un email valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Champ mot de passe
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                final authProvider = Provider.of<AuthProvider>(
                                  context,
                                  listen: false,
                                );

                                await authProvider.login(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                  isAdmin:
                                      widget.isAdmin || widget.isSuperAdmin,
                                  isSuperAdmin: widget.isSuperAdmin,
                                );

                                if (mounted) {
                                  _handleLoginSuccess();
                                }
                              }
                            },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),

                // Lien mot de passe oublié
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implémenter la réinitialisation du mot de passe
                    },
                    child: const Text('Mot de passe oublié ?'),
                  ),
                ),

                const SizedBox(height: 24),

                // Bouton de connexion
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Se connecter'),
                ),

                const SizedBox(height: 24),

                // Lien vers l'inscription

                // Espacement en bas pour éviter que le clavier ne cache les champs
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
