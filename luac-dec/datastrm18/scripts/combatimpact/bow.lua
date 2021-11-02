require("Scripts.CombatImpact.ImpactCommon")
function ImpactTable:BowDefault(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Projectile_MD_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowDefaultCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Projectile_MD_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowFlesh(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Projectile_MD_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowFleshCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Projectile_MD_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowFleshHeavy(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Projectile_MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowFleshHead(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(targetEntityId, "Head", "cFX_Impacts.CRIT.base_MD", Vector3(0, 0, 1), PlayerComponentRequestsBus.Event.IsLocalPlayer(targetEntityId), EmitterFollow)
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowArmor(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_Armor.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Armor", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowArmorHead(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(targetEntityId, "Head", "cFX_Impacts_Armor.Impact_Projectile", Vector3(0, 0, 0), PlayerComponentRequestsBus.Event.IsLocalPlayer(targetEntityId), EmitterFollow)
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Armor", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowDamned(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Damned.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowDamnedCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Damned.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowDynasty(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Dynasty.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowDynastyCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Dynasty.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowSun(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Sun.Sun_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowSunCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Sun.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowDryad(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Dryad.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowDryadCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Dryad.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowGhost(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostHunger.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Ghost", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowGhostCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostHunger.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Ghost", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowGhostCharred(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostCharred.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Ghost", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowGhostCharredCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostCharred.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Ghost", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowGhostFrozen(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostFrozen.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Ghost", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowGhostFrozenCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostFrozen.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Ghost", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowGhostPlagued(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostPlagued.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Ghost", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowGhostPlaguedCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostPlagued.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Ghost", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowGhostHanged(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostHanged.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Ghost", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowGhostHangedCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostHanged.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Ghost", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowGhostShipwrecked(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostShipwrecked.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Ghost", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowGhostShipwreckedCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostShipwrecked.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Ghost", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowSkeleton(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Ancient.Impact_Projectile_Skeleton", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Skeleton", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowSkeletonCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Ancient.Impact_Projectile_Skeleton", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Skeleton", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowAncientGuardian(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Ancient.Impact_Projectile_Guardian", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Skeleton", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowAncientGuardianCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Ancient.Impact_Projectile_Guardian", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Skeleton", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowTurkey(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Projectile_MD_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Turkey.Hit_feathers01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowTurkeyCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Projectile_MD_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Turkey.Hit_feathers01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowBlightFiend(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_BlightFiend.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowBlightFiendCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_BlightFiend.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowBearElemental(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_BearElemental.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowBearElementalCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_BearElemental.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowFrostWolf(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_FrostWolf.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowFrostWolfCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_FrostWolf.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowEarthWolf(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_EarthWolf.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowEarthWolfCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_EarthWolf.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowSprigganForest(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Spriggan_Forest.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowSprigganForestCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Spriggan_Forest.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowLost(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Lost.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowLostCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Lost.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowWithered(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Lost.Impact_Projectile_Withered", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowWitheredCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Lost.Impact_Projectile_Withered", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowCorruptedEntity(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Corruption.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowCorruptedEntityCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Corruption.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowRegurgitator(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Regurgitator.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowRegurgitatorCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Regurgitator.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowResist(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOCK.Default_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  HandleBlockSFX(targetEntityId, attackerEntityId, WeaponSoundId.Wpn_Bullet, "Play_Block_Arrow_Reg")
end
function ImpactTable:BowDunePhantom(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_dunepantom.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowDunePhantomCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_dunepantom.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowAENaga(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_AngryEarthNaga.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
function ImpactTable:BowAENagaCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_AngryEarthNaga.Impact_Projectile", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Arrow_Flesh", false, true)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_HitConfirm_Arrows")
  end
end
