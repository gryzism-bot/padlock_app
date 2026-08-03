import 'package:padlock_app/data/verbs/communication.dart';
import 'package:padlock_app/data/verbs/essential.dart';
import 'package:padlock_app/data/verbs/particle.dart' as particle_data;
import 'package:padlock_app/data/verbs/right_particles.dart';
import 'package:padlock_app/data/verbs/work.dart' as work_data;
import 'package:padlock_app/models/grammar/verb/right_particle.dart';
import 'package:padlock_app/models/grammar/verb/verb.dart';

class ParticleObjectOrderRule {
  final Verb verb;
  final RightParticle particle;
  final String example;

  const ParticleObjectOrderRule({
    required this.verb,
    required this.particle,
    required this.example,
  });
}

const particleObjectOrderRules = [
  ParticleObjectOrderRule(
    verb: give,
    particle: upParticle,
    example: 'You give up smoking.',
  ),
  ParticleObjectOrderRule(
    verb: write,
    particle: downParticle,
    example: 'You write down note.',
  ),
  ParticleObjectOrderRule(
    verb: particle_data.turn,
    particle: onParticle,
    example: 'You turn on lamp.',
  ),
  ParticleObjectOrderRule(
    verb: particle_data.turn,
    particle: offParticle,
    example: 'You turn off lamp.',
  ),
  ParticleObjectOrderRule(
    verb: particle_data.pick,
    particle: upParticle,
    example: 'You pick up phone.',
  ),
  ParticleObjectOrderRule(
    verb: particle_data.put,
    particle: downParticle,
    example: 'You put down book.',
  ),
  ParticleObjectOrderRule(
    verb: particle_data.put,
    particle: awayParticle,
    example: 'You put away book.',
  ),
  ParticleObjectOrderRule(
    verb: particle_data.put,
    particle: backParticle,
    example: 'You put back book.',
  ),
  ParticleObjectOrderRule(
    verb: particle_data.look,
    particle: upParticle,
    example: 'You look up word.',
  ),
  ParticleObjectOrderRule(
    verb: take,
    particle: outParticle,
    example: 'You take out key.',
  ),
  ParticleObjectOrderRule(
    verb: bring,
    particle: inParticle,
    example: 'You bring in book.',
  ),
  ParticleObjectOrderRule(
    verb: bring,
    particle: outParticle,
    example: 'You bring out book.',
  ),
  ParticleObjectOrderRule(
    verb: work_data.clean,
    particle: upParticle,
    example: 'You clean up room.',
  ),
];

bool rightParticlePlacesObjectAfter({
  required Verb verb,
  required RightParticle particle,
}) {
  return particleObjectOrderRules.any(
    (rule) => identical(rule.verb, verb) && identical(rule.particle, particle),
  );
}
