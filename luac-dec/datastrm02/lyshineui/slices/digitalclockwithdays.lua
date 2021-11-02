local DigitalClockWithDays = {
  Properties = {
    TimerDaysTextElement = {
      default = EntityId()
    },
    TimerHoursTextElement = {
      default = EntityId()
    },
    TimerMinutesTextElement = {
      default = EntityId()
    },
    TimerSecondsTextElement = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(DigitalClockWithDays)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function DigitalClockWithDays:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
end
function DigitalClockWithDays:OnShutdown()
end
function DigitalClockWithDays:SetTimeSeconds(numSeconds, tickTimer)
  local days, hours, minutes, seconds = timeHelpers:ConvertSecondsToDaysHoursMinutesSeconds(numSeconds)
  UiTextBus.Event.SetText(self.Properties.TimerDaysTextElement, string.format("%02d", days))
  UiTextBus.Event.SetText(self.Properties.TimerHoursTextElement, string.format("%02d", hours))
  UiTextBus.Event.SetText(self.Properties.TimerMinutesTextElement, string.format("%02d", minutes))
  UiTextBus.Event.SetText(self.Properties.TimerSecondsTextElement, string.format("%02d", seconds))
  if tickTimer then
    if not self.tickBusHandler then
      self.tickBusHandler = DynamicBus.UITickBus.Connect(self.entityId, self)
    end
    self.timeRemainingSeconds = numSeconds
  end
end
function DigitalClockWithDays:StopTimerTick()
  if self.tickBusHandler then
    self.tickBusHandler = nil
    DynamicBus.UITickBus.Disconnect(self.entityId, self)
  end
end
function DigitalClockWithDays:OnTick(deltaTime)
  self.timeRemainingSeconds = math.max(self.timeRemainingSeconds - deltaTime, 0)
  self:SetTimeSeconds(self.timeRemainingSeconds)
  if self.timeRemainingSeconds == 0 or not UiCanvasBus.Event.GetEnabled(self.canvasId) then
    self:StopTimerTick()
  end
end
return DigitalClockWithDays
