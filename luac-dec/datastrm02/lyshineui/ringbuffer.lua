local RotateIndex = function(i, n)
  return (i - 1) % n + 1
end
local RingBuffer = {}
function RingBuffer:new(o)
  o = o or {}
  o.history = {}
  o.oldest = 1
  o.max_length = o.max_length or 100
  setmetatable(o, self)
  self.__index = self
  return o
end
function RingBuffer:IsFilled()
  return #self.history == self.max_length
end
function RingBuffer:Push(value)
  local removedValue
  if self:IsFilled() then
    removedValue = self.history[self.oldest]
    self.history[self.oldest] = value
    self.oldest = self.oldest == self.max_length and 1 or self.oldest + 1
  else
    self.history[#self.history + 1] = value
  end
  return removedValue
end
function RingBuffer:GetAt(i)
  local history_length = #self.history
  if i > history_length then
    return nil
  end
  if 1 <= i then
    local i_rotated = RotateIndex(self.oldest - 1 + (history_length + 1 - i), history_length)
    return self.history[i_rotated]
  elseif i <= -1 then
    local i_rotated = RotateIndex(self.oldest - 1 + i * -1, history_length)
    return self.history[i_rotated]
  end
end
function RingBuffer:GetCount()
  return #self.history
end
function RingBuffer:Clear()
  ClearTable(self.history)
  self.oldest = 1
end
return RingBuffer
