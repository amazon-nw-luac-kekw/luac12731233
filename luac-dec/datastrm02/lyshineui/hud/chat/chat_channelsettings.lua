local Chat_ChannelSettings = {
  Properties = {
    RadioButtonsPrototype = {
      default = EntityId()
    },
    RadioButtonsList = {
      default = EntityId()
    },
    QuestionMarkAlert = {
      default = EntityId()
    },
    QuestionMarkFeed = {
      default = EntityId()
    },
    QuestionMarkMuted = {
      default = EntityId()
    }
  },
  radioButtonGroupName = "ChannelSettingRadioButtons"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(Chat_ChannelSettings)
local chatData = RequireScript("LyShineUI.HUD.Chat.ChatData")
function Chat_ChannelSettings:OnInit()
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.QuestionMarkAlert:SetTooltip("@ui_chat_alert_tooltip")
  self.QuestionMarkAlert:SetButtonStyle(self.QuestionMarkAlert.BUTTON_STYLE_QUESTION_MARK)
  self.QuestionMarkAlert:SetSize(18)
  self.QuestionMarkFeed:SetTooltip("@ui_chat_feed_tooltip")
  self.QuestionMarkFeed:SetButtonStyle(self.QuestionMarkFeed.BUTTON_STYLE_QUESTION_MARK)
  self.QuestionMarkFeed:SetSize(18)
  self.QuestionMarkMuted:SetTooltip("@ui_chat_muted_tooltip")
  self.QuestionMarkMuted:SetButtonStyle(self.QuestionMarkMuted.BUTTON_STYLE_QUESTION_MARK)
  self.QuestionMarkMuted:SetSize(18)
  local chatChannelData = chatData.chatChannels
  self.listItems = {}
  for i = 1, #chatChannelData do
    local channelData = chatChannelData[i]
    if channelData.canFilter or channelData.name == eChatMessageType_Whisper then
      local clonedElement = CloneUiElement(self.canvasId, self.registrar, self.Properties.RadioButtonsPrototype, self.Properties.RadioButtonsList, true)
      table.insert(self.listItems, {entityId = clonedElement, channelData = channelData})
    end
  end
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Options.Chat.ChannelSettingsReset", function(self, hudAlwaysFade)
    local totalHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.RadioButtonsList)
    local chatTypesToStates = OptionsDataBus.Broadcast.GetChatTypeStates()
    for _, listItem in ipairs(self.listItems) do
      local channelData = listItem.channelData
      local channelState = eChatMessageTypeState_Feed
      for i = 1, #chatTypesToStates do
        local chatTypeToState = chatTypesToStates[i]
        if channelData.name == chatTypeToState.messageType then
          channelState = chatTypeToState.messageState
          break
        end
      end
      local clonedElement = listItem.entityId
      self:SetRowChatData(clonedElement, channelData)
      local radioButtonGroup = UiElementBus.Event.FindChildByName(clonedElement, self.radioButtonGroupName)
      local radioButtons = UiElementBus.Event.GetChildren(radioButtonGroup)
      for i = 1, #radioButtons do
        local button = self.registrar:GetEntityTable(radioButtons[i])
        button:AddToGroup(radioButtonGroup)
      end
      UiRadioButtonGroupBus.Event.SetState(radioButtonGroup, radioButtons[channelState + 1], true)
      local elementHeight = UiLayoutCellBus.Event.GetTargetHeight(clonedElement)
      totalHeight = totalHeight + elementHeight
      UiTransform2dBus.Event.SetLocalHeight(self.entityId, totalHeight)
    end
  end)
  UiElementBus.Event.Reparent(self.Properties.RadioButtonsPrototype, EntityId(), EntityId())
  UiElementBus.Event.SetIsEnabled(self.Properties.RadioButtonsPrototype, false)
end
function Chat_ChannelSettings:SetRowChatData(rowEntityId, channelData)
  UiElementBus.Event.SetIsEnabled(rowEntityId, true)
  local icon = UiElementBus.Event.FindChildByName(rowEntityId, "Icon")
  UiImageBus.Event.SetSpritePathname(icon, channelData.widgetIcon)
  UiImageBus.Event.SetColor(icon, channelData.color)
  local label = UiElementBus.Event.FindChildByName(rowEntityId, "Label")
  UiTextBus.Event.SetTextWithFlags(label, channelData.displayName, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetColor(label, channelData.color)
end
function Chat_ChannelSettings:OnChannelDataChanged(channelName, newChannelData)
  for _, listItem in pairs(self.listItems) do
    if listItem.channelData.name == channelName then
      self:SetRowChatData(listItem.entityId, newChannelData)
      break
    end
  end
end
function Chat_ChannelSettings:OnShutdown()
  if self.listItems then
    for _, listItem in ipairs(self.listItems) do
      if listItem.entityId ~= self.Properties.RadioButtonsPrototype then
        UiElementBus.Event.DestroyElement(listItem.entityId)
      end
    end
  end
end
function Chat_ChannelSettings:OnRadioButtonChanged(radioGroupEntityId)
  local checkedButtonId = UiRadioButtonGroupBus.Event.GetState(radioGroupEntityId)
  local radioButtonIndex = UiElementBus.Event.GetIndexOfChildByEntityId(radioGroupEntityId, checkedButtonId)
  for _, listItem in ipairs(self.listItems) do
    local radioButtons = UiElementBus.Event.FindChildByName(listItem.entityId, self.radioButtonGroupName)
    if radioButtons == radioGroupEntityId then
      local channelName = listItem.channelData.name
      DynamicBus.ChatNotifications.Broadcast.OnChatChannelSettingChanged(channelName, radioButtonIndex)
      local chatTypesToStates = OptionsDataBus.Broadcast.GetChatTypeStates()
      local updatedExistingValue = false
      for i = 1, #chatTypesToStates do
        local chatTypeToState = chatTypesToStates[i]
        if channelName == chatTypeToState.messageType then
          chatTypeToState.messageState = radioButtonIndex
          updatedExistingValue = true
          break
        end
      end
      if not updatedExistingValue then
        local chatMessageTypeToState = ChatMessageTypeToState()
        chatMessageTypeToState.messageType = channelName
        chatMessageTypeToState.messageState = radioButtonIndex
        chatTypesToStates:push_back(chatMessageTypeToState)
      end
      OptionsDataBus.Broadcast.SerializeOptions()
      local chatChannelData = chatData:GetChannelData(channelName)
      if chatChannelData and chatChannelData.metricName then
        local event = UiAnalyticsEvent("Chat_ChannelMute")
        event:AddAttribute("ChannelName", chatChannelData.metricName)
        event:AddAttribute("IsMuted", tostring(radioButtonIndex == eChatMessageTypeState_Muted))
        event:Send()
      end
      break
    end
  end
end
return Chat_ChannelSettings
