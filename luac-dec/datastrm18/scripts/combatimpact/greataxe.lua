require("Scripts.CombatImpact.ImpactCommon")
function ImpactTable:GreatAxeDefault(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_Impacts.BLOOD.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_GreatAxe_Flesh", false)
end
function ImpactTable:GreatAxeFlesh(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_Impacts.BLOOD.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_GreatAxe_Flesh", false)
end
function ImpactTable:GreatAxeFleshHead(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_Impacts.BLOOD.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_GreatAxe_Flesh", false)
end
function ImpactTable:GreatAxeArmor(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_Armor.Impact_Slash", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_GreatAxe_Armor", false)
end
function ImpactTable:GreatAxeArmorHead(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_Armor.Impact_Slash", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_GreatAxe_Armor", false)
end
function ImpactTable:GreatAxeDamned(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Damned.Impact_Slash_Omni", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Damned.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_GreatAxe_Flesh", false)
end
function ImpactTable:GreatAxeDynasty(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Dynasty.Impact_Slash_Omni", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Dynasty.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_GreatAxe_Flesh", false)
end
function ImpactTable:GreatAxeSun(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Sun.Impact_Slash_Omni", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Sun.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_GreatAxe_Flesh", false)
end
function ImpactTable:GreatAxeDryad(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Dryad.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Dryad.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_GreatAxe_Dryad", false)
end
function ImpactTable:GreatAxeGhost(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostHunger.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_GhostHunger.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_GreatAxe_Ghost", false)
end
function ImpactTable:GreatAxeGhostCharred(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostCharred.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_GhostCharred.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_GreatAxe_Ghost", false)
end
function ImpactTable:GreatAxeGhostFrozen(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostFrozen.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_GhostFrozen.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_GreatAxe_Ghost", false)
end
function ImpactTable:GreatAxeGhostPlagued(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostPlagued.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_GhostPlagued.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_GreatAxe_Ghost", false)
end
function ImpactTable:GreatAxeGhostHanged(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostHanged.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_GhostHanged.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_GreatAxe_Ghost", false)
end
function ImpactTable:GreatAxeGhostShipwrecked(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostShipwrecked.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_GhostShipwrecked.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Ghost", false)
end
function ImpactTable:GreatAxeSkeleton(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Ancient.Impact_Slash_Skeleton_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Ancient.Impact_Slash_Skeleton_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_GreatAxe_Skeleton", false)
end
function ImpactTable:GreatAxeAncientGuardian(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Ancient.Impact_Slash_Guardian_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Ancient.Impact_Slash_Guardian_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_GreatAxe_Skeleton", false)
end
function ImpactTable:GreatAxeTurkey(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Turkey.Hit_feathers01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_Impacts.BLOOD.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Turkey.Hit_feathers_trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_GreatAxe_Flesh", false)
end
function ImpactTable:GreatAxeResist(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOCK.Default_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  HandleBlockSFX(targetEntityId, attackerEntityId, WeaponSoundId.Wpn_Metal_Big, "Play_Block_GreatAxe_Reg")
end
function ImpactTable:GreatAxeBlightFiend(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_BlightFiend.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_BlightFiend.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_GreatAxe_Flesh", false)
end
function ImpactTable:GreatAxeBearElemental(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_BearElemental.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_BearElemental.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Flesh", false)
end
function ImpactTable:GreatAxeFrostWolf(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_FrostWolf.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_FrostWolf.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_GreatAxe_Flesh", false)
end
function ImpactTable:GreatAxeEarthWolf(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_EarthWolf.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_EarthWolf.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_GreatAxe_Flesh", false)
end
function ImpactTable:GreatAxeForestSpriggan(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Spriggan_Forest.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Spriggan_Forest.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_GreatAxe_Flesh", false)
end
function ImpactTable:GreatAxeLost(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Lost.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Lost.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_GreatAxe_Flesh", false)
end
function ImpactTable:GreatAxeWithered(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Lost.Impact_Blunt_Omni_Withered", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Lost.Impact_Blunt_Trail_Withered", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_GreatAxe_Flesh", false)
end
function ImpactTable:GreatAxeCorruptedEntity(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Corruption.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Corruption.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_GreatAxe_Flesh", false)
end
function ImpactTable:GreatAxeRegurgitator(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Regurgitator.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Regurgitator.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_GreatAxe_Flesh", false)
end
function ImpactTable:GreatAxeDunePhantom(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_dunepantom.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_dunepantom.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_GreatAxe_Flesh", false)
end
function ImpactTable:GreatAxeAENaga(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_AngryEarthNaga.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_AngryEarthNaga.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_GreatAxe_Dryad", false)
end
