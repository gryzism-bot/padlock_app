import '../models/grammar/subject.dart';

const i = Subject(text: 'i', isThirdPerson: false, isPlural: false);

const you = Subject(text: 'you', isThirdPerson: false, isPlural: true);

const he = Subject(text: 'he', isThirdPerson: true, isPlural: false);

const she = Subject(text: 'she', isThirdPerson: true, isPlural: false);

const it = Subject(text: 'it', isThirdPerson: true, isPlural: false);

const we = Subject(text: 'we', isThirdPerson: false, isPlural: true);

const they = Subject(text: 'they', isThirdPerson: true, isPlural: true);

const subjects = [i, you, he, she, it, we, they];
