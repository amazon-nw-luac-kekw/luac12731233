require("Scripts.CombatImpact.ImpactCommon")
function IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId)
  return PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true or PlayerComponentRequestsBus.Event.IsLocalPlayer(targetEntityId) == true
end
function ImpactTable:FlameThrowerDefault(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_FireStaff.Proj_Impact", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_FlameThrower", false)
end
function ImpactTable:FlameThrowerDefaultCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_FlameThrower", false, true)
end
function ImpactTable:FlameThrowerEnv(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_FireStaff.Proj_Impact", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_FlameThrower", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:FlameThrowerFlesh(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_FireStaff.Proj_Impact", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Projectile_MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_FlameThrower", false)
end
function ImpactTable:FlameThrowerFleshHead(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_FireStaff.Proj_Impact", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(targetEntityId, "Head", "cFX_Impacts.CRIT.base_MD", Vector3(0, 0, 0), PlayerComponentRequestsBus.Event.IsLocalPlayer(targetEntityId), EmitterFollow)
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_FlameThrower", false)
end
function ImpactTable:FlameThrowerResist(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOCK.Default_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  HandleBlockSFX(targetEntityId, attackerEntityId, WeaponSoundId.Wpn_Magic, "Play_Imp_FlameThrower")
end
