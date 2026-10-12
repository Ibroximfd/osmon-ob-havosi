import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/place_time.dart';
import '../../../../core/error/data_failure.dart';
import '../../../settings/domain/settings_repository.dart';
import '../../../weather/domain/entities/forecast.dart';
import '../../domain/ai_repository.dart';
import '../../domain/chat_turn.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc(this._ai, this._settings, {Clock clock = systemClock})
    : _clock = clock,
      super(ChatState(isConfigured: _ai.isConfigured)) {
    on<ChatStarted>(
      (event, emit) => emit(state.copyWith(forecast: event.forecast)),
    );
    on<ChatMessageSent>(_onMessageSent, transformer: droppable());
    on<ChatRetried>(_onRetried, transformer: droppable());
  }

  final AiRepository _ai;
  final SettingsRepository _settings;
  final Clock _clock;

  Future<void> _onMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty) return;
    final turns = <ChatTurn>[
      ...state.turns,
      ChatTurn(text: text, fromUser: true, at: _clock()),
    ];
    await _ask(turns, emit);
  }

  Future<void> _onRetried(ChatRetried event, Emitter<ChatState> emit) =>
      _ask(state.turns, emit);

  Future<void> _ask(List<ChatTurn> turns, Emitter<ChatState> emit) async {
    emit(state.copyWith(turns: turns, isReplying: true));
    final result = await _ai.reply(
      turns,
      languageCode: _settings.current.languageCode ?? 'uz',
      forecast: state.forecast,
    );
    result.fold(
      (failure) => emit(state.copyWith(isReplying: false, failure: failure)),
      (reply) => emit(
        state.copyWith(
          isReplying: false,
          turns: <ChatTurn>[
            ...turns,
            ChatTurn(text: reply, fromUser: false, at: _clock()),
          ],
        ),
      ),
    );
  }
}
