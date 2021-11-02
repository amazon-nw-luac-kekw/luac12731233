local Hint = {
  Properties = {
    HintText = {
      default = EntityId()
    },
    HintFrame = {
      default = EntityId()
    },
    HintFrameHighlight = {
      default = EntityId()
    },
    HintBg = {
      default = EntityId()
    },
    HintMouseIcon = {
      default = EntityId()
    },
    HintKeyBind = {default = ""},
    HintKeyBindActionMap = {default = "ui"},
    HintGetKeybindWithoutHold = {default = false},
    IsHUDSmallHint = {default = false},
    IsHUDHint = {default = false}
  },
  mWidth = 34,
  mHeight = 34,
  mPressCallback = nil,
  mPressTable = nil,
  mKeybindMapping = nil,
  mMinWidth = 34,
  mIsMouseIconEnabled = false,
  mMouseIconPaths = {
    mouse1 = {
      iconPath = "lyshineui/images/icons/misc/Icon_LeftMouseButton.png"
    },
    mouse2 = {
      iconPath = "lyshineui/images/icons/misc/Icon_RightMouseButton.png"
    },
    mouse3 = {
      iconPath = "lyshineui/images/icons/misc/Icon_MiddleMouseButton.png"
    },
    mwheel_up = {
      iconPath = "lyshineui/images/icons/misc/Icon_MiddleMouseButton.png"
    },
    mwheel_down = {
      iconPath = "lyshineui/images/icons/misc/Icon_MiddleMouseButton.png"
    }
  },
  hintFrameDefault = "lyshineui/images/slices/hint/hintFrame.dds",
  hintFrameSmall = "lyshineui/images/slices/hint/hintFrame_small.dds"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(Hint)
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
function Hint:OnInit()
  BaseElement.OnInit(self)
  self.dataLayer = dataLayer
  if self.Properties.IsHUDSmallHint then
    SetTextStyle(self.Properties.HintText, self.UIStyle.FONT_STYLE_HINT_HUD_SMALL)
    self.ScriptedEntityTweener:Set(self.Properties.HintFrame, {
      imgColor = self.UIStyle.COLOR_WHITE
    })
  elseif self.Properties.IsHUDHint then
    SetTextStyle(self.Properties.HintText, self.UIStyle.FONT_STYLE_HINT_HUD)
    self.ScriptedEntityTweener:Set(self.Properties.HintFrame, {
      imgColor = self.UIStyle.COLOR_WHITE
    })
  else
    SetTextStyle(self.Properties.HintText, self.UIStyle.FONT_STYLE_HINT)
    self.ScriptedEntityTweener:Set(self.Properties.HintFrame, {
      imgColor = self.UIStyle.COLOR_GRAY_70
    })
  end
  if self.HintKeyBind ~= "" then
    self:SetKeybindMapping(self.Properties.HintKeyBind)
  end
end
function Hint:SetCallback(command, table)
  self.mPressCallback = command
  self.mPressTable = table
end
function Hint:SetSize(width, height)
  self.mWidth = width
  self.mHeight = height
end
function Hint:GetWidth()
  return self.mWidth
end
function Hint:GetHeight()
  return self.mHeight
end
function Hint:SetMinWidth(value)
  self.mMinWidth = value
end
function Hint:SetText(value)
  local textPadding = 20
  local isMouseIconEnabled = false
  local isHoldAction = false
  if self.mKeybindMapping then
    local actionMap = LyShineManagerBus.Broadcast.GetActionInputName(self.mKeybindMapping, self.Properties.HintKeyBindActionMap)
    isHoldAction = not self.HintGetKeybindWithoutHold and LyShineManagerBus.Broadcast.IsActionActivatedOnHold(self.mKeybindMapping, self.Properties.HintKeyBindActionMap) or false
    isMouseIconEnabled = self:GetMouseIcon(actionMap)
  end
  if isMouseIconEnabled then
    UiImageBus.Event.SetSpritePathname(self.Properties.HintMouseIcon, isMouseIconEnabled)
    if not isHoldAction then
      self.mWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.HintMouseIcon)
      UiTransformBus.Event.SetLocalPositionX(self.Properties.HintMouseIcon, 0)
    else
      UiTextBus.Event.SetTextWithFlags(self.Properties.HintText, "@TUT_Hold", eUiTextSet_SetLocalized)
      local textWidth = UiTextBus.Event.GetTextWidth(self.Properties.HintText)
      local iconWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.HintMouseIcon)
      self.mWidth = textWidth + textPadding + iconWidth
      local iconX = -self.mWidth / 2 + iconWidth / 2
      local textX = self.mWidth / 2 - textWidth / 2
      UiTransformBus.Event.SetLocalPositionX(self.Properties.HintMouseIcon, iconX)
      UiTransformBus.Event.SetLocalPositionX(self.Properties.HintText, textX)
    end
    UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.mWidth)
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.HintText, value, eUiTextSet_SetLocalized)
    local textWidth = UiTextBus.Event.GetTextWidth(self.Properties.HintText)
    local bgWidth = math.max(self.mMinWidth, textWidth + textPadding)
    UiTransform2dBus.Event.SetLocalWidth(self.entityId, bgWidth)
    self.mWidth = bgWidth
  end
  if self.mIsMouseIconEnabled ~= isMouseIconEnabled or self.mIsHoldAction ~= isHoldAction then
    UiElementBus.Event.SetIsEnabled(self.Properties.HintMouseIcon, isMouseIconEnabled)
    UiElementBus.Event.SetIsEnabled(self.Properties.HintText, not isMouseIconEnabled or isHoldAction)
    UiElementBus.Event.SetIsEnabled(self.Properties.HintFrame, not isMouseIconEnabled)
    UiElementBus.Event.SetIsEnabled(self.Properties.HintFrameHighlight, not isMouseIconEnabled)
    UiElementBus.Event.SetIsEnabled(self.Properties.HintBg, not isMouseIconEnabled)
  end
  self.mIsMouseIconEnabled = isMouseIconEnabled
  self.mIsHoldAction = isHoldAction
end
function Hint:GetText()
  return UiTextBus.Event.GetText(self.Properties.HintText)
end
function Hint:SetKeybindMapping(value)
  if type(value) == "string" and string.len(value) > 0 then
    self.mKeybindMapping = value
    local actionMap = self.Properties.HintKeyBindActionMap or "ui"
    self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Keybind." .. self.mKeybindMapping .. "." .. actionMap, function(self, data)
      self:UpdateKeybindMapping()
    end)
    self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Keybind.Reset", function(self, data)
      self:UpdateKeybindMapping()
    end)
    self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Options.Localization.Language", function(self, languageSelected)
      self:UpdateKeybindMapping()
    end)
  else
    self.dataLayer:UnregisterObservers(self)
    self.mKeybindMapping = nil
  end
end
function Hint:UpdateKeybindMapping()
  local text = ""
  if self.mKeybindMapping then
    if self.HintGetKeybindWithoutHold then
      text = LyShineManagerBus.Broadcast.GetKeybindWithoutHold(self.mKeybindMapping, self.Properties.HintKeyBindActionMap)
    else
      text = LyShineManagerBus.Broadcast.GetKeybind(self.mKeybindMapping, self.Properties.HintKeyBindActionMap)
    end
  end
  self:SetText(text)
end
function Hint:GetKeybindMapping()
  return self.mKeybindMapping
end
function Hint:SetActionMap(value)
  self.Properties.HintKeyBindActionMap = value
end
function Hint:SetTextColor(color)
  self.ScriptedEntityTweener:Play(self.Properties.HintText, 2, {textColor = color})
end
function Hint:SetFontSize(value)
  UiTextBus.Event.SetFontSize(self.Properties.HintText, value)
end
function Hint:GetFontSize(value)
  UiTextBus.Event.GetFontSize(self.Properties.HintText, value)
end
function Hint:SetCharacterSpacing(value)
  UiTextBus.Event.SetCharacterSpacing(self.Properties.HintText, value)
end
function Hint:GetCharacterSpacing()
  return UiTextBus.Event.GetCharacterSpacing(self.Properties.HintText)
end
function Hint:GetFont()
  return UiTextBus.Event.GetFont(self.Properties.HintText)
end
function Hint:SetTextStyle(value)
  SetTextStyle(self.Properties.HintText, value)
end
function Hint:GetMouseIcon(keyMapping)
  return self.mMouseIconPaths[keyMapping] and self.mMouseIconPaths[keyMapping].iconPath or false
end
function Hint:SetMouseIconScale(value)
  if self.mIsMouseIconEnabled then
    UiTransformBus.Event.SetScale(self.Properties.HintMouseIcon, Vector2(value, value))
    self.mWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.HintMouseIcon) * UiTransformBus.Event.GetScaleX(self.Properties.HintMouseIcon)
    UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.mWidth)
  end
end
function Hint:OnFocus()
  self.ScriptedEntityTweener:Play(self.Properties.HintFrame, 0.15, {
    imgColor = self.UIStyle.COLOR_WHITE,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.HintText, 0.15, {
    textColor = self.UIStyle.COLOR_WHITE,
    ease = "QuadOut"
  })
  self.audioHelper:PlaySound(self.audioHelper.OnHover_ButtonSimpleText)
end
function Hint:OnUnfocus()
  self.ScriptedEntityTweener:Play(self.Properties.HintFrame, 0.15, {
    imgColor = self.UIStyle.COLOR_GRAY_70,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.HintText, 0.15, {
    textColor = self.UIStyle.COLOR_WHITE,
    ease = "QuadIn"
  })
end
function Hint:OnPress()
  self.audioHelper:PlaySound(self.audioHelper.Accept)
  if self.mPressCallback ~= nil and self.mPressTable ~= nil then
    if type(self.mPressCallback) == "function" then
      self.mPressCallback(self.mPressTable)
    else
      self.mPressTable[self.mPressCallback](self.mPressTable)
    end
  end
end
function Hint:SetHighlightVisible(isVisible, skipScale)
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.HintFrameHighlight, true)
    if not skipScale then
      self.ScriptedEntityTweener:Set(self.Properties.HintFrameHighlight, {scaleX = 1, scaleY = 1})
    end
    if not self.timeline then
      self.timeline = self.ScriptedEntityTweener:TimelineCreate()
      self.timeline:Add(self.HintFrameHighlight, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
      self.timeline:Add(self.HintFrameHighlight, self.UIStyle.DURATION_TIMELINE_HOLD, {opacity = 1})
      self.timeline:Add(self.HintFrameHighlight, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {
        opacity = 0.2,
        onComplete = function()
          self.timeline:Play()
        end
      })
    end
    self.timeline:Play()
  else
    self.ScriptedEntityTweener:Play(self.HintFrameHighlight, 0.15, {opacity = 0, ease = "QuadOut"})
  end
end
function Hint:SetHighlightScale(scaleValue, duration)
  self.ScriptedEntityTweener:Play(self.Properties.HintFrameHighlight, duration, {scaleX = 1, scaleY = 1}, {
    scaleX = scaleValue,
    scaleY = scaleValue,
    opacity = 0,
    ease = "QuadIn"
  })
end
function Hint:OnShutdown()
  if self.dataLayer then
    self.dataLayer:UnregisterObservers(self)
    self.dataLayer = nil
  end
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
end
return Hint
