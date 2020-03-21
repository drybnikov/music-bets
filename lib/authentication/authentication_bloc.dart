import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:musicbets/network/LoginRepository.dart';

import 'authentication.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final LoginRepository loginRepository;

  AuthenticationBloc({@required this.loginRepository})
      : assert(loginRepository != null);

  @override
  AuthenticationState get initialState => AuthenticationUninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationEvent event) async* {
    if (event is AppStarted) {
      yield* _mapAppStartedToState();
    }

    if (event is LoggedIn) {
      yield AuthenticationLoading();
      await loginRepository.persistToken(event.token);

      yield AuthenticationAuthenticated(token: event.token);
    }

    if (event is LoggedOut) {
      yield AuthenticationLoading();
      await loginRepository.signOut();
      yield AuthenticationUnauthenticated();
    }
  }

  Stream<AuthenticationState> _mapAppStartedToState() async* {
    try {
      final String token = await loginRepository.getToken();
      if (token != null) {
        yield AuthenticationAuthenticated(token: token);
      } else {
        yield AuthenticationUnauthenticated();
      }
    } catch (_) {
      yield AuthenticationUnauthenticated();
    }
  }
}
