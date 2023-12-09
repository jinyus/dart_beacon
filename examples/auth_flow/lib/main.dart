import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:state_beacon/state_beacon.dart';

typedef User = ({int id, String name});

class AuthController {
  final _user = Beacon.writable<User?>(null);

  ReadableBeacon<User?> get user => _user;

  ReadableBeacon<bool> get loggedIn => Beacon.derived(() => user.value != null);

  void login(User userData) {
    _user.value = userData;
  }

  void logout() {
    _user.value = null;
  }
}

void main() => runApp(App());

// this could be provided by Provider
final _authController = AuthController();

/// The main app.
class App extends StatelessWidget {
  App({super.key});

  static const String title = 'State Beacon GoRouter Example';

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: App.title,
      debugShowCheckedModeBanner: false,
    );
  }

  late final GoRouter _router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
    ],

    // redirect to the login page if the user is not logged in
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = _authController.loggedIn.peek();

      if (!loggedIn) {
        return '/login';
      }

      // if the user is logged in but still on the login page, send them to
      // the home page
      final bool loggingIn = state.matchedLocation == '/login';
      if (loggingIn) {
        return '/';
      }

      // no need to redirect at all
      return null;
    },

    // changes on the listenable will cause the router to refresh it's route
    // every beacon is ValueListenable, so you can use any beacon here
    refreshListenable: _authController.loggedIn,
  );
}

/// The login screen.
class LoginScreen extends StatelessWidget {
  /// Creates a [LoginScreen].
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    _authController.user.observe(context, (prev, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('WELCOME BACK ${next.name}')),
        );
      }
    });
    return Scaffold(
      appBar: AppBar(title: const Text(App.title)),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // context.read<AuthController>().login('test-user');
            _authController.login((id: 1, name: 'test-user'));

            // router will automatically redirect from /login to / using
            // refreshListenable
          },
          style: ElevatedButton.styleFrom(
            textStyle: Theme.of(context).textTheme.headlineLarge,
            minimumSize: const Size(200, 100),
          ),
          child: const Text('Login'),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = _authController.user.watch(context);
    if (user == null) return const SizedBox.shrink();
    return Scaffold(
      appBar: AppBar(
        title: const Text(App.title),
        actions: <Widget>[
          IconButton(
            onPressed: _authController.logout,
            tooltip: 'Logout: ${user?.name}',
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
        child: Text(
          'Welcome back ${user?.name.toUpperCase()}',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
    );
  }
}
