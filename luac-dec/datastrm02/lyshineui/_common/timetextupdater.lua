local TimeTextUpdater = {
  Properties = {
    TimeText = {
      default = EntityId()
    }
  },
  omitZeros = false,
  FORMAT_HRS_MIN_SEC = 0,
  FORMAT_SHORTHAND = 1,
  format = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TimeTextUpdater)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function TimeTextUpdater:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
end
function TimeTextUpdater:OnShutdown()
end
function TimeTextUpdater:SetCurrentCountdownTime(timeRemainingSeconds)
  self.timeRemainingSeconds = timeRemainingSeconds
  self:UpdateTimeText()
  self:SetTicking(true)
end
function TimeTextUpdater:SetOmitZeros(omitZeros)
  self.omitZeros = omitZeros
end
function TimeTextUpdater:SetFormat(format)
  self.format = format
  if self.timeRemainingSeconds then
    self:UpdateTimeText()
  end
end
function TimeTextUpdater:SetTicking(shouldTick)
  if shouldTick then
    if not self.tickBusHandler then
      self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
    end
  else
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
  end
end
function TimeTextUpdater:OnTick(deltaTime, timePoint)
  self.timeRemainingSeconds = self.timeRemainingSeconds - deltaTime
  if self.timeRemainingSeconds < 0 then
    self.timeRemainingSeconds = 0
    if self.timerCompleteCallback then
      self.timerCompleteCallback(self.timerCompleteTable, self)
    end
    self:SetTicking(false)
  elseif not UiCanvasBus.Event.GetEnabled(self.canvasId) then
    self:SetTicking(false)
  end
  self:UpdateTimeText()
end
function TimeTextUpdater:UpdateTimeText()
  if self.format == self.FORMAT_HRS_MIN_SEC then
    local timeRemainingText = timeHelpers:ConvertSecondsToHrsMinSecString(self.timeRemainingSeconds, false, self.omitZeros, true)
    UiTextBus.Event.SetText(self.Properties.TimeText, timeRemainingText)
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.TimeText, timeHelpers:ConvertToShorthandString(self.timeRemainingSeconds), eUiTextSet_SetLocalized)
  end
end
function TimeTextUpdater:SetTimerCompleteCallback(command, table)
  self.timerCompleteCallback = command
  self.timerCompleteTable = table
end
function TimeTextUpdater:OverrideTimeText(text)
  UiTextBus.Event.SetTextWithFlags(self.Properties.TimeText, text, eUiTextSet_SetLocalized)
end
return TimeTextUpdater
