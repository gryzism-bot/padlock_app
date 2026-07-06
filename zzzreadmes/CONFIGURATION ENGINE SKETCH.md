```

sealed class ConfigurationMove {
  const ConfigurationMove();
}

// ------------------------------------------------------------------
// WHEELS
// ------------------------------------------------------------------

final class RotateSubjectUp extends ConfigurationMove {
  const RotateSubjectUp();
}

final class RotateSubjectDown extends ConfigurationMove {
  const RotateSubjectDown();
}

final class RotateVerbUp extends ConfigurationMove {
  const RotateVerbUp();
}

final class RotateVerbDown extends ConfigurationMove {
  const RotateVerbDown();
}

final class RotateAspectUp extends ConfigurationMove {
  const RotateAspectUp();
}

final class RotateAspectDown extends ConfigurationMove {
  const RotateAspectDown();
}

final class RotateModalUp extends ConfigurationMove {
  const RotateModalUp();
}

final class RotateModalDown extends ConfigurationMove {
  const RotateModalDown();
}

final class RotatePlaceUp extends ConfigurationMove {
  const RotatePlaceUp();
}

final class RotatePlaceDown extends ConfigurationMove {
  const RotatePlaceDown();
}

final class RotateTimeUp extends ConfigurationMove {
  const RotateTimeUp();
}

final class RotateTimeDown extends ConfigurationMove {
  const RotateTimeDown();
}

final class RotateFrequencyUp extends ConfigurationMove {
  const RotateFrequencyUp();
}

final class RotateFrequencyDown extends ConfigurationMove {
  const RotateFrequencyDown();
}

final class RotateMannerUp extends ConfigurationMove {
  const RotateMannerUp();
}

final class RotateMannerDown extends ConfigurationMove {
  const RotateMannerDown();
}

// ------------------------------------------------------------------
// TOGGLES
// ------------------------------------------------------------------

final class ToggleVoice extends ConfigurationMove {
  const ToggleVoice();
}

final class ToggleQuestion extends ConfigurationMove {
  const ToggleQuestion();
}

final class ToggleNegative extends ConfigurationMove {
  const ToggleNegative();
}

// ------------------------------------------------------------------
// RESULT
// ------------------------------------------------------------------

class ConfigurationResult {
  final SentenceState previous;

  final SentenceState current;

  final ConfigurationMove move;

  final List<ConfigurationChange> changes;

  final List<ConfigurationMessage> messages;

  const ConfigurationResult({
    required this.previous,
    required this.current,
    required this.move,
    required this.changes,
    required this.messages,
  });
}

// ------------------------------------------------------------------
// CHANGES
// ------------------------------------------------------------------

sealed class ConfigurationChange {
  const ConfigurationChange();
}

class FieldChanged extends ConfigurationChange {
  final String field;

  final Object? previous;

  final Object? current;

  const FieldChanged({
    required this.field,
    required this.previous,
    required this.current,
  });
}

class WheelEnabled extends ConfigurationChange {
  final Wheel wheel;

  const WheelEnabled(this.wheel);
}

class WheelDisabled extends ConfigurationChange {
  final Wheel wheel;

  const WheelDisabled(this.wheel);
}

class ToggleEnabled extends ConfigurationChange {
  final Toggle toggle;

  const ToggleEnabled(this.toggle);
}

class ToggleDisabled extends ConfigurationChange {
  final Toggle toggle;

  const ToggleDisabled(this.toggle);
}

// ------------------------------------------------------------------
// EXPLANATIONS
// ------------------------------------------------------------------

class ConfigurationMessage {
  final String text;

  const ConfigurationMessage(this.text);
}

// ------------------------------------------------------------------
// ENGINE
// ------------------------------------------------------------------

class ConfigurationEngine {
  ConfigurationResult applyMove(
    SentenceState current,
    ConfigurationMove move,
  ) {
    var candidate = current.copy();

    switch (move) {
      case RotateVerbUp():
        candidate = candidate.copy(
          action: _nextVerb(current.action),
        );

      case RotateVerbDown():
        candidate = candidate.copy(
          action: _previousVerb(current.action),
        );

      case RotateSubjectUp():
        candidate = candidate.copy(
          agent: _nextAgent(current.agent),
        );

      case RotateSubjectDown():
        candidate = candidate.copy(
          agent: _previousAgent(current.agent),
        );

      case RotateAspectUp():
        candidate = candidate.copy(
          aspect: _nextAspect(current.aspect),
        );

      case RotateAspectDown():
        candidate = candidate.copy(
          aspect: _previousAspect(current.aspect),
        );

      case RotateModalUp():
        candidate = candidate.copy(
          modal: _nextModal(current.modal),
        );

      case RotateModalDown():
        candidate = candidate.copy(
          modal: _previousModal(current.modal),
        );

      case RotatePlaceUp():
        candidate = candidate.copy(
          placePhrase: _nextPlace(current.placePhrase),
        );

      case RotatePlaceDown():
        candidate = candidate.copy(
          placePhrase: _previousPlace(current.placePhrase),
        );

      case ToggleVoice():
        candidate = candidate.copy(
          voice: current.voice == Voice.active
              ? Voice.passive
              : Voice.active,
        );

      case ToggleQuestion():
        candidate = candidate.copy(
          sentenceForm:
              current.sentenceForm == SentenceForm.statement
                  ? SentenceForm.question
                  : SentenceForm.statement,
        );

      case ToggleNegative():
        candidate = candidate.copy(
          polarity:
              current.polarity == Polarity.positive
                  ? Polarity.negative
                  : Polarity.positive,
        );
    }

    final changes = <ConfigurationChange>[];
    final messages = <ConfigurationMessage>[];

    candidate = _resolveConstraints(
      previous: current,
      candidate: candidate,
      changes: changes,
      messages: messages,
    );

    return ConfigurationResult(
      previous: current,
      current: candidate,
      move: move,
      changes: changes,
      messages: messages,
    );
  }

  SentenceState _resolveConstraints({
    required SentenceState previous,
    required SentenceState candidate,
    required List<ConfigurationChange> changes,
    required List<ConfigurationMessage> messages,
  }) {
    // ----------------------------------------------------
    // VERB
    // ----------------------------------------------------

    if (!candidate.action.takesObject &&
        candidate.object != null) {
      changes.add(
        FieldChanged(
          field: 'object',
          previous: candidate.object,
          current: null,
        ),
      );

      candidate = candidate.copy(
        object: null,
      );
    }

    if (candidate.action.usesDestinationPlace &&
        candidate.placeMeaning !=
            PlaceMeaning.destination) {
      changes.add(
        FieldChanged(
          field: 'placeMeaning',
          previous: candidate.placeMeaning,
          current: PlaceMeaning.destination,
        ),
      );

      candidate = candidate.copy(
        placeMeaning: PlaceMeaning.destination,
      );
    }

    if (!candidate.action.takesObject &&
        candidate.voice == Voice.passive) {
      changes.add(
        FieldChanged(
          field: 'voice',
          previous: Voice.passive,
          current: Voice.active,
        ),
      );

      messages.add(
        ConfigurationMessage(
          'Passive voice requires a transitive verb.',
        ),
      );

      candidate = candidate.copy(
        voice: Voice.active,
      );
    }

    // ----------------------------------------------------
    // PASSIVE
    // ----------------------------------------------------

    if (candidate.voice == Voice.passive) {
      final oldAgent = candidate.agent;

      candidate = candidate.copy(
        agent: candidate.object,
        object: oldAgent,
      );
    }

    // ----------------------------------------------------
    // PLACE
    // ----------------------------------------------------

    if (!candidate.action.usesPlace) {
      candidate = candidate.copy(
        placePhrase: null,
      );
    }

    // ----------------------------------------------------
    // MODAL
    // ----------------------------------------------------

    if (candidate.modal != null &&
        !candidate.modal!.supportsAspect(
          candidate.aspect,
        )) {
      messages.add(
        ConfigurationMessage(
          '${candidate.modal!.text} does not support '
          '${candidate.aspect.name}.',
        ),
      );

      candidate = candidate.copy(
        aspect: Aspect.simple,
      );
    }

    return candidate;
  }
}

```