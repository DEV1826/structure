import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:structure_mobile/core/providers/auth_provider.dart';
import 'package:structure_mobile/core/routes/app_router.dart';
import 'package:structure_mobile/themes/app_theme.dart';

/// Écran de démarrage avec animation et vérification initiale
///
/// Cet écran s'affiche au lancement de l'application et effectue les opérations
/// d'initialisation nécessaires avant de rediriger vers l'écran approprié.

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOutBack),
      ),
    );

    _controller.forward();

    // Appeler la méthode asynchrone pour gérer la navigation
    _checkAuthAndNavigate();
  }

  /// Vérifie l'état d'authentification et navigue vers l'écran approprié
  ///
  /// Cette méthode attend que l'animation soit terminée (2 secondes) puis tente
  /// de naviguer vers l'écran d'accueil. En cas d'échec, elle affiche un message
  /// d'erreur et propose de réessayer.
  Future<void> _checkAuthAndNavigate() async {
    try {
      debugPrint('🔵 [Splash] Démarrage de la vérification d\'authentification');
      
      // Attendre que l'animation soit terminée (2 secondes)
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) {
        debugPrint('🟡 [Splash] Widget démonté, annulation de la navigation');
        return;
      }
      
      // Vérifier à nouveau le contexte après le délai
      if (!context.mounted) {
        debugPrint('🟡 [Splash] Contexte non disponible après délai');
        return;
      }
      
      debugPrint('🔵 [Splash] Navigation vers: ${AppRouter.welcome}');
      
      // Utiliser un timeout pour éviter que l'écran reste bloqué
      await _navigateWithTimeout();
      
    } catch (e, stackTrace) {
      debugPrint('🔴 [Splash] Erreur lors de la navigation: $e');
      debugPrint('🔴 [Splash] Stack trace: $stackTrace');
      
      if (mounted) {
        // Afficher un message d'erreur à l'utilisateur
        _showErrorDialog();
      }
    }
  }
  
  /// Tente de naviguer avec un timeout
  Future<void> _navigateWithTimeout() async {
    try {
      // Utiliser un Completer pour gérer le timeout
      final completer = Completer<void>();
      
      // Configurer un timer pour le timeout
      final timer = Timer(const Duration(seconds: 5), () {
        if (!completer.isCompleted) {
          completer.completeError(
            TimeoutException('La navigation a pris trop de temps')
          );
        }
      });
      
      // Vérifier l'état d'authentification
      final authProvider = context.read<AuthProvider>();
      
      // Effectuer la navigation en fonction de l'état d'authentification
      if (mounted) {
        String targetRoute;
        
        if (authProvider.isSuperAdmin) {
          targetRoute = AppRouter.adminHome;
          debugPrint('🟢 [Splash] Redirection Super Admin vers: $targetRoute');
        } else if (authProvider.isAdmin) {
          if (authProvider.user?.structureId != null) {
            targetRoute = '${AppRouter.adminStructures}/${authProvider.user!.structureId}';
            debugPrint('🟢 [Splash] Redirection Admin vers: $targetRoute');
          } else {
            targetRoute = AppRouter.adminHome;
            debugPrint('🟡 [Splash] Admin sans structure, redirection vers: $targetRoute');
          }
        } else if (authProvider.isAuthenticated) {
          targetRoute = AppRouter.home;
          debugPrint('🟢 [Splash] Utilisateur connecté, redirection vers: $targetRoute');
        } else {
          targetRoute = AppRouter.welcome;
          debugPrint('🟢 [Splash] Aucun utilisateur connecté, redirection vers: $targetRoute');
        }
        
        // Effectuer la navigation
        context.go(targetRoute);
        debugPrint('✅ [Splash] Navigation réussie vers: $targetRoute');
        
        // Nettoyage
        timer.cancel();
        completer.complete();
      } else {
        timer.cancel();
        completer.completeError('Widget non monté');
      }
      
      // Attendre que la navigation soit complétée ou que le timeout se déclenche
      await completer.future;
    } on TimeoutException catch (e) {
      debugPrint('🔴 [Splash] Timeout de navigation: $e');
      rethrow;
    } catch (e) {
      debugPrint('🔴 [Splash] Erreur lors de la navigation: $e');
      rethrow;
    }
  }
  
  /// Affiche une boîte de dialogue d'erreur
  void _showErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Erreur de chargement'),
        content: const Text(
          'Impossible de charger l\'application. Vérifiez votre connexion Internet et réessayez.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Réessayer la navigation
              _checkAuthAndNavigate();
            },
            child: const Text('Réessayer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Tenter de quitter l'application
              // Note: Cette fonctionnalité peut ne pas être disponible sur toutes les plateformes
              // et nécessite le package flutter/services
              // SystemNavigator.pop();
            },
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    debugPrint('🟡 [Splash] Disposing SplashScreen');
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo de l'application
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.business,
                        size: 80,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Titre de l'application
                    const Text(
                      'Structure Cameroun',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Sous-titre
                    const Text(
                      'Découvrez les meilleures structures',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 48),
                    // Indicateur de chargement avec texte
                    Column(
                      children: [
                        const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chargement...',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
