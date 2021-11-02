local TabbedListButtonHorizontal = {
  Properties = {
    ButtonFrameLeft = {
      default = EntityId()
    },
    ButtonFrameRight = {
      default = EntityId()
    },
    ButtonFrame = {
      default = EntityId()
    },
    ButtonFocusFrame = {
      default = EntityId()
    },
    ButtonFocusFrameLeft = {
      default = EntityId()
    },
    ButtonFocusFrameRight = {
      default = EntityId()
    },
    ButtonFocusDarken = {
      default = EntityId()
    },
    ButtonText = {
      default = EntityId()
    },
    ButtonBg = {
      default = EntityId()
    },
    ButtonFocus = {
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
    },
    ButtonRadioGroup = {
      default = EntityId()
    }
  },
  BUTTON_STYLE_1 = 1,
  BUTTON_STYLE_2 = 2,
  buttonStyle = nil,
  BUTTON_STYLE_2_FRAME_LEFT_PATH = "lyshineui/images/slices/TabbedListButtonHorizontal/buttonFocusFrameTallShortLeft.dds",
  BUTTON_STYLE_2_FRAME_RIGHT_PATH = "lyshineui/images/slices/TabbedListButtonHorizontal/buttonFocusFrameTallShortRight.dds",
  BUTTON_STYLE_1_HEIGHT = 70,
  BUTTON_STYLE_2_HEIGHT = 52,
  TEXT_ALIGN_LEFT = eUiHAlign_Left,
  TEXT_ALIGN_CENTER = eUiHAlign_Center,
  TEXT_ALIGN_RIGHT = eUiHAlign_Right,
  textAlignment = 1,
  soundOnFocus = nil,
  soundOnPress = nil,
  width = 100,
  height = 30,
  glowOffsetWidth = 170,
  index = nil,
  isFirstIndex = false,
  isLastIndex = false,
  pressCallback = nil,
  pressTable = nil,
  focusCallback = nil,
  focusTable = nil,
  unfocusCallback = nil,
  unfocusTable = nil,
  isUsingTooltip = false,
  isIconVisible = false,
  textInitPosX = nil,
  isHintHighlightVisible = false,
  hintPadding = 18,
  animPositionDuration = 0.3
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TabbedListButtonHorizontal)
function TabbedListButtonHorizontal:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.Properties.ButtonText, self.UIStyle.FONT_STYLE_BUTTON_HORIZONTAL_TAB)
  self.isEnabled = true
  self.textColor = self.UIStyle.COLOR_TAN_LIGHT
  self.width = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.height = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  self:SetSize(self.width, self.height)
  self:SetButtonStyle(self.BUTTON_STYLE_1)
  self.soundOnFocus = self.audioHelper.OnHover_ButtonSimpleText
  self.soundOnPress = self.audioHelper.Accept
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Options.Localization.Language", function(self, language)
    if not language then
      return
    end
    if self.textAlignment ~= nil then
      self:SetTextAlignment(self.textAlignment, true)
    end
  end)
end
function TabbedListButtonHorizontal:SetCallback(command, table)
  self.pressCallback = command
  self.pressTable = table
end
function TabbedListButtonHorizontal:SetFocusCallback(command, table)
  self.focusCallback = command
  self.focusTable = table
end
function TabbedListButtonHorizontal:SetUnfocusCallback(command, table)
  self.unfocusCallback = command
  self.unfocusTable = table
end
function TabbedListButtonHorizontal:SetButtonStyle(style)
  self.buttonStyle = style
  if self.buttonStyle == self.BUTTON_STYLE_1 then
    self:SetHeight(self.BUTTON_STYLE_1_HEIGHT)
    self.ScriptedEntityTweener:Set(self.Properties.ButtonBg, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.ButtonFrame, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.ButtonFocus, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.ButtonFocusFrame, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.ButtonFocusDarken, {opacity = 0})
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonFrameLeft, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonFrameRight, true)
    self:SetGlowOffsetWidth(self.glowOffsetWidth)
    self:SetTextColor(self.UIStyle.COLOR_TAN_LIGHT)
    self:SetTextAlignment(self.TEXT_ALIGN_CENTER)
  elseif self.buttonStyle == self.BUTTON_STYLE_2 then
    self:SetHeight(self.BUTTON_STYLE_2_HEIGHT)
    self.ScriptedEntityTweener:Set(self.Properties.ButtonBg, {opacity = 1})
    self.ScriptedEntityTweener:Set(self.Properties.ButtonFrame, {opacity = 1})
    self.ScriptedEntityTweener:Set(self.Properties.ButtonFocus, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.ButtonFocusFrame, {opacity = 1})
    self.ScriptedEntityTweener:Set(self.Properties.ButtonFocusDarken, {opacity = 1})
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonFrameLeft, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonFrameRight, false)
    self:SetTextColor(self.UIStyle.COLOR_TAN_LIGHT)
    self:SetTextAlignment(self.TEXT_ALIGN_CENTER)
    self:SetButtonFrameStyle()
  end
end
function TabbedListButtonHorizontal:GetButtonStyle()
  return self.buttonStyle
end
function TabbedListButtonHorizontal:SetButtonFrameStyle()
  if self.isFirstIndex then
    UiImageBus.Event.SetSpritePathname(self.Properties.ButtonFocusFrameLeft, self.BUTTON_STYLE_2_FRAME_LEFT_PATH)
  elseif self.isLastIndex then
    UiImageBus.Event.SetSpritePathname(self.Properties.ButtonFocusFrameRight, self.BUTTON_STYLE_2_FRAME_RIGHT_PATH)
  end
end
function TabbedListButtonHorizontal:SetSize(width, height)
  self:SetWidth(width)
  self:SetHeight(height)
end
function TabbedListButtonHorizontal:SetWidth(value)
  self.width = value
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.width)
end
function TabbedListButtonHorizontal:GetWidth()
  return self.width
end
function TabbedListButtonHorizontal:SetHeight(value)
  self.height = value
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.height)
end
function TabbedListButtonHorizontal:GetHeight()
  return self.height
end
function TabbedListButtonHorizontal:SetText(value, skipLocalization)
  if skipLocalization then
    UiTextBus.Event.SetText(self.Properties.ButtonText, value)
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.ButtonText, value, eUiTextSet_SetLocalized)
  end
  self:SetTextAlignment(self.textAlignment)
  if UiElementBus.Event.IsEnabled(self.Properties.ButtonHint) then
    self:SetHintPosition()
  end
end
function TabbedListButtonHorizontal:GetText()
  return UiTextBus.Event.GetText(self.Properties.ButtonText)
end
function TabbedListButtonHorizontal:SetIsMarkupEnabled(value)
  UiTextBus.Event.SetIsMarkupEnabled(self.Properties.ButtonText, value)
end
function TabbedListButtonHorizontal:SetTextAlignment(value, skipAnim)
  local enumAlign
  local textPadding = 15
  local textWidth = UiTextBus.Event.GetTextSize(self.Properties.ButtonText).x
  local textWidthDifference = self.width - textWidth
  local textPosX
  if value == self.TEXT_ALIGN_LEFT then
    enumAlign = value
    textPosX = -textWidthDifference / 2 + textPadding
  elseif value == self.TEXT_ALIGN_CENTER then
    enumAlign = value
    textPosX = 0
    if textWidth > self.width - 10 then
      UiLayoutFitterBus.Event.SetHorizontalFit(self.Properties.ButtonText, false)
      UiTransform2dBus.Event.SetLocalWidth(self.Properties.ButtonText, self.width - 10)
      UiTextBus.Event.SetShrinkToFit(self.Properties.ButtonText, eUiTextShrinkToFit_Uniform)
    else
      UiTextBus.Event.SetShrinkToFit(self.Properties.ButtonText, eUiTextShrinkToFit_None)
      UiLayoutFitterBus.Event.SetHorizontalFit(self.Properties.ButtonText, true)
    end
  elseif value == self.TEXT_ALIGN_RIGHT then
    enumAlign = value
    textPosX = textWidthDifference / 2 - textPadding
  end
  if enumAlign ~= nil then
    self.textAlignment = enumAlign
    self.textInitPosX = textPosX
    if skipAnim then
      self.ScriptedEntityTweener:Set(self.Properties.ButtonText, {x = textPosX})
    else
      self.ScriptedEntityTweener:Play(self.Properties.ButtonText, self.animPositionDuration, {x = textPosX, ease = "QuadOut"})
    end
    if self.isIconVisible then
      self:SetIconPosition()
    end
  end
end
function TabbedListButtonHorizontal:GetTextAlignment()
  return self.textAlignment
end
function TabbedListButtonHorizontal:SetTextColor(color, duration)
  local defaultDuration = 0.3
  local animDuration = duration ~= nil and duration or defaultDuration
  self.textColor = color
  self.ScriptedEntityTweener:Play(self.Properties.ButtonText, animDuration, {textColor = color, ease = "QuadOut"})
end
function TabbedListButtonHorizontal:GetTextColor()
  return UiTextBus.Event.GetColor(self.Properties.ButtonText)
end
function TabbedListButtonHorizontal:SetFontSize(value)
  UiTextBus.Event.SetFontSize(self.Properties.ButtonText, value)
end
function TabbedListButtonHorizontal:GetFontSize()
  return UiTextBus.Event.GetFontSize(self.Properties.ButtonText)
end
function TabbedListButtonHorizontal:SetCharacterSpacing(value)
  UiTextBus.Event.SetCharacterSpacing(self.Properties.ButtonText, value)
end
function TabbedListButtonHorizontal:GetCharacterSpacing()
  return UiTextBus.Event.GetCharacterSpacing(self.Properties.ButtonText)
end
function TabbedListButtonHorizontal:SetTextCasing(value)
  UiTextBus.Event.SetTextCase(self.Properties.ButtonText, value)
end
function TabbedListButtonHorizontal:GetTextCasing()
  return UiTextBus.Event.GetTextCase(self.Properties.ButtonText)
end
function TabbedListButtonHorizontal:SetTextStyle(value)
  SetTextStyle(self.Properties.ButtonText, value)
end
function TabbedListButtonHorizontal:SetIndex(index)
  self.index = index
  if index == 1 then
    self.isFirstIndex = true
  end
  self:SetButtonFrameStyle()
end
function TabbedListButtonHorizontal:GetIndex(index)
  return self.index
end
function TabbedListButtonHorizontal:SetLastIndex(isLastIndex)
  self.isLastIndex = true
  if isLastIndex then
    self.ScriptedEntityTweener:Set(self.Properties.ButtonFrameRight, {opacity = 1})
  end
  self:SetButtonFrameStyle()
end
function TabbedListButtonHorizontal:SetTooltip(value)
  if value == nil or value == "" then
    self.isUsingTooltip = false
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, false)
  else
    self.isUsingTooltip = true
    self.ButtonTooltipSetter:SetSimpleTooltip(value)
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, true)
  end
end
function TabbedListButtonHorizontal:SetHint(hintText, isKeybindName)
  local data = {text = hintText, isKeybind = isKeybindName}
  self:SetHintData(data)
  if hintText then
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonHint, true)
    self:SetHintPosition()
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonHint, false)
    self:SetTextAlignment(self.textAlignment)
  end
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ButtonHint, false)
  self:SetHintPosition()
  if self.isHintHighlightVisible then
    self:SetHintHighlightVisible(self.isHintHighlightVisible)
  end
  local hintKeybindMapping = self.ButtonHint:GetKeybindMapping()
  if hintKeybindMapping ~= nil then
    self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Keybind." .. hintKeybindMapping .. ".ui", function(self, data)
      self:SetHintPosition()
    end)
  end
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Keybind.Reset", function(self, data)
    self:SetHintPosition()
  end)
end
function TabbedListButtonHorizontal:SetHintData(data)
  if data.isKeybind then
    self.ButtonHint:SetKeybindMapping(data.text)
  else
    self.ButtonHint:SetText(data.text)
  end
end
function TabbedListButtonHorizontal:SetHintPadding(value)
  self.hintPadding = value
end
function TabbedListButtonHorizontal:SetHintPosition()
  local textWidth = UiTextBus.Event.GetTextSize(self.Properties.ButtonText).x
  local textWidthDifference = self.width - textWidth
  local hintWidth = self.ButtonHint:GetWidth()
  local initHintWidth = 34
  local initHintPosX = -10
  local hintPadding = self.hintPadding
  local textPosX = 0
  local hintPosX = 0
  if self.textAlignment == self.TEXT_ALIGN_LEFT then
    textPosX = -textWidthDifference / 2 + (hintWidth + hintPadding)
    hintPosX = initHintPosX - (hintWidth - initHintWidth)
  elseif self.textAlignment == self.TEXT_ALIGN_CENTER then
    textPosX = (hintWidth - initHintPosX) / 2
    hintPosX = initHintPosX - (hintWidth - initHintWidth)
  elseif self.textAlignment == self.TEXT_ALIGN_RIGHT then
    textPosX = textWidthDifference / 2 - (hintWidth + hintPadding)
    hintPosX = textWidth + (initHintPosX + initHintWidth + hintPadding)
  end
  self.textInitPosX = textPosX
  self.ScriptedEntityTweener:Play(self.Properties.ButtonText, self.animPositionDuration, {x = textPosX, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonHintHolder, self.animPositionDuration, {x = hintPosX, ease = "QuadOut"})
end
function TabbedListButtonHorizontal:SetHintHighlightVisible(isVisible)
  self.isHintHighlightVisible = isVisible
  if UiElementBus.Event.IsEnabled(self.Properties.ButtonHint) then
    self.ButtonHint:SetHighlightVisible(isVisible)
  end
end
function TabbedListButtonHorizontal:SetIconPath(value)
  if value then
    if not self.isIconVisible then
      self.isIconVisible = true
      UiElementBus.Event.SetIsEnabled(self.Properties.ButtonIconHolder, true)
      self.ScriptedEntityTweener:Set(self.Properties.ButtonIconHolder, {opacity = 1})
    end
    UiImageBus.Event.SetSpritePathname(self.Properties.ButtonIconHolder, value)
  else
    self.isIconVisible = false
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonIconHolder, false)
    self.ScriptedEntityTweener:Play(self.Properties.ButtonIconHolder, self.animPositionDuration / 2, {opacity = 0, ease = "QuadOut"})
  end
  self:SetIconPosition()
end
function TabbedListButtonHorizontal:SetIconPosition()
  if self.isIconVisible then
    local textWidth = UiTextBus.Event.GetTextSize(self.Properties.ButtonText).x
    local textWidthDifference = self.width - textWidth
    local iconTextSpacing = 16
    local iconWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.ButtonIconHolder) + iconTextSpacing
    local iconPadding = 8
    local textPosX = 0
    if self.textAlignment == self.TEXT_ALIGN_LEFT then
      textPosX = -textWidthDifference / 2 + (iconWidth + iconPadding)
    elseif self.textAlignment == self.TEXT_ALIGN_CENTER then
      textPosX = iconWidth / 2
    elseif self.textAlignment == self.TEXT_ALIGN_RIGHT then
      textPosX = textWidthDifference / 2 - iconWidth
      local hintPosX = textWidth + iconWidth / 2
      self.ScriptedEntityTweener:Play(self.Properties.ButtonIconHolder, self.animPositionDuration, {x = hintPosX, ease = "QuadOut"})
    end
    self.ScriptedEntityTweener:Play(self.Properties.ButtonText, self.animPositionDuration, {x = textPosX, ease = "QuadOut"})
  else
    self:SetTextAlignment(self.textAlignment)
  end
end
function TabbedListButtonHorizontal:SetIconColor(color)
  if color then
    UiImageBus.Event.SetColor(self.Properties.ButtonIconHolder, color)
  end
end
function TabbedListButtonHorizontal:SetIconValue(value)
  if value then
    UiTextBus.Event.SetText(self.Properties.ButtonIconValue, tostring(value))
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonIconValue, true)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonIconValue, false)
  end
end
function TabbedListButtonHorizontal:SetIconPositionX(value)
  self.ScriptedEntityTweener:Set(self.Properties.ButtonIconHolder, {x = value})
end
function TabbedListButtonHorizontal:SetHintPositionX(value)
  self.ScriptedEntityTweener:Set(self.Properties.ButtonHint, {x = value})
end
function TabbedListButtonHorizontal:SetSoundOnFocus(value)
  self.soundOnFocus = value
end
function TabbedListButtonHorizontal:SetSoundOnPress(value)
  self.soundOnPress = value
end
function TabbedListButtonHorizontal:OnFocus()
  if self.isUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverStart()
  end
  if not self.isEnabled then
    self:ExecuteCallback(self.focusTable, self.focusCallback)
    return
  end
  local buttonState = UiRadioButtonBus.Event.GetState(self.entityId)
  if buttonState == true then
    self.audioHelper:PlaySound(self.soundOnFocus)
    return
  end
  local animDuration1 = self.UIStyle.DURATION_BUTTON_FADE_IN
  if self.buttonStyle == self.BUTTON_STYLE_1 then
    self.ScriptedEntityTweener:Play(self.Properties.ButtonText, animDuration1, {
      textColor = self.UIStyle.COLOR_WHITE
    })
  elseif self.buttonStyle == self.BUTTON_STYLE_2 then
    self.ScriptedEntityTweener:Play(self.Properties.ButtonText, animDuration1, {
      textColor = self.UIStyle.COLOR_WHITE
    })
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocusFrameLeft, 0, {opacity = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocusFrameRight, 0, {opacity = 0, ease = "QuadOut"})
  end
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
  self:ExecuteCallback(self.focusTable, self.focusCallback)
end
function TabbedListButtonHorizontal:OnUnfocus()
  if self.isUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  end
  local buttonState = UiRadioButtonBus.Event.GetState(self.entityId)
  if buttonState ~= true then
    self:OnUnselected()
  end
  if self.buttonStyle == self.BUTTON_STYLE_2 then
    self.ScriptedEntityTweener:Play(self.Properties.ButtonSelectedGlow, 0.15, {opacity = 0, ease = "QuadIn"})
  end
  self:ExecuteCallback(self.unfocusTable, self.unfocusCallback)
end
function TabbedListButtonHorizontal:OnUnselected()
  local animDuration1 = 0.08
  if self.buttonStyle == self.BUTTON_STYLE_1 then
    self.ScriptedEntityTweener:Play(self.Properties.ButtonText, animDuration1, {
      textColor = self.textColor
    })
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, 0.12, {opacity = 0, ease = "QuadOIn"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonSelectedGlow, 0.12, {opacity = 0, ease = "QuadIn"})
  elseif self.buttonStyle == self.BUTTON_STYLE_2 then
    self.ScriptedEntityTweener:Play(self.Properties.ButtonText, animDuration1, {
      textColor = self.textColor
    })
    self.ScriptedEntityTweener:Play(self.Properties.ButtonBg, 0.02, {opacity = 1, ease = "QuadIn"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFrame, animDuration1, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, 0.12, {opacity = 0, ease = "QuadOIn"})
  end
  if UiElementBus.Event.IsEnabled(self.Properties.ButtonHint) then
    self.ButtonHint:OnUnfocus()
  end
end
function TabbedListButtonHorizontal:OnSelected()
  if not self.isEnabled then
    return
  end
  if self.isUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  end
  self:OnSelect()
  self.audioHelper:PlaySound(self.soundOnPress)
end
function TabbedListButtonHorizontal:OnSelect()
  if not self.isEnabled then
    return
  end
  if self.buttonStyle == self.BUTTON_STYLE_1 then
    self.ScriptedEntityTweener:Play(self.Properties.ButtonText, 0.05, {
      textColor = self.UIStyle.COLOR_WHITE
    })
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, 0.05, {opacity = 0, ease = "QuadIn"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonSelectedGlow, 0.2, {opacity = 0.9, ease = "QuadIn"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonSelectedGlow, 0.2, {
      w = self.width - self.glowOffsetWidth
    }, {
      w = self.width + self.glowOffsetWidth,
      ease = "QuadOut"
    })
  elseif self.buttonStyle == self.BUTTON_STYLE_2 then
    UiElementBus.Event.Reparent(self.entityId, UiRadioButtonBus.Event.GetGroup(self.entityId), EntityId())
    self.ScriptedEntityTweener:Play(self.Properties.ButtonText, 0.05, {
      textColor = self.UIStyle.COLOR_WHITE
    })
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocusFrameLeft, 0.25, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocusFrameRight, 0.25, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonBg, 0.05, {opacity = 0, ease = "QuadIn"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFrame, 0.1, {opacity = 0, ease = "QuadIn"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonSelectedGlow, 0.05, {opacity = 0, ease = "QuadIn"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, 0.05, {opacity = 1, ease = "QuadIn"})
  end
  if UiElementBus.Event.IsEnabled(self.Properties.ButtonHint) then
    self.ButtonHint:OnFocus()
  end
  self:ExecuteCallback(self.pressTable, self.pressCallback)
end
function TabbedListButtonHorizontal:ExecuteCallback(callbackTable, pressCallback)
  if type(pressCallback) == "function" and callbackTable ~= nil then
    pressCallback(callbackTable, self)
  end
end
function TabbedListButtonHorizontal:SetGlowOffsetWidth(glowOffsetWidth)
  self.glowOffsetWidth = glowOffsetWidth
end
function TabbedListButtonHorizontal:GetGlowOffsetWidth()
  return self.glowOffsetWidth
end
function TabbedListButtonHorizontal:OnShutdown()
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
end
function TabbedListButtonHorizontal:SetEnabled(enabled)
  if self.isEnabled ~= enabled then
    self:OnUnselected()
  end
  self.isEnabled = enabled
  if self.buttonStyle == self.BUTTON_STYLE_1 or self.buttonStyle == self.BUTTON_STYLE_2 then
    local animDuration = 0.3
    self:SetTextColor(self.isEnabled and self.UIStyle.COLOR_TAN_LIGHT or self.UIStyle.COLOR_GRAY_30, animDuration)
  end
end
return TabbedListButtonHorizontal
