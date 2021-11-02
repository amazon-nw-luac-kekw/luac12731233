require("Scripts.CombatImpact.ImpactCommon")
function ImpactTable:DemoHammerDefault(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Blunt_MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Warhammer_Flesh", false)
end
function ImpactTable:DemoHammerFlesh(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Blunt_MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Warhammer_Flesh", false)
end
function ImpactTable:DemoHammerHeavy_Dirt(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.DIRT.WarHammer_Heavy_01a", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.DIRT.WarHammer_Heavy_01b", impactPos, impactNormal, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_SwordWood_Dirt", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:DemoHammerMG_Dirt(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.DIRT.WarHammer_Mightygavel_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_SwordWood_Dirt", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:DemoHammerWreck_Sparks(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Warhammer.Wreckingball_impact_01", impactPos, impactNormal, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_SwordWood_Dirt", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:DemoHammerPOD_Dirt(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.DIRT.WarHammer_POD_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_SwordWood_Dirt", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:DemoHammerWreck_Dirt(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.DIRT.WarHammer_Wreckingball_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_SwordWood_Dirt", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:DemoHammerShock_Dirt(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.DIRT.WarHammer_Shockwave_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_SwordWood_Dirt", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:DemoHammerHeavy_Mud(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.MUD.WarHammer_Heavy_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_SwordWood_Dirt", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:DemoHammerHeavy_Sand(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.SAND.WarHammer_Heavy_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_SwordWood_Dirt", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:DemoHammerHeavy_Stone(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.STONE.WarHammer_Heavy_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_SwordWood_Dirt", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:DemoHammerHeavy_Water(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.WATER.WarHammer_Heavy_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_SwordWood_Dirt", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:DemoHammerHeavy_Wood(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.WOOD.WarHammer_Heavy_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_SwordWood_Dirt", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:DemoHammerSpecial_Dirt(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.DIRT.WarHammer_Special_01a", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.DIRT.WarHammer_Special_01b", impactPos, impactNormal, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_SwordWood_Dirt", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:DemoHammerSpecial_Mud(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.MUD.WarHammer_Special_01a", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.MUD.WarHammer_Special_01b", impactPos, impactNormal, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_SwordWood_Dirt", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:DemoHammerSpecial_Sand(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.SAND.WarHammer_Special_01a", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.SAND.WarHammer_Special_01b", impactPos, impactNormal, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_SwordWood_Dirt", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:DemoHammerSpecial_Stone(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.STONE.WarHammer_Special_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_SwordWood_Dirt", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:DemoHammerSpecial_Water(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.WATER.WarHammer_Special_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_SwordWood_Dirt", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:DemoHammerSpecial_Wood(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.WOOD.WarHammer_Special_01a", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.WOOD.WarHammer_Special_01b", impactPos, impactNormal, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_SwordWood_Dirt", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:DemoHammerFleshHead(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Blunt_MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Warhammer_Flesh", false)
end
function ImpactTable:DemoHammerArmor(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_Armor.Impact_Blunt", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Warhammer_Armor", false)
end
function ImpactTable:DemoHammerArmorHead(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_Armor.Impact_Blunt", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Warhammer_Armor", false)
end
function ImpactTable:DemoHammerDamned(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Blunt_MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Warhammer_Flesh", false)
end
function ImpactTable:DemoHammerDynasty(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Blunt_MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Warhammer_Flesh", false)
end
function ImpactTable:DemoHammerDryad(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Dryad.Impact_Blunt", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Warhammer_Dryad", false)
end
function ImpactTable:DemoHammerGhost(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostHunger.Hit_wisp01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Warhammer_Ghost", false)
end
function ImpactTable:DemoHammerSkeleton(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Skeleton.Hit_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Warhammer_Skeleton", false)
end
function ImpactTable:DemoHammerTurkey(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Blunt_MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Turkey.Hit_feathers01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Warhammer_Flesh", false)
end
function ImpactTable:DemoHammerResist(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOCK.Default_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  HandleBlockSFX(targetEntityId, attackerEntityId, WeaponSoundId.Wpn_Metal_Big, "Play_Block_WarHammer_Reg")
end
