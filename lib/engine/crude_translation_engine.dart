import 'package:padlock_app/models/grammar/phrase/place_meaning.dart';
import 'package:padlock_app/models/grammar/recipient_placement.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';
import 'package:padlock_app/models/grammar/subject/person.dart';
import 'package:padlock_app/models/grammar/verb/tense.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';
import 'package:padlock_app/models/grammar/voice.dart';
import 'package:padlock_app/models/language.dart';
import 'package:padlock_app/models/sentence/sentence_state.dart';

class CrudeTranslationEngine {
  const CrudeTranslationEngine();

  String? translateVerb(Verb verb, {Language language = Language.pl}) {
    return _infinitiveTranslation(verb, language);
  }

  String translateSentence({
    required String renderedSentence,
    required SentenceState state,
    Language language = Language.pl,
  }) {
    final replacements = <_TranslationReplacement>[];

    void add(String source, String? target) {
      if (source.trim().isEmpty || target == null || target.trim().isEmpty) {
        return;
      }

      replacements.add(_TranslationReplacement(source, target));
    }

    for (final nounPhrase in [
      state.agent,
      state.object,
      state.recipient,
      state.addressee,
      state.companion,
      state.destination,
      state.topic,
      state.beneficiary,
      state.objectComplement,
      state.complement,
    ]) {
      if (nounPhrase == null) {
        continue;
      }

      add(
        _renderNounPhrase(nounPhrase),
        _translateNounPhrase(nounPhrase, language),
      );
      add(
        _renderObjectCase(nounPhrase),
        _translateNounPhrase(nounPhrase, language),
      );
    }

    for (final adjective in [
      ...?state.object?.adjectiveList,
      ...?state.recipient?.adjectiveList,
      ...?state.addressee?.adjectiveList,
      ...?state.companion?.adjectiveList,
      ...?state.destination?.adjectiveList,
      ...?state.topic?.adjectiveList,
      ...?state.beneficiary?.adjectiveList,
      ...?state.complement?.adjectiveList,
      state.objectAdjectiveComplement,
      state.adjectiveComplement,
    ]) {
      if (adjective == null) {
        continue;
      }

      add(adjective.text, adjective.translations[language]);
    }

    for (final entry in _verbSurfaceTranslations(
      state.action,
      state,
      language,
    ).entries) {
      add(entry.key, entry.value);
    }

    if (state.rightAction != null) {
      final rightActionTranslation = _infinitiveTranslation(
        state.rightAction!,
        language,
      );
      add(state.rightAction!.infinitive, rightActionTranslation);
    }

    if (!state.modal.isNone) {
      add(state.modal.text, _modalTranslation(state.modal.text, language));
    }

    if (state.timePhrase != null) {
      add(state.timePhrase!.render(), state.timePhrase!.translations[language]);
    }
    if (state.frequencyPhrase != null) {
      add(
        state.frequencyPhrase!.render(),
        state.frequencyPhrase!.translations[language],
      );
    }
    if (state.mannerPhrase != null) {
      add(
        state.mannerPhrase!.render(),
        state.mannerPhrase!.translations[language],
      );
    }
    if (state.placePhrase != null) {
      final meaning =
          state.placeMeaning ??
          (state.action.usesDestinationPlace
              ? PlaceMeaning.destination
              : PlaceMeaning.location);
      add(
        state.placePhrase!.render(meaning),
        _translatePlacePhrase(state, language),
      );
    }

    if (state.recipient != null) {
      final preposition =
          state.voice.name == 'passive' ||
              state.recipientPlacement == RecipientPlacement.toPhrase
          ? state.recipientPreposition.text
          : null;
      if (preposition != null) {
        add(preposition, _prepositionTranslation(preposition, language));
      }
    }
    if (state.topic != null) {
      add('about', _prepositionTranslation('about', language));
    }
    if (state.beneficiary != null) {
      add('for', _prepositionTranslation('for', language));
    }

    for (final entry in _supportWordTranslations(state, language).entries) {
      add(entry.key, entry.value);
    }

    var translated = renderedSentence;
    replacements.sort(
      (left, right) => right.source.length.compareTo(left.source.length),
    );
    for (final replacement in replacements) {
      translated = _replacePhrase(
        translated,
        replacement.source,
        replacement.target,
      );
    }

    return _moveTerminalPunctuationIntoFinalIngredient(translated);
  }

  String? _translatePlacePhrase(SentenceState state, Language language) {
    final place = state.placePhrase;
    if (place == null) {
      return null;
    }

    final meaning =
        state.placeMeaning ??
        (state.action.usesDestinationPlace
            ? PlaceMeaning.destination
            : PlaceMeaning.location);
    final preposition = place.prepositions[meaning];
    final translatedPlace = place.translations[language] ?? place.noun;

    if (preposition == null) {
      return translatedPlace;
    }

    final translatedPreposition =
        preposition.translations[language] ??
        _prepositionTranslation(preposition.text, language) ??
        preposition.text;

    return '$translatedPreposition $translatedPlace';
  }
}

class _TranslationReplacement {
  final String source;
  final String target;

  const _TranslationReplacement(this.source, this.target);
}

String? _translateNounPhrase(NounPhrase nounPhrase, Language language) {
  final noun = nounPhrase.translations[language] ?? nounPhrase.text;
  final parts = <String>[
    if (nounPhrase.determiner?.translations[language] != null)
      nounPhrase.determiner!.translations[language]!,
    for (final adjective in nounPhrase.adjectiveList)
      adjective.translations[language] ?? adjective.text,
    noun,
  ];

  return parts.join(' ');
}

String _renderNounPhrase(NounPhrase nounPhrase) {
  return [
    if (nounPhrase.determiner != null) nounPhrase.determiner!.text,
    for (final adjective in nounPhrase.adjectiveList) adjective.text,
    nounPhrase.text.toLowerCase() == 'i' ? 'I' : nounPhrase.text,
  ].join(' ');
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

  return [
    if (nounPhrase.determiner != null) nounPhrase.determiner!.text,
    for (final adjective in nounPhrase.adjectiveList) adjective.text,
    objectText,
  ].join(' ');
}

String? _modalTranslation(String modal, Language language) {
  if (language != Language.pl) {
    return null;
  }

  return switch (modal) {
    'can' => 'moc',
    'could' => 'moglby',
    'may' => 'moze',
    'might' => 'moglby',
    'must' => 'musi',
    'shall' => 'bedzie',
    'should' => 'powinien',
    'will' => 'bedzie',
    'would' => 'chcialby',
    _ => null,
  };
}

String? _prepositionTranslation(String preposition, Language language) {
  if (language != Language.pl) {
    return null;
  }

  return switch (preposition) {
    'to' => 'do',
    'for' => 'dla',
    'about' => 'o',
    'by' => 'przez',
    'with' => 'z',
    'at' => 'w',
    'in' => 'w',
    'from' => 'z',
    'on' => 'na',
    _ => null,
  };
}

Map<String, String?> _verbSurfaceTranslations(
  Verb verb,
  SentenceState state,
  Language language,
) {
  final base = _infinitiveTranslation(verb, language);
  final translations = <String, String?>{
    verb.infinitive: base,
    verb.presentThirdPerson: base,
    verb.pastSimple: base,
    verb.pastParticiple: base,
    verb.ingForm: base,
  };

  if (language != Language.pl) {
    return translations;
  }

  if (state.modal.isNone && state.tense == Tense.present) {
    final present = _presentTranslation(verb, state.agent) ?? base;
    translations[verb.infinitive] = present;
    translations[verb.presentThirdPerson] = present;
  }

  if (state.modal.isNone && state.tense == Tense.past) {
    translations[verb.pastSimple] = _pastTranslation(verb, state.agent) ?? base;
  }

  return translations;
}

String? _infinitiveTranslation(Verb verb, Language language) {
  if (language != Language.pl) {
    return verb.translations[language];
  }

  return _polishVerbForms[verb.infinitive]?.infinitive ??
      verb.translations[language];
}

Map<String, String> _supportWordTranslations(
  SentenceState state,
  Language language,
) {
  if (language != Language.pl) {
    return const {};
  }

  final subject = _displaySubjectForTranslation(state);
  return {
    'am': _presentTranslationForForms(_polishVerbForms['be'], subject) ?? 'być',
    'is': _presentTranslationForForms(_polishVerbForms['be'], subject) ?? 'być',
    'are':
        _presentTranslationForForms(_polishVerbForms['be'], subject) ?? 'być',
    'was': _pastTranslationForForms(_polishVerbForms['be'], subject) ?? 'być',
    'were': _pastTranslationForForms(_polishVerbForms['be'], subject) ?? 'być',
    'be': 'być',
    'being': 'być',
    'been': 'być',
    'have':
        _presentTranslationForForms(_polishVerbForms['have'], state.agent) ??
        'mieć',
    'has':
        _presentTranslationForForms(_polishVerbForms['have'], state.agent) ??
        'mieć',
    'had':
        _pastTranslationForForms(_polishVerbForms['have'], state.agent) ??
        'mieć',
    'do':
        _presentTranslationForForms(_polishVerbForms['do'], state.agent) ??
        'robić',
    'does':
        _presentTranslationForForms(_polishVerbForms['do'], state.agent) ??
        'robić',
    'did':
        _pastTranslationForForms(_polishVerbForms['do'], state.agent) ??
        'robić',
    'will': 'będzie',
    'not': 'nie',
    'cannot': 'nie móc',
    'to': 'do',
    'for': 'dla',
    'by': 'przez',
    'with': 'z',
  };
}

NounPhrase? _displaySubjectForTranslation(SentenceState state) {
  if (state.voice == Voice.active || state.action.infinitive == 'be') {
    return state.agent;
  }

  return state.object ??
      state.recipient ??
      state.objectComplement ??
      state.complement ??
      state.agent;
}

String? _presentTranslation(Verb verb, NounPhrase? subject) {
  return _presentTranslationForForms(
    _polishVerbForms[verb.infinitive],
    subject,
  );
}

String? _presentTranslationForForms(
  _PolishVerbForms? forms,
  NounPhrase? subject,
) {
  if (forms == null || subject == null) {
    return null;
  }

  return switch ((subject.person, subject.number)) {
    (Person.first, Number.singular) => forms.presentFirstSingular,
    (Person.second, Number.singular) => forms.presentSecondSingular,
    (Person.third, Number.singular) => forms.presentThirdSingular,
    (Person.first, Number.plural) => forms.presentFirstPlural,
    (Person.second, Number.plural) => forms.presentSecondPlural,
    (Person.third, Number.plural) => forms.presentThirdPlural,
  };
}

String? _pastTranslation(Verb verb, NounPhrase? subject) {
  return _pastTranslationForForms(_polishVerbForms[verb.infinitive], subject);
}

String? _pastTranslationForForms(_PolishVerbForms? forms, NounPhrase? subject) {
  if (forms == null || subject == null) {
    return null;
  }

  return switch ((subject.person, subject.number)) {
    (Person.first, Number.singular) => forms.pastFirstSingular,
    (Person.second, Number.singular) => forms.pastSecondSingular,
    (Person.third, Number.singular) => _thirdSingularPast(forms, subject),
    (Person.first, Number.plural) => forms.pastFirstPlural,
    (Person.second, Number.plural) => forms.pastSecondPlural,
    (Person.third, Number.plural) => forms.pastThirdPlural,
  };
}

String _thirdSingularPast(_PolishVerbForms forms, NounPhrase subject) {
  return switch (subject.text.toLowerCase()) {
    'she' || 'mary' || 'anna' => forms.pastThirdFeminine,
    'it' => forms.pastThirdNeuter,
    _ => forms.pastThirdMasculine,
  };
}

class _PolishVerbForms {
  final String infinitive;
  final String presentFirstSingular;
  final String presentSecondSingular;
  final String presentThirdSingular;
  final String presentFirstPlural;
  final String presentSecondPlural;
  final String presentThirdPlural;
  final String pastFirstSingular;
  final String pastSecondSingular;
  final String pastThirdMasculine;
  final String pastThirdFeminine;
  final String pastThirdNeuter;
  final String pastFirstPlural;
  final String pastSecondPlural;
  final String pastThirdPlural;

  const _PolishVerbForms({
    required this.infinitive,
    required this.presentFirstSingular,
    required this.presentSecondSingular,
    required this.presentThirdSingular,
    required this.presentFirstPlural,
    required this.presentSecondPlural,
    required this.presentThirdPlural,
    required this.pastFirstSingular,
    required this.pastSecondSingular,
    required this.pastThirdMasculine,
    required this.pastThirdFeminine,
    required this.pastThirdNeuter,
    required this.pastFirstPlural,
    required this.pastSecondPlural,
    required this.pastThirdPlural,
  });
}

const _polishVerbForms = {
  'be': _PolishVerbForms(
    infinitive: 'być',
    presentFirstSingular: 'jestem',
    presentSecondSingular: 'jesteś',
    presentThirdSingular: 'jest',
    presentFirstPlural: 'jesteśmy',
    presentSecondPlural: 'jesteście',
    presentThirdPlural: 'są',
    pastFirstSingular: 'byłem/byłam',
    pastSecondSingular: 'byłeś/byłaś',
    pastThirdMasculine: 'był',
    pastThirdFeminine: 'była',
    pastThirdNeuter: 'było',
    pastFirstPlural: 'byliśmy/byłyśmy',
    pastSecondPlural: 'byliście/byłyście',
    pastThirdPlural: 'byli/były',
  ),
  'have': _PolishVerbForms(
    infinitive: 'mieć',
    presentFirstSingular: 'mam',
    presentSecondSingular: 'masz',
    presentThirdSingular: 'ma',
    presentFirstPlural: 'mamy',
    presentSecondPlural: 'macie',
    presentThirdPlural: 'mają',
    pastFirstSingular: 'miałem/miałam',
    pastSecondSingular: 'miałeś/miałaś',
    pastThirdMasculine: 'miał',
    pastThirdFeminine: 'miała',
    pastThirdNeuter: 'miało',
    pastFirstPlural: 'mieliśmy/miałyśmy',
    pastSecondPlural: 'mieliście/miałyście',
    pastThirdPlural: 'mieli/miały',
  ),
  'do': _PolishVerbForms(
    infinitive: 'robić',
    presentFirstSingular: 'robię',
    presentSecondSingular: 'robisz',
    presentThirdSingular: 'robi',
    presentFirstPlural: 'robimy',
    presentSecondPlural: 'robicie',
    presentThirdPlural: 'robią',
    pastFirstSingular: 'zrobiłem/zrobiłam',
    pastSecondSingular: 'zrobiłeś/zrobiłaś',
    pastThirdMasculine: 'zrobił',
    pastThirdFeminine: 'zrobiła',
    pastThirdNeuter: 'zrobiło',
    pastFirstPlural: 'zrobiliśmy/zrobiłyśmy',
    pastSecondPlural: 'zrobiliście/zrobiłyście',
    pastThirdPlural: 'zrobili/zrobiły',
  ),
  'play': _PolishVerbForms(
    infinitive: 'grać',
    presentFirstSingular: 'gram',
    presentSecondSingular: 'grasz',
    presentThirdSingular: 'gra',
    presentFirstPlural: 'gramy',
    presentSecondPlural: 'gracie',
    presentThirdPlural: 'grają',
    pastFirstSingular: 'grałem/grałam',
    pastSecondSingular: 'grałeś/grałaś',
    pastThirdMasculine: 'grał',
    pastThirdFeminine: 'grała',
    pastThirdNeuter: 'grało',
    pastFirstPlural: 'graliśmy/grałyśmy',
    pastSecondPlural: 'graliście/grałyście',
    pastThirdPlural: 'grali/grały',
  ),
  'learn': _PolishVerbForms(
    infinitive: 'uczyć się',
    presentFirstSingular: 'uczę się',
    presentSecondSingular: 'uczysz się',
    presentThirdSingular: 'uczy się',
    presentFirstPlural: 'uczymy się',
    presentSecondPlural: 'uczycie się',
    presentThirdPlural: 'uczą się',
    pastFirstSingular: 'uczyłem się/uczyłam się',
    pastSecondSingular: 'uczyłeś się/uczyłaś się',
    pastThirdMasculine: 'uczył się',
    pastThirdFeminine: 'uczyła się',
    pastThirdNeuter: 'uczyło się',
    pastFirstPlural: 'uczyliśmy się/uczyłyśmy się',
    pastSecondPlural: 'uczyliście się/uczyłyście się',
    pastThirdPlural: 'uczyli się/uczyły się',
  ),
  'work': _PolishVerbForms(
    infinitive: 'pracować',
    presentFirstSingular: 'pracuję',
    presentSecondSingular: 'pracujesz',
    presentThirdSingular: 'pracuje',
    presentFirstPlural: 'pracujemy',
    presentSecondPlural: 'pracujecie',
    presentThirdPlural: 'pracują',
    pastFirstSingular: 'pracowałem/pracowałam',
    pastSecondSingular: 'pracowałeś/pracowałaś',
    pastThirdMasculine: 'pracował',
    pastThirdFeminine: 'pracowała',
    pastThirdNeuter: 'pracowało',
    pastFirstPlural: 'pracowaliśmy/pracowałyśmy',
    pastSecondPlural: 'pracowaliście/pracowałyście',
    pastThirdPlural: 'pracowali/pracowały',
  ),
  'read': _PolishVerbForms(
    infinitive: 'czytać',
    presentFirstSingular: 'czytam',
    presentSecondSingular: 'czytasz',
    presentThirdSingular: 'czyta',
    presentFirstPlural: 'czytamy',
    presentSecondPlural: 'czytacie',
    presentThirdPlural: 'czytają',
    pastFirstSingular: 'czytałem/czytałam',
    pastSecondSingular: 'czytałeś/czytałaś',
    pastThirdMasculine: 'czytał',
    pastThirdFeminine: 'czytała',
    pastThirdNeuter: 'czytało',
    pastFirstPlural: 'czytaliśmy/czytałyśmy',
    pastSecondPlural: 'czytaliście/czytałyście',
    pastThirdPlural: 'czytali/czytały',
  ),
};

String _replacePhrase(String text, String source, String target) {
  final pattern = RegExp(
    '(^|[^A-Za-z])(${RegExp.escape(source)})(?=[^A-Za-z]|\$)',
    caseSensitive: false,
  );

  return text.replaceAllMapped(pattern, (match) {
    final prefix = match.group(1) ?? '';
    final matched = match.group(2) ?? source;
    final adjustedTarget = _matchCapitalization(matched, target);
    return '$prefix($adjustedTarget)';
  });
}

String _moveTerminalPunctuationIntoFinalIngredient(String text) {
  if (text.length < 2) {
    return text;
  }

  final punctuation = text[text.length - 1];
  if (!'.?!'.contains(punctuation) || text[text.length - 2] != ')') {
    return text;
  }

  return '${text.substring(0, text.length - 2)}$punctuation)';
}

String _matchCapitalization(String source, String target) {
  if (source.isEmpty || target.isEmpty) {
    return target;
  }

  if (source[0].toUpperCase() == source[0]) {
    return target[0].toUpperCase() + target.substring(1);
  }

  return target;
}
