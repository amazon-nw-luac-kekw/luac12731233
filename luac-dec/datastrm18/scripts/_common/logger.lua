local RingBuffer = require("LyShineUI.RingBuffer")
local Logger = {
  SEND_ALL = 1,
  SEND_UNIQUE = 2,
  SEND_NOTHING = 3,
  LOGTYPE_MAX = 4,
  defaultChannelName = "Anonymous",
  channels = {},
  listeners = {}
}
function Logger:CreateChannel(name, sendToConsole)
  local channel = {
    name = name,
    sendToConsole = sendToConsole or self.SEND_NOTHING,
    messages = RingBuffer:new()
  }
  self.channels[name] = channel
  self:NotifyListeners("onCreatedChannel", channel)
  return channel
end
function Logger:GetChannel(name)
  local channel = self.channels[name]
  return channel
end
function Logger:ClearChannel(name)
  local channel = self:GetChannel(name)
  channel.messages = RingBuffer:new()
end
function Logger:AddTextToChannel(channel, text, duplicate)
  local shouldSendToConsole = false
  local message = {
    text = text,
    count = 1,
    timeStamp = self:GetTimeStamp()
  }
  if not duplicate then
    channel.messages:Push(message)
  end
  if channel.sendToConsole == self.SEND_ALL or channel.sendToConsole == self.SEND_UNIQUE and not duplicate then
    shouldSendToConsole = true
  end
  self:NotifyListeners("onLogToChannel", channel, message, duplicate)
  return shouldSendToConsole
end
function Logger:SetChannelMode(name, sendToConsole)
  local channel = self.channels[name]
  if channel then
    channel.sendToConsole = sendToConsole
  else
    self:CreateChannel(name, sendToConsole)
  end
end
function Logger:GetTimeStamp()
  local time = os.time()
  local t = os.date("*t", time)
  local ms = os.clock()
  ms = ms % 10
  local stamp = string.format("%02d:%02d:%02d  %.03f", t.hour, t.min, t.sec, ms)
  return stamp
end
function Logger:LogToChannel(channelName, text)
  if type(channelName) ~= "string" or type(text) ~= "string" then
    return
  end
  local channel = self.channels[channelName]
  channel = channel or self:CreateChannel(channelName)
  local duplicate = false
  if channel.messages:GetCount() > 0 then
    local lastMessage = channel.messages:GetAt(1)
    if lastMessage.text == text then
      lastMessage.count = lastMessage.count + 1
      lastMessage.timeStamp = self:GetTimeStamp()
      duplicate = true
    end
  end
  return self:AddTextToChannel(channel, text, duplicate)
end
function Logger:Log(fmt, ...)
  local text = ""
  local channels = {}
  if type(fmt) ~= "string" then
    if type(fmt) == "table" then
      channels = fmt
      if not fmt[1] then
        return
      end
    else
      if not fmt then
        return
      end
      channels = {
        self.defaultChannelName
      }
    end
    local newArgs = {}
    local count = select("#", ...)
    for i = 2, count do
      newArgs[i - 1] = select(i, ...)
    end
    text = string.format(select(1, ...), unpack(newArgs))
  else
    channels = {
      self.defaultChannelName
    }
    text = string.format(fmt, ...)
  end
  self:HandleLog(channels, text)
end
function Logger:HandleLog(channels, text)
  if type(channels) ~= "table" then
    return
  end
  local sentToConsole = false
  for k, channel in ipairs(channels) do
    if type(channel) == "boolean" and not channel then
      return
    end
    if type(channel) == "string" and self:LogToChannel(channel, text) and not sentToConsole then
      local callerInfo = debug.getinfo(4, "Sl")
      local src = callerInfo.short_src
      local line = callerInfo.currentline
      Debug.Log("\n" .. src .. "(" .. line .. "): " .. text)
      sentToConsole = true
    end
  end
end
function Logger:AddListener(listener)
  if type(listener) ~= "table" then
    return
  end
  self.listeners[listener] = listener
end
function Logger:RemoveListener(listener)
  self.listeners[listener] = nil
end
function Logger:NotifyListeners(logEvent, ...)
  for k, v in pairs(self.listeners) do
    if type(v[logEvent]) == "function" then
      v[logEvent](v, ...)
    end
  end
end
Logger:CreateChannel(Logger.defaultChannelName, Logger.SEND_ALL)
return Logger
