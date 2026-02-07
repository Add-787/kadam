import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/auth_repository.dart';
import 'sign_up_event.dart';
import 'sign_up_state.dart';

@injectable
class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final AuthRepository _authRepository;

  SignUpBloc(this._authRepository) : super(const SignUpState()) {
    on<SignUpUsernameChanged>(_onUsernameChanged);
    on<SignUpEmailChanged>(_onEmailChanged);
    on<SignUpPasswordChanged>(_onPasswordChanged);
    on<SignUpConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<SignUpSubmitted>(_onSubmitted);
    on<SignUpGooglePressed>(_onGooglePressed);
    on<SignUpApplePressed>(_onApplePressed);
  }

  void _onUsernameChanged(
    SignUpUsernameChanged event,
    Emitter<SignUpState> emit,
  ) {
    emit(
      state.copyWith(username: event.username, status: SignUpStatus.initial),
    );
  }

  void _onEmailChanged(SignUpEmailChanged event, Emitter<SignUpState> emit) {
    emit(state.copyWith(email: event.email, status: SignUpStatus.initial));
  }

  void _onPasswordChanged(
    SignUpPasswordChanged event,
    Emitter<SignUpState> emit,
  ) {
    emit(
      state.copyWith(password: event.password, status: SignUpStatus.initial),
    );
  }

  void _onConfirmPasswordChanged(
    SignUpConfirmPasswordChanged event,
    Emitter<SignUpState> emit,
  ) {
    emit(
      state.copyWith(
        confirmPassword: event.confirmPassword,
        status: SignUpStatus.initial,
      ),
    );
  }

  Future<void> _onSubmitted(
    SignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    if (state.status == SignUpStatus.loading) return;

    emit(state.copyWith(status: SignUpStatus.loading));

    try {
      if (state.username.isEmpty ||
          state.email.isEmpty ||
          state.password.isEmpty ||
          state.confirmPassword.isEmpty) {
        emit(
          state.copyWith(
            status: SignUpStatus.failure,
            errorMessage: 'All fields are required',
          ),
        );
        return;
      }

      if (state.password != state.confirmPassword) {
        emit(
          state.copyWith(
            status: SignUpStatus.failure,
            errorMessage: 'Passwords do not match',
          ),
        );
        return;
      }

      final credential = await _authRepository.signUpWithEmail(
          state.email, state.password);
      
      // Attempt to update display name if user is created
      if (credential.user != null && state.username.isNotEmpty) {
        try {
           await credential.user!.updateDisplayName(state.username);
        } catch (_) {
          // Ignore display name update failures for now
        }
      }

      emit(state.copyWith(status: SignUpStatus.success));
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          status: SignUpStatus.failure,
          errorMessage: e.message ?? 'Sign up failed',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SignUpStatus.failure,
          errorMessage: 'Sign up failed. Please try again.',
        ),
      );
    }
  }

  Future<void> _onGooglePressed(
    SignUpGooglePressed event,
    Emitter<SignUpState> emit,
  ) async {
    emit(state.copyWith(status: SignUpStatus.loading));
    try {
      await _authRepository.signInWithGoogle();
      emit(state.copyWith(status: SignUpStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: SignUpStatus.failure,
          errorMessage: "Google Sign Up Failed",
        ),
      );
    }
  }

  Future<void> _onApplePressed(
    SignUpApplePressed event,
    Emitter<SignUpState> emit,
  ) async {
    // Todo: Implement Apple Sign In
    emit(state.copyWith(status: SignUpStatus.loading));
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(state.copyWith(status: SignUpStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: SignUpStatus.failure,
          errorMessage: "Apple Sign Up Failed",
        ),
      );
    }
  }
}
