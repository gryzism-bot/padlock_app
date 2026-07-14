import 'package:padlock_app/data/subjects/third_person/people.dart' as people;
import 'package:padlock_app/models/grammar/subject/noun.dart';
import 'package:padlock_app/models/grammar/subject/noun_phrase.dart';
import 'package:padlock_app/models/grammar/subject/number.dart';

const namedPersonNouns = [people.john, people.mary, people.tom, people.anna];

const familyPersonNouns = [
  people.parent,
  people.mother,
  people.father,
  people.sister,
  people.brother,
  people.child,
  people.man,
  people.woman,
  people.boy,
  people.girl,
];

const schoolPersonNouns = [people.teacher, people.student, people.classmate];

const workPersonNouns = [
  people.boss,
  people.colleague,
  people.customer,
  people.manager,
  people.worker,
  people.engineer,
  people.programmer,
  people.driver,
  people.policeOfficer,
];

const creativePersonNouns = [
  people.musician,
  people.artist,
  people.writer,
  people.cook,
  people.baker,
];

const socialPersonNouns = [
  people.friend,
  people.enemy,
  people.neighbour,
  people.person,
];

const publicPersonNouns = [people.doctor, people.nurse, people.farmer];

List<NounPhrase> _singular(List<Noun> nouns) {
  return [for (final noun in nouns) noun.toNounPhrase(Number.singular)];
}

List<NounPhrase> _plural(List<Noun> nouns) {
  return [for (final noun in nouns) noun.toNounPhrase(Number.plural)];
}

final singularNamedPeople = _singular(namedPersonNouns);
final pluralNamedPeople = _plural(namedPersonNouns);

final singularFamilyPeople = _singular(familyPersonNouns);
final pluralFamilyPeople = _plural(familyPersonNouns);

final singularSchoolPeople = _singular(schoolPersonNouns);
final pluralSchoolPeople = _plural(schoolPersonNouns);

final singularWorkPeople = _singular(workPersonNouns);
final pluralWorkPeople = _plural(workPersonNouns);

final singularCreativePeople = _singular(creativePersonNouns);
final pluralCreativePeople = _plural(creativePersonNouns);

final singularSocialPeople = _singular(socialPersonNouns);
final pluralSocialPeople = _plural(socialPersonNouns);

final singularPublicPeople = _singular(publicPersonNouns);
final pluralPublicPeople = _plural(publicPersonNouns);

final singularEverydayPeople = [
  ...singularNamedPeople,
  ...singularFamilyPeople,
  ...singularSchoolPeople,
  ...singularWorkPeople,
  ...singularCreativePeople,
  ...singularSocialPeople,
  ...singularPublicPeople,
  ...people.indefinitePeople,
];

final pluralEverydayPeople = [
  ...pluralNamedPeople,
  ...pluralFamilyPeople,
  ...pluralSchoolPeople,
  ...pluralWorkPeople,
  ...pluralCreativePeople,
  ...pluralSocialPeople,
  ...pluralPublicPeople,
];
