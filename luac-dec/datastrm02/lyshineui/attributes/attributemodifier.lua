local AttributeModifier = {
  Properties = {
    Text = {
      default = EntityId()
    },
    Value = {
      default = EntityId()
    },
    ValueTooltipSetter = {
      default = EntityId()
    },
    PendingValue = {
      default = EntityId()
    },
    ThresholdBar = {
      default = EntityId()
    },
    QuestionMark = {
      default = EntityId()
    },
    AttributeIconHolder = {
      default = EntityId()
    },
    SubtractButton = {
      default = EntityId()
    },
    SubtractButtonHighlight = {
      default = EntityId()
    },
    Subtract10Button = {
      default = EntityId()
    },
    Subtract10ButtonHighlight = {
      default = EntityId()
    },
    Subtract10ButtonTooltip = {
      default = EntityId()
    },
    AddButton = {
      default = EntityId()
    },
    AddButtonHighlight = {
      default = EntityId()
    },
    Add10Button = {
      default = EntityId()
    },
    Add10ButtonHighlight = {
      default = EntityId()
    },
    Add10ButtonTooltip = {
      default = EntityId()
    }
  },
  AddButtonPress = nil,
  SubtractButtonPress = nil,
  PressTable = nil,
  spentValue = 0,
  pendingValue = 0,
  unspentPoints = 0,
  initialWait = 0.5,
  waitInBetween = 0.1,
  timer = 0,
  hasUpdatedValue = false,
  isFirstUpdate = true
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(AttributeModifier)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function AttributeModifier:OnInit()
  BaseElement.OnInit(self)
  self.originalValuePosY = UiTransformBus.Event.GetLocalPositionY(self.Properties.Value)
  self.timelines = {}
  UiTextBus.Event.SetColor(self.Properties.PendingValue, self.UIStyle.COLOR_ATTRIBUTE_POINT_PENDING)
  self.QuestionMark:SetButtonStyle(self.QuestionMark.BUTTON_STYLE_QUESTION_MARK)
  self.Add10ButtonTooltip:SetSimpleTooltip("@ui_add_10_points")
  self.Subtract10ButtonTooltip:SetSimpleTooltip("@ui_subtract_10_points")
  SetTextStyle(self.Properties.Text, self.UIStyle.FONT_STYLE_ATTRIBUTES_HEADER)
  SetTextStyle(self.Properties.Value, self.UIStyle.FONT_STYLE_ATTRIBUTES_VALUE)
end
function AttributeModifier:RegisterObservers()
  if not self.attributeDataPath then
    return
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Attributes.UnspentPoints", self.SetUnspentPointsData)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.attributeDataPath .. "Pending", self.SetPendingValueData)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.attributeDataPath .. "Spent", self.SetSpentValueData)
end
function AttributeModifier:UnregisterObservers()
  if not self.attributeDataPath then
    return
  end
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Attributes.UnspentPoints")
  self.dataLayer:UnregisterObserver(self, self.attributeDataPath .. "Pending")
  self.dataLayer:UnregisterObserver(self, self.attributeDataPath .. "Spent")
end
function AttributeModifier:SetCallbacks(AddButtonPress, SubtractButtonPress, table)
  self.AddButtonPress = AddButtonPress
  self.SubtractButtonPress = SubtractButtonPress
  self.PressTable = table
end
function AttributeModifier:SetName(value)
  if self.attributeName == value then
    return
  end
  self.attributeName = value
  self.attributeDataPath = string.format("Hud.LocalPlayer.Attributes.%s.", self.attributeName)
end
function AttributeModifier:SetEnum(enum)
  self.enumAttibute = enum
  self.ThresholdBar:SetThresholdBarEnum(enum)
end
function AttributeModifier:SetText(value)
  self.displayName = value
  UiTextBus.Event.SetTextWithFlags(self.Properties.Text, value, eUiTextSet_SetLocalized)
end
function AttributeModifier:SetTooltip(value)
  self.QuestionMark:SetTooltip(value)
end
function AttributeModifier:SetWeaponScalingData(data)
  local weaponScalingData = data.weaponScalingData
  UiDynamicLayoutBus.Event.SetNumChildElements(self.Properties.AttributeIconHolder, #weaponScalingData)
  local childElements = UiElementBus.Event.GetChildren(self.Properties.AttributeIconHolder)
  for i = 1, #childElements do
    local childTable = self.registrar:GetEntityTable(childElements[i])
    local weaponData = weaponScalingData[i]
    local color = weaponData.scalePrimary == data.name and self.UIStyle.COLOR_TAN_LIGHT or self.UIStyle.COLOR_TAN
    local name = LyShineScriptBindRequestBus.Broadcast.LocalizeText(weaponData.text)
    local attribute = LyShineScriptBindRequestBus.Broadcast.LocalizeText(weaponData.attribute)
    local tooltipString = GetLocalizedReplacementText("@ui_attribute_scale", {name = name, attribute = attribute})
    childTable:SetImageType(childTable.IMAGE_TYPE_STRETCHED_TO_FIT)
    childTable:SetFocusEnabled(true)
    childTable:SetIcon(weaponData.iconSmall, color)
    childTable:SetTooltip(tooltipString)
  end
  local iconHolderPosX = UiTransformBus.Event.GetLocalPositionX(self.Properties.AttributeIconHolder)
  local iconHolderWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.AttributeIconHolder)
  local padding = 10
  UiTransformBus.Event.SetLocalPositionX(self.Properties.QuestionMark, iconHolderPosX + iconHolderWidth + padding)
end
function AttributeModifier:SetUnspentPointsData(data)
  if data ~= nil then
    self.unspentPoints = data
    self:UpdateArrows()
  end
end
function AttributeModifier:SetPendingValueData(data)
  if data ~= nil then
    self.pendingValue = data
    if not self.isFirstUpdate then
      self:UpdateValue()
    end
    self.isFirstUpdate = false
    self:UpdateArrows()
  end
end
function AttributeModifier:SetSpentValueData(data)
  if data ~= nil then
    self.spentValue = data
    if not self.isFirstUpdate then
      self:UpdateValue()
    end
    self.isFirstUpdate = false
  end
end
function AttributeModifier:UpdateValue()
  local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  local totalBonusModifier = AttributeRequestBus.Event.GetAttributeBonusLevel(playerEntityId, self.enumAttibute)
  local equipmentModifier = AttributeRequestBus.Event.GetEquipmentAttributeBonusLevel(playerEntityId, self.enumAttibute)
  local buffModifier = totalBonusModifier - equipmentModifier
  local baseValue = self.spentValue - totalBonusModifier
  local tooltipString = GetLocalizedReplacementText("@ui_attributemodifier_tooltip", {
    color = ColorRgbaToHexString(self.UIStyle.COLOR_WHITE),
    attributeValue = self.spentValue,
    attributeName = self.displayName
  })
  if 0 < equipmentModifier or buffModifier ~= 0 or self.pendingValue and 0 < self.pendingValue then
    tooltipString = tooltipString .. "\n" .. GetLocalizedReplacementText("@ui_attributemodifier_tooltip_committed", {
      color = ColorRgbaToHexString(self.UIStyle.COLOR_ATTRIBUTE_POINT_COMMITTED),
      value = baseValue
    })
  end
  if 0 < equipmentModifier then
    tooltipString = tooltipString .. "\n" .. GetLocalizedReplacementText("@ui_attributemodifier_tooltip_equipment", {
      color = ColorRgbaToHexString(self.UIStyle.COLOR_ATTRIBUTE_POINT_EQUIPMENT),
      value = equipmentModifier
    })
  end
  if buffModifier ~= 0 then
    local modifierOperator = buffModifier < 0 and "-" or ""
    local modifierColor = buffModifier < 0 and self.UIStyle.COLOR_RED_MEDIUM or self.UIStyle.COLOR_ATTRIBUTE_POINT_BUFFS
    tooltipString = tooltipString .. "\n" .. GetLocalizedReplacementText("@ui_attributemodifier_tooltip_buffs", {
      color = ColorRgbaToHexString(self.UIStyle.COLOR_ATTRIBUTE_POINT_BUFFS),
      value = buffModifier,
      modifierColor = ColorRgbaToHexString(modifierColor),
      modifierOperator = modifierOperator
    })
  end
  if self.pendingValue and 0 < self.pendingValue then
    self.ScriptedEntityTweener:PlayC(self.Properties.Value, 0.3, tweenerCommon.textToGreen)
    UiElementBus.Event.SetIsEnabled(self.Properties.PendingValue, true)
    local pendingValueText = GetLocalizedReplacementText("@ui_attributemodifier_pending_value", {
      pendingValue = self.pendingValue
    })
    UiTextBus.Event.SetText(self.Properties.PendingValue, pendingValueText)
    tooltipString = tooltipString .. "\n" .. GetLocalizedReplacementText("@ui_attributemodifier_tooltip_pending", {
      color = ColorRgbaToHexString(self.UIStyle.COLOR_ATTRIBUTE_POINT_PENDING),
      value = self.pendingValue
    })
  else
    self.ScriptedEntityTweener:PlayC(self.Properties.Value, 0.3, tweenerCommon.textToWhite)
    UiElementBus.Event.SetIsEnabled(self.Properties.PendingValue, false)
  end
  UiTextBus.Event.SetText(self.Properties.Value, self.spentValue + self.pendingValue)
  self.ThresholdBar:UpdateAttributeValues(baseValue, equipmentModifier, buffModifier, self.pendingValue)
  self.ThresholdBar:SetThresholdBarTooltip(tooltipString)
  self.ValueTooltipSetter:SetSimpleTooltip(tooltipString)
end
function AttributeModifier:UpdateArrows()
  if self.pendingValue and self.pendingValue > 0 then
    self:SetButtonEnabled("SubtractButton", true)
  else
    self:SetButtonEnabled("SubtractButton", false)
  end
  if self.pendingValue and self.pendingValue >= 10 then
    self:SetButtonEnabled("Subtract10Button", true)
  else
    self:SetButtonEnabled("Subtract10Button", false)
  end
  if self.unspentPoints and 0 < self.unspentPoints then
    self:SetButtonEnabled("AddButton", true)
  else
    self:SetButtonEnabled("AddButton", false)
  end
  if self.unspentPoints and 10 <= self.unspentPoints then
    self:SetButtonEnabled("Add10Button", true)
  else
    self:SetButtonEnabled("Add10Button", false)
  end
end
function AttributeModifier:SetButtonEnabled(buttonName, isEnabled)
  local animDuration = 0.15
  if self[buttonName .. "Enabled"] ~= isEnabled then
    self[buttonName .. "Enabled"] = isEnabled
    if isEnabled then
      self.ScriptedEntityTweener:PlayC(self.Properties[buttonName], animDuration, tweenerCommon.fadeInQuadOut)
      self.ScriptedEntityTweener:Play(self.Properties[buttonName], animDuration, {
        imgColor = self.UIStyle.COLOR_TAN
      })
    else
      if buttonName == "Subtract10Button" or buttonName == "Add10Button" then
        self.ScriptedEntityTweener:PlayC(self.Properties[buttonName], animDuration, tweenerCommon.fadeOutQuadOut)
      else
        self.ScriptedEntityTweener:Play(self.Properties[buttonName], animDuration, {
          imgColor = self.UIStyle.COLOR_TAN_DARKER
        })
      end
      self:UnfocusButton(buttonName)
      self:StopTick()
    end
  end
end
function AttributeModifier:OnAddButtonFocus()
  if self.AddButtonEnabled then
    self:FocusButton("AddButton")
  end
end
function AttributeModifier:OnAddButtonUnfocus()
  if self.AddButtonEnabled then
    self:UnfocusButton("AddButton")
    self:StopTick()
  end
end
function AttributeModifier:OnAddButtonPress()
  if self.AddButtonEnabled and self.AddButtonPress and self.PressTable then
    self:OnAdd(1)
    self.updateFunc = self.OnAdd
    self.updateAmount = 1
    if not self.tickHandler then
      self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
    end
  end
end
function AttributeModifier:OnAdd10ButtonFocus()
  if self.Add10ButtonEnabled then
    self:FocusButton("Add10Button")
    self.Add10ButtonTooltip:OnTooltipSetterHoverStart()
  end
end
function AttributeModifier:OnAdd10ButtonUnfocus()
  if self.Add10ButtonEnabled then
    self:UnfocusButton("Add10Button")
    self.Add10ButtonTooltip:OnTooltipSetterHoverEnd()
    self:StopTick()
  end
end
function AttributeModifier:OnAdd10ButtonPress()
  if self.Add10ButtonEnabled and self.AddButtonPress and self.PressTable then
    self.Add10ButtonTooltip:OnTooltipSetterHoverEnd()
    self:OnAdd(10)
    self.updateFunc = self.OnAdd
    self.updateAmount = 10
    if not self.tickHandler then
      self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
    end
  end
end
function AttributeModifier:OnAdd(amount)
  self.AddButtonPress(self.PressTable, self.enumAttibute, amount)
  self.audioHelper:PlaySound(self.audioHelper.Accept)
end
function AttributeModifier:OnAddButtonReleased()
  if self.AddButtonEnabled and self.AddButtonPress and self.PressTable then
    self:StopTick()
  end
end
function AttributeModifier:OnAdd10ButtonReleased()
  if self.Add10ButtonEnabled and self.AddButtonPress and self.PressTable then
    self:StopTick()
  end
end
function AttributeModifier:OnSubtractButtonFocus()
  if self.SubtractButtonEnabled then
    self:FocusButton("SubtractButton")
  end
end
function AttributeModifier:OnSubtractButtonUnfocus()
  if self.SubtractButtonEnabled then
    self:UnfocusButton("SubtractButton")
    self:StopTick()
  end
end
function AttributeModifier:OnSubtractButtonPress()
  if self.SubtractButtonEnabled and self.SubtractButtonPress and self.PressTable then
    self:OnSubtract(1)
    self.updateFunc = self.OnSubtract
    self.updateAmount = 1
    if not self.tickHandler then
      self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
    end
  end
end
function AttributeModifier:OnSubtract10ButtonFocus()
  if self.Subtract10ButtonEnabled then
    self:FocusButton("Subtract10Button")
    self.Subtract10ButtonTooltip:OnTooltipSetterHoverStart()
  end
end
function AttributeModifier:OnSubtract10ButtonUnfocus()
  if self.Subtract10ButtonEnabled then
    self:UnfocusButton("Subtract10Button")
    self.Subtract10ButtonTooltip:OnTooltipSetterHoverEnd()
    self:StopTick()
  end
end
function AttributeModifier:OnSubtract10ButtonPress()
  if self.Subtract10ButtonEnabled and self.SubtractButtonPress and self.PressTable then
    self:OnSubtract(10)
    self.Subtract10ButtonTooltip:OnTooltipSetterHoverEnd()
    self.updateFunc = self.OnSubtract
    self.updateAmount = 10
    if not self.tickHandler then
      self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
    end
  end
end
function AttributeModifier:OnSubtract(amount)
  self.SubtractButtonPress(self.PressTable, self.enumAttibute, amount)
  self.audioHelper:PlaySound(self.audioHelper.Accept)
end
function AttributeModifier:OnSubtractButtonReleased()
  if self.SubtractButtonEnabled and self.SubtractButtonPress and self.PressTable then
    self:StopTick()
  end
end
function AttributeModifier:OnSubtract10ButtonReleased()
  if self.Subtract10ButtonEnabled and self.SubtractButtonPress and self.PressTable then
    self:StopTick()
  end
end
function AttributeModifier:FocusButton(buttonName)
  local highlightEntityId = self.Properties[buttonName .. "Highlight"]
  if not self.timelines[buttonName] then
    self.timelines[buttonName] = self.ScriptedEntityTweener:TimelineCreate()
    self.timelines[buttonName]:Add(highlightEntityId, 0.35, {opacity = 0.7})
    self.timelines[buttonName]:Add(highlightEntityId, 0.05, {opacity = 0.7})
    self.timelines[buttonName]:Add(highlightEntityId, 0.3, {
      opacity = 0.3,
      onComplete = function()
        self.timelines[buttonName]:Play()
      end
    })
  end
  UiElementBus.Event.SetIsEnabled(highlightEntityId, true)
  self.timelines[buttonName]:Play()
end
function AttributeModifier:UnfocusButton(buttonName)
  local highlightEntityId = self.Properties[buttonName .. "Highlight"]
  if self.timelines[buttonName] then
    self.timelines[buttonName]:Stop()
  end
  self.ScriptedEntityTweener:PlayC(self.Properties[buttonName .. "Highlight"], 0.15, tweenerCommon.fadeOutQuadOut, nil, function()
    UiElementBus.Event.SetIsEnabled(highlightEntityId, false)
  end)
end
function AttributeModifier:OnShutdown()
  for i, timeline in pairs(self.timelines) do
    timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(timeline)
  end
  self:UnregisterObservers()
  self:StopTick()
end
function AttributeModifier:OnTick(delta, timepoint)
  if self.hasUpdatedValue == false and self.timer < self.initialWait then
    self.timer = self.timer + delta
    if self.timer > self.initialWait then
      self.timer = self.timer - self.initialWait
      self.hasUpdatedValue = true
      self:updateFunc(self.updateAmount)
    end
  elseif self.timer < self.waitInBetween then
    self.timer = self.timer + delta
    if self.timer > self.waitInBetween then
      self.timer = self.timer - self.waitInBetween
      self:updateFunc(self.updateAmount)
    end
  end
end
function AttributeModifier:StopTick()
  if self.tickHandler then
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
    self.timer = 0
    self.hasUpdatedValue = false
    self.updateFunc = nil
  end
end
return AttributeModifier
