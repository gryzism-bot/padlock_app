import '../models/aspect.dart';
import '../models/modal.dart';
import '../models/polarity.dart';
import '../models/sentence.dart';
import '../models/sentence_form.dart';
import '../models/sentence_state.dart';
import '../models/subject.dart';
import '../models/tense.dart';

class GrammarEngine {
  Sentence generate(SentenceState state) {
    final builder = _SentenceBuilder(state);

    _applyTense(builder);
    _applyAspect(builder);
    _applyModal(builder);
    _applyPolarity(builder);
    _applySentenceForm(builder);

    final text = _buildSentence(builder);

    return Sentence(text: text, state: state);
  }

  void _applyTense(_SentenceBuilder builder) {
    switch (builder.state.tense) {
      case Tense.present:
        if (builder.state.subject.takesThirdPersonVerb) {
          builder.verb = builder.state.verb.presentThirdPerson;
        } else {
          builder.verb = builder.state.verb.infinitive;
        }
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

  void _applyPolarity(_SentenceBuilder builder) {
    switch (builder.state.polarity) {
      case Polarity.positive:
        builder.negative = false;
        break;

      case Polarity.negative:
        builder.negative = true;
        break;
    }
  }

  void _applySentenceForm(_SentenceBuilder builder) {
    switch (builder.state.sentenceForm) {
      case SentenceForm.statement:
        break;

      case SentenceForm.question:
        builder.question = true;
        break;

      case SentenceForm.imperative:
        builder.subject = '';
        break;
    }
  }

  String _buildSentence(_SentenceBuilder builder) {
    final parts = <String>[];

    if (builder.question) {
      if (builder.auxiliary.isEmpty) {
        if (builder.state.tense == Tense.present) {
          builder.auxiliary = builder.state.subject.takesThirdPersonVerb
              ? 'does'
              : 'do';

          builder.verb = builder.state.verb.infinitive;
        } else if (builder.state.tense == Tense.past) {
          builder.auxiliary = 'did';
          builder.verb = builder.state.verb.infinitive;
        }
      }

      parts.add(builder.auxiliary);

      if (builder.subject.isNotEmpty) {
        parts.add(builder.subject);
      }

      if (builder.negative) {
        parts.add('not');
      }

      parts.add(builder.verb);
    } else {
      if (builder.subject.isNotEmpty) {
        parts.add(builder.subject);
      }

      if (builder.auxiliary.isNotEmpty) {
        parts.add(builder.auxiliary);
      }

      if (builder.negative) {
        if (builder.auxiliary.isEmpty) {
          if (builder.state.tense == Tense.present) {
            parts.add(
              builder.state.subject.takesThirdPersonVerb
                  ? 'does not'
                  : 'do not',
            );
            builder.verb = builder.state.verb.infinitive;
          } else if (builder.state.tense == Tense.past) {
            parts.add('did not');
            builder.verb = builder.state.verb.infinitive;
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

  bool negative = false;
  bool question = false;

  _SentenceBuilder(this.state) {
    subject = state.subject.text;
    verb = state.verb.infinitive;
    phrase = state.phrase?.text ?? '';
  }
}
