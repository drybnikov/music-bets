import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();
  
  @override
  List<Object> get props => [];
}

class AuthenticationUninitialized extends AuthenticationState {}

class AuthenticationAuthenticated extends AuthenticationState {
  final String token;

  const AuthenticationAuthenticated({@required this.token});

  @override
  List<Object> get props => [token];

  @override
  String toString() => 'AuthenticationAuthenticated { token: $token }';
}

class AuthenticationUnauthenticated extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}
