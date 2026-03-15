import 'package:structure_mobile/features/user/navigation/user_router.dart';

/// Centralized route names for the application
class AppRouter {
  // Splash and welcome routes
  static const String splash = '/';
  static const String welcome = '/welcome';
  
  // Auth routes
  static const String login = '/login';
  static const String adminLogin = '$login/admin';
  static const String superAdminLogin = '$login/superadmin';
  
  // User routes (imported from UserRouter)
  static const String home = UserRouter.home;
  static const String structureDetail = UserRouter.structureDetail;
  static const String payment = UserRouter.payment;
  static const String paymentSuccess = UserRouter.paymentSuccess;
  
  // Admin routes
  static const String adminHome = '/admin';
  static const String adminStructures = '/admin/structures';
  static const String adminUsers = '/admin/users';
  
  // Other routes
  static const String profile = '/profile';
  static const String settings = '/settings';
  
  // Helper method to get route parameters
  static Map<String, String> getPathParameters(Uri uri) {
    final params = <String, String>{};
    final segments = uri.pathSegments;
    
    for (int i = 0; i < segments.length - 1; i++) {
      if (segments[i].startsWith(':')) {
        final key = segments[i].substring(1);
        params[key] = segments[i + 1];
      }
    }
    
    return params;
  }
}
