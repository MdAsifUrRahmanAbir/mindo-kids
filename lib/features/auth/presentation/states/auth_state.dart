import 'package:flutter/foundation.dart';

@immutable
class AuthFormState {
  final bool isLoading;
  final String? errorMessage;
  final String? infoMessage;

  const AuthFormState({this.isLoading = false, this.errorMessage, this.infoMessage});

  AuthFormState copyWith({bool? isLoading, String? errorMessage, String? infoMessage}) =>
      AuthFormState(isLoading: isLoading ?? this.isLoading, errorMessage: errorMessage, infoMessage: infoMessage);
}
