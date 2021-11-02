function IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId)
  return PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true or PlayerComponentRequestsBus.Event.IsLocalPlayer(targetEntityId) == true
end
function ImpactTable:EnvironmentBulletDirt(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.DIRT.MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.1, 0.15, 5, "materials/vfx/decals/impacts/impact_dirt001")
  PlayImpactSound("Play_Imp_Bullet_Dirt", impactPos, attackerEntityId)
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:EnvironmentBulletRock(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.STONE.MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.1, 0.15, 5, "materials/vfx/decals/impacts/impact_rock001")
  PlayImpactSound("Play_Imp_Bullet_Stone", impactPos, attackerEntityId)
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:EnvironmentBulletWood(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.WOOD.MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.1, 0.15, 5, "materials/vfx/decals/impacts/impact_wood001")
  PlayImpactSound("Play_Imp_Bullet_Wood", impactPos, attackerEntityId)
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:EnvironmentBulletGrass(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.WOOD.MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.1, 0.15, 5, "materials/vfx/decals/impacts/impact_wood001")
  PlayImpactSound("Play_Imp_Bullet_Grass", impactPos, attackerEntityId)
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:EnvironmentBulletMetal(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.WOOD.MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.1, 0.15, 5, "materials/vfx/decals/impacts/impact_wood001")
  PlayImpactSound("Play_Imp_Bullet_Metal", impactPos, attackerEntityId)
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:EnvironmentBulletSand(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.WOOD.MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.1, 0.15, 5, "materials/vfx/decals/impacts/impact_wood001")
  PlayImpactSound("Play_Imp_Bullet_Sand", impactPos, attackerEntityId)
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:EnvironmentBulletWater(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.WOOD.MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.1, 0.15, 5, "materials/vfx/decals/impacts/impact_wood001")
  PlayImpactSound("Play_Imp_Bullet_Water", impactPos, attackerEntityId)
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:EnvironmentBulletFabric(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.WOOD.MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.1, 0.15, 5, "materials/vfx/decals/impacts/impact_wood001")
  PlayImpactSound("Play_Imp_Bullet_Cloth", impactPos, attackerEntityId)
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
