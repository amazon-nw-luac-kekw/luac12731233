require("Scripts.CombatImpact.ImpactCommon")
function ImpactTable:MusketDefault(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Projectile_MD_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketDefaultCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Projectile_MD_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketFlesh(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Projectile_MD_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketFleshCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Projectile_MD_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketFleshHead(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(targetEntityId, "Head", "cFX_Impacts.CRIT.base_MD", Vector3(0, 0, 1), PlayerComponentRequestsBus.Event.IsLocalPlayer(targetEntityId), EmitterFollow)
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketArmor(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_Armor.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Armor", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketArmorHead(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(targetEntityId, "Head", "cFX_Impacts_Armor.Impact_Projectile", Vector3(0, 0, 1), PlayerComponentRequestsBus.Event.IsLocalPlayer(targetEntityId), EmitterFollow)
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Armor", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketDamned(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Damned.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketDamnedCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Damned.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketDynasty(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Dynasty.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketDynastyCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Dynasty.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketSun(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Sun.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketSunCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Sun.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketDryad(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Dryad.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketDryadCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Dryad.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketGhost(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostHunger.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Ghost", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketGhostCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostHunger.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Ghost", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketGhostCharred(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostCharred.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Ghost", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketGhostCharredCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostCharred.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Ghost", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketGhostFrozen(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostFrozen.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Ghost", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketGhostFrozenCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostFrozen.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Ghost", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketGhostPlagued(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostPlagued.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Ghost", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketGhostPlaguedCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostPlagued.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Ghost", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketGhostHanged(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostHanged.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Ghost", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketGhostHangedCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostHanged.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Ghost", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketGhostShipwrecked(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostShipwrecked.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Ghost", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketGhostShipwreckedCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostShipwrecked.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Ghost", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketSkeleton(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Ancient.Impact_Projectile_Skeleton", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Skeleton", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketSkeletonCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Ancient.Impact_Projectile_Skeleton", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Skeleton", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketAncientGuardian(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Ancient.Impact_Projectile_Guardian", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Skeleton", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketAncientGuardianCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Ancient.Impact_Projectile_Guardian", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Skeleton", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketTurkey(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Projectile_MD_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Turkey.Hit_feathers01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketTurkeyCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Projectile_MD_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Turkey.Hit_feathers01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketResist(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOCK.Default_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  HandleBlockSFX(targetEntityId, attackerEntityId, WeaponSoundId.Wpn_Bullet, "Play_Block_Bullet_Reg")
end
function ImpactTable:MusketRegurgitator(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Regurgitator.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketRegurgitatorCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Regurgitator.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketBlightFiend(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_BlightFiend.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketBlightFiendCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_BlightFiend.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketBearElemental(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_BearElemental.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketBearElementalCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_BearElemental.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketBearCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Projectile_MD_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketFrostWolf(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_FrostWolf.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketFrostWolfCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_FrostWolf.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketEarthWolf(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_EarthWolf.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketEarthWolfCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_EarthWolf.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketSprigganForest(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Spriggan_Forest.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketSprigganForestCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Spriggan_Forest.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketLost(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Lost.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketLostCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Lost.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketWithered(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Lost.Impact_Projectile_Withered", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketWitheredCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Lost.Impact_Projectile_Withered", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketCorruptedEntity(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Corruption.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketCorruptedEntityCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Corruption.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:StickyBombDefault(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Ability_StickyBomb_Stuck", false)
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Ability_StickyBomb_Throw")
end
function ImpactTable:MusketDunePhantom(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_dunepantom.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketDunePhantomCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_dunepantom.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketAENaga(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_AngryEarthNaga.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
function ImpactTable:MusketAENagaCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_AngryEarthNaga.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Bullet_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Bullets")
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(attackerEntityId, "Stop_Bullet_WizzBy")
end
