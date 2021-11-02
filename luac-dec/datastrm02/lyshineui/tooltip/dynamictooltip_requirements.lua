local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local DynamicTooltip_Requirements = {
  Properties = {
    StatListMask = {
      default = EntityId()
    },
    StatList = {
      default = EntityId()
    },
    StatLineHeight = {default = 20},
    WeightIcon = {
      default = EntityId()
    }
  },
  isWeapon = false,
  isArmor = false,
  HEADER_HEIGHT = 0,
  BOTTOM_MARGIN = 20,
  CELL_PADDING = 6
}
BaseElement:CreateNewElement(DynamicTooltip_Requirements)
function DynamicTooltip_Requirements:OnInit()
  BaseElement.OnInit(self)
  self.dataLayer = dataLayer
end
function DynamicTooltip_Requirements:OnShutdown()
end
function DynamicTooltip_Requirements:SetCallback(command, table)
  self.callbackFunction = command
  self.callingTable = table
end
function DynamicTooltip_Requirements:SetItem(itemTable, equipSlot, compareTo)
  self.requiredLevel = false
  self.STATS_HEIGHT = 0
  local currentLine = 0
  if itemTable.bindOnPickup then
    currentLine = self:AddStatLine(currentLine, "@ui_bindOnPickup", "", true, true, false, self.UIStyle.COLOR_GREEN)
  elseif itemTable.boundToPlayer then
    currentLine = self:AddStatLine(currentLine, "@ui_boundToPlayer", "", true, true, false, self.UIStyle.COLOR_GREEN)
  elseif itemTable.bindOnEquip then
    currentLine = self:AddStatLine(currentLine, "@ui_bindOnEquip", "", true, true, false, self.UIStyle.COLOR_GREEN)
  end
  if type(itemTable.tier) == "number" and itemTable.tier ~= 0 then
    local tierText = GetRomanFromNumber(itemTable.tier)
    local itemText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@cr_tier_tooltip", tierText)
    currentLine = self:AddStatLine(currentLine, itemText, "", true, true)
  end
  if itemTable.id and itemTable.weaponAttributes then
    local attributeScalingTable = {
      strengthScaling = {
        text = "@ui_strength",
        amount = 0
      },
      dexterityScaling = {
        text = "@ui_dexterity",
        amount = 0
      },
      intelligenceScaling = {
        text = "@ui_intelligence",
        amount = 0
      },
      spiritScaling = {text = "@ui_focus", amount = 0}
    }
    local scalesWith = {}
    local scalingData = ItemDataManagerBus.Broadcast.GetWeaponData(itemTable.id)
    for category, amount in pairs(attributeScalingTable) do
      attributeScalingTable[category].amount = scalingData[category]
      if 0 < attributeScalingTable[category].amount then
        table.insert(scalesWith, attributeScalingTable[category])
      end
    end
    table.sort(scalesWith, function(category1, category2)
      if category1.amount ~= category2.amount then
        return category1.amount > category2.amount
      end
    end)
    if 0 < #scalesWith then
      local label = "@ui_scales_with"
      local value = ""
      for i = 1, #scalesWith do
        if 1 < i then
          value = value .. ", "
        end
        local attributeString = LyShineScriptBindRequestBus.Broadcast.LocalizeText(scalesWith[i].text)
        value = value .. attributeString
      end
      currentLine = self:AddStatLine(currentLine, label, value, true, true)
    end
  end
  if itemTable.weight and not itemTable.ignoreWeight then
    local itemWeight = GetFormattedNumber(itemTable.weight / 10 or 0, 1)
    local itemText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_tooltip_weight", itemWeight)
    currentLine = self:AddStatLine(currentLine, itemText, "", true, true, "lyshineui/images/icons/misc/icon_weight.dds")
  end
  if itemTable.itemType == "Consumable" then
    if itemTable.cooldownDuration and 0 < itemTable.cooldownDuration then
      local duration = LocalizeDecimalSeparators(string.format("%.1f", itemTable.cooldownDuration))
      local itemText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_tooltip_cooldown", duration)
      currentLine = self:AddStatLine(currentLine, itemText, "", true, true, "lyshineui/images/icons/misc/icon_hourglass.dds")
    end
    if itemTable.effectDuration and 0 < itemTable.effectDuration then
      local duration = timeHelpers:ConvertToShorthandString(itemTable.effectDuration, false, false)
      local itemText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_tooltip_effect_duration", duration)
      currentLine = self:AddStatLine(currentLine, itemText, "", true, true, "lyshineui/images/icons/misc/icon_hourglass.dds")
    end
  end
  local maxDurability = itemTable.maxDurability or 0
  local showDurability = 0 < maxDurability
  if showDurability then
    local durability = maxDurability
    local durabilityMaxPercent = 0
    if type(itemTable.durability) == "number" then
      durability = itemTable.durability
    end
    if type(itemTable.maxDurability) == "number" then
      durabilityMaxPercent = 1
    end
    local durabilityPercent = durability / maxDurability
    local showRedDurability = itemTable.deathDurabilityPenalty and durabilityPercent < itemTable.deathDurabilityPenalty
    local durabilityNumber = string.format("%d / %d", tonumber(durability), tonumber(itemTable.maxDurability))
    local durabilityText = showRedDurability and LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_tooltip_durability_red", durabilityNumber) or LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_tooltip_durability", durabilityNumber)
    currentLine = self:AddStatLine(currentLine, durabilityText, "", not showRedDurability, true)
  end
  if itemTable.requiredLevel then
    self.requiredLevel = true
    local statLine
    local requirements = {
      {
        attribute = "requiredLevel",
        attributeOffset = 1,
        name = "@ui_level",
        dataPath = "Hud.LocalPlayer.Progression.Level"
      }
    }
    for _, requirement in ipairs(requirements) do
      local value = GetTableValue(itemTable, requirement.attribute) + requirement.attributeOffset
      if type(value) == "number" and 1 < value then
        local playerValue = self.dataLayer:GetDataFromNode(requirement.dataPath)
        local isValid = playerValue and value <= playerValue
        currentLine = self:AddStatLine(currentLine, requirement.name, value, isValid)
      end
    end
  end
  if currentLine == 0 then
    return 0
  end
  return self.HEADER_HEIGHT + self.STATS_HEIGHT + self.BOTTOM_MARGIN
end
function DynamicTooltip_Requirements:SetTextColor(entity, color)
  UiTextBus.Event.SetColor(entity, color)
end
function DynamicTooltip_Requirements:AddStatLine(currentLine, label, value, isValid, hideHeader, iconPath, color)
  UiDynamicLayoutBus.Event.SetNumChildElements(self.Properties.StatList, currentLine + 1)
  statLine = UiElementBus.Event.GetChild(self.Properties.StatList, currentLine)
  currentLine = currentLine + 1
  local headerEntity = UiElementBus.Event.FindChildByName(statLine, "Header")
  local statEntity = UiElementBus.Event.FindChildByName(headerEntity, "Stat")
  local valueEntity = UiElementBus.Event.FindChildByName(statEntity, "Value")
  local icon = UiElementBus.Event.FindChildByName(statEntity, "WeightIcon")
  local targetHeight = 16
  self.STATS_HEIGHT = self.STATS_HEIGHT + targetHeight + self.CELL_PADDING
  UiLayoutCellBus.Event.SetTargetHeight(statLine, targetHeight)
  UiElementBus.Event.SetIsEnabled(icon, iconPath)
  if iconPath then
    UiImageBus.Event.SetSpritePathname(icon, iconPath)
  end
  local headerText = hideHeader and "" or "@ui_tooltip_required"
  UiTextBus.Event.SetTextWithFlags(headerEntity, headerText, eUiTextSet_SetLocalized)
  local headerPositionX = hideHeader and -5 or 0
  self.ScriptedEntityTweener:Set(headerEntity, {x = headerPositionX})
  SetTextStyle(headerEntity, self.UIStyle.FONT_STYLE_TOOLTIP_STAT_LABEL)
  SetTextStyle(statEntity, self.UIStyle.FONT_STYLE_TOOLTIP_STAT_LABEL)
  SetTextStyle(valueEntity, self.UIStyle.FONT_STYLE_TOOLTIP_STAT_NUMBER)
  UiTextBus.Event.SetTextWithFlags(statEntity, label, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetText(valueEntity, tostring(value))
  local requiredValueColor = color or isValid and self.UIStyle.COLOR_WHITE or self.UIStyle.COLOR_RED_MEDIUM
  local requiredStatColor = color or isValid and self.UIStyle.COLOR_TOOLTIP_GRAY_STATS or self.UIStyle.COLOR_RED_MEDIUM
  self:SetTextColor(valueEntity, requiredValueColor)
  self:SetTextColor(statEntity, requiredStatColor)
  if type(self.callbackFunction) == "function" then
    self.callbackFunction(self.callingTable, not isValid and self.requiredLevel)
  end
  return currentLine
end
return DynamicTooltip_Requirements
