import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WidgetCubit extends Cubit<dynamic> {
  WidgetCubit() : super({-1: Container()});

  void toIndex(int index) {
    emit(index);
  }

  void navigate(int index, Widget child) {
    emit({index: child});
  }
}
