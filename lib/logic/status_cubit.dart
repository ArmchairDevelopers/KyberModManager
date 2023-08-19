import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kyber_mod_manager/main.dart';

class StatusCubit extends Cubit<ApplicationStatus> {
  StatusCubit() : super(ApplicationStatus(initialized: false)) {
    emit(ApplicationStatus(initialized: box.containsKey('setup')));
  }

  void setInitialized(bool initialized) {
    emit(ApplicationStatus(initialized: initialized));
  }
}

class ApplicationStatus {
  final bool initialized;

  ApplicationStatus({required this.initialized});
}
