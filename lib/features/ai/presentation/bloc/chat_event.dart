part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class ChatStarted extends ChatEvent {
  const ChatStarted(this.forecast);

  final Forecast? forecast;

  @override
  List<Object?> get props => <Object?>[forecast];
}

final class ChatMessageSent extends ChatEvent {
  const ChatMessageSent(this.text);

  final String text;

  @override
  List<Object?> get props => <Object?>[text];
}

/// Resends the conversation after a failed reply.
final class ChatRetried extends ChatEvent {
  const ChatRetried();
}
