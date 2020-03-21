part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
  @override
  List<Object> get props => [];
}

class LoginWithGooglePressed extends LoginEvent {}

class LoginButtonPressed extends LoginEvent {
  final String username;
  final String password;

  const LoginButtonPressed({
    @required this.username,
    @required this.password,
  });

  @override
  List<Object> get props => [username, password];

  @override
  String toString() =>
      'LoginButtonPressed { username: $username, password: $password }';
}
