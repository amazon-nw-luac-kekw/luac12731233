local TabbedListButtonVertical = {
  Properties = {
    ButtonText = {
      default = EntityId()
    },
    NewText = {
      default = EntityId()
    },
    ButtonSecondaryText = {
      default = EntityId()
    },
    ButtonBg = {
      default = EntityId()
    },
    ButtonFrame = {
      default = EntityId()
    },
    ButtonFrameUnselected = {
      default = EntityId()
    },
    ButtonFrameSelectedTop = {
      default = EntityId()
    },
    ButtonFrameSelectedBottom = {
      default = EntityId()
    },
    ButtonFocus = {
      default = EntityId()
    },
    ButtonFocusGlow = {
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
    },
    DynamicallyClonedStyle = {default = 0}
  },
  BUTTON_STYLE_1 = 1,
  BUTTON_STYLE_2 = 2,
  BUTTON_STYLE_3 = 3,
  buttonStyle = nil,
  BUTTON_STYLE_1_HEIGHT = 45,
  BUTTON_STYLE_2_HEIGHT = 72,
  BUTTON_STYLE_3_HEIGHT = 45,
  BUTTON_FIRST_INDEX = 1,
  BUTTON_SECOND_INDEX = 2,
  BUTTON_FRAME_TOP_PATH_SHORT = "lyshineui/images/slices/TabbedListButtonVertical/buttonFrameSelectedFrameTopShort.dds",
  BUTTON_FRAME_TOP_PATH_LONG = "lyshineui/images/slices/TabbedListButtonVertical/buttonFrameSelectedFrameTopLong.dds",
  BUTTON_STYLE_3_FRAME_PATH = "lyshineui/images/framethin.dds",
  BUTTON_STYLE_3_SELECTED_PATH = "lyshineui/images/crafting/craftingfilterlisthighlight.dds",
  TEXT_ALIGN_LEFT = eUiHAlign_Left,
  TEXT_ALIGN_CENTER = eUiHAlign_Center,
  TEXT_ALIGN_RIGHT = eUiHAlign_Right,
  textAlignment = 1,
  soundOnFocus = nil,
  soundOnPress = nil,
  width = 100,
  height = 30,
  index = nil,
  pressCallback = nil,
  pressTable = nil,
  focusCallback = nil,
  focusTable = nil,
  unfocusCallback = nil,
  unfocusTable = nil,
  isUsingTooltip = false,
  isTextSet = false,
  isSecondaryTextSet = false,
  isIconValueSet = false,
  isIconVisible = false,
  textInitPosX = nil,
  isHintHighlightVisible = false,
  isWarning = false,
  hintPadding = 18,
  animPositionDuration = 0.3
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TabbedListButtonVertical)
function TabbedListButtonVertical:OnInit()
  BaseElement.OnInit(self)
  self.isEnabled = true
  self.textColor = self.UIStyle.COLOR_WHITE
  self.width = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.height = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  self:SetSize(self.width, self.height)
  if self.Properties.DynamicallyClonedStyle > 0 then
    self:SetButtonStyle(self.Properties.DynamicallyClonedStyle)
  else
    self:SetButtonStyle(self.BUTTON_STYLE_1)
  end
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
function TabbedListButtonVertical:SetCallback(command, table)
  self.pressCallback = command
  self.pressTable = table
end
function TabbedListButtonVertical:SetSelectedCallback(command, table)
  self.selectedCallback = command
  self.selectedTable = table
end
function TabbedListButtonVertical:SetFocusCallback(command, table)
  self.focusCallback = command
  self.focusTable = table
end
function TabbedListButtonVertical:SetUnfocusCallback(command, table)
  self.unfocusCallback = command
  self.unfocusTable = table
end
function TabbedListButtonVertical:SetButtonStyle(style)
  self.buttonStyle = style
  if self.buttonStyle == self.BUTTON_STYLE_1 then
    SetTextStyle(self.Properties.ButtonText, self.UIStyle.FONT_STYLE_BUTTON_VERTICAL_TAB)
    SetTextStyle(self.Properties.ButtonSecondaryText, self.UIStyle.FONT_STYLE_BUTTON_VERTICAL_TAB_SECONDARY)
    SetTextStyle(self.Properties.ButtonIconValue, self.UIStyle.FONT_STYLE_BUTTON_VERTICAL_TAB_VALUE)
    self.ScriptedEntityTweener:Set(self.Properties.ButtonFocus, {opacity = 0})
    self:SetTextColor(self.UIStyle.COLOR_WHITE)
    self:SetTextAlignment(self.TEXT_ALIGN_LEFT)
    UiTransformBus.Event.SetPivot(self.Properties.ButtonIconHolder, Vector2(1, 0.5))
    self:SetIconSize(34, 34)
    self:SetHeight(self.BUTTON_STYLE_1_HEIGHT)
  elseif self.buttonStyle == self.BUTTON_STYLE_2 then
    SetTextStyle(self.Properties.ButtonText, self.UIStyle.FONT_STYLE_BUTTON_VERTICAL_TAB_LARGE)
    SetTextStyle(self.Properties.ButtonSecondaryText, self.UIStyle.FONT_STYLE_BUTTON_VERTICAL_TAB_SECONDARY)
    SetTextStyle(self.Properties.ButtonIconValue, self.UIStyle.FONT_STYLE_BUTTON_VERTICAL_TAB_VALUE_LARGE)
    UiTextBus.Event.SetShrinkToFit(self.Properties.ButtonIconValue, eUiTextShrinkToFit_None)
    UiTransformBus.Event.SetPivot(self.Properties.ButtonIconHolder, Vector2(0.5, 0.5))
    UiImageBus.Event.SetImageType(self.Properties.ButtonIconHolder, eUiImageType_StretchedToFit)
    self:SetIconSize(42, 42)
    self:SetIconColor(self.UIStyle.COLOR_TAN)
    self:SetSecondaryTextColor(self.UIStyle.COLOR_TAN_LIGHT)
    self:SetIconValueColor(self.UIStyle.COLOR_WHITE)
    self:SetTextAlignment(self.TEXT_ALIGN_LEFT)
    self:SetHeight(self.BUTTON_STYLE_2_HEIGHT)
  elseif self.buttonStyle == self.BUTTON_STYLE_3 then
    SetTextStyle(self.Properties.ButtonText, self.UIStyle.FONT_STYLE_BUTTON_VERTICAL_TAB_JOURNAL)
    self:SetTextColor(self.UIStyle.COLOR_TAN_HEADER_SECONDARY)
    UiElementBus.Event.SetIsEnabled(self.Properties.NewText, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonFrameSelectedTop, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonFrameSelectedBottom, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonFrameUnselected, false)
    UiImageBus.Event.SetSpritePathname(self.Properties.ButtonFrame, self.BUTTON_STYLE_3_FRAME_PATH)
    UiImageBus.Event.SetSpritePathname(self.Properties.ButtonFocus, self.BUTTON_STYLE_3_SELECTED_PATH)
    UiTransform2dBus.Event.SetOffsets(self.Properties.ButtonFocus, UiOffsets(0, 1, -1, -1))
    self:SetIconSize(42, 42)
    self:SetIconColor(self.UIStyle.COLOR_TAN)
    self:SetSecondaryTextColor(self.UIStyle.COLOR_TAN_LIGHT)
    self:SetIconValueColor(self.UIStyle.COLOR_WHITE)
    SetTextStyle(self.Properties.NewText, self.UIStyle.FONT_STYLE_BUTTON_VERTICAL_TAB_NEW_TEXT)
    self:SetTextAlignment(self.TEXT_ALIGN_LEFT, true)
    self:SetHeight(self.BUTTON_STYLE_3_HEIGHT)
  end
end
function TabbedListButtonVertical:GetButtonStyle()
  return self.buttonStyle
end
function TabbedListButtonVertical:SetButtonFrameStyle(value)
  if value == self.BUTTON_FIRST_INDEX then
    UiImageBus.Event.SetSpritePathname(self.Properties.ButtonFrameSelectedTop, self.BUTTON_FRAME_TOP_PATH_SHORT)
  elseif value == self.BUTTON_SECOND_INDEX then
    self.ScriptedEntityTweener:Set(self.Properties.ButtonFrameSelectedTop, {h = 50})
    UiImageBus.Event.SetSpritePathname(self.Properties.ButtonFrameSelectedTop, self.BUTTON_FRAME_TOP_PATH_LONG)
  else
    UiImageBus.Event.SetSpritePathname(self.Properties.ButtonFrameSelectedTop, self.BUTTON_FRAME_TOP_PATH_LONG)
  end
end
function TabbedListButtonVertical:SetSize(width, height)
  self.width = width
  self.height = height
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.width)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.height)
end
function TabbedListButtonVertical:SetWidth(value)
  self.width = value
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.width)
end
function TabbedListButtonVertical:GetWidth()
  return self.width
end
function TabbedListButtonVertical:SetHeight(value)
  self.height = value
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.height)
end
function TabbedListButtonVertical:SetLowerBound(below)
  local lowerGlowHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.ButtonFrameSelectedBottom)
  if below < lowerGlowHeight then
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.ButtonFrameSelectedBottom, math.max(below, 1))
  end
end
function TabbedListButtonVertical:GetHeight()
  return self.height
end
function TabbedListButtonVertical:SetText(value, skipLocalization)
  self.isTextSet = value ~= "" and value ~= nil
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
function TabbedListButtonVertical:GetText()
  return UiTextBus.Event.GetText(self.Properties.ButtonText)
end
function TabbedListButtonVertical:SetSecondaryText(value, skipLocalization)
  self.isSecondaryTextSet = value ~= "" and value ~= nil
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonSecondaryText, self.isSecondaryTextSet)
  if skipLocalization then
    UiTextBus.Event.SetText(self.Properties.ButtonSecondaryText, value)
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.ButtonSecondaryText, value, eUiTextSet_SetLocalized)
  end
  self:SetTextAlignment(self.textAlignment)
end
function TabbedListButtonVertical:GetSecondaryText()
  return UiTextBus.Event.GetText(self.Properties.ButtonSecondaryText)
end
function TabbedListButtonVertical:SetIsMarkupEnabled(value)
  UiTextBus.Event.SetIsMarkupEnabled(self.Properties.ButtonText, value)
end
function TabbedListButtonVertical:SetTextAlignment(value, skipAnim)
  if self.buttonStyle == self.BUTTON_STYLE_1 then
    local textPadding = 15
    local textPosY = 0
    self.ScriptedEntityTweener:Set(self.Properties.ButtonText, {y = textPosY})
    UiTextBus.Event.SetShrinkToFit(self.Properties.ButtonText, self.UIStyle.TEXT_SHRINK_TO_FIT_NONE)
    local enumAlign
    local textWidth = UiTextBus.Event.GetTextSize(self.Properties.ButtonText).x
    local maxTextWidth = self.width - textPadding * 2
    if textWidth > maxTextWidth then
      UiLayoutFitterBus.Event.SetHorizontalFit(self.Properties.ButtonText, false)
      UiTextBus.Event.SetShrinkToFit(self.Properties.ButtonText, self.UIStyle.TEXT_SHRINK_TO_FIT_UNIFORM)
      UiTransform2dBus.Event.SetLocalWidth(self.Properties.ButtonText, maxTextWidth)
      textWidth = maxTextWidth
    else
      UiLayoutFitterBus.Event.SetHorizontalFit(self.Properties.ButtonText, true)
      UiTextBus.Event.SetShrinkToFit(self.Properties.ButtonText, self.UIStyle.TEXT_SHRINK_TO_FIT_NONE)
    end
    local textWidthDifference = self.width - textWidth
    local textPosX
    if value == self.TEXT_ALIGN_LEFT then
      enumAlign = value
      textPosX = -textWidthDifference / 2 + textPadding
    elseif value == self.TEXT_ALIGN_CENTER then
      enumAlign = value
      textPosX = 0
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
    end
  elseif self.buttonStyle == self.BUTTON_STYLE_2 then
    local marginRight = 10
    local textPadding = 60
    local textWidth = UiTextBus.Event.GetTextSize(self.Properties.ButtonText).x
    local textWidthDifference = self.width - textWidth
    local textPosX = -textWidthDifference / 2 + textPadding
    local textPosY = -1
    if self.isSecondaryTextSet then
      textPosY = -12
    end
    if textWidthDifference < textPadding + marginRight then
      UiLayoutFitterBus.Event.SetHorizontalFit(self.Properties.ButtonText, false)
      UiTransform2dBus.Event.SetLocalWidth(self.Properties.ButtonText, self.width - (textPadding + marginRight))
      UiTextBus.Event.SetShrinkToFit(self.Properties.ButtonText, eUiTextShrinkToFit_Uniform)
      textPosX = 25
    else
      UiTextBus.Event.SetShrinkToFit(self.Properties.ButtonText, eUiTextShrinkToFit_None)
      UiLayoutFitterBus.Event.SetHorizontalFit(self.Properties.ButtonText, true)
    end
    if skipAnim then
      self.ScriptedEntityTweener:Set(self.Properties.ButtonText, {x = textPosX, y = textPosY})
    else
      self.ScriptedEntityTweener:Play(self.Properties.ButtonText, self.animPositionDuration, {
        x = textPosX,
        y = textPosY,
        ease = "QuadOut"
      })
    end
  elseif self.buttonStyle == self.BUTTON_STYLE_3 then
    local marginRight = 60
    local textPadding = 10
    local textWidth = UiTextBus.Event.GetTextSize(self.Properties.ButtonText).x
    local textWidthDifference = self.width - textWidth
    local textPosX = -textWidthDifference / 2 + textPadding
    local textPosY = -1
    if textWidthDifference < textPadding + marginRight then
      UiLayoutFitterBus.Event.SetHorizontalFit(self.Properties.ButtonText, false)
      UiTransform2dBus.Event.SetLocalWidth(self.Properties.ButtonText, self.width - (textPadding + marginRight))
      UiTextBus.Event.SetShrinkToFit(self.Properties.ButtonText, eUiTextShrinkToFit_Uniform)
      textPosX = 25
    else
      UiTextBus.Event.SetShrinkToFit(self.Properties.ButtonText, eUiTextShrinkToFit_None)
      UiLayoutFitterBus.Event.SetHorizontalFit(self.Properties.ButtonText, true)
    end
    self.ScriptedEntityTweener:Set(self.Properties.ButtonText, {x = textPosX, y = textPosY})
  end
  if self.isIconVisible or self.isIconValueSet then
    self:SetIconPosition()
  end
end
function TabbedListButtonVertical:GetTextAlignment()
  return self.textAlignment
end
function TabbedListButtonVertical:SetTextColor(color, duration)
  local defaultDuration = 0.3
  local animDuration = duration ~= nil and duration or defaultDuration
  self.textColor = color
  self.ScriptedEntityTweener:Play(self.Properties.ButtonText, animDuration, {textColor = color, ease = "QuadOut"})
end
function TabbedListButtonVertical:GetTextColor()
  return UiTextBus.Event.GetColor(self.Properties.ButtonText)
end
function TabbedListButtonVertical:SetSecondaryTextColor(color, duration)
  local defaultDuration = 0.3
  local animDuration = duration ~= nil and duration or defaultDuration
  self.secondaryTextColor = color
  self.ScriptedEntityTweener:Play(self.Properties.ButtonSecondaryText, animDuration, {textColor = color, ease = "QuadOut"})
end
function TabbedListButtonVertical:GetSecondaryTextColor()
  return UiTextBus.Event.GetColor(self.Properties.ButtonSecondaryText)
end
function TabbedListButtonVertical:SetIconValueColor(color, duration)
  local defaultDuration = 0.3
  local animDuration = duration ~= nil and duration or defaultDuration
  self.iconValueColor = color
  self.ScriptedEntityTweener:Play(self.Properties.ButtonIconValue, animDuration, {textColor = color, ease = "QuadOut"})
end
function TabbedListButtonVertical:SetIconValueOpacity(value)
  local opacity = value and value < 1 and 0.35 or 1
  self.ScriptedEntityTweener:Set(self.Properties.ButtonIconValue, {opacity = opacity, ease = "QuadOut"})
end
function TabbedListButtonVertical:SetFontSize(value)
  UiTextBus.Event.SetFontSize(self.Properties.ButtonText, value)
end
function TabbedListButtonVertical:GetFontSize()
  return UiTextBus.Event.GetFontSize(self.Properties.ButtonText)
end
function TabbedListButtonVertical:SetTextPositionY(value)
  UiTransformBus.Event.SetLocalPositionY(self.Properties.ButtonText, value)
end
function TabbedListButtonVertical:GetTextPositionY()
  return UiTransformBus.Event.GetLocalPositionY(self.Properties.ButtonText)
end
function TabbedListButtonVertical:SetCharacterSpacing(value)
  UiTextBus.Event.SetCharacterSpacing(self.Properties.ButtonText, value)
end
function TabbedListButtonVertical:GetCharacterSpacing()
  return UiTextBus.Event.GetCharacterSpacing(self.Properties.ButtonText)
end
function TabbedListButtonVertical:SetTextCasing(value)
  UiTextBus.Event.SetTextCase(self.Properties.ButtonText, value)
end
function TabbedListButtonVertical:GetTextCasing()
  return UiTextBus.Event.GetTextCase(self.Properties.ButtonText)
end
function TabbedListButtonVertical:SetTextStyle(value)
  SetTextStyle(self.Properties.ButtonText, value)
end
function TabbedListButtonVertical:SetWarning(isWarning)
  if isWarning then
    self.isWarning = true
    UiTextBus.Event.SetColor(self.Properties.ButtonText, self.UIStyle.COLOR_RED_MEDIUM)
    UiTextBus.Event.SetColor(self.Properties.ButtonSecondaryText, self.UIStyle.COLOR_RED_MEDIUM)
    UiTextBus.Event.SetColor(self.Properties.ButtonIconValue, self.UIStyle.COLOR_RED_MEDIUM)
    UiImageBus.Event.SetColor(self.Properties.ButtonIconHolder, self.UIStyle.COLOR_RED_MEDIUM)
  else
    self.isWarning = false
    UiTextBus.Event.SetColor(self.Properties.ButtonText, self.textColor)
    UiTextBus.Event.SetColor(self.Properties.ButtonSecondaryText, self.secondaryTextColor)
    UiTextBus.Event.SetColor(self.Properties.ButtonIconValue, self.iconValueColor)
    UiImageBus.Event.SetColor(self.Properties.ButtonIconHolder, self.iconColor)
  end
end
function TabbedListButtonVertical:SetIndex(index)
  self.index = index
  self:SetButtonFrameStyle(index)
end
function TabbedListButtonVertical:GetIndex()
  return self.index
end
function TabbedListButtonVertical:SetTooltip(value)
  if value == nil or value == "" then
    self.isUsingTooltip = false
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, false)
  else
    self.isUsingTooltip = true
    self.ButtonTooltipSetter:SetSimpleTooltip(value)
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, true)
  end
end
function TabbedListButtonVertical:SetHint(hintText, isKeybindName)
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
function TabbedListButtonVertical:SetHintData(data)
  if data.isKeybind then
    self.ButtonHint:SetKeybindMapping(data.text)
  else
    self.ButtonHint:SetText(data.text)
  end
end
function TabbedListButtonVertical:SetHintPadding(value)
  self.hintPadding = value
end
function TabbedListButtonVertical:SetHintPosition()
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
function TabbedListButtonVertical:SetHintHighlightVisible(isVisible)
  self.isHintHighlightVisible = isVisible
  if UiElementBus.Event.IsEnabled(self.Properties.ButtonHint) then
    self.ButtonHint:SetHighlightVisible(isVisible)
  end
end
function TabbedListButtonVertical:SetIconPath(value)
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
function TabbedListButtonVertical:SetIconPosition()
  if self.buttonStyle == self.BUTTON_STYLE_1 then
    if self.isIconVisible then
      local iconWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.ButtonIconHolder)
      local iconPadding = 8
      local iconPositionY = 1
      local valuePositionY = -2
      self:SetIconPositionY(iconPositionY)
      self:SetIconValuePositionY(valuePositionY)
      if not self.isTextSet then
        self:SetIconPositionX(self.width / 2 + iconWidth / 2 - iconPadding)
        return
      end
      local textWidth = UiTextBus.Event.GetTextSize(self.Properties.ButtonText).x
      local textWidthDifference = self.width - textWidth
      local iconTextSpacing = 16
      local textPosX = 0
      iconWidth = iconWidth + iconTextSpacing
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
  elseif self.buttonStyle == self.BUTTON_STYLE_2 then
    self:SetIconPositionX(-30)
    if self.isIconVisible then
      local iconPositionY = 1
      local valuePositionY = -1
      if self.isIconValueSet then
        if self.isSecondaryTextSet then
          iconPositionY = 26
          valuePositionY = -25
        else
          iconPositionY = 14
          valuePositionY = -25
        end
        self:SetIconSize(40, 40)
      else
        if self.isSecondaryTextSet then
          iconPositionY = 12
        end
        self:SetIconSize(42, 42)
      end
      self:SetIconPositionY(iconPositionY)
      self:SetIconValuePositionY(valuePositionY)
    elseif self.isIconValueSet then
      self:SetIconPositionX(-31)
      if self.isSecondaryTextSet then
        self:SetIconPositionY(12)
        self:SetIconValuePositionY(-2)
      else
        self:SetIconPositionY(0)
        self:SetIconValuePositionY(-1)
      end
    end
  end
end
function TabbedListButtonVertical:SetIconColor(color)
  if color then
    self.iconColor = color
    UiImageBus.Event.SetColor(self.ButtonIconHolder, color)
  end
end
function TabbedListButtonVertical:SetIconValue(value)
  self.isIconValueSet = value ~= "" and value ~= nil
  if value then
    if not self.isIconVisible then
      UiElementBus.Event.SetIsEnabled(self.Properties.ButtonIconHolder, true)
      UiImageBus.Event.SetSpritePathname(self.Properties.ButtonIconHolder, "lyshineui/images/icon_blank.dds")
    end
    UiTextBus.Event.SetText(self.Properties.ButtonIconValue, tostring(value))
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonIconValue, true)
    self:SetIconValueOpacity(value)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonIconValue, false)
  end
  self:SetTextAlignment(self.textAlignment)
end
function TabbedListButtonVertical:SetIconSize(width, height)
  self.ScriptedEntityTweener:Set(self.Properties.ButtonIconHolder, {w = width, h = height})
end
function TabbedListButtonVertical:SetIconPositionX(value)
  self.ScriptedEntityTweener:Set(self.Properties.ButtonIconHolder, {x = value})
end
function TabbedListButtonVertical:SetIconPositionY(value)
  self.ScriptedEntityTweener:Set(self.Properties.ButtonIconHolder, {y = value})
end
function TabbedListButtonVertical:SetIconValuePositionY(value)
  self.ScriptedEntityTweener:Set(self.Properties.ButtonIconValue, {y = value})
end
function TabbedListButtonVertical:SetHintPositionX(value)
  self.ScriptedEntityTweener:Set(self.Properties.ButtonHint, {x = value})
end
function TabbedListButtonVertical:SetUserData(userData)
  self.userData = userData
  self.ScriptedEntityTweener:Set(self.Properties.ButtonFocus, {opacity = 0})
  self:SetText(userData.title)
  self:SetUnreadNumber(userData.newPageCount and userData.newPageCount or 0)
end
function TabbedListButtonVertical:SetUnreadNumber(number)
  self:SetIsNew(0 < number)
end
function TabbedListButtonVertical:SetIsNew(isNew)
  self.isNew = isNew
  if self.isNew then
    self:SetTextColor(self.UIStyle.COLOR_WHITE)
  else
    self.textColor = self.UIStyle.COLOR_TAN_HEADER_SECONDARY
  end
  local opacity = isNew and 1 or 0
  self.ScriptedEntityTweener:Set(self.Properties.NewText, {opacity = opacity})
end
function TabbedListButtonVertical:GetUserData()
  return self.userData
end
function TabbedListButtonVertical:SetIsVisible(isVisible)
  self.isVisible = isVisible
end
function TabbedListButtonVertical:AddToRadioGroup(groupEntityId)
  UiRadioButtonGroupBus.Event.AddRadioButton(groupEntityId, self.entityId)
end
function TabbedListButtonVertical:RemoveFromRadioGroup(groupEntityId)
  UiRadioButtonGroupBus.Event.RemoveRadioButton(groupEntityId, self.entityId)
end
function TabbedListButtonVertical:SetSoundOnFocus(value)
  self.soundOnFocus = value
end
function TabbedListButtonVertical:SetSoundOnPress(value)
  self.soundOnPress = value
end
function TabbedListButtonVertical:OnFocus()
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
    ease = "QuadOut",
    onComplete = function()
      self.timeline:Play()
    end
  })
  self.audioHelper:PlaySound(self.soundOnFocus)
  self:ExecuteCallback(self.focusTable, self.focusCallback)
end
function TabbedListButtonVertical:OnUnfocus()
  if self.isUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  end
  local buttonState = UiRadioButtonBus.Event.GetState(self.entityId)
  if buttonState ~= true then
    self:OnUnselected()
  end
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocusGlow, 0.15, {opacity = 0, ease = "QuadIn"})
  self:ExecuteCallback(self.unfocusTable, self.unfocusCallback)
end
function TabbedListButtonVertical:OnUnselected()
  local animDuration1 = 0.15
  local textColor = self.isWarning and self.UIStyle.COLOR_RED_MEDIUM or self.textColor
  local secondaryTextColor = self.isWarning and self.UIStyle.COLOR_RED_MEDIUM or self.secondaryTextColor
  self.ScriptedEntityTweener:Play(self.Properties.ButtonText, animDuration1, {textColor = textColor})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonSecondaryText, animDuration1, {textColor = secondaryTextColor})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration1, {opacity = 0, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFrameUnselected, animDuration1, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFrameSelectedTop, animDuration1, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFrameSelectedBottom, animDuration1, {opacity = 0, ease = "QuadOut"})
  if self.isIconVisible then
    local iconColor = self.UIStyle.COLOR_WHITE
    if self.isWarning then
      iconColor = self.UIStyle.COLOR_RED_MEDIUM
    elseif self.iconColor then
      iconColor = self.iconColor
    end
    self.ScriptedEntityTweener:Play(self.Properties.ButtonIconHolder, animDuration1, {imgColor = iconColor, ease = "QuadOut"})
  end
  if UiElementBus.Event.IsEnabled(self.Properties.ButtonHint) then
    self.ButtonHint:OnUnfocus()
  end
end
function TabbedListButtonVertical:OnSelected()
  if not self.isEnabled then
    return
  end
  if self.isUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  end
  self:OnSelect()
  self.audioHelper:PlaySound(self.soundOnPress)
end
function TabbedListButtonVertical:OnSelect(onlyVisual)
  if not self.isEnabled then
    return
  end
  local animDuration1 = 0.1
  local textColor = self.isWarning and self.UIStyle.COLOR_RED_MEDIUM or self.UIStyle.COLOR_WHITE
  local secondaryTextColor = self.isWarning and self.UIStyle.COLOR_RED_MEDIUM or self.UIStyle.COLOR_WHITE
  self.ScriptedEntityTweener:Play(self.Properties.ButtonText, animDuration1, {textColor = textColor})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonSecondaryText, animDuration1, {textColor = secondaryTextColor})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocusGlow, animDuration1, {opacity = 0, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration1, {opacity = 1, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFrameSelectedTop, 0.25, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFrameSelectedBottom, 0.25, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFrameUnselected, animDuration1, {opacity = 0, ease = "QuadOut"})
  local iconColor = self.isWarning and self.UIStyle.COLOR_RED_MEDIUM or self.UIStyle.COLOR_WHITE
  if self.isIconVisible then
    self.ScriptedEntityTweener:Play(self.Properties.ButtonIconHolder, animDuration1, {imgColor = iconColor, ease = "QuadOut"})
  end
  if UiElementBus.Event.IsEnabled(self.Properties.ButtonHint) then
    self.ButtonHint:OnFocus()
  end
  self:ExecuteCallback(self.selectedTable, self.selectedCallback)
  if not onlyVisual then
    self:ExecuteCallback(self.pressTable, self.pressCallback)
  end
end
function TabbedListButtonVertical:ExecuteCallback(callbackTable, pressCallback)
  if type(pressCallback) == "function" and callbackTable ~= nil then
    pressCallback(callbackTable, self)
  end
end
function TabbedListButtonVertical:OnShutdown()
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
end
function TabbedListButtonVertical:SetEnabled(enabled)
  self.isEnabled = enabled
  if self.buttonStyle == self.BUTTON_STYLE_1 then
    if self.isEnabled == false then
      local animDuration = 0.3
      self:SetTextColor(self.UIStyle.COLOR_GRAY_30, animDuration)
    end
  elseif self.buttonStyle == self.BUTTON_STYLE_2 then
    local animDuration = 0.3
    if self.isEnabled == false then
      self:SetTextColor(self.UIStyle.COLOR_GRAY_30, animDuration)
      self:SetSecondaryTextColor(self.UIStyle.COLOR_GRAY_30, animDuration)
      if self.isIconVisible then
        self:SetIconColor(self.UIStyle.COLOR_GRAY_30)
      end
    else
      self:SetTextColor(self.UIStyle.COLOR_WHITE, animDuration)
      self:SetSecondaryTextColor(self.UIStyle.COLOR_TAN_LIGHT, animDuration)
      if self.isIconVisible then
        self:SetIconColor(self.UIStyle.COLOR_TAN)
      end
    end
  elseif self.buttonStyle == self.BUTTON_STYLE_3 then
    local animDuration = 0.3
    if self.isEnabled == false then
      self:SetTextColor(self.UIStyle.COLOR_GRAY_30, animDuration)
      self:SetSecondaryTextColor(self.UIStyle.COLOR_GRAY_30, animDuration)
      if self.isIconVisible then
        self:SetIconColor(self.UIStyle.COLOR_GRAY_30)
      end
    else
      self:SetTextColor(self.UIStyle.COLOR_TAN_HEADER_SECONDARY, animDuration)
      self:SetSecondaryTextColor(self.UIStyle.COLOR_TAN_LIGHT, animDuration)
      if self.isIconVisible then
        self:SetIconColor(self.UIStyle.COLOR_TAN)
      end
    end
  end
end
return TabbedListButtonVertical
