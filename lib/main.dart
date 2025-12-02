import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:structure_mobile/core/network/api_service.dart';
import 'package:structure_mobile/core/providers/auth_provider.dart';
import 'package:structure_mobile/core/routes/app_router.dart';
import 'package:structure_mobile/features/auth/login_screen.dart';
import 'package:structure_mobile/features/auth/register_screen.dart';
import 'package:structure_mobile/features/home/screens/welcome_screen.dart';
import 'package:structure_mobile/features/structures/providers/structures_provider.dart';
import 'package:structure_mobile/features/admin/providers/dashboard_provider.dart';
import 'package:structure_mobile/features/admin/screens/admin_dashboard_screen.dart';
import 'package:structure_mobile/features/structures/screens/structure_detail_screen.dart';
import 'package:structure_mobile/features/splash/splash_screen.dart';
import 'package:structure_mobile/features/user/navigation/user_router.dart';
import 'package:structure_mobile/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider()..init(prefs),
        ),
        ChangeNotifierProxyProvider<AuthProvider, StructuresProvider>(
          create: (context) => StructuresProvider(context),
          update: (_, authProvider, structuresProvider) =>
              structuresProvider!..updateAuth(authProvider),
        ),
        ChangeNotifierProvider(create: (context) => DashboardProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Structure Cameroun',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }

  static final GoRouter _router = GoRouter(
    initialLocation: AppRouter.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRouter.splash,
        name: 'splash',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const SplashScreen()),
      ),
      GoRoute(
        path: AppRouter.welcome,
        name: 'welcome',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const WelcomeScreen()),
      ),
      GoRoute(
        path: AppRouter.login,
        name: 'login',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const LoginScreen(
            onLoginSuccess: null,
            isAdmin: false,
            isSuperAdmin: false,
          ),
        ),
      ),
      GoRoute(
        path: '${AppRouter.login}/admin',
        name: 'admin-login',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const LoginScreen(
            onLoginSuccess: null,
            isAdmin: true,
            isSuperAdmin: false,
          ),
        ),
      ),
      GoRoute(
        path: '${AppRouter.login}/superadmin',
        name: 'superadmin-login',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const LoginScreen(
            onLoginSuccess: null,
            isAdmin: true,
            isSuperAdmin: true,
          ),
        ),
      ),
      GoRoute(
        path: AppRouter.adminHome,
        name: 'admin-dashboard',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const AdminDashboardScreen(),
        ),
      ),
      GoRoute(
        path: '${AppRouter.adminStructures}/:structureId',
        name: 'admin-structure-detail',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: StructureDetailScreen(
            structureId: state.pathParameters['structureId'],
          ),
        ),
      ),
      ...UserRouter.routes,
      GoRoute(
        path: '/:pathMatch(.*)*',
        name: 'not-found',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '404',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Page non trouvée',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go(UserRouter.home),
                    child: const Text('Retour à l\'accueil'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Erreur')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Une erreur est survenue'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRouter.home),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    ),
  );
}
