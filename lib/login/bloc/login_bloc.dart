import 'dart:async';

import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:musicbets/network/LoginRepository.dart';

import 'package:musicbets/authentication/authentication.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepository loginRepository;
  final AuthenticationBloc authenticationBloc;

  LoginBloc({
    @required this.loginRepository,
    @required this.authenticationBloc,
  })  : assert(loginRepository != null),
        assert(authenticationBloc != null);

  @override
  LoginState get initialState => LoginInitial();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginButtonPressed) {
      yield LoginLoading();

      try {
        final user = await loginRepository.signInWithCredentials(event.username, event.password);

        authenticationBloc.add(LoggedIn(token: user.uid));
        yield LoginInitial();
      } catch (error) {
        yield LoginFailure(error: error.toString());
      }
    } else if (event is LoginWithGooglePressed) {
      yield LoginLoading();
      try {
        final user = await loginRepository.signInWithGoogle();

        authenticationBloc.add(LoggedIn(token: user.uid));
        yield LoginInitial();
      } catch (error) {
        yield LoginFailure(error: error.toString());
      }
    }
  }
}
