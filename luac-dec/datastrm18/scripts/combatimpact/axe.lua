require("Scripts.CombatImpact.ImpactCommon")
function ImpactTable:AxeDefault(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_Impacts.BLOOD.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeDefaultCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_Impacts.BLOOD.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false, true)
end
function ImpactTable:AxeDefaultThrow(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeDefaultThrowCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false, true)
end
function ImpactTable:AxeFlesh(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_Impacts.BLOOD.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeFleshThrow(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeFleshHead(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_Impacts.BLOOD.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeFleshHeadThrow(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeArmor(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_Armor.Impact_Slash", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Armor", false)
end
function ImpactTable:AxeArmorHead(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_Armor.Impact_Slash", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Armor", false)
end
function ImpactTable:AxeDamned(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Damned.Impact_Slash_Omni", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Damned.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeDamnedThrow(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Damned.Impact_Slash_Omni", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeDamnedThrowCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Damned.Impact_Slash_Omni", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false, true)
end
function ImpactTable:AxeDryad(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Dryad.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Dryad.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Dryad", false)
end
function ImpactTable:AxeDryadThrow(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Dryad.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Dryad", false)
end
function ImpactTable:AxeDryadThrowCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Dryad.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Dryad", false, true)
end
function ImpactTable:AxeGhost(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostHunger.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_GhostHunger.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Ghost", false)
end
function ImpactTable:AxeGhostThrow(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostHunger.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Ghost", false)
end
function ImpactTable:AxeGhostThrowCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostHunger.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Ghost", false, true)
end
function ImpactTable:AxeGhostCharred(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostCharred.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_GhostCharred.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Ghost", false)
end
function ImpactTable:AxeGhostCharredThrow(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostCharred.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Ghost", false)
end
function ImpactTable:AxeGhostCharredThrowCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostCharred.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Ghost", false, true)
end
function ImpactTable:AxeGhostFrozen(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostFrozen.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_GhostFrozen.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Ghost", false)
end
function ImpactTable:AxeGhostFrozenThrow(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostFrozen.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Ghost", false)
end
function ImpactTable:AxeGhostFrozenThrowCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostFrozen.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Ghost", false, true)
end
function ImpactTable:AxeGhostPlagued(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostPlagued.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_GhostPlagued.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Ghost", false)
end
function ImpactTable:AxeGhostPlaguedThrow(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostPlagued.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Ghost", false)
end
function ImpactTable:AxeGhostPlaguedThrowCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostPlagued.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Ghost", false, true)
end
function ImpactTable:AxeGhostHanged(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostHanged.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_GhostHanged.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Ghost", false)
end
function ImpactTable:AxeGhostHangedThrow(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostHanged.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Ghost", false)
end
function ImpactTable:AxeGhostHangedThrowCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostHanged.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Ghost", false, true)
end
function ImpactTable:AxeGhostShipwrecked(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostShipwrecked.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_GhostShipwrecked.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Ghost", false)
end
function ImpactTable:AxeGhostShipwreckedThrow(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostShipwrecked.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Ghost", false)
end
function ImpactTable:AxeGhostShipwreckedThrowCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostShipwrecked.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Ghost", false, true)
end
function ImpactTable:AxeSkeleton(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Ancient.Impact_Slash_Skeleton_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Ancient.Impact_Slash_Skeleton_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Skeleton", false)
end
function ImpactTable:AxeSkeletonThrow(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Ancient.Impact_Slash_Skeleton_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Skeleton", false)
end
function ImpactTable:AxeSkeletonThrowCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Ancient.Impact_Slash_Skeleton_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Skeleton", false, true)
end
function ImpactTable:AxeAncientGuardian(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Ancient.Impact_Slash_Guardian_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Ancient.Impact_Slash_Guardian_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Skeleton", false)
end
function ImpactTable:AxeTurkey(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Turkey.Hit_feathers01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_Impacts.BLOOD.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Turkey.Hit_feathers_trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeTurkeyThrow(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Turkey.Hit_feathers01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeTurkeyThrowCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Turkey.Hit_feathers01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false, true)
end
function ImpactTable:AxeResist(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOCK.Default_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  HandleBlockSFX(targetEntityId, attackerEntityId, WeaponSoundId.Wpn_Metal_Sml, "Play_Block_Axe_Reg")
end
function ImpactTable:AxeBlightFiend(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_BlightFiend.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_BlightFiend.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeBlightFiendThrow(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_BlightFiend.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeBlightFiendThrowCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_BlightFiend.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false, true)
end
function ImpactTable:AxeBearElemental(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_BearElemental.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_BearElemental.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false)
end
function ImpactTable:AxeBearElementalThrow(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_BearElemental.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false)
end
function ImpactTable:AxeBearElementalThrowCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_BearElemental.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false, true)
end
function ImpactTable:AxeBearThrowCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false, true)
end
function ImpactTable:AxeFrostWolf(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_FrostWolf.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_FrostWolf.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeFrostWolfThrow(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_FrostWolf.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeFrostWolfThrowCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_FrostWolf.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false, true)
end
function ImpactTable:AxeEarthWolf(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_EarthWolf.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_EarthWolf.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeEarthWolfThrow(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_EarthWolf.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeEarthWolfThrowCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_EarthWolf.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false, true)
end
function ImpactTable:AxeSprigganForest(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Spriggan_Forest.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Spriggan_Forest.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeSprigganForestThrow(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Spriggan_Forest.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeSprigganForestCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Spriggan_Forest.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false, true)
end
function ImpactTable:AxeLost(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Lost.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Lost.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeLostThrow(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Lost.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeLostThrowCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Lost.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false, true)
end
function ImpactTable:AxeWithered(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Lost.Impact_Slash_Omni_Withered", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Lost.Impact_Slash_Trail_Withered", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeWitheredThrow(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Lost.Impact_Slash_Omni_Withered", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeWitheredThrowCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Lost.Impact_Slash_Omni_Withered", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false, true)
end
function ImpactTable:AxeCorruptedEntity(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Corruption.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Corruption.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeCorruptedEntityThrow(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Corruption.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeCorruptedEntityThrowCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Corruption.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false, true)
end
function ImpactTable:AxeRegurgitator(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Regurgitator.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Regurgitator.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeRegurgitatorThrow(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Regurgitator.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeRegurgitatorThrowCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Regurgitator.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false, true)
end
function ImpactTable:AxeDynasty(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Dynasty.Impact_Slash_Omni", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Dynasty.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeDynastyThrow(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Dynasty.Impact_Slash_Omni", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeDynastyThrowCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Dynasty.Impact_Slash_Omni", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false, true)
end
function ImpactTable:AxeSun(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Sun.Impact_Slash_Omni", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Sun.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeSunThrow(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Sun.Impact_Slash_Omni", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeSunThrowCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Sun.Impact_Slash_Omni", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false, true)
end
function ImpactTable:AxeDunePhantom(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_dunepantom.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_dunepantom.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeDunePhantomThrow(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_dunepantom.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false)
end
function ImpactTable:AxeDunePhantomThrowCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_dunepantom.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Flesh", false, true)
end
function ImpactTable:AxeAENaga(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_AngryEarthNaga.Impact_Slash_Omni", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_AngryEarthNaga.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Dryad", false)
end
function ImpactTable:AxeAENagaThrow(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_AngryEarthNaga.Impact_Slash_Omni", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Dryad", false)
end
function ImpactTable:AxeAENagaThrowCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_AngryEarthNaga.Impact_Slash_Omni", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Axe_Dryad", false, true)
end
function ImpactTable:EnvironmentAxeWood(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.WOOD.MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.15, 0.2, 5, "materials/vfx/decals/impacts/impact_wood002")
  self:PlayImpactSoundAtPosition("Play_2HAxe_Gather", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:EnvironmentAxeDirt(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.DIRT.MD_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.25, 0.25, 5, "materials/vfx/decals/impacts/impact_dirt001")
  self:PlayImpactSoundAtPosition("Play_Imp_SpearMetal_Dirt", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:EnvironmentAxeMetal(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.DIRT.MD_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.25, 0.25, 5, "materials/vfx/decals/impacts/impact_dirt001")
  self:PlayImpactSoundAtPosition("Play_Imp_GreatAxe_Metal", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:EnvironmentAxeRock(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.DIRT.MD_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.25, 0.25, 5, "materials/vfx/decals/impacts/impact_dirt001")
  self:PlayImpactSoundAtPosition("Play_2HPickaxe_Gather", impactPos, attackerEntityId, targetEntityId)
end
