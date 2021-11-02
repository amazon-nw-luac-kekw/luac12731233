PaperdollUtils = {}
WeaponSoundId = {
  Shield_Big = 1,
  Shield_Med = 2,
  Shield_Sml = 3,
  Wpn_Blunt = 1,
  Wpn_Bullet = 2,
  Wpn_Magic = 3,
  Wpn_Metal_Big = 4,
  Wpn_Metal_Med = 5,
  Wpn_Metal_Sml = 6,
  Wpn_Wood = 7
}
ShieldBlockSoundTable = {
  [WeaponSoundId.Wpn_Blunt] = {
    [WeaponSoundId.Shield_Big] = "Play_BLOCK_Wpn_Blunt_VS_Shield_Metal_Big",
    [WeaponSoundId.Shield_Med] = "Play_BLOCK_Wpn_Blunt_VS_Shield_Metal_Med",
    [WeaponSoundId.Shield_Sml] = "Play_BLOCK_Wpn_Blunt_VS_Shield_Wood_Small"
  },
  [WeaponSoundId.Wpn_Bullet] = {
    [WeaponSoundId.Shield_Big] = "Play_BLOCK_Wpn_Bullet_VS_Shield_Metal_Big",
    [WeaponSoundId.Shield_Med] = "Play_BLOCK_Wpn_Bullet_VS_Shield_Metal_Med",
    [WeaponSoundId.Shield_Sml] = "Play_BLOCK_Wpn_Bullet_VS_Shield_Wood_Small"
  },
  [WeaponSoundId.Wpn_Magic] = {
    [WeaponSoundId.Shield_Big] = "Play_BLOCK_Wpn_Magic_VS_Shield_Metal_Big",
    [WeaponSoundId.Shield_Med] = "Play_BLOCK_Wpn_Magic_VS_Shield_Metal_Med",
    [WeaponSoundId.Shield_Sml] = "Play_BLOCK_Wpn_Magic_VS_Shield_Wood_Small"
  },
  [WeaponSoundId.Wpn_Metal_Big] = {
    [WeaponSoundId.Shield_Big] = "Play_BLOCK_Wpn_Metal_Big_VS_Shield_Metal_Big",
    [WeaponSoundId.Shield_Med] = "Play_BLOCK_Wpn_Metal_Big_VS_Shield_Metal_Med",
    [WeaponSoundId.Shield_Sml] = "Play_BLOCK_Wpn_Metal_Big_VS_Shield_Wood_Small"
  },
  [WeaponSoundId.Wpn_Metal_Med] = {
    [WeaponSoundId.Shield_Big] = "Play_BLOCK_Wpn_Metal_Med_VS_Shield_Metal_Big",
    [WeaponSoundId.Shield_Med] = "Play_BLOCK_Wpn_Metal_Med_VS_Shield_Metal_Med",
    [WeaponSoundId.Shield_Sml] = "Play_BLOCK_Wpn_Metal_Med_VS_Shield_Wood_Small"
  },
  [WeaponSoundId.Wpn_Metal_Sml] = {
    [WeaponSoundId.Shield_Big] = "Play_BLOCK_Wpn_Metal_Small_VS_Shield_Metal_Big",
    [WeaponSoundId.Shield_Med] = "Play_BLOCK_Wpn_Metal_Small_VS_Shield_Metal_Med",
    [WeaponSoundId.Shield_Sml] = "Play_BLOCK_Wpn_Metal_Small_VS_Shield_Wood_Small"
  },
  [WeaponSoundId.Wpn_Wood] = {
    [WeaponSoundId.Shield_Big] = "Play_BLOCK_Wpn_Wood_VS_Shield_Metal_Big",
    [WeaponSoundId.Shield_Med] = "Play_BLOCK_Wpn_Wood_VS_Shield_Metal_Med",
    [WeaponSoundId.Shield_Sml] = "Play_BLOCK_Wpn_Wood_VS_Shield_Wood_Small"
  }
}
function PaperdollUtils:GetWeaponTier(characterEntityId, paperdollSlotAlias)
  local slotId = PaperdollRequestBus.Event.GetActiveSlot(characterEntityId, paperdollSlotAlias)
  local slot = PaperdollRequestBus.Event.GetSlot(characterEntityId, slotId)
  if slot ~= nil then
    local itemData = ItemDataManagerBus.Broadcast.GetItemData(slot:GetItemId())
    if itemData ~= nil then
      return itemData.tier
    end
  end
  return -1
end
function PaperdollUtils:WeaponHasItemClass(characterEntityId, paperdollSlotAlias, itemClass)
  local slotId = PaperdollRequestBus.Event.GetActiveSlot(characterEntityId, paperdollSlotAlias)
  local slot = PaperdollRequestBus.Event.GetSlot(characterEntityId, slotId)
  if slot ~= nil then
    return slot:HasItemClass(itemClass)
  end
  return false
end
function PaperdollUtils:GetWeaponEntityId(characterEntityId, paperdollSlotAlias)
  local slotId = PaperdollRequestBus.Event.GetActiveSlot(characterEntityId, paperdollSlotAlias)
  local slot = PaperdollRequestBus.Event.GetSlot(characterEntityId, slotId)
  if slot ~= nil then
    return slot:GetSpawnedSliceRootId()
  end
  return nil
end
function PaperdollUtils:PlayWeaponBlockSound(weaponName, attackerEntityId, targetEntityId)
  local tier = PaperdollUtils:GetWeaponTier(targetEntityId, ePaperdollSlotAlias_ActiveOffHandWeapon)
  local category = WeaponSoundId.Shield_Sml
  if 2 < tier and tier <= 4 then
    category = WeaponSoundId.Shield_Med
  elseif 4 < tier then
    category = WeaponSoundId.Shield_Big
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, ShieldBlockSoundTable[weaponName][category], true)
end
