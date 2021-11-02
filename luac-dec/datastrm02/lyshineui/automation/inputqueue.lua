local Logger = RequireScript("LyShineUI.Automation.Logger")
local InputQueue = {
  queue = {},
  queueIndex = 1,
  processTimer = 0,
  processInputInterval = 0.25,
  defaultExtraIteration = 1,
  extraProcessIteration = 1,
  initialized = false,
  tickHandler = nil
}
function InputQueue:Reset()
  self.queue = {}
  self.queueIndex = 1
  self.extraProcessIteration = self.defaultExtraIteration
end
function InputQueue:Init()
  if not self.initialized then
    self.initialized = true
    self:Reset()
  end
end
function InputQueue:Initialize()
  self.tickHandler = TickBus.Connect(self)
end
function InputQueue:Shutdown()
  self.initialized = false
  self:Reset()
  if self.tickHandler then
    self.tickHandler:Disconnect()
    self.tickHandler = nil
  end
end
function InputQueue:Flush()
  Logger:Log("Info: InputQueue:Flush()")
  self.initialized = false
  self:Reset()
end
function InputQueue:OnTick(delta)
  if self.processTimer >= self.processInputInterval then
    self:ProcessInput()
    self.processTimer = self.processTimer - self.processInputInterval
  else
    self.processTimer = self.processTimer + delta
  end
end
function InputQueue:AddToQueue(functionPointer)
  self:Init()
  table.insert(self.queue, functionPointer)
end
function InputQueue:IsQueueEmpty()
  return #self.queue == 0
end
function InputQueue:ProcessInput(delta)
  if self.queueIndex <= #self.queue then
    local inputFunc = self.queue[self.queueIndex]
    inputFunc()
    self.queueIndex = self.queueIndex + 1
  elseif self.extraProcessIteration > 0 then
    self.extraProcessIteration = self.extraProcessIteration - 1
  else
    self:Flush()
  end
end
return InputQueue
