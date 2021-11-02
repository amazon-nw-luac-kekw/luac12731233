local NavBarButton = {
  Properties = {
    ButtonText = {
      default = EntityId()
    },
    ButtonBg = {
      default = EntityId()
    },
    ButtonFocus = {
      default = EntityId()
    },
    ButtonFrameRight = {
      default = EntityId()
    },
    ButtonSelectedGlow = {
      default = EntityId()
    },
    ButtonHint = {
      default = EntityId()
    },
    ButtonHintHolder = {
      default = EntityId()
    },
    ButtonIconHolder = {
      default = EntityId()
    },
    ButtonIconValue = {
      default = EntityId()
    },
    ButtonTooltipSetter = {
      default = EntityId()
    }
  },
  soundOnFocus = nil,
  soundOnPress = nil,
  width = 240,
  height = 70,
  index = nil,
  isSelected = false,
  pressCallback = nil,
  pressTable = nil,
  isUsingTooltip = false,
  isIconVisible = false,
  isHintHighlightVisible = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(NavBarButton)
function NavBarButton:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.Properties.ButtonText, self.UIStyle.FONT_STYLE_BUTTON_HORIZONTAL_TAB)
  self.textColor = self.UIStyle.COLOR_TAN_LIGHT
  self.width = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.height = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  self:SetSize(self.width, self.height)
  self.soundOnFocus = self.audioHelper.OnHover_ButtonSimpleText
  self.soundOnPress = self.audioHelper.Accept
end
function NavBarButton:SetCallback(command, table)
  self.pressCallback = command
  self.pressTable = table
end
function NavBarButton:SetSoundOnFocus(value)
  self.soundOnFocus = value
end
function NavBarButton:SetSoundOnPress(value)
  self.soundOnPress = value
end
function NavBarButton:SetSize(width, height)
  self.width = width
  self.height = height
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.width)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.height)
end
function NavBarButton:GetWidth()
  return self.width
end
function NavBarButton:GetHeight()
  return self.height
end
function NavBarButton:SetText(value, skipLocalization)
  if skipLocalization then
    UiTextBus.Event.SetText(self.Properties.ButtonText, value)
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.ButtonText, value, eUiTextSet_SetLocalized)
  end
end
function NavBarButton:GetText()
  return UiTextBus.Event.GetText(self.Properties.ButtonText)
end
function NavBarButton:SetIndex(index)
  self.index = index
end
function NavBarButton:GetIndex()
  return self.index
end
function NavBarButton:SetLastIndex(isLastIndex)
  if isLastIndex then
    self.ScriptedEntityTweener:Set(self.Properties.ButtonFrameRight, {opacity = 1})
  end
end
function NavBarButton:SetIsSelected(isSelected)
  self.isSelected = isSelected
end
function NavBarButton:SetTooltip(value)
  if value == nil or value == "" then
    self.isUsingTooltip = false
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, false)
  else
    self.isUsingTooltip = true
    self.ButtonTooltipSetter:SetSimpleTooltip(value)
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, true)
  end
end
function NavBarButton:SetHint(keybind)
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonHint, true)
  self.ButtonHint:SetKeybindMapping(keybind)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ButtonHint, false)
  if self.isHintHighlightVisible then
    self:SetHintHighlightVisible(self.isHintHighlightVisible)
  end
end
function NavBarButton:SetHintHighlightVisible(isVisible)
  self.isHintHighlightVisible = isVisible
  if UiElementBus.Event.IsEnabled(self.Properties.ButtonHint) then
    self.ButtonHint:SetHighlightVisible(isVisible, true)
  end
end
function NavBarButton:SetIconVisible(isVisible)
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonIconHolder, true)
    self.ScriptedEntityTweener:Play(self.Properties.ButtonIconHolder, 0.2, {opacity = 1, ease = "QuadOut"})
  else
    self.ScriptedEntityTweener:Play(self.Properties.ButtonIconHolder, 0.2, {opacity = 0, ease = "QuadOut"})
  end
end
function NavBarButton:SetIconValue(value)
  if value then
    self:SetIconVisible(true)
    UiTextBus.Event.SetText(self.ButtonIconValue, tostring(value))
    UiElementBus.Event.SetIsEnabled(self.ButtonIconValue, true)
  else
    UiElementBus.Event.SetIsEnabled(self.ButtonIconValue, false)
  end
end
function NavBarButton:OnFocus()
  if self.isUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverStart()
  end
  if self.isSelected then
    return
  end
  local animDuration1 = self.UIStyle.DURATION_BUTTON_FADE_IN
  self.ScriptedEntityTweener:Play(self.Properties.ButtonText, animDuration1, {
    textColor = self.UIStyle.COLOR_WHITE
  })
  if UiElementBus.Event.IsEnabled(self.Properties.ButtonHint) then
    self.ButtonHint:OnFocus()
  end
  if not self.timeline then
    self.timeline = self.ScriptedEntityTweener:TimelineCreate()
    self.timeline:Add(self.Properties.ButtonFocus, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.5})
    self.timeline:Add(self.Properties.ButtonFocus, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 0.75})
    self.timeline:Add(self.Properties.ButtonFocus, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 0.75,
      onComplete = function()
        self.timeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration1, {opacity = 0.75, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 0.75,
    delay = animDuration1,
    onComplete = function()
      self.timeline:Play()
    end
  })
  self.audioHelper:PlaySound(self.soundOnFocus)
end
function NavBarButton:OnUnfocus()
  if self.isUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  end
  if self.isSelected == true then
    return
  end
  local animDuration1 = 0.08
  self.ScriptedEntityTweener:Play(self.Properties.ButtonText, animDuration1, {
    textColor = self.textColor
  })
  self.ScriptedEntityTweener:Play(self.Properties.ButtonBg, 0.02, {opacity = 1, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, 0.12, {opacity = 0, ease = "QuadOIn"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonSelectedGlow, 0.12, {opacity = 0, ease = "QuadIn"})
  if UiElementBus.Event.IsEnabled(self.Properties.ButtonHint) then
    self.ButtonHint:OnUnfocus()
  end
end
function NavBarButton:OnSelect()
  self.ScriptedEntityTweener:Play(self.Properties.ButtonText, 0.05, {
    textColor = self.UIStyle.COLOR_WHITE
  })
  self.ScriptedEntityTweener:Play(self.Properties.ButtonBg, 0.05, {opacity = 0, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, 0.05, {opacity = 0, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonSelectedGlow, 0.2, {opacity = 1, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonSelectedGlow, 0.2, {w = 100}, {w = 364, ease = "QuadOut"})
  if UiElementBus.Event.IsEnabled(self.Properties.ButtonHint) then
    self.ButtonHint:OnFocus()
  end
  self:ExecuteCallback(self.pressTable, self.pressCallback)
end
function NavBarButton:OnPress()
  if self.isUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  end
  self:OnSelect()
  self.audioHelper:PlaySound(self.soundOnPress)
end
function NavBarButton:ExecuteCallback(callbackTable, pressCallback)
  if pressCallback ~= nil and callbackTable ~= nil then
    if type(pressCallback) == "function" then
      pressCallback(callbackTable, self)
    elseif type(callbackTable[pressCallback]) == "function" then
      callbackTable[pressCallback](callbackTable, self)
    end
  end
end
function NavBarButton:OnShutdown()
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
end
return NavBarButton
