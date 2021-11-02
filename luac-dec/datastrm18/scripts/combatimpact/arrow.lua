function IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId)
  return PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true or PlayerComponentRequestsBus.Event.IsLocalPlayer(targetEntityId) == true
end
function ImpactTable:EnvironmentArrowDirt(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.DIRT.MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.1, 0.15, 5, "materials/vfx/decals/impacts/impact_dirt001")
  self:PlayImpactSoundAtPosition("Play_Imp_Arrow_Dirt", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:EnvironmentArrowRock(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.STONE.MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.1, 0.15, 5, "materials/vfx/decals/impacts/impact_rock001")
  self:PlayImpactSoundAtPosition("Play_Imp_Arrow_Stone", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:EnvironmentArrowWood(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.WOOD.MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.1, 0.15, 5, "materials/vfx/decals/impacts/impact_wood001")
  self:PlayImpactSoundAtPosition("Play_Imp_Arrow_Wood", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:EnvironmentArrowGrass(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.DIRT.MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.1, 0.15, 5, "materials/vfx/decals/impacts/impact_dirt001")
  self:PlayImpactSoundAtPosition("Play_Imp_Arrow_Grass", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:EnvironmentArrowMetal(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.DIRT.MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.1, 0.15, 5, "materials/vfx/decals/impacts/impact_dirt001")
  self:PlayImpactSoundAtPosition("Play_Imp_Arrow_Metal", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:EnvironmentArrowSand(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.DIRT.MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.1, 0.15, 5, "materials/vfx/decals/impacts/impact_dirt001")
  self:PlayImpactSoundAtPosition("Play_Imp_Arrow_Sand", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:EnvironmentArrowFabric(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.DIRT.MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.1, 0.15, 5, "materials/vfx/decals/impacts/impact_dirt001")
  self:PlayImpactSoundAtPosition("Play_Imp_Arrow_Cloth", impactPos, attackerEntityId, targetEntityId)
end
