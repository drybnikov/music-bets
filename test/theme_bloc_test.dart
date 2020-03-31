import 'package:musicbets/bloc/ThemeBloc.dart';
import 'package:test/test.dart';
import 'package:flutter/material.dart';
import 'package:bloc_test/bloc_test.dart';

void main() {
  group('ThemeBloc', () {
    ThemeBloc themeBloc;

    setUp(() {
      themeBloc = ThemeBloc();
    });

    test('initial state is `ThemeData.dark`', () {
      expect(themeBloc.initialState, ThemeData.dark());
    });

    blocTest(
      'emits [dark, dark] when ThemeEvent.toggle is added',
      build: () => themeBloc,
      act: (bloc) => bloc.add(ThemeEvent.toggle),
      expect: [ThemeData.dark(), ThemeData.light()],
    );
  });
}
