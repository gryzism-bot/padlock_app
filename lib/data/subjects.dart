import '../models/subject.dart';

const i = Subject(text: 'I', isThirdPerson: false, isPlural: false);

const you = Subject(text: 'You', isThirdPerson: false, isPlural: true);

const he = Subject(text: 'He', isThirdPerson: true, isPlural: false);

const she = Subject(text: 'She', isThirdPerson: true, isPlural: false);

const it = Subject(text: 'It', isThirdPerson: true, isPlural: false);

const we = Subject(text: 'We', isThirdPerson: false, isPlural: true);

const they = Subject(text: 'They', isThirdPerson: true, isPlural: true);

const subjects = [i, you, he, she, it, we, they];
