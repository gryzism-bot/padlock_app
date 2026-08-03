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

const polandPlacePhrase = PlacePhrase(
  noun: 'Poland',
  takesArticle: false,
  prepositions: {
    PlaceMeaning.location: inPreposition,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'Polska'},
);

const europePlacePhrase = PlacePhrase(
  noun: 'Europe',
  takesArticle: false,
  prepositions: {
    PlaceMeaning.location: inPreposition,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'Europa'},
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

const roomPlacePhrase = PlacePhrase(
  noun: 'room',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: inPreposition,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'pokoj'},
);

const itDomainPlacePhrase = PlacePhrase(
  noun: 'IT',
  takesArticle: false,
  prepositions: {PlaceMeaning.location: inPreposition},
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'IT'},
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

const atShopPlacePhrase = PlacePhrase(
  noun: 'shop',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: at,
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

const inBedPlacePhrase = PlacePhrase(
  noun: 'bed',
  takesArticle: false,
  prepositions: {PlaceMeaning.location: inPreposition},
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'lozko'},
);

const cityPlacePhrase = PlacePhrase(
  noun: 'city',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: inPreposition,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'miasto'},
);

const roadPlacePhrase = PlacePhrase(
  noun: 'road',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: on,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'droga'},
);

const streetPlacePhrase = PlacePhrase(
  noun: 'street',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: on,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'ulica'},
);

const stationPlacePhrase = PlacePhrase(
  noun: 'station',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: at,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'stacja'},
);

const airportPlacePhrase = PlacePhrase(
  noun: 'airport',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: at,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'lotnisko'},
);

const hotelPlacePhrase = PlacePhrase(
  noun: 'hotel',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: at,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'hotel'},
);

const beachPlacePhrase = PlacePhrase(
  noun: 'beach',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: on,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'plaza'},
);

const forestPlacePhrase = PlacePhrase(
  noun: 'forest',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: inPreposition,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'las'},
);

const libraryPlacePhrase = PlacePhrase(
  noun: 'library',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: inPreposition,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'biblioteka'},
);

const cinemaPlacePhrase = PlacePhrase(
  noun: 'cinema',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: inPreposition,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'kino'},
);

const cafePlacePhrase = PlacePhrase(
  noun: 'cafe',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: inPreposition,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'kawiarnia'},
);

const marketPlacePhrase = PlacePhrase(
  noun: 'market',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: at,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'rynek'},
);

const bankPlacePhrase = PlacePhrase(
  noun: 'bank',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: at,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'bank'},
);

const gymPlacePhrase = PlacePhrase(
  noun: 'gym',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: at,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'silownia'},
);

const classroomPlacePhrase = PlacePhrase(
  noun: 'classroom',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: inPreposition,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'klasa'},
);

const garagePlacePhrase = PlacePhrase(
  noun: 'garage',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: inPreposition,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'garaz'},
);

const busStopPlacePhrase = PlacePhrase(
  noun: 'bus stop',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: at,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'przystanek autobusowy'},
);

const playgroundPlacePhrase = PlacePhrase(
  noun: 'playground',
  takesArticle: true,
  prepositions: {
    PlaceMeaning.location: on,
    PlaceMeaning.destination: to,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'plac zabaw'},
);

const herePlacePhrase = PlacePhrase(
  noun: 'here',
  takesArticle: false,
  prepositions: {
    PlaceMeaning.location: null,
    PlaceMeaning.destination: null,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'tutaj'},
);

const therePlacePhrase = PlacePhrase(
  noun: 'there',
  takesArticle: false,
  prepositions: {
    PlaceMeaning.location: null,
    PlaceMeaning.destination: null,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'tam'},
);

const outsidePlacePhrase = PlacePhrase(
  noun: 'outside',
  takesArticle: false,
  prepositions: {
    PlaceMeaning.location: null,
    PlaceMeaning.destination: null,
    PlaceMeaning.source: from,
  },
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'na zewnatrz'},
);

List<PlacePhrase> placePhrases = [
  homePlacePhrase,
  workPlacePhrase,
  schoolPlacePhrase,
  universityPlacePhrase,
  polandPlacePhrase,
  europePlacePhrase,
  officePlacePhrase,
  parkPlacePhrase,
  gardenPlacePhrase,
  kitchenPlacePhrase,
  bathroomPlacePhrase,
  bedroomPlacePhrase,
  livingRoomPlacePhrase,
  roomPlacePhrase,
  itDomainPlacePhrase,
  restaurantPlacePhrase,
  hospitalPlacePhrase,
  shopPlacePhrase,
  atShopPlacePhrase,
  bridgePlacePhrase,
  tablePlacePhrase,
  bedPlacePhrase,
  inBedPlacePhrase,
  cityPlacePhrase,
  roadPlacePhrase,
  streetPlacePhrase,
  stationPlacePhrase,
  airportPlacePhrase,
  hotelPlacePhrase,
  beachPlacePhrase,
  forestPlacePhrase,
  libraryPlacePhrase,
  cinemaPlacePhrase,
  cafePlacePhrase,
  marketPlacePhrase,
  bankPlacePhrase,
  gymPlacePhrase,
  classroomPlacePhrase,
  garagePlacePhrase,
  busStopPlacePhrase,
  playgroundPlacePhrase,
  herePlacePhrase,
  therePlacePhrase,
  outsidePlacePhrase,
];
