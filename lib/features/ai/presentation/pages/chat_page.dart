import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injector.dart';
import '../../../weather/presentation/bloc/weather_bloc.dart';
import '../bloc/chat_bloc.dart';
import '../widgets/chat_view.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<ChatBloc>(
    create: (_) =>
        sl<ChatBloc>()
          ..add(ChatStarted(context.read<WeatherBloc>().state.forecast)),
    child: const ChatView(),
  );
}
