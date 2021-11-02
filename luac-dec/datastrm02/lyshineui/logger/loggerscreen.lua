local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
local SlashCommands = RequireScript("LyShineUI.SlashCommands")
local LoggerScreen = {
  Properties = {
    ChannelList = {
      default = EntityId()
    },
    ChannelMessagesList = {
      default = EntityId()
    },
    MoveButtonText = {
      default = EntityId()
    }
  },
  channelListDirty = false,
  dirtyChannels = {},
  channelEntitiesToChannelId = {},
  maxMessagesInList = 100,
  framesSinceMessageFill = 0,
  currentChannelName = "",
  onRight = true
}
BaseScreen:CreateNewScreen(LoggerScreen)
function LoggerScreen:OnInit()
  BaseScreen.OnInit(self)
  if not g_Logger then
    Debug.Log("Logger system not initialized!")
    return
  end
  self.logger = g_Logger
  self.logger:AddListener(self)
  SlashCommands:RegisterSlashCommand("logger", self.onSlashLogger, self)
end
function LoggerScreen:OnShutdown()
  if self.logger then
    self.logger:RemoveListener(self)
    self.logger = nil
  end
end
function LoggerScreen:OnTick(deltaTime, timePoint)
  if self.channelListDirty then
    self:FillChannelList()
  end
  self.framesSinceMessageFill = self.framesSinceMessageFill + 1
  if self.framesSinceMessageFill > 60 then
    local channel = self.logger:GetChannel(self.currentChannelName)
    if channel and self.dirtyChannels[self.currentChannelName] then
      self:FillMessageList(channel)
    end
  end
end
function LoggerScreen:EchoHelp()
  Log({"Logger"}, "usage: ")
  Log({"Logger"}, "    /logger <channelName> setMode [all|unique|off] -- sets echo mode for channel (default is all)")
  Log({"Logger"}, "    /logger <channelName> echo [count] -- echos the last [count] messages from the channel (default is all)")
  Log({"Logger"}, "    /logger <channelName> clear -- deletes all message in the channel")
end
function LoggerScreen:onSlashLogger(args)
  if not self.tickBus then
    self.tickBus = self:BusConnect(DynamicBus.UITickBus)
  end
  if #args == 2 then
    if args[2] == "help" then
      self:EchoHelp()
      return
    end
    return
  end
  if #args == 1 then
    LyShineManagerBus.Broadcast.TryShowById(self.canvasId)
    self.channelListDirty = true
    return
  end
  local channelName = args[2]
  local command = args[3]
  local channel = self.logger:GetChannel(channelName)
  if not channel then
    Log({"Logger"}, "Channel %s does not exist", tostring(channelName))
    return
  end
  if command == "setMode" then
    local mode = args[4] or "all"
    if mode == "all" then
      self.logger:SetChannelMode(channelName, self.logger.SEND_ALL)
      self.channelListDirty = true
      return
    end
    if mode == "unique" then
      self.logger:SetChannelMode(channelName, self.logger.SEND_UNIQUE)
      self.channelListDirty = true
      return
    end
    if mode == "off" then
      self.logger:SetChannelMode(channelName, self.logger.SEND_NOTHING)
      self.channelListDirty = true
      return
    end
    Log({"Logger"}, "Unknown mode. Use all, unqique, or off")
    return
  end
  if command == "clear" then
    self.logger:ClearChannel(channelName)
    return
  end
  if command == "echo" then
    local count = math.floor(tonumber(args[4] or channel.messages:GetCount()))
    count = math.min(count, channel.messages:GetCount())
    for i = 1, count do
      local message = channel.messages:GetAt(i)
      local out = ""
      if 1 < message.count then
        out = string.format("%s(%d):%s", channelName, message.count, message.text)
      else
        out = string.format("%s:%s", channelName, message.text)
      end
      Debug.Log(out)
    end
    return
  end
  self:EchoHelp()
end
function LoggerScreen:OnClose()
  LyShineManagerBus.Broadcast.TryHideById(self.canvasId)
  if self.tickBus then
    DynamicBus.UITickBus.Disconnect(self.entityId, self)
    self.tickBus = nil
  end
end
function LoggerScreen:OnMove(entityId, actionName)
  local anchors = UiTransform2dBus.Event.GetAnchors(self.entityId)
  local offsets = UiTransform2dBus.Event.GetOffsets(self.entityId)
  local text = ">"
  if self.onRight then
    anchors.left = 0
    anchors.right = 0
    offsets.left = 0
    offsets.right = 600
    text = ">"
  else
    anchors.left = 1
    anchors.right = 1
    offsets.left = -600
    offsets.right = 0
    text = "<"
  end
  self.onRight = not self.onRight
  UiTextBus.Event.SetText(self.Properties.MoveButtonText, text)
  UiTransform2dBus.Event.SetAnchorsScript(self.entityId, anchors)
  UiTransform2dBus.Event.SetOffsets(self.entityId, offsets)
end
function LoggerScreen:onCreatedChannel(channel)
  self.channelListDirty = true
end
function LoggerScreen:onLogToChannel(channel, message, duplicate)
  self.dirtyChannels[channel.name] = true
  self.channelListDirty = true
end
function LoggerScreen:UpdateChannelEntry(childElement, channel)
  local nameText = UiElementBus.Event.FindChildByName(childElement, "Name")
  local countText = UiElementBus.Event.FindChildByName(childElement, "Count")
  local logType = UiElementBus.Event.FindChildByName(childElement, "LogType")
  local logTypeText = UiElementBus.Event.FindChildByName(logType, "Text")
  local sendToConsoleStrings = {
    "Send All",
    "Only Unique",
    "None"
  }
  local countString = tostring(channel.messages:GetCount())
  if self.dirtyChannels[channel.name] then
    countString = countString .. "(*)"
  end
  UiTextBus.Event.SetText(nameText, tostring(channel.name))
  UiTextBus.Event.SetText(countText, countString)
  UiTextBus.Event.SetText(logTypeText, tostring(sendToConsoleStrings[channel.sendToConsole]))
end
function LoggerScreen:FillChannelList()
  local count = 0
  for k, v in pairs(self.logger.channels) do
    count = count + 1
  end
  UiDynamicLayoutBus.Event.SetNumChildElements(self.Properties.ChannelList, count)
  local i = 0
  local selected
  for k, channel in pairs(self.logger.channels) do
    local childElement = UiElementBus.Event.GetChild(self.Properties.ChannelList, i)
    self.channelEntitiesToChannelId[tostring(childElement)] = channel.name
    self:UpdateChannelEntry(childElement, channel)
    if channel.name == self.currentChannelName then
      selected = childElement
    end
    i = i + 1
  end
  if selected then
    UiRadioButtonGroupBus.Event.SetState(self.Properties.ChannelList, selected, true)
  end
  self.channelListDirty = false
end
function LoggerScreen:OnAction(entityId, actionName)
  if not BaseScreen.OnAction(self, entityId, actionName) and type(self[actionName]) == "function" then
    self[actionName](self, entityId, actionName)
  end
end
function LoggerScreen:OnLogTypeClick(entityId)
  local channelElement = UiElementBus.Event.GetParent(entityId)
  local channelName = self.channelEntitiesToChannelId[tostring(channelElement)]
  if not channelName then
    return
  end
  local channel = self.logger.channels[channelName]
  if not channel then
    return
  end
  channel.sendToConsole = channel.sendToConsole + 1
  if channel.sendToConsole > self.logger.SEND_NOTHING then
    channel.sendToConsole = self.logger.SEND_ALL
  end
  self:UpdateChannelEntry(channelElement, channel)
end
function LoggerScreen:FillMessageList(channel)
  local count = math.min(self.maxMessagesInList, channel.messages:GetCount())
  local start = 1
  UiDynamicLayoutBus.Event.SetNumChildElements(self.Properties.ChannelMessagesList, count)
  local i = 0
  for msgNum = count, start, -1 do
    local message = channel.messages:GetAt(msgNum)
    local childElement = UiElementBus.Event.GetChild(self.Properties.ChannelMessagesList, i)
    local channelText = UiElementBus.Event.FindChildByName(childElement, "ChannelName")
    local countElement = UiElementBus.Event.FindChildByName(childElement, "Count")
    local messageText = UiElementBus.Event.FindChildByName(childElement, "Message")
    local countText = UiElementBus.Event.FindChildByName(countElement, "Text")
    UiTextBus.Event.SetText(channelText, tostring(message.timeStamp))
    UiTextBus.Event.SetText(countText, tostring(message.count))
    UiTextBus.Event.SetText(messageText, message.text)
    UiElementBus.Event.SetIsEnabled(countElement, 1 < message.count)
    i = i + 1
  end
  self.dirtyChannels[channel.name] = nil
  self.channelListDirty = true
  self.framesSinceMessageFill = 0
end
function LoggerScreen:OnChannelClick(entityId)
  local channelName = self.channelEntitiesToChannelId[tostring(entityId)]
  if not channelName then
    return
  end
  local channel = self.logger.channels[channelName]
  self.currentChannelName = channelName
  self:FillMessageList(channel)
end
return LoggerScreen
