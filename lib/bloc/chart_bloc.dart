import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'chart_event.dart';
part 'chart_state.dart';

class ChartBloc extends Bloc<ChartEvent, ChartState> {
  @override
  ChartState get initialState => ChartInitial();

  @override
  Stream<ChartState> mapEventToState(ChartEvent event) async* {
    // TODO: implement mapEventToState
  }
}
