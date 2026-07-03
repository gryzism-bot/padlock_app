import 'package:padlock_app/models/grammar/phrase/phrase_position.dart';
import 'package:padlock_app/models/grammar/phrase/place_phrase.dart';
import 'package:padlock_app/models/language.dart';

const homePlacePhrase = PlacePhrase(
  text: 'home',
  locationPreposition: 'at',
  destinationPreposition: '',
  sourcePreposition: 'from',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'dom'},
);

const workPlacePhrase = PlacePhrase(
  text: 'work',
  locationPreposition: 'at',
  destinationPreposition: 'to',
  sourcePreposition: 'from',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'praca'},
);

const schoolPlacePhrase = PlacePhrase(
  text: 'school',
  locationPreposition: 'at',
  destinationPreposition: 'to',
  sourcePreposition: 'from',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'szkoła'},
);

const universityPlacePhrase = PlacePhrase(
  text: 'university',
  locationPreposition: 'at',
  destinationPreposition: 'to',
  sourcePreposition: 'from',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'uniwersytet'},
);

const officePlacePhrase = PlacePhrase(
  text: 'office',
  locationPreposition: 'in',
  destinationPreposition: 'to',
  sourcePreposition: 'from',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'biuro'},
);

const parkPlacePhrase = PlacePhrase(
  text: 'the park',
  locationPreposition: 'in',
  destinationPreposition: 'to',
  sourcePreposition: 'from',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'park'},
);

const gardenPlacePhrase = PlacePhrase(
  text: 'the garden',
  locationPreposition: 'in',
  destinationPreposition: 'to',
  sourcePreposition: 'from',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'ogród'},
);

const kitchenPlacePhrase = PlacePhrase(
  text: 'the kitchen',
  locationPreposition: 'in',
  destinationPreposition: 'to',
  sourcePreposition: 'from',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'kuchnia'},
);

const bathroomPlacePhrase = PlacePhrase(
  text: 'the bathroom',
  locationPreposition: 'in',
  destinationPreposition: 'to',
  sourcePreposition: 'from',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'łazienka'},
);

const bedroomPlacePhrase = PlacePhrase(
  text: 'the bedroom',
  locationPreposition: 'in',
  destinationPreposition: 'to',
  sourcePreposition: 'from',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'sypialnia'},
);

const livingRoomPlacePhrase = PlacePhrase(
  text: 'the living room',
  locationPreposition: 'in',
  destinationPreposition: 'to',
  sourcePreposition: 'from',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'salon'},
);

const restaurantPlacePhrase = PlacePhrase(
  text: 'the restaurant',
  locationPreposition: 'in',
  destinationPreposition: 'to',
  sourcePreposition: 'from',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'restauracja'},
);

const hospitalPlacePhrase = PlacePhrase(
  text: 'the hospital',
  locationPreposition: 'in',
  destinationPreposition: 'to',
  sourcePreposition: 'from',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'szpital'},
);

const shopPlacePhrase = PlacePhrase(
  text: 'the shop',
  locationPreposition: 'in',
  destinationPreposition: 'to',
  sourcePreposition: 'from',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'sklep'},
);

const bridgePlacePhrase = PlacePhrase(
  text: 'the bridge',
  locationPreposition: 'under',
  destinationPreposition: 'to',
  sourcePreposition: 'from',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'most'},
);

const tablePlacePhrase = PlacePhrase(
  text: 'the table',
  locationPreposition: 'under',
  destinationPreposition: 'to',
  sourcePreposition: 'from',
  position: PhrasePosition.afterPredicate,
  translations: {Language.pl: 'stół'},
);

const bedPlacePhrase = PlacePhrase(
  text: 'the bed',
  locationPreposition: 'under',
  destinationPreposition: 'to',
  sourcePreposition: 'from',
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
