local EquipmentStatRow = {
  Properties = {
    LabelText = {
      default = EntityId()
    },
    TotalValueText = {
      default = EntityId()
    },
    ModifierText = {
      default = EntityId()
    },
    DummyValueText = {
      default = EntityId()
    }
  },
  totalValue = 0,
  baseValue = 0,
  modifierValue = 0,
  hasBeenUpdated = false,
  decimalCount = 0,
  totalValueWidth = 0,
  modifierWidth = 0,
  totalValuePadding = 54,
  modifierPadding = 6,
  containerPadding = 18
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(EquipmentStatRow)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function EquipmentStatRow:OnInit()
  self.negativeColorLight = self.UIStyle.COLOR_RED_LIGHT
  self.negativeColorDark = self.UIStyle.COLOR_RED
  self.positiveColorLight = MixColors(self.UIStyle.COLOR_WHITE, self.UIStyle.COLOR_GREEN, 0.25)
  self.positiveColorDark = self.UIStyle.COLOR_GREEN
  self:SetValueForColorShift(5)
end
function EquipmentStatRow:OnShutdown()
end
function EquipmentStatRow:SetValueForColorShift(value)
  self.deltaColorRamp = {
    {
      value = -value,
      color = self.negativeColorDark
    },
    {
      value = -1,
      color = self.negativeColorLight
    },
    {
      value = 1,
      color = self.positiveColorLight
    },
    {
      value = value,
      color = self.positiveColorDark
    }
  }
end
function EquipmentStatRow:SetLabel(value, skipLocalization)
  if skipLocalization then
    UiTextBus.Event.SetText(self.Properties.LabelText, value)
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.LabelText, value, eUiTextSet_SetLocalized)
  end
end
function EquipmentStatRow:SetStatType(statType)
  self.statType = statType
end
function EquipmentStatRow:UpdateStatValues(skipAnimation)
  if not self.statType then
    Log("EquipmentStatRow:UpdateStatValues() ERROR - Must set statType before calling this function")
    return
  end
  local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  self.baseValue = AttributeRequestBus.Event.GetAttributeBaseLevel(playerEntityId, self.statType)
  self.modifierValue = AttributeRequestBus.Event.GetAttributeBonusLevel(playerEntityId, self.statType)
  self:UpdateValue(skipAnimation)
end
function EquipmentStatRow:SetBaseValue(baseValue, skipAnimation)
  self.baseValue = baseValue or 0
  self:UpdateValue(skipAnimation)
end
function EquipmentStatRow:SetModifierValue(modifierValue, skipAnimation)
  self.modifierValue = modifierValue or 0
  self:UpdateValue(skipAnimation)
end
function EquipmentStatRow:SetDecimalCount(value)
  self.decimalCount = value
end
function EquipmentStatRow:GetLabelWidth()
  return UiTextBus.Event.GetTextWidth(self.Properties.LabelText)
end
function EquipmentStatRow:GetValueWidth()
  return UiTextBus.Event.GetTextWidth(self.Properties.DummyValueText)
end
function EquipmentStatRow:SetAllowAnimation(value)
  self.allowAnimation = value
end
function EquipmentStatRow:UpdateValue(skipAnimation)
  local totalValue = self.baseValue + self.modifierValue
  if totalValue == self.totalValue and self.hasBeenUpdated then
    return
  end
  if self.allowAnimation and not skipAnimation then
    self.ScriptedEntityTweener:Stop(self.Properties.TotalValueText)
    UiTextBus.Event.SetText(self.Properties.TotalValueText, GetFormattedNumber(self.totalValue, self.decimalCount))
    self.ScriptedEntityTweener:PlayC(self.entityId, 0.3, tweenerCommon.fadeInQuadOut)
    do
      local valueDifference = totalValue - self.totalValue
      local valueColor = self:GetColorFromRamp(self.deltaColorRamp, valueDifference)
      local origValue = self.totalValue
      self.ScriptedEntityTweener:Play(self.Properties.TotalValueText, 0.3, {
        textColor = valueColor,
        onUpdate = function(currentAnimValue, currentAnimPercent)
          local nowNum = Lerp(origValue, totalValue, currentAnimPercent)
          UiTextBus.Event.SetText(self.Properties.TotalValueText, GetFormattedNumber(nowNum, self.decimalCount))
        end,
        onComplete = function()
          UiTextBus.Event.SetText(self.Properties.TotalValueText, GetFormattedNumber(totalValue, self.decimalCount))
          self.ScriptedEntityTweener:PlayC(self.Properties.TotalValueText, 0.8, tweenerCommon.textToWhite, 0.1)
        end
      })
    end
  else
    UiTextBus.Event.SetText(self.Properties.TotalValueText, GetFormattedNumber(totalValue, self.decimalCount))
  end
  UiTextBus.Event.SetText(self.Properties.DummyValueText, GetFormattedNumber(totalValue, self.decimalCount))
  self.totalValueWidth = UiTextBus.Event.GetTextWidth(self.Properties.DummyValueText) + self.totalValuePadding
  self:UpdateModifierString()
  self.totalValue = totalValue
  self.hasBeenUpdated = true
end
function EquipmentStatRow:UpdateModifierString()
  if self.modifierValue ~= 0 then
    local modifierColor = ColorRgbaToHexString(self.modifierValue > 0 and self.UIStyle.COLOR_GREEN or self.UIStyle.COLOR_RED_MEDIUM)
    local modifierOperator = self.modifierValue > 0 and "+" or "-"
    local modifierString = GetLocalizedReplacementText("@inv_equipmentstatrow_modifiertemplate", {
      baseValue = self.baseValue,
      modifierColor = modifierColor,
      operator = modifierOperator,
      modifierValue = GetFormattedNumber(self.modifierValue, self.decimalCount)
    })
    UiTextBus.Event.SetText(self.Properties.ModifierText, modifierString)
    UiElementBus.Event.SetIsEnabled(self.Properties.ModifierText, true)
    local modifierWidth = UiTextBus.Event.GetTextWidth(self.Properties.ModifierText)
    self.modifierWidth = modifierWidth + self.modifierPadding
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.ModifierText, false)
    self.modifierWidth = 0
  end
end
function EquipmentStatRow:GetWidth()
  return self.totalValueWidth + self.modifierWidth + self.containerPadding
end
function EquipmentStatRow:GetColorFromRamp(ramp, value)
  local lowValue, lowColor, highValue, highColor
  for _, stop in ipairs(ramp) do
    if value > stop.value then
      lowValue = stop.value
      lowColor = stop.color
    elseif value < stop.value then
      highValue = stop.value
      highColor = stop.color
      break
    else
      return stop.color
    end
  end
  if lowColor ~= nil and highColor ~= nil then
    local amount = (value - lowValue) / (highValue - lowValue)
    return MixColors(lowColor, highColor, amount)
  elseif lowColor ~= nil then
    return lowColor
  elseif highColor ~= nil then
    return highColor
  else
    return self.UIStyle.COLOR_WHITE
  end
end
return EquipmentStatRow
