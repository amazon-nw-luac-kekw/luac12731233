local Logger = RequireScript("LyShineUI.Automation.Logger")
local TimerHandled = {}
TimerHandled.__index = TimerHandled
setmetatable(TimerHandled, {
  __call = function(cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end
})
function TimerHandled:OnTick(delta, timePoint)
  self.timeRemaining = self.timeRemaining - delta
  self.timeElapsed = self.timeElapsed + delta
  if self.timeRemaining <= 0 then
    self.timeUp = true
  end
end
function TimerHandled:_init(time)
  self.timeRemaining = time
  self.timeElapsed = 0
  self.timeUp = false
end
function TimerHandled:TimeUp()
  return self.timeUp
end
return TimerHandled
