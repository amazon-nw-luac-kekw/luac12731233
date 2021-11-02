local AttributeThresholdBonusSection = {
  Properties = {
    BarContainer = {
      default = EntityId()
    },
    BasePoinstBar = {
      default = EntityId()
    },
    EquipmentModifierBar = {
      default = EntityId()
    },
    BuffModifierBar = {
      default = EntityId()
    },
    PendingPointsBar = {
      default = EntityId()
    },
    ThresholdIcon = {
      default = EntityId()
    },
    BaseDivider = {
      default = EntityId()
    },
    EquipmentDivider = {
      default = EntityId()
    },
    BuffDivider = {
      default = EntityId()
    },
    PendingOverlay = {
      default = EntityId()
    },
    BuffOverlay = {
      default = EntityId()
    },
    EquipmentOverlay = {
      default = EntityId()
    },
    BaseOverlay = {
      default = EntityId()
    },
    FlashOverlay = {
      default = EntityId()
    }
  },
  isFirstUpdate = true
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(AttributeThresholdBonusSection)
function AttributeThresholdBonusSection:OnInit()
  BaseElement.OnInit(self)
  self.iconWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.ThresholdIcon)
  UiImageBus.Event.SetColor(self.Properties.BasePoinstBar, self.UIStyle.COLOR_ATTRIBUTE_POINT_COMMITTED)
  UiImageBus.Event.SetColor(self.Properties.EquipmentModifierBar, self.UIStyle.COLOR_ATTRIBUTE_POINT_EQUIPMENT)
  UiImageBus.Event.SetColor(self.Properties.BuffModifierBar, self.UIStyle.COLOR_ATTRIBUTE_POINT_BUFFS)
  UiImageBus.Event.SetColor(self.Properties.PendingPointsBar, self.UIStyle.COLOR_ATTRIBUTE_POINT_PENDING)
  self.ScriptedEntityTweener:Set(self.Properties.FlashOverlay, {opacity = 0})
end
function AttributeThresholdBonusSection:SetThresholdSectionData(data, minValue, maxThreshold, totalWidth, posX)
  if maxThreshold == 0 then
    return 0
  end
  self.ThresholdIcon:SetThresholdIconData(data)
  self.value = data.value
  self.minValue = minValue
  self.range = data.value - minValue
  local sectionRatio = (data.value - minValue) / maxThreshold
  local sectionWidth = sectionRatio * totalWidth
  local barWidth = sectionWidth - self.iconWidth
  self.barWidth = barWidth
  self.sectionWidth = sectionWidth
  self.totalWidth = totalWidth
  self.dividerWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.BaseDivider)
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, sectionWidth)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.BarContainer, barWidth)
  UiTransformBus.Event.SetLocalPositionX(self.entityId, posX)
  return sectionWidth
end
function AttributeThresholdBonusSection:UpdateAttributeValues(baseValue, equipmentModifier, buffModifier, pendingValue)
  if self.range == 0 then
    return
  end
  local spentPoints = baseValue
  local baseFillPct = 0
  if spentPoints > self.minValue then
    baseFillPct = math.min((spentPoints - self.minValue) / self.range, 1)
  end
  UiImageBus.Event.SetFillAmount(self.Properties.BasePoinstBar, baseFillPct)
  UiElementBus.Event.SetIsEnabled(self.Properties.BaseDivider, 0 < baseFillPct and baseFillPct < 1)
  if 0 < baseFillPct then
    self.ScriptedEntityTweener:Set(self.Properties.BaseDivider, {
      x = baseFillPct * self.barWidth - self.dividerWidth
    })
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.BaseOverlay, 0 < baseFillPct)
  self.ScriptedEntityTweener:Set(self.Properties.BaseOverlay, {
    x = (spentPoints - self.minValue) / self.range * self.barWidth,
    w = spentPoints / self.range * self.barWidth,
    opacity = 0.4
  })
  spentPoints = spentPoints + equipmentModifier
  local equipmentFillPct = 0
  if spentPoints > self.minValue then
    equipmentFillPct = math.min((spentPoints - self.minValue) / self.range, 1)
  end
  UiImageBus.Event.SetFillAmount(self.Properties.EquipmentModifierBar, equipmentFillPct)
  UiElementBus.Event.SetIsEnabled(self.Properties.EquipmentDivider, 0 < equipmentFillPct and equipmentFillPct < 1)
  if 0 < equipmentFillPct then
    self.ScriptedEntityTweener:Set(self.Properties.EquipmentDivider, {
      x = equipmentFillPct * self.barWidth - self.dividerWidth
    })
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.EquipmentOverlay, baseFillPct < equipmentFillPct)
  self.ScriptedEntityTweener:Set(self.Properties.EquipmentOverlay, {
    x = (spentPoints - self.minValue) / self.range * self.barWidth,
    w = equipmentModifier / self.range * self.barWidth,
    opacity = 0.4
  })
  local spentPoints = spentPoints + buffModifier
  local buffFillPct = 0
  if spentPoints > self.minValue then
    buffFillPct = math.min((spentPoints - self.minValue) / self.range, 1)
  end
  UiImageBus.Event.SetFillAmount(self.Properties.BuffModifierBar, buffFillPct)
  UiElementBus.Event.SetIsEnabled(self.Properties.BuffDivider, 0 < buffFillPct and buffFillPct < 1)
  if 0 < buffFillPct then
    self.ScriptedEntityTweener:Set(self.Properties.BuffDivider, {
      x = buffFillPct * self.barWidth - self.dividerWidth
    })
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.BuffOverlay, buffFillPct > math.max(equipmentFillPct, baseFillPct))
  self.ScriptedEntityTweener:Set(self.Properties.BuffOverlay, {
    x = (spentPoints - self.minValue) / self.range * self.barWidth,
    w = buffModifier / self.range * self.barWidth,
    opacity = 0.4
  })
  local pendingValue = spentPoints + pendingValue
  local pendingFillPct = 0
  if pendingValue > self.minValue then
    pendingFillPct = math.min((pendingValue - self.minValue) / self.range, 1)
  end
  local duration = not (not (spentPoints < pendingValue) or pendingValue > self.value or pendingValue < self.minValue) and 0.1 or 0
  self.ScriptedEntityTweener:Play(self.Properties.PendingPointsBar, duration, {imgFill = pendingFillPct})
  UiElementBus.Event.SetIsEnabled(self.Properties.PendingOverlay, spentPoints < pendingValue)
  self.ScriptedEntityTweener:Set(self.Properties.PendingOverlay, {
    x = (pendingValue - self.minValue) / self.range * self.barWidth,
    w = (pendingValue - spentPoints) / self.range * self.barWidth,
    opacity = 0.4
  })
  local justBecameActive = spentPoints >= self.value and self.lastSpentPoints ~= nil and self.lastSpentPoints < self.value
  self.previousPending = justBecameActive and self.previousPending or pendingValue
  local flashWidth = math.max(self.previousPending - (self.lastSpentPoints and self.lastSpentPoints or self.minValue), spentPoints - self.previousPending)
  self.ScriptedEntityTweener:Set(self.Properties.FlashOverlay, {
    x = (pendingValue - self.minValue) / self.range * self.barWidth,
    w = flashWidth / self.range * self.barWidth
  })
  if spentPoints == self.previousPending and not self.isFirstUpdate then
    self.ScriptedEntityTweener:Play(self.Properties.FlashOverlay, 1, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  end
  if 1 <= baseFillPct then
    self.ThresholdIcon:SetThresholdIconState(self.ThresholdIcon.STATE_ACTIVE, self.UIStyle.COLOR_ATTRIBUTE_POINT_COMMITTED, justBecameActive)
  elseif 1 <= equipmentFillPct then
    self.ThresholdIcon:SetThresholdIconState(self.ThresholdIcon.STATE_ACTIVE, self.UIStyle.COLOR_ATTRIBUTE_POINT_EQUIPMENT, justBecameActive)
  elseif 1 <= buffFillPct then
    self.ThresholdIcon:SetThresholdIconState(self.ThresholdIcon.STATE_ACTIVE, self.UIStyle.COLOR_ATTRIBUTE_POINT_BUFFS, justBecameActive)
  elseif 1 <= pendingFillPct then
    self.ThresholdIcon:SetThresholdIconState(self.ThresholdIcon.STATE_PENDING)
  else
    self.ThresholdIcon:SetThresholdIconState(self.ThresholdIcon.STATE_NEUTRAL)
  end
  if not self.isFirstUpdate then
    self.lastSpentPoints = spentPoints
  else
    self.isFirstUpdate = false
  end
end
return AttributeThresholdBonusSection
