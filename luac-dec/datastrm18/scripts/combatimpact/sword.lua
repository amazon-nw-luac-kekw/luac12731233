require("Scripts.CombatImpact.ImpactCommon")
function ImpactTable:SwordDefault(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_Impacts.BLOOD.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false)
end
function ImpactTable:SwordDefaultCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_Impacts.BLOOD.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false)
end
function ImpactTable:SwordFlesh(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_Impacts.BLOOD.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false)
end
function ImpactTable:SwordFleshHead(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_Impacts.BLOOD.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false)
end
function ImpactTable:SwordArmor(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_Armor.Impact_Slash", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Armor", false)
end
function ImpactTable:SwordArmorHead(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_Armor.Impact_Slash", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Armor", false)
end
function ImpactTable:SwordDamned(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Damned.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Damned.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false)
end
function ImpactTable:SwordDamnedResist(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Damned.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Damned.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  HandleBlockSFX(targetEntityId, attackerEntityId, WeaponSoundId.Wpn_Metal_Sml, "Play_Block_Shield_Reg")
end
function ImpactTable:SwordDamnedCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Damned.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Damned.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false, true)
end
function ImpactTable:SwordDynasty(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Dynasty.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Dynasty.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false)
end
function ImpactTable:SwordDynastyCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Dynasty.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Dynasty.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false, true)
end
function ImpactTable:SwordSun(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Sun.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Sun.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false)
end
function ImpactTable:SwordSunCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Sun.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Dynasty.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false, true)
end
function ImpactTable:SwordDryad(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Dryad.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Dryad.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Dryad", false)
end
function ImpactTable:SwordDryadCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Dryad.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Dryad.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Dryad", false, true)
end
function ImpactTable:SwordGhost(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostHunger.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_GhostHunger.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Ghost", false)
end
function ImpactTable:SwordGhostCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostHunger.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_GhostHunger.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Ghost", false, true)
end
function ImpactTable:SwordSkeleton(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Ancient.Impact_Slash_Skeleton_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Ancient.Impact_Slash_Skeleton_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Skeleton", false)
end
function ImpactTable:SwordSkeletonCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Ancient.Impact_Slash_Skeleton_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Ancient.Impact_Slash_Skeleton_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Skeleton", false, true)
end
function ImpactTable:SwordAncientGuardian(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Ancient.Impact_Slash_Guardian_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Ancient.Impact_Slash_Guardian_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Skeleton", false)
end
function ImpactTable:SwordAncientGuardianCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Ancient.Impact_Slash_Guardian_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Ancient.Impact_Slash_Guardian_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Skeleton", false, true)
end
function ImpactTable:SwordTurkey(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Turkey.Hit_feathers01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_Impacts.BLOOD.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Turkey.Hit_feathers_trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false)
end
function ImpactTable:SwordTurkeyCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Turkey.Hit_feathers01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_Impacts.BLOOD.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Turkey.Hit_feathers_trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false, true)
end
function ImpactTable:SwordGhostCharred(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostCharred.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_GhostCharred.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Ghost", false)
end
function ImpactTable:SwordGhostCharredCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostCharred.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_GhostCharred.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Ghost", false, true)
end
function ImpactTable:SwordGhostFrozen(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostFrozen.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_GhostFrozen.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Ghost", false)
end
function ImpactTable:SwordGhostFrozenCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostFrozen.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_GhostFrozen.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Ghost", false, true)
end
function ImpactTable:SwordGhostHanged(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostHanged.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_GhostHanged.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Ghost", false)
end
function ImpactTable:SwordGhostHangedCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostHanged.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_GhostHanged.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Ghost", false, true)
end
function ImpactTable:SwordGhostShipwrecked(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostShipwrecked.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_GhostShipwrecked.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Ghost", false)
end
function ImpactTable:SwordGhostShipwreckedCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostShipwrecked.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_GhostShipwrecked.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Ghost", false, true)
end
function ImpactTable:SwordGhostPlagued(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostPlagued.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_GhostPlagued.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Ghost", false)
end
function ImpactTable:SwordGhostPlaguedCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostPlagued.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_GhostPlagued.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Ghost", false, true)
end
function ImpactTable:SwordBearElemental(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_BearElemental.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_BearElemental.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false)
end
function ImpactTable:SwordBearElementalCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_BearElemental.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_BearElemental.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false, true)
end
function ImpactTable:SwordBear(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_Impacts.BLOOD.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false)
end
function ImpactTable:SwordBearCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_Impacts.BLOOD.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false, true)
end
function ImpactTable:SwordResist(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOCK.Default_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  HandleBlockSFX(targetEntityId, attackerEntityId, WeaponSoundId.Wpn_Metal_Sml, "Play_Block_Sword_Reg")
end
function ImpactTable:SwordFire(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_DamnedCommander.Impact_fire01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(targetEntityId, "Neck", "cFX_npc_DamnedCommander.Impact_fire02", Vector3(0, 0, 0), PlayerComponentRequestsBus.Event.IsLocalPlayer(targetEntityId), EmitterFollow)
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(targetEntityId, "UpperArm_left", "cFX_npc_DamnedCommander.Impact_fire02", Vector3(0, 0, 0), PlayerComponentRequestsBus.Event.IsLocalPlayer(targetEntityId), EmitterFollow)
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(targetEntityId, "UpperArm_right", "cFX_npc_DamnedCommander.Impact_fire02", Vector3(0, 0, 0), PlayerComponentRequestsBus.Event.IsLocalPlayer(targetEntityId), EmitterFollow)
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false)
end
function ImpactTable:SwordFireGeneric(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_DamnedCommander.Impact_fire01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false)
end
function ImpactTable:SwordRegurgitator(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Regurgitator.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Regurgitator.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false)
end
function ImpactTable:SwordRegurgitatorCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Regurgitator.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Regurgitator.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false, true)
end
function ImpactTable:SwordSprigganForest(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Spriggan_Forest.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Spriggan_Forest.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordWood_Flesh", false)
end
function ImpactTable:SwordSprigganForestCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Spriggan_Forest.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Spriggan_Forest.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false, true)
end
function ImpactTable:SwordCorruptedEntity(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Corruption.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Corruption.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false)
end
function ImpactTable:SwordCorruptedEntityCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Corruption.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Corruption.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false, true)
end
function ImpactTable:SwordBlightFiend(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_BlightFiend.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_BlightFiend.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false)
end
function ImpactTable:SwordBlightFiendCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_BlightFiend.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_BlightFiend.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false, true)
end
function ImpactTable:SwordFrostWolf(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_FrostWolf.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_FrostWolf.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false)
end
function ImpactTable:SwordFrostWolfCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_FrostWolf.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_FrostWolf.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false, true)
end
function ImpactTable:SwordEarthWolf(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_EarthWolf.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_EarthWolf.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false)
end
function ImpactTable:SwordEarthWolfCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_EarthWolf.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_EarthWolf.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false, true)
end
function ImpactTable:SwordLost(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Lost.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Lost.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false)
end
function ImpactTable:SwordLostCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Lost.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Lost.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false, true)
end
function ImpactTable:SwordWithered(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Lost.Impact_Slash_Omni_Withered", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Lost.Impact_Slash_Trail_Withered", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false)
end
function ImpactTable:SwordWitheredCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Lost.Impact_Slash_Omni_Withered", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Lost.Impact_Slash_Trail_Withered", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false, true)
end
function ImpactTable:SwordDunePhantom(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_dunepantom.Impact_Slash_Omni_Sand", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_dunepantom.Impact_Slash_Trail_Sand", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false)
end
function ImpactTable:SwordDunePhantomCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_dunepantom.Impact_Slash_Omni_Sand", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_dunepantom.Impact_Slash_Trail_Sand", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false, true)
end
function ImpactTable:SwordAENaga(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_AngryEarthNaga.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_AngryEarthNaga.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Dryad", false)
end
function ImpactTable:SwordAENagaCrit(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_AngryEarthNaga.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD_cfx_addon", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_AngryEarthNaga.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false, true)
end
function ImpactTable:EnvironmentSwordWood(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.WOOD.MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.15, 0.2, 5, "materials/vfx/decals/impacts/impact_wood002")
  self:PlayImpactSoundAtPosition("Play_Imp_SwordMetal_Wood", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:EnvironmentSwordDirt(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.DIRT.MD_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.25, 0.25, 5, "materials/vfx/decals/impacts/impact_dirt001")
  self:PlayImpactSoundAtPosition("Play_Imp_SwordMetal_Dirt", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:EnvironmentSwordMetal(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.METAL.MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_SwordMetal_Metal", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:EnvironmentSwordRock(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.STONE.MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.15, 0.2, 5, "materials/vfx/decals/impacts/impact_rock001")
  self:PlayImpactSoundAtPosition("Play_Imp_SwordMetal_Stone", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:EnvironmentSwordSand(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.DIRT.MD_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.25, 0.25, 5, "materials/vfx/decals/impacts/impact_dirt001")
  self:PlayImpactSoundAtPosition("Play_Imp_SwordMetal_Sand", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:EnvironmentSwordGrass(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.DIRT.MD_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.25, 0.25, 5, "materials/vfx/decals/impacts/impact_dirt001")
  self:PlayImpactSoundAtPosition("Play_Imp_SwordMetal_Grass", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:EnvironmentSwordFabric(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.FABRIC.MD_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_SwordMetal_Cloth", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:EnvironmentSwordWater(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.WATER.MD_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_SwordWood_Water", impactPos, attackerEntityId, targetEntityId)
end
