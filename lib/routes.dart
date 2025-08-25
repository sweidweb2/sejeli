import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'pages/register.dart';
import 'pages/main_user.dart';
import 'pages/leadboards.dart';
import 'pages/remove_individuals.dart';

class GenerateRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/register':
        return MaterialPageRoute(builder: (context) => const RegisterPage());
      case '/home':
        return MaterialPageRoute(builder: (context) => const MainUserPage());
      case '/leaderboards':
        return MaterialPageRoute(builder: (context) => const LeaderboardsPage());
      case '/manage_individuals':
        return MaterialPageRoute(builder: (context) => const ManageIndividualsPage());
      case '/login':
        return MaterialPageRoute(builder: (context) => const LoginPage());
      default:
        // Default route - this should not be reached with AuthWrapper
        return MaterialPageRoute(builder: (context) => const LoginPage());
    }
  }
}
