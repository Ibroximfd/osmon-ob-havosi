part of 'chat_bloc.dart';

final class ChatState extends Equatable {
  const ChatState({
    required this.isConfigured,
    this.turns = const <ChatTurn>[],
    this.isReplying = false,
    this.failure,
    this.forecast,
  });

  final bool isConfigured;
  final List<ChatTurn> turns;
  final bool isReplying;

  /// The last reply's failure; cleared by the next send.
  final DataFailure? failure;
  final Forecast? forecast;

  bool get isEmpty => turns.isEmpty;

  ChatState copyWith({
    List<ChatTurn>? turns,
    bool? isReplying,
    DataFailure? failure,
    Forecast? forecast,
  }) => ChatState(
    isConfigured: isConfigured,
    turns: turns ?? this.turns,
    isReplying: isReplying ?? this.isReplying,
    failure: failure,
    forecast: forecast ?? this.forecast,
  );

  @override
  List<Object?> get props => <Object?>[
    isConfigured,
    turns,
    isReplying,
    failure,
    forecast,
  ];
}
