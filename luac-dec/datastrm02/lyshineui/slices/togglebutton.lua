local ToggleButton = {
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
    ButtonFocusGlow = {
      default = EntityId()
    },
    ToggleRadioGroup = {
      default = EntityId()
    },
    ButtonTooltipSetter = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    }
  },
  mWidth = 100,
  mHeight = 30,
  mPressCallback = nil,
  mPressTable = nil,
  enabled = true
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ToggleButton)
function ToggleButton:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.ButtonText, self.UIStyle.FONT_STYLE_BUTTON)
  self.mWidth = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.mHeight = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  self:SetSize(self.mWidth, self.mHeight)
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonFocusGlow, true)
  self.ScriptedEntityTweener:Set(self.Properties.ButtonBg, {
    opacity = 0,
    imgColor = self.UIStyle.COLOR_DARKER_ORANGE
  })
  self.ScriptedEntityTweener:Set(self.Properties.ButtonFocus, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.ButtonFocusGlow, {opacity = 0})
  UiImageBus.Event.SetColor(self.Properties.Frame, self.UIStyle.COLOR_MEDIUM_ORANGE_FOCUSED)
  UiImageBus.Event.SetColor(self.Properties.ButtonFocusGlow, self.UIStyle.COLOR_BRIGHT_ORANGE)
end
function ToggleButton:SetCallback(command, table)
  self.mPressCallback = command
  self.mPressTable = table
end
function ToggleButton:SetSize(width, height)
  self.mWidth = width
  self.mHeight = height
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.mWidth)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.mHeight)
end
function ToggleButton:GetWidth()
  return self.mWidth
end
function ToggleButton:GetHeight()
  return self.mHeight
end
function ToggleButton:SetText(value)
  UiTextBus.Event.SetTextWithFlags(self.ButtonText, value, eUiTextSet_SetLocalized)
end
function ToggleButton:GetText()
  return UiTextBus.Event.GetText(self.ButtonText)
end
function ToggleButton:SetTextColor(color)
  self.ScriptedEntityTweener:Play(self.ButtonText, 0.2, {textColor = color})
end
function ToggleButton:SetFontSize(value)
  UiTextBus.Event.SetFontSize(self.ButtonText, value)
end
function ToggleButton:GetFontSize(value)
  UiTextBus.Event.GetFontSize(self.ButtonText, value)
end
function ToggleButton:SetCharacterSpacing(value)
  UiTextBus.Event.SetCharacterSpacing(self.ButtonText, value)
end
function ToggleButton:GetCharacterSpacing()
  return UiTextBus.Event.GetCharacterSpacing(self.ButtonText)
end
function ToggleButton:SetTextStyle(value)
  SetTextStyle(self.ButtonText, value)
end
function ToggleButton:OnFocus()
  if self.mIsUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverStart()
  end
  local toggleState = UiRadioButtonBus.Event.GetState(self.entityId)
  if toggleState == true then
    return
  end
  self:SetTextColor(self.UIStyle.COLOR_WHITE)
  local animDuration1 = self.UIStyle.DURATION_BUTTON_FADE_IN
  if not self.timeline then
    self.timeline = self.ScriptedEntityTweener:TimelineCreate()
    self.timeline:Add(self.Properties.ButtonFocusGlow, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.3})
    self.timeline:Add(self.Properties.ButtonFocusGlow, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 0.4})
    self.timeline:Add(self.Properties.ButtonFocusGlow, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 0.4,
      onComplete = function()
        self.timeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocusGlow, animDuration1, {opacity = 0.4, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocusGlow, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 0.4,
    delay = animDuration1,
    onComplete = function()
      self.timeline:Play()
    end
  })
  self.audioHelper:PlaySound(self.audioHelper.OnHover_ToggleButton)
end
function ToggleButton:OnUnfocus()
  if self.mIsUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  end
  local toggleState = UiRadioButtonBus.Event.GetState(self.entityId)
  if toggleState ~= true then
    self:OnUnselected()
  end
end
function ToggleButton:Select(noCallback)
  local animDuration = 0.2
  if self.enabled then
    self.ScriptedEntityTweener:Play(self.Properties.ButtonBg, animDuration, {
      opacity = 1,
      imgColor = self.UIStyle.COLOR_DARK_ORANGE,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration, {opacity = 0.1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.Frame, animDuration, {
      opacity = 1,
      imgColor = self.UIStyle.COLOR_MEDIUM_ORANGE_FOCUSED,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocusGlow, animDuration, {
      opacity = 0.4,
      imgColor = self.UIStyle.COLOR_BRIGHT_ORANGE,
      ease = "QuadOut"
    })
    self:SetTextColor(self.UIStyle.COLOR_WHITE, animDuration)
  else
    self.ScriptedEntityTweener:Play(self.Properties.ButtonBg, animDuration, {
      opacity = 1,
      imgColor = self.UIStyle.COLOR_GRAY_DARK,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration, {opacity = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.Frame, animDuration, {
      opacity = 1,
      imgColor = self.UIStyle.COLOR_GRAY_MEDIUM_DARK,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFocusGlow, animDuration, {opacity = 0, ease = "QuadOut"})
    self:SetTextColor(self.UIStyle.COLOR_GRAY_60, animDuration)
  end
  if not noCallback and self.mPressCallback ~= nil and self.mPressTable ~= nil then
    if type(self.mPressCallback) == "function" then
      self.mPressCallback(self.mPressTable)
    else
      self.mPressTable[self.mPressCallback](self.mPressTable)
    end
  end
end
function ToggleButton:Init(noCallback)
  self:Select(noCallback)
end
function ToggleButton:OnSelected()
  self:Select()
  self.audioHelper:PlaySound(self.audioHelper.Accept)
end
function ToggleButton:OnUnselected()
  if self.mIsUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  end
  local textColor = self.enabled == true and self.UIStyle.COLOR_TAN or self.UIStyle.COLOR_GRAY_30
  self:SetTextColor(textColor)
  local animDuration1 = 0.1
  self.ScriptedEntityTweener:Stop(self.Properties.ButtonBg)
  self.ScriptedEntityTweener:Stop(self.Properties.ButtonFocus)
  self.ScriptedEntityTweener:Stop(self.Properties.Frame)
  self.ScriptedEntityTweener:Stop(self.Properties.ButtonFocusGlow)
  self.ScriptedEntityTweener:Play(self.Properties.ButtonBg, animDuration1, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration1, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.Frame, animDuration1, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.ButtonFocusGlow, animDuration1, {opacity = 0})
end
function ToggleButton:SetDisabled(disabled)
  self.enabled = not disabled
  local selected = UiRadioButtonBus.Event.GetState(self.entityId)
  if selected then
    self:Select(true)
  else
    self:OnUnselected()
  end
  UiInteractableBus.Event.SetIsHandlingEvents(self.entityId, self.enabled)
end
function ToggleButton:OnShutdown()
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
end
function ToggleButton:SetGroup(groupEntityId)
  UiRadioButtonGroupBus.Event.AddRadioButton(groupEntityId, self.entityId)
end
function ToggleButton:SetTooltip(value)
  if value == nil or value == "" then
    self.mIsUsingTooltip = false
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, false)
  else
    self.mIsUsingTooltip = true
    self.ButtonTooltipSetter:SetSimpleTooltip(value)
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, true)
  end
end
return ToggleButton
