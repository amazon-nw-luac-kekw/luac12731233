local RadioTab = {
  Properties = {
    Highlight = {
      default = EntityId()
    },
    Hatching = {
      default = EntityId()
    },
    Text = {
      default = EntityId()
    },
    TextPrefix = {
      default = EntityId()
    },
    ExtraIndicator = {
      default = EntityId()
    },
    UnreadBadge = {
      default = EntityId()
    }
  },
  highlightMaxOpacity = 0.15,
  hatchingMaxOpacity = 0.25,
  animationTime = 0.2,
  isShowingExtraIndicator = false,
  unreadNumber = 0,
  STYLE_PICA = 1,
  STYLE_NIMBUS = 2
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(RadioTab)
function RadioTab:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.TextPrefix, self.UIStyle.FONT_STYLE_RADIO_TAB_PREFIX)
  self:SetStyle(self.STYLE_PICA)
  if self.UnreadBadge then
    self.UnreadBadge:SetIsShowingText(false)
  end
  self.soundOnFocus = self.audioHelper.OnHover_ButtonSimpleText
  self.soundOnSelected = self.audioHelper.Accept
end
function RadioTab:OnShutdown()
  if self.highlightTimeline then
    self.ScriptedEntityTweener:TimelineDestroy(self.highlightTimeline)
  end
end
function RadioTab:OnHoverStart()
  if self.isSelected then
    return
  end
  self.audioHelper:PlaySound(self.soundOnFocus)
  if not self.highlightTimeline then
    self.highlightTimeline = self.ScriptedEntityTweener:TimelineCreate()
    self.highlightTimeline:Add(self.Highlight, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.05})
    self.highlightTimeline:Add(self.Highlight, self.UIStyle.DURATION_TIMELINE_FADE_IN, {
      opacity = self.highlightMaxOpacity
    })
    self.highlightTimeline:Add(self.Highlight, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = self.highlightMaxOpacity,
      onComplete = function()
        self.highlightTimeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, self.UIStyle.DURATION_BUTTON_FADE_IN, {
    opacity = self.highlightMaxOpacity,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = self.highlightMaxOpacity,
    delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
    onComplete = function()
      self.highlightTimeline:Play()
    end
  })
end
function RadioTab:OnHoverStop()
  if self.highlightTimeline then
    self.highlightTimeline:Stop()
    if self.isSelected then
      self.ScriptedEntityTweener:Play(self.Highlight, self.animationTime, {
        opacity = self.highlightMaxOpacity
      })
    else
      self.ScriptedEntityTweener:Play(self.Highlight, self.animationTime, {opacity = 0})
    end
  end
end
function RadioTab:OnSelected()
  self.audioHelper:PlaySound(self.soundOnSelected)
  self.isSelected = true
  if self.selectedCallback ~= nil and self.selectedCallbackTable ~= nil then
    self.selectedCallbackTable[self.selectedCallback](self.selectedCallbackTable, self.selectedCallbackArgument)
  end
  self:UpdateVisualState()
end
function RadioTab:OnDeselected()
  self.isSelected = false
  if self.deselectedCallback ~= nil and self.deselectedCallbackTable ~= nil then
    self.deselectedCallbackTable[self.deselectedCallback](self.deselectedCallbackTable, self.deselectedCallbackArgument)
  end
  self:UpdateVisualState()
end
function RadioTab:UpdateVisualState()
  if self.isSelected then
    self.ScriptedEntityTweener:Play(self.Text, self.animationTime, {
      textColor = self.UIStyle.COLOR_WHITE
    })
    self.ScriptedEntityTweener:Play(self.Highlight, self.animationTime, {
      opacity = self.highlightMaxOpacity
    })
    self.ScriptedEntityTweener:Play(self.Hatching, self.animationTime, {
      opacity = self.hatchingMaxOpacity
    })
  else
    self.ScriptedEntityTweener:Play(self.Text, self.animationTime, {
      textColor = self.deselectedTextColor
    })
    self.ScriptedEntityTweener:Play(self.Highlight, self.animationTime, {opacity = 0})
    self.ScriptedEntityTweener:Play(self.Hatching, self.animationTime, {opacity = 0})
  end
end
function RadioTab:SetText(textString, skipLocalization)
  if skipLocalization then
    UiTextBus.Event.SetText(self.Text, textString)
  else
    UiTextBus.Event.SetTextWithFlags(self.Text, textString, eUiTextSet_SetLocalized)
  end
end
function RadioTab:SetTextPrefix(textString, skipLocalization)
  if skipLocalization then
    UiTextBus.Event.SetText(self.TextPrefix, textString)
  else
    UiTextBus.Event.SetTextWithFlags(self.TextPrefix, textString, eUiTextSet_SetLocalized)
  end
end
function RadioTab:SetShowingExtraIndicator(show)
  if show == self.isShowingExtraIndicator then
    return
  elseif show then
    UiElementBus.Event.SetIsEnabled(self.ExtraIndicator, true)
    self.ScriptedEntityTweener:Play(self.ExtraIndicator, self.animationTime, {scaleY = 0}, {scaleY = 1, ease = "QuadOut"})
  else
    self.ScriptedEntityTweener:Play(self.ExtraIndicator, self.animationTime, {
      scaleY = 0,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.ExtraIndicator, false)
      end
    })
  end
  self.isShowingExtraIndicator = show
end
function RadioTab:SetSelectedCallback(command, table, argument)
  self.selectedCallback = command
  self.selectedCallbackTable = table
  self.selectedCallbackArgument = argument
end
function RadioTab:SetDeselectedCallback(command, table, argument)
  self.deselectedCallback = command
  self.deselectedCallbackTable = table
  self.deselectedCallbackArgument = argument
end
function RadioTab:SetStyle(styleIndex)
  local textStyle = self.UIStyle.FONT_STYLE_RADIO_TAB
  if styleIndex == self.STYLE_NIMBUS then
    textStyle = {
      fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_REGULAR,
      fontSize = 24,
      fontColor = self.UIStyle.COLOR_GRAY_60,
      characterSpacing = 25,
      textCasing = self.UIStyle.TEXT_CASING_NORMAL
    }
  end
  SetTextStyle(self.Properties.Text, textStyle)
  self.deselectedTextColor = textStyle.fontColor or self.UIStyle.COLOR_TAN
  self:UpdateVisualState()
end
function RadioTab:AddToRadioGroup(groupEntityId)
  UiRadioButtonGroupBus.Event.AddRadioButton(groupEntityId, self.entityId)
end
function RadioTab:SetUserData(userData)
  self:SetStyle(self.STYLE_NIMBUS)
  self:SetText(userData.title)
  UiElementBus.Event.SetIsEnabled(self.Properties.TextPrefix, false)
  self:SetUnreadNumber(userData.newPageCount or 0)
  self.userData = userData
end
function RadioTab:GetUserData()
  return self.userData
end
function RadioTab:SetUnreadNumber(number)
  if 0 < number then
    UiElementBus.Event.SetIsEnabled(self.Properties.UnreadBadge, true)
    self.UnreadBadge:SetNumber(number)
    if self.isVisible then
      self.UnreadBadge:StartAnimation(true)
    end
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.UnreadBadge, false)
    self.UnreadBadge:StopAnimation()
  end
  self.unreadNumber = number
end
function RadioTab:SetIsVisible(isVisible)
  if isVisible == self.isVisible then
    return
  end
  if isVisible and self.unreadNumber > 0 then
    self.UnreadBadge:StartAnimation(true)
  else
    self.UnreadBadge:StopAnimation()
  end
  self.isVisible = isVisible
end
return RadioTab
