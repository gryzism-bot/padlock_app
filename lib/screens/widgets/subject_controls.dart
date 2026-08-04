part of '../home_screen.dart';

class _PronounSection extends StatelessWidget {
  final NounPhrase? agent;
  final ValueChanged<ConfigurationMove> onMove;

  const _PronounSection({required this.agent, required this.onMove});

  @override
  Widget build(BuildContext context) {
    return _ControlCard(
      title: 'Subject',
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final laneWidth = constraints.maxWidth >= 360
                ? (constraints.maxWidth - 6) / 2
                : constraints.maxWidth;

            return Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                SizedBox(
                  width: laneWidth,
                  child: _CompactChipCluster(
                    label: 'singular',
                    children: [
                      _MoveButton(
                        label: 'I',
                        selected: _sameNounPhrase(agent, i),
                        onPressed: () => onMove(const SetAgent(i)),
                      ),
                      _MoveButton(
                        label: 'you',
                        selected: _sameNounPhrase(agent, you),
                        onPressed: () => onMove(const SetAgent(you)),
                      ),
                      _MoveButton(
                        label: 'he',
                        selected: _sameNounPhrase(agent, he),
                        onPressed: () => onMove(const SetAgent(he)),
                      ),
                      _MoveButton(
                        label: 'she',
                        selected: _sameNounPhrase(agent, she),
                        onPressed: () => onMove(const SetAgent(she)),
                      ),
                      _MoveButton(
                        label: 'it',
                        selected: _sameNounPhrase(agent, it),
                        onPressed: () => onMove(const SetAgent(it)),
                      ),
                      _SubjectNounMenuButton(
                        tooltip: 'Choose 3rd person singular noun',
                        agent: agent,
                        isSelected: _isSelectedSubjectNoun(
                          agent,
                          _singularSubjectNounGroups,
                        ),
                        groups: _singularSubjectNounGroups,
                        onMove: onMove,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: laneWidth,
                  child: _CompactChipCluster(
                    label: 'plural',
                    children: [
                      _MoveButton(
                        label: 'we',
                        selected: _sameNounPhrase(agent, we),
                        onPressed: () => onMove(const SetAgent(we)),
                      ),
                      _MoveButton(
                        label: 'you',
                        selected: _sameNounPhrase(agent, youPlural),
                        onPressed: () => onMove(const SetAgent(youPlural)),
                      ),
                      _MoveButton(
                        label: 'they',
                        selected: _sameNounPhrase(agent, they),
                        onPressed: () => onMove(const SetAgent(they)),
                      ),
                      _SubjectNounMenuButton(
                        tooltip: 'Choose 3rd person plural noun',
                        agent: agent,
                        isSelected: _isSelectedSubjectNoun(
                          agent,
                          _pluralSubjectNounGroups,
                        ),
                        groups: _pluralSubjectNounGroups,
                        onMove: onMove,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SubjectNounChoice {
  final String label;
  final NounPhrase phrase;

  const _SubjectNounChoice({required this.label, required this.phrase});
}

class _SubjectNounGroup {
  final String label;
  final List<_SubjectNounChoice> choices;

  const _SubjectNounGroup({required this.label, required this.choices});
}

final _singularSubjectNounGroups = _uniqueSubjectNounGroups([
  _SubjectNounGroup(
    label: 'family',
    choices: _subjectNounChoices(people_categories.singularFamilyPeople),
  ),
  _SubjectNounGroup(
    label: 'work people',
    choices: _subjectNounChoices(people_categories.singularWorkPeople),
  ),
  _SubjectNounGroup(
    label: 'wild animals',
    choices: _subjectNounChoices(animal_categories.singularWildAnimals),
  ),
  _SubjectNounGroup(
    label: 'social people',
    choices: _subjectNounChoices(people_categories.singularSocialPeople),
  ),
  _SubjectNounGroup(
    label: 'names',
    choices: _subjectNounChoices(people_categories.singularNamedPeople),
  ),
  _SubjectNounGroup(
    label: 'pets',
    choices: _subjectNounChoices(animal_categories.singularPetAnimals),
  ),
  _SubjectNounGroup(
    label: 'public people',
    choices: _subjectNounChoices(people_categories.singularPublicPeople),
  ),
  _SubjectNounGroup(
    label: 'creative people',
    choices: _subjectNounChoices(people_categories.singularCreativePeople),
  ),
  _SubjectNounGroup(
    label: 'farm animals',
    choices: _subjectNounChoices(animal_categories.singularFarmAnimals),
  ),
  _SubjectNounGroup(
    label: 'school people',
    choices: _subjectNounChoices(people_categories.singularSchoolPeople),
  ),
  _SubjectNounGroup(
    label: 'birds',
    choices: _subjectNounChoices(animal_categories.singularBirdAnimals),
  ),
  _SubjectNounGroup(
    label: 'small animals',
    choices: _subjectNounChoices(animal_categories.singularSmallAnimals),
  ),
  _SubjectNounGroup(
    label: 'water animals',
    choices: _subjectNounChoices(animal_categories.singularWaterAnimals),
  ),
  _SubjectNounGroup(
    label: 'someone words',
    choices: [
      _SubjectNounChoice(label: 'someone', phrase: someone),
      _SubjectNounChoice(label: 'anyone', phrase: anyone),
      _SubjectNounChoice(label: 'nobody', phrase: nobody),
      _SubjectNounChoice(label: 'everyone', phrase: everyone),
    ],
  ),
]);

final _pluralSubjectNounGroups = _uniqueSubjectNounGroups([
  _SubjectNounGroup(
    label: 'family',
    choices: _subjectNounChoices(people_categories.pluralFamilyPeople),
  ),
  _SubjectNounGroup(
    label: 'work people',
    choices: _subjectNounChoices(people_categories.pluralWorkPeople),
  ),
  _SubjectNounGroup(
    label: 'wild animals',
    choices: _subjectNounChoices(animal_categories.pluralWildAnimals),
  ),
  _SubjectNounGroup(
    label: 'social people',
    choices: _subjectNounChoices(people_categories.pluralSocialPeople),
  ),
  _SubjectNounGroup(
    label: 'names',
    choices: _subjectNounChoices(people_categories.pluralNamedPeople),
  ),
  _SubjectNounGroup(
    label: 'pets',
    choices: _subjectNounChoices(animal_categories.pluralPetAnimals),
  ),
  _SubjectNounGroup(
    label: 'public people',
    choices: _subjectNounChoices(people_categories.pluralPublicPeople),
  ),
  _SubjectNounGroup(
    label: 'creative people',
    choices: _subjectNounChoices(people_categories.pluralCreativePeople),
  ),
  _SubjectNounGroup(
    label: 'farm animals',
    choices: _subjectNounChoices(animal_categories.pluralFarmAnimals),
  ),
  _SubjectNounGroup(
    label: 'school people',
    choices: _subjectNounChoices(people_categories.pluralSchoolPeople),
  ),
  _SubjectNounGroup(
    label: 'birds',
    choices: _subjectNounChoices(animal_categories.pluralBirdAnimals),
  ),
  _SubjectNounGroup(
    label: 'small animals',
    choices: _subjectNounChoices(animal_categories.pluralSmallAnimals),
  ),
  _SubjectNounGroup(
    label: 'water animals',
    choices: _subjectNounChoices(animal_categories.pluralWaterAnimals),
  ),
]);

List<_SubjectNounChoice> _subjectNounChoices(List<NounPhrase> phrases) {
  final seen = <String>{};
  return [
    for (final phrase in phrases)
      if (seen.add(phrase.text))
        _SubjectNounChoice(label: phrase.text, phrase: phrase),
  ];
}

List<_SubjectNounGroup> _uniqueSubjectNounGroups(
  List<_SubjectNounGroup> groups,
) {
  final seen = <String>{};
  return [
    for (final group in groups)
      _SubjectNounGroup(
        label: group.label,
        choices: [
          for (final choice in group.choices)
            if (seen.add(choice.phrase.text)) choice,
        ],
      ),
  ];
}

class _SubjectOverlayChoice {
  final String label;
  final ConfigurationMove move;
  final bool isSelected;

  const _SubjectOverlayChoice({
    required this.label,
    required this.move,
    this.isSelected = false,
  });
}

class _SubjectNounMenuButton extends StatelessWidget {
  final String tooltip;
  final NounPhrase? agent;
  final bool isSelected;
  final List<_SubjectNounGroup> groups;
  final ValueChanged<ConfigurationMove> onMove;

  const _SubjectNounMenuButton({
    required this.tooltip,
    required this.agent,
    required this.isSelected,
    required this.groups,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return PopupMenuButton<ConfigurationMove>(
      tooltip: tooltip,
      position: PopupMenuPosition.under,
      constraints: const BoxConstraints(maxHeight: 500, minWidth: 920),
      onSelected: onMove,
      itemBuilder: (context) => [
        _SubjectPopupColumnsEntry(
          agent: agent,
          isSelected: isSelected,
          groups: groups,
          onMove: onMove,
        ),
      ],
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? colors.primary : colors.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          child: Icon(
            Icons.expand_more,
            size: 16,
            color: isSelected ? colors.primary : colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _SubjectPopupColumnsEntry extends PopupMenuEntry<ConfigurationMove> {
  final NounPhrase? agent;
  final bool isSelected;
  final List<_SubjectNounGroup> groups;
  final ValueChanged<ConfigurationMove> onMove;

  const _SubjectPopupColumnsEntry({
    required this.agent,
    required this.isSelected,
    required this.groups,
    required this.onMove,
  });

  @override
  double get height => 440;

  @override
  bool represents(ConfigurationMove? value) => false;

  @override
  State<_SubjectPopupColumnsEntry> createState() =>
      _SubjectPopupColumnsEntryState();
}

class _SubjectPopupColumnsEntryState extends State<_SubjectPopupColumnsEntry> {
  bool isDeterminerExpanded = true;
  bool isAdjectiveExpanded = true;
  late NounPhrase? localAgent = widget.agent;

  bool get isLocalSelected =>
      localAgent != null &&
      widget.groups
          .expand((group) => group.choices)
          .any((choice) => _sameNounPhrase(localAgent, choice.phrase));

  List<_SubjectOverlayChoice> get determinerChoices {
    return _subjectDeterminerSuggestionsFor(localAgent);
  }

  List<_SubjectOverlayChoice> get adjectiveChoices {
    return _subjectAdjectiveSuggestionsFor(localAgent);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 900,
      height: 440,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: _SubjectPopupNounColumn(
                agent: localAgent,
                groups: widget.groups,
                onNounSelected: (phrase) {
                  final move = SetAgent(phrase);
                  widget.onMove(move);
                  setState(() {
                    localAgent = phrase;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: _SubjectPopupSuggestionColumn(
                label: 'determiner',
                enabled: isLocalSelected,
                isExpanded: isDeterminerExpanded,
                choices: determinerChoices,
                onChoiceSelected: (choice) {
                  widget.onMove(choice.move);
                  setState(() {
                    localAgent = _applyLocalSubjectModifier(
                      localAgent,
                      choice.move,
                    );
                  });
                },
                onToggle: () {
                  setState(() {
                    isDeterminerExpanded = !isDeterminerExpanded;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: _SubjectPopupSuggestionColumn(
                label: 'adjective',
                enabled: isLocalSelected,
                isExpanded: isAdjectiveExpanded,
                choices: adjectiveChoices,
                onChoiceSelected: (choice) {
                  widget.onMove(choice.move);
                  setState(() {
                    localAgent = _applyLocalSubjectModifier(
                      localAgent,
                      choice.move,
                    );
                  });
                },
                onToggle: () {
                  setState(() {
                    isAdjectiveExpanded = !isAdjectiveExpanded;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectPopupNounColumn extends StatefulWidget {
  final NounPhrase? agent;
  final List<_SubjectNounGroup> groups;
  final ValueChanged<NounPhrase> onNounSelected;

  const _SubjectPopupNounColumn({
    required this.agent,
    required this.groups,
    required this.onNounSelected,
  });

  @override
  State<_SubjectPopupNounColumn> createState() =>
      _SubjectPopupNounColumnState();
}

class _SubjectPopupNounColumnState extends State<_SubjectPopupNounColumn> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SubjectPopupColumnShell(
      label: 'noun',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 560
              ? 4
              : constraints.maxWidth >= 400
              ? 3
              : 2;
          final columnWidth =
              (constraints.maxWidth - (columns - 1) * 8) / columns;

          return Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            trackVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.only(right: 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  for (final group in widget.groups)
                    SizedBox(
                      width: columnWidth,
                      child: _SubjectPopupNounGroupColumn(
                        agent: widget.agent,
                        group: group,
                        onNounSelected: widget.onNounSelected,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SubjectPopupNounGroupColumn extends StatelessWidget {
  final NounPhrase? agent;
  final _SubjectNounGroup group;
  final ValueChanged<NounPhrase> onNounSelected;

  const _SubjectPopupNounGroupColumn({
    required this.agent,
    required this.group,
    required this.onNounSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _SubjectPopupGroupLabel(group.label),
        for (final choice in group.choices)
          _SubjectPopupMoveCell(
            label: choice.label,
            isSelected: _sameNounPhrase(agent, choice.phrase),
            onTap: () => onNounSelected(choice.phrase),
          ),
      ],
    );
  }
}

class _SubjectPopupSuggestionColumn extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool isExpanded;
  final List<_SubjectOverlayChoice> choices;
  final ValueChanged<_SubjectOverlayChoice> onChoiceSelected;
  final VoidCallback onToggle;

  const _SubjectPopupSuggestionColumn({
    required this.label,
    required this.enabled,
    required this.isExpanded,
    required this.choices,
    required this.onChoiceSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return _SubjectPopupColumnShell(
      label: label,
      isExpanded: isExpanded,
      canExpand: enabled && choices.isNotEmpty,
      onToggle: enabled && choices.isNotEmpty ? onToggle : null,
      child: !enabled
          ? Text(
              'choose noun',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            )
          : !isExpanded
          ? const SizedBox.shrink()
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final choice in choices)
                  _SubjectPopupMoveCell(
                    label: choice.label,
                    isSelected: choice.isSelected,
                    onTap: () => onChoiceSelected(choice),
                  ),
              ],
            ),
    );
  }
}

class _SubjectPopupColumnShell extends StatelessWidget {
  final String label;
  final Widget child;
  final bool? isExpanded;
  final bool canExpand;
  final VoidCallback? onToggle;

  const _SubjectPopupColumnShell({
    required this.label,
    required this.child,
    this.isExpanded,
    this.canExpand = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final header = _SubjectPopupHeader(
      label,
      isExpanded: isExpanded,
      canExpand: canExpand,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        onToggle == null
            ? header
            : InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: onToggle,
                child: header,
              ),
        const SizedBox(height: 6),
        Expanded(child: child),
      ],
    );
  }
}

class _SubjectPopupMoveCell extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubjectPopupMoveCell({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                child: isSelected
                    ? Icon(Icons.check, size: 14, color: colors.primary)
                    : null,
              ),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectPopupGroupLabel extends StatelessWidget {
  final String label;

  const _SubjectPopupGroupLabel(this.label);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colors.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

List<_SubjectOverlayChoice> _subjectDeterminerSuggestionsFor(
  NounPhrase? phrase,
) {
  if (phrase == null || !phrase.canTakeModifiers) {
    return const [];
  }

  return [
    _SubjectOverlayChoice(
      move: const SetNounPhraseDeterminer(NounPhraseTarget.agent, null),
      label: 'no determiner',
      isSelected: phrase.determiner == null,
    ),
    for (final determiner in allDeterminers)
      if (_subjectDeterminerFits(phrase, determiner.text))
        _SubjectOverlayChoice(
          move: SetNounPhraseDeterminer(NounPhraseTarget.agent, determiner),
          label: determiner.text,
          isSelected: phrase.determiner == determiner,
        ),
  ];
}

List<_SubjectOverlayChoice> _subjectAdjectiveSuggestionsFor(
  NounPhrase? phrase,
) {
  if (phrase == null || !phrase.canTakeModifiers) {
    return const [];
  }

  final current = phrase.adjectiveList;

  return [
    _SubjectOverlayChoice(
      move: const SetNounPhraseAdjectives(NounPhraseTarget.agent, []),
      label: 'no adjective',
      isSelected: current.isEmpty,
    ),
    for (final adjective in current)
      _SubjectOverlayChoice(
        move: SetNounPhraseAdjectives(NounPhraseTarget.agent, current),
        label: adjective.text,
        isSelected: true,
      ),
    for (final adjective in adjective_data.adjectives)
      if (!current.contains(adjective) &&
          _subjectDeterminerFits(
            phrase.copyWith(adjectives: [...current, adjective]),
            phrase.determiner?.text,
          ))
        _SubjectOverlayChoice(
          move: SetNounPhraseAdjectives(NounPhraseTarget.agent, [
            ...current,
            adjective,
          ]),
          label: adjective.text,
        ),
  ];
}

NounPhrase? _applyLocalSubjectModifier(
  NounPhrase? phrase,
  ConfigurationMove move,
) {
  if (phrase == null) {
    return null;
  }

  return switch (move) {
    SetNounPhraseDeterminer(:final target, :final determiner)
        when target == NounPhraseTarget.agent =>
      phrase.copyWith(determiner: determiner),
    SetNounPhraseAdjectives(:final target, :final adjectives)
        when target == NounPhraseTarget.agent =>
      phrase.copyWith(
        adjective: adjectives.isEmpty ? null : adjectives.first,
        adjectives: adjectives,
      ),
    _ => phrase,
  };
}

bool _subjectDeterminerFits(NounPhrase phrase, String? determinerText) {
  if (determinerText == null) {
    return true;
  }

  if (_subjectSingularDeterminers.contains(determinerText) && phrase.isPlural) {
    return false;
  }

  if (_subjectPluralDeterminers.contains(determinerText) && !phrase.isPlural) {
    return false;
  }

  final firstSpokenWord = phrase.adjectiveList.isEmpty
      ? phrase.text
      : phrase.adjectiveList.first.text;

  if (determinerText == 'a' && _subjectStartsWithVowelLetter(firstSpokenWord)) {
    return false;
  }

  if (determinerText == 'an' &&
      !_subjectStartsWithVowelLetter(firstSpokenWord)) {
    return false;
  }

  return true;
}

const _subjectSingularDeterminers = {
  'a',
  'an',
  'this',
  'that',
  'each',
  'every',
};
const _subjectPluralDeterminers = {'these', 'those', 'all', 'many'};

bool _subjectStartsWithVowelLetter(String text) {
  final normalized = text.trim().toLowerCase();
  if (normalized.isEmpty) {
    return false;
  }

  return 'aeiou'.contains(normalized[0]);
}

class _SubjectPopupHeader extends StatelessWidget {
  final String label;
  final bool? isExpanded;
  final bool canExpand;

  const _SubjectPopupHeader(
    this.label, {
    this.isExpanded,
    this.canExpand = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (canExpand && isExpanded != null)
          Icon(
            isExpanded! ? Icons.expand_less : Icons.expand_more,
            size: 16,
            color: colors.primary,
          ),
      ],
    );
  }
}

bool _isSelectedSubjectNoun(NounPhrase? agent, List<_SubjectNounGroup> groups) {
  if (agent == null) {
    return false;
  }

  return groups
      .expand((group) => group.choices)
      .any((choice) => _sameNounPhrase(agent, choice.phrase));
}
