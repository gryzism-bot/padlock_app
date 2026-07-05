import 'package:padlock_app/data/prepositions.dart';
import 'package:padlock_app/models/grammar/phrase/phrase_position.dart';
import 'package:padlock_app/models/grammar/phrase/place_meaning.dart';
import 'package:padlock_app/models/grammar/phrase/place_phrase.dart';
import 'package:padlock_app/models/language.dart';

const homePlacePhrase = PlacePhrase(
  noun: 'home',
  takesArticle: false,
  prepositions: {
    PlaceMeaning.location: at,
    PlaceMeaning.destination:
        null, //TODO: for "go home", not "go to home" render(PlaceMeaning.destination)
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'dom'},
);

const workPlacePhrase = PlacePhrase(
  noun: 'work',
  takesArticle: false,
  prepositions: {
    PlaceMeaning.location: at,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'praca'},
);

const schoolPlacePhrase = PlacePhrase(
  noun: 'school',
  takesArticle: false,
  prepositions: {
    PlaceMeaning.location: at,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'szkoła'},
);

const universityPlacePhrase = PlacePhrase(
  noun: 'university',
  takesArticle: false,
  prepositions: {
    PlaceMeaning.location: at,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'uniwersytet'},
);

const officePlacePhrase = PlacePhrase(
  noun: 'office',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: inPreposition,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'biuro'},
);

const parkPlacePhrase = PlacePhrase(
  noun: 'park',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: inPreposition,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'park'},
);

const gardenPlacePhrase = PlacePhrase(
  noun: 'garden',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: inPreposition,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'ogród'},
);

const kitchenPlacePhrase = PlacePhrase(
  noun: 'kitchen',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: inPreposition,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'kuchnia'},
);

const bathroomPlacePhrase = PlacePhrase(
  noun: 'bathroom',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: inPreposition,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'łazienka'},
);

const bedroomPlacePhrase = PlacePhrase(
  noun: 'bedroom',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: inPreposition,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'sypialnia'},
);

const livingRoomPlacePhrase = PlacePhrase(
  noun: 'living room',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: inPreposition,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'salon'},
);

const restaurantPlacePhrase = PlacePhrase(
  noun: 'restaurant',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: inPreposition,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'restauracja'},
);

const hospitalPlacePhrase = PlacePhrase(
  noun: 'hospital',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: inPreposition,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'szpital'},
);

const shopPlacePhrase = PlacePhrase(
  noun: 'shop',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: inPreposition,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'sklep'},
);

const bridgePlacePhrase = PlacePhrase(
  noun: 'bridge',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: on,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'most'},
);

const tablePlacePhrase = PlacePhrase(
  noun: 'table',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: on,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'stół'},
);

const bedPlacePhrase = PlacePhrase(
  noun: 'bed',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: on,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'łóżko'},
);

List<PlacePhrase> placePhrases = [
  homePlacePhrase,
  workPlacePhrase,
  schoolPlacePhrase,
  universityPlacePhrase,
  officePlacePhrase,
  parkPlacePhrase,
  gardenPlacePhrase,
  kitchenPlacePhrase,
  bathroomPlacePhrase,
  bedroomPlacePhrase,
  livingRoomPlacePhrase,
  restaurantPlacePhrase,
  hospitalPlacePhrase,
  shopPlacePhrase,
  bridgePlacePhrase,
  tablePlacePhrase,
  bedPlacePhrase,
];
