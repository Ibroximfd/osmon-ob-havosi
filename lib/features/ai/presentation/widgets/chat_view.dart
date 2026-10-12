import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/sky/sky_palette.dart';
import '../../../../core/theme/osmon_colors.dart';
import '../../../../core/theme/osmon_motion.dart';
import '../../../../core/theme/osmon_spacing.dart';
import '../../../../core/theme/osmon_typography.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/osmon_chip.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../weather/presentation/bloc/weather_bloc.dart';
import '../../domain/chat_turn.dart';
import '../bloc/chat_bloc.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send([String? text]) {
    final message = (text ?? _input.text).trim();
    if (message.isEmpty) return;
    context.read<ChatBloc>().add(ChatMessageSent(message));
    _input.clear();
  }

  void _scrollToEnd() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.maxScrollExtent,
      duration: OsmonMotion.base,
      curve: OsmonMotion.standard,
    );
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tint = context.select<WeatherBloc, Color>(
      (bloc) => bloc.state.scene.palette.tint,
    );
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<ChatBloc, ChatState>(
          listenWhen: (previous, current) =>
              previous.turns.length != current.turns.length ||
              previous.isReplying != current.isReplying,
          listener: (context, state) => _scrollToEnd(),
          builder: (context, state) {
            if (!state.isConfigured) {
              return Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: OsmonSpace.gutter,
                    ),
                    child: ScreenHeader(title: l10n.chatTitle, showBack: true),
                  ),
                  Expanded(
                    child: Center(
                      child: MessageStateView(
                        icon: LucideIcons.sparkles,
                        title: l10n.stateNotConfiguredTitle,
                        message: l10n.stateNotConfiguredMessage,
                      ),
                    ),
                  ),
                ],
              );
            }
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: OsmonSpace.gutter,
                  ),
                  child: ScreenHeader(
                    title: l10n.chatTitle,
                    subtitle: l10n.chatSubtitle,
                    showBack: true,
                  ),
                ),
                Expanded(
                  child: state.isEmpty
                      ? _Suggestions(onPick: _send, tint: tint)
                      : ListView.separated(
                          controller: _scroll,
                          padding: const EdgeInsets.all(OsmonSpace.gutter),
                          itemCount:
                              state.turns.length +
                              (state.isReplying || state.failure != null
                                  ? 1
                                  : 0),
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: OsmonSpace.s10),
                          itemBuilder: (context, i) {
                            if (i < state.turns.length) {
                              return _Bubble(turn: state.turns[i], tint: tint);
                            }
                            return state.isReplying
                                ? Text(
                                    l10n.chatTyping,
                                    style: OsmonType.caption.copyWith(
                                      color: OsmonColors.textTertiary,
                                    ),
                                  )
                                : _FailedReply(
                                    onRetry: () => context.read<ChatBloc>().add(
                                      const ChatRetried(),
                                    ),
                                  );
                          },
                        ),
                ),
                _Composer(
                  controller: _input,
                  enabled: !state.isReplying,
                  onSend: _send,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.onPick, required this.tint});

  final ValueChanged<String> onPick;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final prompts = <String>[
      l10n.chatSuggest1,
      l10n.chatSuggest2,
      l10n.chatSuggest3,
      l10n.chatSuggest4,
    ];
    return ListView(
      padding: const EdgeInsets.all(OsmonSpace.gutter),
      children: <Widget>[
        MessageStateView(
          icon: LucideIcons.sparkles,
          iconColor: tint,
          title: l10n.chatEmptyTitle,
          message: l10n.chatEmptyMessage,
        ),
        Wrap(
          spacing: OsmonSpace.s8,
          runSpacing: OsmonSpace.s8,
          alignment: WrapAlignment.center,
          children: <Widget>[
            for (final prompt in prompts)
              OsmonChip(
                label: prompt,
                selected: false,
                onTap: () => onPick(prompt),
              ),
          ],
        ),
        const SizedBox(height: OsmonSpace.s24),
        Text(
          l10n.chatDisclaimer,
          textAlign: TextAlign.center,
          style: OsmonType.micro.copyWith(color: OsmonColors.textTertiary),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.turn, required this.tint});

  final ChatTurn turn;
  final Color tint;

  @override
  Widget build(BuildContext context) => Align(
    alignment: turn.fromUser ? Alignment.centerRight : Alignment.centerLeft,
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.8,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: turn.fromUser
              ? tint.withValues(alpha: 0.32)
              : OsmonColors.glassFill,
          border: Border.all(color: OsmonColors.glassStrokeSoft),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(OsmonRadius.lg),
            topRight: const Radius.circular(OsmonRadius.lg),
            bottomLeft: Radius.circular(
              turn.fromUser ? OsmonRadius.lg : OsmonRadius.xs,
            ),
            bottomRight: Radius.circular(
              turn.fromUser ? OsmonRadius.xs : OsmonRadius.lg,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: OsmonSpace.s14,
            vertical: OsmonSpace.s10,
          ),
          child: SelectableText(
            turn.text,
            style: OsmonType.body.copyWith(height: 1.5),
          ),
        ),
      ),
    ),
  );
}

class _FailedReply extends StatelessWidget {
  const _FailedReply({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: <Widget>[
        const Icon(
          LucideIcons.alertCircle,
          size: OsmonSize.iconSm,
          color: OsmonColors.severe,
        ),
        const SizedBox(width: OsmonSpace.s6),
        Text(l10n.chatError, style: OsmonType.caption),
        TextButton(
          onPressed: onRetry,
          style: TextButton.styleFrom(foregroundColor: OsmonColors.accent),
          child: Text(l10n.actionRetry),
        ),
      ],
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        OsmonSpace.gutter,
        OsmonSpace.s8,
        OsmonSpace.gutter,
        OsmonSpace.s12,
      ),
      child: GlassPanel(
        blur: true,
        radius: OsmonRadius.xl,
        padding: const EdgeInsets.only(
          left: OsmonSpace.s16,
          right: OsmonSpace.s4,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: onSend,
                style: OsmonType.body,
                decoration: InputDecoration(
                  hintText: l10n.chatHint,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              tooltip: l10n.chatSend,
              onPressed: enabled ? () => onSend(controller.text) : null,
              icon: const Icon(LucideIcons.send, color: OsmonColors.accent),
            ),
          ],
        ),
      ),
    );
  }
}
