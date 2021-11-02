local Timer = {}
Timer.__index = Timer
setmetatable(Timer, {
  __call = function(cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end
})
function Timer:OnTick(delta, timePoint)
  self.timeRemaining = self.timeRemaining - delta
  self.timeElapsed = self.timeElapsed + delta
  if self:TimeUp() then
    self.tickHandler:Disconnect()
  end
end
function Timer:_init(time)
  self.timeRemaining = time
  self.timeElapsed = 0
  self.tickHandler = TickBus.Connect(self)
end
function Timer:TimeUp()
  return self.timeRemaining <= 0
end
function Timer.Sleep(time)
  local timer = Timer(time)
  while not timer:TimeUp() do
    coroutine.yield()
  end
end
return Timer
