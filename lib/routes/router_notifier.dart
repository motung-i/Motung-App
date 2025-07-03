import 'package:flutter/material.dart';
import 'package:motunge/bloc/auth/auth_bloc.dart';
import 'package:motunge/bloc/auth/auth_state.dart';
import 'package:motunge/model/auth/enum/auth_state.dart';

class RouterNotifier extends ChangeNotifier {
  late final AuthBloc _authBloc;
  AuthStatus _authStatus = AuthStatus.loading;

  AuthStatus get authStatus => _authStatus;

  RouterNotifier(this._authBloc) {
    _authBloc.stream.listen((state) {
      final newStatus = _getAuthStatusFromBlocState(state);
      if (newStatus != _authStatus) {
        _authStatus = newStatus;
        notifyListeners();
      }
    });

    // 초기 상태 설정
    _authStatus = _getAuthStatusFromBlocState(_authBloc.state);
  }

  AuthStatus _getAuthStatusFromBlocState(AuthBlocState state) {
    if (state is AuthInitial || state is AuthLoading) {
      return AuthStatus.loading;
    } else if (state is AuthUnauthenticated) {
      return AuthStatus.unauthenticated;
    } else if (state is AuthNeedRegister) {
      return AuthStatus.needRegister;
    } else if (state is AuthAuthenticated) {
      return AuthStatus.authenticated;
    } else {
      return AuthStatus.loading;
    }
  }
}
