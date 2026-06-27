import '../models/grammar/verb/aspect.dart';
import '../models/grammar/verb/modal.dart';
import '../models/grammar/phrase/phrase_position.dart';
import '../models/grammar/verb/polarity.dart';
import '../models/sentence/sentence.dart';
import '../models/grammar/sentence_form.dart';
import '../models/sentence/sentence_state.dart';
import '../models/grammar/verb/tense.dart';

class GrammarEngine {
  Sentence generate(SentenceState state) {
    final builder = _SentenceBuilder(state);

    _applySubject(builder);
    _applyTense(builder);
    _applyAspect(builder);
    _applyModal(builder);

    final text = _buildSentence(builder);

    return Sentence(text: text, state: state);
  }

  void _applySubject(_SentenceBuilder builder) {
    builder.subject = builder.state.subject.text;
  }

  void _applyTense(_SentenceBuilder builder) {
    switch (builder.state.tense) {
      case Tense.past:
        builder.verb = builder.state.verb.pastSimple;
        break;

      case Tense.present:
        builder.verb = builder.state.subject.takesThirdPersonVerb
            ? builder.state.verb.presentThirdPerson
            : builder.state.verb.infinitive;
        break;

      case Tense.future:
        builder.auxiliary = 'will';
        builder.verb = builder.state.verb.infinitive;
        break;
    }
  }

  void _applyAspect(_SentenceBuilder builder) {
    switch (builder.state.aspect) {
      case Aspect.simple:
        break;

      case Aspect.continuous:
        switch (builder.state.tense) {
          case Tense.past:
            builder.auxiliary = builder.state.subject.isPlural ? 'were' : 'was';
            break;

          case Tense.present:
            builder.auxiliary = builder.state.subject.isPlural ? 'are' : 'is';
            break;

          case Tense.future:
            builder.auxiliary = 'will';
            builder.helper = 'be';
            break;
        }

        builder.verb = builder.state.verb.ingForm;
        break;

      case Aspect.perfect:
        switch (builder.state.tense) {
          case Tense.past:
            builder.auxiliary = 'had';
            break;

          case Tense.present:
            builder.auxiliary = builder.state.subject.takesThirdPersonVerb
                ? 'has'
                : 'have';
            break;

          case Tense.future:
            builder.auxiliary = 'will';
            builder.helper = 'have';
            break;
        }

        builder.verb = builder.state.verb.pastParticiple;
        break;

      case Aspect.perfectContinuous:
        switch (builder.state.tense) {
          case Tense.past:
            builder.auxiliary = 'had';
            builder.helper = 'been';
            break;

          case Tense.present:
            builder.auxiliary = builder.state.subject.takesThirdPersonVerb
                ? 'has'
                : 'have';

            builder.helper = 'been';
            break;

          case Tense.future:
            builder.auxiliary = 'will';
            builder.helper = 'have been';
            break;
        }

        builder.verb = builder.state.verb.ingForm;
        break;
    }
  }

  void _applyModal(_SentenceBuilder builder) {
    switch (builder.state.modal) {
      case Modal.none:
        break;

      // Strong obligation
      case Modal.must:
        builder.auxiliary = 'must';
        builder.verb = builder.state.verb.infinitive;
        break;

      case Modal.oughtTo:
        builder.auxiliary = 'ought to';
        builder.verb = builder.state.verb.infinitive;
        break;

      case Modal.should:
        builder.auxiliary = 'should';
        builder.verb = builder.state.verb.infinitive;
        break;

      // Recommendation / possibility
      case Modal.would:
        builder.auxiliary = 'would';
        builder.verb = builder.state.verb.infinitive;
        break;

      case Modal.could:
        builder.auxiliary = 'could';
        builder.verb = builder.state.verb.infinitive;
        break;

      case Modal.can:
        builder.auxiliary = 'can';
        builder.verb = builder.state.verb.infinitive;
        break;

      // Permission / probability
      case Modal.may:
        builder.auxiliary = 'may';
        builder.verb = builder.state.verb.infinitive;
        break;

      case Modal.might:
        builder.auxiliary = 'might';
        builder.verb = builder.state.verb.infinitive;
        break;

      // Future
      case Modal.shall:
        builder.auxiliary = 'shall';
        builder.verb = builder.state.verb.infinitive;
        break;

      case Modal.will:
        builder.auxiliary = 'will';
        builder.verb = builder.state.verb.infinitive;
        break;
    }
  }

  String _buildSentence(_SentenceBuilder builder) {
    final state = builder.state;
    final parts = <String>[];

    // ---------- FRONT PHRASES ----------

    if (state.timePhrase?.position == PhrasePosition.beforeSubject) {
      parts.add(builder.timePhrase);
    }

    if (state.placePhrase?.position == PhrasePosition.beforeSubject) {
      parts.add(builder.placePhrase);
    }

    // ---------- QUESTION ----------

    if (state.sentenceForm == SentenceForm.question) {
      if (builder.auxiliary.isEmpty) {
        switch (state.tense) {
          case Tense.present:
            builder.auxiliary = state.subject.takesThirdPersonVerb
                ? 'does'
                : 'do';
            builder.verb = state.verb.infinitive;
            break;

          case Tense.past:
            builder.auxiliary = 'did';
            builder.verb = state.verb.infinitive;
            break;

          case Tense.future:
            break;
        }
      }

      parts.add(builder.auxiliary);

      if (state.sentenceForm != SentenceForm.imperative) {
        parts.add(builder.subject);
      }

      if (state.polarity == Polarity.negative) {
        parts.add('not');
      }

      if (builder.helper.isNotEmpty) {
        parts.add(builder.helper);
      }

      parts.add(builder.verb);
    }
    // ---------- STATEMENT / IMPERATIVE ----------
    else {
      if (state.sentenceForm != SentenceForm.imperative) {
        parts.add(builder.subject);
      }

      if (builder.auxiliary.isNotEmpty) {
        parts.add(builder.auxiliary);
      }

      if (state.polarity == Polarity.negative) {
        if (builder.auxiliary.isEmpty) {
          switch (state.tense) {
            case Tense.present:
              parts.add(
                state.subject.takesThirdPersonVerb ? 'does not' : 'do not',
              );
              builder.verb = state.verb.infinitive;
              break;

            case Tense.past:
              parts.add('did not');
              builder.verb = state.verb.infinitive;
              break;

            case Tense.future:
              parts.add('not');
              break;
          }
        } else {
          parts.add('not');
        }
      }

      if (builder.helper.isNotEmpty) {
        parts.add(builder.helper);
      }

      parts.add(builder.verb);
    }

    // ---------- BACK PHRASES ----------

    if (state.placePhrase?.position == PhrasePosition.afterPredicate) {
      parts.add(builder.placePhrase);
    }

    if (state.timePhrase?.position == PhrasePosition.afterPredicate) {
      parts.add(builder.timePhrase);
    }

    String punctuation;

    switch (state.sentenceForm) {
      case SentenceForm.statement:
        punctuation = '.';
        break;

      case SentenceForm.question:
        punctuation = '?';
        break;

      case SentenceForm.exclamation:
        punctuation = '!';
        break;

      case SentenceForm.imperative:
        punctuation = '.';
        break;
    }

    final sentence = parts.join(' ').capitalizeFirst();

    return '$sentence$punctuation';
  }
}

class _SentenceBuilder {
  final SentenceState state;

  String subject = '';
  String auxiliary = '';
  String helper = '';
  String verb = '';

  String timePhrase = '';
  String placePhrase = '';

  _SentenceBuilder(this.state) {
    timePhrase = state.timePhrase?.text ?? '';
    placePhrase = state.placePhrase?.text ?? '';
  }
}

extension SentenceFormatting on String {
  String capitalizeFirst() {
    if (isEmpty) return this;

    return this[0].toUpperCase() + substring(1);
  }
}
