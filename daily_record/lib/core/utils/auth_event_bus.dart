import 'dart:async';

abstract class AuthEvent {}

class LogoutEvent extends AuthEvent {}

class AuthEventBus {
  static final StreamController<AuthEvent> _controller =
      StreamController<AuthEvent>.broadcast();

  static Stream<AuthEvent> get stream => _controller.stream;

  static void emit(AuthEvent event) {
    _controller.add(event);
  }

  static void emitLogout() {
    emit(LogoutEvent());
  }

  static void dispose() {
    if (!_controller.isClosed) {
      _controller.close();
    }
  }
}
