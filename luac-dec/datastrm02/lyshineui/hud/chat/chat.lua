local ChatChannelData = RequireScript("LyShineUI.HUD.Chat.ChatData")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local GameModeCommon = RequireScript("LyShineUI._Common.GameModeCommon")
local ChatScreen = {
  Properties = {
    ChatContainer = {
      default = EntityId()
    },
    ContentPositioner = {
      default = EntityId()
    },
    ContentBg = {
      default = EntityId()
    },
    EntityChatBox = {
      default = EntityId()
    },
    EntityChatBoxContent = {
      default = EntityId()
    },
    EntityScrollBar = {
      default = EntityId()
    },
    FrameParent = {
      default = EntityId()
    },
    WidgetBgParent = {
      default = EntityId()
    },
    WidgetCloseButton = {
      default = EntityId()
    },
    LeftFill = {
      default = EntityId()
    },
    LeftBg = {
      default = EntityId()
    },
    ChatTextField = {
      default = EntityId()
    },
    ChatBackground = {
      default = EntityId()
    },
    ChatInputText = {
      default = EntityId()
    },
    ChatInputPlaceholderText = {
      default = EntityId()
    },
    ChatLimitIndicator = {
      default = EntityId()
    },
    WhisperBackground = {
      default = EntityId()
    },
    WhisperInputText = {
      default = EntityId()
    },
    WhisperPlaceholderText = {
      default = EntityId()
    },
    WhisperTextField = {
      default = EntityId()
    },
    WhisperTextTip = {
      default = EntityId()
    },
    HintParent = {
      default = EntityId()
    },
    EmoteButton = {
      default = EntityId()
    },
    EmoteHint = {
      default = EntityId()
    },
    VoiceChatHintParent = {
      default = EntityId()
    },
    VoiceChatHint = {
      default = EntityId()
    },
    VoiceChatHintText = {
      default = EntityId()
    },
    ColorOwnMessage = {
      default = Color(1, 0.79, 0.51, 1)
    },
    ChannelPillsDropdown = {
      default = EntityId()
    },
    ShowGlobalChatCheckbox = {
      default = EntityId()
    },
    ChatSettingsButton = {
      default = EntityId()
    },
    ChatSettingsContainer = {
      default = EntityId()
    },
    ChatDisplaySettings = {
      default = EntityId()
    },
    ChatChannelSettings = {
      default = EntityId()
    },
    ChatChannelListContainer = {
      default = EntityId()
    },
    ChatChannelList = {
      default = EntityId()
    }
  },
  currentChannelIndex = 1,
  animDuration1 = 0.45,
  isFilteringGlobal = false,
  currentChatChannel = ChatChannelData.feedChannelId,
  emoteSlashCommands = {},
  recipientName = "",
  lastWhisperName = "",
  whisperReplyCmd = "R",
  mainBgWidth = 90,
  MAX_MESSAGE_HISTORY_SIZE = 512000,
  INDIVIDUAL_MESSAGE_SIZE = 300,
  MAX_WHISPER_CHANNELS = 10,
  screenStatesToDisable = {
    [2972535350] = true,
    [3349343259] = true,
    [2552344588] = true,
    [3576764016] = true,
    [3493198471] = true,
    [2477632187] = true,
    [3024636726] = true,
    [2478623298] = true,
    [1967160747] = true,
    [1823500652] = true,
    [156281203] = true,
    [3784122317] = true,
    [849925872] = true,
    [640726528] = true,
    [3370453353] = true,
    [3211015753] = true,
    [2896319374] = true,
    [828869394] = true,
    [2640373987] = true,
    [1319313135] = true,
    [1468490675] = true,
    [1101180544] = true,
    [2437603339] = true,
    [1643432462] = true,
    [3664731564] = true,
    [4119896358] = true,
    [3666413045] = true,
    [2609973752] = true,
    [3901667439] = true,
    [1634988588] = true,
    [319051850] = true,
    [921202721] = true,
    [3160088100] = true,
    [4283914359] = true
  },
  MAX_MESSAGES_TO_FADE = 7,
  fadeDelay = 25,
  fadeDuration = 5,
  fadeToOpacity = 0,
  gameplayOpacity = 1,
  messageStartFadeIndex = 0,
  messageOpacity = {},
  tickBusHandler = nil,
  coloredChannelName = "<font color=%s>%s</font>",
  queuedMessages = {},
  linkedItems = vector_ItemDescriptor(),
  onInvitePlayerEventId = "Popup_ChatInviteToGroup",
  itemSize = 10,
  itemReplacementCharSize = 2,
  bracketPaddingSize = 2,
  maxMessagesPerFrame = 1,
  msgsToDisplay = {},
  xInHud = 89,
  xInNavbar = 130,
  heightInHud = 636,
  heightInWidget = 636,
  heightInNavbar = 1023,
  heightAfterScroll = 1023,
  closedContentBottom = -65,
  MaxMessageLength = 200
}
local RingBuffer = RequireScript("LyShineUI.RingBuffer")
local SlashCommands = RequireScript("LyShineUI.SlashCommands")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
local itemCommon = RequireScript("LyShineUI._Common.ItemCommon")
local genericInviteCommon = RequireScript("LyShineUI._Common.GenericInviteCommon")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local NameValidationCommon = RequireScript("LyShineUI._Common.NameValidationCommon")
local TimeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local cryActionCommon = RequireScript("LyShineUI._Common.CryActionCommon")
BaseScreen:CreateNewScreen(ChatScreen)
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
function ChatScreen:OnInit()
  BaseScreen.OnInit(self)
  DynamicBus.ChatBus.Connect(self.entityId, self)
  DynamicBus.ChatNotifications.Connect(self.entityId, self)
  local lastChannel = self.dataLayer:GetDataFromNode("Hud.Chat.CurrentChannel")
  local lastActiveOutputChannel = self.dataLayer:GetDataFromNode("Hud.Chat.ActiveOutputChannel")
  if lastChannel then
    LyShineDataLayerBus.Broadcast.SetData("Chat.Last.Channel", lastChannel)
  end
  if lastActiveOutputChannel then
    LyShineDataLayerBus.Broadcast.SetData("Chat.Last.ActiveOutputChannel", lastActiveOutputChannel)
  end
  self:BusConnect(UiDynamicScrollBoxDataBus, self.Properties.EntityChatBox)
  self:BusConnect(UiDynamicScrollBoxElementNotificationBus, self.Properties.EntityChatBox)
  self:BusConnect(UiScrollBoxNotificationBus, self.Properties.EntityChatBox)
  self:BusConnect(UiTextInputNotificationBus, self.Properties.WhisperTextField)
  self:BusConnect(UiTextInputNotificationBus, self.ChatTextField)
  self:BusConnect(CryActionNotificationsBus, "toggleChatComponent")
  self:BusConnect(CryActionNotificationsBus, "toggleChatComponentSlash")
  cryActionCommon:RegisterActionListener(self, "ui_scroll_up", 0, self.OnCryAction)
  cryActionCommon:RegisterActionListener(self, "ui_scroll_down", 0, self.OnCryAction)
  self.socialDataHandler = SocialDataHandler
  self.socialDataHandler:OnActivate()
  self.contentPositionerOffsets = UiTransform2dBus.Event.GetOffsets(self.Properties.ContentPositioner)
  self.chatChannelListContainerOffsets = UiTransform2dBus.Event.GetOffsets(self.Properties.ChatChannelListContainer)
  self.chatChannels = ChatChannelData.chatChannels
  self.OtherChatColor = ChatChannelData.colorOtherChat
  self.BackdropColor = ChatChannelData.colorChatBackdrop
  self.textFieldTop = UiTransformBus.Event.GetLocalPositionY(self.Properties.ChatInputText)
  SlashCommands:RegisterSlashCommand("showdata", self.OnShowData, self)
  SlashCommands:RegisterSlashCommand("setdata", self.OnSetData, self)
  SlashCommands:RegisterSlashCommand("stuck", self.OnStuck, self, true)
  SlashCommands:RegisterSlashCommand("unstuck", self.OnStuck, self, true)
  SlashCommands:RegisterSlashCommand("played", self.OnRequestAge, self, true)
  SlashCommands:RegisterSlashCommand("invite", self.RequestGroupInvite, self, true, "Social")
  SlashCommands:RegisterSlashCommand("ginvite", self.RequestGroupInvite, self, true, "Social")
  SlashCommands:RegisterSlashCommand("mute", self.TryRequestMute, self, true, "Social")
  SlashCommands:RegisterSlashCommand("unmute", self.TryRequestUnmute, self, true, "Social")
  SlashCommands:RegisterSlashCommand("friend", self.TryRequestFriend, self, true, "Social")
  SlashCommands:RegisterSlashCommand("unfriend", self.TryRequestUnfriend, self, true, "Social")
  SlashCommands:RegisterSlashCommand("duel", self.TryDuelCommand, self, true, "Social")
  SlashCommands:RegisterSlashCommand("trade", self.TryTradeCommand, self, true, "Social")
  SlashCommands:RegisterSlashCommand("kick", self.TryKickCommand, self, true, "Social")
  SlashCommands:RegisterSlashCommand("busy", self.ToggleStreamerMode, self, true, "Social")
  SlashCommands:RegisterSlashCommand("dnd", self.ToggleStreamerMode, self, true, "Social")
  UiTextInputBus.Event.SetMaxStringLength(self.Properties.ChatTextField, self.MaxMessageLength)
  self.sentHistory = RingBuffer:new()
  self.sentHistoryIndex = 0
  local numChannelsWithHistory = 1 + self.MAX_WHISPER_CHANNELS
  for i, channelData in ipairs(self.chatChannels) do
    if channelData.canFilter then
      numChannelsWithHistory = numChannelsWithHistory + 1
    end
  end
  self.messagesPerChannel = math.floor(self.MAX_MESSAGE_HISTORY_SIZE / numChannelsWithHistory / self.INDIVIDUAL_MESSAGE_SIZE)
  local savedChatTypeToStates = OptionsDataBus.Broadcast.GetChatTypeStates()
  self.channelsInFeed = {}
  self.whisperChannelMessageData = {}
  self.whisperCount = 0
  self.chatMessagesByChannel = {}
  self.chatMessagesByChannel[ChatChannelData.feedChannelId] = RingBuffer:new({
    max_length = self.messagesPerChannel
  })
  self:SwitchViewedChannel(ChatChannelData.feedChannelId, true)
  self:SetActiveOutputChannel(eChatMessageType_Global)
  local channelList = {}
  for i, channelData in ipairs(self.chatChannels) do
    if channelData.canOutput then
      table.insert(channelList, channelData)
    end
    local shouldBeInFeed = true
    if channelData.canFilter then
      self.chatMessagesByChannel[channelData.name] = RingBuffer:new({
        max_length = self.messagesPerChannel
      })
      for i = 1, #savedChatTypeToStates do
        local chatTypeToState = savedChatTypeToStates[i]
        if channelData.name == chatTypeToState.messageType then
          shouldBeInFeed = chatTypeToState.messageState ~= eChatMessageTypeState_Muted
          break
        end
      end
    end
    if shouldBeInFeed then
      table.insert(self.channelsInFeed, channelData.name)
    end
  end
  self.ChannelPillsDropdown:SetChannels(channelList)
  self.ChannelPillsDropdown:SetCallback(self.OnChannelDropdownSelected, self)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.OnLocalPlayerSet", function(self, isSet)
    if isSet then
      self.emoteSlashCommands = LocalPlayerUIRequestsBus.Broadcast.GetEmoteSlashCommands()
      local debugSlashCommandsEnabled = self.dataLayer:GetDataFromNode("UIFeatures.g_uiEnableDebugSlashCommands")
      self:SetHelpText(debugSlashCommandsEnabled)
      self.itemSize = ChatComponentBus.Broadcast.GetChatItemSize()
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Localization.Language", function(self, setLang)
    if not setLang then
      return
    end
    self.alertErrorMsg = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_no_permission_alert")
    self.whisperBlockErrorMsg = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_error_whisper_block")
    local voipKeybind = LyShineManagerBus.Broadcast.GetKeybind("toggleMicrophoneOn", "ui")
    local emoteKeybind = LyShineManagerBus.Broadcast.GetKeybind("toggleEmoteWindow", "ui")
    self.VoiceChatHint:SetText(voipKeybind)
    self.EmoteHint:SetText(emoteKeybind)
    self:QueueRefreshContent()
  end)
  local element = UiElementBus.Event.GetChild(self.Properties.EntityChatBoxContent, 0)
  local chatMessage = self.registrar:GetEntityTable(element)
  local originalMessageFontSize = chatMessage.originalMessageFontSize or 24
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_chatSettings", function(self, isEnabled)
    if isEnabled ~= nil then
      UiElementBus.Event.SetIsEnabled(self.Properties.ChatSettingsButton, isEnabled)
      if isEnabled then
        self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Options.Chat.ChatUseCompactView", function(self, displayState)
          self:QueueRefreshContent()
        end)
        self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Options.Chat.ChatColorMessageToChannel", function(self, colorMessages)
          self.colorMessagesToChannel = colorMessages
          self:QueueRefreshContent()
        end)
        self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Chat.ChatFontSize", function(self, fontSize)
          if fontSize then
            self.textScale = fontSize / originalMessageFontSize
            self:QueueRefreshContent()
            if not self.originalChatFontsize then
              self.originalChatFontsize = UiTextBus.Event.GetFontSize(self.Properties.ChatInputText)
              self.originalWhisperFontsize = UiTextBus.Event.GetFontSize(self.Properties.WhisperInputText)
            end
            UiTextBus.Event.SetFontSize(self.Properties.ChatInputText, self.originalChatFontsize * self.textScale)
            UiTextBus.Event.SetFontSize(self.Properties.ChatInputPlaceholderText, self.originalChatFontsize * self.textScale)
            UiTextBus.Event.SetFontSize(self.Properties.WhisperInputText, self.originalWhisperFontsize * self.textScale)
            UiTextBus.Event.SetFontSize(self.Properties.WhisperPlaceholderText, self.originalWhisperFontsize * self.textScale)
            self:OnChangeChatField()
          end
        end)
      else
        self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Options.Accessibility.TextSizeOption", function(self, textSize)
          self.textScale = 1
          if textSize == eAccessibilityTextOptions_Bigger then
            self.textScale = 1.25
          end
          self:QueueRefreshContent()
          if not self.originalChatFontsize then
            self.originalChatFontsize = UiTextBus.Event.GetFontSize(self.Properties.ChatInputText)
            self.originalWhisperFontsize = UiTextBus.Event.GetFontSize(self.Properties.WhisperInputText)
          end
          UiTextBus.Event.SetFontSize(self.Properties.ChatInputText, self.originalChatFontsize * self.textScale)
          UiTextBus.Event.SetFontSize(self.Properties.WhisperInputText, self.originalWhisperFontsize * self.textScale)
        end)
      end
    end
  end)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.ChatMessage.Received", function(self, data)
    local chatType = data.type
    if data.type == eChatMessageType_GroupAlert then
      DynamicBus.SocialPaneBus.Broadcast.ShowGroupAlertMessage(data.body)
      return
    end
    local isActionMessage = chatType == eChatMessageType_Emote
    local isSystemMessage = chatType == eChatMessageType_System
    self.isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
    if self.isFtue and not data.showInFtue then
      return
    end
    local chatMessageBody = data.body
    local isOwnMessage = data.isOwn
    local isPingMessage = data.isPingMsg
    local chatSender
    local enableMarkup = false
    local alertOnReceive = false
    if isPingMessage then
      chatSender = ""
    else
      chatSender = data.sender
    end
    local itemDescriptors
    if #data.itemDescriptors > 0 then
      enableMarkup = true
      itemDescriptors = vector_ItemDescriptor()
      local descriptor = ItemDescriptor()
      for i = 1, #data.itemDescriptors do
        local otherDesc = data.itemDescriptors[i]
        descriptor.itemId = otherDesc.itemId
        descriptor.quantity = otherDesc.quantity
        descriptor.gearScore = otherDesc.gearScore
        descriptor:SetPerks(itemCommon:GetPerks(otherDesc))
        itemDescriptors:push_back(descriptor)
      end
    end
    if isActionMessage then
      chatType = eChatMessageType_Area
    elseif chatType == eChatMessageType_Area_Announce then
      enableMarkup = true
      chatType = eChatMessageType_Area
    elseif chatType == eChatMessageType_Guild_Announce then
      enableMarkup = true
      chatType = eChatMessageType_Guild
    elseif chatType == eChatMessageType_Group_Announce then
      enableMarkup = true
      chatType = eChatMessageType_Group
    elseif chatType == eChatMessageType_Raid_Announce then
      enableMarkup = true
      chatType = eChatMessageType_Raid
    end
    if data and data.alertOnReceive then
      alertOnReceive = true
      enableMarkup = true
    end
    local chatMessageData = {
      chatType = chatType,
      chatSender = chatSender,
      chatRecipient = data.recipientName,
      chatMessage = isSystemMessage and LyShineScriptBindRequestBus.Broadcast.LocalizeText(chatMessageBody) or chatMessageBody,
      isOwnMessage = isOwnMessage,
      isPingMessage = isPingMessage,
      isGameMasterClientMsg = data.isGameMasterClientMsg,
      time = TimeHelpers:GetLocalizedTime(data.timestamp),
      itemDescriptors = itemDescriptors,
      alertOnReceive = alertOnReceive,
      enableMarkup = enableMarkup
    }
    if chatType == eChatMessageType_Whisper and not isOwnMessage then
      self.lastWhisperName = chatMessageData.chatSender.playerName
    end
    if data.isNew then
      DynamicBus.ChatNotifications.Broadcast.OnChatMessageReceived(chatMessageData)
      self:QueueChatMessage(chatMessageData)
    else
      self:ProcessOneMessage(chatMessageData)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.Enabled", function(self, enabled)
    if enabled then
      do
        local function updateOfficerPermission()
          local hasPermission = self.officerChatPrivilege
          local officerChannelData = self:GetChannelData(eChatMessageType_Guild_Officer)
          officerChannelData.hasPermission = hasPermission
          LyShineDataLayerBus.Broadcast.SetData("Chat.HasOfficerPermission", hasPermission)
          self:OnChannelAvailabilityChanged(eChatMessageType_Guild_Officer, hasPermission)
        end
        self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.Id", function(self, guildId)
          local isInGuild = guildId and guildId:IsValid()
          if isInGuild then
            updateOfficerPermission()
          else
            local guildChannelData = self:GetChannelData(eChatMessageType_Guild)
            guildChannelData.hasPermission = false
          end
          local skipChannelPillNotification = true
          self:OnChannelAvailabilityChanged(eChatMessageType_Guild, isInGuild, skipChannelPillNotification)
        end)
        self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Guild.Rank", function(self, rank)
          if rank then
            local guildChatPrivilege = GuildsComponentBus.Broadcast.HasPrivilege(eGuildPrivilegeId_Chat_Speak)
            self.officerChatPrivilege = GuildsComponentBus.Broadcast.HasPrivilege(eGuildPrivilegeId_OfficerChat_Speak)
            local guildChannelData = self:GetChannelData(eChatMessageType_Guild)
            guildChannelData.hasPermission = guildChatPrivilege
            updateOfficerPermission()
          end
        end)
      end
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Group.Id", function(self, groupId)
    local isInGroup = groupId and groupId:IsValid()
    local groupChannelData = self:GetChannelData(eChatMessageType_Group)
    groupChannelData.hasPermission = isInGroup
    self:OnChannelAvailabilityChanged(eChatMessageType_Group, isInGroup)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Raid.Id", function(self, raidId)
    local inRaid = raidId and raidId:IsValid()
    local channelData = self:GetChannelData(eChatMessageType_Raid)
    channelData.hasPermission = inRaid
    self:OnChannelAvailabilityChanged(eChatMessageType_Raid, inRaid)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Faction", function(self, faction)
    if faction == nil then
      return
    end
    local playerRootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
    local validFaction = FactionRequestBus.Event.IsValidFaction(playerRootEntityId, faction)
    local channelData = self:GetChannelData(eChatMessageType_Faction)
    channelData.hasPermission = validFaction
    if validFaction then
      local factionData = FactionCommon.factionInfoTable[faction]
      channelData.displayName = "@ui_chat_name_faction_" .. faction
      channelData.displayNameUpper = "@ui_chat_name_faction_upper_" .. faction
      channelData.widgetIcon = factionData.chatIcon
      channelData.messageIcon = factionData.chatIcon
      channelData.color = factionData.chatColor
      self.ChatChannelSettings:OnChannelDataChanged(eChatMessageType_Faction, channelData)
      self.ChannelPillsDropdown:OnChannelDataChanged(eChatMessageType_Faction, channelData)
    end
    self:OnChannelAvailabilityChanged(eChatMessageType_Faction, validFaction)
  end)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Screens.Chat.SetContainerVisibility", self.SetContainerVisibility)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Chat.ChatMessageFadeDelay", function(self, fadeDelay)
    if fadeDelay then
      self.fadeDelay = fadeDelay
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Chat.ChatMessageGameplayOpacity", function(self, opacity)
    if opacity then
      self.gameplayOpacity = opacity / 100
      self.opacitySet = true
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_chatChannels", function(self, isEnabled)
    if isEnabled ~= nil then
      self.isChannelsEnabled = isEnabled
      UiElementBus.Event.SetIsEnabled(self.Properties.ChatChannelListContainer, isEnabled)
      UiElementBus.Event.SetIsEnabled(self.Properties.ShowGlobalChatCheckbox, not isEnabled)
      UiElementBus.Event.SetIsEnabled(self.Properties.HintParent, not isEnabled)
      self.defaultFrameParentWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.FrameParent)
    end
  end)
  self.ChatSettingsButton:SetCallback(function(self)
    self:SetChatSettingsVisibility(not self.isChatSettingsVisible)
  end, self)
  UiElementBus.Event.SetIsEnabled(self.Properties.WhisperTextField, false)
  self.WhisperTextField:SetEnterCallback(self.WhisperFieldOnEnter, self)
  self.WhisperTextField:SetStartEditCallback(self.EnterWhisperField, self)
  self.WhisperTextField:SetEndEditCallback(self.ExitWhisperField, self)
  self.WhisperTextField:SetOnlineOnly(true)
  self.WidgetCloseButton:SetCallback(function()
    DynamicBus.ChatBus.Broadcast.SetFlyoutWidgetState(false)
  end, self)
  self:SetContainerVisibility(false)
  self:UpdateRemainingText()
  self.isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
  self.ScriptedEntityTweener:Set(self.Properties.LeftBg, {
    x = -self.mainBgWidth
  })
  self.ScriptedEntityTweener:Set(self.Properties.LeftFill, {x = -2})
  LyShineDataLayerBus.Broadcast.SetData("Hud.Chat.IsUIReady", true)
end
function ChatScreen:OnShutdown()
  LyShineDataLayerBus.Broadcast.SetData("Hud.Chat.IsUIReady", false)
  DynamicBus.ChatBus.Disconnect(self.entityId, self)
  DynamicBus.ChatNotifications.Disconnect(self.entityId, self)
  self.socialDataHandler:OnDeactivate()
  BaseScreen.OnShutdown(self)
  cryActionCommon:UnregisterActionListener(self, "ui_scroll_up")
  cryActionCommon:UnregisterActionListener(self, "ui_scroll_down")
end
function ChatScreen:QueueRefreshContent()
  self.queueRefreshContent = true
  if self.tickBusHandler == nil then
    self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function ChatScreen:GetChannelData(channelName)
  return ChatChannelData:GetChannelData(channelName)
end
function ChatScreen:OnTick(deltaTime, timepoint)
  if self.queueRefreshContent then
    UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.EntityChatBox)
    self.queueRefreshContent = false
  end
  if self.reenterChatField then
    self:FocusChatTextField()
    self.reenterChatField = false
  end
  if #self.messageOpacity == 0 and #self.queuedMessages == 0 then
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
    return
  end
  ClearTable(self.msgsToDisplay)
  local messagesPerFrame = self.maxMessagesPerFrame
  if messagesPerFrame > #self.queuedMessages then
    messagesPerFrame = #self.queuedMessages
  end
  for i = 1, messagesPerFrame do
    table.insert(self.msgsToDisplay, self.queuedMessages[1])
    table.remove(self.queuedMessages, 1)
  end
  local numMessages = #self.msgsToDisplay
  local numElementsToRemove = 0
  if 0 < numMessages then
    local removedMessages = 0
    local addedMessages = 0
    local scrollToEnd = false
    local playWhisperSound = false
    for i = 1, numMessages do
      local queuedMessage = self.msgsToDisplay[i]
      local added, removed, scrollToEnd = self:ProcessMessage(queuedMessage)
      addedMessages = addedMessages + added
      removedMessages = removedMessages + removed
    end
    UiDynamicScrollBoxBus.Event.RemoveElementsFromFront(self.Properties.EntityChatBox, removedMessages)
    UiDynamicScrollBoxBus.Event.AddElementsToEnd(self.Properties.EntityChatBox, addedMessages, true)
    if scrollToEnd then
      UiDynamicScrollBoxBus.Event.ScrollToEnd(self.Properties.EntityChatBox)
    end
    if 0 < addedMessages then
      local height = UiTransform2dBus.Event.GetLocalHeight(self.Properties.EntityChatBoxContent)
      self.messageStartFadeIndex = self.currentChatChannelMessages:GetCount() - 1
      for i = self.messageStartFadeIndex, self.messageStartFadeIndex - (addedMessages - 1), -1 do
        if #self.messageOpacity == self.MAX_MESSAGES_TO_FADE then
          table.remove(self.messageOpacity, 1)
          if not self.isVisible then
            local entityId = UiDynamicScrollBoxBus.Event.GetChildAtElementIndex(self.Properties.EntityChatBox, i - self.MAX_MESSAGES_TO_FADE)
            self.ScriptedEntityTweener:Set(entityId, {opacity = 0})
          end
        end
        table.insert(self.messageOpacity, {t = 0, alpha = 1})
      end
    end
    ClearTable(self.msgsToDisplay)
  end
  if 0 < numElementsToRemove and not self.isVisible then
    for i = 0, numElementsToRemove - 1 do
      local chatEntityId = UiDynamicScrollBoxBus.Event.GetChildAtElementIndex(self.Properties.EntityChatBox, self.messageStartFadeIndex - self.MAX_MESSAGES_TO_FADE - i)
      UiFaderBus.Event.SetFadeValue(chatEntityId, self.fadeToOpacity)
    end
  end
  if not self.isVisible then
    local startOpacity = 1
    local totalFadeDuration = self.fadeDelay + self.fadeDuration
    for i = 0, #self.messageOpacity - 1 do
      local messageIndex = #self.messageOpacity - i
      local fadeObj = self.messageOpacity[messageIndex]
      local opacity = startOpacity
      if fadeObj then
        fadeObj.t = fadeObj.t + deltaTime
        if fadeObj.t > self.fadeDelay then
          local timeActive = (fadeObj.t - self.fadeDelay) / self.fadeDuration
          opacity = -1 * (self.fadeToOpacity - startOpacity) * timeActive * (timeActive - 2) + startOpacity
        end
        if totalFadeDuration <= fadeObj.t then
          opacity = self.fadeToOpacity
          table.remove(self.messageOpacity, messageIndex)
        end
        local chatEntityId = UiDynamicScrollBoxBus.Event.GetChildAtElementIndex(self.Properties.EntityChatBox, self.messageStartFadeIndex - i)
        UiFaderBus.Event.SetFadeValue(chatEntityId, opacity)
      end
    end
  end
end
function ChatScreen:ProcessMessage(queuedMessage)
  local addedMessages = 0
  local removedMessages = 0
  local scrollToEnd = false
  local isWhisper = queuedMessage.chatType == eChatMessageType_Whisper
  local whisperTarget
  if isWhisper then
    whisperTarget = ChatChannelData:GetWhisperTarget(queuedMessage)
    local chatHistory = self.chatMessagesByChannel[whisperTarget]
    if not chatHistory then
      if #self.whisperChannelMessageData >= self.MAX_WHISPER_CHANNELS then
        local oldestWhisperChannelData = self.whisperChannelMessageData[1]
        for _, data in ipairs(self.whisperChannelMessageData) do
          if oldestWhisperChannelData.count > data.count then
            oldestWhisperChannelData = data
          end
        end
        local oldestChannel = self.chatMessagesByChannel[oldestWhisperChannelData.whisperTarget]
        oldestChannel:Clear()
        self.chatMessagesByChannel[whisperTarget] = oldestChannel
        self.chatMessagesByChannel[oldestWhisperChannelData.whisperTarget] = nil
        DynamicBus.Chat_ChannelList.Broadcast.OnWhisperChannelUpdated(oldestWhisperChannelData.whisperTarget, whisperTarget)
        oldestWhisperChannelData.whisperTarget = whisperTarget
        oldestWhisperChannelData.count = self.whisperCount
        chatHistory = oldestChannel
      else
        self.chatMessagesByChannel[whisperTarget] = RingBuffer:new({
          max_length = self.messagesPerChannel
        })
        table.insert(self.whisperChannelMessageData, {
          whisperTarget = whisperTarget,
          count = self.whisperCount
        })
        chatHistory = self.chatMessagesByChannel[whisperTarget]
        DynamicBus.Chat_ChannelList.Broadcast.OnWhisperChannelAdded(whisperTarget)
      end
    end
    local removedMsg = chatHistory:Push(queuedMessage)
    if removedMsg and self.currentChatChannel == whisperTarget then
      removedMessages = removedMessages + 1
    end
    self.whisperCount = self.whisperCount + 1
    self.audioHelper:PlaySound(self.audioHelper.OnWhisperReceived)
  end
  if self:IsChannelInFeed(queuedMessage.chatType) then
    local removedMsg = self.chatMessagesByChannel[ChatChannelData.feedChannelId]:Push(queuedMessage)
    if removedMsg and self.currentChatChannel == ChatChannelData.feedChannelId then
      removedMessages = removedMessages + 1
    end
  end
  local chatChannelToUpdate = queuedMessage.chatType
  if chatChannelToUpdate == eChatMessageType_System and self.currentChatChannel ~= ChatChannelData.feedChannelId then
    chatChannelToUpdate = self.currentChatChannel
  end
  if not isWhisper then
    local chatHistory = self.chatMessagesByChannel[chatChannelToUpdate]
    if not chatHistory then
      chatChannelToUpdate = eChatMessageType_Global
      chatHistory = self.chatMessagesByChannel[chatChannelToUpdate]
    end
    local removedMsg = chatHistory:Push(queuedMessage)
    if removedMsg and self.currentChatChannel == chatChannelToUpdate then
      removedMessages = removedMessages + 1
    end
  end
  if self.currentChatChannel == chatChannelToUpdate or self.currentChatChannel == ChatChannelData.feedChannelId and self:IsChannelInFeed(isWhisper and eChatMessageType_Whisper or chatChannelToUpdate) or isWhisper and self.currentChatChannel == whisperTarget then
    if queuedMessage.isOwnMessage then
      scrollToEnd = true
    end
    addedMessages = addedMessages + 1
  end
  return addedMessages, removedMessages, scrollToEnd
end
function ChatScreen:ProcessOneMessage(queuedMessage)
  local addedMessages, removedMessages, scrollToEnd = self:ProcessMessage(queuedMessage)
  UiDynamicScrollBoxBus.Event.RemoveElementsFromFront(self.Properties.EntityChatBox, removedMessages)
  UiDynamicScrollBoxBus.Event.AddElementsToEnd(self.Properties.EntityChatBox, addedMessages, true)
  if scrollToEnd then
    UiDynamicScrollBoxBus.Event.ScrollToEnd(self.Properties.EntityChatBox)
  end
end
function ChatScreen:OnScrollOffsetChanging(offset)
  local curHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.EntityChatBox)
  if curHeight ~= self.heightAfterScroll then
    self.ScriptedEntityTweener:Set(self.Properties.ChatContainer, {
      h = self.heightAfterScroll
    })
  end
end
function ChatScreen:OnCryAction(actionName)
  if actionName == "toggleChatComponent" or actionName == "toggleChatComponentSlash" then
    self:OpenChatOrFlyout(true, actionName)
  elseif self.isVisible and (actionName == "ui_scroll_up" or actionName == "ui_scroll_down") then
    DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
  end
end
function ChatScreen:OpenChat(actionName)
  LyShineManagerBus.Broadcast.SetState(3766762380)
  if LyShineManagerBus.Broadcast.IsInState(3766762380) then
    self.screenEnteredForChat = true
    self:FocusChatTextField(actionName == "toggleChatComponentSlash")
  end
end
function ChatScreen:OnChannelDropdownSelected(channelData)
  if channelData and channelData.name then
    self:SetActiveOutputChannel(channelData.name)
    if channelData.name == eChatMessageType_Whisper then
      self:FocusWhisperTextField()
    else
      self:FocusChatTextField()
    end
  end
end
function ChatScreen:SetHelpText(debugSlashCommandsOn)
  self.helpCommand = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_help")
  self.helpText = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_chat_slash_commands")
  if #self.emoteSlashCommands > 0 then
    self.helpText = string.format([[
%s
%s : 
]], self.helpText, LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_emote"))
    for i = 1, #self.emoteSlashCommands do
      self.helpText = string.format("%s/%s ", self.helpText, self.emoteSlashCommands[i])
    end
  end
  self.helpText = string.format([[
%s
%s : 
]], self.helpText, LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_chatchannel"))
  for channelIndex, channelData in ipairs(self.chatChannels) do
    if channelData.canSelect then
      self.helpText = string.format("%s/%s ", self.helpText, LyShineScriptBindRequestBus.Broadcast.LocalizeText(channelData.displayName):lower())
    end
  end
  self.helpText = string.format("%s/r ", self.helpText)
  local hasUtilityCommands = false
  local hasSocialCommands = false
  local utilityCommands = string.format("%s : \n", LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_chat_utilities"))
  local socialCommands = string.format("%s : \n", LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_chat_social"))
  for commandName, commandData in pairs(g_slashCommands) do
    if commandData.enabledInRelease or not commandData.enabledInRelease and debugSlashCommandsOn then
      if commandData.commandType == "Social" then
        socialCommands = string.format("%s/%s ", socialCommands, commandName)
        hasSocialCommands = true
      else
        utilityCommands = string.format("%s/%s ", utilityCommands, commandName)
        hasUtilityCommands = true
      end
    end
  end
  if hasUtilityCommands then
    self.helpText = string.format([[
%s
%s]], self.helpText, utilityCommands)
  end
  if hasSocialCommands then
    self.helpText = string.format([[
%s
%s]], self.helpText, socialCommands)
  end
  self.helpText = string.format("%s\n", self.helpText)
end
function ChatScreen:GetMessageByIndex(index)
  return self.currentChatChannelMessages and self.currentChatChannelMessages:GetAt(index * -1) or nil
end
function ChatScreen:GetNumElements()
  return self.currentChatChannelMessages and self.currentChatChannelMessages:GetCount() or 0
end
function ChatScreen:OnPrepareElementForSizeCalculation(rootEntity, index)
  local chatMessageData = self:GetMessageByIndex(index + 1)
  if not chatMessageData then
    return
  end
  local chatMessage = self.registrar:GetEntityTable(rootEntity)
  if chatMessageData.isPingMessage then
    chatMessage:SetPingMessage(chatMessageData.chatMessage)
  else
    chatMessage:SetText(chatMessageData.chatMessage, chatMessageData.enableMarkup)
  end
  return chatMessage, chatMessageData
end
function ChatScreen:ChatMessageFocus(entityId)
  local chatMessage = self.registrar:GetEntityTable(entityId)
  if self.previousFocusedOptions and chatMessage ~= self.previousFocusedOptions and self.previousFocusedOptions ~= self.lastChatOptions then
    self.previousFocusedOptions:OnUnfocus()
  end
  self.previousFocusedOptions = chatMessage
  local isMouseOver = true
  chatMessage:OnFocus(isMouseOver)
end
function ChatScreen:OnElementBecomingVisible(rootEntity, index)
  local chatMessage, chatMessageData = self:OnPrepareElementForSizeCalculation(rootEntity, index)
  chatMessage:SetupChatElement(chatMessageData)
  if index == self.currentChatChannelMessages:GetCount() - 1 then
    if self.lastChatOptions and chatMessage ~= self.lastChatOptions then
      self.lastChatOptions:OnUnfocus(true)
    end
    self.lastChatOptions = chatMessage
    if self.isVisible then
      local isMouseOver = false
      local isInstant = true
      chatMessage:OnFocus(isMouseOver, isInstant)
    end
  else
    chatMessage:OnUnfocus(true)
  end
end
function ChatScreen:OnToggleGlobal()
  self.isFilteringGlobal = not self.isFilteringGlobal
  local event = UiAnalyticsEvent("PlayerToggledGlobalChatFilter")
  event:AddAttribute("FilteringIsOn", tostring(self.isFilteringGlobal))
  event:Send()
  self:SetChannelInFeed(eChatMessageType_Global, not self.isFilteringGlobal)
end
function ChatScreen:ReinitializeFeed()
  local feed = self.chatMessagesByChannel[ChatChannelData.feedChannelId]
  feed:Clear()
  local channelsToPopulate = {}
  local channelsForOutput = {}
  for _, channelName in ipairs(self.channelsInFeed) do
    local messages = self.chatMessagesByChannel[channelName]
    if messages then
      table.insert(channelsToPopulate, {messages = messages, curIndex = 1})
    end
    local channelData = self:GetChannelData(channelName)
    if channelData.canOutput then
      table.insert(channelsForOutput, channelData)
    end
  end
  local newestMessages = {}
  for i = 1, feed.max_length do
    local newestMessage, newestMessageContainer
    for _, messages in ipairs(channelsToPopulate) do
      local message = messages.messages:GetAt(messages.curIndex)
      if message and (not newestMessage or message.time > newestMessage.time) then
        newestMessage = message
        newestMessageContainer = messages
      end
    end
    if not newestMessage then
      break
    end
    newestMessageContainer.curIndex = newestMessageContainer.curIndex + 1
    table.insert(newestMessages, newestMessage)
  end
  for i = #newestMessages, 1, -1 do
    local newestMessage = newestMessages[i]
    feed:Push(newestMessage)
  end
  self.ChannelPillsDropdown:SetChannels(channelsForOutput)
  if self.currentChatChannel == ChatChannelData.feedChannelId then
    self:SwitchViewedChannel(ChatChannelData.feedChannelId)
  end
end
function ChatScreen:QueueChatMessage(chatMessageData)
  if not self.tickBusHandler then
    self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
  end
  table.insert(self.queuedMessages, chatMessageData)
end
function ChatScreen:SetContainerVisibility(isVisible, force)
  if self.isFtue then
    isVisible = false
  end
  if self.isVisible ~= isVisible or force then
    local chatBoxFadeDuration = self.isChatEnabled and 0.2 or 0
    self.isVisible = isVisible
    local chatWidgetCanvasId = UiCanvasManagerBus.Broadcast.FindLoadedCanvasByPathName("LyShineUI/HUD/Chat/ChatWidget.uicanvas")
    if isVisible then
      UiCanvasBus.Event.SetEnabled(chatWidgetCanvasId, false)
      self.ScriptedEntityTweener:Play(self.Properties.LeftBg, 0.25, {x = -2, ease = "QuadOut"})
      self.ScriptedEntityTweener:Play(self.Properties.LeftFill, 0.25, {x = 65, ease = "QuadOut"})
      if self.isInWidgetState then
        self.ScriptedEntityTweener:Set(self.Properties.ChatContainer, {
          h = self.heightInWidget
        })
        self.ScriptedEntityTweener:Set(self.Properties.FrameParent, {opacity = 0})
        self.ScriptedEntityTweener:PlayC(self.Properties.WidgetBgParent, 0.25, tweenerCommon.fadeInQuadOut)
      else
        self.ScriptedEntityTweener:Set(self.Properties.ChatContainer, {
          h = self.heightInNavbar
        })
        self.ScriptedEntityTweener:Set(self.Properties.WidgetBgParent, {opacity = 0})
        self.ScriptedEntityTweener:PlayC(self.Properties.FrameParent, 0.25, tweenerCommon.fadeInQuadOut)
        self.ScriptedEntityTweener:PlayC(self.Properties.ContentBg, 0.25, tweenerCommon.fadeInQuadOut)
      end
      self.ScriptedEntityTweener:PlayC(self.Properties.ChatTextField, 0.25, tweenerCommon.fadeInQuadOut)
      self.ScriptedEntityTweener:PlayC(self.Properties.ChatChannelListContainer, 0.25, tweenerCommon.fadeInQuadOut)
      self.ScriptedEntityTweener:PlayC(self.Properties.ChatSettingsButton, 0.25, tweenerCommon.fadeInQuadOut)
      if self.isChannelsEnabled then
        self.ScriptedEntityTweener:Play(self.entityId, chatBoxFadeDuration, {
          x = self.xInNavbar,
          ease = "QuadOut"
        })
        local extraBgWidth = self.xInNavbar - self.xInHud
        self.ScriptedEntityTweener:Play(self.Properties.FrameParent, chatBoxFadeDuration, {
          w = self.defaultFrameParentWidth + extraBgWidth,
          ease = "QuadOut"
        })
      end
      if self.lastChatOptions then
        self.lastChatOptions:OnFocus()
      end
      if self.tickBusHandler and #self.queuedMessages == 0 then
        self:BusDisconnect(self.tickBusHandler)
        self.tickBusHandler = nil
      end
      self:PositionContentToChatField()
    else
      UiCanvasBus.Event.SetEnabled(chatWidgetCanvasId, true)
      self.ScriptedEntityTweener:Set(self.Properties.ChatContainer, {
        h = self.heightInHud
      })
      self.ScriptedEntityTweener:Play(self.Properties.LeftBg, 0.25, {
        x = -self.mainBgWidth,
        ease = "QuadIn"
      })
      self.ScriptedEntityTweener:Play(self.Properties.LeftFill, 0.25, {x = -2, ease = "QuadIn"})
      self.ScriptedEntityTweener:PlayC(self.Properties.WidgetBgParent, 0.25, tweenerCommon.fadeOutQuadOut)
      self.ScriptedEntityTweener:PlayC(self.Properties.FrameParent, 0.25, tweenerCommon.fadeOutQuadOut)
      self.ScriptedEntityTweener:PlayC(self.Properties.ChatTextField, 0.25, tweenerCommon.fadeOutQuadOut)
      self.ScriptedEntityTweener:PlayC(self.Properties.ChatChannelListContainer, 0.25, tweenerCommon.fadeOutQuadOut)
      self.ScriptedEntityTweener:PlayC(self.Properties.ChatSettingsButton, 0.25, tweenerCommon.fadeOutQuadOut)
      self.ScriptedEntityTweener:PlayC(self.Properties.ContentBg, 0.25, tweenerCommon.fadeOutQuadOut)
      if self.isChannelsEnabled then
        self.ScriptedEntityTweener:Play(self.entityId, chatBoxFadeDuration, {
          x = self.xInHud,
          ease = "QuadOut"
        })
        self.ScriptedEntityTweener:Play(self.Properties.FrameParent, chatBoxFadeDuration, {
          w = self.defaultFrameParentWidth,
          ease = "QuadOut"
        })
      end
      if self.lastChatOptions then
        self.lastChatOptions:OnUnfocus()
      end
      if self.isChatFocused or self.isWhisperFocused then
        self:SetInteractState(false)
      end
      if 0 < #self.messageOpacity and self.tickBusHandler == nil then
        self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
      end
      self.ChannelPillsDropdown:SetIsExpanded(false)
      self:SetContentBottom(self.closedContentBottom)
    end
    if self.previousFocusedOptions then
      self.previousFocusedOptions:OnUnfocus()
      self.previousFocusedOptions = nil
    end
    UiCanvasBus.Event.SetIsPositionalInputSupported(self.canvasId, self.isVisible)
    UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.EntityChatBox, self.isVisible)
    UiElementBus.Event.SetIsEnabled(self.Properties.EmoteButton, self.isVisible)
    UiElementBus.Event.SetIsEnabled(self.Properties.VoiceChatHintParent, self.isVisible)
    UiDynamicScrollBoxBus.Event.ScrollToEnd(self.Properties.EntityChatBox)
    self.ScriptedEntityTweener:Play(self.Properties.EntityScrollBar, chatBoxFadeDuration, {
      opacity = isVisible and 1 or 0,
      ease = "QuadOut"
    })
    UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.EntityScrollBar, isVisible)
    if self.gameplayOpacity ~= 1 or self.opacitySet then
      self.ScriptedEntityTweener:Play(self.entityId, chatBoxFadeDuration, {
        opacity = isVisible and 1 or self.gameplayOpacity,
        ease = "QuadOut"
      })
      if self.opacitySet then
        self.opacitySet = false
      end
    end
    local fadingEntities = {}
    if self.fadeDuration > 10 then
      for i = 0, #self.messageOpacity - 1 do
        local chatEntityId = UiDynamicScrollBoxBus.Event.GetChildAtElementIndex(self.Properties.EntityChatBox, self.messageStartFadeIndex - i)
        fadingEntities[tostring(chatEntityId)] = 1
      end
    end
    local children = UiElementBus.Event.GetChildren(self.Properties.EntityChatBoxContent)
    for i = 1, #children do
      local chatMessageId = children[i]
      local chatMessage = self.registrar:GetEntityTable(chatMessageId)
      if chatMessageId ~= nil then
        if isVisible then
          self.ScriptedEntityTweener:Set(chatMessageId, {opacity = 1})
        elseif fadingEntities[tostring(children[i])] == nil then
          self.ScriptedEntityTweener:Set(chatMessageId, {opacity = 0})
        end
      end
    end
  end
end
function ChatScreen:IsInWidgetState()
  return self.isInWidgetState
end
function ChatScreen:SetFlyoutWidgetState(isEnabled)
  if self.isInWidgetState ~= isEnabled then
    self.isInWidgetState = isEnabled
    if isEnabled then
      self.defaultDrawOrder = UiCanvasBus.Event.GetDrawOrder(self.canvasId)
      local canvasCommon = RequireScript("LyShineUI._Common.CanvasCommon")
      local drawOrder = canvasCommon.CHAT_WIDGET_DRAW_ORDER
      UiCanvasBus.Event.SetDrawOrder(self.canvasId, drawOrder)
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Screens.Chat.SetContainerVisibility", true)
      self.screenEnteredForChat = false
      self:FocusChatTextField(false)
      self:UpdateVisibility(3326371288)
      self:SetContainerVisibility(true, true)
    else
      UiCanvasBus.Event.SetDrawOrder(self.canvasId, self.defaultDrawOrder)
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Screens.Chat.SetContainerVisibility", false)
      self.isInWidgetState = false
      self:OnTransitionOut(self.toState, nil, self.toState)
      self:SetContainerVisibility(false, true)
    end
    LyShineDataLayerBus.Broadcast.SetData("Hud.Chat.WidgetStateEnabled", self.isInWidgetState)
  end
end
function ChatScreen:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  self.toState = toState
  if toState == 3326371288 then
    self:SetFlyoutWidgetState(true)
    return
  end
  self:UpdateVisibility(toState)
end
function ChatScreen:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  if self.isInWidgetState then
    self:SetFlyoutWidgetState(false)
    return
  end
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  self:UpdateVisibility(toState)
  self:SetChatSettingsVisibility(false)
  self.ChatChannelListContainer:SetIsFocused(false)
end
function ChatScreen:SetChatSettingsVisibility(isVisible)
  local wasVisible = UiElementBus.Event.IsEnabled(self.Properties.ChatSettingsContainer)
  UiElementBus.Event.SetIsEnabled(self.Properties.ChatSettingsContainer, isVisible)
  self.isChatSettingsVisible = isVisible
  if not isVisible and wasVisible then
    OptionsDataBus.Broadcast.SerializeOptions()
  end
  if isVisible and not self.hasSizedSettings then
    self:UpdateChatSettingsSize()
  end
end
function ChatScreen:UpdateChatSettingsSize()
  local displaySettingsHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.ChatDisplaySettings)
  local channelSettingsHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.ChatChannelSettings)
  local targetHeight = math.max(displaySettingsHeight, channelSettingsHeight)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.ChatSettingsContainer, targetHeight)
  self.hasSizedSettings = true
end
function ChatScreen:OnChatSettingsClickoutPressed()
  self:SetChatSettingsVisibility(false)
end
function ChatScreen:UpdateVisibility(toState)
  local isChatEnabled = not self.screenStatesToDisable[toState]
  if toState == 3326371288 then
    isChatEnabled = self.isInWidgetState
  end
  UiCanvasBus.Event.SetEnabled(self.canvasId, isChatEnabled)
  self.isChatEnabled = isChatEnabled
  self.isInNavBar = toState == 3766762380
  LyShineDataLayerBus.Broadcast.SetData("Hud.Chat.Visibility", isChatEnabled)
  DynamicBus.InlineTextSuggestions.Broadcast.StopSuggestions()
  DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
  if not isChatEnabled then
    self.reenterChatField = false
  end
end
function ChatScreen:EnterChatField()
  self:OnChangeChatField()
  self:UpdateTipVisibility()
  self:SetInteractState(true)
  self.ScriptedEntityTweener:Play(self.Properties.ChatBackground, self.animDuration1, {
    opacity = 1,
    imgColor = self.UIStyle.COLOR_GRAY_80,
    ease = "QuadOut"
  })
  self.screenEnteredForChat = true
  self.isChatFocused = true
  self.ChannelPillsDropdown:SetIsExpanded(false)
end
function ChatScreen:ExitChatField()
  self:OnChangeChatField()
  self.ScriptedEntityTweener:Play(self.Properties.ChatBackground, self.animDuration1, {
    opacity = 0.6,
    imgColor = self.UIStyle.COLOR_TAN,
    ease = "QuadOut"
  })
  if not self.isWhisperFocused then
    self:SetInteractState(false)
  end
  self.isChatFocused = false
  self.screenEnteredForChat = false
  self.ChannelPillsDropdown:SetIsExpanded(false)
end
function ChatScreen:OnChangeChatField()
  local textHeight = UiTextBus.Event.GetTextHeight(self.Properties.ChatInputText)
  local padding = 6
  local chatTextFieldHeight = textHeight + self.textFieldTop + padding
  if chatTextFieldHeight ~= self.chatTextFieldHeight then
    local chatInputTextPositionY = UiTransformBus.Event.GetLocalPositionY(self.Properties.ChatInputText)
    local chatInputTextHeight = chatTextFieldHeight - chatInputTextPositionY
    self.ScriptedEntityTweener:Play(self.Properties.ChatInputText, 0.2, {h = chatInputTextHeight, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ChatTextField, 0.2, {h = chatTextFieldHeight, ease = "QuadOut"})
    self.chatTextFieldHeight = chatTextFieldHeight
    self:PositionContentToChatField()
  end
  UiFaderBus.Event.SetFadeValue(self.Properties.ChatInputPlaceholderText, UiTextBus.Event.GetText(self.Properties.ChatInputText) == "" and 1 or 0)
end
function ChatScreen:PositionContentToChatField()
  local margin = 50
  self:SetContentBottom(-1 * (self.chatTextFieldHeight + margin))
end
function ChatScreen:EnterWhisperField()
  self:UpdateTipVisibility()
  self:SetInteractState(true)
  self.ScriptedEntityTweener:Play(self.Properties.WhisperBackground, self.animDuration1, {
    opacity = 1,
    imgColor = self.UIStyle.COLOR_GRAY_80,
    ease = "QuadOut"
  })
  self.isWhisperFocused = true
end
function ChatScreen:ExitWhisperField()
  self:SetRecipientName()
  self.ScriptedEntityTweener:Play(self.Properties.WhisperBackground, self.animDuration1, {
    opacity = 0.6,
    imgColor = self.UIStyle.COLOR_TAN,
    ease = "QuadOut"
  })
  if not self.isChatFocused then
    self:SetInteractState(false)
  end
  self.isWhisperFocused = false
end
function ChatScreen:OnChangeWhisperField()
  UiFaderBus.Event.SetFadeValue(self.Properties.WhisperPlaceholderText, UiTextBus.Event.GetText(self.Properties.WhisperInputText) == "" and 1 or 0)
end
function ChatScreen:WhisperFieldOnEnter()
  self:FocusChatTextField()
end
function ChatScreen:SendMessage()
  if DynamicBus.InlineTextSuggestions.Broadcast.GetIsVisible() then
    return
  end
  local textMessage = UiTextInputBus.Event.GetText(self.Properties.ChatTextField)
  if textMessage and textMessage:len() > 0 then
    do
      local chatMessageType = self.chatChannels[self.currentChannelIndex].name
      if textMessage ~= self.sentHistory:GetAt(1) then
        self.sentHistory:Push(textMessage)
      end
      self.sentHistoryIndex = 0
      if string.sub(textMessage, 1, 1) == "/" then
        local command = string.sub(textMessage, 2)
        if command and command ~= "" and not self:TrySpecialCommands(command) then
          SlashCommands:HandleSlashCommand(textMessage)
        end
      else
        local isWhisper = chatMessageType == eChatMessageType_Whisper
        if isWhisper then
          SocialDataHandler:GetPlayerIdentificationByName_ServerCall(self, function(self, result)
            if 0 < #result then
              local playerId = result[1].playerId
              if ChatComponentBus.Broadcast.IsPlayerMuted(playerId.characterIdString) then
                local chatMessage = BaseGameChatMessage()
                chatMessage.type = eChatMessageType_System
                chatMessage.body = self.whisperBlockErrorMsg
                ChatComponentBus.Broadcast.WriteMessageToLocalChat(chatMessage)
              else
                ChatComponentBus.Broadcast.SendChatMessage(chatMessageType, textMessage, playerId.playerName, self.linkedItems)
              end
            else
              local notificationData = NotificationData()
              notificationData.type = "Minor"
              notificationData.text = "@ui_error_whisper_no_recipient"
              UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
            end
          end, function()
          end, self.recipientName)
        else
          ChatComponentBus.Broadcast.SendChatMessage(chatMessageType, textMessage, "", self.linkedItems)
        end
      end
      if self.isFilteringGlobal and chatMessageType == eChatMessageType_Global then
        self:OnToggleGlobal()
        UiCheckboxBus.Event.SetState(self.Properties.ShowGlobalChatCheckbox, true)
      end
    end
  end
  UiTextInputBus.Event.SetText(self.Properties.ChatTextField, "")
  self:ClearLinkedItem()
  self:UpdateRemainingText()
  local closeChatAfterSending = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Options.Chat.ChatCloseAfterSending")
  if self.screenEnteredForChat and closeChatAfterSending then
    if self.isInWidgetState then
      DynamicBus.ChatBus.Broadcast.SetFlyoutWidgetState(false)
    else
      LyShineManagerBus.Broadcast.SetState(2702338936)
    end
    self.screenEnteredForChat = false
  else
    self:QueueEnterChatField()
  end
end
function ChatScreen:QueueEnterChatField()
  self.reenterChatField = true
  if self.tickBusHandler == nil then
    self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function ChatScreen:ReplyToWhisper(whisperName)
  self.lastWhisperName = whisperName
  TimingUtils:Delay(0.1, self, function()
    self:TrySlashSetChannel(self.whisperReplyCmd)
  end)
end
function ChatScreen:TrySpecialCommands(command)
  return self:TrySlashSetChannel(command) or self:TryEmoteSlashCommand(command) or self:TryHelpCommand(command) or self:TryGroupAlertCommand(command) or self:TryDuelCommand(command) or self:TryTradeCommand(command) or self:TryKickCommand(command) or self:TryRequestMute(command) or self:TryRequestUnmute(command) or self:TryRequestFriend(command) or self:TryRequestUnfriend(command)
end
function ChatScreen:TrySlashSetChannel(textString)
  textString = textString:upper()
  if self.lastWhisperName ~= "" and textString == self.whisperReplyCmd then
    self:SetActiveOutputChannel(eChatMessageType_Whisper)
    self.WhisperTextField:SetText(self.lastWhisperName)
    self:SetRecipientName()
    self:FocusChatTextField()
    self:OnChangeWhisperField()
    return true
  end
  for channelIndex, channelData in ipairs(self.chatChannels) do
    local localizedDisplayName = LyShineScriptBindRequestBus.Broadcast.LocalizeText(channelData.displayName)
    if channelData.canSelect and (localizedDisplayName:upper() == textString or channelData.shortcut:upper() == textString) then
      if self:CanSelectOutputChannel(channelData, false, true) then
        if self.currentChatChannel == ChatChannelData.feedChannelId then
          self:SetActiveOutputChannel(channelData.name)
        else
          self:SwitchViewedChannel(channelData.name)
          self.ChatChannelList:UpdateViewedChannel(self.currentChatChannel)
        end
      else
        local message = ""
        if channelData.name == eChatMessageType_Guild then
          local guildId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Id")
          local isInGuild = guildId and guildId:IsValid()
          if not isInGuild then
            message = "@ui_error_guildchat"
          end
        end
        if message == "" then
          if channelData.name == eChatMessageType_Guild_Officer then
            message = "@ui_error_officerchat"
          elseif channelData.name == eChatMessageType_Group then
            message = "@ui_error_groupchat"
          elseif channelData.name == eChatMessageType_Raid then
            message = "@ui_error_raidchat"
          elseif self.currentChatChannel == ChatChannelData.feedChannelId then
            message = GetLocalizedReplacementText("@ui_error_muted_in_feed", {name = localizedDisplayName})
          end
        end
        if message ~= "" then
          local chatMessageData = {
            chatType = eChatMessageType_System,
            chatMessage = LyShineScriptBindRequestBus.Broadcast.LocalizeText(message)
          }
          self:QueueChatMessage(chatMessageData)
        end
      end
      return true
    end
  end
  return false
end
function ChatScreen:TryEmoteSlashCommand(textString)
  textString = textString:lower()
  for i = 1, #self.emoteSlashCommands do
    if textString == self.emoteSlashCommands[i] then
      local emoteSuccess = LocalPlayerUIRequestsBus.Broadcast.StartEmoteBySlashCommand(textString)
      if not emoteSuccess then
        local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
        local isEntitled = EmoteControllerComponentRequestsBus.Event.IsEmoteEntitled(playerEntityId, Math.CreateCrc32(textString))
        if not isEntitled then
          return true
        end
        local chatMessageData = {
          chatType = eChatMessageType_System,
          chatMessage = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_emote_unavailable")
        }
        self:QueueChatMessage(chatMessageData)
      end
      return true
    end
  end
  return false
end
function ChatScreen:TryHelpCommand(textString)
  if textString == "?" or textString:lower() == self.helpCommand then
    if self.dataLayer:GetDataFromNode("UIFeatures.g_uiEnableDebugSlashCommands") then
      self:SetHelpText(true)
    end
    local chatMessageData = {
      chatType = eChatMessageType_System,
      chatMessage = self.helpText
    }
    self:QueueChatMessage(chatMessageData)
    return true
  end
  return false
end
local chatMessage = BaseGameChatMessage()
function ChatScreen:TryGroupAlertCommand(textString)
  if string.sub(textString, 1, 5) == "alert" then
    textString = string.sub(textString, 6)
  else
    return false
  end
  local raidId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Raid.Id")
  if self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Group.IsGroupLeader") and raidId and raidId:IsValid() then
    ChatComponentBus.Broadcast.SendChatMessage(eChatMessageType_GroupAlert, textString, "", self.linkedItems)
  else
    chatMessage.type = eChatMessageType_System
    chatMessage.body = self.alertErrorMsg
    ChatComponentBus.Broadcast.WriteMessageToLocalChat(chatMessage)
  end
  return true
end
function ChatScreen:TryDuelCommand(textString)
  local playerName = self:GetPlayerFromCommand("duel", textString)
  if not playerName then
    return false
  end
  if playerName == "" then
    return true
  end
  local duelsEnabled = self.dataLayer:GetDataFromNode("javelin.enable-game-mode-duels")
  if not duelsEnabled then
    return true
  end
  SocialDataHandler:GetPlayerIdentificationByName_ServerCall(self, function(self, result)
    if 0 < #result then
      local playerId = result[1].playerId
      local canInviteToDuel, errorMessage = genericInviteCommon:ValidateEligibility(2612307810, playerId)
      if canInviteToDuel then
        genericInviteCommon:RequestSendNewDuelInvite(playerId:GetCharacterIdString())
      elseif errorMessage then
        local notificationData = NotificationData()
        notificationData.type = "Minor"
        notificationData.text = errorMessage
        UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
      end
    else
      self:OnPlayerIdentificationFailed(playerName, "@ui_duel_failmessage_invalidname")
    end
  end, function(self)
    self:OnPlayerIdentificationFailed(playerName, "@ui_duel_failmessage_invalidname")
  end, playerName)
  return true
end
function ChatScreen:TryTradeCommand(textString)
  local playerName = self:GetPlayerFromCommand("trade", textString)
  if not playerName then
    return false
  end
  if playerName == "" then
    return true
  end
  local p2pTradingEnabled = self.dataLayer:GetDataFromNode("javelin.enable-p2p-trading")
  if not p2pTradingEnabled then
    return true
  end
  SocialDataHandler:GetPlayerIdentificationByName_ServerCall(self, function(self, result)
    if 0 < #result then
      local playerId = result[1].playerId
      local canInviteToTrade, errorMessage = genericInviteCommon:ValidateEligibility(2115650406, playerId)
      if canInviteToTrade then
        genericInviteCommon:RequestSendNewInvite(2115650406, eForwardType_Solo, playerId:GetCharacterIdString(), "@ui_p2ptrading_trade_notification_sent")
      elseif errorMessage then
        local notificationData = NotificationData()
        notificationData.type = "Minor"
        notificationData.text = errorMessage
        UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
      end
    else
      self:OnPlayerIdentificationFailed(playerName, "@ui_p2ptrading_failmessage_invalidname")
    end
  end, function(self)
    self:OnPlayerIdentificationFailed(playerName, "@ui_p2ptrading_failmessage_invalidname")
  end, playerName)
  return true
end
function ChatScreen:TryKickCommand(textString)
  local playerName = self:GetPlayerFromCommand("kick", textString)
  if not playerName then
    return false
  end
  if playerName == "" then
    return true
  end
  local groupKickEnabled = ConfigProviderEventBus.Broadcast.GetBool("javelin.social.group-kick-enabled")
  if not groupKickEnabled then
    return true
  end
  SocialDataHandler:GetPlayerIdentificationByName_ServerCall(self, function(self, result)
    if 0 < #result then
      local playerId = result[1].playerId
      local isGroupMate = LocalGroupRequestBus.Broadcast.IsGroupMate(playerId:GetCharacterIdString())
      if isGroupMate then
        GroupsRequestBus.Broadcast.RequestInitiateKickVotePlayer(playerId:GetCharacterIdString())
      else
        self:OnPlayerIdentificationFailed(playerName, "@ui_votekick_failed_notingroup")
      end
    else
      self:OnPlayerIdentificationFailed(playerName, "@ui_votekick_failed_invalidname")
    end
  end, function(self)
    self:OnPlayerIdentificationFailed(playerName, "@ui_votekick_failed_invalidname")
  end, playerName)
  return true
end
function ChatScreen:ToggleStreamerMode()
  local streamerModeEnabled = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Options.Social.StreamerModeUI")
  local chatMessage = BaseGameChatMessage()
  chatMessage.type = eChatMessageType_System
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  if streamerModeEnabled then
    OptionsDataBus.Broadcast.SetStreamerModeUIEnabled(false)
    chatMessage.body = "@ui_streamermode_disabled"
    notificationData.text = "@ui_streamermode_disabled"
  else
    OptionsDataBus.Broadcast.SetStreamerModeUIEnabled(true)
    chatMessage.body = "@ui_streamermode_enabled"
    notificationData.text = "@ui_streamermode_enabled"
  end
  ChatComponentBus.Broadcast.WriteMessageToLocalChat(chatMessage)
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function ChatScreen:OnPlayerIdentificationFailed(playerName, locString)
  local text = GetLocalizedReplacementText(locString, {playerName = playerName})
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = text
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function ChatScreen:SetRecipientName()
  local recipientName = self.WhisperTextField:GetText()
  if recipientName and recipientName:len() > 0 then
    self.recipientName = recipientName
  else
    self.recipientName = ""
  end
end
function ChatScreen:FocusChatTextField(focusedWithSlash)
  UiCanvasBus.Event.SetActiveInteractable(self.canvasId, self.ChatTextField, true)
  UiTextInputBus.Event.BeginEdit(self.Properties.ChatTextField)
  self:UpdateTipVisibility()
  if focusedWithSlash then
    UiTextInputBus.Event.SetText(self.Properties.ChatTextField, "/")
    self:ClearLinkedItem()
  end
end
function ChatScreen:FocusWhisperTextField()
  local hasWhisperRecipient = self.recipientName ~= ""
  if not hasWhisperRecipient then
    self.WhisperTextField:SetActiveAndBegin()
  end
  self:UpdateTipVisibility()
end
function ChatScreen:UpdateTipVisibility()
  local isNotWhisperChannel = self.chatChannels[self.currentChannelIndex].name ~= eChatMessageType_Whisper
  local textMessage = self.WhisperTextField:GetText()
  UiElementBus.Event.SetIsEnabled(self.Properties.WhisperTextTip, isNotWhisperChannel or textMessage:len() == 0)
end
function ChatScreen:SetInteractState(isFocused)
  local channelName = self.chatChannels[self.currentChannelIndex].name
  channelName = channelName or eChatMessageType_Global
  SetActionmapsForTextInput(self.canvasId, isFocused)
end
function ChatScreen:OnUpArrow(entity, textString)
  if DynamicBus.InlineTextSuggestions.Broadcast.GetIsVisible() then
    return
  end
  self.sentHistoryIndex = math.min(self.sentHistory:GetCount(), self.sentHistoryIndex + 1)
  self:OnChatArrow()
end
function ChatScreen:OnDownArrow(entity, textString)
  if DynamicBus.InlineTextSuggestions.Broadcast.GetIsVisible() then
    return
  end
  self.sentHistoryIndex = math.max(0, self.sentHistoryIndex - 1)
  self:OnChatArrow()
end
function ChatScreen:OnChatArrow()
  local text = self.sentHistory:GetAt(self.sentHistoryIndex)
  if not text then
    text = ""
    self.sentHistoryIndex = 0
  end
  UiTextInputBus.Event.SetText(self.Properties.ChatTextField, text)
  self:ClearLinkedItem()
  self:UpdateRemainingText()
  self:OnChangeChatField()
end
function ChatScreen:ClearLinkedItem()
  UiTextInputBus.Event.SetMaxStringLength(self.Properties.ChatTextField, self.MaxMessageLength)
  self.linkedItems:clear()
end
function ChatScreen:UpdateRemainingText()
  local remaining = self.MaxMessageLength - self:GetCurrentMessageSize()
  UiTextBus.Event.SetText(self.Properties.ChatLimitIndicator, tostring(remaining))
end
function ChatScreen:OnTextInputChange(textString)
  textString = textString or ""
  local stringLength = string.len(textString)
  if 0 < stringLength and string.sub(textString, 1, 1) == "/" and string.sub(textString, stringLength) == " " and self:TrySlashSetChannel(string.sub(textString, 2, stringLength - 1)) then
    UiTextInputBus.Event.SetText(self.Properties.ChatTextField, "")
    self:ClearLinkedItem()
  end
  self:UpdateRemainingText()
  if self.chatChannels[self.currentChannelIndex].name ~= eChatMessageType_Whisper and 0 < stringLength then
    JavSocialComponentBus.Broadcast.SetChattingState(eSocialChattingState_Text)
  end
  if string.find(textString, "@[^@%s]*$") then
    if not self.foundSuggestion then
      self.foundSuggestion = true
      local fieldViewportPos = UiTransformBus.Event.GetViewportPosition(self.Properties.ChatInputText)
      fieldViewportPos.x = fieldViewportPos.x + UiTextBus.Event.GetTextWidth(self.Properties.ChatInputText)
      DynamicBus.InlineTextSuggestions.Broadcast.RequestSuggestions(self:GetSuggestionsForChannel(self.currentChatChannel), self.Properties.ChatTextField, self, self.OnMentionSuggestionSelected, fieldViewportPos, nil, "@")
    end
  elseif self.foundSuggestion then
    DynamicBus.InlineTextSuggestions.Broadcast.StopSuggestions()
    self.foundSuggestion = false
  end
end
function ChatScreen:OnMentionSuggestionSelected(selectedData)
  local currentText = UiTextInputBus.Event.GetText(self.Properties.ChatTextField)
  local replacedString = string.gsub(currentText, "@[^@]*$", "@" .. selectedData.displayName)
  UiTextInputBus.Event.SetText(self.Properties.ChatTextField, replacedString)
  self:QueueEnterChatField()
  self:UpdateRemainingText()
end
function ChatScreen:GetSuggestionsForChannel(channelName)
  local results = {}
  if channelName == ChatChannelData.feedChannelId or channelName == eChatMessageType_Area or channelName == eChatMessageType_Global or channelName == eChatMessageType_Help or channelName == eChatMessageType_Recruitment or channelName == eChatMessageType_Guild or channelName == eChatMessageType_Guild_Officer then
    local maxSuggestions = 100
    local chatMessages = self.chatMessagesByChannel[channelName]
    for i = 1, chatMessages:GetCount() do
      local message = chatMessages:GetAt(i)
      if type(message.chatSender) == "userdata" then
        local sender = message.chatSender.playerName
        local found = false
        for _, entries in ipairs(results) do
          if entries.displayName == sender then
            found = true
            break
          end
        end
        if not found then
          table.insert(results, {displayName = sender})
          if maxSuggestions < #results then
            break
          end
        end
      end
    end
  elseif channelName == eChatMessageType_Group then
    local memberCount = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Group.MemberCount")
    local groupNode = self.dataLayer:GetDataNode("Hud.LocalPlayer.Group.Members")
    for i = 1, memberCount do
      local node = groupNode[tostring(i)]
      if node ~= nil then
        local playerId = node.PlayerId:GetData()
        table.insert(results, {
          displayName = playerId.playerName
        })
      end
    end
  end
  return results
end
function ChatScreen:OnTab(entity, textString)
  if entity == self.Properties.WhisperTextField then
    self:FocusChatTextField()
    return
  end
  if DynamicBus.InlineTextSuggestions.Broadcast.GetIsVisible() then
    DynamicBus.InlineTextSuggestions.Broadcast.OnTextInputEnter()
    return
  end
  local newChannelData
  local hasChannelChanged = false
  for i = self.currentChannelIndex + 1, #self.chatChannels do
    newChannelData = self.chatChannels[i]
    if self:CanSelectOutputChannel(newChannelData) then
      hasChannelChanged = true
      break
    end
  end
  if not hasChannelChanged then
    for channelIndex, channelData in ipairs(self.chatChannels) do
      if self:CanSelectOutputChannel(channelData) then
        newChannelData = channelData
        break
      end
    end
  end
  if self.currentChatChannel ~= ChatChannelData.feedChannelId then
    self:SwitchViewedChannel(newChannelData.name, true)
    self.ChatChannelList:UpdateViewedChannel(newChannelData.name)
  else
    self:SetActiveOutputChannel(newChannelData.name)
  end
end
function ChatScreen:OnCtrlTab(entity, textString)
  local newChannelData
  local hasChannelChanged = false
  for i = self.currentChannelIndex - 1, 1, -1 do
    newChannelData = self.chatChannels[i]
    if self:CanSelectOutputChannel(newChannelData) then
      hasChannelChanged = true
      break
    end
  end
  if not hasChannelChanged then
    for i = #self.chatChannels, 1, -1 do
      newChannelData = self.chatChannels[i]
      if self:CanSelectOutputChannel(newChannelData) then
        break
      end
    end
  end
  if self.currentChatChannel ~= ChatChannelData.feedChannelId then
    self:SwitchViewedChannel(newChannelData.name, true)
    self.ChatChannelList:UpdateViewedChannel(newChannelData.name)
  else
    self:SetActiveOutputChannel(newChannelData.name)
  end
end
function ChatScreen:CanSelectOutputChannel(channelData, onlyCheckPermissions, isSlashCommand)
  if not self.isChannelsEnabled or onlyCheckPermissions then
    return self:IsWhisperToPlayerChannel(channelData.name) or channelData.hasPermission
  end
  local canSelect = channelData.hasPermission
  if canSelect then
    if self.currentChatChannel == ChatChannelData.feedChannelId then
      return self:IsChannelInFeed(channelData.name)
    elseif self:IsWhisperToPlayerChannel(self.currentChatChannel) then
      return channelData.name == eChatMessageType_Whisper
    else
      return true
    end
  end
  return canSelect
end
function ChatScreen:OnShowData(args)
  local path = ""
  if 2 <= #args then
    path = args[2]
  end
  self.dataLayer:LogPath(path)
end
function ChatScreen:OnSetData(args)
  if 3 <= #args then
    LyShineDataLayerBus.Broadcast.SetData(args[2], args[3])
  end
end
function ChatScreen:OnStuck(args)
  LocalPlayerComponentRequestBus.Broadcast.RequestUnstuck()
end
function ChatScreen:OnRequestAge(args)
  LocalPlayerComponentRequestBus.Broadcast.RequestAge()
end
function ChatScreen:OpenWhisperToPlayer(playerName, skipInputFocus)
  self.WhisperTextField:SetText(playerName)
  self:OnChangeWhisperField()
  self:SetRecipientName()
  if not skipInputFocus then
    self:OpenChatOrFlyout()
  end
  self:SetActiveOutputChannel(eChatMessageType_Whisper, skipInputFocus)
  self:UpdateTipVisibility()
  local hasWhisperRecipient = self.recipientName ~= ""
  if not skipInputFocus and not hasWhisperRecipient then
    UiCanvasBus.Event.SetActiveInteractable(self.canvasId, self.ChatTextField, false)
    self:FocusWhisperTextField()
  end
  if hasWhisperRecipient then
    TimingUtils:Delay(0.1, self, function()
      self:QueueEnterChatField()
    end)
  end
end
function ChatScreen:SetActiveOutputChannel(channelName, skipInputFocus)
  for index, channelData in ipairs(self.chatChannels) do
    if channelData.name == channelName then
      local chatChannelColor = channelData.color
      UiTextBus.Event.SetColor(self.Properties.ChatInputText, chatChannelColor)
      LyShineDataLayerBus.Broadcast.SetData("Hud.Chat.ActiveOutputChannel", channelName)
      self.ChannelPillsDropdown:SetActiveChannel(channelName)
      if channelData.name == eChatMessageType_Whisper then
        UiElementBus.Event.SetIsEnabled(self.Properties.WhisperTextField, true)
        if not skipInputFocus then
          self:FocusWhisperTextField()
        end
      elseif self.chatChannels[self.currentChannelIndex].name == eChatMessageType_Whisper then
        UiElementBus.Event.SetIsEnabled(self.Properties.WhisperTextField, false)
        if not skipInputFocus then
          self:FocusChatTextField()
        end
      end
      self.currentChannelIndex = index
      self:UpdateTipVisibility()
      DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
      break
    end
  end
end
function ChatScreen:OpenChatOrFlyout(focusChatTextField, actionName)
  local chatWidgetEnabled = self.dataLayer:GetDataFromNode("UIFeatures.g_chatWidget")
  if not self.forceUseWidget and (LyShineManagerBus.Broadcast.GetCurrentLevel() <= 0 or self.isInNavBar or not chatWidgetEnabled) then
    self:OpenChat(actionName)
  else
    self:SetFlyoutWidgetState(true)
  end
  if focusChatTextField then
    self:QueueEnterChatField()
  end
end
function ChatScreen:LinkItem(itemDescriptor)
  self:OpenChatOrFlyout()
  local newMessageSize = self:GetCurrentMessageSize() + self.itemSize + self.itemReplacementCharSize
  if newMessageSize > self.MaxMessageLength then
    return
  end
  self.linkedItems:push_back(itemDescriptor)
  local displayName = itemDescriptor:GetDisplayName()
  local textMessage = UiTextInputBus.Event.GetText(self.Properties.ChatTextField)
  textMessage = string.format(textMessage .. "[%s]", displayName)
  textMessage = LyShineScriptBindRequestBus.Broadcast.LocalizeText(textMessage)
  local maxStringLength = string.len(textMessage) + (self.MaxMessageLength - newMessageSize)
  UiTextInputBus.Event.SetMaxStringLength(self.Properties.ChatTextField, maxStringLength)
  UiTextInputBus.Event.SetText(self.Properties.ChatTextField, textMessage)
  self:QueueEnterChatField()
  self:UpdateRemainingText()
end
function ChatScreen:GetCurrentMessageSize()
  local totalItemTextSize = 0
  local numLinkedItems = #self.linkedItems
  for i = 1, numLinkedItems do
    local itemDesc = self.linkedItems[i]
    totalItemTextSize = totalItemTextSize + #LyShineScriptBindRequestBus.Broadcast.LocalizeText(itemDesc:GetDisplayName()) + self.bracketPaddingSize
  end
  local totalItemDataSize = self.itemSize * numLinkedItems + self.itemReplacementCharSize * numLinkedItems
  local textMessageSize = #UiTextInputBus.Event.GetText(self.Properties.ChatTextField)
  return textMessageSize - totalItemTextSize + totalItemDataSize
end
function ChatScreen:TrySwitchChannel(channelData)
  if self:CanSelectOutputChannel(channelData, true) then
    self:SwitchViewedChannel(channelData.name, true)
    return true
  end
end
function ChatScreen:CycleViewedChannel(cycleBackward)
  local isWhisperChannel = self:IsWhisperToPlayerChannel(self.currentChatChannel)
  if cycleBackward then
    if isWhisperChannel then
      local doSwitch = false
      for i = #self.whisperChannelMessageData, 1, -1 do
        local data = self.whisperChannelMessageData[i]
        if doSwitch then
          self:SwitchViewedChannel(data.whisperTarget, true)
          return
        elseif data.whisperTarget == self.currentChatChannel then
          doSwitch = true
        end
      end
      for i = #self.chatChannels, 1, -1 do
        if self:TrySwitchChannel(self.chatChannels[i]) then
          return
        end
      end
    elseif self.currentChatChannel == ChatChannelData.feedChannelId then
      for i = #self.whisperChannelMessageData, 1, -1 do
        local data = self.whisperChannelMessageData[i]
        self:SwitchViewedChannel(data.whisperTarget, true)
        return
      end
      for i = #self.chatChannels, 1, -1 do
        if self:TrySwitchChannel(self.chatChannels[i]) then
          return
        end
      end
    else
      local index = ChatChannelData:GetChannelDataIndex(self.currentChatChannel)
      for i = index - 1, 1, -1 do
        local nextChannel = self.chatChannels[i]
        if self:TrySwitchChannel(nextChannel) then
          return
        end
      end
      self:SwitchViewedChannel(ChatChannelData.feedChannelId, true)
    end
  else
    if isWhisperChannel then
      local doSwitch = false
      for _, data in ipairs(self.whisperChannelMessageData) do
        if doSwitch then
          self:SwitchViewedChannel(data.whisperTarget, true)
          return
        elseif data.whisperTarget == self.currentChatChannel then
          doSwitch = true
        end
      end
    else
      local index = ChatChannelData:GetChannelDataIndex(self.currentChatChannel)
      for i = index + 1, #self.chatChannels do
        local nextChannel = self.chatChannels[i]
        if self:TrySwitchChannel(nextChannel) then
          return
        end
      end
      for _, data in ipairs(self.whisperChannelMessageData) do
        self:SwitchViewedChannel(data.whisperTarget, true)
        return
      end
    end
    self:SwitchViewedChannel(ChatChannelData.feedChannelId, true)
  end
end
function ChatScreen:GetViewedChannel()
  return self.currentChatChannel
end
function ChatScreen:SwitchViewedChannel(channelName, skipInputFocus)
  self.currentChatChannel = channelName
  self.currentChatChannelMessages = self.chatMessagesByChannel[self.currentChatChannel]
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.EntityChatBox)
  LyShineDataLayerBus.Broadcast.SetData("Hud.Chat.CurrentChannel", self.currentChatChannel)
  self.ChannelPillsDropdown:SetCanExpand(self.currentChatChannel == ChatChannelData.feedChannelId)
  if self:IsWhisperToPlayerChannel(channelName) then
    self:OpenWhisperToPlayer(channelName, skipInputFocus)
    return
  end
  self:SetActiveOutputChannel(channelName, skipInputFocus)
end
function ChatScreen:IsWhisperToPlayerChannel(channelName)
  for _, data in ipairs(self.whisperChannelMessageData) do
    if data.whisperTarget == channelName then
      return true
    end
  end
  return false
end
function ChatScreen:OnChannelAvailabilityChanged(chatMessageType, isAvailable, skipChannelPillNotification)
  if not isAvailable then
    local isInChannel = self.chatChannels[self.currentChannelIndex].name == chatMessageType
    if isInChannel then
      self:SetActiveOutputChannel(eChatMessageType_Global)
    end
    local isViewingChannel = self.currentChatChannel == chatMessageType
    if isViewingChannel then
      self:SwitchViewedChannel(ChatChannelData.feedChannelId, true)
      self.ChatChannelList:UpdateViewedChannel(ChatChannelData.feedChannelId)
    end
  end
  DynamicBus.Chat_ChannelList.Broadcast.OnChannelAvailabilityChanged(chatMessageType, isAvailable)
  if not skipChannelPillNotification then
    self.ChannelPillsDropdown:OnChannelAvailabilityChanged()
  end
end
function ChatScreen:OnChatChannelSettingChanged(channelName, chatMessageTypeState)
  self:SetChannelInFeed(channelName, chatMessageTypeState ~= eChatMessageTypeState_Muted)
end
function ChatScreen:SetChannelInFeed(requestedChannelName, isInFeed)
  local indexOfChannel = self:IsChannelInFeed(requestedChannelName)
  local isAlreadyInFeed = indexOfChannel ~= nil
  if isInFeed and not isAlreadyInFeed then
    table.insert(self.channelsInFeed, requestedChannelName)
  elseif isAlreadyInFeed and not isInFeed then
    table.remove(self.channelsInFeed, indexOfChannel)
  end
  self:ReinitializeFeed()
end
function ChatScreen:IsChannelInFeed(channelNameToCheck)
  if self:IsWhisperToPlayerChannel(channelNameToCheck) then
    channelNameToCheck = eChatMessageType_Whisper
  end
  for channelIndex, channelName in ipairs(self.channelsInFeed) do
    if channelNameToCheck == channelName then
      return channelIndex
    end
  end
  return nil
end
function ChatScreen:CloseChatSettingsWindow()
  self:SetChatSettingsVisibility(false)
end
function ChatScreen:OnPopupResult(result, eventId)
  if result ~= ePopupResult_Yes then
    return
  end
  if eventId == self.onInvitePlayerEventId then
    GroupsRequestBus.Broadcast.RequestGroupInvite(self.playerToInvite)
    self.playerToInvite = nil
  end
end
function ChatScreen:RequestGroupInvite(args)
  if not args or #args < 2 then
    return
  end
  local playerName = args[2]
  if not playerName then
    return
  end
  if playerName == "" then
    return true
  end
  for i = 3, #args do
    playerName = playerName .. " " .. args[i]
  end
  SocialDataHandler:GetPlayerIdentificationByName_ServerCall(self, function(self, result)
    if 0 < #result then
      local playerId = result[1].playerId
      local playerRootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
      local isInOutpostRushQueue = GameModeParticipantComponentRequestBus.Event.IsInQueueForGameMode(playerRootEntityId, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
      if isInOutpostRushQueue then
        self.playerToInvite = playerId:GetCharacterIdString()
        PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_invitetogroup", "@ui_queuewarning_invite", self.onInvitePlayerEventId, self, self.OnPopupResult)
      else
        GroupsRequestBus.Broadcast.RequestGroupInvite(playerId:GetCharacterIdString())
      end
    end
  end, function(self)
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@ui_group_invite_failed"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end, playerName)
end
function ChatScreen:GetPlayerFromCommand(commandName, commandString)
  local commandLength = string.len(commandName)
  if string.sub(commandString, 1, commandLength):lower() ~= commandName then
    return nil
  end
  local playerName = NameValidationCommon:TrimString(string.sub(commandString, commandLength + 2))
  return playerName
end
function ChatScreen:CallbackCommandHelper(callback, playerName, errorString)
  SocialDataHandler:GetPlayerIdentificationByName_ServerCall(self, function(self, result)
    if 0 < #result then
      local playerId = result[1].playerId
      callback(playerId:GetCharacterIdString())
    end
  end, function(self)
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = errorString
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end, playerName)
end
function ChatScreen:CallbackWithOneParamCommandHelper(callback, callbackFirstParam, playerName, errorString)
  SocialDataHandler:GetPlayerIdentificationByName_ServerCall(self, function(self, result)
    if 0 < #result then
      local playerId = result[1].playerId
      callback(callbackFirstParam, playerId:GetCharacterIdString())
    end
  end, function(self)
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = errorString
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end, playerName)
end
function ChatScreen:TryRequestMute(textString)
  local playerName = self:GetPlayerFromCommand("mute", textString)
  if not playerName then
    return false
  end
  if playerName == "" then
    return true
  end
  self:CallbackCommandHelper(ChatComponentBus.Broadcast.SendSetChatMute, playerName, "@ui_set_mute_failed")
  return true
end
function ChatScreen:TryRequestUnmute(textString)
  local playerName = self:GetPlayerFromCommand("unmute", textString)
  if not playerName then
    return false
  end
  if playerName == "" then
    return true
  end
  self:CallbackCommandHelper(ChatComponentBus.Broadcast.SendClearChatMute, playerName, "@ui_clear_mute_failed")
  return true
end
function ChatScreen:TryRequestFriend(textString)
  local playerName = self:GetPlayerFromCommand("friend", textString)
  if not playerName then
    return false
  end
  if playerName == "" then
    return true
  end
  local function cb(characterId)
    local notificationData = NotificationData()
    notificationData.type = "FriendInvite"
    notificationData.contextId = self.entityId
    notificationData.title = "@ui_friendrequesttitle"
    notificationData.text = GetLocalizedReplacementText("@ui_friendrequestsendermessage", {playerName = playerName})
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    JavSocialComponentBus.Broadcast.RequestFriendStatusChange(eFriendRequestType_Invite, characterId)
  end
  self:CallbackCommandHelper(cb, playerName, "@ui_request_friend_failed")
  return true
end
function ChatScreen:TryRequestUnfriend(textString)
  local playerName = self:GetPlayerFromCommand("unfriend", textString)
  if not playerName then
    return false
  end
  if playerName == "" then
    return true
  end
  self:CallbackWithOneParamCommandHelper(JavSocialComponentBus.Broadcast.RequestFriendStatusChange, eFriendRequestType_Remove, playerName, "@ui_request_unfriend_failed")
  return true
end
function ChatScreen:SetContentBottom(value, skipAnimation)
  if value == self.contentPositionerOffsets.bottom then
    return
  end
  if skipAnimation then
    self.contentPositionerOffsets.bottom = value
    UiTransform2dBus.Event.SetOffsets(self.Properties.ContentPositioner, self.contentPositionerOffsets)
    self.chatChannelListContainerOffsets.bottom = value
  else
    do
      local startBottom = self.contentPositionerOffsets.bottom
      self.ScriptedEntityTweener:Play(self.Properties.ContentPositioner, 0.15, {
        scaleX = 1,
        onUpdate = function(currentValue, currentProgressPercent)
          local currentBottom = Lerp(startBottom, value, currentProgressPercent)
          self.contentPositionerOffsets.bottom = currentBottom
          UiTransform2dBus.Event.SetOffsets(self.Properties.ContentPositioner, self.contentPositionerOffsets)
          self.chatChannelListContainerOffsets.bottom = currentBottom
        end,
        onComplete = function()
          self.contentPositionerOffsets.bottom = value
          UiTransform2dBus.Event.SetOffsets(self.Properties.ContentPositioner, self.contentPositionerOffsets)
          self.chatChannelListContainerOffsets.bottom = value
        end
      })
    end
  end
end
function ChatScreen:ForceUseWidget(forceUseWidget)
  self.forceUseWidget = forceUseWidget
end
return ChatScreen
