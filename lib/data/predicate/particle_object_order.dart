import 'package:padlock_app/data/phrases/manner_phrases.dart';
import 'package:padlock_app/data/verbs/communication.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/data/verbs/particle.dart' as particle_data;
import 'package:padlock_app/data/verbs/work.dart' as work_data;
import 'package:padlock_app/models/grammar/phrase/manner_phrase.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';

bool rightParticlePlacesObjectAfter({
  required Verb verb,
  required MannerPhrase particle,
}) {
  return (identical(verb, give) && identical(particle, upMannerPhrase)) ||
      (identical(verb, write) && identical(particle, downMannerPhrase)) ||
      (identical(verb, particle_data.turn) &&
          (identical(particle, onMannerPhrase) ||
              identical(particle, offMannerPhrase))) ||
      (identical(verb, particle_data.pick) &&
          identical(particle, upMannerPhrase)) ||
      (identical(verb, particle_data.put) &&
          (identical(particle, downMannerPhrase) ||
              identical(particle, awayMannerPhrase) ||
              identical(particle, backMannerPhrase))) ||
      (identical(verb, particle_data.look) &&
          identical(particle, upMannerPhrase)) ||
      (identical(verb, take) && identical(particle, outMannerPhrase)) ||
      (identical(verb, bring) &&
          (identical(particle, inMannerPhrase) ||
              identical(particle, outMannerPhrase))) ||
      (identical(verb, work_data.clean) && identical(particle, upMannerPhrase));
}
