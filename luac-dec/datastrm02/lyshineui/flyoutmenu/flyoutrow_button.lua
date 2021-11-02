local FlyoutRow_Button = {
  Properties = {
    Button = {
      default = EntityId()
    },
    ButtonTextSecondary = {
      default = EntityId()
    },
    ButtonTextTertiary = {
      default = EntityId()
    },
    ButtonTextTimer = {
      default = EntityId()
    },
    ButtonTextCost = {
      default = EntityId()
    },
    ButtonTextTotal = {
      default = EntityId()
    },
    TimerIcon = {
      default = EntityId()
    },
    QuestionMark = {
      default = EntityId()
    }
  },
  callback = nil,
  callbackTable = nil,
  callbackData = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FlyoutRow_Button)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
function FlyoutRow_Button:OnInit()
  BaseElement.OnInit(self)
  self.originalRowHeight = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  self.originalButtonHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.Button)
  self.originalButtonWidth = self.Button:GetWidth()
  self.padding = self.originalRowHeight - self.originalButtonHeight
  self.originalColor = self.Button:GetTextColor()
  self.QuestionMark:SetButtonStyle(self.QuestionMark.BUTTON_STYLE_QUESTION_MARK)
  SetTextStyle(self.Properties.ButtonTextSecondary, self.UIStyle.FONT_STYLE_FLYOUT_BUTTON_TEXT)
end
function FlyoutRow_Button:OnShutdown()
  timingUtils:StopDelay(self)
end
function FlyoutRow_Button:SetData(data)
  timingUtils:StopDelay(self)
  if not data then
    Log("[FlyoutRow_Button] Error: invalid data passed to SetData")
    return
  end
  self.Button:SetText(data.buttonText or "", data.skipLocalization, false)
  if data.skipLocalization then
    UiTextBus.Event.SetText(self.Properties.ButtonTextSecondary, data.buttonText or "")
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.ButtonTextSecondary, data.buttonText or "", eUiTextSet_SetLocalized)
  end
  self.Button:SetTextColor(data.color or self.originalColor)
  if data.hint then
    self.Button:SetHint(data.hint, data.hintIsKeybind)
  end
  self.Button:SetTooltip(data.tooltipInfo)
  self:SetFlyoutRowButtonEnabledState(data.isEnabled, data.forceUpdate)
  UiElementBus.Event.SetIsEnabled(self.Properties.QuestionMark, data.showQuestionMark)
  if data.icon then
    self.Button:SetButtonSingleIconPath(data.icon, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTextSecondary, true)
    self.Button:SetText("", data.skipLocalization)
  else
    self.Button:SetButtonSingleIconPath(nil)
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTextSecondary, false)
  end
  self:SetFlyoutRowButtonTimerText(data.timer)
  self:SetFlyoutRowButtonTimerIcon(data.timerIcon)
  UiTextBus.Event.SetText(self.Properties.ButtonTextCost, data.cost or "")
  UiTextBus.Event.SetText(self.Properties.ButtonTextTotal, data.total or "")
  if data.refreshTimer then
    timingUtils:Delay(1, self, function(self)
      local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
      local timeRemaining = math.max(data.timeWallClock:Subtract(now):ToSecondsUnrounded(), 0)
      local timeBeforeRecall = timeHelpers:ConvertSecondsToHrsMinSecString(timeRemaining)
      local timeText
      if data.timerLocTag then
        timeText = GetLocalizedReplacementText(data.timerLocTag, {time = timeBeforeRecall})
      else
        timeText = timeBeforeRecall
      end
      UiTextBus.Event.SetText(self.Properties.ButtonTextTimer, timeText)
      if timeRemaining == 0 and data.timerEndCallback and data.callbackTable then
        data.timerEndCallback(data.callbackTable, self)
      end
      local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
      local canvasEnabled = UiCanvasBus.Event.GetEnabled(canvasId)
      local isStillEnabled = UiElementBus.Event.GetAreElementAndAncestorsEnabled(self.entityId)
      if not (isStillEnabled and canvasEnabled) or timeRemaining == 0 then
        timingUtils:StopDelay(self)
      end
    end, true)
  end
  if data.callback then
    self:SetCallback(data.callback, data.callbackTable, data.callbackData)
    self.Button:SetCallback(self.OnButtonClick, self)
  end
  local buttonHeight = self:SetFlyoutRowButtonTextTertiary(data.buttonTextTertiary)
  self.bottomPadding = data.bottomPadding or 28
  self:SetFlyoutRowButtonSize(buttonHeight)
end
function FlyoutRow_Button:UpdateDataForTimerEnd(data)
  if not data then
    Log("[FlyoutRow_Button] Error: invalid data passed to UpdateDataForTimerEnd")
    return
  end
  if data.callback then
    self:SetCallback(data.callback, data.callbackTable, data.callbackData)
  end
  if data.isEnabled then
    self.Button:SetButtonStyle(self.buttonStyle)
  end
  self:SetFlyoutRowButtonEnabledState(data.isEnabled, data.forceUpdate)
  self:SetFlyoutRowButtonTimerText()
  self:SetFlyoutRowButtonTimerIcon(data.timerIcon)
  local buttonHeight = self:SetFlyoutRowButtonTextTertiary(data.buttonTextTertiary)
  self:SetFlyoutRowButtonSize(buttonHeight)
end
function FlyoutRow_Button:SetFlyoutRowButtonEnabledState(isEnabled, forceUpdate)
  if isEnabled then
    self.Button:SetEnabled(true, 0.3, forceUpdate)
    self.ScriptedEntityTweener:Set(self.Properties.ButtonTextSecondary, {
      textColor = self.UIStyle.COLOR_WHITE
    })
  elseif isEnabled == false then
    self.Button:SetEnabled(false, 0.3, forceUpdate)
    self.ScriptedEntityTweener:Set(self.Properties.ButtonTextSecondary, {
      textColor = self.UIStyle.COLOR_GRAY_50
    })
  end
end
function FlyoutRow_Button:SetFlyoutRowButtonSize(buttonHeight)
  self.Button:SetSize(self.originalButtonWidth, buttonHeight)
  local topPadding = 0
  local height = buttonHeight + topPadding + self.bottomPadding
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, height)
  UiLayoutCellBus.Event.SetTargetHeight(self.entityId, height)
end
function FlyoutRow_Button:SetFlyoutRowButtonTimerText(timerText)
  UiTextBus.Event.SetText(self.Properties.ButtonTextTimer, timerText or "")
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.ButtonTextSecondary, timerText and 200 or 286)
end
function FlyoutRow_Button:SetFlyoutRowButtonTimerIcon(timerIcon)
  UiElementBus.Event.SetIsEnabled(self.Properties.TimerIcon, timerIcon)
  if timerIcon then
    UiImageBus.Event.SetSpritePathname(self.Properties.TimerIcon, timerIcon)
  end
end
function FlyoutRow_Button:SetFlyoutRowButtonTextTertiary(buttonTextTertiary)
  local buttonHeight = 52
  if buttonTextTertiary then
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTextTertiary, true)
    UiTextBus.Event.SetTextWithFlags(self.Properties.ButtonTextTertiary, buttonTextTertiary, eUiTextSet_SetLocalized)
    local textHeight = UiTextBus.Event.GetTextHeight(self.Properties.ButtonTextTertiary)
    buttonHeight = buttonHeight + textHeight + 4
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTextTertiary, false)
  end
  return buttonHeight
end
function FlyoutRow_Button:SetCallback(command, table, data)
  self.callback = command
  self.table = table
  self.data = data
end
function FlyoutRow_Button:ExecuteCallback()
  if self.callback and self.table then
    if type(self.callback) == "function" then
      self.callback(self.table, self.data)
    elseif type(self.table[self.callback]) == "function" then
      self.table[self.callback](self.table, self.data)
    end
  end
end
function FlyoutRow_Button:OnButtonClick()
  self:ExecuteCallback()
  DynamicBus.FlyoutMenuBus.Broadcast.OnClickBackground()
end
return FlyoutRow_Button
