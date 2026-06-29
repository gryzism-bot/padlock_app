import 'package:padlock_app/models/grammar/phrase/phrase_position.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/voice.dart';
import 'package:padlock_app/models/sentence/sentence.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';

class GrammarEngine {
  Sentence generate(SentenceState state) {
    final builder = _SentenceBuilder(state);

    _applyVoice(builder);
    _applyVerbChain(builder);

    _applySentenceForm(builder);

    _applyPhrases(builder);

    final text = _buildSentence(builder);

    return Sentence(text: text, state: state);
  }

  // -------------------------------------------------------
  // Voice
  // -------------------------------------------------------

  void _applyVoice(_SentenceBuilder builder) {
    switch (builder.state.voice) {
      case Voice.active:
        assert(builder.state.agent != null, 'Active voice requires an agent.');

        builder.displaySubject = builder.state.agent!;
        builder.displayObject = builder.state.object;
        builder.displayAgent = null;
        break;

      case Voice.passive:
        assert(
          builder.state.object != null,
          'Passive voice requires an object.',
        );

        builder.displaySubject = builder.state.object!;
        builder.displayObject = null;
        builder.displayAgent = builder.state.agent;
        break;
    }
  }

  // -------------------------------------------------------
  // Noun phrases
  // -------------------------------------------------------

  String _renderNounPhrase(NounPhrase nounPhrase) {
    final parts = <String>[];

    if (nounPhrase.determiner != null) {
      parts.add(nounPhrase.determiner!.text);
    }

    parts.add(nounPhrase.text);

    return parts.join(' ');
  }

  // -------------------------------------------------------
  // Grammar
  // -------------------------------------------------------

  void _applyVerbChain(_SentenceBuilder builder) {
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
              builder.verbChain.add(
                builder.displaySubject.takesThirdPersonVerb ? 'is' : 'are',
              );

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
              builder.verbChain.add(
                builder.displaySubject.takesThirdPersonVerb ? 'is' : 'are',
              );

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
              builder.verbChain.add(
                builder.displaySubject.isPlural ? 'were' : 'was',
              );

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
              builder.verbChain.add(
                builder.displaySubject.isPlural ? 'were' : 'was',
              );

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
    if (builder.state.timePhrase != null) {
      builder.timePhrase = builder.state.timePhrase!.text;
    }

    if (builder.state.placePhrase != null) {
      builder.placePhrase = builder.state.placePhrase!.text;
    }

    if (builder.state.frequencyPhrase != null) {
      builder.frequencyPhrase = builder.state.frequencyPhrase!.text;
    }

    if (builder.state.mannerPhrase != null) {
      builder.mannerPhrase = builder.state.mannerPhrase!.text;
    }
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

      parts.add(_renderNounPhrase(builder.displaySubject));

      if (builder.verbChain.length > 1) {
        parts.addAll(builder.verbChain.skip(1));
      }
    } else {
      parts.add(_renderNounPhrase(builder.displaySubject));

      parts.addAll(builder.verbChain);
    }

    // ---------- OBJECT ----------

    if (builder.displayObject != null) {
      parts.add(_renderNounPhrase(builder.displayObject!));
    }

    // ---------- PASSIVE AGENT ----------

    if (builder.displayAgent != null) {
      parts.add('by ${_renderNounPhrase(builder.displayAgent!)}');
    }

    // ---------- BACK PHRASES ----------

    _addBackPhrases(parts, builder);

    return '${parts.join(' ').capitalizeFirst()}${builder.punctuation}';
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
    if (builder.state.timePhrase?.position == PhrasePosition.afterPredicate) {
      _addPhrase(parts, builder.timePhrase);
    }

    if (builder.state.placePhrase?.position == PhrasePosition.afterPredicate) {
      _addPhrase(parts, builder.placePhrase);
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
  NounPhrase? displayAgent;

  bool invertSubjectAndAuxiliary = false;

  final List<String> verbChain = [];

  String punctuation = '';

  String timePhrase = '';
  String placePhrase = '';
  String frequencyPhrase = '';
  String mannerPhrase = '';

  _SentenceBuilder(this.state);
}

extension SentenceFormatting on String {
  String capitalizeFirst() {
    if (isEmpty) return this;

    return this[0].toUpperCase() + substring(1);
  }
}
