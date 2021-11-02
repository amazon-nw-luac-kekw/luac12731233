local HoverIntentDetector = {}
HoverIntentDetector.hoverCallingTable = nil
HoverIntentDetector.hoverCallback = nil
HoverIntentDetector.mouseVelocitySqThreshold = 10000
HoverIntentDetector.timeMouseSlowBeforeHover = 0.1
HoverIntentDetector.timeMouseSlow = 0.1
function HoverIntentDetector:OnHoverDetected(callingTable, functionToCall)
  self.lastCursorPos = CursorBus.Broadcast.GetCursorPosition()
  self.hoverCallingTable = callingTable
  self.hoverCallback = functionToCall
end
function HoverIntentDetector:StopHoverDetected(callingTable)
  if self.hoverCallingTable == callingTable then
    self:Reset()
  end
end
function HoverIntentDetector:OnTick(deltaTime, timePoint)
  if not self.hoverCallingTable then
    return
  end
  local currentCursorPos = CursorBus.Broadcast.GetCursorPosition()
  local delta = currentCursorPos - self.lastCursorPos
  local velocitySq = (delta.x * delta.x + delta.y * delta.y) / (deltaTime * deltaTime)
  if velocitySq < self.mouseVelocitySqThreshold then
    self.timeMouseSlow = self.timeMouseSlow - deltaTime
  else
    self.timeMouseSlow = self.timeMouseSlowBeforeHover
  end
  if self.timeMouseSlow <= 0 then
    self.hoverCallback(self.hoverCallingTable)
    self:Reset()
  end
  self.lastCursorPos = currentCursorPos
end
function HoverIntentDetector:Reset()
  self.hoverCallingTable = nil
  self.hoverCallback = nil
end
return HoverIntentDetector
