require("Scripts.CombatImpact.ImpactCommon")
function ImpactTable:BeamLaserDefault(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_TorsoBoss.EyeBeam_Impact", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Beam_Laser", false)
end
function ImpactTable:BeamVoidSpikeDefault(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_TorsoBoss.EyeBeam_Impact", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Beam_VoidSpike", false)
end
