import 'package:padlock_app/models/grammar/phrase/frequency_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/manner_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/place_meaning.dart';
import 'package:padlock_app/models/grammar/phrase/place_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/time_phrase.dart';
import 'package:padlock_app/models/grammar/subject/adjective.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/verb/modal.dart';
import 'package:padlock_app/models/grammar/verb/right_particle.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

class SentenceStateGoal {
  final SentenceState target;

  const SentenceStateGoal(this.target);

  SentenceStateDiff compare(SentenceState current) {
    return SentenceStateDiff.between(current: current, target: target);
  }

  bool isSolvedBy(SentenceState current) => compare(current).isSolved;

  int remainingMovesFrom(SentenceState current) {
    return compare(current).remainingMoves;
  }
}

class SentenceStateDiff {
  final SentenceState current;
  final SentenceState target;
  final List<SentenceStateFieldDiff> fields;

  const SentenceStateDiff._({
    required this.current,
    required this.target,
    required this.fields,
  });

  factory SentenceStateDiff.between({
    required SentenceState current,
    required SentenceState target,
  }) {
    final fields = [
      _field(SentenceStateField.agent, current.agent, target.agent, _nounValue),
      _field(
        SentenceStateField.action,
        current.action,
        target.action,
        _verbValue,
      ),
      _field(
        SentenceStateField.object,
        current.object,
        target.object,
        _nounValue,
      ),
      _field(
        SentenceStateField.recipient,
        current.recipient,
        target.recipient,
        _nounValue,
      ),
      _field(
        SentenceStateField.addressee,
        current.addressee,
        target.addressee,
        _nounValue,
      ),
      _field(
        SentenceStateField.companion,
        current.companion,
        target.companion,
        _nounValue,
      ),
      _field(
        SentenceStateField.instrument,
        current.instrument,
        target.instrument,
        _nounValue,
      ),
      _field(
        SentenceStateField.destination,
        current.destination,
        target.destination,
        _nounValue,
      ),
      _field(SentenceStateField.topic, current.topic, target.topic, _nounValue),
      _field(
        SentenceStateField.topicPreposition,
        current.topicPreposition,
        target.topicPreposition,
        _plainValue,
      ),
      _field(
        SentenceStateField.beneficiary,
        current.beneficiary,
        target.beneficiary,
        _nounValue,
      ),
      _field(
        SentenceStateField.source,
        current.source,
        target.source,
        _nounValue,
      ),
      _field(
        SentenceStateField.purpose,
        current.purpose,
        target.purpose,
        _nounValue,
      ),
      _field(
        SentenceStateField.rightAction,
        current.rightAction,
        target.rightAction,
        _verbValue,
      ),
      _field(
        SentenceStateField.rightParticle,
        current.rightParticle,
        target.rightParticle,
        _rightParticleValue,
      ),
      _field(
        SentenceStateField.recipientPlacement,
        current.recipientPlacement,
        target.recipientPlacement,
        _plainValue,
      ),
      _field(
        SentenceStateField.recipientPreposition,
        current.recipientPreposition,
        target.recipientPreposition,
        _plainValue,
      ),
      _field(
        SentenceStateField.objectComplement,
        current.objectComplement,
        target.objectComplement,
        _nounValue,
      ),
      _field(
        SentenceStateField.objectAdjectiveComplement,
        current.objectAdjectiveComplement,
        target.objectAdjectiveComplement,
        _adjectiveValue,
      ),
      _field(
        SentenceStateField.complement,
        current.complement,
        target.complement,
        _nounValue,
      ),
      _field(
        SentenceStateField.adjectiveComplement,
        current.adjectiveComplement,
        target.adjectiveComplement,
        _adjectiveValue,
      ),
      _field(
        SentenceStateField.voice,
        current.voice,
        target.voice,
        _plainValue,
      ),
      _field(
        SentenceStateField.passiveFocus,
        current.passiveFocus,
        target.passiveFocus,
        _plainValue,
      ),
      _field(
        SentenceStateField.showPassiveAgent,
        current.showPassiveAgent,
        target.showPassiveAgent,
        _plainValue,
      ),
      _field(
        SentenceStateField.tense,
        current.tense,
        target.tense,
        _plainValue,
      ),
      _field(
        SentenceStateField.aspect,
        current.aspect,
        target.aspect,
        _plainValue,
      ),
      _field(
        SentenceStateField.modal,
        current.modal,
        target.modal,
        _modalValue,
      ),
      _field(
        SentenceStateField.polarity,
        current.polarity,
        target.polarity,
        _plainValue,
      ),
      _field(
        SentenceStateField.sentenceForm,
        current.sentenceForm,
        target.sentenceForm,
        _plainValue,
      ),
      _field(
        SentenceStateField.timePhrase,
        current.timePhrase,
        target.timePhrase,
        _timeValue,
      ),
      _field(
        SentenceStateField.placePhrase,
        current.placePhrase,
        target.placePhrase,
        _placeValue,
      ),
      _field(
        SentenceStateField.placeMeaning,
        current.placeMeaning,
        target.placeMeaning,
        _plainValue,
      ),
      _field(
        SentenceStateField.frequencyPhrase,
        current.frequencyPhrase,
        target.frequencyPhrase,
        _frequencyValue,
      ),
      _field(
        SentenceStateField.mannerPhrase,
        current.mannerPhrase,
        target.mannerPhrase,
        _mannerValue,
      ),
    ];

    return SentenceStateDiff._(
      current: current,
      target: target,
      fields: fields.where((field) => !field.isMatch).toList(growable: false),
    );
  }

  bool get isSolved => fields.isEmpty;

  int get remainingMoves => fields.length;

  List<SentenceStateField> get differingFields {
    return [for (final field in fields) field.field];
  }

  bool differs(SentenceStateField field) {
    return fields.any((diff) => diff.field == field);
  }

  SentenceStateFieldDiff? diffFor(SentenceStateField field) {
    for (final diff in fields) {
      if (diff.field == field) {
        return diff;
      }
    }

    return null;
  }
}

enum SentenceStateField {
  agent,
  action,
  object,
  recipient,
  addressee,
  companion,
  instrument,
  destination,
  topic,
  topicPreposition,
  beneficiary,
  source,
  purpose,
  rightAction,
  rightParticle,
  recipientPlacement,
  recipientPreposition,
  objectComplement,
  objectAdjectiveComplement,
  complement,
  adjectiveComplement,
  voice,
  passiveFocus,
  showPassiveAgent,
  tense,
  aspect,
  modal,
  polarity,
  sentenceForm,
  timePhrase,
  placePhrase,
  placeMeaning,
  frequencyPhrase,
  mannerPhrase,
}

extension SentenceStateFieldLabel on SentenceStateField {
  String get label {
    return switch (this) {
      SentenceStateField.agent => 'subject',
      SentenceStateField.action => 'verb',
      SentenceStateField.object => 'object',
      SentenceStateField.recipient => 'recipient',
      SentenceStateField.addressee => 'addressee',
      SentenceStateField.companion => 'companion',
      SentenceStateField.instrument => 'instrument',
      SentenceStateField.destination => 'destination',
      SentenceStateField.topic => 'topic',
      SentenceStateField.topicPreposition => 'topic preposition',
      SentenceStateField.beneficiary => 'beneficiary',
      SentenceStateField.source => 'source',
      SentenceStateField.purpose => 'purpose',
      SentenceStateField.rightAction => 'right action',
      SentenceStateField.rightParticle => 'right particle',
      SentenceStateField.recipientPlacement => 'recipient placement',
      SentenceStateField.recipientPreposition => 'recipient preposition',
      SentenceStateField.objectComplement => 'object complement',
      SentenceStateField.objectAdjectiveComplement =>
        'object adjective complement',
      SentenceStateField.complement => 'noun complement',
      SentenceStateField.adjectiveComplement => 'adjective complement',
      SentenceStateField.voice => 'voice',
      SentenceStateField.passiveFocus => 'passive focus',
      SentenceStateField.showPassiveAgent => 'passive agent',
      SentenceStateField.tense => 'tense',
      SentenceStateField.aspect => 'aspect',
      SentenceStateField.modal => 'modal',
      SentenceStateField.polarity => 'polarity',
      SentenceStateField.sentenceForm => 'form',
      SentenceStateField.timePhrase => 'time phrase',
      SentenceStateField.placePhrase => 'place phrase',
      SentenceStateField.placeMeaning => 'place meaning',
      SentenceStateField.frequencyPhrase => 'frequency phrase',
      SentenceStateField.mannerPhrase => 'manner phrase',
    };
  }
}

class SentenceStateFieldDiff {
  final SentenceStateField field;
  final String label;
  final String? current;
  final String? target;

  const SentenceStateFieldDiff({
    required this.field,
    required this.label,
    required this.current,
    required this.target,
  });

  bool get isMatch => current == target;
}

SentenceStateFieldDiff _field<T>(
  SentenceStateField field,
  T current,
  T target,
  String? Function(T value) valueOf,
) {
  return SentenceStateFieldDiff(
    field: field,
    label: field.label,
    current: valueOf(current),
    target: valueOf(target),
  );
}

String? _nounValue(NounPhrase? phrase) {
  if (phrase == null) {
    return null;
  }

  return [
    phrase.text,
    phrase.person.toString(),
    phrase.number.toString(),
    phrase.determiner?.text ?? '-',
    phrase.adjectiveList.map((adjective) => adjective.text).join('|'),
  ].join('/');
}

String? _verbValue(Verb? verb) => verb?.infinitive;

String? _modalValue(Modal? modal) => modal?.text;

String? _rightParticleValue(RightParticle? particle) => particle?.text;

String? _adjectiveValue(Adjective? adjective) => adjective?.text;

String? _timeValue(TimePhrase? phrase) => phrase?.text;

String? _frequencyValue(FrequencyPhrase? phrase) => phrase?.text;

String? _mannerValue(MannerPhrase? phrase) => phrase?.text;

String? _placeValue(PlacePhrase? phrase) {
  if (phrase == null) {
    return null;
  }

  return [
    phrase.noun,
    phrase.render(PlaceMeaning.location),
    phrase.render(PlaceMeaning.destination),
    phrase.render(PlaceMeaning.source),
  ].join('/');
}

String? _plainValue(Object? value) => value?.toString();
