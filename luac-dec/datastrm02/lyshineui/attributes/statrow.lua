local StatRow = {
  Properties = {
    Text = {
      default = EntityId()
    },
    CurrentValue = {
      default = EntityId()
    },
    ModifiedValue = {
      default = EntityId()
    },
    BarBg = {
      default = EntityId()
    },
    BarFill = {
      default = EntityId()
    },
    TooltipSetter = {
      default = EntityId()
    }
  },
  previewOffset = 9,
  pendingValue = 0,
  currentValue = 0,
  barWidth = 400
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(StatRow)
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function StatRow:OnInit()
  BaseElement.OnInit(self)
  self.dataLayer = dataLayer
  self.barColor = self.UIStyle.COLOR_WHITE
  UiFaderBus.Event.SetFadeValue(self.ModifiedValue, 0)
  self.modifiedValueX = UiTransformBus.Event.GetLocalPositionX(self.Properties.ModifiedValue)
  UiTransformBus.Event.SetLocalPositionX(self.Properties.ModifiedValue, self.modifiedValueX - self.previewOffset)
  SetTextStyle(self.Properties.Text, self.UIStyle.FONT_STYLE_ATTRIBUTES_STAT_VITALS)
  SetTextStyle(self.Properties.CurrentValue, self.UIStyle.FONT_STYLE_ATTRIBUTES_STAT)
end
function StatRow:UpdateStatValue(data)
  if data ~= nil then
    if self.floorValue then
      data = math.floor(data)
    end
    self.currentValue = data
    self:UpdateCurrentValue()
  end
end
function StatRow:UpdateActiveValue(data)
  if data ~= nil then
    self.statValue = data
    self:UpdateCurrentValue()
  end
end
function StatRow:UpdatePendingValue(data)
  if data ~= nil then
    self.pendingValue = data
    self:UpdateModifiedValue()
  end
end
function StatRow:UpdateByEbusRequest()
  if self.ebusRequest then
    local value = self.ebusRequest()
    if value then
      self:UpdateStatValue(value)
    end
  end
end
function StatRow:RegisterObservers()
  if not self.isDataRegistered then
    if self.activeDataPath ~= nil then
      self.dataLayer:RegisterAndExecuteDataObserver(self, self.activeDataPath, self.UpdateActiveValue)
    end
    if self.statDataPath ~= nil then
      self.dataLayer:RegisterAndExecuteDataObserver(self, self.statDataPath, self.UpdateStatValue)
    end
    if self.pendingDataPath ~= nil then
      self.dataLayer:RegisterAndExecuteDataObserver(self, self.pendingDataPath, self.UpdatePendingValue)
    end
    self.isDataRegistered = true
  end
end
function StatRow:UnregisterObservers()
  self.isDataRegistered = false
  self.dataLayer:UnregisterObservers(self)
end
function StatRow:SetDataPath(value)
  self.statDataPath = value
end
function StatRow:SetPendingDataPath(value)
  self.pendingDataPath = value
end
function StatRow:SetActiveDataPath(value)
  self.activeDataPath = value
end
function StatRow:SetEbusRequest(value)
  self.ebusRequest = value
  self:UpdateByEbusRequest()
end
function StatRow:SetBarColor(value)
  self.barColor = value
  self:UpdateBarColor()
end
function StatRow:SetDepletedBarColor(value)
  self.depletedBarColor = value
  self:UpdateBarColor()
end
function StatRow:SetIsPercent(value)
  self.isPercent = value
end
function StatRow:SetNumberFormat(value)
  self.numberFormat = value
end
function StatRow:SetDivisor(value)
  self.divisor = value
end
function StatRow:SetText(value)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Text, value, eUiTextSet_SetLocalized)
end
function StatRow:SetName(value)
  self.name = value
end
function StatRow:SetTooltip(value)
  self.tooltipString = value
  self:UpdateTooltip()
end
function StatRow:SetBarHeight(height)
  UiElementBus.Event.SetIsEnabled(self.Properties.BarBg, 0 < height)
  if 0 < height then
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.BarBg, height)
  end
  local targetHeight = self.baseHeight + height
  UiLayoutCellBus.Event.SetTargetHeight(self.entityId, targetHeight)
end
function StatRow:GetDisplayCurrentValue(stat, numeratorStat)
  if self.divisor and self.divisor ~= 0 then
    stat = stat / self.divisor
  end
  local returnVal
  if self.isPercent and self.numberFormat then
    returnVal = string.format(self.numberFormat .. "%%", stat * 100)
  elseif self.isPercent then
    if self.roundValue then
      returnVal = string.format("%d%%", math.floor(stat * 100 + 0.5))
    else
      returnVal = string.format("%.2f%%", stat * 100)
    end
  elseif self.numberFormat then
    returnVal = string.format(self.numberFormat, stat)
  else
    if self.roundValue then
      returnVal = math.floor(stat + 0.5)
    else
      returnVal = math.ceil(stat)
    end
    if numeratorStat then
      returnVal = math.ceil(numeratorStat) .. " / " .. returnVal
    end
  end
  return LocalizeDecimalSeparators(returnVal)
end
function StatRow:UpdateTooltip()
  if self.tooltipString ~= nil then
    local tooltipValue = GetLocalizedReplacementText(self.tooltipString, {
      currentValue = math.floor(self.statValue or 0),
      maxValue = self.currentValue
    })
    self.TooltipSetter:SetSimpleTooltip(tooltipValue)
  end
end
function StatRow:SetFloorValue(floorValue)
  self.floorValue = floorValue
end
function StatRow:SetRoundValue(roundValue)
  self.roundValue = roundValue
end
function StatRow:UpdateCurrentValue()
  if self.currentValue then
    UiTextBus.Event.SetText(self.CurrentValue, self:GetDisplayCurrentValue(self.currentValue))
    if self.currentValue > 0 then
      local barPercent = (self.statValue or 0) / self.currentValue
      UiTransformBus.Event.SetScaleX(self.Properties.BarFill, barPercent)
      self:UpdateBarColor()
    end
    self:UpdateModifiedValue()
    self:UpdateTooltip()
  else
    UiTextBus.Event.SetText(self.CurrentValue, "@ui_coming_soon")
  end
end
function StatRow:UpdateModifiedValue()
  local animDuration = 0.15
  if self.pendingValue > 0 and not Math.IsClose(self.pendingValue, 0) then
    local displayValue = self.pendingValue + self.currentValue
    UiTextBus.Event.SetText(self.Properties.ModifiedValue, self:GetDisplayCurrentValue(displayValue))
    local modifiedTextWidth = UiTextBus.Event.GetTextWidth(self.Properties.ModifiedValue)
    local margin = 15
    self.ScriptedEntityTweener:Play(self.Properties.ModifiedValue, animDuration, {
      x = self.modifiedValueX,
      opacity = 1,
      ease = "QuadOut"
    })
  else
    self.ScriptedEntityTweener:Play(self.Properties.ModifiedValue, animDuration, {
      x = self.modifiedValueX - self.previewOffset,
      opacity = 0,
      ease = "QuadOut"
    })
  end
end
function StatRow:UpdateBarColor()
  local color = self.barColor
  if self.depletedBarColor and self.statValue and self.currentValue and self.statValue < self.currentValue then
    color = self.depletedBarColor
  end
  UiImageBus.Event.SetColor(self.Properties.BarFill, color)
end
function StatRow:OnShutdown()
  self:UnregisterObservers()
end
return StatRow
