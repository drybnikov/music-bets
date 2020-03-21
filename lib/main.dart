import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/ThemeBloc.dart';
import 'ChartList.dart';
import 'package:musicbets/login/login_page.dart';
import 'package:musicbets/network/LoginRepository.dart';

import 'package:musicbets/authentication/authentication.dart';
import 'package:musicbets/ui/splash_page.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print(error);
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final loginRepository = LoginRepository();

  runApp(BlocProvider<AuthenticationBloc>(
    create: (context) {
      return AuthenticationBloc(loginRepository: loginRepository)
        ..add(AppStarted());
    },
    child: App(loginRepository: loginRepository),
  ));
}

class App extends StatelessWidget {
  final LoginRepository loginRepository;

  App({Key key, @required this.loginRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => ThemeBloc(),
        child: BlocBuilder<ThemeBloc, ThemeData>(builder: (_, theme) {
          return MaterialApp(
            title: 'Music Bets',
            theme: theme,
            home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
              builder: (context, state) {
                if (state is AuthenticationAuthenticated) {
                  return ChartListHome(currentUserId: state.token);
                }
                if (state is AuthenticationUnauthenticated) {
                  return LoginPage(loginRepository: loginRepository);
                }
                // if (state is AuthenticationLoading) {
                //   return LoadingIndicator();
                // }
                return SplashPage();
              },
            ),
            debugShowCheckedModeBanner: false,
          );
        }));
  }
}
