import 'package:equatable/equatable.dart';

final class ChatTurn extends Equatable {
  const ChatTurn({
    required this.text,
    required this.fromUser,
    required this.at,
  });

  final String text;
  final bool fromUser;
  final DateTime at;

  @override
  List<Object?> get props => <Object?>[text, fromUser, at];
}
