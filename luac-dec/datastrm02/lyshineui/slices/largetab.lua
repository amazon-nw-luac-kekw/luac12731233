local LargeTab = {
  Properties = {
    numberYWithoutIcon = {
      default = -5,
      description = "Y value of Number element when NumberIcon is not showing"
    },
    numberYWithIcon = {
      default = -14,
      description = "Y value of Number element when NumberIcon is showing"
    },
    Darkener = {
      default = EntityId()
    },
    Warning = {
      default = EntityId()
    },
    Highlight = {
      default = EntityId()
    },
    Hatching = {
      default = EntityId()
    },
    FrameBase = {
      default = EntityId()
    },
    FrameEdge = {
      default = EntityId()
    },
    PrimaryText = {
      default = EntityId()
    },
    SecondaryText = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    GuildCrest = {
      default = EntityId()
    },
    Number = {
      default = EntityId()
    },
    NumberIcon = {
      default = EntityId()
    }
  },
  selectedStateEnabled = true,
  isSelected = false,
  isWarning = false,
  isShowingIcon = false,
  isShowingCrest = false,
  isShowingNumber = false,
  isShowingNumberIcon = false,
  selectedHighlightOpacity = 0.25,
  warningOpacity = 0.5,
  animationTime = 0.3,
  userData = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(LargeTab)
function LargeTab:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.PrimaryText, self.UIStyle.FONT_STYLE_LARGE_TAB_PRIMARY)
  SetTextStyle(self.SecondaryText, self.UIStyle.FONT_STYLE_LARGE_TAB_SECONDARY)
  SetTextStyle(self.Number, self.UIStyle.FONT_STYLE_LARGE_TAB_NUMBER)
  UiImageBus.Event.SetColor(self.FrameEdge, self.UIStyle.COLOR_TAN)
  UiImageBus.Event.SetColor(self.Warning, self.UIStyle.COLOR_RED_DARK)
  self:UpdateVisualState()
end
function LargeTab:OnShutdown()
  if self.highlightTimeline then
    self.ScriptedEntityTweener:TimelineDestroy(self.highlightTimeline)
  end
end
function LargeTab:OnHoverStart()
  if self.isSelected and self.selectedStateEnabled then
    return
  end
  if not self.highlightTimeline then
    self.highlightTimeline = self.ScriptedEntityTweener:TimelineCreate()
    self.highlightTimeline:Add(self.Highlight, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.05})
    self.highlightTimeline:Add(self.Highlight, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 0.15})
    self.highlightTimeline:Add(self.Highlight, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 0.15,
      onComplete = function()
        self.highlightTimeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 0.15, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 0.15,
    delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
    onComplete = function()
      self.highlightTimeline:Play()
    end
  })
end
function LargeTab:OnHoverStop()
  if self.highlightTimeline then
    self.highlightTimeline:Stop()
    if self.isSelected and self.selectedStateEnabled then
      self.ScriptedEntityTweener:Play(self.Highlight, self.animationTime, {
        opacity = self.selectedHighlightOpacity
      })
    else
      self.ScriptedEntityTweener:Play(self.Highlight, self.animationTime, {opacity = 0})
    end
  end
end
function LargeTab:OnPress()
  if type(self.callback) == "function" and self.callbackTable ~= nil then
    self.callback(self.callbackTable, self.callbackArgument)
  end
end
function LargeTab:UpdateVisualState()
  local darkenerOpacity = 0.5
  local warningOpacity = 0
  local hatchingOpacity = 0
  local highlightOpacity = 0
  local frameColor = self.UIStyle.COLOR_TAN
  local primaryTextColor = self.UIStyle.COLOR_TAN
  local secondaryTextColor = self.UIStyle.COLOR_GRAY_80
  local frameEdgeEnabled = true
  local iconColor = self.UIStyle.COLOR_TAN_DARK
  local numberColor = self.UIStyle.COLOR_GRAY_80
  local numberIconColor = self.UIStyle.COLOR_TAN
  if self.isSelected and self.selectedStateEnabled then
    darkenerOpacity = 0
    hatchingOpacity = 1
    highlightOpacity = self.selectedHighlightOpacity
    frameColor = self.UIStyle.COLOR_WHITE
    primaryTextColor = self.UIStyle.COLOR_WHITE
    secondaryTextColor = self.UIStyle.COLOR_WHITE
    frameEdgeEnabled = false
    iconColor = self.UIStyle.COLOR_WHITE
    numberColor = self.UIStyle.COLOR_WHITE
    numberIconColor = self.UIStyle.COLOR_WHITE
    if self.highlightTimeline then
      self.highlightTimeline:Stop()
    end
  elseif self.isWarning then
    warningOpacity = self.warningOpacity
    primaryTextColor = self.UIStyle.COLOR_RED
    secondaryTextColor = self.UIStyle.COLOR_RED
    iconColor = self.UIStyle.COLOR_RED
    numberColor = self.UIStyle.COLOR_RED
    numberIconColor = self.UIStyle.COLOR_RED
  end
  self.ScriptedEntityTweener:Play(self.Darkener, self.animationTime, {opacity = darkenerOpacity})
  self.ScriptedEntityTweener:Play(self.Warning, self.animationTime, {opacity = warningOpacity})
  self.ScriptedEntityTweener:Play(self.Hatching, self.animationTime, {opacity = hatchingOpacity})
  self.ScriptedEntityTweener:Play(self.Highlight, self.animationTime, {opacity = highlightOpacity})
  self.ScriptedEntityTweener:Play(self.FrameBase, self.animationTime, {imgColor = frameColor})
  self.ScriptedEntityTweener:Play(self.PrimaryText, self.animationTime, {textColor = primaryTextColor})
  self.ScriptedEntityTweener:Play(self.SecondaryText, self.animationTime, {textColor = secondaryTextColor})
  UiElementBus.Event.SetIsEnabled(self.FrameEdge, frameEdgeEnabled)
  if self.isShowingIcon then
    self.ScriptedEntityTweener:Play(self.Icon, self.animationTime, {imgColor = iconColor})
  elseif self.isShowingNumber then
    self.ScriptedEntityTweener:Play(self.Number, self.animationTime, {textColor = numberColor})
    if self.isShowingNumberIcon then
      self.ScriptedEntityTweener:Play(self.NumberIcon, self.animationTime, {imgColor = numberIconColor})
    end
  end
end
function LargeTab:SetPrimaryText(textString, skipLocalization)
  if skipLocalization then
    UiTextBus.Event.SetText(self.PrimaryText, textString)
  else
    UiTextBus.Event.SetTextWithFlags(self.PrimaryText, textString, eUiTextSet_SetLocalized)
  end
end
function LargeTab:SetSecondaryText(textString, skipLocalization)
  if skipLocalization then
    UiTextBus.Event.SetText(self.SecondaryText, textString)
  else
    UiTextBus.Event.SetTextWithFlags(self.SecondaryText, textString, eUiTextSet_SetLocalized)
  end
end
function LargeTab:SetIcon(iconPath)
  UiElementBus.Event.SetIsEnabled(self.Icon, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.GuildCrest, false)
  UiElementBus.Event.SetIsEnabled(self.Number, false)
  UiImageBus.Event.SetSpritePathname(self.Icon, iconPath)
  self.isShowingIcon = true
  self.isShowingCrest = false
  self.isShowingNumber = false
  self:UpdateVisualState()
end
function LargeTab:SetCrest(crestData)
  if crestData ~= nil then
    UiElementBus.Event.SetIsEnabled(self.Icon, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.GuildCrest, true)
    UiElementBus.Event.SetIsEnabled(self.Number, false)
    self.GuildCrest:SetSmallIcon(crestData)
    self.isShowingIcon = false
    self.isShowingCrest = true
    self.isShowingNumber = false
    self:UpdateVisualState()
  end
end
function LargeTab:SetNumber(number)
  UiElementBus.Event.SetIsEnabled(self.Icon, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.GuildCrest, false)
  UiElementBus.Event.SetIsEnabled(self.Number, true)
  UiTextBus.Event.SetText(self.Properties.Number, tostring(number))
  self.isShowingIcon = false
  self.isShowingCrest = false
  self.isShowingNumber = true
  self:UpdateVisualState()
end
function LargeTab:SetNumberIcon(numberIconPath)
  local shouldShowNumberIcon = numberIconPath ~= nil
  UiElementBus.Event.SetIsEnabled(self.Properties.NumberIcon, shouldShowNumberIcon)
  self.isShowingNumberIcon = shouldShowNumberIcon
  if shouldShowNumberIcon then
    UiImageBus.Event.SetSpritePathname(self.Icon, numberIconPath)
    self.ScriptedEntityTweener:Set(self.Number, {
      y = self.Properties.numberYWithIcon
    })
  else
    self.ScriptedEntityTweener:Set(self.Number, {
      y = self.Properties.numberYWithoutIcon
    })
  end
  self:UpdateVisualState()
end
function LargeTab:SetSelected(selected)
  if self.isSelected ~= selected then
    self.isSelected = selected
    self:UpdateVisualState()
  end
end
function LargeTab:SetWarning(warning)
  if self.isWarning ~= warning then
    self.isWarning = warning
    self:UpdateVisualState()
  end
end
function LargeTab:SetPressCallback(command, table, arg)
  self.callback = command
  self.callbackTable = table
  self.callbackArgument = arg
end
function LargeTab:SetUserData(userData)
  self.userData = userData
end
function LargeTab:GetUserData()
  return self.userData
end
function LargeTab:SetEnableSelectedState(isEnabled)
  if self.selectedStateEnabled ~= isEnabled then
    self.selectedStateEnabled = isEnabled
    self:UpdateVisualState()
  end
end
return LargeTab
