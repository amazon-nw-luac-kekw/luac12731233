require("Scripts.CombatImpact.ImpactCommon")
function IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId)
  return PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true or PlayerComponentRequestsBus.Event.IsLocalPlayer(targetEntityId) == true
end
function ImpactTable:LifeStaffDefault(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("wFX_LifeStaff_Base.Proj_Impact_Env", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_LifeStaff", impactPos, attackerEntityId, targetEntityId)
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_GreatAxe_Flesh", false)
end
function ImpactTable:LifeStaffDefaultCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_LifeStaff", impactPos, attackerEntityId, targetEntityId)
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_GreatAxe_Flesh", false, true)
end
function ImpactTable:LifeStaffEnv(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("wFX_LifeStaff_Base.Proj_Impact_Env", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_LifeStaff_Env", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:LifeStaff_Protect_Env(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("wFX_LifeStaff_Protector.Protection_Impact", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_IMP_LifeStaff_Protect", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:LifeStaff_Protect(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("wFX_LifeStaff_Protector.Protection_Impact", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_IMP_LifeStaff_Protect", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:LifeStaffFlesh(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("wFX_LifeStaff_Base.Proj_Impact_Env", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Projectile_MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_LifeStaff", false)
end
function ImpactTable:LifeStaffFleshHead(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("wFX_LifeStaff_Base.Proj_Impact_Env", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(targetEntityId, "Head", "cFX_Impacts.CRIT.base_MD", Vector3(0, 0, 0), PlayerComponentRequestsBus.Event.IsLocalPlayer(targetEntityId), EmitterFollow)
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_LifeStaff", false)
end
function ImpactTable:LifeStaffResist(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOCK.Default_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  HandleBlockSFX(targetEntityId, attackerEntityId, WeaponSoundId.Wpn_Magic, "Play_Block_Staff_Reg")
end
function ImpactTable:LifeStaffPlayerResist(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOCK.Default_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  HandleBlockSFX(targetEntityId, attackerEntityId, WeaponSoundId.Wpn_Magic, "Play_Block_Staff_Reg")
end
