import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_form.dart';
import 'package:musicbets/network/LoginRepository.dart';

import 'package:musicbets/authentication/authentication.dart';
import 'bloc/login_bloc.dart';

class LoginPage extends StatelessWidget {
  final LoginRepository loginRepository;

  LoginPage({Key key, @required this.loginRepository})
      : assert(loginRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: BlocProvider(
        create: (context) {
          return LoginBloc(
            authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
            loginRepository: loginRepository,
          );
        },
        child: LoginForm(),
      ),
    );
  }
}