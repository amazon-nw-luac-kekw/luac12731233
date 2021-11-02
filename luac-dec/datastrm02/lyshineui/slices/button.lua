local Button = {
  Properties = {
    ButtonText = {
      default = EntityId()
    },
    ButtonTextPrefix = {
      default = EntityId()
    },
    ButtonBg = {
      default = EntityId()
    },
    ButtonFocus = {
      default = EntityId()
    },
    ButtonFocusGlow = {
      default = EntityId()
    },
    HeroImageSequence = {
      default = EntityId()
    },
    HeroImageSequenceDisabled = {
      default = EntityId()
    },
    HeroBorder = {
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
    ButtonSecondaryIconHolder = {
      default = EntityId()
    },
    ButtonSecondaryIconValue = {
      default = EntityId()
    },
    ButtonSecondarySprite = {
      default = EntityId()
    },
    ButtonTooltipSetter = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    Spinner = {
      default = EntityId()
    }
  },
  BUTTON_STYLE_DEFAULT = 1,
  BUTTON_STYLE_CTA = 2,
  BUTTON_STYLE_BLOCKED = 3,
  BUTTON_STYLE_TWITCH = 4,
  BUTTON_STYLE_HERO = 5,
  BUTTON_STYLE_DIALOGUE = 6,
  mButtonStyle = nil,
  BUTTON_FRAME_PATH = "lyshineui/images/slices/button/primarybuttonframe.dds",
  BUTTON_FRAME_HERO_PATH = "lyshineui/images/slices/button/heroframe.dds",
  BUTTON_FRAME_HERO_DISABLED_PATH = "lyshineui/images/slices/button/heroframedisabled.dds",
  BUTTON_GLOW_PATH = "lyshineui/images/slices/button/buttonFocusGlow.dds",
  BUTTON_BG_HERO_PATH = "lyshineui/images/slices/button/herobg.dds",
  BUTTON_BG_HERO_DISABLED_PATH = "lyshineui/images/slices/button/herobgdisabled.dds",
  BUTTON_HERO_BORDER_PATH = "lyshineui/images/slices/button/heroborder.dds",
  TEXT_ALIGN_LEFT = eUiHAlign_Left,
  TEXT_ALIGN_CENTER = eUiHAlign_Center,
  TEXT_ALIGN_RIGHT = eUiHAlign_Right,
  mTextAlignment = 1,
  mSoundOnFocus = nil,
  mSoundOnPress = nil,
  mSoundSwitchMusicDB = nil,
  mSoundOnMixStateChanged = nil,
  mSoundOnUIStateChanged = nil,
  mButtonSecondaryIcon = nil,
  mAnimPositionDuration = 0.3,
  mWidth = 100,
  mHeight = 30,
  mIndex = nil,
  mIsSelected = false,
  mPressCallback = nil,
  mPressTable = nil,
  mFocusCallback = nil,
  mFocusTable = nil,
  mUnfocusCallback = nil,
  mUnfocusTable = nil,
  mIsUsingTooltip = false,
  mIsIconVisible = false,
  mIsSecondaryIconVisible = false,
  mTextInitPosX = nil,
  mIsHintHighlightVisible = false,
  mHintPadding = 18,
  mDialoguePadding = 30,
  mMultilineMinHeight = 54,
  mMultilinePaddingX = 30,
  mMultilinePaddingY = 20,
  mSpaceForTextPrefix = 24,
  mSizedToText = false,
  mTextSizedToButton = false,
  mTextSizePadding = 20,
  autoSizePadding = 50,
  spinnerIconPath = "lyshineui/images/frontend/image_loading_spinner.dds"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(Button)
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
function Button:OnInit()
  BaseElement.OnInit(self)
  self.dataLayer = dataLayer
  SetTextStyle(self.ButtonText, self.UIStyle.FONT_STYLE_BUTTON)
  SetTextStyle(self.ButtonTextPrefix, self.UIStyle.FONT_STYLE_BUTTON_PREFIX)
  self.mIsEnabled = true
  self.textColor = self.UIStyle.COLOR_TAN
  self.mWidth = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.mHeight = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  self:SetSize(self.mWidth, self.mHeight)
  self:SetButtonStyle(self.BUTTON_STYLE_DEFAULT)
  self.mSoundOnFocus = self.audioHelper.OnHover_ButtonSimpleText
  self.mSoundOnPress = self.audioHelper.Accept
  UiElementBus.Event.SetIsEnabled(self.ButtonSecondaryIconHolder, false)
  if self.ButtonSecondaryIconValue ~= nil then
    UiElementBus.Event.SetIsEnabled(self.ButtonSecondaryIconValue, false)
  end
  if self.mSizedToText then
    self:SizeToText()
  end
end
function Button:SetCallback(command, table)
  self.mPressCallback = command
  self.mPressTable = table
end
function Button:SetFocusCallback(command, table)
  self.mFocusCallback = command
  self.mFocusTable = table
end
function Button:SetUnfocusCallback(command, table)
  self.mUnfocusCallback = command
  self.mUnfocusTable = table
end
function Button:SetButtonStyle(style)
  self.mButtonStyle = style
  UiElementBus.Event.SetIsEnabled(self.Properties.HeroImageSequence, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.HeroImageSequenceDisabled, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.HeroBorder, false)
  self:StartStopImageSequence(false)
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonFocusGlow, true)
  UiImageBus.Event.SetSpritePathname(self.Properties.Frame, self.BUTTON_FRAME_PATH)
  if self.mButtonStyle == self.BUTTON_STYLE_DEFAULT then
    self.ScriptedEntityTweener:Set(self.Properties.ButtonBg, {
      opacity = 1,
      imgColor = self.UIStyle.COLOR_DARKER_ORANGE
    })
    self.ScriptedEntityTweener:Set(self.Properties.ButtonFocus, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.ButtonFocusGlow, {opacity = 0})
    self:SetLineColor(self.UIStyle.COLOR_MEDIUM_ORANGE_UNFOCUSED)
    self:SetGlowColor(self.UIStyle.COLOR_BRIGHT_ORANGE)
    SetTextStyle(self.Properties.ButtonText, self.UIStyle.FONT_STYLE_BUTTON)
  elseif self.mButtonStyle == self.BUTTON_STYLE_CTA then
    self.ScriptedEntityTweener:Set(self.Properties.ButtonBg, {
      opacity = 1,
      imgColor = self.UIStyle.COLOR_DARK_ORANGE
    })
    self.ScriptedEntityTweener:Set(self.Properties.ButtonFocus, {opacity = 0.1})
    self.ScriptedEntityTweener:Set(self.Properties.ButtonFocusGlow, {opacity = 0.4})
    self:SetLineColor(self.UIStyle.COLOR_MEDIUM_ORANGE_UNFOCUSED)
    self:SetGlowColor(self.UIStyle.COLOR_BRIGHT_ORANGE)
    SetTextStyle(self.Properties.ButtonText, self.UIStyle.FONT_STYLE_BUTTON)
  elseif self.mButtonStyle == self.BUTTON_STYLE_BLOCKED then
    self.ScriptedEntityTweener:Set(self.Properties.ButtonBg, {
      opacity = 0.8,
      imgColor = self.UIStyle.COLOR_RED_BLOCKED
    })
    self.ScriptedEntityTweener:Set(self.Properties.ButtonFocus, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.ButtonFocusGlow, {opacity = 0})
    self:SetLineColor(self.UIStyle.COLOR_RED_BLOCKED_BRIGHT)
    SetTextStyle(self.Properties.ButtonText, self.UIStyle.FONT_STYLE_BUTTON_BLOCKED)
  elseif self.mButtonStyle == self.BUTTON_STYLE_TWITCH then
    self.ScriptedEntityTweener:Set(self.Properties.ButtonBg, {
      opacity = 1,
      imgColor = self.UIStyle.COLOR_TWITCH_PURPLE_DARK
    })
    self.ScriptedEntityTweener:Set(self.Properties.ButtonFocus, {opacity = 0.1})
    self.ScriptedEntityTweener:Set(self.Properties.ButtonFocusGlow, {opacity = 0.4})
    self:SetLineColor(self.UIStyle.COLOR_TWITCH_PURPLE)
    self:SetGlowColor(self.UIStyle.COLOR_TWITCH_PURPLE)
    SetTextStyle(self.Properties.ButtonText, self.UIStyle.FONT_STYLE_BUTTON)
  elseif self.mButtonStyle == self.BUTTON_STYLE_HERO then
    UiImageBus.Event.SetSpritePathname(self.Properties.Frame, self.BUTTON_FRAME_HERO_PATH)
    UiImageBus.Event.SetSpritePathname(self.Properties.HeroBorder, self.BUTTON_HERO_BORDER_PATH)
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonFocusGlow, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.HeroImageSequence, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.HeroImageSequenceDisabled, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.HeroBorder, true)
    local imageSequenceAlpha = 0.8
    self.ScriptedEntityTweener:Set(self.Properties.ButtonBg, {
      opacity = 1,
      imgColor = self.UIStyle.COLOR_BLACK
    })
    self.ScriptedEntityTweener:Set(self.Properties.ButtonFocus, {opacity = 0.1})
    self.ScriptedEntityTweener:Set(self.Properties.HeroImageSequence, {opacity = imageSequenceAlpha})
    self.ScriptedEntityTweener:Set(self.Properties.HeroImageSequenceDisabled, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.HeroBorder, {opacity = 0})
    self:SetLineColor(self.UIStyle.COLOR_WHITE)
    SetTextStyle(self.Properties.ButtonText, self.UIStyle.FONT_STYLE_BUTTON_HERO)
    self:StartStopImageSequence(true)
  elseif self.mButtonStyle == self.BUTTON_STYLE_DIALOGUE then
    self.ScriptedEntityTweener:Set(self.Properties.ButtonBg, {
      opacity = 1,
      imgColor = self.UIStyle.COLOR_DARKER_ORANGE
    })
    self.ScriptedEntityTweener:Set(self.Properties.ButtonFocus, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.ButtonFocusGlow, {opacity = 0})
    local alpha = 0.6
    self:SetLineColor(self.UIStyle.COLOR_MEDIUM_ORANGE)
    self:SetLineAlpha(alpha)
    self:SetGlowColor(self.UIStyle.COLOR_BRIGHT_ORANGE)
    SetTextStyle(self.Properties.ButtonText, self.UIStyle.FONT_STYLE_BUTTON_DIALOGUE)
    SetTextStyle(self.Properties.ButtonTextPrefix, self.UIStyle.FONT_STYLE_BUTTON_DIALOGUE_PREFIX)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.ButtonTextPrefix, 0)
    self:SetTextAlignment(self.TEXT_ALIGN_LEFT)
    self:SetIsMultiline(true)
    UiImageBus.Event.SetImageType(self.Properties.ButtonSecondaryIconHolder, eUiImageType_StretchedToFit)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.ButtonSecondaryIconHolder, 28)
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.ButtonSecondaryIconHolder, 28)
    self.dialogDefaultTextSize = UiTextBus.Event.GetTextHeight(self.Properties.ButtonText)
  end
end
function Button:GetButtonStyle()
  return self.mButtonStyle
end
function Button:SetHeroPulseActive(isPulsing)
  self.isHeroPulseActive = isPulsing
  if self.mButtonStyle == self.BUTTON_STYLE_HERO and isPulsing then
    if not self.timelineHeroPulse then
      self.timelineHeroPulse = self.ScriptedEntityTweener:TimelineCreate()
      self.timelineHeroPulse:Add(self.Properties.HeroBorder, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
      self.timelineHeroPulse:Add(self.Properties.HeroBorder, self.UIStyle.DURATION_TIMELINE_HOLD, {opacity = 1})
      self.timelineHeroPulse:Add(self.Properties.HeroBorder, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {
        opacity = 0.3,
        onComplete = function()
          self.timelineHeroPulse:Play()
        end
      })
    end
    self.timelineHeroPulse:Play()
  else
    self.ScriptedEntityTweener:Play(self.Properties.HeroBorder, 0.15, {opacity = 0, ease = "QuadIn"})
  end
end
function Button:SetSize(width, height)
  self.mWidth = width
  self.mHeight = height
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.mWidth)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.mHeight)
end
function Button:GetWidth()
  return self.mWidth
end
function Button:GetHeight()
  return self.mHeight
end
function Button:SetText(value, skipLocalization)
  if skipLocalization then
    UiTextBus.Event.SetText(self.Properties.ButtonText, value)
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.ButtonText, value, eUiTextSet_SetLocalized)
  end
  self:SetTextAlignment(self.mTextAlignment)
  if UiElementBus.Event.IsEnabled(self.Properties.ButtonHint) then
    self:SetHintPosition()
  end
  if self.mIsMultiline then
    local height = math.max(self.mMultilineMinHeight, self.mMultilinePaddingY + UiTextBus.Event.GetTextHeight(self.Properties.ButtonText))
    self:SetSize(self.mWidth, height)
  end
end
function Button:GetText()
  return UiTextBus.Event.GetText(self.ButtonText)
end
function Button:SizeToText()
  self.mSizedToText = true
  self.mTextSizedToButton = false
  UiTextBus.Event.SetShrinkToFit(self.Properties.ButtonText, eUiTextShrinkToFit_None)
  UiLayoutFitterBus.Event.SetHorizontalFit(self.Properties.ButtonText, true)
  local textWidth = UiTextBus.Event.GetTextWidth(self.Properties.ButtonText)
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, textWidth + self.autoSizePadding)
end
function Button:SizeTextToButton(padding)
  self.mSizedToText = false
  self.mTextSizedToButton = true
  if not self.mIsMultiline then
    UiTextBus.Event.SetShrinkToFit(self.Properties.ButtonText, eUiTextShrinkToFit_Uniform)
  end
  UiLayoutFitterBus.Event.SetHorizontalFit(self.Properties.ButtonText, false)
  self.mTextSizePadding = padding or self.mTextSizePadding
  local finalTextWidth = self.mWidth - self.mTextSizePadding
  if self.showingTextPrefix then
    finalTextWidth = finalTextWidth - self.mSpaceForTextPrefix
  end
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.ButtonText, finalTextWidth)
  self:SetTextAlignment(self.mTextAlignment)
end
function Button:SetIsMarkupEnabled(value)
  UiTextBus.Event.SetIsMarkupEnabled(self.Properties.ButtonText, value)
end
function Button:SetIsMultiline(value)
  self.mIsMultiline = value
  self.mMultilineMinHeight = self.mHeight
  if self.mIsMultiline then
    UiTextBus.Event.SetWrapText(self.Properties.ButtonText, self.UIStyle.TEXT_WRAP_SETTING_WRAP)
    self:SizeTextToButton(self.mMultilinePaddingX)
  else
    UiTextBus.Event.SetWrapText(self.Properties.ButtonText, self.UIStyle.TEXT_WRAP_SETTING_NO_WRAP)
  end
  self:SetTextAlignment(self.mTextAlignment)
end
function Button:SetTextAlignment(value)
  if not self.mIsMultiline then
    local enumAlign
    local textPadding = self.mButtonStyle == self.BUTTON_STYLE_DIALOGUE and self.mDialoguePadding or 15
    local textWidth = UiTextBus.Event.GetTextSize(self.ButtonText).x
    local textWidthDifference = self.mWidth - textWidth
    local textPosX
    if value == self.TEXT_ALIGN_LEFT then
      enumAlign = value
      textPosX = -textWidthDifference / 2 + textPadding
      if self.showingTextPrefix then
        textPosX = textPosX + self.mSpaceForTextPrefix
      end
      self.savedTextOffset = textPosX
    elseif value == self.TEXT_ALIGN_CENTER then
      enumAlign = value
      textPosX = 0
    elseif value == self.TEXT_ALIGN_RIGHT then
      enumAlign = value
      textPosX = textWidthDifference / 2 - textPadding
    end
    if enumAlign ~= nil then
      self.mTextAlignment = enumAlign
      self.mTextInitPosX = textPosX
      self.ScriptedEntityTweener:Play(self.ButtonText, self.mAnimPositionDuration, {x = textPosX, ease = "QuadOut"})
      if self.mIsIconVisible then
        self:SetIconPosition()
      end
      if self.mIsSecondaryIconVisible then
        self:SetSecondaryIconPosition()
      end
    end
  elseif value ~= nil then
    self.mTextAlignment = value
    self.mTextInitPosX = 0
    UiTextBus.Event.SetHorizontalTextAlignment(self.Properties.ButtonText, value)
    if self.mIsIconVisible then
      self:SetIconPosition()
    elseif self.mIsSecondaryIconVisible then
      self:SetSecondaryIconPosition()
    else
      UiTransformBus.Event.SetLocalPositionX(self.Properties.ButtonText, 0)
    end
  end
end
function Button:GetTextAlignment()
  return self.mTextAlignment
end
function Button:SetTextColor(color, duration)
  local defaultDuration = 0.3
  local animDuration = duration ~= nil and duration or defaultDuration
  self.textColor = color
  self.ScriptedEntityTweener:Play(self.ButtonText, animDuration, {textColor = color, ease = "QuadOut"})
end
function Button:GetTextColor()
  return UiTextBus.Event.GetColor(self.ButtonText)
end
function Button:SetFontSize(value)
  UiTextBus.Event.SetFontSize(self.ButtonText, value)
end
function Button:GetFontSize(value)
  UiTextBus.Event.GetFontSize(self.ButtonText, value)
end
function Button:SetCharacterSpacing(value)
  UiTextBus.Event.SetCharacterSpacing(self.ButtonText, value)
end
function Button:GetCharacterSpacing()
  return UiTextBus.Event.GetCharacterSpacing(self.ButtonText)
end
function Button:SetTextCasing(value)
  UiTextBus.Event.SetTextCase(self.ButtonText, value)
end
function Button:GetTextCasing()
  return UiTextBus.Event.GetTextCase(self.ButtonText)
end
function Button:SetTextStyle(value)
  SetTextStyle(self.ButtonText, value)
end
function Button:SetTextPrefixStyle(value)
  SetTextStyle(self.ButtonTextPrefix, value)
end
function Button:SetTextPrefix(value)
  local showingTextPrefix = value ~= nil
  if self.showingTextPrefix ~= showingTextPrefix then
    self.showingTextPrefix = showingTextPrefix
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTextPrefix, self.showingTextPrefix)
    self:SetIsMultiline(self.mIsMultiline)
  end
  UiTextBus.Event.SetText(self.ButtonTextPrefix, value)
end
function Button:GetTextPrefix()
  return UiTextBus.Event.GetText(self.ButtonTextPrefix)
end
function Button:SetIndex(index)
  self.mIndex = index
end
function Button:GetIndex(index)
  return self.mIndex
end
function Button:SetIsSelected(isSelected)
  self.mIsSelected = isSelected
end
function Button:SetGlowColor(color)
  UiImageBus.Event.SetColor(self.Properties.ButtonFocusGlow, color)
end
function Button:SetTooltip(value)
  if value == nil or value == "" then
    self.mIsUsingTooltip = false
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, false)
  else
    self.mIsUsingTooltip = true
    if type(value) == "string" then
      self.ButtonTooltipSetter:SetSimpleTooltip(value)
    else
      self.ButtonTooltipSetter:SetTooltipInfo(value)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, true)
  end
end
function Button:SetHint(hintText, isKeybindName, actionMap)
  local data = {
    text = hintText,
    isKeybind = isKeybindName,
    actionMap = actionMap
  }
  self:SetHintData(data)
  if hintText then
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonHint, true)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonHint, false)
    self:SetTextAlignment(self.mTextAlignment)
  end
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ButtonHint, false)
  self:SetHintPosition()
  self:SetSecondaryIconPosition()
  if self.mIsHintHighlightVisible then
    self:SetHintHighlightVisible(self.mIsHintHighlightVisible)
  end
  local hintKeybindMapping = self.ButtonHint:GetKeybindMapping()
  if hintKeybindMapping ~= nil then
    local actionMap = actionMap or "ui"
    self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Keybind." .. hintKeybindMapping .. "." .. actionMap, function(self, data)
      self:SetHintPosition()
      self:SetSecondaryIconPosition()
    end)
  end
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Keybind.Reset", function(self, data)
    self:SetHintPosition()
    self:SetSecondaryIconPosition()
  end)
end
function Button:SetHintData(data)
  if data.isKeybind then
    self.ButtonHint:SetActionMap(data.actionMap)
    self.ButtonHint:SetKeybindMapping(data.text)
  else
    self.ButtonHint:SetText(data.text)
  end
end
function Button:SetHintPadding(value)
  self.mHintPadding = value
end
function Button:SetHintPosition()
  local textPosX = 0
  local hintPosX = 0
  local textWidth = UiTextBus.Event.GetTextSize(self.ButtonText).x
  local textWidthDifference = self.mWidth - textWidth
  local hintWidth = self.ButtonHint:GetWidth()
  local initHintWidth = 34
  local initHintPosX = -5
  local hintPadding = self.mHintPadding
  if self.mButtonStyle == self.BUTTON_STYLE_DIALOGUE then
    hintPosX = initHintPosX - (hintWidth - initHintWidth)
  elseif self.mTextAlignment == self.TEXT_ALIGN_LEFT then
    textPosX = -textWidthDifference / 2 + (hintWidth + hintPadding)
    hintPosX = initHintPosX - (hintWidth - initHintWidth)
    if self.showingTextPrefix then
      textPosX = textPosX + self.mSpaceForTextPrefix
    end
  elseif self.mTextAlignment == self.TEXT_ALIGN_CENTER then
    textPosX = (hintWidth - initHintPosX) / 2
    hintPosX = initHintPosX - (hintWidth - initHintWidth)
  elseif self.mTextAlignment == self.TEXT_ALIGN_RIGHT then
    textPosX = textWidthDifference / 2 - (hintWidth + hintPadding)
    hintPosX = textWidth + (initHintPosX + initHintWidth + hintPadding)
  end
  if self.showingTextPrefix then
    hintPosX = hintPosX - self.mSpaceForTextPrefix
  end
  self.mTextInitPosX = textPosX
  self.ScriptedEntityTweener:Play(self.ButtonText, self.mAnimPositionDuration, {x = textPosX, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.ButtonHintHolder, self.mAnimPositionDuration, {x = hintPosX, ease = "QuadOut"})
end
function Button:SetHintHighlightVisible(isVisible)
  self.mIsHintHighlightVisible = isVisible
  if UiElementBus.Event.IsEnabled(self.Properties.ButtonHint) then
    self.ButtonHint:SetHighlightVisible(isVisible)
  end
end
function Button:SetIconPath(value, noPositionChange)
  if value then
    if not self.mIsIconVisible then
      self.mIsIconVisible = true
      UiElementBus.Event.SetIsEnabled(self.ButtonIconHolder, true)
      self.ScriptedEntityTweener:Set(self.ButtonIconHolder, {opacity = 1})
    end
    UiImageBus.Event.SetSpritePathname(self.ButtonIconHolder, value)
  else
    self.mIsIconVisible = false
    UiElementBus.Event.SetIsEnabled(self.ButtonIconHolder, false)
    self.ScriptedEntityTweener:Set(self.ButtonIconHolder, {opacity = 0})
  end
  if noPositionChange == nil then
    noPositionChange = false
  end
  if not noPositionChange then
    self:SetIconPosition()
  end
end
function Button:SetIconPosition()
  if self.mIsIconVisible then
    local iconTextSpacing = 10
    local iconWidth = UiTransform2dBus.Event.GetLocalWidth(self.ButtonIconHolder) + iconTextSpacing
    local iconPadding = 8
    local textPosX = 0
    if self.mTextSizedToButton then
      local totalIconSpace = iconWidth + iconPadding
      UiTransform2dBus.Event.SetLocalWidth(self.Properties.ButtonText, self.mWidth - self.mTextSizePadding - totalIconSpace)
      textPosX = totalIconSpace / 2
    else
      local textWidth = UiTextBus.Event.GetTextSize(self.ButtonText).x
      local textWidthDifference = self.mWidth - textWidth
      if not self.mTextSizedToButton then
        if self.mTextAlignment == self.TEXT_ALIGN_LEFT then
          textPosX = -textWidthDifference / 2 + (iconWidth + iconPadding)
        elseif self.mTextAlignment == self.TEXT_ALIGN_CENTER then
          textPosX = iconWidth / 2
        elseif self.mTextAlignment == self.TEXT_ALIGN_RIGHT then
          textPosX = textWidthDifference / 2 - iconWidth
          local hintPosX = textWidth + iconWidth / 2
          self.ScriptedEntityTweener:Set(self.ButtonIconHolder, {x = hintPosX})
        end
      end
    end
    self.ScriptedEntityTweener:Set(self.ButtonText, {x = textPosX})
  else
    self:SetTextAlignment(self.mTextAlignment)
  end
end
function Button:SetIconColor(color)
  if color then
    UiImageBus.Event.SetColor(self.ButtonIconHolder, color)
  end
end
function Button:SetIconValue(value)
  if self.ButtonIconValue == nil then
    return
  end
  if value then
    UiTextBus.Event.SetText(self.ButtonIconValue, tostring(value))
    UiElementBus.Event.SetIsEnabled(self.ButtonIconValue, true)
  else
    UiElementBus.Event.SetIsEnabled(self.ButtonIconValue, false)
  end
end
function Button:SetSecondaryIconPath(value, isSpriteSheet)
  self.mButtonSecondaryIcon = isSpriteSheet and self.ButtonSecondarySprite or self.ButtonSecondaryIconHolder
  if value then
    if not self.mIsSecondaryIconVisible then
      self.mIsSecondaryIconVisible = true
      UiElementBus.Event.SetIsEnabled(self.mButtonSecondaryIcon, true)
      self.ScriptedEntityTweener:Play(self.mButtonSecondaryIcon, self.mAnimPositionDuration, {scaleX = 0, scaleY = 0}, {
        scaleX = 1,
        scaleY = 1,
        ease = "QuadOut"
      })
      self.ScriptedEntityTweener:Play(self.mButtonSecondaryIcon, self.mAnimPositionDuration, {opacity = 1, ease = "QuadOut"})
      if isSpriteSheet then
        UiFlipbookAnimationBus.Event.SetCurrentFrame(self.mButtonSecondaryIcon, 0)
        UiFlipbookAnimationBus.Event.Start(self.mButtonSecondaryIcon)
      end
    end
    UiImageBus.Event.SetSpritePathname(self.mButtonSecondaryIcon, value)
  else
    self.mIsSecondaryIconVisible = false
    self.ScriptedEntityTweener:Play(self.mButtonSecondaryIcon, self.mAnimPositionDuration, {
      scaleX = 0,
      scaleY = 0,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.mButtonSecondaryIcon, self.mAnimPositionDuration / 2, {opacity = 0, ease = "QuadOut"})
    if isSpriteSheet then
      UiFlipbookAnimationBus.Event.Stop(self.mButtonSecondaryIcon)
    end
  end
  self:SetSecondaryIconPosition()
end
function Button:SetSecondaryIconPosition()
  if self.mIsSecondaryIconVisible then
    local iconTextSpacing = 10
    local iconWidth = UiTransform2dBus.Event.GetLocalWidth(self.ButtonSecondaryIconHolder)
    local textOffsetX = iconWidth + iconTextSpacing + self.mTextInitPosX
    local iconX = -27
    if self.showingTextPrefix then
      textOffsetX = textOffsetX + self.mSpaceForTextPrefix / 2
      iconX = iconX - self.mSpaceForTextPrefix
    end
    if UiElementBus.Event.IsEnabled(self.Properties.ButtonHint) then
      local hintOffsetX = self.ButtonHint:GetWidth() + iconTextSpacing * 2
      if self.showingTextPrefix then
        hintOffsetX = hintOffsetX + self.mSpaceForTextPrefix
      end
      self.ScriptedEntityTweener:Play(self.ButtonHintHolder, self.mAnimPositionDuration, {
        x = -hintOffsetX,
        ease = "QuadOut"
      })
    end
    if self.mTextSizedToButton then
      local totalIconSpace = iconWidth + iconTextSpacing
      if self.showingTextPrefix then
        totalIconSpace = totalIconSpace + self.mSpaceForTextPrefix
      end
      UiTransform2dBus.Event.SetLocalWidth(self.Properties.ButtonText, self.mWidth - self.mTextSizePadding - totalIconSpace)
    end
    self.ScriptedEntityTweener:Play(self.Properties.ButtonText, self.mAnimPositionDuration, {x = textOffsetX, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonSecondaryIconHolder, self.mAnimPositionDuration, {x = iconX, ease = "QuadOut"})
  elseif UiElementBus.Event.IsEnabled(self.Properties.ButtonHint) then
    self:SetHintPosition()
  else
    self:SetTextAlignment(self.mTextAlignment)
  end
end
function Button:SetSecondaryIconColor(color)
  if color and self.mButtonSecondaryIcon then
    UiImageBus.Event.SetColor(self.mButtonSecondaryIcon, color)
  end
end
function Button:SetSecondaryIconValue(value)
  if self.ButtonSecondaryIconValue == nil then
    return
  end
  if value then
    UiTextBus.Event.SetText(self.ButtonSecondaryIconValue, tostring(value))
    UiElementBus.Event.SetIsEnabled(self.ButtonSecondaryIconValue, true)
  else
    UiElementBus.Event.SetIsEnabled(self.ButtonSecondaryIconValue, false)
  end
end
function Button:SetIconPositionX(value)
  self.ScriptedEntityTweener:Set(self.ButtonIconHolder, {x = value})
end
function Button:SetHintPositionX(value)
  self.ScriptedEntityTweener:Set(self.Properties.ButtonHint, {x = value})
end
function Button:SetBlockingSpinnerShowing(isShowing)
  if not self.Spinner or not self.Spinner:IsValid() then
    return
  end
  self.mIsSpinning = isShowing
  UiElementBus.Event.SetIsEnabled(self.Properties.Spinner, isShowing)
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonText, not isShowing)
  UiImageBus.Event.SetSpritePathname(self.Properties.Spinner, self.spinnerIconPath)
  if isShowing then
    self.ScriptedEntityTweener:Play(self.Properties.Spinner, 2.5, {rotation = 0}, {timesToPlay = -1, rotation = 359})
  else
    self.ScriptedEntityTweener:Stop(self.Properties.Spinner)
    self.ScriptedEntityTweener:Set(self.Properties.Spinner, {rotation = 0})
  end
end
function Button:SetLineAlpha(alpha)
  self.ScriptedEntityTweener:Set(self.Properties.Frame, {opacity = alpha})
end
function Button:SetLineColor(color, duration, params)
  UiImageBus.Event.SetColor(self.Properties.Frame, color)
end
function Button:SetSoundOnFocus(value)
  self.mSoundOnFocus = value
end
function Button:SetSoundOnPress(value)
  self.mSoundOnPress = value
end
function Button:SetSwitchMusicDBOnPress(value)
  self.mSoundSwitchMusicDB = value
end
function Button:SetMixStateChangedOnPress(value)
  self.mSoundOnMixStateChanged = value
end
function Button:SetUIStateChangedOnPress(value)
  self.mSoundOnUIStateChanged = value
end
function Button:SetAnimPositionDuration(value)
  self.mAnimPositionDuration = value
end
function Button:StartStopImageSequence(start)
  if start then
    UiFlipbookAnimationBus.Event.Start(self.Properties.HeroImageSequence)
    UiFlipbookAnimationBus.Event.Start(self.Properties.HeroImageSequenceDisabled)
  else
    UiFlipbookAnimationBus.Event.Stop(self.Properties.HeroImageSequence)
    UiFlipbookAnimationBus.Event.Stop(self.Properties.HeroImageSequenceDisabled)
  end
end
function Button:OnFocus()
  if self.mIsUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverStart()
  end
  if not self.mIsEnabled or self.mIsSpinning then
    self:ExecuteCallback(self.mFocusTable, self.mFocusCallback)
    return
  end
  if self.mIsSelected then
    return
  end
  local animDuration1 = self.UIStyle.DURATION_BUTTON_FADE_IN
  local animDuration2 = 0.2
  local animDuration3 = 0.45
  local animDuration4 = 0.9
  local shouldAnimate = true
  local pulseBrightAlpha = 0.8
  local pulseDarkAlpha = 0.4
  if self.mButtonStyle == self.BUTTON_STYLE_DEFAULT or self.mButtonStyle == self.BUTTON_STYLE_DIALOGUE then
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration1, {opacity = 0.1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.Frame, animDuration1, {
      imgColor = self.UIStyle.COLOR_MEDIUM_ORANGE_FOCUSED,
      ease = "QuadOut"
    })
    pulseBrightAlpha = 0.4
    pulseDarkAlpha = 0.3
  elseif self.mButtonStyle == self.BUTTON_STYLE_CTA then
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration1, {opacity = 0.2, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.Frame, animDuration1, {
      imgColor = self.UIStyle.COLOR_MEDIUM_ORANGE_FOCUSED,
      ease = "QuadOut"
    })
    pulseBrightAlpha = 0.8
    pulseDarkAlpha = 0.6
  elseif self.mButtonStyle == self.BUTTON_STYLE_BLOCKED then
    shouldAnimate = false
  elseif self.mButtonStyle == self.BUTTON_STYLE_TWITCH then
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration1, {opacity = 0.2, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.Frame, animDuration1, {
      imgColor = self.UIStyle.COLOR_TWITCH_PURPLE_LIGHT,
      ease = "QuadOut"
    })
    pulseBrightAlpha = 0.8
    pulseDarkAlpha = 0.6
  elseif self.mButtonStyle == self.BUTTON_STYLE_HERO then
    shouldAnimate = false
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration1, {opacity = 0.2, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.HeroImageSequence, animDuration1, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.HeroBorder, animDuration3, {opacity = 1, ease = "QuadOut"})
  end
  if UiElementBus.Event.IsEnabled(self.Properties.ButtonHint) then
    self.ButtonHint:OnFocus()
  end
  if shouldAnimate then
    if not self.timeline then
      self.timeline = self.ScriptedEntityTweener:TimelineCreate()
      self.timeline:Add(self.Properties.ButtonFocusGlow, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = pulseDarkAlpha})
      self.timeline:Add(self.Properties.ButtonFocusGlow, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = pulseBrightAlpha})
      self.timeline:Add(self.Properties.ButtonFocusGlow, self.UIStyle.DURATION_TIMELINE_HOLD, {
        opacity = pulseBrightAlpha,
        onComplete = function()
          self.timeline:Play()
        end
      })
    end
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocusGlow, animDuration1, {opacity = pulseBrightAlpha, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocusGlow, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
      opacity = pulseBrightAlpha,
      delay = animDuration1,
      onComplete = function()
        self.timeline:Play()
      end
    })
  end
  self.audioHelper:PlaySound(self.mSoundOnFocus)
  self:ExecuteCallback(self.mFocusTable, self.mFocusCallback)
end
function Button:OnUnfocus()
  if self.mIsUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  end
  if not self.mIsEnabled or self.mIsSpinning then
    self:ExecuteCallback(self.mUnfocusTable, self.mUnfocusCallback)
    return
  end
  if self.mIsSelected == true then
    return
  end
  local animDuration1 = self.UIStyle.DURATION_BUTTON_FADE_OUT
  local animDuration2 = 0
  if self.mButtonStyle == self.BUTTON_STYLE_DEFAULT or self.mButtonStyle == self.BUTTON_STYLE_DIALOGUE then
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration1, {opacity = 0, ease = "QuadIn"})
    self.ScriptedEntityTweener:Play(self.Properties.Frame, animDuration1, {
      imgColor = self.UIStyle.COLOR_MEDIUM_ORANGE_UNFOCUSED,
      ease = "QuadIn"
    })
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocusGlow, animDuration1, {opacity = 0, ease = "QuadIn"})
  elseif self.mButtonStyle == self.BUTTON_STYLE_CTA then
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration1, {opacity = 0.1, ease = "QuadIn"})
    self.ScriptedEntityTweener:Play(self.Properties.Frame, animDuration1, {
      imgColor = self.UIStyle.COLOR_MEDIUM_ORANGE_UNFOCUSED,
      ease = "QuadIn"
    })
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocusGlow, animDuration1, {opacity = 0.4, ease = "QuadIn"})
  elseif self.mButtonStyle == self.BUTTON_STYLE_TWITCH then
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration1, {opacity = 0.1, ease = "QuadIn"})
    self.ScriptedEntityTweener:Play(self.Properties.Frame, animDuration1, {
      imgColor = self.UIStyle.COLOR_TWITCH_PURPLE,
      ease = "QuadIn"
    })
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocusGlow, animDuration1, {opacity = 0.4, ease = "QuadIn"})
  elseif self.mButtonStyle == self.BUTTON_STYLE_HERO then
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration1, {opacity = 0.1, ease = "QuadIn"})
    self.ScriptedEntityTweener:Play(self.Properties.HeroImageSequence, animDuration1, {opacity = 0.8, ease = "QuadIn"})
    local heroBorderOpacity = self.isHeroPulseActive and 0.3 or 0
    self.ScriptedEntityTweener:Play(self.Properties.HeroBorder, animDuration1, {
      opacity = heroBorderOpacity,
      ease = "QuadIn",
      onComplete = function()
        if self.isHeroPulseActive and self.timelineHeroPulse then
          self.timelineHeroPulse:Play()
        end
      end
    })
  end
  if UiElementBus.Event.IsEnabled(self.Properties.ButtonHint) then
    self.ButtonHint:OnUnfocus()
  end
  self:ExecuteCallback(self.mUnfocusTable, self.mUnfocusCallback)
end
function Button:OnSelect()
  if not self.mIsEnabled or self.mIsSpinning then
    return
  end
  local animDuration1 = 0.1
  local animDuration2 = 0
  if self.mButtonStyle == self.BUTTON_STYLE_DEFAULT then
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocusGlow, animDuration1, {opacity = 0, ease = "QuadIn"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration1, {opacity = 0, ease = "QuadIn"})
    self.ScriptedEntityTweener:Play(self.Properties.Frame, animDuration1, {
      imgColor = self.UIStyle.COLOR_MEDIUM_ORANGE_UNFOCUSED,
      ease = "QuadIn"
    })
  elseif self.mButtonStyle == self.BUTTON_STYLE_CTA then
    self.ScriptedEntityTweener:Play(self.ButtonFocusGlow, animDuration1, {opacity = 0.4, ease = "QuadIn"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration1, {opacity = 0.1, ease = "QuadIn"})
    self.ScriptedEntityTweener:Play(self.Properties.Frame, animDuration1, {
      imgColor = self.UIStyle.COLOR_MEDIUM_ORANGE_UNFOCUSED,
      ease = "QuadIn"
    })
  elseif self.mButtonStyle == self.BUTTON_STYLE_TWITCH then
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocusGlow, animDuration1, {opacity = 0.4, ease = "QuadIn"})
    self.ScriptedEntityTweener:Play(self.ButtonFocus, animDuration1, {opacity = 0.2, ease = "QuadIn"})
    self.ScriptedEntityTweener:Play(self.Properties.Frame, animDuration1, {
      opacity = 0.6,
      imgColor = self.UIStyle.COLOR_TWITCH_PURPLE,
      ease = "QuadIn"
    })
  elseif self.mButtonStyle == self.BUTTON_STYLE_HERO then
    self.ScriptedEntityTweener:Play(self.Properties.HeroBorder, animDuration1, {opacity = 0, ease = "QuadIn"})
    self.ScriptedEntityTweener:Play(self.Properties.HeroImageSequence, animDuration1, {opacity = 0.7, ease = "QuadIn"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration1, {opacity = 0.1, ease = "QuadIn"})
  end
  if UiElementBus.Event.IsEnabled(self.Properties.ButtonHint) then
    self.ButtonHint:OnFocus()
  end
  self:ExecuteCallback(self.mPressTable, self.mPressCallback)
end
function Button:OnPress()
  if not self.mIsEnabled or self.mIsSpinning then
    return
  end
  if self.mIsUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  end
  self:OnSelect()
  self.audioHelper:PlaySound(self.mSoundOnPress)
  if self.mSoundSwitchMusicDB then
    self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Gameplay, self.mSoundSwitchMusicDB)
  end
  if self.mSoundOnMixStateChanged then
    self.audioHelper:onMixStateChanged(self.mSoundOnMixStateChanged)
  end
  if self.mSoundOnUIStateChanged then
    self.audioHelper:onUIStateChanged(self.mSoundOnUIStateChanged)
  end
end
function Button:ExecuteCallback(scopeTable, pressCallback)
  if pressCallback ~= nil and scopeTable ~= nil then
    if type(pressCallback) == "function" then
      pressCallback(scopeTable, self)
    elseif type(scopeTable[pressCallback]) == "function" then
      scopeTable[pressCallback](scopeTable, self)
    end
  end
end
function Button:OnShutdown()
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
  self.dataLayer:UnregisterObservers(self)
end
function Button:SetEnabled(enabled, forceUpdate)
  if self.mIsEnabled == enabled and not forceUpdate then
    return
  end
  self.mIsEnabled = enabled
  local animDuration = 0.3
  if self.mButtonStyle == self.BUTTON_STYLE_DEFAULT then
    if self.mIsEnabled == false then
      self.ScriptedEntityTweener:Play(self.Properties.ButtonBg, animDuration, {
        opacity = 1,
        imgColor = self.UIStyle.COLOR_GRAY_DARK,
        ease = "QuadIn"
      })
      self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration, {opacity = 0, ease = "QuadIn"})
      self.ScriptedEntityTweener:Play(self.Properties.Frame, animDuration, {
        imgColor = self.UIStyle.COLOR_GRAY_MEDIUM_DARK,
        ease = "QuadIn"
      })
      self.ScriptedEntityTweener:Play(self.Properties.ButtonFocusGlow, animDuration, {opacity = 0, ease = "QuadIn"})
      self:SetTextColor(self.UIStyle.COLOR_GRAY_30, animDuration)
    else
      self.ScriptedEntityTweener:Play(self.Properties.ButtonBg, animDuration, {
        opacity = 1,
        imgColor = self.UIStyle.COLOR_DARKER_ORANGE,
        ease = "QuadOut"
      })
      self.ScriptedEntityTweener:Play(self.Properties.Frame, animDuration, {
        imgColor = self.UIStyle.COLOR_MEDIUM_ORANGE_UNFOCUSED,
        ease = "QuadOut"
      })
      self.ScriptedEntityTweener:Play(self.Properties.ButtonFocusGlow, animDuration, {opacity = 0, ease = "QuadIn"})
      self:SetTextColor(self.UIStyle.COLOR_WHITE, animDuration)
    end
  elseif self.mButtonStyle == self.BUTTON_STYLE_CTA then
    if self.mIsEnabled == false then
      if not self.mIsSpinning then
        self.ScriptedEntityTweener:Play(self.Properties.ButtonBg, animDuration, {
          opacity = 1,
          imgColor = self.UIStyle.COLOR_GRAY_DARK,
          ease = "QuadIn"
        })
        self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration, {opacity = 0, ease = "QuadIn"})
        self.ScriptedEntityTweener:Play(self.Properties.Frame, animDuration, {
          imgColor = self.UIStyle.COLOR_GRAY_MEDIUM_DARK,
          ease = "QuadIn"
        })
        self.ScriptedEntityTweener:Play(self.Properties.ButtonFocusGlow, animDuration, {opacity = 0, ease = "QuadIn"})
        self:SetTextColor(self.UIStyle.COLOR_GRAY_30, animDuration)
      end
    else
      self.ScriptedEntityTweener:Play(self.Properties.ButtonBg, animDuration, {
        opacity = 1,
        imgColor = self.UIStyle.COLOR_DARK_ORANGE,
        ease = "QuadOut"
      })
      self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration, {opacity = 0.1, ease = "QuadOut"})
      self.ScriptedEntityTweener:Play(self.Properties.Frame, animDuration, {
        imgColor = self.UIStyle.COLOR_MEDIUM_ORANGE_UNFOCUSED,
        ease = "QuadOut"
      })
      self.ScriptedEntityTweener:Play(self.Properties.ButtonFocusGlow, animDuration, {
        opacity = 0.4,
        imgColor = self.UIStyle.COLOR_BRIGHT_ORANGE,
        ease = "QuadOut"
      })
      self:SetTextColor(self.UIStyle.COLOR_WHITE, animDuration)
    end
  elseif self.mButtonStyle == self.BUTTON_STYLE_TWITCH then
    if self.mIsEnabled == false then
      self.ScriptedEntityTweener:Play(self.Properties.ButtonBg, animDuration, {
        opacity = 1,
        imgColor = self.UIStyle.COLOR_GRAY_DARK,
        ease = "QuadIn"
      })
      self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration, {opacity = 0, ease = "QuadIn"})
      self.ScriptedEntityTweener:Play(self.Properties.Frame, animDuration, {
        imgColor = self.UIStyle.COLOR_GRAY_MEDIUM_DARK,
        ease = "QuadIn"
      })
      self.ScriptedEntityTweener:Play(self.Properties.ButtonFocusGlow, animDuration, {opacity = 0, ease = "QuadIn"})
      self:SetTextColor(self.UIStyle.COLOR_GRAY_30, animDuration)
    else
      self.ScriptedEntityTweener:Play(self.Properties.ButtonBg, animDuration, {
        opacity = 1,
        imgColor = self.UIStyle.COLOR_TWITCH_PURPLE_DARK,
        ease = "QuadOut"
      })
      self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration, {opacity = 0.1, ease = "QuadOut"})
      self.ScriptedEntityTweener:Play(self.Properties.Frame, animDuration, {
        imgColor = self.UIStyle.COLOR_TWITCH_PURPLE,
        ease = "QuadOut"
      })
      self.ScriptedEntityTweener:Play(self.Properties.ButtonFocusGlow, animDuration, {
        opacity = 0.4,
        imgColor = self.UIStyle.COLOR_TWITCH_PURPLE,
        ease = "QuadOut"
      })
      self:SetTextColor(self.UIStyle.COLOR_WHITE, animDuration)
    end
  elseif self.mButtonStyle == self.BUTTON_STYLE_HERO then
    if self.mIsEnabled == false then
      self.ScriptedEntityTweener:Play(self.Properties.HeroImageSequence, animDuration, {opacity = 0, ease = "QuadIn"})
      self.ScriptedEntityTweener:Play(self.Properties.HeroImageSequenceDisabled, animDuration, {opacity = 1, ease = "QuadOut"})
      UiImageBus.Event.SetSpritePathname(self.Properties.Frame, self.BUTTON_FRAME_HERO_DISABLED_PATH)
      self.ScriptedEntityTweener:Play(self.Properties.HeroBorder, animDuration, {opacity = 0, ease = "QuadIn"})
      self:SetTextColor(self.UIStyle.COLOR_GRAY_50, animDuration)
    else
      self.ScriptedEntityTweener:Play(self.Properties.HeroImageSequence, animDuration, {opacity = 0.8, ease = "QuadOut"})
      self.ScriptedEntityTweener:Play(self.Properties.HeroImageSequenceDisabled, animDuration, {opacity = 0, ease = "QuadIn"})
      self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration, {opacity = 0.1, ease = "QuadIn"})
      UiImageBus.Event.SetSpritePathname(self.Properties.Frame, self.BUTTON_FRAME_HERO_PATH)
      self.ScriptedEntityTweener:Play(self.Properties.HeroBorder, animDuration, {opacity = 0, ease = "QuadIn"})
      self:SetTextColor(self.UIStyle.COLOR_WHITE, animDuration)
    end
  end
end
function Button:IsEnabled()
  return self.mIsEnabled
end
return Button
