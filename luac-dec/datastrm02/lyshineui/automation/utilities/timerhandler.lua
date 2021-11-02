local Logger = RequireScript("LyShineUI.Automation.Logger")
local TimerHandled = RequireScript("LyShineUI.Automation.Utilities.TimerHandled")
local TimerHandler = {
  Initialized = false,
  timers = {},
  timerIndex = 1
}
TimerHandler.__index = TimerHandler
setmetatable(TimerHandler, {
  __call = function(cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end
})
function TimerHandler:GetTimer(timeout)
  Logger:Log("TimerHandler:GetTimer " .. timeout)
  timer = TimerHandled(timeout)
  table.insert(self.timers, timer)
  return timer
end
function TimerHandler:Init()
  Logger:Log("TimerHandler:Init")
  if not self.Initialized then
    self.Initialized = true
    self.TickHandler = TickBus.Connect(self)
  end
end
function TimerHandler:Shutdown()
  self.Initialized = false
  if self.TickHandler then
    self.TickHandler:Disconnect()
    self.TickHandler = nil
  end
end
function TimerHandler:OnTick(delta, timePoint)
  for k, t in pairs(self.timers) do
    if t:TimeUp() then
      table.remove(self.timers, k)
    else
      t:OnTick(delta, timePoint)
    end
  end
end
function TimerHandler:_init(time)
  self.tickHandler = TickBus.Connect(self)
end
function TimerHandler:Sleep(time)
  local timer = self:GetTimer(time)
  while not timer:TimeUp() do
    coroutine.yield()
  end
end
return TimerHandler
