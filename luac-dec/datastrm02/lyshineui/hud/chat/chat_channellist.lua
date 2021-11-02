local Chat_ChannelList = {
  Properties = {
    ChannelListButtonPrototype = {
      default = EntityId()
    },
    ChannelListPublic = {
      default = EntityId()
    },
    ChannelListPrivate = {
      default = EntityId()
    },
    ChannelListWhisper = {
      default = EntityId()
    },
    DividerPublic = {
      default = EntityId()
    },
    DividerPrivate = {
      default = EntityId()
    },
    DividerWhisper = {
      default = EntityId()
    },
    BG = {
      default = EntityId()
    },
    ScrollBar = {
      default = EntityId()
    }
  },
  totalWhisperChannels = 0,
  activeChannelButton = nil,
  viewedChannelName = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(Chat_ChannelList)
local chatData = RequireScript("LyShineUI.HUD.Chat.ChatData")
function Chat_ChannelList:OnInit()
  local chatChannelData = chatData.chatChannels
  self.channelButtonsByName = {
    [chatData.feedChannelId] = self.ChannelListButtonPrototype
  }
  self.ChannelListButtonPrototype:InitChannelData({
    name = chatData.feedChannelId,
    displayName = "@ui_chat_feed",
    widgetIcon = "lyshineui/images/icons/chat/channelFeed.png",
    color = self.UIStyle.COLOR_WHITE
  }, self.OnChannelClicked, self, chatData.feedChannelId)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.clonedElements = {}
  local numPublic = 0
  local numPrivate = 0
  for _, channelData in ipairs(chatChannelData) do
    if channelData.canFilter then
      local listEntity = channelData.isPublicChannel and self.Properties.ChannelListPublic or self.Properties.ChannelListPrivate
      local clonedElement = CloneUiElement(self.canvasId, self.registrar, self.Properties.ChannelListButtonPrototype, listEntity, true)
      clonedElement:InitChannelData(channelData, self.OnChannelClicked, self, channelData.name)
      table.insert(self.clonedElements, clonedElement)
      self.channelButtonsByName[channelData.name] = clonedElement
      clonedElement:SetIsVisible(channelData.hasPermission)
      if channelData.isPublicChannel then
        numPublic = numPublic + 1
      else
        numPrivate = numPrivate + 1
      end
    end
  end
  self.buttonHeight = UiLayoutCellBus.Event.GetTargetHeight(self.Properties.ChannelListButtonPrototype)
  self.dividerHeight = UiLayoutCellBus.Event.GetTargetHeight(self.Properties.DividerPublic)
  self:ResizeChannelList(self.Properties.ChannelListPublic)
  self:ResizeChannelList(self.Properties.ChannelListPrivate)
  self.defaultWhisperChannelName = ".whisperChannelName"
  self.whisperChannels = {}
  self:AddWhisperChannel({
    name = self.defaultWhisperChannelName,
    displayName = "@ui_chat_name_whisperto",
    widgetIcon = "lyshineui/images/icons/chat/channelAddDirect.png",
    color = self.UIStyle.COLOR_CHAT_DIRECT,
    isDirectMessage = true,
    isDefaultWhisperChannel = true
  })
  DynamicBus.Chat_ChannelList.Connect(self.entityId, self)
  self:OnChannelClicked(chatData.feedChannelId)
  local lastChannel = self.dataLayer:GetDataFromNode("Chat.Last.Channel")
  local lastActiveOutputChannel = self.dataLayer:GetDataFromNode("Chat.Last.ActiveOutputChannel")
  if lastChannel ~= nil then
    self:OnChannelClicked(lastChannel)
  end
  if lastActiveOutputChannel ~= nil and lastActiveOutputChannel ~= lastChannel then
    DynamicBus.ChatBus.Broadcast.SetActiveOutputChannel(lastActiveOutputChannel, true)
  end
end
function Chat_ChannelList:SetContainingChannelPane(paneTable)
  self.containingChannelPane = paneTable
end
function Chat_ChannelList:GetIsChannelSettingsVisible()
  return self.isChannelSettingsVisible
end
function Chat_ChannelList:SetScrollBarVisible(isVisible)
  self.ScriptedEntityTweener:Stop(self.Properties.ScrollBar)
  if isVisible then
    self.ScriptedEntityTweener:Play(self.Properties.ScrollBar, 0.2, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  else
    self.ScriptedEntityTweener:Play(self.Properties.ScrollBar, 0.1, {opacity = 0, ease = "QuadOut"})
  end
end
function Chat_ChannelList:OnShutdown()
  if self.clonedElements then
    for _, elementTable in ipairs(self.clonedElements) do
      UiElementBus.Event.DestroyElement(elementTable.entityId)
    end
  end
  DynamicBus.Chat_ChannelList.Disconnect(self.entityId, self)
end
function Chat_ChannelList:SetChannelFocused(isFocused)
  self.ChannelListButtonPrototype:SetChannelFocusState(isFocused)
  for _, elements in ipairs(self.clonedElements) do
    elements:SetChannelFocusState(isFocused)
  end
end
function Chat_ChannelList:ResizeChannelList(channelListId)
  local children = UiElementBus.Event.GetChildren(channelListId)
  local enabledCount = 0
  for i = 1, #children do
    if UiElementBus.Event.IsEnabled(children[i]) then
      enabledCount = enabledCount + 1
    end
  end
  UiLayoutCellBus.Event.SetTargetHeight(channelListId, enabledCount * self.buttonHeight)
  local divider = self.Properties.DividerPrivate
  if channelListId == self.Properties.ChannelListPublic then
    divider = self.Properties.DividerPublic
  elseif channelListId == self.Properties.ChannelListWhisper then
    divider = self.Properties.DividerWhisper
  end
  local showDivider = 0 < enabledCount
  UiElementBus.Event.SetIsEnabled(divider, showDivider)
  UiLayoutCellBus.Event.SetTargetHeight(divider, showDivider and self.dividerHeight or 0)
end
function Chat_ChannelList:AddWhisperChannel(channelData)
  local addWhisperElement = CloneUiElement(self.canvasId, self.registrar, self.Properties.ChannelListButtonPrototype, self.Properties.ChannelListWhisper, true)
  addWhisperElement:InitChannelData(channelData, self.OnWhisperClicked, self, channelData.name)
  table.insert(self.clonedElements, addWhisperElement)
  self.totalWhisperChannels = self.totalWhisperChannels + 1
  addWhisperElement:SetIsActive(false)
  UiLayoutCellBus.Event.SetTargetHeight(self.Properties.ChannelListWhisper, self.buttonHeight * self.totalWhisperChannels)
  if channelData.name then
    self.whisperChannels[channelData.name] = addWhisperElement
  end
end
function Chat_ChannelList:OnChannelAvailabilityChanged(channelName, isAvailable)
  local button = self.channelButtonsByName[channelName]
  if button then
    button:SetIsVisible(isAvailable)
    local channelList = UiElementBus.Event.GetParent(button.entityId)
    self:ResizeChannelList(channelList)
  end
end
function Chat_ChannelList:OnChannelDataChanged(channelName, newChannelData)
  local button = self.channelButtonsByName[channelName]
  if button then
    button:SetChannelData(newChannelData)
    local channelList = UiElementBus.Event.GetParent(button.entityId)
    self:ResizeChannelList(channelList)
  end
end
function Chat_ChannelList:AppendWhisperChannelTableInfo(targetWhisperChannelData, whisperTarget)
  targetWhisperChannelData.displayName = whisperTarget
  targetWhisperChannelData.name = whisperTarget
  targetWhisperChannelData.playerName = whisperTarget
  targetWhisperChannelData.isDirectMessage = true
end
function Chat_ChannelList:OnWhisperChannelAdded(whisperTarget)
  local baseWhisperChannelData = chatData:GetChannelData(eChatMessageType_Whisper)
  local targetWhisperChannelData = DeepClone(baseWhisperChannelData)
  self:AppendWhisperChannelTableInfo(targetWhisperChannelData, whisperTarget)
  self:AddWhisperChannel(targetWhisperChannelData)
end
function Chat_ChannelList:OnWhisperChannelUpdated(oldWhisperTarget, newWhisperTarget)
  local whisperChannelButton = self.whisperChannels[oldWhisperTarget]
  self.whisperChannels[newWhisperTarget] = whisperChannelButton
  self.whisperChannels[oldWhisperTarget] = nil
  local channelData = {}
  self:AppendWhisperChannelTableInfo(channelData, newWhisperTarget)
  whisperChannelButton:InitChannelData(channelData, self.OnWhisperClicked, self, newWhisperTarget)
  if self.viewedChannelName == oldWhisperTarget then
    self:OnChannelClicked(newWhisperTarget)
  end
end
function Chat_ChannelList:OnWhisperClicked(whisperTarget)
  if whisperTarget == self.defaultWhisperChannelName then
    whisperTarget = nil
  end
  DynamicBus.ChatBus.Broadcast.OpenWhisperToPlayer(whisperTarget)
  self:OnChannelClicked(whisperTarget)
end
function Chat_ChannelList:OnChannelClicked(channelName)
  if self.viewedChannelName == channelName then
    return
  end
  local outputChannel = chatData:GetChannelData(channelName)
  local canSelectForOutput = true
  if outputChannel then
    canSelectForOutput = DynamicBus.ChatBus.Broadcast.CanSelectOutputChannel(outputChannel, true)
  end
  if canSelectForOutput or channelName == chatData.feedChannelId then
    DynamicBus.ChatBus.Broadcast.SwitchViewedChannel(channelName)
    self:UpdateViewedChannel(channelName)
  elseif channelName == nil then
    self:UpdateViewedChannel(self.defaultWhisperChannelName)
  end
end
function Chat_ChannelList:UpdateViewedChannel(channelName)
  self.viewedChannelName = channelName
  if self.activeChannelButton then
    self.activeChannelButton:SetIsActive(false)
  end
  local channelButton = self.channelButtonsByName[channelName] or self.whisperChannels[channelName] or nil
  self.activeChannelButton = channelButton
  if channelButton then
    channelButton:SetIsActive(true)
  end
end
return Chat_ChannelList
