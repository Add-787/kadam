import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'sign_in_event.dart';
import 'sign_in_state.dart';

@injectable
class SignInBloc extends Bloc<SignInEvent, SignInState> {
  SignInBloc() : super(const SignInState()) {
    on<SignInEmailChanged>(_onEmailChanged);
    on<SignInPasswordChanged>(_onPasswordChanged);
    on<SignInSubmitted>(_onSubmitted);
    on<SignInGooglePressed>(_onGooglePressed);
    on<SignInApplePressed>(_onApplePressed);
  }

  void _onEmailChanged(SignInEmailChanged event, Emitter<SignInState> emit) {
    emit(state.copyWith(email: event.email, status: SignInStatus.initial));
  }

  void _onPasswordChanged(
    SignInPasswordChanged event,
    Emitter<SignInState> emit,
  ) {
    emit(
      state.copyWith(password: event.password, status: SignInStatus.initial),
    );
  }

  Future<void> _onSubmitted(
    SignInSubmitted event,
    Emitter<SignInState> emit,
  ) async {
    if (state.status == SignInStatus.loading) return;

    emit(state.copyWith(status: SignInStatus.loading));

    // Todo: Integrate with real AuthService
    try {
      if (state.email.isEmpty || state.password.isEmpty) {
        emit(
          state.copyWith(
            status: SignInStatus.failure,
            errorMessage: 'Email and password cannot be empty',
          ),
        );
        return;
      }

      await Future.delayed(const Duration(seconds: 1)); // Mock Network Delay
      emit(state.copyWith(status: SignInStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: SignInStatus.failure,
          errorMessage: 'Sign in failed. Please try again.',
        ),
      );
    }
  }

  Future<void> _onGooglePressed(
    SignInGooglePressed event,
    Emitter<SignInState> emit,
  ) async {
    emit(state.copyWith(status: SignInStatus.loading));
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(state.copyWith(status: SignInStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: SignInStatus.failure,
          errorMessage: "Google Sign In Failed",
        ),
      );
    }
  }

  Future<void> _onApplePressed(
    SignInApplePressed event,
    Emitter<SignInState> emit,
  ) async {
    emit(state.copyWith(status: SignInStatus.loading));
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(state.copyWith(status: SignInStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: SignInStatus.failure,
          errorMessage: "Apple Sign In Failed",
        ),
      );
    }
  }
}
