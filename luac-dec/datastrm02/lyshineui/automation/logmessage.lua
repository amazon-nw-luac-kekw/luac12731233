local LogMessage = {}
LogMessage.__index = LogMessage
setmetatable(LogMessage, {
  __call = function(cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end
})
function LogMessage:_init(fmt, ...)
  self.timestamp = os.time()
  self.message = "[UXAutomation] " .. string.format(fmt, ...)
end
function LogMessage:DeserializedMessage()
  return tostring(self.timestamp) .. " " .. self.message
end
return LogMessage
