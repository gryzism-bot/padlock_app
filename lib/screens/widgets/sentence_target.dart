part of '../home_screen.dart';

class _SentenceTarget {
  final SentenceState state;
  final String sentence;
  final String message;
  final String traceLabel;
  final _SentenceStateRailPlan railPlan;

  const _SentenceTarget({
    required this.state,
    required this.sentence,
    required this.message,
    required this.traceLabel,
    required this.railPlan,
  });

  factory _SentenceTarget.fromRecognizedSentence(
    _RecognitionInputResult result,
  ) {
    return _SentenceTarget(
      state: result.state,
      sentence: result.canonicalSentence,
      message: result.message,
      traceLabel: result.input,
      railPlan: _SentenceStateRailPlan.fromSentenceState(result.state),
    );
  }
}

class _SentenceStateRailPlan {
  final Set<ConfigurationCompassSlot> slots;

  const _SentenceStateRailPlan(this.slots);

  factory _SentenceStateRailPlan.fromSentenceState(SentenceState state) {
    final slots = <ConfigurationCompassSlot>{};

    void addIf(bool condition, ConfigurationCompassSlot slot) {
      if (condition) {
        slots.add(slot);
      }
    }

    addIf(state.object != null, ConfigurationCompassSlot.object);
    addIf(
      state.object?.determiner != null,
      ConfigurationCompassSlot.objectDeterminer,
    );
    addIf(
      state.object?.adjectiveList.isNotEmpty == true,
      ConfigurationCompassSlot.objectAdjective,
    );
    addIf(state.recipient != null, ConfigurationCompassSlot.recipient);
    addIf(
      state.recipient?.determiner != null,
      ConfigurationCompassSlot.recipientDeterminer,
    );
    addIf(
      state.recipient?.adjectiveList.isNotEmpty == true,
      ConfigurationCompassSlot.recipientAdjective,
    );
    addIf(state.addressee != null, ConfigurationCompassSlot.addressee);
    addIf(state.companion != null, ConfigurationCompassSlot.companion);
    addIf(state.instrument != null, ConfigurationCompassSlot.instrument);
    addIf(state.destination != null, ConfigurationCompassSlot.destination);
    addIf(state.topic != null, ConfigurationCompassSlot.topic);
    addIf(state.beneficiary != null, ConfigurationCompassSlot.beneficiary);
    addIf(state.source != null, ConfigurationCompassSlot.source);
    addIf(state.purpose != null, ConfigurationCompassSlot.purpose);
    addIf(state.rightAction != null, ConfigurationCompassSlot.rightAction);
    addIf(state.rightParticle != null, ConfigurationCompassSlot.rightParticle);
    addIf(
      state.objectComplement != null,
      ConfigurationCompassSlot.objectComplement,
    );
    addIf(
      state.objectComplement?.determiner != null,
      ConfigurationCompassSlot.objectComplementDeterminer,
    );
    addIf(
      state.objectComplement?.adjectiveList.isNotEmpty == true,
      ConfigurationCompassSlot.objectComplementAdjective,
    );
    addIf(
      state.objectAdjectiveComplement != null,
      ConfigurationCompassSlot.objectAdjectiveComplement,
    );
    addIf(state.complement != null, ConfigurationCompassSlot.complement);
    addIf(
      state.complement?.determiner != null,
      ConfigurationCompassSlot.complementDeterminer,
    );
    addIf(
      state.complement?.adjectiveList.isNotEmpty == true,
      ConfigurationCompassSlot.complementAdjective,
    );
    addIf(
      state.adjectiveComplement != null,
      ConfigurationCompassSlot.adjectiveComplement,
    );
    addIf(
      state.voice == Voice.passive && state.passiveFocus != null,
      ConfigurationCompassSlot.passiveFocus,
    );
    addIf(
      state.voice == Voice.passive && state.showPassiveAgent,
      ConfigurationCompassSlot.passiveAgent,
    );
    addIf(state.timePhrase != null, ConfigurationCompassSlot.timePhrase);
    addIf(state.placePhrase != null, ConfigurationCompassSlot.placePhrase);
    addIf(
      state.frequencyPhrase != null,
      ConfigurationCompassSlot.frequencyPhrase,
    );
    addIf(state.mannerPhrase != null, ConfigurationCompassSlot.mannerPhrase);

    return _SentenceStateRailPlan(slots);
  }

  List<ConfigurationCompassSlot> get orderedSlots {
    return [
      for (final slot in ConfigurationCompassSlot.values)
        if (slots.contains(slot)) slot,
    ];
  }

  bool get isEmpty => slots.isEmpty;
}

class _RailOpeningSequence {
  final List<Timer> _timers = [];

  void open(
    _SentenceStateRailPlan railPlan, {
    required bool Function() isMounted,
    required ValueChanged<ConfigurationCompassSlot> openSlot,
  }) {
    cancel();

    if (railPlan.isEmpty) {
      return;
    }

    final orderedSlots = railPlan.orderedSlots;
    for (var index = 0; index < orderedSlots.length; index++) {
      final timer = Timer(Duration(milliseconds: 55 * (index + 1)), () {
        if (!isMounted()) {
          return;
        }

        openSlot(orderedSlots[index]);
      });
      _timers.add(timer);
    }
  }

  void cancel() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }
}
