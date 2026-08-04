import 'package:padlock_app/data/modals.dart' as modal_data;
import 'package:padlock_app/models/grammar/phrase/frequency_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/manner_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/place_meaning.dart';
import 'package:padlock_app/models/grammar/phrase/place_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/time_phrase.dart';
import 'package:padlock_app/models/grammar/subject/adjective.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/verb/modal.dart';
import 'package:padlock_app/models/grammar/verb/right_particle.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
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
    final comparableCurrent = _normalizeFutureModal(current);
    final comparableTarget = _normalizeFutureModal(target);
    final fields = [
      _field(
        SentenceStateField.agent,
        comparableCurrent.agent,
        comparableTarget.agent,
        _nounValue,
      ),
      _field(
        SentenceStateField.action,
        comparableCurrent.action,
        comparableTarget.action,
        _verbValue,
      ),
      _field(
        SentenceStateField.object,
        comparableCurrent.object,
        comparableTarget.object,
        _nounValue,
      ),
      _field(
        SentenceStateField.recipient,
        comparableCurrent.recipient,
        comparableTarget.recipient,
        _nounValue,
      ),
      _field(
        SentenceStateField.addressee,
        comparableCurrent.addressee,
        comparableTarget.addressee,
        _nounValue,
      ),
      _field(
        SentenceStateField.companion,
        comparableCurrent.companion,
        comparableTarget.companion,
        _nounValue,
      ),
      _field(
        SentenceStateField.instrument,
        comparableCurrent.instrument,
        comparableTarget.instrument,
        _nounValue,
      ),
      _field(
        SentenceStateField.destination,
        comparableCurrent.destination,
        comparableTarget.destination,
        _nounValue,
      ),
      _field(
        SentenceStateField.topic,
        comparableCurrent.topic,
        comparableTarget.topic,
        _nounValue,
      ),
      _field(
        SentenceStateField.topicPreposition,
        comparableCurrent.topicPreposition,
        comparableTarget.topicPreposition,
        _plainValue,
      ),
      _field(
        SentenceStateField.beneficiary,
        comparableCurrent.beneficiary,
        comparableTarget.beneficiary,
        _nounValue,
      ),
      _field(
        SentenceStateField.source,
        comparableCurrent.source,
        comparableTarget.source,
        _nounValue,
      ),
      _field(
        SentenceStateField.purpose,
        comparableCurrent.purpose,
        comparableTarget.purpose,
        _nounValue,
      ),
      _field(
        SentenceStateField.rightAction,
        comparableCurrent.rightAction,
        comparableTarget.rightAction,
        _verbValue,
      ),
      _field(
        SentenceStateField.rightParticle,
        comparableCurrent.rightParticle,
        comparableTarget.rightParticle,
        _rightParticleValue,
      ),
      _field(
        SentenceStateField.recipientPlacement,
        comparableCurrent.recipientPlacement,
        comparableTarget.recipientPlacement,
        _plainValue,
      ),
      _field(
        SentenceStateField.recipientPreposition,
        comparableCurrent.recipientPreposition,
        comparableTarget.recipientPreposition,
        _plainValue,
      ),
      _field(
        SentenceStateField.objectComplement,
        comparableCurrent.objectComplement,
        comparableTarget.objectComplement,
        _nounValue,
      ),
      _field(
        SentenceStateField.objectAdjectiveComplement,
        comparableCurrent.objectAdjectiveComplement,
        comparableTarget.objectAdjectiveComplement,
        _adjectiveValue,
      ),
      _field(
        SentenceStateField.complement,
        comparableCurrent.complement,
        comparableTarget.complement,
        _nounValue,
      ),
      _field(
        SentenceStateField.adjectiveComplement,
        comparableCurrent.adjectiveComplement,
        comparableTarget.adjectiveComplement,
        _adjectiveValue,
      ),
      _field(
        SentenceStateField.voice,
        comparableCurrent.voice,
        comparableTarget.voice,
        _plainValue,
      ),
      _field(
        SentenceStateField.passiveFocus,
        comparableCurrent.passiveFocus,
        comparableTarget.passiveFocus,
        _plainValue,
      ),
      _field(
        SentenceStateField.showPassiveAgent,
        comparableCurrent.showPassiveAgent,
        comparableTarget.showPassiveAgent,
        _plainValue,
      ),
      _field(
        SentenceStateField.tense,
        comparableCurrent.tense,
        comparableTarget.tense,
        _plainValue,
      ),
      _field(
        SentenceStateField.aspect,
        comparableCurrent.aspect,
        comparableTarget.aspect,
        _plainValue,
      ),
      _field(
        SentenceStateField.modal,
        comparableCurrent.modal,
        comparableTarget.modal,
        _modalValue,
      ),
      _field(
        SentenceStateField.polarity,
        comparableCurrent.polarity,
        comparableTarget.polarity,
        _plainValue,
      ),
      _field(
        SentenceStateField.sentenceForm,
        comparableCurrent.sentenceForm,
        comparableTarget.sentenceForm,
        _plainValue,
      ),
      _field(
        SentenceStateField.timePhrase,
        comparableCurrent.timePhrase,
        comparableTarget.timePhrase,
        _timeValue,
      ),
      _field(
        SentenceStateField.placePhrase,
        comparableCurrent.placePhrase,
        comparableTarget.placePhrase,
        _placeValue,
      ),
      _field(
        SentenceStateField.placeMeaning,
        comparableCurrent.placeMeaning,
        comparableTarget.placeMeaning,
        _plainValue,
      ),
      _field(
        SentenceStateField.frequencyPhrase,
        comparableCurrent.frequencyPhrase,
        comparableTarget.frequencyPhrase,
        _frequencyValue,
      ),
      _field(
        SentenceStateField.mannerPhrase,
        comparableCurrent.mannerPhrase,
        comparableTarget.mannerPhrase,
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

SentenceState _normalizeFutureModal(SentenceState state) {
  if (state.modal != modal_data.will) {
    return state;
  }

  return state.copyWith(tense: Tense.future, modal: modal_data.noModal);
}
