local Logger = RequireScript("LyShineUI.Automation.Logger")
local InputUtility = RequireScript("LyShineUI.Automation.Utilities.InputUtility")
local MenuStack = RequireScript("LyShineUI.Automation.MenuStack")
local MenuUtility = RequireScript("LyShineUI.Automation.Utilities.MenuUtility")
local DataLayer = RequireScript("LyShineUI.UiDataLayer")
local ChatData = RequireScript("LyShineUI.HUD.Chat.ChatData")
local TimerHandler = RequireScript("LyShineUI.Automation.Utilities.TimerHandler")
local ChatUtility = {
  ScreenName = "Chat",
  EmotesScreenName = "EmoteUI",
  ChatCRC = 3766762380,
  EmotesCRC = 663562859,
  CommandPrefix = "/"
}
function ChatUtility:Initialize()
  self.Chat = DynamicBus.Chat.Broadcast.GetTable()
  self.EmoteMenu = DynamicBus.EmoteUI.Broadcast.GetTable()
  self.ChannelPane = MenuUtility:GetEntityTable(self.Chat.Properties.ChatChannelList)
end
ChatUtility.Channels = {
  Global = {name = eChatMessageType_Global},
  Area = {name = eChatMessageType_Area},
  Help = {name = eChatMessageType_Help},
  Recruitment = {name = eChatMessageType_Recruitment},
  Faction = {name = eChatMessageType_Faction},
  Group = {name = eChatMessageType_Group},
  Army = {name = eChatMessageType_Raid},
  Company = {name = eChatMessageType_Guild},
  Consul = {name = eChatMessageType_Guild_Officer},
  DirectMessage = {name = eChatMessageType_Whisper},
  Emote = {name = eChatMessageType_Emote},
  System = {name = eChatMessageType_System}
}
ChatUtility.ChannelStatus = {
  Alert = 1,
  Feed = 2,
  Muted = 3
}
local function Log(msg)
  Logger:Log("[ChatUtility] " .. tostring(msg))
end
local function CloseChat()
  ChatUtility:CloseChannelSettings()
  ChatUtility:CloseChatSettings()
  coroutine.yield()
  if MenuStack:IsScreenOpen(ChatUtility.ScreenName) then
    local pos = MenuUtility:GetObjectViewportPosition(ChatUtility.Chat.Properties.ChatContainer, MenuUtility.Anchors.CenterRight)
    MenuUtility:ClickAt(Vector2(pos.x + 20, pos.y))
  end
end
local function OpenChat()
  InputUtility:PressKey("toggleChatComponent")
end
local function CloseEmotes()
  if MenuStack:IsScreenOpen(ChatUtility.EmotesScreenName) then
    InputUtility:PressKey("toggleEmoteWindow")
  end
end
local function OpenEmotes()
  InputUtility:PressKey("toggleEmoteWindow")
end
function ChatUtility:IsChatOpen()
  return not MenuStack:IsEmpty() and MenuStack:Peek().name == ChatUtility.ScreenName and MenuStack:VerifyScreen() and MenuStack:VerifyState() and ChatUtility.Chat.screenEnteredForChat
end
function ChatUtility:AreChatSettingsOpen()
  return self.Chat.settingsVisibility
end
function ChatUtility:AreChannelSettingsOpen()
  return self.ChannelPane.isChannelSettingsVisible
end
function ChatUtility:IsEmoteMenuOpen()
  return not MenuStack:IsEmpty() and MenuStack:Peek().name == ChatUtility.EmotesScreenName and MenuStack:VerifyScreen() and MenuStack:VerifyState()
end
function ChatUtility:OpenChat()
  MenuUtility:OpenMenu(ChatUtility.ScreenName, "Chat", OpenChat, CloseChat, ChatUtility.IsChatOpen, ChatUtility.ChatCRC)
end
function ChatUtility:WaitForChat()
  MenuUtility:WaitForMenu(self.OpenChat, self.IsChatOpen)
end
function ChatUtility:CloseChat()
  MenuUtility:CloseMenu(self.ScreenName, "Chat")
end
function ChatUtility:OpenEmotesMenu()
  MenuUtility:OpenMenu(ChatUtility.EmotesScreenName, "Emote menu", OpenEmotes, CloseEmotes, ChatUtility.IsEmoteMenuOpen, ChatUtility.EmotesCRC)
end
function ChatUtility:WaitForEmotesMenu()
  MenuUtility:WaitForMenu(self.OpenEmotesMenu, self.IsEmoteMenuOpen)
end
function ChatUtility:CloseEmotesMenu()
  MenuUtility:CloseMenu(self.EmotesScreenName, "Emote menu")
end
function ChatUtility:EnterText(text)
  if self:IsChatOpen() then
    UiTextInputBus.Event.SetText(MenuUtility:GetEntityId(self.Chat.ChatTextField), text)
    return true
  end
end
function ChatUtility:Send()
  if self:IsChatOpen() then
    DynamicBus.ChatBus.Broadcast.SendMessage()
    if DataLayer:GetDataFromNode("Hud.LocalPlayer.Options.Chat.ChatCloseAfterSending") then
      MenuStack:Pop()
    end
    return true
  end
end
function ChatUtility:GetChatMessages()
  if self:IsChatOpen() then
    local parsedMessages = {}
    local messages = MenuUtility:GetDynamicScrollBoxChildern(self.Chat.Properties.EntityChatBox)
    for i = 1, #messages do
      local chatMessage = MenuUtility:GetEntityTable(messages[i])
      if chatMessage then
        table.insert(parsedMessages, 1, {
          text = UiTextBus.Event.GetText(chatMessage:GetMessageField())
        })
      end
    end
    return parsedMessages
  end
end
function ChatUtility:SendCommand(command)
  if command:sub(1, #self.CommandPrefix) ~= self.CommandPrefix then
    command = self.CommandPrefix .. command
  end
  if not self:IsChatOpen() then
    self:WaitForChat()
  end
  if self:IsChatOpen() and self:EnterText(command) then
    return self:Send()
  end
end
function ChatUtility:OpenChatSettings()
  if self:IsChatOpen() and not self:AreChatSettingsOpen() then
    MenuUtility:ClickButton(self.Chat.Properties.ChatSettingsButton)
    return true
  end
end
function ChatUtility:CloseChatSettings()
  if self:AreChatSettingsOpen() then
    MenuUtility:ClickButton(self.Chat.Properties.ChatSettingsButton)
    return true
  end
end
function ChatUtility:GetChannelData(channel)
  return ChatData:GetChannelData(channel.name)
end
function ChatUtility:GetChannelButtons()
  local channelButtons = self.ChannelPane.channelButtonsByName
  channelButtons[ChatUtility.Channels.DirectMessage.name] = MenuUtility:GetChildren(self.ChannelPane.Properties.ChannelListWhisper)[1]
  for k, v in pairs(self.ChannelPane.whisperChannels) do
    channelButtons[k] = v
  end
  return channelButtons
end
function ChatUtility:SelectChannel(channel)
  if self:IsChatOpen() then
    local channelButtons = self:GetChannelButtons()
    local targetButton
    if channel then
      targetButton = channelButtons[channel.name]
    else
      targetButton = channelButtons[ChatData.feedChannelId]
    end
    if targetButton then
      MenuUtility:ClickButton(targetButton)
      return true
    end
  end
end
function ChatUtility:SelectChannelByName(channelName)
  if self:IsChatOpen() then
    ChatUtility:SelectChannel({name = channelName})
  end
end
function ChatUtility:GetCurrentChannel()
  if self:IsChatOpen() then
    local currentChannleButton = MenuUtility:GetEntityTable(self.Chat.Properties.ChannelPillsDropdown).CurrentChannelButton
    if currentChannleButton then
      return MenuUtility:GetEntityTable(currentChannleButton):GetChannelName()
    end
  end
end
function ChatUtility:EnterWhisperTarget(name)
  if self:IsChatOpen() and self:GetCurrentChannel() == ChatUtility.Channels.DirectMessage.name then
    UiTextInputBus.Event.SetText(MenuUtility:GetEntityId(self.Chat.WhisperTextField), name)
    return true
  end
end
function ChatUtility:OpenChannelSettings()
  if self:IsChatOpen() and not self:AreChannelSettingsOpen() then
    if not MenuUtility:GetEntityTable(self.Chat.Properties.ChatChannelListContainer).isFocused then
      MenuUtility:ClickButton(self.ChannelPane.Properties.SettingsButton)
      TimerHandler:Sleep(2)
    end
    MenuUtility:ClickButton(self.ChannelPane.Properties.SettingsButton)
  end
  return self:AreChannelSettingsOpen()
end
function ChatUtility:CloseChannelSettings()
  if self:AreChannelSettingsOpen() then
    MenuUtility:ClickButton(self.ChannelPane.Properties.SettingsButton)
    coroutine.yield()
  end
  return not self:AreChannelSettingsOpen()
end
function ChatUtility:GetChannelStatus(channel)
  if self:AreChannelSettingsOpen() then
    local settings = MenuUtility:GetEntityTable(self.ChannelPane.Properties.ChannelSettingsMenu)
    for i = 1, #settings.listItems do
      if settings.listItems[i].channelData.name == channel.name then
        local group = MenuUtility:GetChildByName(settings.listItems[i].entityId, settings.radioButtonGroupName)
        local buttons = MenuUtility:GetChildren(group)
        for j = 1, #buttons do
          if MenuUtility:GetRadioButtonState(buttons[j]) then
            return j
          end
        end
      end
    end
  end
end
function ChatUtility:ChangeChannelStatus(channel, status)
  if self:AreChannelSettingsOpen() then
    local settings = MenuUtility:GetEntityTable(self.ChannelPane.Properties.ChannelSettingsMenu)
    for i = 1, #settings.listItems do
      if settings.listItems[i].channelData.name == channel.name then
        local group = MenuUtility:GetChildByName(settings.listItems[i].entityId, settings.radioButtonGroupName)
        local buttons = MenuUtility:GetChildren(group)
        MenuUtility:ClickButton(buttons[status])
      end
    end
  end
end
function ChatUtility:GetAllEmotesData()
  return EmoteDataManagerBus.Broadcast.GetEmoteList()
end
function ChatUtility:GetAllEmotesCommands()
  local allEmotes = self:GetAllEmotesData()
  local allCommands = {}
  for i = 1, #allEmotes do
    table.insert(allCommands, allEmotes[i].slashCommand)
  end
  return allCommands
end
function ChatUtility:GetEmoteDataByCommand(command)
  local allEmotes = self:GetAllEmotesData()
  local allCommands = {}
  for i = 1, #allEmotes do
    if allEmotes[i].slashCommand == command then
      return allEmotes[i]
    end
  end
end
function ChatUtility:PickEmote(emoteData)
  if self:IsEmoteMenuOpen() then
    local buttons = MenuUtility:GetGridItemListChildren(self.EmoteMenu.Properties.SimpleGridItemList)
    for i = 1, #buttons do
      local button = MenuUtility:GetEntityTable(buttons[i])
      if button and button.GetText and button:GetText() == emoteData.displayName then
        MenuUtility:ClickButton(button)
        coroutine.yield()
        if DataLayer:GetDataFromNode("Hud.LocalPlayer.Options.Chat.ChatCloseAfterSending") then
          MenuStack:Pop()
        end
        return true
      end
    end
  end
end
return ChatUtility
