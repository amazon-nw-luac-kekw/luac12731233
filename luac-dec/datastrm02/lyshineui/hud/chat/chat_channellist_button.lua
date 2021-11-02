local chatChannelData = RequireScript("LyShineUI.HUD.Chat.ChatData")
local Chat_ChannelList_Button = {
  Properties = {
    ChannelIcon = {
      default = EntityId()
    },
    PlayerIcon = {
      default = EntityId()
    },
    ChannelName = {
      default = EntityId()
    },
    UnreadCountContainer = {
      default = EntityId()
    },
    UnreadCountText = {
      default = EntityId()
    },
    SelectedHighlight = {
      default = EntityId()
    },
    SelectedHighlightText = {
      default = EntityId()
    },
    MutedIcon = {
      default = EntityId()
    },
    ChannelPane = {
      default = EntityId()
    }
  },
  currentChannel = chatChannelData.feedChannelId,
  channelName = chatChannelData.feedChannelId,
  unreadMessages = 0,
  isActive = false,
  areChannelsFocused = false,
  focusedIconOpacity = 1,
  MUTED_ICON_OPACITY = 0.7,
  INACTIVE_ICON_OPACITY = 0.4
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(Chat_ChannelList_Button)
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
function Chat_ChannelList_Button:OnInit()
  local channelNameStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_SEMIBOLD,
    fontSize = 24,
    hAlignment = self.UIStyle.TEXT_HALIGN_LEFT
  }
  SetTextStyle(self.Properties.ChannelName, channelNameStyle)
  self.highlightPulse = self.ScriptedEntityTweener:TimelineCreate()
  self.highlightPulse:Add(self.Properties.SelectedHighlight, 0.35, {opacity = 0.7, ease = "QuadOut"})
  self.highlightPulse:Add(self.Properties.SelectedHighlight, 0.05, {opacity = 0.7})
  self.highlightPulse:Add(self.Properties.SelectedHighlight, 0.6, {
    opacity = 0.3,
    ease = "QuadIn",
    onComplete = function()
      self.highlightPulse:Play()
    end
  })
  self.defaultHeight = UiLayoutCellBus.Event.GetTargetHeight(self.entityId)
  self:SetChannelFocusState(false)
  UiElementBus.Event.SetIsEnabled(self.Properties.UnreadCountContainer, false)
end
function Chat_ChannelList_Button:OnShutdown()
  DynamicBus.ChatNotifications.Disconnect(self.entityId, self)
  self.ScriptedEntityTweener:TimelineDestroy(self.highlightPulse)
end
function Chat_ChannelList_Button:InitChannelData(channelData, callbackFn, callbackTable, callbackData)
  self:SetChannelData(channelData)
  self.dataLayer:RegisterDataCallback(self, "Hud.Chat.CurrentChannel", function(self, channelName)
    self.currentChannel = channelName
    if self.channelName == self.currentChannel or self.currentChannel == chatChannelData.feedChannelId and DynamicBus.ChatBus.Broadcast.IsChannelInFeed(self.isDirectMessage and eChatMessageType_Whisper or self.channelName) then
      self:ClearUnread()
    end
  end)
  DynamicBus.ChatNotifications.Connect(self.entityId, self)
  self.callbackFn = callbackFn
  self.callbackTable = callbackTable
  self.callbackData = callbackData
  self.dataLayer:RegisterDataObserver(self, "Hud.Chat.Visibility", function(self, isVisible)
    self.isVisible = isVisible
    self:UpdateUnreadText()
  end)
  local directMessageMuted = false
  if self.isDirectMessage then
    local savedChatTypeToStates = OptionsDataBus.Broadcast.GetChatTypeStates()
    for i = 1, #savedChatTypeToStates do
      local chatTypeToState = savedChatTypeToStates[i]
      if chatTypeToState.messageType == eChatMessageType_Whisper and chatTypeToState.messageState == eChatMessageTypeState_Muted then
        directMessageMuted = true
        break
      end
    end
    self:SetIsMuted(directMessageMuted)
    return
  end
  self:SetIsMuted(not DynamicBus.ChatBus.Broadcast.IsChannelInFeed(self.channelName))
end
function Chat_ChannelList_Button:SetChannelData(channelData)
  if not channelData.color then
    channelData.color = self.UIStyle.COLOR_WHITE
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.ChannelName, channelData.displayName, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetColor(self.Properties.ChannelName, channelData.color)
  UiElementBus.Event.SetIsEnabled(self.Properties.ChannelIcon, channelData.widgetIcon ~= nil)
  if channelData.widgetIcon then
    UiImageBus.Event.SetSpritePathname(self.Properties.ChannelIcon, channelData.widgetIcon)
    UiImageBus.Event.SetColor(self.Properties.ChannelIcon, channelData.color)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.PlayerIcon, false)
  if channelData.isDirectMessage and not channelData.isDefaultWhisperChannel then
    SocialDataHandler:GetPlayerIdentificationByName_ServerCall(self, function(self, result)
      if 0 < #result then
        local playerId = result[1].playerId
        self.PlayerIcon:SetPlayerId(playerId)
        UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.PlayerIcon, false)
        UiElementBus.Event.SetIsEnabled(self.Properties.PlayerIcon, true)
      end
    end, function()
    end, channelData.playerName)
  end
  self.channelName = channelData.name
  self.isPublicChannel = channelData.isPublicChannel
  self.isDirectMessage = channelData.isDirectMessage
  self.channelColor = channelData.color
  self.canBeMuted = channelData.canOutput
end
function Chat_ChannelList_Button:GetIsPublicChannel()
  return self.isPublicChannel
end
function Chat_ChannelList_Button:GetIsDirectMessage()
  return self.isDirectMessage
end
function Chat_ChannelList_Button:OnChatMessageReceived(chatMessageData)
  if chatMessageData.chatType ~= self.channelName or chatMessageData.isPingMessage then
    return
  end
  local hasUnreadMessage = false
  if self.currentChannel == chatChannelData.feedChannelId then
    hasUnreadMessage = not DynamicBus.ChatBus.Broadcast.IsChannelInFeed(self.isDirectMessage and eChatMessageType_Whisper or self.channelName)
  else
    hasUnreadMessage = self.currentChannel ~= self.channelName
  end
  if hasUnreadMessage then
    self.unreadMessages = self.unreadMessages + 1
    self:UpdateUnreadText()
  end
end
function Chat_ChannelList_Button:SetChannelFocusState(isFocused, animTime)
  animTime = animTime or 0.3
  UiElementBus.Event.SetIsEnabled(self.Properties.ChannelName, isFocused)
  UiElementBus.Event.SetIsEnabled(self.Properties.SelectedHighlightText, isFocused)
  if isFocused then
    if 0 < animTime then
      self.ScriptedEntityTweener:Set(self.Properties.ChannelName, {opacity = 0})
      self.ScriptedEntityTweener:Set(self.Properties.SelectedHighlightText, {opacity = 0})
    end
    self.ScriptedEntityTweener:Play(self.Properties.ChannelName, animTime, {
      opacity = self.focusedIconOpacity,
      ease = "QuadOut",
      delay = 0.1
    })
    self.ScriptedEntityTweener:Play(self.Properties.SelectedHighlightText, animTime, {opacity = 0.8, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ChannelIcon, animTime, {
      opacity = self.focusedIconOpacity,
      ease = "QuadOut"
    })
    if self.isMuted then
      self.ScriptedEntityTweener:Play(self.Properties.MutedIcon, animTime, {
        imgColor = self.UIStyle.COLOR_GRAY_80,
        ease = "QuadOut"
      })
    end
  elseif not self.isActive then
    self.ScriptedEntityTweener:Play(self.Properties.ChannelIcon, animTime, {
      opacity = self.INACTIVE_ICON_OPACITY,
      ease = "QuadOut"
    })
    if self.isMuted then
      self.ScriptedEntityTweener:Play(self.Properties.MutedIcon, animTime, {
        imgColor = self.UIStyle.COLOR_GRAY_50,
        ease = "QuadOut"
      })
    end
  end
  self.areChannelsFocused = isFocused
end
function Chat_ChannelList_Button:UpdateUnreadText()
  if self.isVisible then
    UiElementBus.Event.SetIsEnabled(self.Properties.UnreadCountContainer, self.unreadMessages ~= 0)
    UiTextBus.Event.SetText(self.Properties.UnreadCountText, tostring(self.unreadMessages))
  end
end
function Chat_ChannelList_Button:ClearUnread()
  if self.unreadMessages ~= 0 then
    self.unreadMessages = 0
    self:UpdateUnreadText()
  end
end
function Chat_ChannelList_Button:OnChannelFocusChanged()
  if self.unreadMessages ~= 0 then
    self.unreadMessages = 0
    self:UpdateUnreadText()
  end
end
function Chat_ChannelList_Button:SetIsActive(isActive)
  self.isActive = isActive
  UiElementBus.Event.SetIsEnabled(self.Properties.SelectedHighlight, isActive)
  local iconOpacity = self.areChannelsFocused and self.focusedIconOpacity or self.INACTIVE_ICON_OPACITY
  if isActive then
    self.highlightPulse:Stop()
    UiFaderBus.Event.SetFadeValue(self.Properties.SelectedHighlight, 1)
    iconOpacity = 1
  end
  self.ScriptedEntityTweener:Play(self.Properties.ChannelIcon, 0.3, {opacity = iconOpacity, ease = "QuadOut"})
end
function Chat_ChannelList_Button:SetIsVisible(isVisible)
  UiLayoutCellBus.Event.SetTargetHeight(self.entityId, isVisible and self.defaultHeight or 0)
  UiElementBus.Event.SetIsEnabled(self.entityId, isVisible)
  if not isVisible then
    self:ClearUnread()
  end
end
function Chat_ChannelList_Button:SetIsMuted(isMuted)
  if not self.canBeMuted and not self.isDirectMessage then
    return
  end
  local unreadColor = isMuted and self.UIStyle.COLOR_GRAY_50 or self.UIStyle.COLOR_YELLOW
  self.ScriptedEntityTweener:Play(self.Properties.UnreadCountContainer, self.unreadMessages > 0 and 0.3 or 0, {imgColor = unreadColor, ease = "QuadOut"})
  self.focusedIconOpacity = isMuted and self.MUTED_ICON_OPACITY or 1
  self.isMuted = isMuted
  UiElementBus.Event.SetIsEnabled(self.Properties.MutedIcon, isMuted)
  self:SetChannelFocusState(self.areChannelsFocused, 0)
end
function Chat_ChannelList_Button:OnFocus()
  if not self.isActive then
    UiFaderBus.Event.SetFadeValue(self.Properties.SelectedHighlight, 0)
    UiElementBus.Event.SetIsEnabled(self.Properties.SelectedHighlight, true)
    self.highlightPulse:Play()
  end
  self.ChannelPane:OnFocus()
end
function Chat_ChannelList_Button:OnUnfocus()
  if not self.isActive then
    self.highlightPulse:Stop()
    self.ScriptedEntityTweener:Play(self.Properties.SelectedHighlight, 0.15, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.Properties.SelectedHighlight, false)
      end
    })
  end
end
function Chat_ChannelList_Button:OnClick()
  if self.callbackFn then
    self.callbackFn(self.callbackTable, self.callbackData)
  end
end
function Chat_ChannelList_Button:OnChatChannelSettingChanged(channelName, chatMessageTypeState)
  if channelName == self.channelName or self.isDirectMessage and channelName == eChatMessageType_Whisper then
    self:SetIsMuted(chatMessageTypeState == eChatMessageTypeState_Muted)
  end
end
return Chat_ChannelList_Button
