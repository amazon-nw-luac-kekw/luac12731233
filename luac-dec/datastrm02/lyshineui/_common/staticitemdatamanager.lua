local StaticItemDataManager = {
  items = {},
  cacheSize = 0,
  itemCount = 0,
  APPROX_TABLE_SIZE = 30,
  NUMBER_USERDATA_SIZE = 8,
  logCacheSize = false,
  playerEntityId = EntityId(),
  blockUseFromFlyout = false
}
local columns = {
  "RefinedAtLabelText",
  "RefinedAtText",
  "RefinedAtIcon",
  "DerivedFromText",
  "DerivedFromIcon",
  "SpecialInstructions",
  "UsedAtTexts",
  "UsedAtIcons",
  "CommonUsesLabelText",
  "CommonUsesTextsLarge",
  "CommonUsesIconsLarge",
  "CommonUsesItemsLarge",
  "CommonUsesTextsSmall",
  "CommonUsesIconsSmall",
  "CommonUsesItemsSmall",
  "CanBeCraftedTextsLarge",
  "CanBeCraftedIconsLarge",
  "CanBeCraftedTextsSmall",
  "CanBeCraftedIconsSmall",
  "ResourcesLabelText",
  "ResourcesTexts",
  "ResourcesIcons",
  "ResourcesAmounts",
  "RefineryInputText",
  "RefineryInputIcon",
  "RefineryInputAmount",
  "RefineryOutputText",
  "RefineryOutputIcon",
  "RefineryOutputAmount",
  "MainHeaderIcon",
  "ResourcesHeaderIcon"
}
local dataLayer = RequireScript("LyShineUI.UIDataLayer")
function StaticItemDataManager:OnActivate()
  dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
  end)
  dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, rootEntityId)
    self.rootEntityId = rootEntityId
  end)
end
function StaticItemDataManager:Reset()
end
function StaticItemDataManager:MakeStaticItem(item)
  local proxy = {original = item}
  if not self.converters then
    self.converters = {}
    if not self.dummyFn then
      function self.dummyFn(t)
      end
    end
    self.converters.weaponAttributes = self.dummyFn
    self.converters.basePrice = self.dummyFn
    self.converters.armorAttributes = self.dummyFn
    self.converters.ammoAttributes = self.dummyFn
    self.converters.maxDurability = self.dummyFn
    self.converters.durability = self.dummyFn
    self.converters.descriptionHorizontalAlignment = self.dummyFn
    self.converters.equipSlot = self.dummyFn
    self.converters.itemInstanceId = self.dummyFn
    self.converters.owgAvailableItem = self.dummyFn
    self.converters.availableProducts = self.dummyFn
    self.converters.rewardType = self.dummyFn
    self.converters.rewardKey = self.dummyFn
    self.converters.ignoreRequirements = self.dummyFn
    self.converters.ignoreWeight = self.dummyFn
    self.converters.dynamicInfoText = self.dummyFn
    self.converters.dynamicInfoColor = self.dummyFn
    self.converters.disclaimerText = self.dummyFn
    self.converters.spriteName = self.dummyFn
    self.converters.spriteColor = self.dummyFn
    self.converters.gearScoreRangeMod = self.dummyFn
    self.converters.productType = self.dummyFn
    self.converters.skinType = self.dummyFn
    self.converters.sourceType = self.dummyFn
    self.converters.isSelectedForTrade = self.dummyFn
    self.converters.isRewardOwned = self.dummyFn
    self.converters.deathDurabilityPenalty = self.dummyFn
    function self.converters.name(t)
      t.original.name = t.original.staticItemData.key
    end
    function self.converters.repairRecipe(t)
      t.original.repairRecipe = ItemDataManagerBus.Broadcast.GetRepairRecipe(t.original.id)
    end
    function self.converters.craftingRecipe(t)
      t.original.craftingRecipe = ItemDataManagerBus.Broadcast.GetCraftingRecipe(t.original.id)
    end
    function self.converters.weaponGatheringType(t)
      t.original.weaponGatheringType = ItemDataManagerBus.Broadcast.GetWeaponGatheringType(t.original.id)
    end
    function self.converters.iconPath(t)
      t.original.iconPath = ItemDataManagerBus.Broadcast.GetIconPath(t.original.id)
    end
    function self.converters.ammoType(t)
      t.original.ammoType = ItemDataManagerBus.Broadcast.GetAmmoType(t.original.id)
    end
    function self.converters.baseGearScore(t)
      t.original.baseGearScore = ItemDataManagerBus.Broadcast.GetBaseGearScore(t.original.id)
    end
    function self.converters.isRepairable(t)
      t.original.isRepairable = ItemDataManagerBus.Broadcast.IsRepairable(t.original.id)
    end
    function self.converters.blueprintCurrencyCost(t)
      t.original.blueprintCurrencyCost = ItemDataManagerBus.Broadcast.GetBlueprintCurrencyCost(t.original.id)
    end
    function self.converters.isBlueprintDeployable(t)
      t.original.isBlueprintDeployable = ItemDataManagerBus.Broadcast.GetBlueprintIsDeployable(t.original.id)
    end
    function self.converters.tierNumber(t)
      t.original.tierNumber = ItemDataManagerBus.Broadcast.GetTierNumber(t.original.id)
    end
    function self.converters.equipSlots(t)
      t.original.equipSlots = {}
      local equipSlots = ItemDataManagerBus.Broadcast.GetEquipSlots(t.original.id)
      for i = 1, #equipSlots do
        table.insert(t.original.equipSlots, equipSlots[i])
      end
    end
    function self.converters.isTrinket(t)
      t.original.isTrinket = CraftingRequestBus.Broadcast.GetRecipeResultIsTrinket(t.original.staticItemData.key)
    end
    function self.converters.isBag(t)
      t.original.isBag = CraftingRequestBus.Broadcast.GetRecipeResultIsBag(t.original.staticItemData.key)
    end
    function self.converters.catSection(t)
      t.original.catSection = ItemDataManagerBus.Broadcast.GetCatSection(t.original.id)
    end
    function self.converters.jsonString(t)
      t.original.jsonString = ItemDataManagerBus.Broadcast.GetJsonString(t.original.id)
    end
    function self.converters.tooltipLayout(t)
      t.original.tooltipLayout = {}
      for i, column in ipairs(columns) do
        t.original.tooltipLayout[column] = ItemDataManagerBus.Broadcast.GetTooltipLayoutValue(t.original.id, column)
      end
    end
    function self.converters.isOnCooldown(t)
      local staticConsumableData = ItemDataManagerBus.Broadcast.GetConsumableData(t.original.id)
      t.original.isOnCooldown = staticConsumableData:IsValid() and CooldownTimersComponentBus.Event.IsConsumableOnCooldown(self.rootEntityId, staticConsumableData.cooldownId)
    end
    function self.converters.cooldownId(t)
      local staticConsumableData = ItemDataManagerBus.Broadcast.GetConsumableData(t.original.id)
      t.original.cooldownId = staticConsumableData.cooldownId
    end
    function self.converters.cooldownDuration(t)
      local staticConsumableData = ItemDataManagerBus.Broadcast.GetConsumableData(t.original.id)
      t.original.cooldownDuration = staticConsumableData.cooldownDuration
    end
    function self.converters.cooldownItemId(t)
      local staticConsumableData = ItemDataManagerBus.Broadcast.GetConsumableData(t.original.id)
      local isOnCooldown = staticConsumableData:IsValid() and CooldownTimersComponentBus.Event.IsConsumableOnCooldown(self.rootEntityId, staticConsumableData.cooldownId)
      t.original.cooldownItemId = isOnCooldown and CooldownTimersComponentBus.Event.GetConsumableCooldownItemId(self.rootEntityId, t.original.id)
    end
    function self.converters.effectDuration(t)
      local staticConsumableData = ItemDataManagerBus.Broadcast.GetConsumableData(t.original.id)
      t.original.effectDuration = staticConsumableData.effectDuration
    end
  end
  if not self.mt then
    self.mt = {
      __index = function(t, k)
        if t.original[k] then
          return t.original[k]
        end
        local fn = self.converters[k]
        if fn then
          fn(t)
        elseif t.original.staticItemData[k] ~= nil then
          t.original[k] = t.original.staticItemData[k]
        end
        if t.original[k] == nil then
          return nil
        end
        if self.logCacheSize then
          local newType = type(t.original[k])
          self.cacheSize = self.cacheSize + self.NUMBER_USERDATA_SIZE
          if newType == "string" then
            self.cacheSize = self.cacheSize + string.len(t.original[k]) + 1
          elseif newType == "boolean" then
            self.cacheSize = self.cacheSize + 1
          else
            self.cacheSize = self.cacheSize + self.NUMBER_USERDATA_SIZE
          end
        end
        return t.original[k]
      end,
      __newindex = function(t, k, v)
        Log("Attempt to write to read-only item[%s]", tostring(k))
      end
    }
  end
  setmetatable(proxy, self.mt)
  return proxy
end
function StaticItemDataManager:BlockUseItemFromFlyout(block)
  self.blockUseFromFlyout = block
end
function StaticItemDataManager:ClearAllItems()
  ClearTable(self.items)
  self.cacheSize = 0
  self.itemCount = 0
end
function StaticItemDataManager:IsUniqueItem(itemId)
  local itemData = self:GetItem(itemId)
  if not itemData then
    return false
  end
  return itemData.isUniqueItem
end
function StaticItemDataManager:GetItemName(itemId)
  local lootTableTag = "%[LTID%]"
  local lootBucketTag = "%[LBID%]"
  local ltidIndex = string.find(itemId, lootTableTag)
  if ltidIndex then
    return "@" .. string.gsub(itemId, lootTableTag, "") .. "_MasterName"
  end
  local lbidIndex = string.find(itemId, lootBucketTag)
  if lbidIndex then
    return "@" .. string.gsub(itemId, lootBucketTag, "") .. "_MasterName"
  end
  return ItemDataManagerBus.Broadcast.GetDisplayName(Math.CreateCrc32(itemId))
end
function StaticItemDataManager:GetItem(itemId)
  if self.items[itemId] then
    return self.items[itemId]
  end
  local staticItemData = ItemDataManagerBus.Broadcast.GetItemData(itemId)
  if not staticItemData:IsValid() then
    return nil
  end
  local item = {id = itemId, staticItemData = staticItemData}
  local staticItem = self:MakeStaticItem(item)
  self.items[itemId] = staticItem
  self.itemCount = self.itemCount + 1
  if self.logCacheSize then
    self.cacheSize = self.cacheSize + self.APPROX_TABLE_SIZE + self.NUMBER_USERDATA_SIZE + self.NUMBER_USERDATA_SIZE
  end
  return staticItem
end
function StaticItemDataManager:GetOverloadableItem(itemId)
  local staticItem = self:GetItem(itemId)
  if not staticItem then
    Log("ERROR: Trying to create overloadable item for invalid itemId %s", tostring(itemId))
    return nil
  end
  local proxy = {
    staticItem = staticItem,
    overrides = {}
  }
  if not self.tdiMeta then
    self.tdiMeta = {
      __index = function(t, k)
        if t.overrides[k] ~= nil then
          return t.overrides[k]
        end
        return t.staticItem[k]
      end,
      __newindex = function(t, k, v)
        t.overrides[k] = v
      end
    }
  end
  setmetatable(proxy, self.tdiMeta)
  return proxy
end
function StaticItemDataManager:CleanUpAttributes(attributesTable)
  if attributesTable then
    if not attributesTable.weaponAttributes.isValid then
      attributesTable.weaponAttributes = nil
    end
    if not attributesTable.armorAttributes.isValid then
      attributesTable.armorAttributes = nil
    else
      local newArmorAttributes = {
        physicalArmorRating = attributesTable.armorAttributes.physicalArmorRating,
        elementalArmorRating = attributesTable.armorAttributes.elementalArmorRating,
        encumbranceModifier = attributesTable.armorAttributes.encumbranceModifier,
        equipLoadModifier = attributesTable.armorAttributes.equipLoadModifier,
        absorption = {},
        resistances = {}
      }
      for k = 1, #attributesTable.armorAttributes.absorption do
        newArmorAttributes.absorption[attributesTable.armorAttributes.absorption[k].name] = attributesTable.armorAttributes.absorption[k].amount
      end
      for k = 1, #attributesTable.armorAttributes.resistances do
        newArmorAttributes.resistances[attributesTable.armorAttributes.resistances[k].name] = attributesTable.armorAttributes.resistances[k].amount
      end
      attributesTable.armorAttributes = newArmorAttributes
    end
  end
end
function StaticItemDataManager:GetTooltipDisplayInfo(itemDescriptor, slot)
  local tdi = self:GetOverloadableItem(itemDescriptor.itemId)
  if not tdi then
    return nil
  end
  tdi.hasBaseAttributes = false
  tdi.isDiscount = false
  tdi.isRepair = false
  tdi.isSalvage = false
  if slot then
    tdi.weaponAttributes = slot:GetWeaponAttributes()
    tdi.armorAttributes = slot:GetArmorAttributes()
    tdi.ammoAttributes = slot:GetAmmoAttributes()
    tdi.coreDamage = slot:GetCoreDamage(self.rootEntityId)
    tdi.gearScoreRangeMod = slot:GetGearScoreRangeMod()
    if slot:GetDurability() == 0 then
      tdi.hasBaseAttributes = true
      tdi.baseAttributes = {}
      tdi.baseAttributes.weaponAttributes = itemDescriptor:GetWeaponAttributes()
      tdi.baseAttributes.armorAttributes = itemDescriptor:GetArmorAttributes()
      tdi.baseAttributes.ammoAttributes = itemDescriptor:GetAmmoAttributes()
      tdi.baseAttributes.coreDamage = itemDescriptor:GetCoreDamageForOwner(self.rootEntityId, true, ePaperDollSlotTypes_Num)
    end
  else
    tdi.weaponAttributes = itemDescriptor:GetWeaponAttributes()
    tdi.armorAttributes = itemDescriptor:GetArmorAttributes()
    tdi.ammoAttributes = itemDescriptor:GetAmmoAttributes()
    tdi.coreDamage = itemDescriptor:GetCoreDamageForOwner(self.rootEntityId, true, ePaperDollSlotTypes_Num)
    tdi.gearScoreRangeMod = itemDescriptor:GetGearScoreRangeMod(true) or 0
  end
  self:CleanUpAttributes(tdi)
  if tdi.hasBaseAttributes then
    self:CleanUpAttributes(tdi.baseAttributes)
  end
  tdi.gearScore = itemDescriptor:GetGearScore()
  tdi.perks = {}
  local numPerks = itemDescriptor:GetPerkCount()
  for i = 0, numPerks - 1 do
    local perkId = itemDescriptor:GetPerk(i)
    if perkId ~= 0 then
      table.insert(tdi.perks, perkId)
    end
  end
  tdi.usesRarity = itemDescriptor:UsesRarity()
  tdi.rarityLevel = itemDescriptor:GetRarityLevel()
  tdi.requiredLevel = itemDescriptor:GetLevelRequirement()
  tdi.isRanged = itemDescriptor:HasItemClass(eItemClass_Ranged)
  tdi.isOutpostRushOnly = itemDescriptor:HasItemClass(eItemClass_OutpostRushOnly)
  tdi.itemDescriptorRef = itemDescriptor
  if slot then
    local staticConsumableData = ItemDataManagerBus.Broadcast.GetConsumableData(itemDescriptor.itemId)
    if staticConsumableData:IsValid() then
      tdi.cooldownId = staticConsumableData.cooldownId
      tdi.cooldownDuration = staticConsumableData.cooldownDuration
      tdi.effectDuration = staticConsumableData.effectDuration
      tdi.isOnCooldown = CooldownTimersComponentBus.Event.IsConsumableOnCooldown(self.rootEntityId, tdi.cooldownId)
      if tdi.isOnCooldown then
        tdi.cooldownItemId = CooldownTimersComponentBus.Event.GetConsumableCooldownItemId(self.rootEntityId, tdi.cooldownId)
      end
    end
    tdi.canEquip = slot:CanEquipItem(self.playerEntityId)
    tdi.canSalvage = false
    tdi.confirmDestroy = false
    tdi.canUse = false
    tdi.canDrop = false
    tdi.isEquipped = slot:IsEquipped()
    if self.blockUseFromFlyout == false then
      tdi.canSalvage = slot:CanSalvageItem()
      tdi.canUse = slot:CanUseItem(self.playerEntityId)
      tdi.canDrop = not slot:IsEquipped() and not slot:IsNonRemovableFromPlayer(true)
      tdi.confirmDestroy = slot:IsConfirmDestroy()
    end
    tdi.canRepair = slot:CanRepairItem()
    tdi.boundToPlayer = slot:IsBoundToPlayer()
    tdi.bindOnEquip = slot:IsBindOnEquip()
    tdi.hasEntitlements = slot:HasEntitlements()
    tdi.durability = slot:GetDurability()
    tdi.maxDurability = slot:GetMaxDurability()
    tdi.itemType = slot:GetItemType()
    tdi.itemInstanceId = slot:GetItemInstanceId()
    tdi.weight = slot:GetWeight()
    tdi.displayName = slot:GetItemDescriptor():GetDisplayName()
  else
    tdi.isEquipped = false
    tdi.canSalvage = false
    tdi.confirmDestroy = false
    tdi.boundToPlayer = false
    tdi.bindOnEquip = false
    tdi.canRepair = false
    tdi.canDrop = false
    tdi.canEquip = false
    tdi.canUse = false
    tdi.hasEntitlements = false
    tdi.weight = itemDescriptor:GetWeight()
    tdi.displayName = itemDescriptor:GetDisplayName()
  end
  return tdi
end
local comparableTagsToIgnore = {
  ["1H_Melee"] = true,
  ["2H_Melee"] = true,
  MagicStaff = true,
  ["2H_Ranged"] = true,
  Throwable = true
}
function StaticItemDataManager:ShouldTooltipCompare(thisItemTdi, slot)
  if not slot or not slot:IsValid() then
    return false
  end
  local itemDesc = slot:GetItemDescriptor()
  local tdi = self:GetTooltipDisplayInfo(itemDesc, slot)
  local isThisWeapon = thisItemTdi.weaponAttributes ~= nil
  local isWeapon = tdi.weaponAttributes ~= nil
  if isThisWeapon ~= isWeapon then
    return false, tdi
  end
  local thisWeaponGatheringType = ItemDataManagerBus.Broadcast.GetWeaponGatheringType(thisItemTdi.id)
  local otherWeaponGatheringType = ItemDataManagerBus.Broadcast.GetWeaponGatheringType(tdi.id)
  local isThisGatheringTool = thisWeaponGatheringType ~= "None"
  local isOtherGatheringTool = otherWeaponGatheringType ~= "None"
  if isThisGatheringTool ~= isOtherGatheringTool then
    return false, tdi
  elseif isThisGatheringTool then
    return thisWeaponGatheringType == otherWeaponGatheringType, tdi
  end
  local equipSlot = thisItemTdi.equipSlot
  if not equipSlot and thisItemTdi.equipSlots then
    equipSlot = thisItemTdi.equipSlots[1]
  end
  if isThisWeapon and equipSlot ~= "off-hand-option-1" then
    local shouldCompare = false
    local weaponData = ItemDataManagerBus.Broadcast.GetWeaponData(tdi.id).mannequinTags
    local thisWeaponData = ItemDataManagerBus.Broadcast.GetWeaponData(thisItemTdi.id).mannequinTags
    for i = 1, #weaponData do
      local otherTag = weaponData[i]
      for j = 1, #thisWeaponData do
        local thisTag = thisWeaponData[j]
        if otherTag == thisTag and not comparableTagsToIgnore[thisTag] then
          shouldCompare = true
          break
        end
      end
    end
    return shouldCompare, tdi
  else
    local otherEquipSlot = tdi.equipSlot
    if not otherEquipSlot and tdi.equipSlots then
      otherEquipSlot = tdi.equipSlots[1]
    end
    return equipSlot == otherEquipSlot, tdi
  end
end
return StaticItemDataManager
