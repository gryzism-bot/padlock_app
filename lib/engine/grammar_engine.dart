import '../models/grammar/aspect.dart';
import '../models/grammar/modal.dart';
import '../models/grammar/polarity.dart';
import '../models/sentence/sentence.dart';
import '../models/grammar/sentence_form.dart';
import '../models/sentence/sentence_state.dart';
import '../models/grammar/subject.dart';
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
        // TODO
        break;

      case Aspect.perfect:
        // TODO
        break;

      case Aspect.perfectContinuous:
        // TODO
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

    final isQuestion = state.sentenceForm == SentenceForm.question;
    final isNegative = state.polarity == Polarity.negative;

    if (isQuestion) {
      if (builder.auxiliary.isEmpty) {
        if (state.tense == Tense.present) {
          builder.auxiliary = state.subject.takesThirdPersonVerb
              ? 'does'
              : 'do';
          builder.verb = state.verb.infinitive;
        } else if (state.tense == Tense.past) {
          builder.auxiliary = 'did';
          builder.verb = state.verb.infinitive;
        }
      }

      parts.add(builder.auxiliary);

      if (state.sentenceForm != SentenceForm.imperative) {
        parts.add(builder.subject);
      }

      if (isNegative) {
        parts.add('not');
      }

      parts.add(builder.verb);
    } else {
      if (state.sentenceForm != SentenceForm.imperative) {
        parts.add(builder.subject);
      }

      if (builder.auxiliary.isNotEmpty) {
        parts.add(builder.auxiliary);
      }

      if (isNegative) {
        if (builder.auxiliary.isEmpty) {
          if (state.tense == Tense.present) {
            parts.add(
              state.subject.takesThirdPersonVerb ? 'does not' : 'do not',
            );
            builder.verb = state.verb.infinitive;
          } else if (state.tense == Tense.past) {
            parts.add('did not');
            builder.verb = state.verb.infinitive;
          } else {
            parts.add('not');
          }
        } else {
          parts.add('not');
        }
      }

      parts.add(builder.verb);
    }

    if (builder.phrase.isNotEmpty) {
      parts.add(builder.phrase);
    }

    final sentence = parts.join(' ').trim();

    return '${sentence[0].toUpperCase()}${sentence.substring(1)}.';
  }
}

class _SentenceBuilder {
  final SentenceState state;

  String subject = '';
  String auxiliary = '';
  String verb = '';
  String phrase = '';

  _SentenceBuilder(this.state) {
    phrase = state.phrase?.text ?? '';
  }
}
