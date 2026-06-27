import 'package:padlock_app/models/grammar/verb/aspect.dart';
import 'package:padlock_app/models/grammar/verb/modal.dart';
import 'package:padlock_app/models/grammar/phrase/phrase_position.dart';
import 'package:padlock_app/models/grammar/verb/polarity.dart';
import 'package:padlock_app/models/grammar/voice.dart';
import 'package:padlock_app/models/sentence/sentence.dart';
import 'package:padlock_app/models/grammar/sentence_form.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';

class GrammarEngine {
  Sentence generate(SentenceState state) {
    final builder = _SentenceBuilder(state);

    _applySubject(builder);
    _applyTense(builder);
    _applyAspect(builder);
    _applyModal(builder);

    final text = _applyVoice(builder);

    return Sentence(text: text, state: state);
  }

  String _applyVoice(_SentenceBuilder builder) {
    switch (builder.voice) {
      case Voice.active:
        return _buildActive(builder);

      case Voice.passive:
        return _buildPassive(builder);
    }
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

  String _buildActive(_SentenceBuilder builder) {
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
        if (builder.determiner.isNotEmpty) {
          parts.add(builder.determiner);
        }

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
        if (builder.determiner.isNotEmpty) {
          parts.add(builder.determiner);
        }

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

  String _buildPassive(_SentenceBuilder builder) {
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
      switch (state.modal) {
        case Modal.none:
          _buildPassiveQuestionWithoutModal(builder, parts);
          break;

        default:
          parts.add(builder.auxiliary);

          if (builder.determiner.isNotEmpty) {
            parts.add(builder.determiner);
          }

          parts.add(builder.subject);

          parts.add('be');
          parts.add(state.verb.pastParticiple);
          break;
      }
    }
    // ---------- STATEMENT / IMPERATIVE ----------
    else {
      if (state.sentenceForm != SentenceForm.imperative) {
        if (builder.determiner.isNotEmpty) {
          parts.add(builder.determiner);
        }

        parts.add(builder.subject);
      }

      switch (state.modal) {
        case Modal.none:
          _buildPassivePredicateWithoutModal(builder, parts);
          break;

        default:
          parts.add(builder.auxiliary);
          parts.add('be');
          parts.add(state.verb.pastParticiple);
          break;
      }
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

  void _buildPassivePredicateWithoutModal(
    _SentenceBuilder builder,
    List<String> parts,
  ) {
    final state = builder.state;

    switch (state.aspect) {
      case Aspect.simple:
        switch (state.tense) {
          case Tense.present:
            parts.add(state.subject.isPlural ? 'are' : 'is');
            break;

          case Tense.past:
            parts.add(state.subject.isPlural ? 'were' : 'was');
            break;

          case Tense.future:
            parts.add('will');
            parts.add('be');
            break;
        }

        parts.add(state.verb.pastParticiple);
        break;

      case Aspect.continuous:
        switch (state.tense) {
          case Tense.present:
            parts.add(state.subject.isPlural ? 'are' : 'is');
            parts.add('being');
            break;

          case Tense.past:
            parts.add(state.subject.isPlural ? 'were' : 'was');
            parts.add('being');
            break;

          case Tense.future:
            throw UnimplementedError();
        }

        parts.add(state.verb.pastParticiple);
        break;

      case Aspect.perfect:
        switch (state.tense) {
          case Tense.present:
            parts.add(state.subject.takesThirdPersonVerb ? 'has' : 'have');
            parts.add('been');
            break;

          case Tense.past:
            parts.add('had');
            parts.add('been');
            break;

          case Tense.future:
            parts.add('will');
            parts.add('have');
            parts.add('been');
            break;
        }

        parts.add(state.verb.pastParticiple);
        break;

      case Aspect.perfectContinuous:
        throw UnimplementedError();
    }
  }

  void _buildPassiveQuestionWithoutModal(
    _SentenceBuilder builder,
    List<String> parts,
  ) {
    final state = builder.state;

    switch (state.aspect) {
      case Aspect.simple:
        switch (state.tense) {
          case Tense.present:
            parts.add(state.subject.isPlural ? 'are' : 'is');
            break;

          case Tense.past:
            parts.add(state.subject.isPlural ? 'were' : 'was');
            break;

          case Tense.future:
            parts.add('will');
            break;
        }

        if (builder.determiner.isNotEmpty) {
          parts.add(builder.determiner);
        }

        parts.add(builder.subject);

        if (state.tense == Tense.future) {
          parts.add('be');
        }

        parts.add(state.verb.pastParticiple);
        break;

      case Aspect.continuous:
        switch (state.tense) {
          case Tense.present:
            parts.add(state.subject.isPlural ? 'are' : 'is');
            break;

          case Tense.past:
            parts.add(state.subject.isPlural ? 'were' : 'was');
            break;

          case Tense.future:
            throw UnimplementedError();
        }

        if (builder.determiner.isNotEmpty) {
          parts.add(builder.determiner);
        }

        parts.add(builder.subject);
        parts.add('being');
        parts.add(state.verb.pastParticiple);
        break;

      case Aspect.perfect:
        switch (state.tense) {
          case Tense.present:
            parts.add(state.subject.takesThirdPersonVerb ? 'has' : 'have');
            break;

          case Tense.past:
            parts.add('had');
            break;

          case Tense.future:
            parts.add('will');
            break;
        }

        if (builder.determiner.isNotEmpty) {
          parts.add(builder.determiner);
        }

        parts.add(builder.subject);

        if (state.tense == Tense.future) {
          parts.add('have');
        }

        parts.add('been');
        parts.add(state.verb.pastParticiple);
        break;

      case Aspect.perfectContinuous:
        throw UnimplementedError();
    }
  }
}

class _SentenceBuilder {
  final SentenceState state;

  final Voice voice;

  String determiner = '';
  String subject = '';
  String auxiliary = '';
  String helper = '';
  String verb = '';

  String timePhrase = '';
  String placePhrase = '';

  _SentenceBuilder(this.state) : voice = state.voice {
    determiner = state.subject.determiner?.text ?? '';

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
