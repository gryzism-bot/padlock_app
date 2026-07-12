import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/phrases/frequency_phrases.dart';
import 'package:padlock_app/data/phrases/manner_phrases.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/predicate/fixed_object_frames.dart';
import 'package:padlock_app/data/subjects/adjectives/essential_adjectives.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/subjects/fixed_predicate_objects.dart'
    as fixed_object;
import 'package:padlock_app/data/subjects/pronouns.dart' show you;
import 'package:padlock_app/data/subjects/third_person/animals.dart';
import 'package:padlock_app/data/subjects/third_person/geography.dart';
import 'package:padlock_app/data/subjects/third_person/objects.dart';
import 'package:padlock_app/data/subjects/third_person/people.dart';
import 'package:padlock_app/data/verbs/essential.dart' hide need;
import 'package:padlock_app/engine/logger/engine_logger.dart';
import 'package:padlock_app/engine/logger/recognition_diagnostics.dart';
import 'package:padlock_app/models/grammar/passive_focus.dart';
import 'package:padlock_app/models/grammar/phrase/frequency_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/manner_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/phrase_position.dart';
import 'package:padlock_app/models/grammar/phrase/place_meaning.dart';
import 'package:padlock_app/models/grammar/phrase/place_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/time_phrase.dart';
import 'package:padlock_app/models/grammar/preposition.dart';
import 'package:padlock_app/models/grammar/recipient_placement.dart';
import 'package:padlock_app/models/grammar/recipient_preposition.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/subject/adjective.dart';
import 'package:padlock_app/models/grammar/subject/determiner.dart';
import 'package:padlock_app/models/grammar/subject/noun.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/subject/person.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/modal.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';
import 'package:padlock_app/models/grammar/voice.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

class RecognitionEngine {
  final EngineLogger logger;

  RecognitionEngine({this.logger = const EngineLogger()});

  SentenceState recognize(String sentence) {
    final builder = _RecognitionBuilder(sentence);
    var phase = 'start';

    try {
      phase = 'normalize';
      _normalize(builder);
      _logRecognitionPhase(builder, phase);

      phase = 'tokenize';
      _tokenize(builder);
      _logRecognitionPhase(builder, phase);

      phase = 'sentence form';
      _recognizeSentenceForm(builder);
      _logRecognitionPhase(builder, phase);

      phase = 'verb chain';
      _recognizeVerbChain(builder);
      _logRecognitionPhase(builder, phase);

      phase = 'imperative';
      _recognizeImperative(builder);
      _logRecognitionPhase(builder, phase);

      phase = 'voice';
      _recognizeVoice(builder);
      _logRecognitionPhase(builder, phase);

      phase = 'participant boundaries';
      _recognizeParticipantBoundaries(builder);
      _logRecognitionPhase(builder, phase);

      phase = 'phrases';
      _recognizePhrases(builder);
      _logRecognitionPhase(builder, phase);

      phase = 'trim participant boundaries';
      _trimParticipantBoundaries(builder);
      _logRecognitionPhase(builder, phase);

      phase = 'participants';
      _buildParticipants(builder);
      _logRecognitionPhase(builder, phase);

      phase = 'unknown tokens';
      _recognizeUnknownTokens(builder);
      _logRecognitionPhase(builder, phase);

      phase = 'state';
      final state = builder.state;

      logger.logRecognition(
        RecognitionDiagnostics(
          sentence: sentence,
          tokens: builder.tokens,
          verbChainStart: builder.verbChainStart,
          verbChainEnd: builder.verbChainEnd,
          state: state,

          unknownTokens: builder.unknownTokens,
        ),
      );

      return state;
    } catch (error, stackTrace) {
      logger.logRecognitionFailure(
        phase,
        error,
        stackTrace,
        builder.debugSnapshot(),
      );
      rethrow;
    }
  }

  void _logRecognitionPhase(_RecognitionBuilder builder, String phase) {
    logger.logRecognitionPhase(phase, builder.debugSnapshot());
  }

  // -------------------------------------------------------
  // NORMALIZATION
  // -------------------------------------------------------

  void _normalize(_RecognitionBuilder builder) {
    builder.normalizedSentence = builder.sentence.trim();

    if (builder.normalizedSentence.endsWith('.')) {
      builder.normalizedSentence = builder.normalizedSentence.substring(
        0,
        builder.normalizedSentence.length - 1,
      );
    }

    if (builder.normalizedSentence.endsWith('?')) {
      builder.normalizedSentence = builder.normalizedSentence.substring(
        0,
        builder.normalizedSentence.length - 1,
      );
    }

    if (builder.normalizedSentence.endsWith('!')) {
      builder.normalizedSentence = builder.normalizedSentence.substring(
        0,
        builder.normalizedSentence.length - 1,
      );
    }
  }

  // -------------------------------------------------------
  // TOKENIZATION
  // -------------------------------------------------------

  void _tokenize(_RecognitionBuilder builder) {
    builder.tokens
      ..clear()
      ..addAll(builder.normalizedSentence.split(' '));
  }

  // -------------------------------------------------------
  // SENTENCE FORM
  // -------------------------------------------------------

  void _recognizeSentenceForm(_RecognitionBuilder builder) {
    if (builder.sentence.endsWith('?')) {
      builder.sentenceForm = SentenceForm.question;
      return;
    }

    if (builder.sentence.endsWith('!')) {
      builder.sentenceForm = SentenceForm.exclamation;
      return;
    }

    builder.sentenceForm = SentenceForm.statement;
  }

  // -------------------------------------------------------
  // VERB CHAIN
  // -------------------------------------------------------

  void _recognizeVerbChain(_RecognitionBuilder builder) {
    for (var i = 0; i < builder.tokens.length; i++) {
      final token = builder.tokens[i].toLowerCase();

      // -------------------------------------------------------
      // MODALS
      // -------------------------------------------------------

      final modal = _lookupModal(token);

      if (modal != null && _isModalUse(builder, i, modal)) {
        builder.modal = modal;
        builder.verbChainStart = i;
        if (token == 'cannot') {
          builder.polarity = Polarity.negative;
        }

        if (modal == will) {
          builder.tense = Tense.future;
        } else {
          builder.tense = Tense.present;
        }

        var current = i + 1;
        if (builder.sentenceForm == SentenceForm.question && i == 0) {
          builder.subjectStart = current;

          while (current < builder.tokens.length) {
            if (_isPredicateLexicalVerb(builder, current)) {
              break;
            }

            current++;
          }
          builder.subjectEnd = _subjectEndBeforePredicate(builder, current);
          for (var j = builder.subjectStart; j < current; j++) {
            if (builder.tokens[j].toLowerCase() == 'not') {
              builder.polarity = Polarity.negative;
              break;
            }
          }
        } else {
          if (current < builder.tokens.length &&
              builder.tokens[current].toLowerCase() == 'not') {
            builder.polarity = Polarity.negative;
            current++;
          }
        }

        if (current < builder.tokens.length &&
            builder.tokens[current].toLowerCase() == 'have') {
          final haveIndex = current;
          builder.aspect = Aspect.perfect;
          current++;

          if (current < builder.tokens.length &&
              builder.tokens[current].toLowerCase() == 'been') {
            final beenIndex = current;
            current++;
            _recognizeVerbAfterBeen(builder, current);
            if (builder.action == null && current < builder.tokens.length) {
              _recognizeLexicalBeAfterBeen(builder, beenIndex, current);
            }
          } else if (current < builder.tokens.length) {
            final match = _lookupVerbAt(builder.tokens, current);

            if (match != null) {
              builder.action = match.verb;
              builder.verbChainEnd = match.end;
            }
          }

          if (builder.action == null) {
            builder.action = have;
            builder.aspect = Aspect.simple;
            builder.verbChainEnd = haveIndex;
          }
        } else if (current < builder.tokens.length &&
            builder.tokens[current].toLowerCase() == 'be') {
          final beIndex = current;
          current++;
          _recognizeVerbAfterBe(builder, current);
          if (builder.action == null) {
            _recognizeLexicalBeAfterBe(builder, beIndex, current);
          }
        } else {
          builder.aspect = Aspect.simple;
        }

        if (builder.action == null && current < builder.tokens.length) {
          final match = _lookupVerbAt(builder.tokens, current);

          if (match != null) {
            if (match.verb == be &&
                _matchesVerbFormAt(builder.tokens, current, be.infinitive)) {
              _recognizeLexicalBeAfterBe(builder, current, match.end + 1);
            } else {
              builder.action = match.verb;
              builder.verbChainEnd = match.end;
            }
          }
        }

        break;
      }

      // -------------------------------------------------------
      // DO / DOES
      // -------------------------------------------------------

      if (token == 'do' || token == 'does') {
        builder.tense = Tense.present;
        builder.aspect = Aspect.simple;
        builder.verbChainStart = i;

        var current = i + 1;
        if (builder.sentenceForm == SentenceForm.question && i == 0) {
          builder.subjectStart = current;

          while (current < builder.tokens.length) {
            if (_isPredicateLexicalVerb(builder, current)) {
              break;
            }

            current++;
          }
          builder.subjectEnd = _subjectEndBeforePredicate(builder, current);
          _recognizePolarityBetween(builder, builder.subjectStart, current);
        } else {
          if (current < builder.tokens.length &&
              builder.tokens[current].toLowerCase() == 'not') {
            builder.polarity = Polarity.negative;
            current++;
          }
        }

        if (current < builder.tokens.length) {
          final match = _lookupVerbAt(builder.tokens, current);

          if (match != null) {
            if (match.verb == be &&
                _matchesVerbFormAt(builder.tokens, current, be.infinitive)) {
              _recognizeLexicalBeAfterBe(builder, current, match.end + 1);
            } else {
              builder.action = match.verb;
              builder.verbChainEnd = match.end;
            }
          }
        }

        if (builder.action == null) {
          builder.action = doVerb;
          builder.verbChainEnd = i;
        }
        break;
      }

      // -------------------------------------------------------
      // DID
      // -------------------------------------------------------

      if (token == 'did') {
        builder.tense = Tense.past;
        builder.aspect = Aspect.simple;
        builder.verbChainStart = i;

        var current = i + 1;
        if (builder.sentenceForm == SentenceForm.question && i == 0) {
          builder.subjectStart = current;

          while (current < builder.tokens.length) {
            if (_isPredicateLexicalVerb(builder, current)) {
              break;
            }

            current++;
          }
          builder.subjectEnd = _subjectEndBeforePredicate(builder, current);
          _recognizePolarityBetween(builder, builder.subjectStart, current);
        } else {
          if (current < builder.tokens.length &&
              builder.tokens[current].toLowerCase() == 'not') {
            builder.polarity = Polarity.negative;
            current++;
          }
        }

        if (current > 0 && builder.tokens[current - 1].toLowerCase() == 'not') {
          builder.polarity = Polarity.negative;
        }

        if (current < builder.tokens.length) {
          final match = _lookupVerbAt(builder.tokens, current);

          if (match != null) {
            builder.action = match.verb;
            builder.verbChainEnd = match.end;
          }
        }

        if (builder.action == null) {
          builder.action = doVerb;
          builder.verbChainEnd = i;
        }
        break;
      }

      // -------------------------------------------------------
      // HAVE / HAS
      // -------------------------------------------------------

      if (token == 'have' || token == 'has') {
        builder.tense = Tense.present;
        builder.verbChainStart = i;

        var current = i + 1;
        if (builder.sentenceForm == SentenceForm.question && i == 0) {
          builder.subjectStart = current;

          while (current < builder.tokens.length) {
            if (_isPredicateLexicalVerb(builder, current)) {
              break;
            }

            current++;
          }
          builder.subjectEnd = _subjectEndBeforePredicate(builder, current);
          for (var j = builder.subjectStart; j < current; j++) {
            if (builder.tokens[j].toLowerCase() == 'not') {
              builder.polarity = Polarity.negative;
              break;
            }
          }
        } else {
          if (current < builder.tokens.length &&
              builder.tokens[current].toLowerCase() == 'not') {
            builder.polarity = Polarity.negative;
            current++;
          }
        }

        builder.aspect = Aspect.perfect;

        if (current < builder.tokens.length &&
            builder.tokens[current].toLowerCase() == 'been') {
          final beenIndex = current;
          current++;
          _recognizeVerbAfterBeen(builder, current);
          if (builder.action == null && current < builder.tokens.length) {
            _recognizeLexicalBeAfterBeen(builder, beenIndex, current);
          }
        } else if (current < builder.tokens.length) {
          // print(current);
          // print(builder.tokens[current]);
          final match = _lookupVerbAt(builder.tokens, current);

          if (match != null) {
            builder.action = match.verb;
            builder.verbChainEnd = match.end;
          }
        }

        if (builder.action == null) {
          builder.action = have;
          builder.aspect = Aspect.simple;
          builder.verbChainEnd = i;
        }
        break;
      }

      // -------------------------------------------------------
      // HAD
      // -------------------------------------------------------

      if (token == 'had') {
        builder.tense = Tense.past;
        builder.aspect = Aspect.perfect;
        builder.verbChainStart = i;

        var current = i + 1;
        if (builder.sentenceForm == SentenceForm.question && i == 0) {
          builder.subjectStart = current;

          while (current < builder.tokens.length) {
            if (_isPredicateLexicalVerb(builder, current)) {
              break;
            }

            current++;
          }
          builder.subjectEnd = _subjectEndBeforePredicate(builder, current);
          for (var j = builder.subjectStart; j < current; j++) {
            if (builder.tokens[j].toLowerCase() == 'not') {
              builder.polarity = Polarity.negative;
              break;
            }
          }
        } else {
          if (current < builder.tokens.length &&
              builder.tokens[current].toLowerCase() == 'not') {
            builder.polarity = Polarity.negative;
            current++;
          }
        }

        if (current < builder.tokens.length &&
            builder.tokens[current].toLowerCase() == 'been') {
          final beenIndex = current;
          current++;
          _recognizeVerbAfterBeen(builder, current);
          if (builder.action == null && current < builder.tokens.length) {
            _recognizeLexicalBeAfterBeen(builder, beenIndex, current);
          }
        } else if (current < builder.tokens.length) {
          final match = _lookupVerbAt(builder.tokens, current);

          if (match != null) {
            builder.action = match.verb;
            builder.verbChainEnd = match.end;
          }
        }

        if (builder.action == null) {
          builder.action = have;
          builder.aspect = Aspect.simple;
          builder.verbChainEnd = i;
        }
        break;
      }

      // -------------------------------------------------------
      // BE
      // -------------------------------------------------------

      if (token == 'am' ||
          token == 'is' ||
          token == 'are' ||
          token == 'was' ||
          token == 'were') {
        builder.tense = token == 'was' || token == 'were'
            ? Tense.past
            : Tense.present;

        builder.verbChainStart = i;

        var current = i + 1;
        if (builder.sentenceForm == SentenceForm.question && i == 0) {
          builder.subjectStart = current;

          while (current < builder.tokens.length) {
            if (_isPredicateLexicalVerb(builder, current)) {
              break;
            }

            current++;
          }
          builder.subjectEnd = _subjectEndBeforePredicate(builder, current);
          _recognizePolarityBetween(builder, builder.subjectStart, current);
        } else {
          if (current < builder.tokens.length &&
              builder.tokens[current].toLowerCase() == 'not') {
            builder.polarity = Polarity.negative;
            current++;
          }
        }

        _recognizeVerbAfterBe(builder, current);
        if (builder.action == null) {
          if (builder.sentenceForm == SentenceForm.question && i == 0) {
            builder.subjectEnd = _nounPhraseEnd(builder, builder.subjectStart);
            _recognizeLexicalBeAfterBe(builder, i, builder.subjectEnd + 1);
          } else {
            _recognizeLexicalBeAfterBe(builder, i, current);
          }
        }
        break;
      }

      // -------------------------------------------------------
      // SIMPLE PRESENT / PAST
      // -------------------------------------------------------

      final match = _lookupVerbAt(builder.tokens, i);
      final verb = match?.verb;

      if (verb != null) {
        if (_looksLikeNounPhraseToken(builder, i) ||
            _shouldYieldToLaterPredicate(builder, i)) {
          continue;
        }

        builder.action = verb;
        builder.verbChainStart = i;
        builder.verbChainEnd = match!.end;

        if (verb == be &&
            _matchesVerbFormAt(builder.tokens, i, verb.infinitive)) {
          builder.tense = Tense.present;
          builder.aspect = Aspect.simple;
          _recognizeLexicalBeAfterBe(builder, i, match.end + 1);
        } else if (_matchesVerbFormAt(builder.tokens, i, verb.infinitive)) {
          builder.tense =
              _matchesVerbFormAt(builder.tokens, i, verb.pastSimple) &&
                  _hasThirdPersonSingularSubjectBefore(builder, i)
              ? Tense.past
              : Tense.present;
          builder.aspect = Aspect.simple;
        } else if (_matchesVerbFormAt(
          builder.tokens,
          i,
          verb.presentThirdPerson,
        )) {
          builder.tense = Tense.present;
          builder.aspect = Aspect.simple;
        } else if (_matchesVerbFormAt(builder.tokens, i, verb.pastSimple)) {
          builder.tense = Tense.past;
          builder.aspect = Aspect.simple;
        }
        break;
      }
    }
  }

  void _recognizeImperative(_RecognitionBuilder builder) {
    if (builder.sentenceForm != SentenceForm.statement ||
        builder.verbChainStart != 0 ||
        builder.action == null) {
      return;
    }

    final firstToken = builder.tokens.first.toLowerCase();

    final isDoSupportImperative =
        firstToken == 'do' && builder.action != doVerb;
    final isBareBeImperative = firstToken == 'be' && builder.action == be;
    final isBareInfinitiveImperative = _matchesVerbFormAt(
      builder.tokens,
      0,
      builder.action!.infinitive,
    );

    if (isDoSupportImperative ||
        isBareBeImperative ||
        isBareInfinitiveImperative) {
      builder.sentenceForm = SentenceForm.imperative;
    }
  }

  void _recognizeVerbAfterBeen(_RecognitionBuilder builder, int current) {
    if (current >= builder.tokens.length) {
      return;
    }

    if (builder.tokens[current].toLowerCase() == 'being' &&
        current + 1 < builder.tokens.length) {
      final passiveMatch = _lookupVerbAt(builder.tokens, current + 1);
      final passiveVerb = passiveMatch?.verb;

      if (passiveVerb != null &&
          _matchesVerbFormAt(
            builder.tokens,
            current + 1,
            passiveVerb.pastParticiple,
          )) {
        builder.action = passiveVerb;
        builder.aspect = Aspect.perfectContinuous;
        builder.verbChainEnd = passiveMatch!.end;
      }

      return;
    }

    final match = _lookupVerbAt(builder.tokens, current);
    final verb = match?.verb;

    if (verb != null) {
      if (_matchesVerbFormAt(builder.tokens, current, verb.ingForm)) {
        builder.action = verb;
        builder.aspect = Aspect.perfectContinuous;
        builder.verbChainEnd = match!.end;
        return;
      }

      if (_matchesVerbFormAt(builder.tokens, current, verb.pastParticiple)) {
        builder.action = verb;
        builder.verbChainEnd = match!.end;
      }
    }
  }

  void _recognizeVerbAfterBe(_RecognitionBuilder builder, int current) {
    builder.aspect = Aspect.simple;

    if (current >= builder.tokens.length) {
      return;
    }

    if (builder.tokens[current].toLowerCase() == 'being' &&
        current + 1 < builder.tokens.length) {
      final passiveMatch = _lookupVerbAt(builder.tokens, current + 1);
      final passiveVerb = passiveMatch?.verb;

      if (passiveVerb != null &&
          _matchesVerbFormAt(
            builder.tokens,
            current + 1,
            passiveVerb.pastParticiple,
          )) {
        builder.action = passiveVerb;
        builder.aspect = Aspect.continuous;
        builder.verbChainEnd = passiveMatch!.end;
      }

      return;
    }

    final match = _lookupVerbAt(builder.tokens, current);
    final verb = match?.verb;

    if (verb == null) {
      return;
    }

    if (_matchesVerbFormAt(builder.tokens, current, verb.ingForm)) {
      builder.action = verb;
      builder.aspect = Aspect.continuous;
      builder.verbChainEnd = match!.end;
      return;
    }

    if (_matchesVerbFormAt(builder.tokens, current, verb.pastParticiple)) {
      builder.action = verb;
      builder.verbChainEnd = match!.end;
    }
  }

  void _recognizeLexicalBeAfterBe(
    _RecognitionBuilder builder,
    int beIndex,
    int complementStart,
  ) {
    final start = _skipNot(builder, complementStart);

    if (start < builder.tokens.length &&
        builder.tokens[start].toLowerCase() == 'being') {
      _recognizeLexicalBeComplement(
        builder,
        beIndex,
        start + 1,
        aspect: Aspect.continuous,
        verbChainEnd: start,
      );
      return;
    }

    _recognizeLexicalBeComplement(
      builder,
      beIndex,
      start,
      aspect: Aspect.simple,
      verbChainEnd: beIndex,
    );
  }

  void _recognizeLexicalBeAfterBeen(
    _RecognitionBuilder builder,
    int beenIndex,
    int complementStart,
  ) {
    final start = _skipNot(builder, complementStart);

    if (start < builder.tokens.length &&
        builder.tokens[start].toLowerCase() == 'being') {
      _recognizeLexicalBeComplement(
        builder,
        beenIndex,
        start + 1,
        aspect: Aspect.perfectContinuous,
        verbChainEnd: start,
      );
      return;
    }

    _recognizeLexicalBeComplement(
      builder,
      beenIndex,
      start,
      aspect: Aspect.perfect,
      verbChainEnd: beenIndex,
    );
  }

  int _skipNot(_RecognitionBuilder builder, int index) {
    if (index < builder.tokens.length &&
        builder.tokens[index].toLowerCase() == 'not') {
      return index + 1;
    }

    return index;
  }

  void _recognizeLexicalBeComplement(
    _RecognitionBuilder builder,
    int beIndex,
    int complementStart, {
    required Aspect aspect,
    required int verbChainEnd,
  }) {
    builder.action = be;
    builder.aspect = aspect;
    builder.verbChainEnd = verbChainEnd;
    builder.complementStart = complementStart;

    if (builder.complementStart < builder.tokens.length &&
        builder.tokens[builder.complementStart].toLowerCase() == 'not') {
      builder.complementStart++;
    }

    builder.complementEnd = builder.tokens.length - 1;
  }

  Verb? _lookupVerb(String token) {
    final normalized = token.toLowerCase();

    for (final verb in verbs) {
      if (_findVerb(verb, normalized)) {
        return verb;
      }
    }

    return null;
  }

  bool _findVerb(Verb verb, String token) {
    return token == verb.infinitive ||
        token == verb.presentThirdPerson ||
        token == verb.pastSimple ||
        token == verb.pastParticiple ||
        token == verb.ingForm;
  }

  _VerbMatch? _lookupVerbAt(List<String> tokens, int start) {
    _VerbMatch? best;

    for (final verb in verbs) {
      for (final form in [
        verb.infinitive,
        verb.presentThirdPerson,
        verb.pastSimple,
        verb.pastParticiple,
        verb.ingForm,
      ]) {
        if (!_matchesVerbFormAt(tokens, start, form)) {
          continue;
        }

        final length = form.split(' ').length;
        if (best == null || length > best.length) {
          best = _VerbMatch(verb, start + length - 1, length);
        }
      }
    }

    return best;
  }

  bool _matchesVerbFormAt(List<String> tokens, int start, String form) {
    final words = form.toLowerCase().split(' ');

    if (start + words.length > tokens.length) {
      return false;
    }

    for (var i = 0; i < words.length; i++) {
      if (tokens[start + i].toLowerCase() != words[i]) {
        return false;
      }
    }

    return true;
  }

  bool _isPredicateLexicalVerb(_RecognitionBuilder builder, int index) {
    final verb = _lookupVerbAt(builder.tokens, index)?.verb;

    if (verb == null) {
      return false;
    }

    if (_looksLikeNounPhraseToken(builder, index)) {
      return false;
    }

    return true;
  }

  bool _looksLikeNounPhraseToken(_RecognitionBuilder builder, int index) {
    if (index == 0) {
      return false;
    }

    final previous = builder.tokens[index - 1].toLowerCase();

    return _lookupDeterminer(previous) != null ||
        _lookupAdjective(previous) != null;
  }

  bool _shouldYieldToLaterPredicate(_RecognitionBuilder builder, int index) {
    if (index != 0) {
      return false;
    }

    for (var i = index + 1; i < builder.tokens.length; i++) {
      if (_startsAuxiliaryPredicate(builder.tokens[i])) {
        return true;
      }
    }

    return false;
  }

  bool _startsAuxiliaryPredicate(String token) {
    final normalized = token.toLowerCase();

    return _lookupModal(normalized) != null ||
        switch (normalized) {
          'do' ||
          'does' ||
          'did' ||
          'have' ||
          'has' ||
          'had' ||
          'am' ||
          'is' ||
          'are' ||
          'was' ||
          'were' => true,
          _ => false,
        };
  }

  bool _hasThirdPersonSingularSubjectBefore(
    _RecognitionBuilder builder,
    int verbIndex,
  ) {
    if (verbIndex <= 0) {
      return false;
    }

    final subjectTokens = builder.tokens.sublist(0, verbIndex);
    final first = subjectTokens.first.toLowerCase();
    final last = subjectTokens.last.toLowerCase();

    if (first == 'he' || first == 'she' || first == 'it') {
      return true;
    }

    if (subjectTokens.length == 1) {
      final original = subjectTokens.single;
      return original.isNotEmpty && original[0].toUpperCase() == original[0];
    }

    if (first == 'a' ||
        first == 'an' ||
        first == 'this' ||
        first == 'that' ||
        first == 'each' ||
        first == 'every') {
      return true;
    }

    if (first == 'the') {
      return !_looksPluralNounText(last);
    }

    return false;
  }

  bool _looksPluralNounText(String text) {
    return text.endsWith('s') ||
        switch (text) {
          'children' || 'men' || 'women' || 'mice' || 'sheep' || 'fish' => true,
          _ => false,
        };
  }

  void _recognizePolarityBetween(
    _RecognitionBuilder builder,
    int start,
    int end,
  ) {
    for (var i = start; i < end; i++) {
      if (builder.tokens[i].toLowerCase() == 'not') {
        builder.polarity = Polarity.negative;
        return;
      }
    }
  }

  Modal? _lookupModal(String token) {
    final normalized = token.toLowerCase();

    if (normalized == 'cannot') {
      return can;
    }

    for (final modal in modals) {
      if (normalized == modal.text) {
        return modal;
      }
    }

    return null;
  }

  bool _isModalUse(_RecognitionBuilder builder, int index, Modal modal) {
    if (modal != need) {
      return true;
    }

    if (builder.sentenceForm == SentenceForm.question && index == 0) {
      for (
        var current = index + 1;
        current < builder.tokens.length;
        current++
      ) {
        if (_isPredicateLexicalVerb(builder, current)) {
          return true;
        }
      }

      return false;
    }

    var current = index + 1;
    if (current < builder.tokens.length &&
        builder.tokens[current].toLowerCase() == 'not') {
      current++;
    }

    if (current >= builder.tokens.length) {
      return false;
    }

    final token = builder.tokens[current].toLowerCase();
    return token == 'have' ||
        token == 'be' ||
        _isPredicateLexicalVerb(builder, current);
  }

  int _participantEnd(_RecognitionBuilder builder) {
    var end = builder.verbChainEnd - 1;

    while (end >= 0) {
      switch (builder.tokens[end].toLowerCase()) {
        case 'not':
        case 'be':
        case 'been':
        case 'being':
        case 'have':
        case 'has':
        case 'had':
          end--;
          continue;
      }

      break;
    }

    return end;
  }

  int _subjectEndBeforePredicate(
    _RecognitionBuilder builder,
    int predicateStart,
  ) {
    var end = predicateStart - 1;

    while (end >= builder.subjectStart) {
      switch (builder.tokens[end].toLowerCase()) {
        case 'not':
        case 'be':
        case 'been':
        case 'being':
        case 'have':
        case 'has':
        case 'had':
          end--;
          continue;
      }

      break;
    }

    return end;
  }

  // -------------------------------------------------------
  // VOICE
  // -------------------------------------------------------

  void _recognizeVoice(_RecognitionBuilder builder) {
    if (builder.action == null) {
      return;
    }

    final verbToken = builder.tokens[builder.verbChainEnd].toLowerCase();

    if (verbToken == builder.action!.pastParticiple) {
      for (var i = builder.verbChainStart; i < builder.verbChainEnd; i++) {
        switch (builder.tokens[i].toLowerCase()) {
          case 'be':
          case 'am':
          case 'is':
          case 'are':
          case 'was':
          case 'were':
          case 'been':
          case 'being':
            builder.voice = Voice.passive;
            return;
        }
      }
    }

    builder.voice = Voice.active;
  }

  // -------------------------------------------------------
  // PARTICIPANTS
  // -------------------------------------------------------

  void _recognizeParticipantBoundaries(_RecognitionBuilder builder) {
    if (builder.verbChainStart < 0 || builder.verbChainEnd < 0) {
      return;
    }

    if (builder.voice == Voice.active) {
      _recognizeActiveParticipants(builder);
    } else {
      _recognizePassiveParticipants(builder);
    }
  }

  void _recognizeActiveParticipants(_RecognitionBuilder builder) {
    if (builder.sentenceForm == SentenceForm.imperative) {
      builder.agent = you;
    } else if (builder.sentenceForm == SentenceForm.question &&
        builder.verbChainStart == 0) {
      builder.agentStart = builder.subjectStart;
      builder.agentEnd = builder.subjectEnd >= builder.subjectStart
          ? builder.subjectEnd
          : _participantEnd(builder);
    } else {
      builder.agentStart = 0;
      builder.agentEnd = builder.verbChainStart - 1;
    }

    if (builder.action?.takesObject != true) {
      return;
    }

    if (builder.verbChainEnd < builder.tokens.length - 1) {
      if (_startsNonParticipantPhrase(builder, builder.verbChainEnd + 1)) {
        return;
      }

      if (builder.action?.takesObjectComplement == true &&
          _recognizeActiveObjectComplement(builder)) {
        return;
      }

      if (builder.action?.takesRecipient == true) {
        _recognizeActiveRecipientAndObject(builder);
        return;
      }

      builder.objectStart = builder.verbChainEnd + 1;
      builder.objectEnd = builder.tokens.length - 1;
    }
  }

  bool _startsNonParticipantPhrase(_RecognitionBuilder builder, int start) {
    if (start >= builder.tokens.length) {
      return false;
    }

    final tokens = builder.tokens.sublist(start);

    for (final phrase in timePhrases) {
      if (_phraseWordIndex(tokens, phrase.text) == 0) {
        return true;
      }
    }

    for (final phrase in placePhrases) {
      for (final preposition in phrase.prepositions.values) {
        if (_placePhraseWordIndex(tokens, phrase, preposition) == 0) {
          return true;
        }
      }
    }

    for (final phrase in frequencyPhrases) {
      if (_phraseWordIndex(tokens, phrase.text) == 0) {
        return true;
      }
    }

    for (final phrase in mannerPhrases) {
      if (_phraseWordIndex(tokens, phrase.text) == 0) {
        return true;
      }
    }

    return false;
  }

  bool _recognizeActiveObjectComplement(_RecognitionBuilder builder) {
    final participantStart = builder.verbChainEnd + 1;
    final objectEnd = _nounPhraseEnd(builder, participantStart);
    final complementStart = objectEnd + 1;

    if (objectEnd < participantStart ||
        complementStart > builder.tokens.length - 1) {
      return false;
    }

    if (!_looksLikeObjectComplement(builder, complementStart)) {
      return false;
    }

    builder.objectStart = participantStart;
    builder.objectEnd = objectEnd;
    builder.objectComplementStart = complementStart;
    builder.objectComplementEnd = builder.tokens.length - 1;
    return true;
  }

  bool _looksLikeObjectComplement(_RecognitionBuilder builder, int start) {
    if (start >= builder.tokens.length) {
      return false;
    }

    final token = builder.tokens[start].toLowerCase();
    if (token == 'to' || token == 'for' || token == 'by') {
      return false;
    }

    if (_lookupAdjective(builder.tokens[start]) != null) {
      return true;
    }

    if (builder.action?.takesRecipient == true &&
        _lookupDeterminer(builder.tokens[start]) != null) {
      return false;
    }

    return true;
  }

  void _recognizeActiveRecipientAndObject(_RecognitionBuilder builder) {
    final participantStart = builder.verbChainEnd + 1;
    final prepositionMatch = _recipientPrepositionMatch(
      builder,
      participantStart,
    );
    final prepositionIndex = prepositionMatch?.index ?? -1;

    if (prepositionIndex == participantStart &&
        builder.action?.takesAddressee == true) {
      return;
    }

    if (prepositionIndex > participantStart &&
        prepositionIndex < builder.tokens.length - 1) {
      builder.objectStart = participantStart;
      builder.objectEnd = prepositionIndex - 1;
      builder.recipientStart = prepositionIndex + 1;
      builder.recipientEnd = builder.tokens.length - 1;
      builder.recipientPlacement = RecipientPlacement.toPhrase;
      builder.recipientPreposition = prepositionMatch!.preposition;
      return;
    }

    final recipientEnd = _nounPhraseEnd(builder, participantStart);
    final objectStart = recipientEnd + 1;

    if (recipientEnd < participantStart ||
        objectStart > builder.tokens.length - 1) {
      builder.objectStart = participantStart;
      builder.objectEnd = builder.tokens.length - 1;
      return;
    }

    builder.recipientStart = participantStart;
    builder.recipientEnd = recipientEnd;
    builder.objectStart = objectStart;
    builder.objectEnd = builder.tokens.length - 1;
    builder.recipientPlacement = RecipientPlacement.beforeObject;
    builder.recipientPreposition = RecipientPreposition.to;
  }

  _RecipientPrepositionMatch? _recipientPrepositionMatch(
    _RecognitionBuilder builder,
    int start,
  ) {
    for (var index = start; index < builder.tokens.length; index++) {
      final token = builder.tokens[index].toLowerCase();
      if (token == 'to') {
        return _RecipientPrepositionMatch(index, RecipientPreposition.to);
      }
      if (token == 'for') {
        return _RecipientPrepositionMatch(
          index,
          RecipientPreposition.forBenefit,
        );
      }
    }

    return null;
  }

  int _nounPhraseEnd(_RecognitionBuilder builder, int start) {
    if (start >= builder.tokens.length) {
      return -1;
    }

    var current = start;

    if (_startsStandalonePronounPhrase(builder, current)) {
      return current;
    }

    if (_lookupDeterminer(builder.tokens[current]) != null &&
        current + 1 < builder.tokens.length) {
      current++;
    }

    while (_lookupAdjective(builder.tokens[current]) != null &&
        current + 1 < builder.tokens.length) {
      current++;
    }

    return current;
  }

  bool _startsStandalonePronounPhrase(_RecognitionBuilder builder, int index) {
    final token = builder.tokens[index].toLowerCase();

    if (token == 'i' ||
        token == 'you' ||
        token == 'he' ||
        token == 'she' ||
        token == 'it' ||
        token == 'we' ||
        token == 'they' ||
        token == 'me' ||
        token == 'him' ||
        token == 'us' ||
        token == 'them') {
      return true;
    }

    if (token == 'her') {
      return index == builder.tokens.length - 1 ||
          _lookupDeterminer(builder.tokens[index + 1]) != null;
    }

    return false;
  }

  void _recognizePassiveParticipants(_RecognitionBuilder builder) {
    final byIndex = builder.tokens.indexWhere(
      (token) => token.toLowerCase() == 'by',
    );

    if (builder.action?.takesRecipient == true &&
        !_hasPassiveObjectComplementTail(builder, byIndex)) {
      _recognizePassiveRecipientFrame(builder, byIndex);
      return;
    }

    if (builder.sentenceForm == SentenceForm.question &&
        builder.verbChainStart == 0) {
      builder.objectStart = builder.subjectStart;
      builder.objectEnd = builder.subjectEnd >= builder.subjectStart
          ? builder.subjectEnd
          : _participantEnd(builder);
    } else {
      builder.objectStart = 0;
      builder.objectEnd = builder.verbChainStart - 1;
    }

    if (builder.action?.takesObjectComplement == true) {
      final complementStart = builder.verbChainEnd + 1;
      final complementEnd = byIndex >= 0
          ? byIndex - 1
          : builder.tokens.length - 1;

      if (complementStart <= complementEnd &&
          _looksLikeObjectComplement(builder, complementStart)) {
        builder.objectComplementStart = complementStart;
        builder.objectComplementEnd = complementEnd;
      }
    }

    if (byIndex >= 0) {
      builder.agentStart = byIndex + 1;
      builder.agentEnd = builder.tokens.length - 1;
    }
  }

  bool _hasPassiveObjectComplementTail(
    _RecognitionBuilder builder,
    int byIndex,
  ) {
    if (builder.action?.takesObjectComplement != true) {
      return false;
    }

    final complementStart = builder.verbChainEnd + 1;
    final complementEnd = byIndex >= 0
        ? byIndex - 1
        : builder.tokens.length - 1;

    return complementStart <= complementEnd &&
        _looksLikeObjectComplement(builder, complementStart);
  }

  void _recognizePassiveRecipientFrame(
    _RecognitionBuilder builder,
    int byIndex,
  ) {
    final prepositionMatch = _recipientPrepositionMatch(
      builder,
      builder.verbChainEnd + 1,
    );
    final prepositionIndex = prepositionMatch?.index ?? -1;

    if (prepositionIndex >= 0 && (byIndex < 0 || prepositionIndex < byIndex)) {
      builder.passiveFocus = PassiveFocus.object;
      _recognizePassiveObjectSubject(builder);
      builder.recipientStart = prepositionIndex + 1;
      builder.recipientEnd = byIndex >= 0
          ? byIndex - 1
          : builder.tokens.length - 1;
      builder.recipientPreposition = prepositionMatch!.preposition;
    } else {
      builder.passiveFocus = PassiveFocus.recipient;
      _recognizePassiveRecipientSubject(builder);

      if (builder.verbChainEnd < builder.tokens.length - 1) {
        builder.objectStart = builder.verbChainEnd + 1;
        builder.objectEnd = byIndex >= 0
            ? byIndex - 1
            : builder.tokens.length - 1;
      }
    }

    if (byIndex >= 0) {
      builder.agentStart = byIndex + 1;
      builder.agentEnd = builder.tokens.length - 1;
    }
  }

  void _recognizePassiveObjectSubject(_RecognitionBuilder builder) {
    if (builder.sentenceForm == SentenceForm.question &&
        builder.verbChainStart == 0) {
      builder.objectStart = builder.subjectStart;
      builder.objectEnd = builder.subjectEnd >= builder.subjectStart
          ? builder.subjectEnd
          : _participantEnd(builder);
    } else {
      builder.objectStart = 0;
      builder.objectEnd = builder.verbChainStart - 1;
    }
  }

  void _recognizePassiveRecipientSubject(_RecognitionBuilder builder) {
    if (builder.sentenceForm == SentenceForm.question &&
        builder.verbChainStart == 0) {
      builder.recipientStart = builder.subjectStart;
      builder.recipientEnd = builder.subjectEnd >= builder.subjectStart
          ? builder.subjectEnd
          : _participantEnd(builder);
    } else {
      builder.recipientStart = 0;
      builder.recipientEnd = builder.verbChainStart - 1;
    }
  }

  void _trimParticipantBoundaries(_RecognitionBuilder builder) {
    _trimFrontPhrases(builder);

    final starts = <int>[
      builder.timePhraseStart,
      builder.placePhraseStart,
      builder.addresseeStart > 0 ? builder.addresseeStart - 1 : -1,
      builder.companionStart > 0 ? builder.companionStart - 1 : -1,
      if (builder.frequencyPhrase?.position != PhrasePosition.beforeSubject)
        builder.frequencyPhraseStart,
      builder.mannerPhraseStart,
    ]..removeWhere((e) => e < 0);

    if (starts.isEmpty) {
      return;
    }

    final firstPhraseStart = starts.reduce((a, b) => a < b ? a : b);

    if (_crossesPhrase(
      builder.objectStart,
      builder.objectEnd,
      firstPhraseStart,
    )) {
      builder.objectEnd = firstPhraseStart - 1;
    }

    if (_crossesPhrase(
      builder.objectComplementStart,
      builder.objectComplementEnd,
      firstPhraseStart,
    )) {
      builder.objectComplementEnd = firstPhraseStart - 1;
    }

    if (_crossesPhrase(
      builder.recipientStart,
      builder.recipientEnd,
      firstPhraseStart,
    )) {
      builder.recipientEnd = firstPhraseStart - 1;
    }

    if (_crossesPhrase(
      builder.addresseeStart,
      builder.addresseeEnd,
      firstPhraseStart,
    )) {
      builder.addresseeEnd = firstPhraseStart - 1;
    }

    if (_crossesPhrase(
      builder.companionStart,
      builder.companionEnd,
      firstPhraseStart,
    )) {
      builder.companionEnd = firstPhraseStart - 1;
    }

    if (_crossesPhrase(
      builder.agentStart,
      builder.agentEnd,
      firstPhraseStart,
    )) {
      builder.agentEnd = firstPhraseStart - 1;
    }

    if (_crossesPhrase(
      builder.complementStart,
      builder.complementEnd,
      firstPhraseStart,
    )) {
      builder.complementEnd = firstPhraseStart - 1;
    }
  }

  bool _crossesPhrase(int start, int end, int phraseStart) {
    return start >= 0 && start <= phraseStart && end >= phraseStart;
  }

  void _trimFrontPhrases(_RecognitionBuilder builder) {
    final frontPhraseEnds = <int>[];

    if (builder.frequencyPhrase?.position == PhrasePosition.beforeSubject) {
      frontPhraseEnds.add(builder.frequencyPhraseEnd);
    }

    if (frontPhraseEnds.isEmpty) {
      return;
    }

    final frontPhraseEnd = frontPhraseEnds.reduce((a, b) => a > b ? a : b);

    if (builder.agentStart >= 0 && builder.agentStart <= frontPhraseEnd) {
      builder.agentStart = frontPhraseEnd + 1;
    }

    if (builder.objectStart >= 0 && builder.objectStart <= frontPhraseEnd) {
      builder.objectStart = frontPhraseEnd + 1;
    }

    if (builder.objectComplementStart >= 0 &&
        builder.objectComplementStart <= frontPhraseEnd) {
      builder.objectComplementStart = frontPhraseEnd + 1;
    }

    if (builder.recipientStart >= 0 &&
        builder.recipientStart <= frontPhraseEnd) {
      builder.recipientStart = frontPhraseEnd + 1;
    }

    if (builder.addresseeStart >= 0 &&
        builder.addresseeStart <= frontPhraseEnd) {
      builder.addresseeStart = frontPhraseEnd + 1;
    }

    if (builder.companionStart >= 0 &&
        builder.companionStart <= frontPhraseEnd) {
      builder.companionStart = frontPhraseEnd + 1;
    }

    if (builder.complementStart >= 0 &&
        builder.complementStart <= frontPhraseEnd) {
      builder.complementStart = frontPhraseEnd + 1;
    }
  }

  void _buildParticipants(_RecognitionBuilder builder) {
    if (builder.agentStart >= 0 && builder.agentEnd >= builder.agentStart) {
      builder.agent = _recognizeNounPhrase(
        builder.tokens.sublist(builder.agentStart, builder.agentEnd + 1),
      );
    }

    if (builder.objectStart >= 0 && builder.objectEnd >= builder.objectStart) {
      builder.object = _recognizeNounPhrase(
        builder.tokens.sublist(builder.objectStart, builder.objectEnd + 1),
      );
    }

    if (builder.objectComplementStart >= 0 &&
        builder.objectComplementEnd >= builder.objectComplementStart) {
      final objectComplementTokens = builder.tokens.sublist(
        builder.objectComplementStart,
        builder.objectComplementEnd + 1,
      );

      if (objectComplementTokens.length == 1) {
        builder.objectAdjectiveComplement = _lookupAdjective(
          objectComplementTokens.single,
        );
      }

      if (builder.objectAdjectiveComplement == null) {
        builder.objectComplement = _recognizeNounPhrase(objectComplementTokens);
      }
    }

    if (builder.recipientStart >= 0 &&
        builder.recipientEnd >= builder.recipientStart) {
      builder.recipient = _recognizeNounPhrase(
        builder.tokens.sublist(
          builder.recipientStart,
          builder.recipientEnd + 1,
        ),
      );
    }

    if (builder.addresseeStart >= 0 &&
        builder.addresseeEnd >= builder.addresseeStart) {
      builder.addressee = _recognizeNounPhrase(
        builder.tokens.sublist(
          builder.addresseeStart,
          builder.addresseeEnd + 1,
        ),
      );
    }

    if (builder.companionStart >= 0 &&
        builder.companionEnd >= builder.companionStart) {
      builder.companion = _recognizeNounPhrase(
        builder.tokens.sublist(
          builder.companionStart,
          builder.companionEnd + 1,
        ),
      );
    }

    if (builder.complementStart >= 0 &&
        builder.complementEnd >= builder.complementStart) {
      final complementTokens = builder.tokens.sublist(
        builder.complementStart,
        builder.complementEnd + 1,
      );

      if (complementTokens.length == 1) {
        builder.adjectiveComplement = _lookupAdjective(complementTokens.single);
      }

      if (builder.adjectiveComplement == null) {
        builder.complement = _recognizeNounPhrase(complementTokens);
      }
    }
  }

  NounPhrase _recognizeNounPhrase(List<String> tokens) {
    Determiner? determiner;
    final recognizedAdjectives = <Adjective>[];

    final remaining = [...tokens];

    if (remaining.length > 1) {
      determiner = _lookupDeterminer(remaining.first);

      if (determiner != null) {
        remaining.removeAt(0);
      }
    }

    while (remaining.isNotEmpty) {
      final adjective = _lookupAdjective(remaining.first);

      if (adjective == null) {
        break;
      }

      recognizedAdjectives.add(adjective);
      remaining.removeAt(0);
    }

    final text = remaining.join(' ').toLowerCase();

    return NounPhrase(
      text: _recognizedNounText(text),
      person: _recognizedPerson(text),
      number: _recognizedNumber(text),
      determiner: determiner,
      adjective: recognizedAdjectives.isNotEmpty
          ? recognizedAdjectives.first
          : null,
      adjectives: recognizedAdjectives,
      translations: const {},
    );
  }

  String _recognizedNounText(String text) {
    final fixedObject = _lookupFixedObject(text);

    if (fixedObject != null) {
      return fixedObject.text;
    }

    final noun = _lookupNoun(text);

    if (noun != null) {
      return text.toLowerCase() == noun.plural.toLowerCase()
          ? noun.plural
          : noun.singular;
    }

    return switch (text) {
      'i' => 'I',
      _ => text,
    };
  }

  Person _recognizedPerson(String text) {
    return switch (text) {
      'i' || 'me' || 'myself' || 'we' || 'us' || 'ourselves' => Person.first,
      'you' || 'yourself' || 'yourselves' => Person.second,
      _ => Person.third,
    };
  }

  Number _recognizedNumber(String text) {
    final noun = _lookupNoun(text);

    if (noun != null && text.toLowerCase() == noun.plural.toLowerCase()) {
      return Number.plural;
    }

    return switch (text) {
      'we' ||
      'us' ||
      'ourselves' ||
      'they' ||
      'them' ||
      'themselves' => Number.plural,
      'yourselves' => Number.plural,
      _ when _looksPluralNounText(text) => Number.plural,
      _ => Number.singular,
    };
  }

  Noun? _lookupNoun(String text) {
    final normalized = text.toLowerCase();

    for (final noun in _knownNouns) {
      if (normalized == noun.singular.toLowerCase() ||
          normalized == noun.plural.toLowerCase()) {
        return noun;
      }
    }

    return null;
  }

  NounPhrase? _lookupFixedObject(String text) {
    final normalized = text.toLowerCase();

    for (final object in _knownFixedObjects) {
      if (normalized == object.text.toLowerCase()) {
        return object;
      }
    }

    return null;
  }

  Adjective? _lookupAdjective(String token) {
    for (final adjective in adjectives) {
      if (adjective.text.toLowerCase() == token.toLowerCase()) {
        return adjective;
      }
    }

    return null;
  }

  Determiner? _lookupDeterminer(String token) {
    for (final determiner in allDeterminers) {
      if (determiner.text == token.toLowerCase()) {
        return determiner;
      }
    }

    return null;
  }

  // -------------------------------------------------------
  // PHRASES
  // -------------------------------------------------------

  void _recognizePhrases(_RecognitionBuilder builder) {
    final phraseTokens = _remainingPhraseTokens(builder);

    _recognizeTimePhrase(builder, phraseTokens);
    _recognizePlacePhrase(builder, phraseTokens);
    _recognizeFrequencyPhrase(builder, phraseTokens);
    _recognizeAddresseePhrase(builder, phraseTokens);
    _recognizeCompanionPhrase(builder, phraseTokens);
    _recognizeMannerPhrase(builder, phraseTokens);
  }

  List<String> _remainingPhraseTokens(_RecognitionBuilder builder) {
    final remaining = <String>[];

    for (var i = builder.verbChainEnd + 1; i < builder.tokens.length; i++) {
      remaining.add(builder.tokens[i]);
    }

    return remaining;
  }

  void _recognizeTimePhrase(_RecognitionBuilder builder, List<String> tokens) {
    for (final phrase in timePhrases) {
      final phraseText = phrase.text.toLowerCase();

      final wordsBefore = _phraseWordIndex(tokens, phraseText);

      if (wordsBefore < 0) {
        continue;
      }

      builder.timePhrase = phrase;

      builder.timePhraseStart = builder.verbChainEnd + 1 + wordsBefore;

      builder.timePhraseEnd =
          builder.timePhraseStart + phrase.text.split(' ').length - 1;
      return;
    }
  }

  void _recognizePlacePhrase(_RecognitionBuilder builder, List<String> tokens) {
    for (final phrase in placePhrases) {
      for (final entry in phrase.prepositions.entries) {
        final meaning = entry.key;
        final preposition = entry.value;
        final wordsBefore = _placePhraseWordIndex(tokens, phrase, preposition);

        if (wordsBefore < 0) {
          continue;
        }

        builder.placePhrase = phrase;
        builder.placeMeaning = meaning;

        final phraseLength =
            (preposition != null ? 1 : 0) +
            (phrase.takesArticle ? 1 : 0) +
            phrase.noun.split(' ').length;

        builder.placePhraseStart = builder.verbChainEnd + 1 + wordsBefore;

        builder.placePhraseEnd = builder.placePhraseStart + phraseLength - 1;

        return;
      }
    }
  }

  int _placePhraseWordIndex(
    List<String> tokens,
    PlacePhrase phrase,
    Preposition? preposition,
  ) {
    final expected = <String>[];

    if (preposition != null) {
      expected.add(preposition.text);
    }

    if (phrase.takesArticle) {
      expected.add('the');
    }

    expected.addAll(phrase.noun.toLowerCase().split(' '));

    return _phraseWordIndex(tokens, expected.join(' '));
  }

  int _phraseWordIndex(List<String> tokens, String phraseText) {
    final phraseWords = phraseText.toLowerCase().split(' ');

    for (var i = 0; i <= tokens.length - phraseWords.length; i++) {
      var matches = true;

      for (var j = 0; j < phraseWords.length; j++) {
        if (tokens[i + j].toLowerCase() != phraseWords[j]) {
          matches = false;
          break;
        }
      }

      if (matches) {
        return i;
      }
    }

    return -1;
  }

  void _recognizeFrequencyPhrase(
    _RecognitionBuilder builder,
    List<String> tokens,
  ) {
    for (final phrase in frequencyPhrases) {
      final phraseText = phrase.text.toLowerCase();

      final wordsBefore = phrase.position == PhrasePosition.beforeSubject
          ? _phraseWordIndex(builder.tokens, phraseText)
          : _phraseWordIndex(tokens, phraseText);

      if (wordsBefore < 0) {
        continue;
      }

      builder.frequencyPhrase = phrase;

      builder.frequencyPhraseStart =
          (phrase.position == PhrasePosition.beforeSubject
              ? 0
              : builder.verbChainEnd + 1) +
          wordsBefore;

      builder.frequencyPhraseEnd =
          builder.frequencyPhraseStart + phrase.text.split(' ').length - 1;

      return;
    }
  }

  void _recognizeCompanionPhrase(
    _RecognitionBuilder builder,
    List<String> tokens,
  ) {
    if (builder.action != be && builder.action?.takesCompanion != true) {
      return;
    }

    final wordsBefore = _phraseWordIndex(tokens, 'with');

    if (wordsBefore < 0) {
      return;
    }

    final withIndex = builder.verbChainEnd + 1 + wordsBefore;
    final companionStart = withIndex + 1;

    if (!_looksLikeCompanionPhrase(builder, companionStart)) {
      return;
    }

    builder.companionStart = companionStart;
    builder.companionEnd = _nounPhraseEnd(builder, companionStart);
  }

  void _recognizeAddresseePhrase(
    _RecognitionBuilder builder,
    List<String> tokens,
  ) {
    if (builder.action?.takesAddressee != true || builder.recipientStart >= 0) {
      return;
    }

    final wordsBefore = _phraseWordIndex(tokens, 'to');

    if (wordsBefore < 0) {
      return;
    }

    final toIndex = builder.verbChainEnd + 1 + wordsBefore;
    final addresseeStart = toIndex + 1;

    if (!_looksLikeCompanionPhrase(builder, addresseeStart)) {
      return;
    }

    builder.addresseeStart = addresseeStart;
    builder.addresseeEnd = _nounPhraseEnd(builder, addresseeStart);
  }

  bool _looksLikeCompanionPhrase(_RecognitionBuilder builder, int start) {
    if (start >= builder.tokens.length) {
      return false;
    }

    if (_startsStandalonePronounPhrase(builder, start)) {
      return true;
    }

    var current = start;
    if (_lookupDeterminer(builder.tokens[current]) != null &&
        current + 1 < builder.tokens.length) {
      current++;
    }

    while (_lookupAdjective(builder.tokens[current]) != null &&
        current + 1 < builder.tokens.length) {
      current++;
    }

    final text = builder.tokens[current].toLowerCase();
    return _lookupNoun(text) != null;
  }

  void _recognizeMannerPhrase(
    _RecognitionBuilder builder,
    List<String> tokens,
  ) {
    for (final phrase in mannerPhrases) {
      final phraseText = phrase.text.toLowerCase();

      final wordsBefore = _phraseWordIndex(tokens, phraseText);

      if (wordsBefore < 0) {
        continue;
      }

      builder.mannerPhrase = phrase;

      builder.mannerPhraseStart = builder.verbChainEnd + 1 + wordsBefore;

      builder.mannerPhraseEnd =
          builder.mannerPhraseStart + phrase.text.split(' ').length - 1;

      return;
    }
  }

  void _recognizeUnknownTokens(_RecognitionBuilder builder) {
    for (final token in builder.tokens) {
      if (token.toLowerCase() == 'not') continue;

      if (token.toLowerCase() == 'by') continue;

      if (token.toLowerCase() == 'to') continue;

      if (token.toLowerCase() == 'with') continue;

      if (_lookupVerb(token) != null) continue;

      if (_lookupModal(token) != null) continue;

      if (_lookupDeterminer(token) != null) continue;

      if (_lookupAdjective(token) != null) continue;

      builder.unknownTokens.add(token);
    }
  }
}

class _RecognitionBuilder {
  // ----------------------------
  // Input
  // ----------------------------

  final String sentence;

  String normalizedSentence = '';

  final List<String> tokens = [];

  // ----------------------------
  // Temporary parser state
  // ----------------------------

  int verbChainStart = -1;
  int verbChainEnd = -1;

  int agentStart = -1;
  int agentEnd = -1;

  int objectStart = -1;
  int objectEnd = -1;

  int objectComplementStart = -1;
  int objectComplementEnd = -1;

  int recipientStart = -1;
  int recipientEnd = -1;

  int addresseeStart = -1;
  int addresseeEnd = -1;

  int companionStart = -1;
  int companionEnd = -1;

  int complementStart = -1;
  int complementEnd = -1;

  int subjectStart = 0;
  int subjectEnd = -1;

  // ----------------------------
  // Recognized grammar
  // ----------------------------

  SentenceForm sentenceForm = SentenceForm.statement;

  Voice voice = Voice.active;
  PassiveFocus? passiveFocus;

  Tense tense = Tense.present;

  Aspect aspect = Aspect.simple;

  Modal modal = noModal;

  Polarity polarity = Polarity.positive;

  Verb? action;

  NounPhrase? agent;

  NounPhrase? object;
  NounPhrase? objectComplement;
  Adjective? objectAdjectiveComplement;
  NounPhrase? recipient;
  NounPhrase? addressee;
  NounPhrase? companion;
  RecipientPlacement recipientPlacement = RecipientPlacement.beforeObject;
  RecipientPreposition recipientPreposition = RecipientPreposition.to;
  NounPhrase? complement;
  Adjective? adjectiveComplement;

  TimePhrase? timePhrase;
  int timePhraseStart = -1;
  int timePhraseEnd = -1;

  PlacePhrase? placePhrase;
  PlaceMeaning? placeMeaning;
  int placePhraseStart = -1;
  int placePhraseEnd = -1;

  FrequencyPhrase? frequencyPhrase;
  int frequencyPhraseStart = -1;
  int frequencyPhraseEnd = -1;

  MannerPhrase? mannerPhrase;
  int mannerPhraseStart = -1;
  int mannerPhraseEnd = -1;

  _RecognitionBuilder(this.sentence);

  final List<String> unknownTokens = [];

  SentenceState get state {
    final fixedObjectAlias = fixedObjectVerbAliasFor(action!);

    return SentenceState(
      action: fixedObjectAlias?.action ?? action!,
      agent: agent,
      object: object ?? fixedObjectAlias?.object,
      objectComplement: objectComplement,
      objectAdjectiveComplement: objectAdjectiveComplement,
      recipient: recipient,
      addressee: addressee,
      companion: companion,
      recipientPlacement: recipientPlacement,
      recipientPreposition: recipientPreposition,
      complement: complement,
      adjectiveComplement: adjectiveComplement,
      voice: voice,
      passiveFocus: voice == Voice.passive
          ? passiveFocus ?? PassiveFocus.object
          : null,
      tense: tense,
      aspect: aspect,
      modal: modal,
      polarity: polarity,
      sentenceForm: sentenceForm,
      timePhrase: timePhrase,
      placePhrase: placePhrase,
      placeMeaning: placeMeaning,
      frequencyPhrase: frequencyPhrase,
      mannerPhrase: mannerPhrase,
    );
  }

  String debugSnapshot() {
    return [
      'sentence: $sentence',
      'normalized: $normalizedSentence',
      'tokens: $tokens',
      'sentenceForm: $sentenceForm',
      'verbChain: $verbChainStart -> $verbChainEnd (${_tokensBetween(verbChainStart, verbChainEnd)})',
      'subject: $subjectStart -> $subjectEnd (${_tokensBetween(subjectStart, subjectEnd)})',
      'agent: $agentStart -> $agentEnd (${_tokensBetween(agentStart, agentEnd)}) = ${agent?.text}',
      'recipient: $recipientStart -> $recipientEnd (${_tokensBetween(recipientStart, recipientEnd)}) = ${recipient?.text}',
      'addressee: $addresseeStart -> $addresseeEnd (${_tokensBetween(addresseeStart, addresseeEnd)}) = ${addressee?.text}',
      'companion: $companionStart -> $companionEnd (${_tokensBetween(companionStart, companionEnd)}) = ${companion?.text}',
      'recipientPlacement: $recipientPlacement',
      'recipientPreposition: $recipientPreposition',
      'object: $objectStart -> $objectEnd (${_tokensBetween(objectStart, objectEnd)}) = ${object?.text}',
      'objectComplement: $objectComplementStart -> $objectComplementEnd (${_tokensBetween(objectComplementStart, objectComplementEnd)}) = ${objectComplement?.text ?? objectAdjectiveComplement?.text}',
      'complement: $complementStart -> $complementEnd (${_tokensBetween(complementStart, complementEnd)}) = ${complement?.text ?? adjectiveComplement?.text}',
      'action: ${action?.infinitive}',
      'tense/aspect: $tense / $aspect',
      'voice: $voice',
      'passiveFocus: $passiveFocus',
      'modal: $modal',
      'polarity: $polarity',
      'phrases: time=${timePhrase?.text} [$timePhraseStart,$timePhraseEnd], place=${placePhrase?.noun}/${placeMeaning?.name} [$placePhraseStart,$placePhraseEnd], frequency=${frequencyPhrase?.text} [$frequencyPhraseStart,$frequencyPhraseEnd], manner=${mannerPhrase?.text} [$mannerPhraseStart,$mannerPhraseEnd]',
      'unknownTokens: $unknownTokens',
      if (action != null) 'state: ${state.summary}',
    ].join('\n');
  }

  String _tokensBetween(int start, int end) {
    if (start < 0 || end < start || start >= tokens.length) {
      return '';
    }

    final safeEnd = end >= tokens.length ? tokens.length - 1 : end;
    return tokens.sublist(start, safeEnd + 1).join(' ');
  }
}

class _VerbMatch {
  final Verb verb;
  final int end;
  final int length;

  const _VerbMatch(this.verb, this.end, this.length);
}

class _RecipientPrepositionMatch {
  final int index;
  final RecipientPreposition preposition;

  const _RecipientPrepositionMatch(this.index, this.preposition);
}

const _knownNouns = [
  john,
  mary,
  tom,
  anna,
  choir,
  teacher,
  student,
  doctor,
  nurse,
  engineer,
  worker,
  programmer,
  friend,
  neighbour,
  customer,
  manager,
  child,
  man,
  woman,
  boy,
  girl,
  czechia,
  house,
  apartment,
  car,
  bridge,
  bus,
  train,
  bicycle,
  phone,
  computer,
  laptop,
  keyboard,
  mouseDevice,
  monitor,
  television,
  book,
  newspaper,
  letter,
  story,
  gift,
  magazine,
  pen,
  pencil,
  table,
  chair,
  bed,
  door,
  window,
  key,
  bottle,
  cup,
  glass,
  ball,
  plate,
  spoon,
  fork,
  knife,
  cat,
  dog,
  horse,
  cow,
  pig,
  sheep,
  goat,
  chicken,
  duck,
  bird,
  fish,
  rabbit,
  mouse,
  bear,
  wolf,
  fox,
  lion,
  tiger,
  elephant,
  monkey,
  snake,
  turtle,
  bee,
  butterfly,
];

const _knownFixedObjects = [
  fixed_object.football,
  fixed_object.basketball,
  fixed_object.volleyball,
  fixed_object.tennis,
  fixed_object.golf,
  fixed_object.english,
  fixed_object.polish,
  fixed_object.spanish,
  fixed_object.math,
  fixed_object.history,
  fixed_object.science,
  fixed_object.grammar,
];
