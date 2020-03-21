import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/login_bloc.dart';

import 'package:musicbets/ui/GoogleLoginButton.dart';
import 'package:musicbets/ui/validators.dart';

class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _onLoginButtonPressed() {
      BlocProvider.of<LoginBloc>(context).add(
        LoginButtonPressed(
          username: _usernameController.text,
          password: _passwordController.text,
        ),
      );
    }

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return Padding(
              padding: EdgeInsets.all(20.0),
              child: Form(
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.email),
                        labelText: 'Email',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autovalidate: true,
                      autocorrect: false,
                      controller: _usernameController,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.lock),
                        labelText: 'Password',
                      ),
                      obscureText: true,
                      autovalidate: true,
                      autocorrect: false,
                      controller: _passwordController,
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              RaisedButton(
                                onPressed: state is! LoginLoading
                                    ? _onLoginButtonPressed
                                    : null,
                                child: Text('Login'),
                              ),
                              GoogleLoginButton(),
                              Container(
                                child: state is LoginLoading
                                    ? CircularProgressIndicator()
                                    : null,
                              ),
                            ]))
                  ],
                ),
              ));
        },
      ),
    );
  }
}
