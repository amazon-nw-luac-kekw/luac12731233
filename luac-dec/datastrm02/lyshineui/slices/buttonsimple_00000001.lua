local ButtonSimple = {
  Properties = {
    ButtonText = {
      default = EntityId()
    },
    ButtonBg = {
      default = EntityId()
    },
    ButtonBgTexture = {
      default = EntityId()
    },
    ButtonHintHolder = {
      default = EntityId()
    },
    ButtonTooltipSetter = {
      default = EntityId()
    },
    ButtonArrow = {
      default = EntityId()
    },
    ButtonHint = {
      default = EntityId()
    },
    ButtonSingleIcon = {
      default = EntityId()
    },
    UseAlternateTexture = {default = false}
  },
  width = nil,
  height = nil,
  callback = nil,
  callbackTable = nil,
  isClickable = true,
  autoSizePadding = 32,
  initBgAlpha = 0.1,
  mSoundOnFocus = nil,
  mSoundOnPress = nil,
  mIsPulseStyle = false,
  mIsIconVisible = false,
  mIsEnabled = true,
  mBackgroundColor = nil,
  TEXT_ALIGN_LEFT = eUiHAlign_Left,
  TEXT_ALIGN_CENTER = eUiHAlign_Center,
  TEXT_ALIGN_RIGHT = eUiHAlign_Right,
  OVERFLOW_OVERFLOW_TEXT = eUiTextOverflowMode_OverflowText,
  OVERFLOW_CLIP_TEXT = eUiTextOverflowMode_ClipText,
  OVERFLOW_ELLIPSIS = eUiTextOverflowMode_Ellipsis,
  mTextAlignment = nil,
  mTextInitPosX = nil,
  mAnimPositionDuration = 0.3,
  mSizedToText = false,
  savedTextOffset = 0,
  mTextPadding = 17,
  mHintPadding = 18,
  hintIconSize = 0,
  BG_TEXTURE_STYLE_1 = "lyshineui/images/slices/buttonsimple/button_simple_bgMask1.dds",
  BG_TEXTURE_STYLE_2 = "lyshineui/images/slices/buttonsimple/button_simple_bgMask2.dds",
  BG_TEXTURE_STYLE_COLOR_BACKGROUND = "lyshineui/images/slices/buttonsimple/button_simple_bgMask3.dds"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ButtonSimple)
function ButtonSimple:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.ButtonText, self.UIStyle.FONT_STYLE_BUTTON_SIMPLE)
  self.width = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.height = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  self:SetSize(self.width, self.height)
  self.mSoundOnFocus = self.audioHelper.OnHover_ButtonSimpleText
  self.mSoundOnPress = self.audioHelper.Accept
  if self.Properties.UseAlternateTexture then
    UiImageBus.Event.SetSpritePathname(self.Properties.ButtonBgTexture, self.BG_TEXTURE_STYLE_2)
  end
  self.mBackgroundColor = self.UIStyle.COLOR_WHITE
  self.mTextColor = self.UIStyle.COLOR_WHITE
  if not self.timelineOpacity then
    self.timelineOpacity = self.ScriptedEntityTweener:TimelineCreate()
    self.timelineOpacity:Add(self.ButtonBg, 0.02, {opacity = 0.8})
    self.timelineOpacity:Add(self.ButtonBg, 0.3, {opacity = 0.5})
    self.timelineOpacity:Add(self.ButtonBg, 0.32, {
      opacity = 0.8,
      onComplete = function()
        self.timelineOpacity:Play()
      end
    })
  end
  if not self.timelineScale then
    self.timelineScale = self.ScriptedEntityTweener:TimelineCreate()
    self.timelineScale:Add(self.entityId, 0.02, {scaleX = 1.03, scaleY = 1.03})
    self.timelineScale:Add(self.entityId, 0.3, {scaleX = 1, scaleY = 1})
    self.timelineScale:Add(self.entityId, 0.32, {
      scaleX = 1.03,
      scaleY = 1.03,
      onComplete = function()
        self.timelineScale:Play()
      end
    })
  end
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Options.Localization.Language", function(self, language)
    if self.mTextAlignment ~= nil then
      self:SetTextAlignment(self.mTextAlignment)
    end
    if self.mSizedToText then
      self:SizeToText()
    end
  end)
end
function ButtonSimple:SetPulseStyle(isPulse)
  if isPulse ~= self.mIsPulseStyle then
    self.mIsPulseStyle = isPulse
    if isPulse then
      self.mIsPulseStyle = true
      self.timelineOpacity:Play()
      self.timelineScale:Play()
    else
      self.mIsPulseStyle = false
      self.timelineOpacity:Stop()
      self.timelineScale:Stop()
    end
  end
end
function ButtonSimple:SetCallback(command, table)
  self.callback = command
  self.callbackTable = table
end
function ButtonSimple:SetSize(width, height)
  self.width = width
  self.height = height
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.width)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.height)
end
function ButtonSimple:GetWidth()
  return self.width
end
function ButtonSimple:GetHeight()
  return self.height
end
function ButtonSimple:SetText(value, skipLocalization, autoResize, autoSizePadding)
  if not skipLocalization then
    UiTextBus.Event.SetTextWithFlags(self.ButtonText, value, eUiTextSet_SetLocalized)
  else
    UiTextBus.Event.SetText(self.ButtonText, value)
  end
  if autoResize then
    if autoSizePadding then
      self.autoSizePadding = autoSizePadding
    end
    self:SizeToText()
  end
  self:SetTextAlignment(self.mTextAlignment)
end
function ButtonSimple:GetText()
  return UiTextBus.Event.GetText(self.ButtonText)
end
function ButtonSimple:SizeToText()
  self.mSizedToText = true
  local textWidth = UiTextBus.Event.GetTextWidth(self.ButtonText)
  self:SetSize(textWidth + self.autoSizePadding, self.height)
end
function ButtonSimple:SetIsMarkupEnabled(value)
  UiTextBus.Event.SetIsMarkupEnabled(self.Properties.ButtonText, value)
end
function ButtonSimple:SetTooltip(value)
  if value == nil then
    self.usingTooltip = false
    UiElementBus.Event.SetIsEnabled(self.ButtonTooltipSetter.entityId, false)
  else
    self.usingTooltip = true
    if type(value) == "string" then
      self.ButtonTooltipSetter:SetSimpleTooltip(value)
    else
      self.ButtonTooltipSetter:SetTooltipInfo(value)
    end
    UiElementBus.Event.SetIsEnabled(self.ButtonTooltipSetter.entityId, true)
  end
end
function ButtonSimple:SetTextColor(color, animTime, skipSet)
  if not skipSet then
    self.mTextColor = color
  end
  animTime = animTime ~= nil and animTime or 2
  self.ScriptedEntityTweener:Play(self.ButtonText, animTime, {textColor = color})
end
function ButtonSimple:SetFontSize(value)
  UiTextBus.Event.SetFontSize(self.ButtonText, value)
end
function ButtonSimple:GetFontSize(value)
  return UiTextBus.Event.GetFontSize(self.ButtonText)
end
function ButtonSimple:SetCharacterSpacing(value)
  UiTextBus.Event.SetCharacterSpacing(self.ButtonText, value)
end
function ButtonSimple:GetCharacterSpacing()
  return UiTextBus.Event.GetCharacterSpacing(self.ButtonText)
end
function ButtonSimple:SetTextStyle(value)
  SetTextStyle(self.ButtonText, value)
end
function ButtonSimple:SetTextPadding(value)
  self.mTextPadding = value
end
function ButtonSimple:SetTextAlignment(value)
  local enumAlign
  local textWidth = 0
  if self.Properties.ButtonText:IsValid() then
    textWidth = UiTextBus.Event.GetTextSize(self.Properties.ButtonText).x
  end
  local textWidthDifference = self.width - textWidth
  local textPosX
  if value == self.TEXT_ALIGN_LEFT then
    enumAlign = value
    textPosX = -textWidthDifference / 2 + self.mTextPadding
    self.savedTextOffset = textPosX
  elseif value == self.TEXT_ALIGN_CENTER then
    enumAlign = value
    textPosX = 0
  elseif value == self.TEXT_ALIGN_RIGHT then
    enumAlign = value
    textPosX = textWidthDifference / 2 - self.mTextPadding
  end
  if enumAlign ~= nil then
    self.mTextAlignment = enumAlign
    self.mTextInitPosX = self.savedTextOffset ~= 0 and self.savedTextOffset or textPosX
    self.ScriptedEntityTweener:Play(self.ButtonText, self.mAnimPositionDuration, {x = textPosX, ease = "QuadOut"})
  end
  if UiElementBus.Event.IsEnabled(self.Properties.ButtonHint) then
    self:SetHintPosition()
  end
end
function ButtonSimple:SetHintPosition()
  local textPosX = 0
  local hintPosX = 0
  local textWidth = UiTextBus.Event.GetTextSize(self.ButtonText).x
  local textWidthDifference = self.width - textWidth
  local hintWidth = self.ButtonHint:GetWidth()
  local initHintWidth = 34
  local initHintPosX = -5
  local hintPadding = self.mHintPadding
  if self.mTextAlignment == self.TEXT_ALIGN_LEFT then
    textPosX = -textWidthDifference / 2 + (hintWidth + hintPadding)
    hintPosX = initHintPosX - (hintWidth - initHintWidth)
  elseif self.mTextAlignment == self.TEXT_ALIGN_CENTER then
    textPosX = (hintWidth - initHintPosX) / 2
    hintPosX = initHintPosX - (hintWidth - initHintWidth)
  elseif self.mTextAlignment == self.TEXT_ALIGN_RIGHT then
    textPosX = textWidthDifference / 2 - (hintWidth + hintPadding)
    hintPosX = textWidth + (initHintPosX + initHintWidth + hintPadding)
  else
    textPosX = (hintWidth - initHintPosX) / 2
    hintPosX = initHintPosX - (hintWidth - initHintWidth)
  end
  self.mTextInitPosX = self.savedTextOffset ~= 0 and self.savedTextOffset or textPosX
  self.ScriptedEntityTweener:Play(self.ButtonText, self.mAnimPositionDuration, {x = textPosX, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.ButtonHintHolder, self.mAnimPositionDuration, {x = hintPosX, ease = "QuadOut"})
end
function ButtonSimple:SetBackgroundColor(value)
  self.mBackgroundColor = value
  UiImageBus.Event.SetColor(self.ButtonBg, value)
end
function ButtonSimple:SetButtonBgTexture(value)
  UiImageBus.Event.SetSpritePathname(self.Properties.ButtonBgTexture, value)
end
function ButtonSimple:SetBackgroundOpacity(value)
  self.initBgAlpha = value
  UiFaderBus.Event.SetFadeValue(self.ButtonBg, value)
  if self.timeline then
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
    self.timeline = nil
  end
end
function ButtonSimple:SetIsMarkupEnabled(value)
  UiTextBus.Event.SetIsMarkupEnabled(self.Properties.ButtonText, value)
end
function ButtonSimple:SetOverflowMode(value)
  if value == self.OVERFLOW_OVERFLOW_TEXT then
    UiTextBus.Event.SetOverflowMode(self.Properties.ButtonText, value)
    UiLayoutFitterBus.Event.SetHorizontalFit(self.Properties.ButtonText, true)
  elseif value == self.OVERFLOW_CLIP_TEXT or value == self.OVERFLOW_ELLIPSIS then
    local textPadding = 15
    local width = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
    UiTextBus.Event.SetOverflowMode(self.Properties.ButtonText, value)
    UiLayoutFitterBus.Event.SetHorizontalFit(self.Properties.ButtonText, false)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.ButtonText, width - textPadding)
  end
end
function ButtonSimple:SetIsClickable(value)
  self:OnUnfocus()
  self.isClickable = value
  if self.ButtonArrow then
    if not self.isClickable then
      self.ScriptedEntityTweener:Set(self.ButtonArrow, {opacity = 0.3})
    else
      self.ScriptedEntityTweener:Set(self.ButtonArrow, {opacity = 1})
    end
  end
end
function ButtonSimple:OnFocus()
  if self.usingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverStart()
  end
  if not self.isClickable then
    return
  end
  if self.mIsPulseStyle then
    self.timelineOpacity:Stop()
    self.timelineScale:Stop()
    self.ScriptedEntityTweener:Play(self.ButtonBg, 0.15, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.entityId, 0.1, {
      scaleX = 1.03,
      scaleY = 1.03,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.ButtonText, 0.1, {
      textColor = self.UIStyle.COLOR_WHITE
    })
  elseif not self.mIsEnabled then
    self.ScriptedEntityTweener:Play(self.ButtonBg, 0.1, {opacity = 0.1, ease = "QuadOut"})
  else
    local opacityIncrease = 0.2
    local pulseDown = math.min(self.initBgAlpha + 0.1, 1)
    local pulseUp = math.min(self.initBgAlpha + opacityIncrease, 1)
    local animDuration1 = self.UIStyle.DURATION_BUTTON_FADE_IN
    if not self.timeline then
      self.timeline = self.ScriptedEntityTweener:TimelineCreate()
      self.timeline:Add(self.ButtonBg, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = pulseDown})
      self.timeline:Add(self.ButtonBg, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = pulseUp})
      self.timeline:Add(self.ButtonBg, self.UIStyle.DURATION_TIMELINE_HOLD, {
        opacity = pulseUp,
        onComplete = function()
          self.timeline:Play()
        end
      })
    end
    self.ScriptedEntityTweener:Play(self.Properties.ButtonBg, animDuration1, {opacity = pulseUp, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonBg, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
      opacity = pulseUp,
      delay = animDuration1,
      onComplete = function()
        self.timeline:Play()
      end
    })
  end
  if self.mIsEnabled then
    if self.ButtonHint ~= nil and type(self.ButtonHint) == "table" and UiElementBus.Event.IsEnabled(self.ButtonHint.entityId) then
      self.ButtonHint:OnFocus()
    end
    if self.ButtonArrow then
      self.ScriptedEntityTweener:Play(self.ButtonArrow, 0.15, {
        imgColor = self.UIStyle.COLOR_WHITE,
        ease = "QuadOut"
      })
    end
    if self.mIsIconVisible and self.buttonSingleIconFocusColor then
      self.ScriptedEntityTweener:Play(self.Properties.ButtonSingleIcon, 0.15, {
        imgColor = self.buttonSingleIconFocusColor,
        ease = "QuadOut"
      })
    end
    self.audioHelper:PlaySound(self.mSoundOnFocus)
  end
end
function ButtonSimple:OnUnfocus()
  if self.usingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  end
  if not self.isClickable then
    return
  end
  if self.mIsPulseStyle then
    self.timelineOpacity:Play()
    self.timelineScale:Play()
    self.ScriptedEntityTweener:Play(self.ButtonText, self.UIStyle.DURATION_BUTTON_FADE_OUT, {
      textColor = self.UIStyle.COLOR_BLACK
    })
  elseif not self.mIsEnabled then
    self.ScriptedEntityTweener:Play(self.ButtonBg, self.UIStyle.DURATION_BUTTON_FADE_OUT, {opacity = 0.1, ease = "QuadOut"})
  else
    self.ScriptedEntityTweener:Play(self.ButtonBg, self.UIStyle.DURATION_BUTTON_FADE_OUT, {
      opacity = self.initBgAlpha,
      ease = "QuadOut"
    })
  end
  if self.ButtonArrow then
    self.ScriptedEntityTweener:Play(self.ButtonArrow, self.UIStyle.DURATION_BUTTON_FADE_OUT, {
      imgColor = self.UIStyle.COLOR_TAN,
      ease = "QuadOut"
    })
  end
  if self.ButtonHint ~= nil and type(self.ButtonHint) == "table" and UiElementBus.Event.IsEnabled(self.ButtonHint.entityId) then
    self.ButtonHint:OnUnfocus()
  end
  if self.mIsIconVisible and self.buttonSingleIconColor then
    self.ScriptedEntityTweener:Play(self.Properties.ButtonSingleIcon, self.UIStyle.DURATION_BUTTON_FADE_OUT, {
      imgColor = self.buttonSingleIconColor,
      ease = "QuadOut"
    })
  end
end
function ButtonSimple:OnPress()
  if not self.isClickable then
    return
  end
  if not self.mIsEnabled then
    self.audioHelper:PlaySound(self.audioHelper.OnQuickBarPressEmpty)
    return
  end
  if self.usingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  end
  self.audioHelper:PlaySound(self.mSoundOnPress)
  if self.callback ~= nil and self.callbackTable ~= nil then
    if type(self.callback) == "function" then
      self.callback(self.callbackTable)
    else
      self.callbackTable[self.callback](self.callbackTable)
    end
    self.ScriptedEntityTweener:Play(self.ButtonBg, 0.15, {
      opacity = self.initBgAlpha,
      ease = "QuadOut"
    })
  end
end
function ButtonSimple:SetHint(hintText, isKeybindName, actionMap)
  local data = {
    text = hintText,
    isKeybind = isKeybindName,
    actionMap = actionMap or "ui"
  }
  if self.ButtonHint ~= nil then
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonHint, hintText ~= nil)
    self:SetHintData(data)
    local hintKeybindMapping = self.ButtonHint:GetKeybindMapping()
    local actionMap = actionMap or "ui"
    self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Keybind." .. hintKeybindMapping .. "." .. actionMap, function(self, data)
      self:SetHintPosition()
    end)
    self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Keybind.Reset", function(self, data)
      self:SetHintPosition()
    end)
    self:SetHintPosition()
  end
end
function ButtonSimple:SetHintData(data)
  if data.isKeybind then
    self.ButtonHint:SetActionMap(data.actionMap)
    self.ButtonHint:SetKeybindMapping(data.text)
  else
    self.ButtonHint:SetText(data.text)
  end
end
function ButtonSimple:SetEnabled(enabled, durationOverride, forceUpdate)
  if self.mIsEnabled == enabled and not forceUpdate then
    return
  end
  self.mIsEnabled = enabled
  local animDuration = durationOverride and durationOverride or 0.3
  if self.mIsEnabled == false then
    self.ScriptedEntityTweener:Play(self.ButtonBg, animDuration, {
      opacity = 0.1,
      imgColor = self.UIStyle.COLOR_GRAY_50,
      ease = "QuadOut"
    })
    self:SetTextColor(self.UIStyle.COLOR_GRAY_30, animDuration, true)
  else
    self.ScriptedEntityTweener:Play(self.ButtonBg, animDuration, {
      opacity = self.initBgAlpha,
      imgColor = self.mBackgroundColor,
      ease = "QuadOut"
    })
    self:SetTextColor(self.mTextColor, animDuration)
  end
end
function ButtonSimple:OnShutdown()
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
  if self.timelineOpacity ~= nil then
    self.timelineOpacity:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timelineOpacity)
  end
  if self.timelineScale ~= nil then
    self.timelineScale:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timelineScale)
  end
end
function ButtonSimple:SetSoundOnFocus(value)
  self.mSoundOnFocus = value
end
function ButtonSimple:SetSoundOnPress(value)
  self.mSoundOnPress = value
end
function ButtonSimple:SetButtonSingleIconPath(value)
  if value then
    if not self.mIsIconVisible then
      self.mIsIconVisible = true
      UiElementBus.Event.SetIsEnabled(self.ButtonSingleIcon, true)
    end
    UiImageBus.Event.SetSpritePathname(self.ButtonSingleIcon, value)
  else
    self.mIsIconVisible = false
    UiElementBus.Event.SetIsEnabled(self.ButtonSingleIcon, false)
  end
end
function ButtonSimple:SetButtonSingleIconColor(value)
  self.buttonSingleIconColor = value
  UiImageBus.Event.SetColor(self.Properties.ButtonSingleIcon, self.buttonSingleIconColor)
end
function ButtonSimple:SetButtonSingleIconFocusColor(value)
  self.buttonSingleIconFocusColor = value
end
function ButtonSimple:SetButtonSingleIconVisible(visible)
  UiElementBus.Event.SetIsEnabled(self.ButtonSingleIcon, visible)
end
function ButtonSimple:PositionButtonSingleIconToText()
  local iconWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.ButtonSingleIcon)
  local textWidth = UiTextBus.Event.GetTextWidth(self.Properties.ButtonText)
  local margin = 6
  UiTransformBus.Event.SetLocalPositionX(self.Properties.ButtonText, (iconWidth + margin) / 2)
  UiTransformBus.Event.SetLocalPositionX(self.Properties.ButtonSingleIcon, (textWidth + margin) / 2 * -1)
  UiTransformBus.Event.SetLocalPositionY(self.Properties.ButtonSingleIcon, 0)
end
function ButtonSimple:SetButtonSingleIconSize(size)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.ButtonSingleIcon, size)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.ButtonSingleIcon, size)
end
function ButtonSimple:GetTextColor()
  return UiTextBus.Event.GetColor(self.Properties.ButtonText)
end
return ButtonSimple
