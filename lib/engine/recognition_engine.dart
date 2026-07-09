import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/phrases/frequency_phrases.dart';
import 'package:padlock_app/data/phrases/manner_phrases.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/subjects/adjectives/essential_adjectives.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/engine/logger/engine_logger.dart';
import 'package:padlock_app/engine/logger/recognition_diagnostics.dart';
import 'package:padlock_app/models/grammar/passive_focus.dart';
import 'package:padlock_app/models/grammar/phrase/frequency_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/manner_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/place_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/time_phrase.dart';
import 'package:padlock_app/models/grammar/preposition.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/grammar/subject/adjective.dart';
import 'package:padlock_app/models/grammar/subject/determiner.dart';
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

    _normalize(builder);

    _tokenize(builder);

    _recognizeSentenceForm(builder);

    _recognizeVerbChain(builder);

    _recognizeVoice(builder);

    _recognizeParticipantBoundaries(builder);

    _recognizePhrases(builder);

    _trimParticipantBoundaries(builder);

    _buildParticipants(builder);

    _recognizeUnknownTokens(builder);

    logger.logRecognition(
      RecognitionDiagnostics(
        sentence: sentence,
        tokens: builder.tokens,
        verbChainStart: builder.verbChainStart,
        verbChainEnd: builder.verbChainEnd,
        state: builder.state,

        unknownTokens: builder.unknownTokens,
      ),
    );

    return builder.state;
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

      if (modal != null) {
        builder.modal = modal;
        builder.verbChainStart = i;

        if (modal == will) {
          builder.tense = Tense.future;
        } else {
          builder.tense = Tense.present;
        }

        var current = i + 1;
        if (builder.sentenceForm == SentenceForm.question && i == 0) {
          builder.subjectStart = current;

          while (current < builder.tokens.length) {
            if (_lookupVerb(builder.tokens[current]) != null) {
              break;
            }

            current++;
          }
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
          builder.aspect = Aspect.perfect;
          current++;

          if (current < builder.tokens.length &&
              builder.tokens[current].toLowerCase() == 'been') {
            builder.aspect = Aspect.perfectContinuous;
            current++;
            _recognizeVerbAfterBeen(builder, current);
          }
        } else if (current < builder.tokens.length &&
            builder.tokens[current].toLowerCase() == 'be') {
          current++;

          builder.aspect = Aspect.simple;

          if (current < builder.tokens.length) {
            final verb = _lookupVerb(builder.tokens[current]);

            if (verb != null &&
                builder.tokens[current].toLowerCase() == verb.ingForm) {
              builder.aspect = Aspect.continuous;
            }
          }
        } else {
          builder.aspect = Aspect.simple;
        }

        if (builder.action == null && current < builder.tokens.length) {
          final verb = _lookupVerb(builder.tokens[current]);

          if (verb != null) {
            builder.action = verb;
            builder.verbChainEnd = current;
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
            if (_lookupVerb(builder.tokens[current]) != null) {
              break;
            }

            current++;
          }
          _recognizePolarityBetween(builder, builder.subjectStart, current);
        } else {
          if (current < builder.tokens.length &&
              builder.tokens[current].toLowerCase() == 'not') {
            builder.polarity = Polarity.negative;
            current++;
          }
        }

        if (current < builder.tokens.length) {
          final verb = _lookupVerb(builder.tokens[current]);

          if (verb != null) {
            builder.action = verb;
            builder.verbChainEnd = current;
          }
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
            if (_lookupVerb(builder.tokens[current]) != null) {
              break;
            }

            current++;
          }
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
          final verb = _lookupVerb(builder.tokens[current]);

          if (verb != null) {
            builder.action = verb;
            builder.verbChainEnd = current;
          }
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
            if (_lookupVerb(builder.tokens[current]) != null) {
              break;
            }

            current++;
          }
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
          current++;
          _recognizeVerbAfterBeen(builder, current);
        } else if (current < builder.tokens.length) {
          // print(current);
          // print(builder.tokens[current]);
          final verb = _lookupVerb(builder.tokens[current]);

          if (verb != null) {
            builder.action = verb;
            builder.verbChainEnd = current;
          }
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
            if (_lookupVerb(builder.tokens[current]) != null) {
              break;
            }

            current++;
          }
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
          current++;
          _recognizeVerbAfterBeen(builder, current);
        } else if (current < builder.tokens.length) {
          final verb = _lookupVerb(builder.tokens[current]);

          if (verb != null) {
            builder.action = verb;
            builder.verbChainEnd = current;
          }
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
            if (_lookupVerb(builder.tokens[current]) != null) {
              break;
            }

            current++;
          }
          _recognizePolarityBetween(builder, builder.subjectStart, current);
        } else {
          if (current < builder.tokens.length &&
              builder.tokens[current].toLowerCase() == 'not') {
            builder.polarity = Polarity.negative;
            current++;
          }
        }

        if (current < builder.tokens.length) {
          final verb = _lookupVerb(builder.tokens[current]);

          if (verb != null) {
            builder.action = verb;

            if (builder.tokens[current].toLowerCase() == verb.ingForm) {
              builder.aspect = Aspect.continuous;
            } else {
              builder.aspect = Aspect.simple;
            }

            builder.verbChainEnd = current;
          }
        }
        break;
      }

      // -------------------------------------------------------
      // SIMPLE PRESENT / PAST
      // -------------------------------------------------------

      final verb = _lookupVerb(token);

      if (verb != null) {
        if (_looksLikeNounPhraseToken(builder, i) ||
            _shouldYieldToLaterPredicate(builder, i)) {
          continue;
        }

        builder.action = verb;
        builder.verbChainStart = i;
        builder.verbChainEnd = i;

        if (token == verb.infinitive) {
          builder.tense =
              token == verb.pastSimple &&
                  _hasThirdPersonSingularSubjectBefore(builder, i)
              ? Tense.past
              : Tense.present;
          builder.aspect = Aspect.simple;
        } else if (token == verb.presentThirdPerson) {
          builder.tense = Tense.present;
          builder.aspect = Aspect.simple;
        } else if (token == verb.pastSimple) {
          builder.tense = Tense.past;
          builder.aspect = Aspect.simple;
        }
        break;
      }
    }
  }

  void _recognizeVerbAfterBeen(_RecognitionBuilder builder, int current) {
    if (current >= builder.tokens.length) {
      return;
    }

    if (builder.tokens[current].toLowerCase() == 'being' &&
        current + 1 < builder.tokens.length) {
      final passiveVerb = _lookupVerb(builder.tokens[current + 1]);

      if (passiveVerb != null &&
          builder.tokens[current + 1].toLowerCase() ==
              passiveVerb.pastParticiple) {
        builder.action = passiveVerb;
        builder.aspect = Aspect.perfectContinuous;
        builder.verbChainEnd = current + 1;
      }

      return;
    }

    final verb = _lookupVerb(builder.tokens[current]);

    if (verb != null) {
      builder.action = verb;

      if (builder.tokens[current].toLowerCase() == verb.ingForm) {
        builder.aspect = Aspect.perfectContinuous;
      }

      builder.verbChainEnd = current;
    }
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

    for (final modal in modals) {
      if (normalized == modal.text) {
        return modal;
      }
    }

    return null;
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
    if (builder.sentenceForm == SentenceForm.question &&
        builder.verbChainStart == 0) {
      builder.agentStart = builder.subjectStart;
      builder.agentEnd = _participantEnd(builder);
    } else {
      builder.agentStart = 0;
      builder.agentEnd = builder.verbChainStart - 1;
    }

    if (builder.action?.takesObject != true) {
      return;
    }

    if (builder.verbChainEnd < builder.tokens.length - 1) {
      if (builder.action?.takesRecipient == true) {
        _recognizeActiveRecipientAndObject(builder);
        return;
      }

      builder.objectStart = builder.verbChainEnd + 1;
      builder.objectEnd = builder.tokens.length - 1;
    }
  }

  void _recognizeActiveRecipientAndObject(_RecognitionBuilder builder) {
    final participantStart = builder.verbChainEnd + 1;
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

    if (builder.action?.takesRecipient == true) {
      _recognizePassiveRecipientFrame(builder, byIndex);
      return;
    }

    if (builder.sentenceForm == SentenceForm.question &&
        builder.verbChainStart == 0) {
      builder.objectStart = builder.subjectStart;
      builder.objectEnd = _participantEnd(builder);
    } else {
      builder.objectStart = 0;
      builder.objectEnd = builder.verbChainStart - 1;
    }

    if (byIndex >= 0) {
      builder.agentStart = byIndex + 1;
      builder.agentEnd = builder.tokens.length - 1;
    }
  }

  void _recognizePassiveRecipientFrame(
    _RecognitionBuilder builder,
    int byIndex,
  ) {
    final toIndex = builder.tokens.indexWhere(
      (token) => token.toLowerCase() == 'to',
      builder.verbChainEnd + 1,
    );

    if (toIndex >= 0 && (byIndex < 0 || toIndex < byIndex)) {
      builder.passiveFocus = PassiveFocus.object;
      _recognizePassiveObjectSubject(builder);
      builder.recipientStart = toIndex + 1;
      builder.recipientEnd = byIndex >= 0
          ? byIndex - 1
          : builder.tokens.length - 1;
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
      builder.objectEnd = _participantEnd(builder);
    } else {
      builder.objectStart = 0;
      builder.objectEnd = builder.verbChainStart - 1;
    }
  }

  void _recognizePassiveRecipientSubject(_RecognitionBuilder builder) {
    if (builder.sentenceForm == SentenceForm.question &&
        builder.verbChainStart == 0) {
      builder.recipientStart = builder.subjectStart;
      builder.recipientEnd = _participantEnd(builder);
    } else {
      builder.recipientStart = 0;
      builder.recipientEnd = builder.verbChainStart - 1;
    }
  }

  void _trimParticipantBoundaries(_RecognitionBuilder builder) {
    final starts = <int>[
      builder.timePhraseStart,
      builder.placePhraseStart,
      builder.frequencyPhraseStart,
      builder.mannerPhraseStart,
    ]..removeWhere((e) => e < 0);

    if (starts.isEmpty) {
      return;
    }

    final firstPhraseStart = starts.reduce((a, b) => a < b ? a : b);

    if (builder.objectStart >= 0 && builder.objectEnd >= firstPhraseStart) {
      builder.objectEnd = firstPhraseStart - 1;
    }

    if (builder.recipientStart >= 0 &&
        builder.recipientEnd >= firstPhraseStart) {
      builder.recipientEnd = firstPhraseStart - 1;
    }

    if (builder.agentStart >= 0 && builder.agentEnd >= firstPhraseStart) {
      builder.agentEnd = firstPhraseStart - 1;
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

    if (builder.recipientStart >= 0 &&
        builder.recipientEnd >= builder.recipientStart) {
      builder.recipient = _recognizeNounPhrase(
        builder.tokens.sublist(
          builder.recipientStart,
          builder.recipientEnd + 1,
        ),
      );
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
    return switch (text) {
      'i' => 'I',
      _ => text,
    };
  }

  Person _recognizedPerson(String text) {
    return switch (text) {
      'i' || 'me' || 'we' || 'us' => Person.first,
      'you' => Person.second,
      _ => Person.third,
    };
  }

  Number _recognizedNumber(String text) {
    return switch (text) {
      'we' || 'us' || 'they' || 'them' => Number.plural,
      _ => Number.singular,
    };
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
      for (final preposition in phrase.prepositions.values) {
        final wordsBefore = _placePhraseWordIndex(tokens, phrase, preposition);

        if (wordsBefore < 0) {
          continue;
        }

        builder.placePhrase = phrase;

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

      final wordsBefore = _phraseWordIndex(tokens, phraseText);

      if (wordsBefore < 0) {
        continue;
      }

      builder.frequencyPhrase = phrase;

      builder.frequencyPhraseStart = builder.verbChainEnd + 1 + wordsBefore;

      builder.frequencyPhraseEnd =
          builder.frequencyPhraseStart + phrase.text.split(' ').length - 1;

      return;
    }
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

  int recipientStart = -1;
  int recipientEnd = -1;

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
  NounPhrase? recipient;

  TimePhrase? timePhrase;
  int timePhraseStart = -1;
  int timePhraseEnd = -1;

  PlacePhrase? placePhrase;
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

  SentenceState get state => SentenceState(
    action: action!,
    agent: agent,
    object: object,
    recipient: recipient,
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
    frequencyPhrase: frequencyPhrase,
    mannerPhrase: mannerPhrase,
  );
}
