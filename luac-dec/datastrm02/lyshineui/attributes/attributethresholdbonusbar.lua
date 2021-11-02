local AttributeThresholdBonusBar = {
  Properties = {
    Thresholds = {
      default = {
        EntityId()
      }
    },
    TooltipSetter = {
      default = EntityId()
    },
    BarBgHighlight = {
      default = EntityId()
    }
  },
  maxThreshold = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(AttributeThresholdBonusBar)
function AttributeThresholdBonusBar:OnInit()
  BaseElement.OnInit(self)
  self.barWidth = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "javelin.enable-attribute-threshold-bonuses", function(self, enabled)
    self.thresholdsEnabled = enabled ~= nil and enabled or false
    UiElementBus.Event.SetIsEnabled(self.entityId, self.thresholdsEnabled)
  end)
end
function AttributeThresholdBonusBar:SetThresholdBarEnum(enum)
  if not self.thresholdsEnabled then
    return
  end
  self.enum = enum
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, rootPlayerId)
    if not rootPlayerId then
      return
    end
    self.playerEntityId = rootPlayerId
    self:InitThresholdData()
  end)
end
function AttributeThresholdBonusBar:InitThresholdData()
  self.thresholds = {}
  local maxThreshold = 0
  local thresholdValues = AttributeRequestBus.Event.GetAttributeThresholds(self.playerEntityId, self.enum)
  for i = 1, #thresholdValues do
    local attributeLevel = thresholdValues[i].first
    local abilityIds = thresholdValues[i].second
    for j = 1, #abilityIds do
      local staticData = CharacterAbilityRequestBus.Event.GetAbilityData(self.playerEntityId, 786867246, abilityIds[j])
      if 0 < string.len(staticData.displayDescription) then
        local thresholdData = {
          value = attributeLevel,
          inactiveText = staticData.displayDescription,
          activeText = staticData.displayName,
          iconPath = staticData.displayIcon
        }
        maxThreshold = math.max(maxThreshold, thresholdData.value)
        table.insert(self.thresholds, thresholdData)
        break
      end
    end
  end
  local numThresholdEntities = #self.Thresholds
  local minValue = 0
  local posX = 0
  for i = numThresholdEntities, 0, -1 do
    local thresholdSection = self.Thresholds[i]
    local dataIndex = numThresholdEntities - i + 1
    local thresholdData = self.thresholds[dataIndex]
    if thresholdData then
      thresholdData.section = thresholdSection
      local sectionWidth = thresholdSection:SetThresholdSectionData(thresholdData, minValue, maxThreshold, self.barWidth, posX)
      minValue = thresholdData.value
      posX = posX + sectionWidth
    else
      UiElementBus.Event.SetIsEnabled(thresholdSection.entityId, false)
    end
  end
end
function AttributeThresholdBonusBar:UpdateAttributeValues(baseValue, equipmentModifier, buffModifier, pendingValue)
  if not self.thresholdsEnabled then
    return
  end
  for _, thresholdSection in ipairs(self.thresholds) do
    thresholdSection.section:UpdateAttributeValues(baseValue, equipmentModifier, buffModifier, pendingValue)
  end
end
function AttributeThresholdBonusBar:OnFocus()
  self.ScriptedEntityTweener:Play(self.Properties.BarBgHighlight, 0.3, {opacity = 1, ease = "QuadOut"})
  self.TooltipSetter:OnTooltipSetterHoverStart()
end
function AttributeThresholdBonusBar:OnUnfocus()
  self.ScriptedEntityTweener:Play(self.Properties.BarBgHighlight, 0.2, {opacity = 0, ease = "QuadOut"})
  self.TooltipSetter:OnTooltipSetterHoverEnd()
end
function AttributeThresholdBonusBar:SetThresholdBarTooltip(tooltipString)
  self.TooltipSetter:SetSimpleTooltip(tooltipString)
end
return AttributeThresholdBonusBar
