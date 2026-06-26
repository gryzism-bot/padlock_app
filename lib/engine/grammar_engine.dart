import '../models/grammar/aspect.dart';
import '../models/grammar/modal.dart';
import '../models/grammar/phrase_position.dart';
import '../models/grammar/polarity.dart';
import '../models/sentence/sentence.dart';
import '../models/grammar/sentence_form.dart';
import '../models/sentence/sentence_state.dart';
import '../models/grammar/tense.dart';

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
      case Tense.present:
        builder.verb = builder.state.subject.takesThirdPersonVerb
            ? builder.state.verb.presentThirdPerson
            : builder.state.verb.infinitive;
        break;

      case Tense.past:
        builder.verb = builder.state.verb.pastSimple;
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
          case Tense.present:
            builder.auxiliary = builder.state.subject.isPlural ? 'are' : 'is';
            break;

          case Tense.past:
            builder.auxiliary = builder.state.subject.isPlural ? 'were' : 'was';
            break;

          case Tense.future:
            builder.auxiliary = 'will be';
            break;
        }

        builder.verb = builder.state.verb.ingForm;
        break;

      case Aspect.perfect:
        switch (builder.state.tense) {
          case Tense.present:
            builder.auxiliary = builder.state.subject.takesThirdPersonVerb
                ? 'has'
                : 'have';
            break;

          case Tense.past:
            builder.auxiliary = 'had';
            break;

          case Tense.future:
            builder.auxiliary = 'will have';
            break;
        }

        builder.verb = builder.state.verb.pastParticiple;
        break;

      case Aspect.perfectContinuous:
        switch (builder.state.tense) {
          case Tense.present:
            builder.auxiliary = builder.state.subject.takesThirdPersonVerb
                ? 'has been'
                : 'have been';
            break;

          case Tense.past:
            builder.auxiliary = 'had been';
            break;

          case Tense.future:
            builder.auxiliary = 'will have been';
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

      case Modal.can:
        builder.auxiliary = 'can';
        builder.verb = builder.state.verb.infinitive;
        break;

      case Modal.could:
        builder.auxiliary = 'could';
        builder.verb = builder.state.verb.infinitive;
        break;

      case Modal.may:
        builder.auxiliary = 'may';
        builder.verb = builder.state.verb.infinitive;
        break;

      case Modal.might:
        builder.auxiliary = 'might';
        builder.verb = builder.state.verb.infinitive;
        break;

      case Modal.must:
        builder.auxiliary = 'must';
        builder.verb = builder.state.verb.infinitive;
        break;

      case Modal.shall:
        builder.auxiliary = 'shall';
        builder.verb = builder.state.verb.infinitive;
        break;

      case Modal.should:
        builder.auxiliary = 'should';
        builder.verb = builder.state.verb.infinitive;
        break;

      case Modal.will:
        builder.auxiliary = 'will';
        builder.verb = builder.state.verb.infinitive;
        break;

      case Modal.would:
        builder.auxiliary = 'would';
        builder.verb = builder.state.verb.infinitive;
        break;

      case Modal.oughtTo:
        builder.auxiliary = 'ought to';
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

      parts.add(builder.verb);
    }

    // ---------- BACK PHRASES ----------

    if (state.placePhrase?.position == PhrasePosition.afterPredicate) {
      parts.add(builder.placePhrase);
    }

    if (state.timePhrase?.position == PhrasePosition.afterPredicate) {
      parts.add(builder.timePhrase);
    }

    return '${parts.join(' ')}.';
  }
}

class _SentenceBuilder {
  final SentenceState state;

  String subject = '';
  String auxiliary = '';
  String verb = '';

  String timePhrase = '';
  String placePhrase = '';

  _SentenceBuilder(this.state) {
    timePhrase = state.timePhrase?.text ?? '';
    placePhrase = state.placePhrase?.text ?? '';
  }
}
