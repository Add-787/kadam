import 'package:equatable/equatable.dart';

enum SignUpStatus { initial, loading, success, failure }

class SignUpState extends Equatable {
  final String username;
  final String email;
  final String password;
  final String confirmPassword;
  final SignUpStatus status;
  final String? errorMessage;

  const SignUpState({
    this.username = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.status = SignUpStatus.initial,
    this.errorMessage,
  });

  SignUpState copyWith({
    String? username,
    String? email,
    String? password,
    String? confirmPassword,
    SignUpStatus? status,
    String? errorMessage,
  }) {
    return SignUpState(
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    username,
    email,
    password,
    confirmPassword,
    status,
    errorMessage,
  ];
}
