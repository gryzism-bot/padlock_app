part of '../home_screen.dart';

class _CoreParticipantSurfaceMap extends StatelessWidget {
  final ConfigurationState configuration;
  final Set<ConfigurationCompassSlot> expandedRails;
  final bool isExpanded;
  final VoidCallback onToggleSection;
  final ValueChanged<ConfigurationCompassSlot> onToggleRail;

  const _CoreParticipantSurfaceMap({
    required this.configuration,
    required this.expandedRails,
    required this.isExpanded,
    required this.onToggleSection,
    required this.onToggleRail,
  });

  @override
  Widget build(BuildContext context) {
    final participantDoors = _coreParticipantDoors(configuration);

    return _SectionFrame(
      title: 'Core participant surface',
      isExpanded: isExpanded,
      onToggle: onToggleSection,
      collapsedHint: 'Click to show participant doors.',
      children: [
        for (final door in participantDoors)
          _ParticipantDoorChip(
            door: door,
            isExpanded: door.slot != null && expandedRails.contains(door.slot),
            onPressed:
                door.slot == null ||
                    door.status == _ParticipantDoorStatus.asleep
                ? null
                : () => onToggleRail(door.slot!),
          ),
      ],
    );
  }
}

class _ParticipantDoor {
  final String label;
  final String value;
  final _ParticipantDoorStatus status;
  final ConfigurationCompassSlot? slot;

  const _ParticipantDoor({
    required this.label,
    required this.value,
    required this.status,
    this.slot,
  });
}

enum _ParticipantDoorStatus { asleep, awake, filled }

class _ParticipantDoorChip extends StatelessWidget {
  final _ParticipantDoor door;
  final bool isExpanded;
  final VoidCallback? onPressed;

  const _ParticipantDoorChip({
    required this.door,
    required this.isExpanded,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final statusLabel = switch (door.status) {
      _ParticipantDoorStatus.asleep => 'asleep',
      _ParticipantDoorStatus.awake => isExpanded ? 'open' : 'awake',
      _ParticipantDoorStatus.filled => isExpanded ? 'open' : 'filled',
    };
    final statusColor = switch (door.status) {
      _ParticipantDoorStatus.asleep => colors.onSurfaceVariant,
      _ParticipantDoorStatus.awake => colors.tertiary,
      _ParticipantDoorStatus.filled => colors.primary,
    };

    return Tooltip(
      message: onPressed == null
          ? '${door.label}: ${door.value}'
          : '${door.label}: ${door.value}. Click to ${isExpanded ? 'close' : 'open'} rail.',
      child: OutlinedButton.icon(
        key: door.slot == null
            ? null
            : Key('participant-door-${door.slot!.name}'),
        style: OutlinedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          minimumSize: const Size(0, 36),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: door.status == _ParticipantDoorStatus.asleep
              ? colors.onSurfaceVariant
              : null,
          side: BorderSide(
            color: isExpanded ? colors.primary : colors.outlineVariant,
            width: isExpanded ? 2 : 1,
          ),
        ),
        onPressed: onPressed,
        icon: Icon(
          switch (door.status) {
            _ParticipantDoorStatus.asleep => Icons.lock_outline,
            _ParticipantDoorStatus.awake => Icons.meeting_room_outlined,
            _ParticipantDoorStatus.filled => Icons.radio_button_checked,
          },
          size: 16,
          color: statusColor,
        ),
        label: Text('${door.label}: ${door.value} ($statusLabel)'),
      ),
    );
  }
}

class _VisibleCompassSlot {
  final ConfigurationCompassSlot slot;
  final List<ConfigurationSuggestion> suggestions;
  final String title;
  final String unlockHint;
  final String? surfaceMarker;
  final bool isExpanded;
  final bool canToggle;

  const _VisibleCompassSlot(
    this.slot,
    this.suggestions, {
    required this.title,
    required this.unlockHint,
    required this.surfaceMarker,
    required this.isExpanded,
    required this.canToggle,
  });
}
