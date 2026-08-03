import 'package:padlock_app/data/verbs/communication.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/data/verbs/particle.dart' as particle_data;
import 'package:padlock_app/data/verbs/right_particles.dart';
import 'package:padlock_app/data/verbs/work.dart' as work_data;
import 'package:padlock_app/models/grammar/verb/right_particle.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';

bool rightParticlePlacesObjectAfter({
  required Verb verb,
  required RightParticle particle,
}) {
  return (identical(verb, give) && identical(particle, upParticle)) ||
      (identical(verb, write) && identical(particle, downParticle)) ||
      (identical(verb, particle_data.turn) &&
          (identical(particle, onParticle) ||
              identical(particle, offParticle))) ||
      (identical(verb, particle_data.pick) &&
          identical(particle, upParticle)) ||
      (identical(verb, particle_data.put) &&
          (identical(particle, downParticle) ||
              identical(particle, awayParticle) ||
              identical(particle, backParticle))) ||
      (identical(verb, particle_data.look) &&
          identical(particle, upParticle)) ||
      (identical(verb, take) && identical(particle, outParticle)) ||
      (identical(verb, bring) &&
          (identical(particle, inParticle) ||
              identical(particle, outParticle))) ||
      (identical(verb, work_data.clean) && identical(particle, upParticle));
}
