import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musicbets/bloc/ThemeBloc.dart';
import 'package:musicbets/authentication/authentication.dart';

import 'package:musicbets/chipsInput.dart';

enum ExtraAction { logout, switchTheme, openChipds }

class ExtraActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ExtraAction>(
      key: Key('__extraActionsPopupMenuButton__'),
      tooltip: "Settings",
      onSelected: (action) {
        switch (action) {
          case ExtraAction.logout:
            BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut());
            break;
          case ExtraAction.switchTheme:
            BlocProvider.of<ThemeBloc>(context).add(ThemeEvent.toggle);
            break;
          case ExtraAction.openChipds:
            _openChips(context);
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuItem<ExtraAction>>[
        PopupMenuItem<ExtraAction>(
          key: Key('__openChipds__'),
          value: ExtraAction.openChipds,
          child: Text('Chips demo'),
        ),
        PopupMenuItem<ExtraAction>(
            key: Key('__switchTheme__'),
            value: ExtraAction.switchTheme,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const <Widget>[
                  Icon(Icons.slideshow),
                  Padding(padding: EdgeInsets.only(left: 8.0)),
                  Text("Switch theme")
                ])),
        PopupMenuItem<ExtraAction>(
            key: Key('__logout__'),
            value: ExtraAction.logout,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const <Widget>[
                  Icon(Icons.exit_to_app),
                  Padding(padding: EdgeInsets.only(left: 8.0)),
                  Text("Logout")
                ])),
      ],
    );
  }

  void _openChips(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return ChipsPage();
        },
      ),
    );
  }
}
