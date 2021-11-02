local ChannelPillsDropdown = {
  Properties = {
    CurrentButtonBackground = {
      default = EntityId()
    },
    CurrentChannelButton = {
      default = EntityId()
    },
    DropdownHolder = {
      default = EntityId()
    },
    DropdownList = {
      default = EntityId()
    }
  },
  isExpanded = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ChannelPillsDropdown)
local chatData = RequireScript("LyShineUI.HUD.Chat.ChatData")
function ChannelPillsDropdown:OnInit()
  self:SetChannels()
  self.CurrentChannelButton:SetCallback(self.OnCurrentChannelButtonClicked, self)
end
function ChannelPillsDropdown:SetChannels(channelsToShow)
  if channelsToShow == nil then
    channelsToShow = {}
    for i = 1, #chatData.chatChannels do
      if chatData.chatChannels[i] and chatData.chatChannels[i].canOutput then
        table.insert(channelsToShow, chatData.chatChannels[i])
      end
    end
  end
  UiDynamicLayoutBus.Event.SetNumChildElements(self.Properties.DropdownList, #channelsToShow)
  local childElements = UiElementBus.Event.GetChildren(self.Properties.DropdownList)
  local widest = 0
  for i = 1, #childElements do
    local pillButtonTable = self.registrar:GetEntityTable(childElements[i])
    if pillButtonTable then
      pillButtonTable:SetChannelData(channelsToShow[i])
      pillButtonTable:SetCallback(self.OnOptionClicked, self)
      widest = math.max(widest, pillButtonTable:GetWidth())
    end
  end
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, widest)
  self.listWidth = widest
  self.listHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.DropdownList)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.DropdownHolder, self.listHeight)
end
function ChannelPillsDropdown:SetIsExpanded(isExpanded)
  if isExpanded == self.isExpanded then
    return
  elseif isExpanded then
    UiElementBus.Event.SetIsEnabled(self.Properties.DropdownHolder, true)
    self.ScriptedEntityTweener:Play(self.Properties.DropdownHolder, 0.2, {h = 0}, {
      h = self.listHeight,
      ease = "QuadOut"
    })
    self.isExpanded = true
    self:CheckPermissions()
  else
    self.ScriptedEntityTweener:Play(self.Properties.DropdownHolder, 0.2, {
      h = 0,
      ease = "QuadIn",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.Properties.DropdownHolder, false)
        self.isExpanded = false
      end
    })
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.CurrentButtonBackground, isExpanded)
end
function ChannelPillsDropdown:SetActiveChannel(channelName)
  for i = 1, #chatData.chatChannels do
    if chatData.chatChannels[i].name == channelName then
      self.CurrentChannelButton:SetChannelData(chatData.chatChannels[i])
      return
    end
  end
end
function ChannelPillsDropdown:SetCallback(command, table)
  self.callback = command
  self.callbackTable = table
end
function ChannelPillsDropdown:SetCanExpand(canExpand)
  self.canExpand = canExpand
  self.CurrentChannelButton:SetCanInteract(self.canExpand)
  if not self.canExpand then
    self:SetIsExpanded(false)
  end
end
function ChannelPillsDropdown:OnChannelAvailabilityChanged()
  self:CheckPermissions()
end
function ChannelPillsDropdown:OnChannelDataChanged(channelName, newChannelData)
  local childElements = UiElementBus.Event.GetChildren(self.Properties.DropdownList)
  local updatedButtonWidth = 0
  for i = 1, #childElements do
    local pillButtonTable = self.registrar:GetEntityTable(childElements[i])
    if pillButtonTable and pillButtonTable:GetChannelName() == channelName then
      pillButtonTable:SetChannelData(newChannelData)
      updatedButtonWidth = pillButtonTable:GetWidth()
    end
  end
  if self.CurrentChannelButton:GetChannelName() == channelName then
    self.CurrentChannelButton:SetChannelData(newChannelData)
  end
  if updatedButtonWidth > self.listWidth then
    self.listWidth = updatedButtonWidth
    UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.listWidth)
  end
end
function ChannelPillsDropdown:CheckPermissions()
  local childElements = UiElementBus.Event.GetChildren(self.Properties.DropdownList)
  for i = 1, #childElements do
    local pillButtonTable = self.registrar:GetEntityTable(childElements[i])
    if pillButtonTable then
      local channelData = pillButtonTable:GetChannelData()
      if channelData then
        local canSelect = DynamicBus.ChatBus.Broadcast.CanSelectOutputChannel(channelData)
        pillButtonTable:SetCanInteract(canSelect)
      end
    end
  end
end
function ChannelPillsDropdown:OnOptionClicked(channelData)
  self:SetIsExpanded(false)
  if self.callbackTable and type(self.callback) == "function" then
    self.callback(self.callbackTable, channelData)
  end
end
function ChannelPillsDropdown:OnCurrentChannelButtonClicked()
  self:SetIsExpanded(not self.isExpanded)
end
return ChannelPillsDropdown
