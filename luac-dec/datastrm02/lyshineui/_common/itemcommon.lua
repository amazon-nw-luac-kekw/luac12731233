local ItemCommon = {
  MODE_TYPE_EQUIPPED = 1,
  MODE_TYPE_CRAFTING = 2,
  MODE_TYPE_CONTAINER = 3,
  MODE_TYPE_CRAFTING_RARITY = 4,
  MODE_TYPE_BUILD_RESOURCE = 5,
  MODE_TYPE_INVENTORY = 6,
  MODE_TYPE_TRADING_POST = 7,
  MODE_TYPE_TRADING_POST_DETAILS = 8,
  IMAGE_PATH_FRAME_RECTANGLE = "lyshineui/images/slices/itemLayout/itemBgLarge",
  IMAGE_PATH_FRAME_CIRCLE = "lyshineui/images/slices/itemLayout/itemBgCircle",
  IMAGE_PATH_FRAME_SQUARE = "lyshineui/images/slices/itemLayout/itemBgSquare",
  IMAGE_PATH_RARITY_RECTANGLE = "lyshineui/images/slices/itemLayout/itemRarityBgLarge",
  IMAGE_PATH_RARITY_CIRCLE = "lyshineui/images/slices/itemLayout/itemRarityBgCircle",
  IMAGE_PATH_RARITY_SQUARE = "lyshineui/images/slices/itemLayout/itemRarityBgSquare",
  IMAGE_PATH_HIGHLIGHT_RECTANGLE = "lyshineui/images/slices/itemLayout/itemHighlightLarge.dds",
  IMAGE_PATH_HIGHLIGHT_CIRCLE = "lyshineui/images/slices/itemLayout/itemHighlightCircle.dds",
  IMAGE_PATH_HIGHLIGHT_SQUARE = "lyshineui/images/slices/itemLayout/itemHighlightSquare.dds",
  RARITY_LEVEL_NONE = "None",
  RARITY_LEVEL_0 = "",
  RARITY_LEVEL_1 = "RarityLevel1",
  RARITY_LEVEL_2 = "RarityLevel2",
  RARITY_LEVEL_3 = "RarityLevel3",
  EMPTY_GEM_SLOT_PERK_ID = 3763820582,
  ITEM_TYPE_WEAPON = "Weapon",
  ITEM_TYPE_AMMO = "Ammo",
  ITEM_TYPE_ARMOR = "Armor",
  ITEM_TYPE_BLUEPRINT = "Blueprint",
  ITEM_TYPE_CONSUMABLE = "Consumable",
  ITEM_TYPE_CURRENCY = "Currency",
  ITEM_TYPE_KIT = "Kit",
  ITEM_TYPE_PASSIVE_TOOL = "PassiveTool",
  ITEM_TYPE_RESOURCE = "Resource",
  ITEM_TYPE_LORE = "Lore",
  ITEM_TYPE_HOUSING_ITEM = "HousingItem",
  AttributeDisplayOrder = {
    {
      stat = CharacterAttributeType_Strength,
      name = "@ui_strength"
    },
    {
      stat = CharacterAttributeType_Dexterity,
      name = "@ui_dexterity"
    },
    {
      stat = CharacterAttributeType_Constitution,
      name = "@ui_constitution"
    },
    {
      stat = CharacterAttributeType_Intelligence,
      name = "@ui_intelligence"
    },
    {stat = CharacterAttributeType_Focus, name = "@ui_focus"}
  }
}
local UIStyle = RequireScript("LyShineUI._Common.UIStyle")
function ItemCommon:GetPerks(objectWithPerks, isContractItemData)
  local perks = vector_Crc32()
  local numPerks = isContractItemData and objectWithPerks:GetPerksVectorSize() or objectWithPerks:GetPerkCount()
  for i = 0, numPerks - 1 do
    local perkId = objectWithPerks:GetPerk(i)
    if perkId ~= 0 then
      perks:push_back(perkId)
    end
  end
  return perks
end
function ItemCommon:GetFullDescriptorFromId(itemId)
  local resultItemData = ItemDataManagerBus.Broadcast.GetItemData(itemId)
  local descriptor = ItemDescriptor()
  descriptor.itemId = itemId
  if resultItemData.gearScoreOverride > 0 then
    descriptor.gearScore = resultItemData.gearScoreOverride
  else
    descriptor.gearScore = resultItemData.gearScoreRange.minValue
  end
  local perks = vector_Crc32()
  local numPerks = resultItemData:GetPerkCount()
  for i = 0, numPerks - 1 do
    local perkId = resultItemData:GetPerkId(i)
    if perkId ~= 0 then
      perks:push_back(perkId)
    end
  end
  descriptor:SetPerks(perks)
  return descriptor
end
function ItemCommon:CloneItemDescriptor(otherDesc)
end
function ItemCommon:GetDisplayTier(itemDescriptor)
  local tierNumber = ItemDataManagerBus.Broadcast.GetTierNumber(itemDescriptor.itemId)
  return GetRomanFromNumber(tierNumber)
end
function ItemCommon:GetDisplayGearScore(itemDescriptor)
  local gearScore = itemDescriptor:GetGearScore()
  if gearScore == 0 then
    return "--"
  else
    return tostring(gearScore)
  end
end
function ItemCommon:GetDisplayRarity(raritySuffix)
  local displayName = "@RarityLevel" .. raritySuffix .. "_DisplayName"
  local colorName = string.format("COLOR_RARITY_LEVEL_%s", raritySuffix)
  local color = UIStyle[colorName]
  return AddTextColorMarkup(displayName, color)
end
function ItemCommon:GetDisplayPerks(itemDescriptor)
  local numPerks = itemDescriptor:GetPerkCount()
  if numPerks == 0 then
    return "@ui_none"
  else
    local itemPerksDataTable = {}
    for i = 0, numPerks - 1 do
      local perkId = itemDescriptor:GetPerk(i)
      local perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(perkId)
      if perkData:IsValid() and perkData.perkType ~= ePerkType_Gem then
        table.insert(itemPerksDataTable, perkData)
      end
    end
    table.sort(itemPerksDataTable, function(perk1, perk2)
      return perk1.perkType == ePerkType_Inherent
    end)
    local perkIconStr = ""
    for _, perkData in ipairs(itemPerksDataTable) do
      local perkIconPath = "lyshineui/images/" .. perkData.iconPath .. ".dds"
      local markupStr = string.format("<img src=\"%s\" xPadding=\"0\" scale=\"2\"> </img>", perkIconPath)
      if perkData.perkType == ePerkType_Inherent then
        perkIconPath = "lyshineui/images/icons/misc/icon_attribute_arrow.dds"
        markupStr = string.format("<img src=\"%s\" xPadding=\"0\" yOffset=\"-3\" scale=\"1.5\"> </img>", perkIconPath)
      end
      perkIconStr = perkIconStr .. markupStr
    end
    return perkIconStr
  end
end
function ItemCommon:GetDisplaySocket(itemDescriptor)
  local perkId = itemDescriptor:GetGemPerk()
  if perkId == 0 then
    return "@ui_no"
  end
  local perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(perkId)
  if perkData:IsValid() then
    local perkIconPath = "lyshineui/images/" .. perkData.iconPath .. ".dds"
    local markupStr = string.format("<img src=\"%s\" xPadding=\"0\" scale=\"2\"></img>", perkIconPath)
    return markupStr
  end
  return "@ui_no"
end
local shieldItems = {
  "Sword",
  "Club",
  "Longsword"
}
function ItemCommon:DoesItemSupportShieldOffhand(itemName)
  for _, shieldItemName in ipairs(shieldItems) do
    if string.find(itemName, shieldItemName) then
      return true
    end
  end
  return false
end
local abilityProgressionItems = {
  "sword",
  "hatchet",
  "bow",
  "throwing",
  "warhammer",
  "staff_life",
  "stafflife",
  "lifestaff",
  "musket",
  "stafffire",
  "firestaff",
  "elementalstaff_fire",
  "spear",
  "greataxe",
  "rapier",
  "gauntlet_ice",
  "gauntletice",
  "voidgauntlet"
}
function ItemCommon:DoesItemSupportAbilityProgression(itemName)
  if itemName then
    for _, abilityItemName in ipairs(abilityProgressionItems) do
      if string.find(itemName:lower(), abilityItemName) then
        return true
      end
    end
  end
  return false
end
local itemClassNames = {
  [eItemClass_LootContainer] = "@owg_rewards_title",
  [eItemClass_UI_Weapon] = "@ui_weapons",
  [eItemClass_UI_Armor] = "@inv_apparrel",
  [eItemClass_UI_Ammo] = "@inv_ammo",
  [eItemClass_UI_Cooking] = "@inv_cooking",
  [eItemClass_UI_Consumable] = "@inv_utilities",
  [eItemClass_UI_Tools] = "@inv_tools",
  [eItemClass_UI_Material] = "@inv_resources",
  [eItemClass_UI_Lore] = "@inv_loreitems",
  [eItemClass_UI_RepairKit] = "@inv_repair_kits",
  [eItemClass_UI_Dye] = "@inv_dyes",
  [eItemClass_UI_Bait] = "@inv_baits",
  [eItemClass_UI_CraftingModifiers] = "@inv_crafting_modifiers",
  [eItemClass_UI_Furniture] = "@inv_furniture",
  [eItemClass_UI_OutpostRush] = "@inv_outpostrush",
  [eItemClass_UI_Alchemy] = "@inv_alchemy",
  [eItemClass_UI_TuningOrbs] = "@inv_tuningorbs",
  [eItemClass_UI_Quest] = "@inv_quest",
  [eItemClass_UI_JewelCrafting] = "@inv_jewelcrafting",
  [eItemClass_UI_Refining] = "@inv_refining",
  [eItemClass_UI_AttributeFood] = "@inv_attributefood",
  [eItemClass_UI_Smelting] = "@inv_smelting",
  [eItemClass_UI_TradeSkillFood] = "@inv_tradeskillfood",
  [eItemClass_UI_Leatherworking] = "@inv_leatherworking",
  [eItemClass_UI_Weaving] = "@inv_weaving",
  [eItemClass_UI_Woodworking] = "@inv_woodworking",
  [eItemClass_UI_Stonecutting] = "@inv_stonecutting",
  [eItemClass_UI_BasicFood] = "@inv_basicfood"
}
function ItemCommon:GetItemClassName(itemClass)
  return itemClassNames[itemClass]
end
function ItemCommon:GetItemClassNameForSlot(slot)
  for class, name in pairs(itemClassNames) do
    if slot:HasItemClass(class) then
      return name
    end
  end
  return nil
end
function ItemCommon:GetInherentPerkSummary(itemId)
  local summaryString = ""
  local resourceData = itemId and ItemDataManagerBus.Broadcast.GetResourceData(itemId)
  local perks = ItemDataManagerBus.Broadcast.GetValidPerksForPerkBucket(resourceData.perkBucketCrc)
  local potentialStats = {}
  for index, attributeData in ipairs(self.AttributeDisplayOrder) do
    potentialStats[index] = {
      name = attributeData.name,
      value = 0
    }
  end
  for i = 1, #perks do
    local bucketPerkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(perks[i])
    for index, attributeData in ipairs(self.AttributeDisplayOrder) do
      local statValue = bucketPerkData:GetAttributeBonus(attributeData.stat, 1, 1)
      if statValue ~= 0 then
        potentialStats[index].value = statValue
      end
    end
  end
  table.sort(potentialStats, function(a, b)
    return a.value > b.value
  end)
  for _, data in ipairs(potentialStats) do
    if data.value > 0 then
      if 0 < string.len(summaryString) then
        summaryString = summaryString .. "/"
      end
      summaryString = summaryString .. data.name
    end
  end
  return summaryString
end
function ItemCommon:IsTrinket(itemId)
  local itemDescriptor = ItemDescriptor()
  itemDescriptor.itemId = itemId
  return itemDescriptor:HasItemClass(eItemClass_EquippableAmulet) or itemDescriptor:HasItemClass(eItemClass_EquippableToken) or itemDescriptor:HasItemClass(eItemClass_EquippableRing)
end
return ItemCommon
