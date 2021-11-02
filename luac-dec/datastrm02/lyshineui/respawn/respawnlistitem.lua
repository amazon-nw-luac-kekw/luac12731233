local RespawnListItem = {
  Properties = {
    ItemTextLabel = {
      default = EntityId()
    },
    ItemTextDistance = {
      default = EntityId()
    },
    ItemTextCooldown = {
      default = EntityId()
    },
    ItemBg = {
      default = EntityId()
    },
    ItemIcon = {
      default = EntityId()
    },
    ItemFocus = {
      default = EntityId()
    },
    ItemSecondaryTextLabel = {
      default = EntityId()
    },
    ButtonTooltipSetter = {
      default = EntityId()
    }
  },
  width = nil,
  height = nil,
  data = nil,
  callback = nil,
  callbackTable = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(RespawnListItem)
function RespawnListItem:OnInit()
  BaseElement.OnInit(self)
  local textLabelStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = 30,
    fontColor = self.UIStyle.COLOR_TAN,
    lineSpacing = -5
  }
  local textSecondaryStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_SEMIBOLD,
    fontSize = 20,
    fontColor = self.UIStyle.COLOR_TAN
  }
  local textDistanceStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_CASLON,
    fontSize = 30,
    fontColor = self.UIStyle.COLOR_TAN
  }
  local textCooldownStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_MEDIUM,
    fontSize = 18,
    fontColor = self.UIStyle.COLOR_GRAY_70
  }
  SetTextStyle(self.Properties.ItemTextLabel, textLabelStyle)
  SetTextStyle(self.Properties.ItemSecondaryTextLabel, textSecondaryStyle)
  SetTextStyle(self.Properties.ItemTextDistance, textDistanceStyle)
  SetTextStyle(self.Properties.ItemTextCooldown, textCooldownStyle)
  self.width = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.height = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  UiTransformBus.Event.SetLocalPositionY(self.Properties.ItemTextLabel, 0)
  UiTransformBus.Event.SetLocalPositionY(self.Properties.ItemTextDistance, 0)
end
function RespawnListItem:SetCallback(command, table)
  self.callback = command
  self.callbackTable = table
end
function RespawnListItem:SetSize(width, height)
  self.width = width
  self.height = height
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.width)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.height)
end
function RespawnListItem:GetWidth()
  return self.width
end
function RespawnListItem:GetHeight()
  return self.height
end
function RespawnListItem:SetText(value)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ItemTextLabel, value, eUiTextSet_SetLocalized)
end
function RespawnListItem:GetText()
  return UiTextBus.Event.GetText(self.Properties.ItemTextLabel)
end
function RespawnListItem:SetSecondaryText(value)
  if value then
    UiTextBus.Event.SetTextWithFlags(self.Properties.ItemSecondaryTextLabel, value, eUiTextSet_SetLocalized)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.ItemTextLabel, -12)
  else
    UiTextBus.Event.SetText(self.Properties.ItemSecondaryTextLabel, "")
    UiTransformBus.Event.SetLocalPositionY(self.Properties.ItemTextLabel, 0)
  end
end
function RespawnListItem:GetSecondaryText()
  return UiTextBus.Event.GetText(self.Properties.PropertiesItemSecondaryTextLabel)
end
function RespawnListItem:SetTextDistance(value, useWarningColor)
  self.ScriptedEntityTweener:Stop(self.Properties.ItemTextDistance)
  self.useWarningColor = useWarningColor
  if useWarningColor then
    UiTextBus.Event.SetColor(self.Properties.ItemTextDistance, self.UIStyle.COLOR_RED_LIGHT)
  else
    UiTextBus.Event.SetColor(self.Properties.ItemTextDistance, self.UIStyle.COLOR_TAN)
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.ItemTextDistance, value, eUiTextSet_SetLocalized)
end
function RespawnListItem:GetTextDistance()
  return UiTextBus.Event.GetText(self.Properties.ItemTextDistance)
end
function RespawnListItem:SetTextCooldown(value, useWarningColor)
  if useWarningColor then
    UiTextBus.Event.SetColor(self.Properties.ItemTextCooldown, self.UIStyle.COLOR_RED_LIGHT)
  else
    UiTextBus.Event.SetColor(self.Properties.ItemTextCooldown, self.UIStyle.COLOR_GRAY_70)
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.ItemTextCooldown, value, eUiTextSet_SetLocalized)
  UiTransformBus.Event.SetLocalPositionY(self.Properties.ItemTextDistance, -12)
end
function RespawnListItem:GetTextCooldown()
  return UiTextBus.Event.GetText(self.ItemTextCooldown)
end
function RespawnListItem:SetListIcon(iconpath)
  self.offsetApplied = false
  UiElementBus.Event.SetIsEnabled(self.Properties.ItemIcon, true)
  UiImageBus.Event.SetSpritePathname(self.Properties.ItemIcon, iconpath)
  local initialTextOffset = 18
  local iconOffset = 40
  local currentTextOffset = UiTransformBus.Event.GetLocalPositionX(self.Properties.ItemTextLabel)
  local textOffsetWithIcon = initialTextOffset + iconOffset
  local newTextOffset = initialTextOffset > currentTextOffset and currentTextOffset or textOffsetWithIcon
  UiTransformBus.Event.SetLocalPositionX(self.Properties.ItemTextLabel, newTextOffset)
  UiTransformBus.Event.SetLocalPositionX(self.Properties.ItemSecondaryTextLabel, newTextOffset)
end
function RespawnListItem:SetData(data)
  self.data = data
end
function RespawnListItem:GetData()
  return self.data
end
function RespawnListItem:OnFocus()
  local animDuration1 = self.UIStyle.DURATION_BUTTON_FADE_IN
  self.ScriptedEntityTweener:Play(self.Properties.ItemTextLabel, animDuration1, {
    textColor = self.UIStyle.COLOR_WHITE
  })
  self.ScriptedEntityTweener:Play(self.Properties.ItemSecondaryTextLabel, animDuration1, {
    textColor = self.UIStyle.COLOR_WHITE
  })
  if not self.useWarningColor then
    self.ScriptedEntityTweener:Play(self.Properties.ItemTextDistance, animDuration1, {
      textColor = self.UIStyle.COLOR_WHITE
    })
  end
  if not self.timeline then
    self.timeline = self.ScriptedEntityTweener:TimelineCreate()
    self.timeline:Add(self.Properties.ItemFocus, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.7})
    self.timeline:Add(self.Properties.ItemFocus, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
    self.timeline:Add(self.Properties.ItemFocus, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 1,
      onComplete = function()
        self.timeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.ItemFocus, animDuration1, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ItemFocus, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 1,
    delay = animDuration1,
    onComplete = function()
      self.timeline:Play()
    end
  })
  self.ItemFocus:OnFocus()
  self.audioHelper:PlaySound(self.audioHelper.OnHover_DropdownListItem)
  if self.usingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverStart()
  end
end
function RespawnListItem:OnUnfocus()
  local toggleState = UiRadioButtonBus.Event.GetState(self.entityId)
  if toggleState ~= true then
    self:OnUnselected()
  else
    self:UpdateSelectedItem()
  end
  if self.usingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  end
end
function RespawnListItem:SetTooltip(value)
  if value == nil then
    self.ButtonTooltipSetter:SetSimpleTooltip("")
    self.usingTooltip = false
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, false)
  else
    self.ButtonTooltipSetter:SetSimpleTooltip(value)
    self.usingTooltip = true
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, true)
  end
end
function RespawnListItem:OnUnselected()
  local animDuration1 = 0.15
  self.ScriptedEntityTweener:Play(self.Properties.ItemFocus, animDuration1, {opacity = 0, ease = "QuadOut"})
  self.ItemFocus:OnUnfocus()
  self.ScriptedEntityTweener:Play(self.Properties.ItemTextLabel, animDuration1, {
    textColor = self.UIStyle.COLOR_TAN
  })
  self.ScriptedEntityTweener:Play(self.Properties.ItemSecondaryTextLabel, animDuration1, {
    textColor = self.UIStyle.COLOR_TAN
  })
  if not self.useWarningColor then
    self.ScriptedEntityTweener:Play(self.Properties.ItemTextDistance, animDuration1, {
      textColor = self.UIStyle.COLOR_TAN
    })
  end
end
function RespawnListItem:OnPressed()
  self.audioHelper:PlaySound(self.audioHelper.Accept)
end
function RespawnListItem:OnItemSelected()
  self:UpdateSelectedItem()
  if self.soundEnabled then
    self.audioHelper:PlaySound(self.audioHelper.Accept)
  end
end
function RespawnListItem:UpdateSelectedItem()
  local animDuration1 = 0.15
  self.ScriptedEntityTweener:Play(self.Properties.ItemFocus, animDuration1, {opacity = 0.8, ease = "QuadOut"})
  self.ItemFocus:OnFocus()
  self.ScriptedEntityTweener:Play(self.Properties.ItemTextLabel, animDuration1, {
    textColor = self.UIStyle.COLOR_WHITE
  })
  self.ScriptedEntityTweener:Play(self.Properties.ItemSecondaryTextLabel, animDuration1, {
    textColor = self.UIStyle.COLOR_WHITE
  })
  if not self.useWarningColor then
    self.ScriptedEntityTweener:Play(self.Properties.ItemTextDistance, animDuration1, {
      textColor = self.UIStyle.COLOR_WHITE
    })
  end
  if self.callback ~= nil and self.callbackTable ~= nil then
    self.callbackTable[self.callback](self.callbackTable, self.entityId, self.data)
  end
end
function RespawnListItem:OnShutdown()
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
end
return RespawnListItem
