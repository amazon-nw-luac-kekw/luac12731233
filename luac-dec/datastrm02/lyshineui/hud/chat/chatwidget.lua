local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local ChatWidget = {
  Properties = {
    ChannelIconContainer = {
      default = EntityId(),
      order = 1
    },
    ChannelIconPrototype = {
      default = EntityId(),
      order = 1
    },
    Button = {
      default = EntityId()
    },
    HighPriorityFlash = {
      default = EntityId()
    },
    HoverHighlight = {
      default = EntityId()
    },
    UnseenMessagesContainer = {
      default = EntityId(),
      order = 2
    },
    UnseenMessagesCount = {
      default = EntityId(),
      order = 2
    },
    ChatAlerts = {
      default = EntityId(),
      order = 3
    }
  },
  isChatVisibleInHud = true,
  isFlyoutShowing = false,
  isInHiddenState = true,
  isInDisabledState = false,
  totalUnread = 0,
  isFtue = false,
  screenStatesToHide = {
    [2702338936] = true,
    [849925872] = true,
    [921202721] = true,
    [3406343509] = true,
    [0] = true,
    [3766762380] = true
  },
  screenStatesToDisable = {},
  screenStatesWithoutInteraction = {
    [2702338936] = true,
    [0] = true,
    [3766762380] = true
  }
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(ChatWidget)
local chatData = RequireScript("LyShineUI.HUD.Chat.ChatData")
function ChatWidget:OnInit()
  BaseScreen.OnInit(self)
  self.isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
  local chatChannelData = chatData.chatChannels
  UiImageBus.Event.SetSpritePathname(self.Properties.ChannelIconPrototype, "lyshineui/images/icons/chat/channelFeed.png")
  UiImageBus.Event.SetColor(self.Properties.ChannelIconPrototype, self.UIStyle.COLOR_GRAY_50)
  UiFaderBus.Event.SetFadeValue(self.Properties.ChannelIconPrototype, 0)
  self.messageTypeToData = {
    [chatData.feedChannelId] = {
      unreadMessages = 0,
      widgetIconEntity = self.Properties.ChannelIconPrototype,
      isInFeed = false
    }
  }
  for i, data in ipairs(chatChannelData) do
    if data.canFilter then
      data.unreadMessages = 0
      data.highPriorityMessages = false
      data.isInFeed = DynamicBus.ChatBus.Broadcast.IsChannelInFeed(data.name)
      local channelIcon = CloneUiElement(self.canvasId, self.registrar, self.Properties.ChannelIconPrototype, self.Properties.ChannelIconContainer, true)
      UiImageBus.Event.SetSpritePathname(channelIcon, data.widgetIcon)
      data.widgetIconEntity = channelIcon
      self.messageTypeToData[data.name] = data
    end
  end
  self:UpdateTotalUnread()
  self.dataLayer:RegisterDataObserver(self, "Hud.Chat.Visibility", function(self, isVisible)
    self.isChatVisibleInHud = isVisible
    if isVisible then
      self:OnViewedMessageType(self.viewedChannel)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_chatWidget", function(self, isEnabled)
    self.isChatWidgetEnabled = isEnabled and not self.isFtue
    UiCanvasBus.Event.SetEnabled(self.canvasId, self.isChatWidgetEnabled == true)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.Chat.CurrentChannel", self.OnViewedChannelChanged)
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Group.Id", function(self, groupId)
    local isInGroup = groupId and groupId:IsValid()
    if not isInGroup then
      self:OnViewedMessageType(eChatMessageType_Group)
    end
  end)
  self.dataLayer:RegisterDataObserver(self, "Chat.HasOfficerPermission", function(self, hasPermission)
    if not hasPermission then
      self:OnViewedMessageType(eChatMessageType_Guild_Officer)
    end
  end)
  self.chatHandler = DynamicBus.ChatBus.Connect(self.entityId, self)
  self.chatNotificationHandler = DynamicBus.ChatNotifications.Connect(self.entityId, self)
  self.channelListHandler = DynamicBus.Chat_ChannelList.Connect(self.entityId, self)
  UiElementBus.Event.SetIsEnabled(self.Properties.UnseenMessagesContainer, false)
end
function ChatWidget:SetIsWidgetButtonClickable(isClickable)
  self.isWidgetButtonClickable = isClickable
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.Button, isClickable)
  if not isClickable then
    self:OnWidgetUnfocus()
  end
end
function ChatWidget:FlashWidgetVisibility()
  if not self.isWidgetVisible then
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    self.ScriptedEntityTweener:PlayC(self.Properties.Button, 0.25, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:Play(self.Properties.Button, 1, {
      opacity = 0,
      delay = 1.5,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.entityId, false)
      end
    })
  end
end
function ChatWidget:OnChatMessageReceived(chatMessageData)
  if chatMessageData.isPingMessage then
    return
  end
  local isChatVisible = self.isChatVisibleInHud or DynamicBus.ChatBus.Broadcast.IsInWidgetState()
  if not isChatVisible or self.viewedChannel ~= chatData.feedChannelId and chatMessageData.chatType ~= self.viewedChannel then
    self:OnUnseenMessageQueued(chatMessageData.chatType)
  end
end
function ChatWidget:OnShutdown()
  BaseScreen.OnShutdown(self)
  if self.chatNotificationHandler then
    DynamicBus.ChatNotifications.Disconnect(self.entityId, self)
    self.chatNotificationHandler = nil
  end
  if self.chatHandler then
    DynamicBus.ChatBus.Disconnect(self.entityId, self)
    self.chatHandler = nil
  end
  if self.channelListHandler then
    DynamicBus.Chat_ChannelList.Disconnect(self.entityId, self)
    self.channelListHandler = nil
  end
  if self.timelineHighPriority then
    self.ScriptedEntityTweener:TimelineDestroy(self.timelineHighPriority)
  end
  if self.timelineHighlight then
    self.ScriptedEntityTweener:TimelineDestroy(self.timelineHighlight)
  end
  for _, data in pairs(self.messageTypeToData) do
    if data.widgetIconEntity then
      if data.widgetIconEntity ~= self.Properties.ChannelIconPrototype then
        UiElementBus.Event.DestroyElement(data.widgetIconEntity)
      end
      data.widgetIconEntity = nil
      data.unreadMessages = 0
    end
  end
end
function ChatWidget:OnUnseenMessageQueued(messageType, containsMention)
  local chatData = self.messageTypeToData[messageType]
  if not chatData then
    return
  end
  chatData.unreadMessages = chatData.unreadMessages + 1
  if messageType == eChatMessageType_Whisper or containsMention then
    chatData.highPriorityMessages = true
  end
  if not chatData.isInFeed then
    return
  end
  self:UpdateTotalUnread()
  if messageType ~= self.viewedChannel then
    if self.viewedChannel ~= nil then
      local viewedData = self.messageTypeToData[self.viewedChannel]
      if viewedData then
        self.ScriptedEntityTweener:Play(viewedData.widgetIconEntity, 0.3, {opacity = 0.15, ease = "QuadOut"})
        self.ScriptedEntityTweener:Play(viewedData.widgetIconEntity, 1, {
          opacity = 1,
          delay = 1,
          ease = "QuadOut"
        })
      end
    end
    self.ScriptedEntityTweener:Play(chatData.widgetIconEntity, 0.3, {opacity = 0}, {
      opacity = 0.8,
      imgColor = chatData.color,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:PlayC(chatData.widgetIconEntity, 1.4, tweenerCommon.chatWidgetIconUnseen, 0.6)
  end
  self:FlashWidgetVisibility()
end
function ChatWidget:OnWhisperChannelAdded(whisperTarget)
  local whisperTargetData = {}
  whisperTargetData.name = whisperTarget
  whisperTargetData.unreadMessages = 0
  whisperTargetData.highPriorityMessages = true
  whisperTargetData.isInFeed = true
  local baseWhisperChannelData = chatData:GetChannelData(eChatMessageType_Whisper)
  local channelIconEntity = CloneUiElement(self.canvasId, self.registrar, self.Properties.ChannelIconPrototype, self.Properties.ChannelIconContainer, true)
  UiImageBus.Event.SetSpritePathname(channelIconEntity, baseWhisperChannelData.widgetIcon)
  whisperTargetData.widgetIconEntity = channelIconEntity
  UiFaderBus.Event.SetFadeValue(whisperTargetData.widgetIconEntity, 0)
  self.messageTypeToData[whisperTargetData.name] = whisperTargetData
end
function ChatWidget:OnWhisperChannelUpdated(oldWhisperTarget, newWhisperTarget)
  local whisperTargetData = self.messageTypeToData[oldWhisperTarget]
  self.messageTypeToData[newWhisperTarget] = whisperTargetData
  self.messageTypeToData[oldWhisperTarget] = nil
end
function ChatWidget:OnViewedMessageType(messageType)
  if messageType == chatData.feedChannelId then
    for type, chatData in pairs(self.messageTypeToData) do
      chatData.unreadMessages = 0
      chatData.highPriorityMessages = false
    end
  elseif self.messageTypeToData[messageType] then
    local chatData = self.messageTypeToData[messageType]
    chatData.unreadMessages = 0
    chatData.highPriorityMessages = false
  end
  self:UpdateTotalUnread()
end
function ChatWidget:OnViewedChannelChanged(viewedChannel)
  if viewedChannel ~= self.viewedChannel then
    local animTime = self.isWidgetVisible and 0.3 or 0
    if self.viewedChannel ~= nil then
      local oldViewedData = self.messageTypeToData[self.viewedChannel]
      if oldViewedData then
        self.ScriptedEntityTweener:Play(oldViewedData.widgetIconEntity, animTime, {opacity = 0, ease = "QuadOut"})
      end
    end
    local newViewedData = self.messageTypeToData[viewedChannel]
    newViewedData = newViewedData or self.messageTypeToData[eChatMessageType_Whisper]
    if newViewedData then
      self.ScriptedEntityTweener:Play(newViewedData.widgetIconEntity, animTime, {opacity = 1, ease = "QuadOut"})
    end
    self.viewedChannel = viewedChannel
    self:OnViewedMessageType(viewedChannel)
    self:FlashWidgetVisibility()
  end
end
function ChatWidget:OnWidgetFocus()
  if not self.isWidgetButtonClickable then
    return
  end
  if not self.timelineHighlight then
    self.timelineHighlight = self.ScriptedEntityTweener:TimelineCreate()
    self.timelineHighlight:Add(self.Properties.HoverHighlight, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.15})
    self.timelineHighlight:Add(self.Properties.HoverHighlight, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 0.3})
    self.timelineHighlight:Add(self.Properties.HoverHighlight, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 0.3,
      onComplete = function()
        self.timelineHighlight:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.HoverHighlight, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 0.3, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.HoverHighlight, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 0.3,
    delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
    onComplete = function()
      self.timelineHighlight:Play()
    end
  })
  self.audioHelper:PlaySound(self.audioHelper.OnHover_ButtonSimpleText)
end
function ChatWidget:OnWidgetUnfocus()
  if self.timelineHighlight then
    self.timelineHighlight:Stop()
    self.ScriptedEntityTweener:Play(self.Properties.HoverHighlight, self.UIStyle.DURATION_BUTTON_FADE_OUT, {opacity = 0, ease = "QuadOut"})
  end
end
function ChatWidget:OnWidgetClicked()
  DynamicBus.ChatBus.Broadcast.SetFlyoutWidgetState(not self.isFlyoutShowing)
end
function ChatWidget:UpdateTotalUnread()
  local totalUnread = 0
  local anyHighPriority = false
  for _, data in pairs(self.messageTypeToData) do
    if data.isInFeed then
      if data.highPriorityMessages then
        anyHighPriority = true
      end
      if totalUnread < 99 then
        totalUnread = totalUnread + data.unreadMessages
      elseif anyHighPriority then
        break
      end
    end
  end
  if self.totalUnread == totalUnread then
    return
  end
  totalUnread = math.min(totalUnread, 99)
  UiElementBus.Event.SetIsEnabled(self.Properties.UnseenMessagesContainer, 0 < totalUnread)
  UiTextBus.Event.SetText(self.Properties.UnseenMessagesCount, tostring(totalUnread))
  self.totalUnread = totalUnread
  if anyHighPriority then
    if not self.timelineHighPriority then
      self.timelineHighPriority = self.ScriptedEntityTweener:TimelineCreate()
      self.timelineHighPriority:Add(self.Properties.HighPriorityFlash, 1.5, {opacity = 0.12})
      self.timelineHighPriority:Add(self.Properties.HighPriorityFlash, 0.1, {opacity = 1})
      self.timelineHighPriority:Add(self.Properties.HighPriorityFlash, 1, {
        opacity = 0.12,
        onComplete = function()
          self.timelineHighPriority:Play()
        end
      })
    end
    self.timelineHighPriority:Play()
  elseif self.timelineHighPriority then
    self.timelineHighPriority:Stop()
    self.ScriptedEntityTweener:Play(self.Properties.HighPriorityFlash, 0.2, {opacity = 0, ease = "QuadOut"})
  end
  self:UpdateWidgetVisibility()
end
function ChatWidget:UpdateWidgetVisibility()
  local isWidgetVisible = not self.isInDisabledState
  if self.isInHiddenState and not self.isInDisabledState then
    isWidgetVisible = self.totalUnread > 0
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, isWidgetVisible)
  if isWidgetVisible and not self.isWidgetVisible then
    self.ScriptedEntityTweener:Play(self.Properties.Button, 0.3, {opacity = 1, ease = "QuadOut"})
  end
  self.ChatAlerts:OnWidgetVisibilityChanged(isWidgetVisible and self.isWidgetButtonClickable)
  self.isWidgetVisible = isWidgetVisible
end
function ChatWidget:SetScreenState(toState)
  self.isInHiddenState = self.screenStatesToHide[toState] or false
  self.isInDisabledState = self.screenStatesToDisable[toState] or false
  local isButtonClickable = not self.screenStatesWithoutInteraction[toState] or false
  self:SetIsWidgetButtonClickable(isButtonClickable)
  self:UpdateWidgetVisibility()
end
function ChatWidget:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  if not self.isChatWidgetEnabled then
    return
  end
  self:SetScreenState(toState)
end
function ChatWidget:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  if not self.isChatWidgetEnabled then
    return
  end
  self:SetScreenState(toState)
end
function ChatWidget:OnPreScreenStateChanged(stateName, isTransitionIn)
  if self.isFlyoutShowing then
    DynamicBus.ChatBus.Broadcast.SetFlyoutWidgetState(false)
  end
  self:UpdateWidgetVisibility()
end
function ChatWidget:SetFlyoutWidgetState(isEnabled)
  self.isFlyoutShowing = isEnabled
  if not isEnabled then
    self:OnWidgetUnfocus()
  end
end
function ChatWidget:OnChatChannelSettingChanged(channelName, chatMessageTypeState)
  for _, channelData in pairs(self.messageTypeToData) do
    if channelData.name == channelName then
      channelData.isInFeed = chatMessageTypeState ~= eChatMessageTypeState_Muted
      break
    end
  end
  self:UpdateTotalUnread()
end
function ChatWidget:ChatMessageFocus()
end
return ChatWidget
