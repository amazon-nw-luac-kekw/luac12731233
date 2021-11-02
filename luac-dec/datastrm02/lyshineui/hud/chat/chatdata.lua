local UIStyle = RequireScript("lyshineui/_common/UIStyle")
local ChatData = {
  feedChannelId = -1,
  colorGlobalChannel = UIStyle.COLOR_CHAT_GLOBAL,
  colorGuildChannel = UIStyle.COLOR_CHAT_COMPANY,
  colorGroupChannel = UIStyle.COLOR_CHAT_GROUP,
  colorRaidChannel = UIStyle.COLOR_CHAT_RAID,
  colorLocalChannel = UIStyle.COLOR_CHAT_AREA,
  colorWhisperChannel = UIStyle.COLOR_CHAT_DIRECT,
  colorEmote = Color(0.8),
  colorPing = ColorRgba(204, 204, 204, 1),
  colorSystem = Color(1, 0.4, 0.4, 1),
  colorGuildOfficerChannel = UIStyle.COLOR_CHAT_CONSUL,
  colorFactionChannel = UIStyle.COLOR_CHAT_FACTION,
  colorHelpChannel = UIStyle.COLOR_CHAT_HELP,
  colorRecruitmentChannel = UIStyle.COLOR_CHAT_RECRUITMENT,
  colorWhisperBackground = ColorRgba(0, 120, 126, 1),
  colorOtherChat = Color(0, 0, 0, 0),
  colorChatBackdrop = Color(1, 1, 1, 0.65),
  channelPillWidths = {},
  maxChannelPillWidth = 0
}
ChatData.chatChannels = {
  {
    name = eChatMessageType_Global,
    displayName = "@ui_chat_name_global",
    displayNameUpper = "@ui_chat_name_global_upper",
    shortcut = "g",
    canSelect = true,
    hasPermission = true,
    color = ChatData.colorGlobalChannel,
    widgetIcon = "lyshineui/images/icons/chat/channelGlobal.png",
    messageIcon = "lyshineui/images/icons/chat/channelGlobalSm.png",
    canOutput = true,
    canFilter = true,
    isPublicChannel = true,
    metricName = "Global"
  },
  {
    name = eChatMessageType_Area,
    displayName = "@ui_chat_name_local",
    displayNameUpper = "@ui_chat_name_local_upper",
    shortcut = "a",
    canSelect = true,
    hasPermission = true,
    color = ChatData.colorLocalChannel,
    widgetIcon = "lyshineui/images/icons/chat/channelArea.png",
    messageIcon = "lyshineui/images/icons/chat/channelAreaSm.png",
    canOutput = true,
    canFilter = true,
    isPublicChannel = true,
    metricName = "Area"
  },
  {
    name = eChatMessageType_Help,
    displayName = "@ui_chat_name_help",
    displayNameUpper = "@ui_chat_name_help_upper",
    shortcut = "help",
    canSelect = true,
    hasPermission = true,
    color = ChatData.colorHelpChannel,
    widgetIcon = "lyshineui/images/icons/chat/channelHelp.png",
    messageIcon = "lyshineui/images/icons/chat/channelHelpSm.png",
    canOutput = true,
    canFilter = true,
    isPublicChannel = true,
    metricName = "Help"
  },
  {
    name = eChatMessageType_Recruitment,
    displayName = "@ui_chat_name_recruitment",
    displayNameUpper = "@ui_chat_name_recruitment_upper",
    shortcut = "rec",
    canSelect = true,
    hasPermission = true,
    color = ChatData.colorRecruitmentChannel,
    widgetIcon = "lyshineui/images/icons/chat/channelRecruitment.png",
    messageIcon = "lyshineui/images/icons/chat/channelRecruitmentSm.png",
    canOutput = true,
    canFilter = true,
    isPublicChannel = true,
    metricName = "Recruitment"
  },
  {
    name = eChatMessageType_Faction,
    displayName = "@ui_chat_name_faction",
    displayNameUpper = "@ui_chat_name_faction_upper",
    shortcut = "f",
    canSelect = true,
    hasPermission = true,
    color = ChatData.colorFactionChannel,
    widgetIcon = "lyshineui/images/icons/chat/channelFaction.png",
    messageIcon = "lyshineui/images/icons/chat/channelFactionSm.png",
    canOutput = true,
    canFilter = true,
    metricName = "Faction"
  },
  {
    name = eChatMessageType_Group,
    displayName = "@ui_chat_name_group",
    displayNameUpper = "@ui_chat_name_group_upper",
    shortcut = "p",
    canSelect = true,
    hasPermission = false,
    color = ChatData.colorGroupChannel,
    widgetIcon = "lyshineui/images/icons/chat/channelGroup.png",
    messageIcon = "lyshineui/images/icons/chat/channelGroupSm.png",
    canOutput = true,
    canFilter = true,
    metricName = "Group"
  },
  {
    name = eChatMessageType_Raid,
    displayName = "@ui_chat_name_raid",
    displayNameUpper = "@ui_chat_name_raid_upper",
    shortcut = "ra",
    canSelect = true,
    hasPermission = false,
    color = ChatData.colorRaidChannel,
    widgetIcon = "lyshineui/images/icons/chat/channelRaid.png",
    messageIcon = "lyshineui/images/icons/chat/channelRaidSm.png",
    canOutput = true,
    canFilter = true,
    metricName = "Raid"
  },
  {
    name = eChatMessageType_Guild,
    displayName = "@ui_chat_name_guild",
    displayNameUpper = "@ui_chat_name_guild_upper",
    shortcut = "c",
    canSelect = true,
    hasPermission = true,
    color = ChatData.colorGuildChannel,
    widgetIcon = "lyshineui/images/icons/chat/channelCompany.png",
    messageIcon = "lyshineui/images/icons/chat/channelCompanySm.png",
    canOutput = true,
    canFilter = true,
    metricName = "Guild"
  },
  {
    name = eChatMessageType_Guild_Officer,
    displayName = "@ui_chat_name_officer",
    displayNameUpper = "@ui_chat_name_officer_upper",
    shortcut = "o",
    canSelect = true,
    hasPermission = false,
    color = ChatData.colorGuildOfficerChannel,
    widgetIcon = "lyshineui/images/icons/chat/channelConsul.png",
    messageIcon = "lyshineui/images/icons/chat/channelConsulSm.png",
    canOutput = true,
    canFilter = true,
    metricName = "Consul"
  },
  {
    name = eChatMessageType_Whisper,
    displayName = "@ui_chat_name_whisper",
    displayNameUpper = "@ui_chat_name_whisper_upper",
    shortcut = "w",
    canSelect = true,
    hasPermission = true,
    color = ChatData.colorWhisperChannel,
    backgroundColor = ChatData.colorWhisperBackground,
    widgetIcon = "lyshineui/images/icons/chat/channelDirect.png",
    messageIcon = "lyshineui/images/icons/chat/channelDirectSm.png",
    canOutput = true,
    canFilter = false,
    metricName = "Whisper"
  },
  {
    name = eChatMessageType_Emote,
    canSelect = false,
    color = ChatData.colorEmote,
    widgetIcon = "lyshineui/images/hud/chat/emote.png",
    messageIcon = "lyshineui/images/hud/chat/emote.png",
    canOutput = false,
    canFilter = false,
    metricName = "Emote"
  },
  {
    name = eChatMessageType_System,
    displayName = "@ui_error_systemname",
    displayNameUpper = "@ui_error_systemname_upper",
    canSelect = false,
    color = ChatData.colorSystem,
    widgetIcon = "lyshineui/images/icons/chat/channelSystem.png",
    messageIcon = "lyshineui/images/icons/chat/channelSystem.png",
    canOutput = false,
    canFilter = false
  }
}
function ChatData:GetWhisperTarget(chatMessageData)
  if chatMessageData.chatType == eChatMessageType_Whisper then
    if chatMessageData.isOwnMessage then
      return chatMessageData.chatRecipient
    else
      return chatMessageData.chatSender.playerName
    end
  end
end
function ChatData:GetChannelData(channelName)
  for i, channelData in ipairs(self.chatChannels) do
    if channelData.name == channelName then
      return channelData
    end
  end
  return {
    name = channelName,
    displayName = "@ui_error_systemname",
    canSelect = false,
    color = UIStyle.COLOR_RED,
    canOutput = false,
    canFilter = false
  }
end
function ChatData:GetChannelDataIndex(channelName)
  if channelName == self.feedChannelId then
    return 0
  end
  for i, channelData in ipairs(self.chatChannels) do
    if channelData.name == channelName then
      return i
    end
  end
end
return ChatData
