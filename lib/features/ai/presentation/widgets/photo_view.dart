import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/error/data_failure.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/platform/external_flow.dart';
import '../../../../core/sky/sky_palette.dart';
import '../../../../core/theme/osmon_colors.dart';
import '../../../../core/theme/osmon_spacing.dart';
import '../../../../core/theme/osmon_typography.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/osmon_button.dart';
import '../../../../core/widgets/osmon_chip.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/sky_scroll_view.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../weather/presentation/bloc/weather_bloc.dart';
import '../bloc/photo_bloc.dart';

class PhotoView extends StatelessWidget {
  const PhotoView({super.key});

  /// Large enough for the model, small enough to upload quickly.
  static const double _maxSide = 1600;
  static const int _quality = 85;

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final bloc = context.read<PhotoBloc>();
    final file = await ExternalFlow.run(
      () => ImagePicker().pickImage(
        source: source,
        maxWidth: _maxSide,
        maxHeight: _maxSide,
        imageQuality: _quality,
      ),
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    bloc.add(PhotoPicked(bytes, file.mimeType ?? _mimeOf(file.name)));
  }

  static String _mimeOf(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tint = context.select<WeatherBloc, Color>(
      (bloc) => bloc.state.scene.palette.tint,
    );
    return Scaffold(
      body: BlocConsumer<PhotoBloc, PhotoState>(
        listenWhen: (previous, current) =>
            previous.savedNotice != current.savedNotice ||
            (current.failure != null && previous.failure != current.failure),
        listener: (context, state) {
          final message = state.failure == null
              ? l10n.photoSaved
              : state.failure is PermissionFailure
              ? l10n.photoPermissionDenied
              : state.failure is QuotaFailure
              ? l10n.stateQuotaMessage
              : l10n.stateErrorMessage;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
        builder: (context, state) {
          final bloc = context.read<PhotoBloc>();
          return SkyScrollView(
            clearNavBar: false,
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: ScreenHeader(
                  title: l10n.photoTitle,
                  subtitle: l10n.photoSubtitle,
                  showBack: true,
                ),
              ),
              SliverToBoxAdapter(
                child: !state.isConfigured
                    ? MessageStateView(
                        icon: LucideIcons.sparkles,
                        title: l10n.stateNotConfiguredTitle,
                        message: l10n.stateNotConfiguredMessage,
                      )
                    : !state.hasPhoto
                    ? _PickPrompt(
                        onCamera: () => _pick(context, ImageSource.camera),
                        onGallery: () => _pick(context, ImageSource.gallery),
                      )
                    : _PhotoWorkspace(
                        state: state,
                        tint: tint,
                        onAnalyse: () =>
                            bloc.add(const PhotoAnalysisRequested()),
                        onRestyle: (style) =>
                            bloc.add(PhotoRestyleRequested(style)),
                        onSave: () => bloc.add(const PhotoSaveRequested()),
                        onReset: () => bloc.add(const PhotoCleared()),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PickPrompt extends StatelessWidget {
  const _PickPrompt({required this.onCamera, required this.onGallery});

  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: OsmonSpace.s24),
      child: GlassPanel(
        padding: const EdgeInsets.all(OsmonSpace.s20),
        child: Column(
          children: <Widget>[
            MessageStateView(
              icon: LucideIcons.image,
              title: l10n.photoEmptyTitle,
              message: l10n.photoEmptyMessage,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: OsmonButton(
                    label: l10n.photoCamera,
                    icon: LucideIcons.camera,
                    expand: true,
                    onPressed: onCamera,
                  ),
                ),
                const SizedBox(width: OsmonSpace.s10),
                Expanded(
                  child: OsmonButton(
                    label: l10n.photoGallery,
                    icon: LucideIcons.image,
                    expand: true,
                    tone: OsmonButtonTone.glass,
                    onPressed: onGallery,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoWorkspace extends StatelessWidget {
  const _PhotoWorkspace({
    required this.state,
    required this.tint,
    required this.onAnalyse,
    required this.onRestyle,
    required this.onSave,
    required this.onReset,
  });

  final PhotoState state;
  final Color tint;
  final VoidCallback onAnalyse;
  final ValueChanged<PhotoStyle> onRestyle;
  final VoidCallback onSave;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final busy = state.busyWith;
    final styles = <PhotoStyle, String>{
      PhotoStyle.snow: l10n.photoStyleSnow,
      PhotoStyle.rain: l10n.photoStyleRain,
      PhotoStyle.sunset: l10n.photoStyleSunset,
      PhotoStyle.storm: l10n.photoStyleStorm,
      PhotoStyle.clear: l10n.photoStyleClear,
    };
    final Uint8List image = state.edited ?? state.original!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: OsmonSpace.s16),
        ClipRRect(
          borderRadius: BorderRadius.circular(OsmonRadius.lg),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Image.memory(image, fit: BoxFit.cover, gaplessPlayback: true),
              if (busy == PhotoAction.restyle)
                const Positioned.fill(
                  child: ColoredBox(
                    color: OsmonColors.scrim,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: OsmonSpace.s12),
        OsmonButton(
          label: l10n.photoAnalyse,
          icon: LucideIcons.scanLine,
          expand: true,
          isBusy: busy == PhotoAction.analyse,
          onPressed: busy == null ? onAnalyse : null,
        ),
        if (state.description != null) ...<Widget>[
          Eyebrow(l10n.photoAnalysis),
          GlassPanel(
            child: Text(
              state.description!,
              style: OsmonType.body.copyWith(height: 1.55),
            ),
          ),
        ],
        Eyebrow(l10n.photoRestyle),
        Wrap(
          spacing: OsmonSpace.s8,
          runSpacing: OsmonSpace.s8,
          children: <Widget>[
            for (final entry in styles.entries)
              OsmonChip(
                label: entry.value,
                selected: false,
                tint: tint,
                onTap: busy == null ? () => onRestyle(entry.key) : null,
              ),
          ],
        ),
        const SizedBox(height: OsmonSpace.s20),
        Row(
          children: <Widget>[
            Expanded(
              child: OsmonButton(
                label: l10n.photoSave,
                icon: LucideIcons.download,
                tone: OsmonButtonTone.glass,
                expand: true,
                isBusy: busy == PhotoAction.save,
                onPressed: busy == null ? onSave : null,
              ),
            ),
            const SizedBox(width: OsmonSpace.s10),
            Expanded(
              child: OsmonButton(
                label: l10n.photoNew,
                icon: LucideIcons.refreshCw,
                tone: OsmonButtonTone.glass,
                expand: true,
                onPressed: busy == null ? onReset : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
