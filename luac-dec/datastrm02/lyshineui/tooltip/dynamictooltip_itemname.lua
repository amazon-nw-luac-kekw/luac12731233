local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local ItemCommon = RequireScript("LyShineUI._Common.ItemCommon")
local ObjectiveTypeData = RequireScript("LyShineUI.Objectives.ObjectiveTypeData")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local EntitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
local DynamicTooltip_ItemName = {
  Properties = {
    Name = {
      default = EntityId()
    },
    Bg = {
      default = EntityId()
    },
    RarityFrame = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    DurabilityMeter = {
      default = EntityId()
    },
    DurabilityFill = {
      default = EntityId()
    },
    DurabilityMaxLoss = {
      default = EntityId()
    },
    DurabilityIcon = {
      default = EntityId()
    },
    DurabilityDividers = {
      default = {
        EntityId()
      }
    },
    TierText = {
      default = EntityId()
    },
    RarityText = {
      default = EntityId()
    },
    MissionIndicator = {
      default = EntityId()
    },
    MissionIcon = {
      default = EntityId()
    },
    MissionText = {
      default = EntityId()
    },
    Equipped = {
      default = EntityId()
    },
    EquippedText = {
      default = EntityId()
    },
    EquippedSeparator = {
      default = EntityId()
    },
    BrokenText = {
      default = EntityId()
    },
    EntitlementIcon = {
      default = EntityId()
    },
    ItemCooldownHolder = {
      default = EntityId()
    },
    ItemCooldownText = {
      default = EntityId()
    },
    ItemCooldownFill = {
      default = EntityId()
    },
    ItemCooldownFlash = {
      default = EntityId()
    },
    OutpostRushIcon = {
      default = EntityId()
    },
    SourceText = {
      default = EntityId()
    },
    SourceIcon = {
      default = EntityId()
    },
    TypeText = {
      default = EntityId()
    }
  },
  parent = nil,
  defaultFramePath = "LyShineUI/images/tooltip/tooltip_itemFrame_rarity_none.dds",
  defaultHeaderBgPath = "LyShineUI/images/tooltip/tooltip_header_bg_0.dds",
  mIconPathRoot = "lyShineui/images/icons/items/",
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
  ITEM_TYPE_DYE = "Dye",
  ITEM_TYPE_HOUSING_ITEM = "HousingItem"
}
BaseElement:CreateNewElement(DynamicTooltip_ItemName)
function DynamicTooltip_ItemName:OnInit()
  BaseElement.OnInit(self)
  self.iconPath = nil
  self.itemType = nil
  SetTextStyle(self.Properties.Name, self.UIStyle.FONT_STYLE_TOOLTIP_HEADER)
  SetTextStyle(self.Properties.TierText, self.UIStyle.FONT_STYLE_TOOLTIP_TIER_ITALIC)
  SetTextStyle(self.Properties.RarityText, self.UIStyle.FONT_STYLE_TOOLTIP_RARITY)
  SetTextStyle(self.Properties.EquippedText, self.UIStyle.FONT_STYLE_TOOLTIP_EQUIPPED)
  SetTextStyle(self.Properties.MissionText, self.UIStyle.FONT_STYLE_TOOLTIP_EQUIPPED)
  SetTextStyle(self.Properties.BrokenText, self.UIStyle.FONT_STYLE_TOOLTIP_STAT_LABEL)
  SetTextStyle(self.Properties.SourceText, self.UIStyle.FONT_STYLE_TOOLTIP_SIMPLE)
  UiTextBus.Event.SetColor(self.Properties.BrokenText, self.UIStyle.COLOR_RED_MEDIUM)
  UiImageBus.Event.SetColor(self.Properties.DurabilityMaxLoss, self.UIStyle.COLOR_RED_DARKER)
  UiImageBus.Event.SetColor(self.Properties.ItemCooldownFill, self.UIStyle.COLOR_ABILITY_COOLDOWN)
  self.damagedTimeline = self.ScriptedEntityTweener:TimelineCreate()
  self.damagedTimeline:Add(self.Properties.DurabilityMeter, 0.39, {
    imgColor = self.UIStyle.COLOR_RED_DARKER
  })
  self.damagedTimeline:Add(self.Properties.DurabilityMeter, 0.06, {
    imgColor = self.UIStyle.COLOR_RED_DARKER
  })
  self.damagedTimeline:Add(self.Properties.DurabilityMeter, 1.002, {
    imgColor = self.UIStyle.COLOR_GRAY_30,
    onComplete = function()
      self.damagedTimeline:Play(0)
    end
  })
end
function DynamicTooltip_ItemName:SetItem(itemTable, equipSlot, compareTo)
  self:ClearItemData()
  local staticItem
  if itemTable.id then
    staticItem = StaticItemDataManager:GetItem(itemTable.id)
  end
  local height = 0
  if type(itemTable.displayName) ~= "string" or string.len(itemTable.displayName) == 0 then
    return height
  end
  height = 90
  if type(itemTable.tier) == "number" and itemTable.tier ~= 0 then
    UiTextBus.Event.SetText(self.Properties.TierText, GetRomanFromNumber(itemTable.tier))
  else
    UiTextBus.Event.SetText(self.Properties.TierText, "")
  end
  local imagePathIcon
  if staticItem then
    self.itemType = staticItem.itemType
    self.iconPath = staticItem.iconPath or staticItem.icon
  end
  local imagePathFolder = self.mIconPathRoot
  if self.itemType == self.ITEM_TYPE_RESOURCE or self.itemType == self.ITEM_TYPE_AMMO or self.itemType == self.ITEM_TYPE_ARMOR or self.itemType == self.ITEM_TYPE_BLUEPRINT or self.itemType == self.ITEM_TYPE_DYE or self.itemType == self.ITEM_TYPE_LORE or self.itemType == self.ITEM_TYPE_WEAPON or self.itemType == self.ITEM_TYPE_CONSUMABLE or self.itemType == self.ITEM_TYPE_CURRENCY or self.itemType == self.ITEM_TYPE_HOUSING_ITEM or self.itemType == self.ITEM_TYPE_KIT or self.itemType == self.ITEM_TYPE_PASSIVE_TOOL then
    imagePathFolder = self.mIconPathRoot .. self.itemType .. "/"
    imagePathIcon = imagePathFolder .. self.iconPath .. ".dds"
  elseif itemTable.spriteName then
    imagePathIcon = itemTable.spriteName
  end
  if imagePathIcon ~= nil then
    UiElementBus.Event.SetIsEnabled(self.Properties.Icon, true)
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, imagePathIcon)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.Icon, false)
  end
  if itemTable.spriteColor then
    UiImageBus.Event.SetColor(self.Properties.Icon, itemTable.spriteColor)
  else
    UiImageBus.Event.SetColor(self.Properties.Icon, self.UIStyle.COLOR_WHITE)
  end
  if itemTable.isOnCooldown then
    local rootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
    local remainingCooldownTime = CooldownTimersComponentBus.Event.GetConsumableCooldown(rootEntityId, itemTable.cooldownId)
    local staticConsumableData = ItemDataManagerBus.Broadcast.GetConsumableData(itemTable.cooldownItemId)
    local totalCooldownTime = staticConsumableData.cooldownDuration
    self:SetItemCooldown(true, remainingCooldownTime, totalCooldownTime)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemCooldownHolder, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemCooldownFlash, false)
  end
  SetTextStyle(self.Properties.Name, self.UIStyle.FONT_STYLE_TOOLTIP_HEADER_NIMBUS)
  SetTextStyle(self.Properties.RarityText, self.UIStyle.FONT_STYLE_TOOLTIP_RARITY)
  UiElementBus.Event.SetIsEnabled(self.Properties.RarityText, itemTable.usesRarity)
  UiElementBus.Event.SetIsEnabled(self.Properties.RarityFrame, true)
  local enableItemSkinning = ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-item-skinning")
  UiElementBus.Event.SetIsEnabled(self.Properties.EntitlementIcon, enableItemSkinning and itemTable.hasEntitlements)
  local frameImagePath, headerBgPath
  if itemTable.usesRarity then
    local raritySuffix = tostring(itemTable.rarityLevel)
    local displayName = "@RarityLevel" .. raritySuffix .. "_DisplayName"
    UiTextBus.Event.SetTextWithFlags(self.Properties.RarityText, displayName, eUiTextSet_SetLocalized)
    local colorName = string.format("COLOR_TOOLTIP_RARITY_LEVEL_%s", raritySuffix)
    UiTextBus.Event.SetColor(self.Properties.RarityText, self.UIStyle[colorName])
    UiTextBus.Event.SetColor(self.Properties.Name, self.UIStyle[colorName])
    if 0 < itemTable.rarityLevel then
      frameImagePath = "LyShineUI/images/tooltip/tooltip_itemFrame_rarity" .. raritySuffix .. ".dds"
      headerBgPath = "LyShineUI/images/tooltip/tooltip_header_bg_" .. raritySuffix .. ".dds"
    end
  end
  UiImageBus.Event.SetSpritePathname(self.Properties.RarityFrame, frameImagePath or self.defaultFramePath)
  UiImageBus.Event.SetSpritePathname(self.Properties.Bg, headerBgPath or self.defaultHeaderBgPath)
  UiImageBus.Event.SetAlpha(self.Properties.Bg, 0.7)
  local maxDurability = itemTable.maxDurability or 0
  local showDurability = 0 < maxDurability
  UiElementBus.Event.SetIsEnabled(self.Properties.DurabilityIcon, showDurability)
  UiElementBus.Event.SetIsEnabled(self.Properties.DurabilityFill, showDurability)
  UiElementBus.Event.SetIsEnabled(self.Properties.DurabilityMeter, showDurability)
  local durability
  local brokenText = ""
  local equippedSeparatorText = ""
  local equippedText = "@ui_equipped"
  if showDurability then
    durability = maxDurability
    local durabilityMaxPercent = 0
    if type(itemTable.durability) == "number" then
      durability = itemTable.durability
    end
    if type(itemTable.maxDurability) == "number" then
      durabilityMaxPercent = 1
    end
    local durabilityPercent = durability / maxDurability
    UiProgressBarBus.Event.SetProgressPercent(self.Properties.DurabilityFill, durabilityPercent)
    local maxLossAnchor = durabilityMaxPercent
    UiTransform2dBus.Event.SetAnchorsScript(self.Properties.DurabilityMaxLoss, UiAnchors(maxLossAnchor, 0, 1, 1))
    UiElementBus.Event.SetIsEnabled(self.Properties.DurabilityIcon, durability == 0)
    if equipSlot == nil then
      equippedText = ""
    end
    if durability == 0 then
      brokenText = "@ui_tooltip_broken"
      if equipSlot ~= nil then
        equippedSeparatorText = "/"
        self.ScriptedEntityTweener:Set(self.Properties.EquippedSeparator, {x = 3})
        self.ScriptedEntityTweener:Set(self.Properties.BrokenText, {x = 3})
      else
        self.ScriptedEntityTweener:Set(self.Properties.EquippedSeparator, {x = 0})
        self.ScriptedEntityTweener:Set(self.Properties.BrokenText, {x = 0})
      end
    end
    if itemTable.deathDurabilityPenalty and durabilityPercent < itemTable.deathDurabilityPenalty then
      self.damagedTimeline:Play()
    else
      self.damagedTimeline:Stop()
      UiImageBus.Event.SetColor(self.Properties.DurabilityMeter, self.UIStyle.COLOR_GRAY_30)
    end
    if itemTable.itemType == "Consumable" then
      for i = 0, #self.Properties.DurabilityDividers do
        local shouldShow = i < maxDurability - 1
        UiElementBus.Event.SetIsEnabled(self.Properties.DurabilityDividers[i], shouldShow)
        if shouldShow then
          UiTransform2dBus.Event.SetAnchorsScript(self.Properties.DurabilityDividers[i], UiAnchors((i + 1) / maxDurability, 0, (i + 1) / maxDurability, 1))
        end
      end
    else
      for i = 0, #self.Properties.DurabilityDividers do
        UiElementBus.Event.SetIsEnabled(self.Properties.DurabilityDividers[i], false)
      end
    end
  else
    equippedSeparatorText = ""
    brokenText = ""
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.Equipped, equipSlot ~= nil or durability == 0)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Name, itemTable.displayName, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.EquippedText, equippedText, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetText(self.Properties.EquippedSeparator, equippedSeparatorText)
  UiTextBus.Event.SetTextWithFlags(self.Properties.BrokenText, brokenText, eUiTextSet_SetLocalized)
  if itemTable.name and itemTable.name ~= "" then
    local dataNode = self.dataLayer:GetDataNode("Hud.LocalPlayer.ItemsToProcure.RefCount")
    local isItemToProcure = false
    local childNames = dataNode:GetChildrenNames()
    for i = 1, #childNames do
      local childName = childNames[i]
      if childName == itemTable.name then
        local childNode = dataNode[childName]
        local instanceIdCount = childNode:GetData()
        isItemToProcure = 0 < instanceIdCount
        if isItemToProcure then
          local objectiveIdNode = self.dataLayer:GetDataNode("Hud.LocalPlayer.ItemsToProcure.ObjectiveIds." .. childName)
          if objectiveIdNode then
            local objectiveTaskIds = objectiveIdNode:GetChildren()
            for i = 1, #objectiveTaskIds do
              local objectiveInstanceId = objectiveTaskIds[i]:GetData()
              if objectiveInstanceId then
                local objectiveType = ObjectiveRequestBus.Event.GetType(objectiveInstanceId)
                local typeData = ObjectiveTypeData:GetType(objectiveType)
                UiImageBus.Event.SetSpritePathname(self.Properties.MissionIcon, typeData.iconPath)
                UiImageBus.Event.SetColor(self.Properties.MissionIcon, typeData.iconColor)
                break
              end
            end
          end
        end
        break
      end
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.MissionIndicator, isItemToProcure)
  end
  if itemTable.isOutpostRushOnly ~= nil then
    UiElementBus.Event.SetIsEnabled(self.Properties.OutpostRushIcon, itemTable.isOutpostRushOnly)
  end
  if itemTable.availableProducts then
    UiElementBus.Event.SetIsEnabled(self.Properties.SourceIcon, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.SourceText, true)
    local iconTexture = "LyShineUI/Images/Entitlements/icon_purchasable.dds"
    local textColor = self.UIStyle.COLOR_YELLOW
    local labelText = "@ui_store"
    if 0 < #itemTable.availableProducts then
      if itemTable.sourceType == EntitlementsDataHandler.MTX_SOURCE_TYPE_TWITCH then
        iconTexture = "LyShineUI/Images/Entitlements/icon_entitlement_Twitch.dds"
        textColor = self.UIStyle.COLOR_PURPLE
        labelText = "@ui_twitch_item"
      elseif itemTable.sourceType == EntitlementsDataHandler.MTX_SOURCE_TYPE_PRIME then
        iconTexture = "LyShineUI/Images/Entitlements/icon_entitlement_TwitchPrime.dds"
        textColor = self.UIStyle.COLOR_BLUE_MEDIUM
        labelText = "@ui_prime_gaming_item"
      elseif itemTable.sourceType == EntitlementsDataHandler.MTX_SOURCE_TYPE_PREORDER then
        iconTexture = "LyShineUI/Images/Entitlements/icon_entitlement_locked.dds"
        textColor = self.UIStyle.COLOR_WHITE
        labelText = "@ui_pre_order_item"
      elseif itemTable.sourceType == EntitlementsDataHandler.MTX_SOURCE_TYPE_STORE then
        iconTexture = "LyShineUI/Images/Entitlements/icon_purchasable.dds"
        textColor = self.UIStyle.COLOR_YELLOW
        labelText = "@ui_store"
      else
        iconTexture = "LyShineUI/Images/Entitlements/icon_entitlement_locked.dds"
        textColor = self.UIStyle.COLOR_WHITE
        labelText = "@ui_mtx_unavailable"
      end
    else
      iconTexture = "LyShineUI/Images/Entitlements/icon_entitlement_locked.dds"
      textColor = self.UIStyle.COLOR_WHITE
      labelText = "@ui_mtx_unavailable"
    end
    UiImageBus.Event.SetSpritePathname(self.Properties.SourceIcon, iconTexture)
    UiTextBus.Event.SetColor(self.Properties.SourceText, textColor)
    UiTextBus.Event.SetTextWithFlags(self.Properties.SourceText, labelText, eUiTextSet_SetLocalized)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.SourceIcon, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.SourceText, false)
  end
  if itemTable.itemTypeDisplayName and 0 < #itemTable.itemTypeDisplayName then
    UiElementBus.Event.SetIsEnabled(self.Properties.TypeText, true)
    UiTextBus.Event.SetTextWithFlags(self.Properties.TypeText, itemTable.itemTypeDisplayName, eUiTextSet_SetLocalized)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.TypeText, false)
  end
  local nameHeight = UiTextBus.Event.GetTextSize(self.Properties.Name).y
  height = math.max(height, nameHeight + 35)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.Bg, height)
  if itemTable.availableProducts then
    height = height + 42
  end
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, height)
  return height
end
function DynamicTooltip_ItemName:SetItemCooldown(isOnCooldown, remainingCooldown, totalCooldown)
  if isOnCooldown then
    if remainingCooldown then
      local startFill = totalCooldown and totalCooldown ~= 0 and remainingCooldown / totalCooldown or 1
      UiElementBus.Event.SetIsEnabled(self.Properties.ItemCooldownHolder, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.ItemCooldownFlash, true)
      self.ScriptedEntityTweener:Stop(self.Properties.ItemCooldownFill)
      self.ScriptedEntityTweener:Play(self.Properties.ItemCooldownHolder, 0.3, {opacity = 1, ease = "QuadOut"})
      self.ScriptedEntityTweener:Play(self.Properties.ItemCooldownFill, remainingCooldown, {imgFill = startFill}, {
        imgFill = 0,
        onUpdate = function(currentValue, currentProgressPercent)
          local timeRemaining = (1 - currentProgressPercent) * remainingCooldown
          if 3 < timeRemaining then
            UiTextBus.Event.SetText(self.Properties.ItemCooldownText, string.format("%d", timeRemaining))
          else
            UiTextBus.Event.SetText(self.Properties.ItemCooldownText, string.format("%.1f", timeRemaining))
          end
        end,
        onComplete = function()
          self:SetItemCooldown(false)
        end
      })
    end
  else
    self.ScriptedEntityTweener:Play(self.Properties.ItemCooldownHolder, 0.3, {opacity = 0, ease = "QuadOut"})
    UiFlipbookAnimationBus.Event.Start(self.Properties.ItemCooldownFlash)
  end
end
function DynamicTooltip_ItemName:ClearItemData()
  self.iconPath = nil
  self.itemType = nil
end
function DynamicTooltip_ItemName:OnHideTooltip()
  self.damagedTimeline:Stop()
end
return DynamicTooltip_ItemName
