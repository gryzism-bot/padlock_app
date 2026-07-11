import 'package:padlock_app/engine/logger/engine_logger.dart';
import 'package:padlock_app/engine/logger/grammar_diagnostics.dart';
import 'package:padlock_app/models/grammar/passive_focus.dart';
import 'package:padlock_app/models/grammar/phrase/phrase_position.dart';
import 'package:padlock_app/models/grammar/phrase/place_meaning.dart';
import 'package:padlock_app/models/grammar/recipient_placement.dart';
import 'package:padlock_app/models/grammar/subject/adjective.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/subject/person.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/voice.dart';
import 'package:padlock_app/models/sentence/sentence.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';

class GrammarEngine {
  final EngineLogger logger;

  GrammarEngine({EngineLogger? logger})
    : logger = logger ?? const EngineLogger();
  Sentence generate(SentenceState state) {
    final builder = _SentenceBuilder(state);
    var phase = 'start';

    try {
      phase = 'voice';
      _applyVoice(builder);
      _logGrammarPhase(builder, phase);

      phase = 'verb chain';
      _applyVerbChain(builder);
      _logGrammarPhase(builder, phase);

      phase = 'sentence form';
      _applySentenceForm(builder);
      _logGrammarPhase(builder, phase);

      phase = 'phrases';
      _applyPhrases(builder);
      _logGrammarPhase(builder, phase);

      phase = 'render';
      final text = _buildSentence(builder);
      logger.logGrammarPhase('render', builder.debugSnapshot(sentence: text));

      logger.logGrammar(GrammarDiagnostics(state: state, sentence: text));

      return Sentence(text: text, state: state);
    } catch (error, stackTrace) {
      logger.logGrammarFailure(
        phase,
        error,
        stackTrace,
        builder.debugSnapshot(),
      );
      rethrow;
    }
  }

  void _logGrammarPhase(_SentenceBuilder builder, String phase) {
    logger.logGrammarPhase(phase, builder.debugSnapshot());
  }

  // -------------------------------------------------------
  // Voice
  // -------------------------------------------------------

  void _applyVoice(_SentenceBuilder builder) {
    if (builder.state.action.infinitive == 'be') {
      assert(builder.state.agent != null, 'Lexical be requires an agent.');
      assert(
        builder.state.voice == Voice.active,
        'Lexical be is active-only in this predicate frame.',
      );

      builder.displaySubject = builder.state.agent!;
      builder.displayObject = null;
      builder.displayRecipient = null;
      builder.displayAgent = null;
      builder.displayComplement = builder.state.complement;
      builder.displayAdjectiveComplement = builder.state.adjectiveComplement;
      return;
    }

    switch (builder.state.voice) {
      case Voice.active:
        assert(builder.state.agent != null, 'Active voice requires an agent.');

        builder.displaySubject = builder.state.agent!;
        builder.displayObject = builder.state.object;
        builder.displayRecipient = builder.state.recipient;
        builder.displayAgent = null;
        break;

      case Voice.passive:
        final passiveFocus = builder.state.passiveFocus ?? PassiveFocus.object;

        switch (passiveFocus) {
          case PassiveFocus.object:
            assert(
              builder.state.object != null,
              'Passive object focus requires an object.',
            );

            builder.displaySubject = builder.state.object!;
            builder.displayObject = null;
            builder.displayRecipient = builder.state.recipient;
            builder.displayAgent = builder.state.showPassiveAgent
                ? builder.state.agent
                : null;
            break;

          case PassiveFocus.recipient:
            assert(
              builder.state.recipient != null,
              'Passive recipient focus requires a recipient.',
            );

            builder.displaySubject = builder.state.recipient!;
            builder.displayObject = builder.state.object;
            builder.displayRecipient = null;
            builder.displayAgent = builder.state.showPassiveAgent
                ? builder.state.agent
                : null;
        }
        break;
    }
  }

  // -------------------------------------------------------
  // Noun phrases
  // -------------------------------------------------------

  String _renderNounPhrase(NounPhrase nounPhrase) {
    return _renderNounPhraseWithText(nounPhrase, nounPhrase.text);
  }

  String _renderNounPhraseWithText(NounPhrase nounPhrase, String text) {
    final parts = <String>[];

    if (nounPhrase.determiner != null) {
      parts.add(nounPhrase.determiner!.text);
    }

    for (final adjective in nounPhrase.adjectiveList) {
      parts.add(adjective.text);
    }

    parts.add(text.toLowerCase() == 'i' ? 'I' : text);

    return parts.join(' ');
  }

  // -------------------------------------------------------
  // Grammar
  // -------------------------------------------------------

  void _applyVerbChain(_SentenceBuilder builder) {
    if (builder.state.action.infinitive == 'be') {
      _applyLexicalBeVerbChain(builder);
      return;
    }

    switch (builder.state.tense) {
      // -------------------------------------------------------
      // PRESENT
      // -------------------------------------------------------

      case Tense.present:
        switch (builder.state.aspect) {
          case Aspect.simple:
            if (!builder.state.modal.isNone) {
              builder.verbChain.add(builder.state.modal.text);

              if (builder.state.polarity == Polarity.negative) {
                builder.verbChain.add('not');
              }

              if (builder.state.voice == Voice.passive) {
                builder.verbChain
                  ..add('be')
                  ..add(builder.state.action.pastParticiple);
              } else {
                builder.verbChain.add(builder.state.action.infinitive);
              }
            } else if (builder.state.voice == Voice.passive) {
              builder.verbChain.add(_presentBe(builder.displaySubject));

              if (builder.state.polarity == Polarity.negative) {
                builder.verbChain.add('not');
              }

              builder.verbChain.add(builder.state.action.pastParticiple);
            } else if (builder.state.polarity == Polarity.negative) {
              builder.verbChain
                ..add(
                  builder.displaySubject.takesThirdPersonVerb ? 'does' : 'do',
                )
                ..add('not')
                ..add(builder.state.action.infinitive);
            } else if (builder.state.sentenceForm == SentenceForm.question) {
              builder.verbChain
                ..add(
                  builder.displaySubject.takesThirdPersonVerb ? 'does' : 'do',
                )
                ..add(builder.state.action.infinitive);
            } else {
              builder.verbChain.add(
                builder.displaySubject.takesThirdPersonVerb
                    ? builder.state.action.presentThirdPerson
                    : builder.state.action.infinitive,
              );
            }
            break;

          case Aspect.continuous:
            if (!builder.state.modal.isNone) {
              builder.verbChain.add(builder.state.modal.text);

              if (builder.state.polarity == Polarity.negative) {
                builder.verbChain.add('not');
              }

              builder.verbChain.add('be');
            } else {
              builder.verbChain.add(_presentBe(builder.displaySubject));

              if (builder.state.polarity == Polarity.negative) {
                builder.verbChain.add('not');
              }
            }

            if (builder.state.voice == Voice.passive) {
              builder.verbChain
                ..add('being')
                ..add(builder.state.action.pastParticiple);
            } else {
              builder.verbChain.add(builder.state.action.ingForm);
            }

            break;

          case Aspect.perfect:
            if (!builder.state.modal.isNone) {
              builder.verbChain.add(builder.state.modal.text);

              if (builder.state.polarity == Polarity.negative) {
                builder.verbChain.add('not');
              }

              builder.verbChain.add('have');
            } else {
              builder.verbChain.add(
                builder.displaySubject.takesThirdPersonVerb ? 'has' : 'have',
              );

              if (builder.state.polarity == Polarity.negative) {
                builder.verbChain.add('not');
              }
            }

            if (builder.state.voice == Voice.passive) {
              builder.verbChain
                ..add('been')
                ..add(builder.state.action.pastParticiple);
            } else {
              builder.verbChain.add(builder.state.action.pastParticiple);
            }

            break;

          case Aspect.perfectContinuous:
            if (!builder.state.modal.isNone) {
              builder.verbChain.add(builder.state.modal.text);

              if (builder.state.polarity == Polarity.negative) {
                builder.verbChain.add('not');
              }

              builder.verbChain
                ..add('have')
                ..add('been');
            } else {
              builder.verbChain.add(
                builder.displaySubject.takesThirdPersonVerb ? 'has' : 'have',
              );

              if (builder.state.polarity == Polarity.negative) {
                builder.verbChain.add('not');
              }

              builder.verbChain.add('been');
            }

            if (builder.state.voice == Voice.passive) {
              builder.verbChain
                ..add('being')
                ..add(builder.state.action.pastParticiple);
            } else {
              builder.verbChain.add(builder.state.action.ingForm);
            }

            break;
        }

        break;
      // -------------------------------------------------------
      // PAST
      // -------------------------------------------------------

      case Tense.past:
        switch (builder.state.aspect) {
          case Aspect.simple:
            if (!builder.state.modal.isNone) {
              builder.verbChain.add(builder.state.modal.text);

              if (builder.state.polarity == Polarity.negative) {
                builder.verbChain.add('not');
              }

              if (builder.state.voice == Voice.passive) {
                builder.verbChain
                  ..add('be')
                  ..add(builder.state.action.pastParticiple);
              } else {
                builder.verbChain.add(builder.state.action.infinitive);
              }
            } else if (builder.state.voice == Voice.passive) {
              builder.verbChain.add(_pastBe(builder.displaySubject));

              if (builder.state.polarity == Polarity.negative) {
                builder.verbChain.add('not');
              }

              builder.verbChain.add(builder.state.action.pastParticiple);
            } else if (builder.state.polarity == Polarity.negative) {
              builder.verbChain
                ..add('did')
                ..add('not')
                ..add(builder.state.action.infinitive);
            } else if (builder.state.sentenceForm == SentenceForm.question) {
              builder.verbChain
                ..add('did')
                ..add(builder.state.action.infinitive);
            } else {
              builder.verbChain.add(builder.state.action.pastSimple);
            }

            break;

          case Aspect.continuous:
            if (!builder.state.modal.isNone) {
              builder.verbChain.add(builder.state.modal.text);

              if (builder.state.polarity == Polarity.negative) {
                builder.verbChain.add('not');
              }

              builder.verbChain.add('be');
            } else {
              builder.verbChain.add(_pastBe(builder.displaySubject));

              if (builder.state.polarity == Polarity.negative) {
                builder.verbChain.add('not');
              }
            }

            if (builder.state.voice == Voice.passive) {
              builder.verbChain
                ..add('being')
                ..add(builder.state.action.pastParticiple);
            } else {
              builder.verbChain.add(builder.state.action.ingForm);
            }

            break;

          case Aspect.perfect:
            if (!builder.state.modal.isNone) {
              builder.verbChain.add(builder.state.modal.text);

              if (builder.state.polarity == Polarity.negative) {
                builder.verbChain.add('not');
              }

              builder.verbChain.add('have');
            } else {
              builder.verbChain.add('had');

              if (builder.state.polarity == Polarity.negative) {
                builder.verbChain.add('not');
              }
            }

            if (builder.state.voice == Voice.passive) {
              builder.verbChain
                ..add('been')
                ..add(builder.state.action.pastParticiple);
            } else {
              builder.verbChain.add(builder.state.action.pastParticiple);
            }

            break;

          case Aspect.perfectContinuous:
            if (!builder.state.modal.isNone) {
              builder.verbChain.add(builder.state.modal.text);

              if (builder.state.polarity == Polarity.negative) {
                builder.verbChain.add('not');
              }

              builder.verbChain
                ..add('have')
                ..add('been');
            } else {
              builder.verbChain.add('had');

              if (builder.state.polarity == Polarity.negative) {
                builder.verbChain.add('not');
              }

              builder.verbChain.add('been');
            }

            if (builder.state.voice == Voice.passive) {
              builder.verbChain
                ..add('being')
                ..add(builder.state.action.pastParticiple);
            } else {
              builder.verbChain.add(builder.state.action.ingForm);
            }

            break;
        }

        break;
      // -------------------------------------------------------
      // FUTURE
      // -------------------------------------------------------

      case Tense.future:
        switch (builder.state.aspect) {
          case Aspect.simple:
            if (!builder.state.modal.isNone) {
              builder.verbChain.add(builder.state.modal.text);

              if (builder.state.polarity == Polarity.negative) {
                builder.verbChain.add('not');
              }
            } else {
              builder.verbChain.add('will');

              if (builder.state.polarity == Polarity.negative) {
                builder.verbChain.add('not');
              }
            }

            if (builder.state.voice == Voice.passive) {
              builder.verbChain
                ..add('be')
                ..add(builder.state.action.pastParticiple);
            } else {
              builder.verbChain.add(builder.state.action.infinitive);
            }

            break;

          case Aspect.continuous:
            if (!builder.state.modal.isNone) {
              builder.verbChain.add(builder.state.modal.text);

              if (builder.state.polarity == Polarity.negative) {
                builder.verbChain.add('not');
              }
            } else {
              builder.verbChain.add('will');

              if (builder.state.polarity == Polarity.negative) {
                builder.verbChain.add('not');
              }
            }

            builder.verbChain.add('be');

            if (builder.state.voice == Voice.passive) {
              builder.verbChain
                ..add('being')
                ..add(builder.state.action.pastParticiple);
            } else {
              builder.verbChain.add(builder.state.action.ingForm);
            }

            break;

          case Aspect.perfect:
            if (!builder.state.modal.isNone) {
              builder.verbChain.add(builder.state.modal.text);

              if (builder.state.polarity == Polarity.negative) {
                builder.verbChain.add('not');
              }
            } else {
              builder.verbChain.add('will');

              if (builder.state.polarity == Polarity.negative) {
                builder.verbChain.add('not');
              }
            }

            builder.verbChain.add('have');

            if (builder.state.voice == Voice.passive) {
              builder.verbChain
                ..add('been')
                ..add(builder.state.action.pastParticiple);
            } else {
              builder.verbChain.add(builder.state.action.pastParticiple);
            }

            break;

          case Aspect.perfectContinuous:
            if (!builder.state.modal.isNone) {
              builder.verbChain.add(builder.state.modal.text);

              if (builder.state.polarity == Polarity.negative) {
                builder.verbChain.add('not');
              }
            } else {
              builder.verbChain.add('will');

              if (builder.state.polarity == Polarity.negative) {
                builder.verbChain.add('not');
              }
            }

            builder.verbChain
              ..add('have')
              ..add('been');

            if (builder.state.voice == Voice.passive) {
              builder.verbChain
                ..add('being')
                ..add(builder.state.action.pastParticiple);
            } else {
              builder.verbChain.add(builder.state.action.ingForm);
            }

            break;
        }

        break;
    }
  }

  void _applyLexicalBeVerbChain(_SentenceBuilder builder) {
    if (builder.state.sentenceForm == SentenceForm.imperative) {
      assert(
        builder.state.tense == Tense.present,
        'Imperative lexical be uses present tense.',
      );
      assert(
        builder.state.aspect == Aspect.simple,
        'Imperative lexical be uses simple aspect.',
      );
      assert(
        builder.state.modal.isNone,
        'Imperative lexical be does not take a modal.',
      );

      if (builder.state.polarity == Polarity.negative) {
        builder.verbChain
          ..add('do')
          ..add('not');
      }

      builder.verbChain.add('be');
      return;
    }

    if (!builder.state.modal.isNone) {
      builder.verbChain.add(builder.state.modal.text);

      if (builder.state.polarity == Polarity.negative) {
        builder.verbChain.add('not');
      }

      switch (builder.state.aspect) {
        case Aspect.simple:
          builder.verbChain.add('be');
          break;
        case Aspect.continuous:
          builder.verbChain
            ..add('be')
            ..add('being');
          break;
        case Aspect.perfect:
          builder.verbChain
            ..add('have')
            ..add('been');
          break;
        case Aspect.perfectContinuous:
          builder.verbChain
            ..add('have')
            ..add('been')
            ..add('being');
          break;
      }
      return;
    }

    switch (builder.state.tense) {
      case Tense.present:
        switch (builder.state.aspect) {
          case Aspect.simple:
            builder.verbChain.add(_presentBe(builder.displaySubject));
            break;
          case Aspect.continuous:
            builder.verbChain.add(_presentBe(builder.displaySubject));
            break;
          case Aspect.perfect:
          case Aspect.perfectContinuous:
            builder.verbChain.add(
              builder.displaySubject.takesThirdPersonVerb ? 'has' : 'have',
            );
            break;
        }
        break;
      case Tense.past:
        switch (builder.state.aspect) {
          case Aspect.simple:
          case Aspect.continuous:
            builder.verbChain.add(_pastBe(builder.displaySubject));
            break;
          case Aspect.perfect:
          case Aspect.perfectContinuous:
            builder.verbChain.add('had');
            break;
        }
        break;
      case Tense.future:
        builder.verbChain.add('will');
        break;
    }

    if (builder.state.polarity == Polarity.negative) {
      builder.verbChain.add('not');
    }

    switch (builder.state.aspect) {
      case Aspect.simple:
        if (builder.state.tense == Tense.future) {
          builder.verbChain.add('be');
        }
        break;
      case Aspect.continuous:
        if (builder.state.tense == Tense.future) {
          builder.verbChain.add('be');
        }
        builder.verbChain.add('being');
        break;
      case Aspect.perfect:
        if (builder.state.tense == Tense.future) {
          builder.verbChain.add('have');
        }
        builder.verbChain.add('been');
        break;
      case Aspect.perfectContinuous:
        if (builder.state.tense == Tense.future) {
          builder.verbChain.add('have');
        }
        builder.verbChain
          ..add('been')
          ..add('being');
        break;
    }
  }

  String _presentBe(NounPhrase subject) {
    if (subject.person == Person.first && subject.number == Number.singular) {
      return 'am';
    }

    if (subject.person == Person.third && subject.number == Number.singular) {
      return 'is';
    }

    return 'are';
  }

  String _pastBe(NounPhrase subject) {
    if (subject.person == Person.second) {
      return 'were';
    }

    if (subject.number == Number.plural) {
      return 'were';
    }

    return 'was';
  }

  String _renderObjectCase(NounPhrase nounPhrase) {
    final objectText = switch (nounPhrase.text.toLowerCase()) {
      'i' => 'me',
      'he' => 'him',
      'she' => 'her',
      'we' => 'us',
      'they' => 'them',
      _ => nounPhrase.text,
    };

    return _renderNounPhraseWithText(nounPhrase, objectText);
  }

  void _applySentenceForm(_SentenceBuilder builder) {
    switch (builder.state.sentenceForm) {
      case SentenceForm.statement:
        builder.punctuation = '.';
        builder.invertSubjectAndAuxiliary = false;
        break;

      case SentenceForm.question:
        builder.punctuation = '?';
        builder.invertSubjectAndAuxiliary = true;
        break;

      case SentenceForm.exclamation:
        builder.punctuation = '!';
        builder.invertSubjectAndAuxiliary = false;
        break;

      case SentenceForm.imperative:
        builder.punctuation = '.';
        builder.invertSubjectAndAuxiliary = false;
        break;
    }
  }

  // -------------------------------------------------------
  // Phrases
  // -------------------------------------------------------

  void _applyPhrases(_SentenceBuilder builder) {
    builder.timePhrase = builder.state.timePhrase?.render() ?? '';

    if (builder.state.placePhrase != null) {
      final meaning = builder.state.action.usesDestinationPlace
          ? PlaceMeaning.destination
          : PlaceMeaning.location;

      builder.placePhrase = builder.state.placePhrase!.render(meaning);
    } else {
      builder.placePhrase = '';
    }

    builder.frequencyPhrase = builder.state.frequencyPhrase?.render() ?? '';

    builder.mannerPhrase = builder.state.mannerPhrase?.render() ?? '';
  }

  // -------------------------------------------------------
  // Rendering
  // -------------------------------------------------------

  String _buildSentence(_SentenceBuilder builder) {
    final parts = <String>[];

    // ---------- FRONT PHRASES ----------

    _addFrontPhrases(parts, builder);

    // ---------- SUBJECT & VERB CHAIN ----------

    if (builder.invertSubjectAndAuxiliary) {
      if (builder.verbChain.isNotEmpty) {
        parts.add(builder.verbChain.first);
      }

      if (builder.state.sentenceForm != SentenceForm.imperative) {
        parts.add(_renderNounPhrase(builder.displaySubject));
      }

      if (builder.verbChain.length > 1) {
        parts.addAll(builder.verbChain.skip(1));
      }
    } else {
      if (builder.state.sentenceForm != SentenceForm.imperative) {
        parts.add(_renderNounPhrase(builder.displaySubject));
      }

      parts.addAll(builder.verbChain);
    }

    final activeToRecipient =
        builder.state.voice == Voice.active &&
        builder.state.recipientPlacement == RecipientPlacement.toPhrase;

    // ---------- RECIPIENT ----------

    if (builder.displayRecipient != null && !activeToRecipient) {
      if (builder.state.voice == Voice.passive) {
        parts.add('to ${_renderObjectCase(builder.displayRecipient!)}');
      } else {
        parts.add(_renderObjectCase(builder.displayRecipient!));
      }
    }

    // ---------- OBJECT ----------

    if (builder.displayObject != null) {
      parts.add(_renderObjectCase(builder.displayObject!));
    }

    if (builder.displayRecipient != null && activeToRecipient) {
      parts.add(
        '${builder.state.recipientPreposition.text} ${_renderObjectCase(builder.displayRecipient!)}',
      );
    }

    // ---------- COMPLEMENT ----------

    if (builder.displayComplement != null) {
      parts.add(_renderNounPhrase(builder.displayComplement!));
    }

    if (builder.displayAdjectiveComplement != null) {
      parts.add(builder.displayAdjectiveComplement!.text);
    }

    // ---------- PASSIVE AGENT ----------

    if (builder.displayAgent != null) {
      parts.add('by ${_renderObjectCase(builder.displayAgent!)}');
    }

    // ---------- BACK PHRASES ----------

    _addBackPhrases(parts, builder);

    String sentence = parts.join(' ');

    sentence = sentence.replaceAll('can not', 'cannot');

    return '${sentence.capitalizeFirst()}${builder.punctuation}';
  }

  void _addFrontPhrases(List<String> parts, _SentenceBuilder builder) {
    if (builder.state.timePhrase?.position == PhrasePosition.beforeSubject) {
      _addPhrase(parts, builder.timePhrase);
    }

    if (builder.state.placePhrase?.position == PhrasePosition.beforeSubject) {
      _addPhrase(parts, builder.placePhrase);
    }

    if (builder.state.frequencyPhrase?.position ==
        PhrasePosition.beforeSubject) {
      _addPhrase(parts, builder.frequencyPhrase);
    }

    if (builder.state.mannerPhrase?.position == PhrasePosition.beforeSubject) {
      _addPhrase(parts, builder.mannerPhrase);
    }
  }

  void _addBackPhrases(List<String> parts, _SentenceBuilder builder) {
    if (builder.state.placePhrase?.position == PhrasePosition.afterPredicate) {
      _addPhrase(parts, builder.placePhrase);
    }

    if (builder.state.timePhrase?.position == PhrasePosition.afterPredicate) {
      _addPhrase(parts, builder.timePhrase);
    }

    if (builder.state.frequencyPhrase?.position ==
        PhrasePosition.afterPredicate) {
      _addPhrase(parts, builder.frequencyPhrase);
    }

    if (builder.state.mannerPhrase?.position == PhrasePosition.afterPredicate) {
      _addPhrase(parts, builder.mannerPhrase);
    }
  }

  void _addPhrase(List<String> parts, String phrase) {
    if (phrase.isNotEmpty) {
      parts.add(phrase);
    }
  }
}

class _SentenceBuilder {
  final SentenceState state;

  late NounPhrase displaySubject;
  NounPhrase? displayObject;
  NounPhrase? displayRecipient;
  NounPhrase? displayAgent;
  NounPhrase? displayComplement;
  Adjective? displayAdjectiveComplement;

  bool invertSubjectAndAuxiliary = false;

  final List<String> verbChain = [];

  String punctuation = '';

  String timePhrase = '';
  String placePhrase = '';
  String frequencyPhrase = '';
  String mannerPhrase = '';

  _SentenceBuilder(this.state);

  String debugSnapshot({String? sentence}) {
    return [
      if (sentence != null) 'sentence: $sentence',
      'state: ${state.summary}',
      'displaySubject: ${displaySubjectOrNull?.text}',
      'displayObject: ${displayObject?.text}',
      'displayRecipient: ${displayRecipient?.text}',
      'displayAgent: ${displayAgent?.text}',
      'displayComplement: ${displayComplement?.text}',
      'displayAdjectiveComplement: ${displayAdjectiveComplement?.text}',
      'verbChain: ${verbChain.join(' ')}',
      'invertSubjectAndAuxiliary: $invertSubjectAndAuxiliary',
      'punctuation: $punctuation',
      'phrases: time="$timePhrase", place="$placePhrase", frequency="$frequencyPhrase", manner="$mannerPhrase"',
    ].join('\n');
  }

  NounPhrase? get displaySubjectOrNull {
    try {
      return displaySubject;
    } catch (_) {
      return null;
    }
  }
}

extension SentenceFormatting on String {
  String capitalizeFirst() {
    if (isEmpty) return this;

    return this[0].toUpperCase() + substring(1);
  }
}
