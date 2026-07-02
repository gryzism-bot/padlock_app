import 'package:padlock_app/data/modals.dart';
import 'package:padlock_app/data/phrases/frequency_phrases.dart';
import 'package:padlock_app/data/phrases/manner_phrases.dart';
import 'package:padlock_app/data/phrases/place_phrases.dart';
import 'package:padlock_app/data/phrases/time_phrases.dart';
import 'package:padlock_app/data/subjects/determiners.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/models/grammar/phrase/frequency_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/manner_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/place_phrase.dart';
import 'package:padlock_app/models/grammar/phrase/time_phrase.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
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
  SentenceState recognize(String sentence) {
    final builder = _RecognitionBuilder(sentence);

    _normalize(builder);

    _tokenize(builder);

    _recognizeSentenceForm(builder);

    _recognizeVerbChain(builder);

    _recognizeVoice(builder);

    _recognizeParticipants(builder);

    _recognizePhrases(builder);

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

        var current = i + 1;

        if (current < builder.tokens.length &&
            builder.tokens[current].toLowerCase() == 'not') {
          builder.polarity = Polarity.negative;
          current++;
        }

        if (current < builder.tokens.length &&
            builder.tokens[current].toLowerCase() == 'have') {
          builder.aspect = Aspect.perfect;
          current++;

          if (current < builder.tokens.length &&
              builder.tokens[current].toLowerCase() == 'been') {
            builder.aspect = Aspect.perfectContinuous;
            current++;
          }
        } else if (current < builder.tokens.length &&
            builder.tokens[current].toLowerCase() == 'be') {
          builder.aspect = Aspect.continuous;
          current++;
        } else {
          builder.aspect = Aspect.simple;
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
      // DO / DOES
      // -------------------------------------------------------

      if (token == 'do' || token == 'does') {
        builder.tense = Tense.present;
        builder.aspect = Aspect.simple;
        builder.verbChainStart = i;

        var current = i + 1;

        if (current < builder.tokens.length &&
            builder.tokens[current].toLowerCase() == 'not') {
          builder.polarity = Polarity.negative;
          current++;
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

        if (current < builder.tokens.length &&
            builder.tokens[current].toLowerCase() == 'not') {
          builder.polarity = Polarity.negative;
          current++;
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

        if (current < builder.tokens.length &&
            builder.tokens[current].toLowerCase() == 'not') {
          builder.polarity = Polarity.negative;
          current++;
        }

        builder.aspect = Aspect.perfect;

        if (current < builder.tokens.length &&
            builder.tokens[current].toLowerCase() == 'been') {
          current++;

          if (current < builder.tokens.length) {
            final verb = _lookupVerb(builder.tokens[current]);

            if (verb != null) {
              builder.action = verb;

              if (builder.tokens[current].toLowerCase() == verb.ingForm) {
                builder.aspect = Aspect.perfectContinuous;
              }

              builder.verbChainEnd = current;
            }
          }
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
      // HAD
      // -------------------------------------------------------

      if (token == 'had') {
        builder.tense = Tense.past;
        builder.aspect = Aspect.perfect;
        builder.verbChainStart = i;

        var current = i + 1;

        if (current < builder.tokens.length &&
            builder.tokens[current].toLowerCase() == 'not') {
          builder.polarity = Polarity.negative;
          current++;
        }

        if (current < builder.tokens.length &&
            builder.tokens[current].toLowerCase() == 'been') {
          current++;

          if (current < builder.tokens.length) {
            final verb = _lookupVerb(builder.tokens[current]);

            if (verb != null) {
              builder.action = verb;

              if (builder.tokens[current].toLowerCase() == verb.ingForm) {
                builder.aspect = Aspect.perfectContinuous;
              }

              builder.verbChainEnd = current;
            }
          }
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

        if (current < builder.tokens.length &&
            builder.tokens[current].toLowerCase() == 'not') {
          builder.polarity = Polarity.negative;
          current++;
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
        builder.action = verb;
        builder.verbChainStart = i;
        builder.verbChainEnd = i;

        if (token == verb.infinitive) {
          builder.tense = Tense.present;
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

  Verb? _lookupVerb(String token) {
    for (final verb in verbs) {
      if (_findVerb(verb, token)) {
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

  Modal? _lookupModal(String token) {
    for (final modal in modals) {
      if (token == modal.text) {
        return modal;
      }
    }

    return null;
  }

  // -------------------------------------------------------
  // VOICE
  // -------------------------------------------------------

  void _recognizeVoice(_RecognitionBuilder builder) {
    if (builder.tokens.contains('by')) {
      builder.voice = Voice.passive;
      return;
    }

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

  void _recognizeParticipants(_RecognitionBuilder builder) {
    if (builder.verbChainStart < 0 || builder.verbChainEnd < 0) {
      return;
    }

    if (builder.voice == Voice.active) {
      _recognizeActiveParticipants(builder);
    } else {
      _recognizePassiveParticipants(builder);
    }

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
  }

  void _recognizeActiveParticipants(_RecognitionBuilder builder) {
    builder.agentStart = 0;
    builder.agentEnd = builder.verbChainStart - 1;

    if (builder.action?.takesObject != true) {
      return;
    }

    if (builder.verbChainEnd < builder.tokens.length - 1) {
      builder.objectStart = builder.verbChainEnd + 1;
      builder.objectEnd = builder.tokens.length - 1;
    }
  }

  void _recognizePassiveParticipants(_RecognitionBuilder builder) {
    builder.objectStart = 0;

    final byIndex = builder.tokens.indexWhere(
      (token) => token.toLowerCase() == 'by',
    );

    if (byIndex >= 0) {
      builder.objectEnd = builder.verbChainStart - 1;

      builder.agentStart = byIndex + 1;
      builder.agentEnd = builder.tokens.length - 1;
    } else {
      builder.objectEnd = builder.verbChainStart - 1;
    }
  }

  NounPhrase _recognizeNounPhrase(List<String> tokens) {
    Determiner? determiner;

    final remaining = [...tokens];

    if (remaining.isNotEmpty) {
      determiner = _lookupDeterminer(remaining.first);

      if (determiner != null) {
        remaining.removeAt(0);
      }
    }

    return NounPhrase(
      text: remaining.join(' '),
      person: Person.third,
      number: Number.singular,
      determiner: determiner,
      translations: const {},
    );
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

    builder.timePhrase = _lookupTimePhrase(phraseTokens);

    builder.placePhrase = _lookupPlacePhrase(phraseTokens);

    builder.frequencyPhrase = _lookupFrequencyPhrase(phraseTokens);

    builder.mannerPhrase = _lookupMannerPhrase(phraseTokens);
  }

  List<String> _remainingPhraseTokens(_RecognitionBuilder builder) {
    final remaining = <String>[];

    for (var i = builder.verbChainEnd + 1; i < builder.tokens.length; i++) {
      if (i >= builder.objectStart &&
          i <= builder.objectEnd &&
          builder.objectStart >= 0) {
        continue;
      }

      if (i >= builder.agentStart &&
          i <= builder.agentEnd &&
          builder.agentStart >= 0) {
        continue;
      }

      remaining.add(builder.tokens[i]);
    }

    return remaining;
  }

  TimePhrase? _lookupTimePhrase(List<String> tokens) {
    final text = tokens.join(' ').toLowerCase();

    for (final phrase in timePhrases) {
      if (text.contains(phrase.text.toLowerCase())) {
        return phrase;
      }
    }

    return null;
  }

  PlacePhrase? _lookupPlacePhrase(List<String> tokens) {
    final text = tokens.join(' ').toLowerCase();

    for (final phrase in placePhrases) {
      if (text.contains(phrase.text.toLowerCase())) {
        return phrase;
      }
    }

    return null;
  }

  FrequencyPhrase? _lookupFrequencyPhrase(List<String> tokens) {
    final text = tokens.join(' ').toLowerCase();

    for (final phrase in frequencyPhrases) {
      if (text.contains(phrase.text.toLowerCase())) {
        return phrase;
      }
    }

    return null;
  }

  MannerPhrase? _lookupMannerPhrase(List<String> tokens) {
    final text = tokens.join(' ').toLowerCase();

    for (final phrase in allMannerPhrases) {
      if (text.contains(phrase.text.toLowerCase())) {
        return phrase;
      }
    }

    return null;
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

  // ----------------------------
  // Recognized grammar
  // ----------------------------

  SentenceForm sentenceForm = SentenceForm.statement;

  Voice voice = Voice.active;

  Tense tense = Tense.present;

  Aspect aspect = Aspect.simple;

  Modal modal = noModal;

  Polarity polarity = Polarity.positive;

  Verb? action;

  NounPhrase? agent;

  NounPhrase? object;

  TimePhrase? timePhrase;

  PlacePhrase? placePhrase;

  FrequencyPhrase? frequencyPhrase;

  MannerPhrase? mannerPhrase;

  _RecognitionBuilder(this.sentence);

  SentenceState get state => SentenceState(
    action: action!,
    agent: agent,
    object: object,
    voice: voice,
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

int verbChainStart = -1;
int verbChainEnd = -1;

int subjectEnd = -1;
int objectStart = -1;
