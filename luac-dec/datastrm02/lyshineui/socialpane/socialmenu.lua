local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local GameModeCommon = RequireScript("LyShineUI._Common.GameModeCommon")
local SocialMenu = {
  Properties = {
    ListHolder = {
      default = EntityId()
    },
    NoFriendSection = {
      default = EntityId()
    },
    DividerSection = {
      default = EntityId()
    },
    ClearFieldButton = {
      default = EntityId()
    },
    SearchbarBackground = {
      default = EntityId()
    },
    UpdateMessaging = {
      default = EntityId()
    },
    SearchIcon = {
      default = EntityId()
    },
    InviteNumberContainer = {
      default = EntityId()
    },
    InviteNumber = {
      default = EntityId()
    },
    InviteNumberAlarm = {
      default = EntityId()
    },
    HeaderText = {
      default = EntityId()
    },
    HeaderIcon = {
      default = EntityId()
    },
    NoFriendParent = {
      default = EntityId()
    },
    NoFriendHeader = {
      default = EntityId()
    },
    NoFriendBody = {
      default = EntityId()
    },
    ListCategoryContainer = {
      default = EntityId()
    },
    DropdownListScrollbox = {
      default = EntityId()
    },
    GroupPanelHolder = {
      default = EntityId()
    },
    SearchTextInput = {
      default = EntityId()
    },
    DisabledHolder = {
      default = EntityId()
    },
    EnterPlayerName = {
      default = EntityId()
    },
    OnlineText = {
      default = EntityId()
    }
  },
  matchData = {},
  screenStatesToHideGroupHealthBars = {
    [3766762380] = true,
    [1967160747] = true,
    [3576764016] = true,
    [1643432462] = true
  },
  playerListItemSlice = "LyShineUI\\SocialPane\\PlayerListItem",
  acceptGroupInviteWhileGroupedPopupEventId = "Popup_acceptInviteWhileGrouped",
  acceptGuildInviteWhileGovernorPopupEventId = "Popup_acceptGuildInviteWhileGovernor",
  onInvitePlayerEventId = "Popup_OnSocialMenuInvitePlayer",
  maxSearchResults = 5,
  groupId = nil,
  isEnabled = false,
  displayingMatches = false,
  socialEventTypes = {
    friendInviteAdded = {},
    friendInviteAccepted = {},
    friendInviteRejectedInvitee = {},
    friendInviteRejectedInviter = {},
    friendRemoved = {}
  },
  NOFRIENDS_SECTION_OFFSET = 100
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(SocialMenu)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local genericInviteCommon = RequireScript("LyShineUI._Common.GenericInviteCommon")
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
function SocialMenu:OnInit()
  BaseElement.OnInit(self)
  self.socialDataHandler = SocialDataHandler
  self.section = {
    GroupInvite = 1,
    FriendInvite = 2,
    GuildInvite = 3,
    EventInvite = 4,
    Online = 5,
    Offline = 6,
    Blocked = 7,
    Muted = 8
  }
  self.sections = {
    {
      headerTitle = "@ui_group_invites",
      category = "GroupInvite",
      collapsed = false,
      data = {}
    },
    {
      headerTitle = "@ui_friend_invites",
      category = "FriendInvite",
      collapsed = false,
      data = {}
    },
    {
      headerTitle = "@ui_guild_invites",
      category = "GuildInvite",
      collapsed = false,
      data = {}
    },
    {
      headerTitle = "@ui_event_invites",
      category = "EventInvite",
      collapsed = false,
      data = {}
    },
    {
      headerTitle = "@ui_online",
      category = "Friend",
      collapsed = false,
      data = {}
    },
    {
      headerTitle = "@ui_offline",
      category = "Friend",
      collapsed = false,
      data = {}
    },
    {
      headerTitle = "@ui_blocked",
      category = "Blocked",
      collapsed = false,
      data = {}
    },
    {
      headerTitle = "@ui_muted",
      category = "Muted",
      collapsed = false,
      data = {}
    }
  }
  self.activeSections = {}
  self.timeHelpers = timeHelpers
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self:BusConnect(UiTextInputAutoCompleteBus, self.SearchTextInput.entityId)
  self:BusConnect(UiDynamicScrollBoxDataBus, self.Properties.ListHolder)
  self:BusConnect(UiDynamicScrollBoxElementNotificationBus, self.Properties.ListHolder)
  self:BusConnect(UiDynamicScrollBoxDataBus, self.Properties.DropdownListScrollbox)
  self:BusConnect(UiDynamicScrollBoxElementNotificationBus, self.Properties.DropdownListScrollbox)
  self.SearchTextInput:SetStartEditCallback(self.OnStartEdit, self)
  self.SearchTextInput:SetEndEditCallback(self.OnEndEdit, self)
  self.dataLayer:RegisterAndExecuteCallback(self, "Hud.LocalPlayer.Social.DataSynced", self.OnSocialDataSync)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Social.LastUpdatedPlayer.CharacterId", self.LastPlayerUpdated)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Friend.LastAddedInvite.CharacterId", self.OnFriendInviteAdded)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Friend.LastRemovedInvite.CharacterId", self.OnFriendInviteRemoved)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Chat.LastBlockAdded", self.OnBlockAdded)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Chat.LastBlockRemoved", self.OnBlockRemoved)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Chat.LastMuteAdded", self.OnMuteAdded)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Chat.LastMuteRemoved", self.OnMuteRemoved)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Group.Invites.RemoveCharacterId", self.OnGroupInviteRemoved)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Group.Id", self.OnGroupIdChanged)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Group.InviteCount", self.UpdateGroupInvites)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.InviteCount", self.UpdateGuildInvites)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Guild.LastAddedInvite.Id", self.OnGuildInviteAdded)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Guild.LastRemovedInvite.Id", self.OnGuildInviteRemoved)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Guild.LastUpdatedInvite.Id", self.OnGuildInviteUpdated)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.GenericInvite.Id", self.OnGenericInviteUpdated)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.SocialEntityId", self.SetSocialEntityId)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, socialEntityId)
    if socialEntityId then
      self:BusConnect(GuildNotificationsBus, socialEntityId)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Localization.Language", function(self, setLang)
    if not setLang then
      return
    end
    self:UpdateNumOnlineText()
  end)
  self.socialMenuHandler = DynamicBus.SocialMenuBus.Connect(self.entityId, self)
end
function SocialMenu:OnShutdown()
  if self.socialMenuHandler then
    DynamicBus.SocialMenuBus.Disconnect(self.entityId, self)
    self.socialMenuHandler = nil
  end
end
function SocialMenu:GetNumElements()
  return #self.matchData
end
function SocialMenu:GetNumSections()
  return #self.activeSections
end
function SocialMenu:GetNumElementsInSection(sectionIndex)
  if #self.activeSections == 0 then
    return 0
  end
  local sectionData = self.sections[self.activeSections[sectionIndex + 1]]
  if sectionData.collapsed then
    return 0
  else
    return #sectionData.data
  end
end
function SocialMenu:OnElementBecomingVisible(entityId, index)
  UiElementBus.Event.SetIsEnabled(entityId, true)
  local entityTable = self.registrar:GetEntityTable(entityId)
  local data = self.matchData[index + 1]
  if not data then
    UiElementBus.Event.SetIsEnabled(entityId, false)
    return
  end
  entityTable:SetListKey(data.playerName)
  entityTable:SetCategory("Matching")
  entityTable:SetData(data, self)
end
function SocialMenu:OnElementInSectionBecomingVisible(entityId, sectionIndex, itemIndexInSection)
  UiElementBus.Event.SetIsEnabled(entityId, true)
  local entityTable = self.registrar:GetEntityTable(entityId)
  local data = self.sections[sectionIndex + 1].data[itemIndexInSection + 1]
  if not data then
    return
  end
  entityTable:SetListKey(data.characterId)
  entityTable:SetCategory(self.sections[sectionIndex + 1].category)
  entityTable:SetData(data, self)
  local listHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.ListCategoryContainer)
  UiTransformBus.Event.SetLocalPositionY(self.NoFriendParent, listHeight + self.NOFRIENDS_SECTION_OFFSET)
end
function SocialMenu:OnSectionHeaderBecomingVisible(entityId, sectionIndex)
  if #self.activeSections == 0 then
    UiElementBus.Event.SetIsEnabled(entityId, false)
    return
  end
  UiElementBus.Event.SetIsEnabled(entityId, true)
  local numberOfPlayers = #self.sections[self.activeSections[sectionIndex + 1]].data
  local entityTable = self.registrar:GetEntityTable(entityId)
  UiTextBus.Event.SetTextWithFlags(entityTable.Title, self.sections[self.activeSections[sectionIndex + 1]].headerTitle, eUiTextSet_SetLocalized)
  UiElementBus.Event.SetIsEnabled(entityTable.Button, 0 < numberOfPlayers)
  UiCheckboxBus.Event.SetState(entityTable.Button, not self.sections[self.activeSections[sectionIndex + 1]].collapsed)
  if self.activeSections[sectionIndex + 1] > self.section.EventInvite then
    entityTable:SetHeaderStyle(entityTable.styles.list)
  else
    entityTable:SetHeaderStyle(entityTable.styles.invite)
  end
  entityTable:SetCountText(tostring(numberOfPlayers))
end
function SocialMenu:AddElementToSection(section, index, count)
  local sectionIndex = self:GetActiveSectionIndex(section)
  if sectionIndex == -1 then
    if section >= self.section.EventInvite then
      self:RefreshActiveSections()
      return
    end
  else
    UiDynamicScrollBoxBus.Event.InsertElementsIntoSection(self.ListHolder, sectionIndex - 1, index, count)
    self:UpdateHeaderCount(nil, section)
  end
end
function SocialMenu:SetEnabled(isEnabled, reason)
  if self.isEnabled == isEnabled then
    return
  end
  self.isEnabled = isEnabled
  DynamicBus.SocialMenuBus.Broadcast.OnSocialMenuVisibilityChanged(isEnabled)
  self.ScriptedEntityTweener:Stop(self.GroupPanelHolder)
  UiElementBus.Event.SetIsEnabled(self.DropdownListScrollbox, false)
  local slideOutPanelTime = 0.21
  local slideInPanelTime = 0.15
  if isEnabled then
    self:ClearSearchField()
    DynamicBus.SocialPaneBus.Broadcast.ShowAllMemberHealthBars(false)
    UiElementBus.Event.SetIsEnabled(self.ListCategoryContainer, true)
    UiElementBus.Event.SetIsEnabled(self.GroupPanelHolder, true)
    self.ScriptedEntityTweener:Play(self.GroupPanelHolder, slideOutPanelTime, {x = -430, opacity = 0}, {
      x = 0,
      opacity = 1,
      ease = "QuadOut"
    })
    local previousReason = self.openReason
    self.openReason = reason
    self:UpdateListEntitiesWithReason()
    if previousReason ~= reason or #self.activeSections == 0 then
      local header = "@ui_social."
      local headerIconPath = "lyshineui/images/socialpane/social_iconSocial.png"
      if reason == "GroupInvite" then
        header = "@ui_invite_to_group."
        headerIconPath = "lyshineui/images/socialpane/social_iconAddGroup.png"
      elseif reason == "GuildInvite" then
        header = "@ui_invite_to_guild."
        headerIconPath = "lyshineui/images/socialpane/social_iconAddGuild.png"
      end
      UiTextBus.Event.SetTextWithFlags(self.HeaderText, header, eUiTextSet_SetLocalized)
      UiImageBus.Event.SetSpritePathname(self.HeaderIcon, headerIconPath)
      self:RefreshActiveSections()
    end
    if not self.cursorNotificationBus then
      self.cursorNotificationBus = self:BusConnect(CursorNotificationBus)
    end
  else
    self.ScriptedEntityTweener:Play(self.GroupPanelHolder, slideInPanelTime, {
      x = -430,
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        local currentState = LyShineManagerBus.Broadcast.GetCurrentState()
        if not self.screenStatesToHideGroupHealthBars[currentState] then
          DynamicBus.SocialPaneBus.Broadcast.ShowAllMemberHealthBars(not self.isEnabled)
        end
        UiElementBus.Event.SetIsEnabled(self.GroupPanelHolder, false)
      end
    })
    if self.cursorNotificationBus then
      self:BusDisconnect(self.cursorNotificationBus)
      self.cursorNotificationBus = nil
    end
  end
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  if not isEnabled then
    self.previousInviteCount = #self.sections[self.section.FriendInvite].data + #self.sections[self.section.GroupInvite].data + #self.sections[self.section.GuildInvite].data + #self.sections[self.section.EventInvite].data
  end
end
function SocialMenu:RefreshActiveSections()
  local noFriendHeader = "@ui_noFriend_header"
  local noFriendBody = "@ui_noFriend_body"
  if self.openReason == "GroupInvite" or self.openReason == "EventInvite" then
    if #self.sections[self.section.Online].data == 0 then
      noFriendHeader = "@ui_noOnline_group_header"
      noFriendBody = "@ui_noOnline_group_body"
      ClearTable(self.activeSections)
      UiElementBus.Event.SetIsEnabled(self.NoFriendParent, true)
    else
      self.activeSections = {
        self.section.Online
      }
      UiElementBus.Event.SetIsEnabled(self.NoFriendParent, false)
    end
  elseif self.openReason == "GuildInvite" then
    if #self.sections[self.section.Online].data == 0 and #self.sections[self.section.Offline].data == 0 then
      noFriendHeader = "@ui_noOnline_guild_header"
      noFriendBody = "@ui_noOnline_guild_body"
      ClearTable(self.activeSections)
      UiElementBus.Event.SetIsEnabled(self.NoFriendParent, true)
    else
      self.activeSections = {
        self.section.Online,
        self.section.Offline
      }
      UiElementBus.Event.SetIsEnabled(self.NoFriendParent, false)
    end
  elseif #self.sections[self.section.Online].data == 0 and #self.sections[self.section.Offline].data == 0 and #self.sections[self.section.Muted].data == 0 and #self.sections[self.section.Blocked].data == 0 then
    UiElementBus.Event.SetIsEnabled(self.NoFriendParent, true)
    self.activeSections = {
      self.section.GroupInvite,
      self.section.FriendInvite,
      self.section.GuildInvite,
      self.section.EventInvite
    }
  else
    UiElementBus.Event.SetIsEnabled(self.NoFriendParent, false)
    self.activeSections = {
      self.section.GroupInvite,
      self.section.FriendInvite,
      self.section.GuildInvite,
      self.section.EventInvite,
      self.section.Online,
      self.section.Offline,
      self.section.Blocked,
      self.section.Muted
    }
  end
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.ListHolder)
  UiTextBus.Event.SetTextWithFlags(self.NoFriendHeader, noFriendHeader, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.NoFriendBody, noFriendBody, eUiTextSet_SetLocalized)
  local listHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.ListCategoryContainer)
  UiTransformBus.Event.SetLocalPositionY(self.NoFriendParent, listHeight + self.NOFRIENDS_SECTION_OFFSET)
end
function SocialMenu:SetSocialEntityId(socialEntityId)
  if socialEntityId and not self.socialEntityId then
    self.socialEntityId = socialEntityId
    self:BusConnect(SocialNotificationsBus, socialEntityId)
    self:BusConnect(SocialBlockEventsBus, socialEntityId)
  end
end
function SocialMenu:DisplaySearchFieldMessage(style, message)
  UiTextBus.Event.SetTextWithFlags(self.UpdateMessaging, message, eUiTextSet_SetLocalized)
  SetTextStyle(self.UpdateMessaging, style)
  self.ScriptedEntityTweener:Stop(self.UpdateMessaging)
  self.ScriptedEntityTweener:Play(self.UpdateMessaging, 0.18, {x = -30, opacity = 0}, {
    x = 0,
    opacity = 1,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.UpdateMessaging, 0.23, {
    opacity = 0,
    ease = "QuadOut",
    delay = 2.2
  })
end
function SocialMenu:ClearSearchField()
  self.SearchTextInput:SetText("")
  self.ScriptedEntityTweener:Set(self.ClearFieldButton, {opacity = 0})
  UiElementBus.Event.SetIsEnabled(self.ClearFieldButton, false)
  UiElementBus.Event.SetIsEnabled(self.EnterPlayerName, true)
  UiElementBus.Event.SetIsEnabled(self.DropdownListScrollbox, false)
  self:ClearMatchingList()
end
function SocialMenu:OnSocialDataSync(isSynced)
  if not isSynced then
    return
  end
  if not self.isFirstSocialSync then
    self.isFirstSocialSync = true
    self.numInitializeCallbacksInFlight = 0
    self:InitializeBlockList()
    self:InitializeMuteList()
    self:InitializeFriendInvitesList()
    self:InitializeFriendsList()
    if self.numInitializeCallbacksInFlight == 0 then
      self:InitializeSections()
    end
    self:UpdateInvitesListCount()
  end
end
function SocialMenu:InitializeSections()
  self:RefreshActiveSections()
  UiDynamicScrollBoxBus.Event.RefreshContent(self.ListHolder)
  self:UpdateNumOnlineText()
end
function SocialMenu:OnStartEdit()
  self.ScriptedEntityTweener:Set(self.ClearFieldButton, {opacity = 1})
  UiElementBus.Event.SetIsEnabled(self.ClearFieldButton, true)
  UiElementBus.Event.SetIsEnabled(self.EnterPlayerName, false)
  self.ScriptedEntityTweener:Play(self.SearchbarBackground, 0.3, {opacity = 1, ease = "QuadOut"})
  SetActionmapsForTextInput(self.canvasId, true)
end
function SocialMenu:OnEndEdit()
  self.ScriptedEntityTweener:Play(self.SearchbarBackground, 0.3, {opacity = 0.5, ease = "QuadOut"})
  SetActionmapsForTextInput(self.canvasId, false)
end
function SocialMenu:ClearMatchingList()
  self.displayingMatches = false
  ClearTable(self.matchData)
  UiElementBus.Event.SetIsEnabled(self.ListCategoryContainer, true)
  UiElementBus.Event.SetIsEnabled(self.NoFriendSection, true)
end
function SocialMenu:ClearContainer(containerEntity)
  local childElements = UiElementBus.Event.GetChildren(containerEntity)
  for i = 1, #childElements do
    UiElementBus.Event.DestroyElement(childElements[i])
  end
end
function SocialMenu:OnUpdateMatchingList(matchingList)
  local displayingMatches = 0 < #matchingList
  if self.displayingMatches ~= displayingMatches then
    self.displayingMatches = displayingMatches
    UiElementBus.Event.SetIsEnabled(self.ListCategoryContainer, false)
    UiElementBus.Event.SetIsEnabled(self.NoFriendSection, false)
    UiElementBus.Event.SetIsEnabled(self.DropdownListScrollbox, true)
  end
  ClearTable(self.matchData)
  for i = 1, #matchingList do
    local foundMatch = false
    for _, data in ipairs(self.matchData) do
      if data.playerName == matchingList[i] then
        foundMatch = true
        break
      end
    end
    if not foundMatch then
      local data = {
        playerName = matchingList[i],
        category = "Matching"
      }
      table.insert(self.matchData, data)
    end
  end
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.DropdownListScrollbox)
end
function SocialMenu:UpdateInvitesListCount()
  local totalInvitesCount = #self.sections[self.section.FriendInvite].data + #self.sections[self.section.GroupInvite].data + #self.sections[self.section.GuildInvite].data + #self.sections[self.section.EventInvite].data
  if self.previousInviteCount == nil then
    self.previousInviteCount = 0
  end
  if totalInvitesCount < self.previousInviteCount then
    self.previousInviteCount = totalInvitesCount
  end
  totalInvitesCount = totalInvitesCount - self.previousInviteCount
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.SocialMenu.UpdateTotalInviteCount", totalInvitesCount)
  if 0 < totalInvitesCount then
    UiElementBus.Event.SetIsEnabled(self.InviteNumberContainer, true)
    UiTextBus.Event.SetText(self.InviteNumber, totalInvitesCount)
    UiTextBus.Event.SetText(self.InviteNumberAlarm, totalInvitesCount)
  else
    UiElementBus.Event.SetIsEnabled(self.InviteNumberContainer, false)
  end
end
function SocialMenu:UpdateGroupInvites(newInviteCount)
  if newInviteCount == nil then
    return
  end
  local invitesNode = self.dataLayer:GetDataNode("Hud.LocalPlayer.Group.Invites")
  for i = 1, newInviteCount do
    local inviteData = invitesNode[tostring(i)]:GetData()
    local found = false
    for _, groupInviteData in pairs(self.sections[self.section.GroupInvite].data) do
      if groupInviteData.characterId == inviteData.senderCharacterIdString then
        found = true
        break
      end
    end
    if not found then
      for _, eventInviteData in pairs(self.sections[self.section.EventInvite].data) do
        if eventInviteData.characterId == inviteData.senderCharacterIdString then
          found = true
          break
        end
      end
    end
    if not found then
      local category = inviteData.senderCharacterIdString == "" and "EventInvite" or "GroupInvite"
      local data = {
        inviteId = inviteData.inviteId,
        characterId = inviteData.senderCharacterIdString,
        category = category,
        warId = inviteData.warId,
        gameModeId = inviteData.gameModeId,
        buttonData = {
          acceptCallback = "OnGroupInviteAccept",
          rejectCallback = "OnGroupInviteReject"
        }
      }
      if inviteData.senderCharacterIdString == "" then
        data.isWarInvite = data.warId ~= nil and not data.warId:IsNull()
        data.isGameModeInvite = data.gameModeId ~= nil
      else
        data.isPvPInvite = inviteData:IsPvPGroup()
      end
      table.insert(self.sections[self.section[category]].data, data)
      self:AddElementToSection(self.section[category], #self.sections[self.section[category]].data - 1, 1)
    end
  end
  self:UpdateInvitesListCount()
end
function SocialMenu:OnGroupInviteRemoved(characterId)
  self:RemoveItemByCharacterId(characterId, self.section.GroupInvite)
  self:RemoveItemByCharacterId(characterId, self.section.EventInvite)
  self:UpdateInvitesListCount()
end
function SocialMenu:OnGroupIdChanged(groupId)
  self.groupId = groupId
end
function SocialMenu:GetInviteId(characterId)
  local inviteId
  for _, data in pairs(self.sections[self.section.GroupInvite].data) do
    if data.characterId == characterId then
      inviteId = data.inviteId
    end
  end
  if not inviteId then
    for _, data in pairs(self.sections[self.section.EventInvite].data) do
      if data.characterId == characterId then
        inviteId = data.inviteId
      end
    end
  end
  return inviteId
end
function SocialMenu:OnGroupInviteAccept(playerId)
  local inviteId = self:GetInviteId(playerId:GetCharacterIdString())
  local myRaidId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Raid.Id")
  local playerRootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  local isInOutpostRushQueue = GameModeParticipantComponentRequestBus.Event.IsInQueueForGameMode(playerRootEntityId, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
  if GameRequestsBus.Broadcast.IsInDungeonGameMode() then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@ui_cannotjoingroup_in_dungeon"
    notificationData.contextId = self.entityId
    notificationData.allowDuplicates = false
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  elseif PlayerArenaRequestBus.Event.IsInArena(playerRootEntityId) then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@ui_cannotjoingroup_in_arena"
    notificationData.contextId = self.entityId
    notificationData.allowDuplicates = false
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  elseif myRaidId and myRaidId:IsValid() then
    self.pendingGroupInviteId = inviteId
    local isInOutpostRush = GameModeParticipantComponentRequestBus.Event.IsInGameMode(playerRootEntityId, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
    if isInOutpostRush then
      local modeEntityId = GameModeParticipantComponentRequestBus.Event.GetGameModeEntityId(playerRootEntityId, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
      local penaltyInSeconds = GameModeComponentRequestBus.Event.GetGameModeRejoinPenaltyTimeSec(modeEntityId)
      local message = "@ui_outpost_rush_leave_desc"
      if 0 < penaltyInSeconds then
        local timeRemainingString = timeHelpers:ConvertToTwoLargestTimeEstimate(penaltyInSeconds, false)
        message = GetLocalizedReplacementText("@ui_outpost_rush_leave_group_desc_time", {time = timeRemainingString})
      end
      PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_outpost_rush_leave_title", message, self.acceptGroupInviteWhileGroupedPopupEventId, self, self.OnPopupResult)
    else
      PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_siege_abandon_and_accept_group_title", "@ui_siege_abandon_and_accept_group_message", self.acceptGroupInviteWhileGroupedPopupEventId, self, self.OnPopupResult)
    end
  elseif self.groupId and self.groupId:IsValid() then
    self.pendingGroupInviteId = inviteId
    PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_acceptinvitepopuptitle", "@ui_acceptinvitepopupmessage", self.acceptGroupInviteWhileGroupedPopupEventId, self, self.OnPopupResult)
  elseif isInOutpostRushQueue then
    self.pendingGroupInviteId = inviteId
    PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_acceptinvitepopuptitle", "@ui_queuewarning_accept", self.acceptGroupInviteWhileGroupedPopupEventId, self, self.OnPopupResult)
  else
    GroupsRequestBus.Broadcast.RequestReplyToGroupInvite(inviteId, true)
  end
end
function SocialMenu:OnGroupInviteReject(playerId)
  local inviteId = self:GetInviteId(playerId:GetCharacterIdString())
  GroupsRequestBus.Broadcast.RequestReplyToGroupInvite(inviteId, false)
  self:RemoveItemByCharacterId(playerId:GetCharacterIdString(), self.section.GroupInvite)
  self:RemoveItemByCharacterId(playerId:GetCharacterIdString(), self.section.EventInvite)
  self:UpdateInvitesListCount()
end
function SocialMenu:OnGroupInvite(playerId)
  local playerRootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  local isInOutpostRushQueue = GameModeParticipantComponentRequestBus.Event.IsInQueueForGameMode(playerRootEntityId, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
  if isInOutpostRushQueue then
    self.playerToInvite = playerId:GetCharacterIdString()
    PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_invitetogroup", "@ui_queuewarning_invite", self.onInvitePlayerEventId, self, self.OnPopupResult)
  else
    GroupsRequestBus.Broadcast.RequestGroupInvite(playerId:GetCharacterIdString())
  end
end
function SocialMenu:InitializeFriendsList()
  local friendsList = JavSocialComponentBus.Broadcast.GetFriends()
  for i = 1, #friendsList do
    self.numInitializeCallbacksInFlight = self.numInitializeCallbacksInFlight + 1
    local characterId = friendsList[i]
    self.socialDataHandler:GetPlayerIdentification_ServerCall(self, self.OnInitializeFriendsList_OnPlayerIdReady, self.OnPlayerIdFailed, characterId)
  end
end
function SocialMenu:InitializeFriendInvitesList()
  local invitesList = JavSocialComponentBus.Broadcast.GetFriendInvites()
  for i = 1, #invitesList do
    self.numInitializeCallbacksInFlight = self.numInitializeCallbacksInFlight + 1
    local characterId = invitesList[i]
    self.socialDataHandler:GetPlayerIdentification_ServerCall(self, self.OnInitializeFriendInvitesList_OnPlayerIdReady, self.OnPlayerIdFailed, characterId)
  end
end
function SocialMenu:OnFriendInviteNotificationChoice(notificationId, isAccepted)
  for _, data in ipairs(self.sections[self.section.FriendInvite].data) do
    if data.notificationId == notificationId then
      if isAccepted then
        self:OnFriendInviteAccept(data.playerId)
        break
      end
      self:OnFriendInviteReject(data.playerId)
      break
    end
  end
end
function SocialMenu:OnFriendInviteAdded(characterId)
  for _, inviteData in pairs(self.sections[self.section.FriendInvite].data) do
    if inviteData.playerId and inviteData.playerId:GetCharacterIdString() == characterId then
      return
    end
  end
  self.socialDataHandler:GetPlayerIdentification_ServerCall(self, self.OnFriendInviteAdded_OnPlayerIdReady, self.OnPlayerIdFailed, characterId)
end
function SocialMenu:OnFriendInviteRemoved(characterId)
  self:RemoveItemByCharacterId(characterId, self.section.FriendInvite)
  self:UpdateInvitesListCount()
end
function SocialMenu:UpdateFriendOnlineStatus(characterId, isOnline)
  local firstSectionToSearch = self.section.Offline
  local secondSectionToSearch = self.section.Online
  if not isOnline then
    firstSectionToSearch = self.section.Online
    secondSectionToSearch = self.section.Offline
  end
  local foundSection = firstSectionToSearch
  local index = self:FindCharacterIdIndexInSection(characterId, firstSectionToSearch)
  if index == -1 then
    index = self:FindCharacterIdIndexInSection(characterId, secondSectionToSearch)
    foundSection = secondSectionToSearch
  end
  if index == -1 then
  end
  if foundSection == self.section.Online and isOnline or foundSection == self.section.Offline and not isOnline then
    return
  end
  local data = table.remove(self.sections[foundSection].data, index)
  table.insert(self.sections[secondSectionToSearch].data, data)
  self:AlphabeticalSort(secondSectionToSearch)
  UiDynamicScrollBoxBus.Event.RefreshContent(self.ListHolder)
  self:UpdateNumOnlineText()
end
function SocialMenu:UpdateNumOnlineText()
  local numberOfPlayers = #self.sections[self.section.Online].data
  local numOnlineText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_online_num", numberOfPlayers)
  UiTextBus.Event.SetText(self.Properties.OnlineText, numOnlineText)
end
function SocialMenu:OnFriendInviteAccept(playerId)
  local characterId = playerId:GetCharacterIdString()
  JavSocialComponentBus.Broadcast.RequestFriendStatusChange(eFriendRequestType_Accept, characterId)
  self:RemoveItemByCharacterId(characterId, self.section.FriendInvite)
  self:UpdateInvitesListCount()
end
function SocialMenu:OnFriendInviteReject(playerId)
  local characterId = playerId:GetCharacterIdString()
  JavSocialComponentBus.Broadcast.RequestFriendStatusChange(eFriendRequestType_Reject, characterId)
  self:RemoveItemByCharacterId(characterId, self.section.FriendInvite)
  self:UpdateInvitesListCount()
  self:SendNotification(playerId.playerName, self.socialEventTypes.friendInviteRejectedInvitee)
end
function SocialMenu:OnAddFriend(characterId)
  if self:FindCharacterIdIndexInSection(characterId, self.section.Online) ~= -1 or self:FindCharacterIdIndexInSection(characterId, self.section.Offline) ~= -1 then
    return
  end
  self.socialDataHandler:GetPlayerIdentification_ServerCall(self, self.OnFriendAdded_OnPlayerIdReady, self.OnPlayerIdFailed, characterId)
end
function SocialMenu:OnRemoveFriend(characterId)
  self:RemoveItemByCharacterId(characterId, self.section.Online)
  self:RemoveItemByCharacterId(characterId, self.section.Offline)
  self:UpdateNumOnlineText()
end
function SocialMenu:OnFriendInviteRejected(characterId)
  self.socialDataHandler:GetPlayerIdentification_ServerCall(self, self.OnFriendInviteRejected_OnPlayerIdReady, self.OnPlayerIdFailed, characterId)
end
function SocialMenu:OnPlayerIdFailed(reason)
  if reason == eSocialRequestFailureReasonThrottled then
    Log("ERR - SocialMenu:OnPlayerIdFailed: Throttled.")
  elseif reason == eSocialRequestFailureReasonTimeout then
    Log("ERR - SocialMenu:OnPlayerIdFailed: Timed Out.")
  end
end
function SocialMenu:OnPlayerIdReady(result)
  local playerId
  if 0 < #result then
    playerId = result[1].playerId
  else
    Log("ERR - SocialMenu:OnPlayerIdReady: Player not found.")
    return
  end
  return playerId
end
function SocialMenu:OnInitializeFriendInvitesList_OnPlayerIdReady(result)
  local playerId = self:OnPlayerIdReady(result)
  if playerId then
    local data = {
      playerId = playerId,
      category = "FriendInvite",
      buttonData = {
        acceptCallback = "OnFriendInviteAccept",
        rejectCallback = "OnFriendInviteReject"
      }
    }
    table.insert(self.sections[self.section.FriendInvite].data, data)
    self:UpdateInvitesListCount()
    self.numInitializeCallbacksInFlight = self.numInitializeCallbacksInFlight - 1
    if self.numInitializeCallbacksInFlight < 1 then
      self:InitializeSections()
    end
  end
end
function SocialMenu:OnFriendInviteAdded_OnPlayerIdReady(result)
  local playerId = self:OnPlayerIdReady(result)
  if playerId then
    local data = {
      playerId = playerId,
      category = "FriendInvite",
      buttonData = {
        acceptCallback = "OnFriendInviteAccept",
        rejectCallback = "OnFriendInviteReject"
      }
    }
    table.insert(self.sections[self.section.FriendInvite].data, data)
    local sectionIndex = #self.sections[self.section.FriendInvite].data
    self:AddElementToSection(self.section.FriendInvite, sectionIndex - 1, 1)
    self:UpdateInvitesListCount()
    local notificationId = self:SendNotification(playerId.playerName, self.socialEventTypes.friendInviteAdded)
    if notificationId then
      self.sections[self.section.FriendInvite].data[sectionIndex].notificationId = notificationId
    end
  end
end
function SocialMenu:OnInitializeFriendsList_OnPlayerIdReady(result)
  local playerId = self:OnPlayerIdReady(result)
  if playerId then
    local data = {playerId = playerId, category = "Friend"}
    local indexToInsert = 1
    local sectionData = self.sections[self.section.Offline].data
    for i = #sectionData, 1, -1 do
      if playerId.playerName < sectionData[i].playerId.playerName then
        indexToInsert = i
        break
      end
    end
    table.insert(self.sections[self.section.Offline].data, indexToInsert, data)
    self.numInitializeCallbacksInFlight = self.numInitializeCallbacksInFlight - 1
    if 1 > self.numInitializeCallbacksInFlight then
      self:InitializeSections()
    end
  end
end
function SocialMenu:OnFriendAdded_OnPlayerIdReady(result)
  local playerId = self:OnPlayerIdReady(result)
  if playerId then
    self:RemoveItemByCharacterId(playerId:GetCharacterIdString(), self.section.FriendInvite)
    local data = {playerId = playerId, category = "Friend"}
    local indexToInsert = 1
    local sectionData = self.sections[self.section.Online].data
    for i = #sectionData, 1, -1 do
      if playerId.playerName < sectionData[i].playerId.playerName then
        indexToInsert = i
        break
      end
    end
    table.insert(self.sections[self.section.Online].data, indexToInsert, data)
    self:AddElementToSection(self.section.Online, indexToInsert - 1, 1)
    self:UpdateHeaderCount(nil, self.section.Online)
    self:UpdateInvitesListCount()
    self:UpdateNumOnlineText()
    self:SendNotification(playerId.playerName, self.socialEventTypes.friendInviteAccepted)
  end
end
function SocialMenu:OnFriendInviteRejected_OnPlayerIdReady(result)
  local playerId = self:OnPlayerIdReady(result)
  if playerId then
    self:SendNotification(playerId.playerName, self.socialEventTypes.friendInviteRejectedInviter)
  end
end
function SocialMenu:SendNotification(playerName, socialEventType)
  if not playerName or not socialEventType then
    return
  end
  local isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
  if isFtue then
    return
  end
  local notificationData = NotificationData()
  notificationData.contextId = self.entityId
  if socialEventType == self.socialEventTypes.friendInviteAdded then
    local isStreamerModeUIHideEnabled = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Options.Social.StreamerModeUI")
    if isStreamerModeUIHideEnabled then
      return
    end
    notificationData.type = "FriendInviteCenter"
    notificationData.priority = eNotificationPriority_High
    notificationData.hasChoice = true
    notificationData.contextId = self.entityId
    notificationData.title = "@ui_friendrequesttitle"
    notificationData.callbackName = "OnFriendInviteNotificationChoice"
    notificationData.text = GetLocalizedReplacementText("@ui_friendrequestrecipientmessage", {playerName = playerName})
  elseif socialEventType == self.socialEventTypes.friendInviteAccepted then
    notificationData.type = "FriendInvite"
    notificationData.title = "@ui_friendshipacceptedtitle"
    notificationData.text = GetLocalizedReplacementText("@ui_friendshipacceptedmessage", {playerName = playerName})
  elseif socialEventType == self.socialEventTypes.friendInviteRejectedInvitee then
    notificationData.type = "FriendInvite"
    notificationData.title = "@ui_friendshiprejectedtitle"
    notificationData.text = GetLocalizedReplacementText("@ui_friendshiprejectedsendermessage", {playerName = playerName})
  elseif socialEventType == self.socialEventTypes.friendInviteRejectedInviter then
    notificationData.type = "FriendInvite"
    notificationData.title = "@ui_friendshiprejectedtitle"
    notificationData.text = GetLocalizedReplacementText("@ui_friendshiprejectedrecipientmessage", {playerName = playerName})
  elseif socialEventType == self.socialEventTypes.friendRemoved then
    notificationData.type = "Friend"
    notificationData.title = "@ui_friendremovedtitle"
    notificationData.text = GetLocalizedReplacementText("@ui_friendremovedmessage", {playerName = playerName})
  else
    return
  end
  return UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function SocialMenu:UpdateGuildInvites(newInviteCount)
  if newInviteCount == nil then
    return
  end
  local invitesNode = self.dataLayer:GetDataNode("Hud.LocalPlayer.Guild.Invites")
  for i = 1, newInviteCount do
    local inviteNode = invitesNode[tostring(i)]
    local characterIdString = inviteNode.CharacterIdString:GetData()
    local guildCrest = inviteNode.Crest:GetData()
    local guildName = inviteNode.Name:GetData()
    local guildId = inviteNode.Id:GetData()
    local found = false
    for _, guildInviteData in pairs(self.sections[self.section.GuildInvite].data) do
      if guildInviteData.guildId == guildId then
        found = true
        break
      end
    end
    if not found then
      local data = {
        characterId = characterIdString,
        guildId = guildId,
        guildName = guildName,
        guildCrest = guildCrest,
        category = "GuildInvite",
        buttonData = {
          acceptCallback = "OnGuildInviteAccept",
          rejectCallback = "OnGuildInviteReject"
        }
      }
      table.insert(self.sections[self.section.GuildInvite].data, data)
      self:AddElementToSection(self.section.GuildInvite, #self.sections[self.section.GuildInvite].data - 1, 1)
    end
  end
  self:UpdateInvitesListCount()
end
function SocialMenu:OnGuildInviteAdded(guildId)
  for _, guildInviteData in pairs(self.sections[self.section.GuildInvite].data) do
    if guildInviteData.guildId == guildId then
      return
    end
  end
  local guildName = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.LastAddedInvite.Name")
  local guildCrest = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.LastAddedInvite.Crest")
  local characterIdString = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.LastAddedInvite.CharacterIdString")
  local inviteData = {
    characterId = characterIdString,
    guildId = guildId,
    guildName = guildName,
    guildCrest = guildCrest,
    category = "GuildInvite",
    buttonData = {
      acceptCallback = "OnGuildInviteAccept",
      rejectCallback = "OnGuildInviteReject"
    }
  }
  table.insert(self.sections[self.section.GuildInvite].data, inviteData)
  self:AddElementToSection(self.section.GuildInvite, #self.sections[self.section.GuildInvite].data - 1, 1)
  self:UpdateInvitesListCount()
  self.socialDataHandler:GetPlayerIdentification_ServerCall(self, self.OnGuildInviteAdded_OnPlayerIdReady, self.OnPlayerIdFailed, characterIdString)
end
function SocialMenu:OnGuildInviteRemoved(guildId)
  self:RemoveItemByGuildId(guildId, self.section.GuildInvite)
  self:UpdateInvitesListCount()
end
function SocialMenu:OnGuildInviteUpdated(guildId)
  local guildName = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.LastUpdatedInvite.Name")
  local guildCrest = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.LastUpdatedInvite.Crest")
  local sectionIndex = self:GetActiveSectionIndex(self.section.GuildInvite) - 1
  for index, data in ipairs(self.sections[self.section.GuildInvite].data) do
    if data.guildId == guildId then
      local elementIndex = index - 1
      data.guildName = guildName
      data.guildCrest = guildCrest
      if UiDynamicScrollBoxBus.Event.IsElementIndexInSectionVisible(self.Properties.ListHolder, sectionIndex, elementIndex) then
        local sectionEntityId = UiDynamicScrollBoxBus.Event.GetEntityIdAtElementIndexInSection(self.Properties.ListHolder, sectionIndex, elementIndex)
        self:OnElementInSectionBecomingVisible(sectionEntityId, sectionIndex, elementIndex)
      end
      return
    end
  end
  local characterIdString = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.LastUpdatedInvite.CharacterIdString")
  local data = {
    characterId = characterIdString,
    guildId = newGuildId,
    guildName = guildName,
    guildCrest = guildCrest,
    category = "GuildInvite",
    container = self.GuildInvite.Container,
    notificationId = nil,
    buttonData = {
      acceptCallback = "OnGuildInviteAccept",
      rejectCallback = "OnGuildInviteReject"
    }
  }
  table.insert(self.sections[self.section.GuildInvite].data, data)
  self:AddElementToSection(self.section.GuildInvite, #self.sections[self.section.GuildInvite].data - 1, 1)
  self:UpdateInvitesListCount()
end
function SocialMenu:OnGuildInviteNotificationChoice(notificationId, isAccepted)
  for _, data in ipairs(self.sections[self.section.GuildInvite].data) do
    if data.notificationId == notificationId then
      if isAccepted then
        self:OnGuildInviteAccept(data.guildId)
        break
      end
      self:OnGuildInviteReject(data.guildId)
      break
    end
  end
end
function SocialMenu:OnGuildInviteAccept(guildId)
  self.audioHelper:PlaySound(self.audioHelper.Invites_Accept)
  local isGuildMaster = GuildsComponentBus.Broadcast.IsGuildMaster()
  local guildMemberCount = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.MemberCount")
  local numberOfClaims = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.NumClaims")
  local popupMessage
  if isGuildMaster and guildMemberCount == 1 and 0 < numberOfClaims then
    popupMessage = "@ui_acceptguildinvitepopupmessage_hasclaims"
  elseif not isGuildMaster and 1 < guildMemberCount then
    local rejoinTime = GuildsComponentBus.Broadcast.GetGuildRejoiningCooldownSeconds()
    local switchTime = GuildsComponentBus.Broadcast.GetGuildSwitchingCooldownSeconds()
    popupMessage = GetLocalizedReplacementText("@ui_acceptguildinvitepopupmessage_noclaims", {
      rejoinTime = self.timeHelpers:ConvertToLargestTimeEstimate(rejoinTime, false),
      switchTime = self.timeHelpers:ConvertToLargestTimeEstimate(switchTime, false)
    })
  else
    self:AcceptGuildInvite(guildId)
    return
  end
  self.pendingInviteGuildId = guildId
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_acceptguildinvitepopuptitle", popupMessage, self.acceptGuildInviteWhileGovernorPopupEventId, self, self.OnPopupResult)
end
function SocialMenu:AcceptGuildInvite(guildId)
  GuildsComponentBus.Broadcast.RequestAcceptGuildInvite(guildId)
  self.audioHelper:PlaySound(self.audioHelper.Invites_Accept)
end
function SocialMenu:OnGuildInviteReject(guildId)
  GuildsComponentBus.Broadcast.RequestRejectGuildInvite(guildId)
  self.audioHelper:PlaySound(self.audioHelper.Invites_Reject)
end
function SocialMenu:OnGuildInvite(playerId)
  GuildsComponentBus.Broadcast.RequestGuildInvite(playerId:GetCharacterIdString())
  local notificationData = NotificationData()
  notificationData.contextId = self.entityId
  notificationData.type = "Minor"
  notificationData.text = GetLocalizedReplacementText("@ui_guildinvitesendermessage", {
    playerName = playerId.playerName
  })
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function SocialMenu:OnGuildInviteRejected(senderCharacterIdString, guildName)
  local localCharacterId = self.dataLayer:GetDataNode("Hud.LocalPlayer.CharacterId"):GetData()
  if localCharacterId == senderCharacterIdString then
    local notificationData = NotificationData()
    notificationData.contextId = self.entityId
    notificationData.type = "Minor"
    notificationData.text = GetLocalizedReplacementText("@ui_guildinviterejectedsendermessage", {guildName = guildName})
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  else
    self.socialDataHandler:GetPlayerIdentification_ServerCall(self, self.OnGuildInviteRejectedRecipient_OnPlayerIdReady, self.OnPlayerIdFailed, senderCharacterIdString)
  end
end
function SocialMenu:OnGuildInviteAdded_OnPlayerIdReady(result)
  local playerId = self:OnPlayerIdReady(result)
  if playerId then
    for index, data in ipairs(self.sections[self.section.GuildInvite].data) do
      if data.characterId == playerId:GetCharacterIdString() then
        local isStreamerModeUIHideEnabled = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Options.Social.StreamerModeUI")
        if isStreamerModeUIHideEnabled then
          data.notificationId = Uuid:Create()
          return
        end
        local notificationData = NotificationData()
        notificationData.type = "GuildInvite"
        notificationData.priority = eNotificationPriority_High
        notificationData.hasChoice = true
        notificationData.contextId = self.entityId
        notificationData.callbackName = "OnGuildInviteNotificationChoice"
        notificationData.text = GetLocalizedReplacementText("@ui_guildinviterecipientmessage", {
          playerName = playerId.playerName,
          guildName = data.guildName
        })
        notificationData.title = "@ui_guildinvitetitle"
        notificationData.guildCrest = data.guildCrest
        data.notificationId = UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
        self.audioHelper:PlaySound(self.audioHelper.OnInvitedToGuild)
        return
      end
    end
  end
end
function SocialMenu:OnGuildInviteRejectedRecipient_OnPlayerIdReady(result)
  local playerId = self:OnPlayerIdReady(result)
  if playerId then
    local notificationData = NotificationData()
    notificationData.contextId = self.entityId
    notificationData.type = "Minor"
    notificationData.text = GetLocalizedReplacementText("@ui_guildinviterejectedrecipientmessage", {
      playerName = playerId.playerName
    })
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
end
function SocialMenu:OnGenericInviteUpdated(inviteId)
  if not inviteId then
    return
  end
  if inviteId:IsNull() then
    if self.genericInviteData and self.genericInviteData.notificationId then
      UiNotificationsBus.Broadcast.RescindNotification(self.genericInviteData.notificationId, true, true)
      self.genericInviteData = nil
    end
  else
    local characterIdString = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.GenericInvite.AcceptedCharacter.1")
    local activityType = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.GenericInvite.ActivityType")
    local activityCrc = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.GenericInvite.ActivityCrc")
    local forwardType = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.GenericInvite.ForwardType")
    local expiryTimePoint = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.GenericInvite.ExpiryTimePoint")
    self.genericInviteData = {
      forwardType = forwardType,
      activityType = activityType,
      activityCrc = activityCrc,
      expiryTimePoint = expiryTimePoint
    }
    self.socialDataHandler:GetPlayerIdentification_ServerCall(self, self.OnGenericInviteUpdated_OnPlayerIdReady, self.OnPlayerIdFailed, characterIdString)
  end
end
function SocialMenu:OnGenericInviteUpdated_OnPlayerIdReady(result)
  local playerId = self:OnPlayerIdReady(result)
  if playerId then
    local isGroupMate = LocalGroupRequestBus.Broadcast.IsGroupMate(playerId:GetCharacterIdString())
    local title, text, icon = genericInviteCommon:GetGenericInviteNotificationData(self.genericInviteData.activityCrc, self.genericInviteData.forwardType, playerId.playerName, isGroupMate)
    local duration = self.genericInviteData.expiryTimePoint:Subtract(TimePoint:Now()):ToSecondsUnrounded()
    local notificationData = NotificationData()
    notificationData.type = "GenericInvite"
    notificationData.priority = eNotificationPriority_Low
    notificationData.maximumDuration = duration
    notificationData.showProgress = true
    notificationData.hasChoice = true
    notificationData.contextId = self.entityId
    notificationData.callbackName = "OnGenericInviteNotificationChoice"
    notificationData.title = title
    notificationData.text = text
    if icon then
      notificationData.icon = icon
    end
    self.genericInviteData.notificationId = UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    self.audioHelper:PlaySound(self.audioHelper.Invites_Added)
  end
end
function SocialMenu:OnGenericInviteNotificationChoice(notificationId, isAccepted)
  if self.genericInviteData and self.genericInviteData.notificationId == notificationId then
    genericInviteCommon:RequestReplyToInvite(isAccepted)
    self.audioHelper:PlaySound(isAccepted and self.audioHelper.Invites_Accept or self.audioHelper.Invites_Reject)
    self.genericInviteData = nil
  end
end
function SocialMenu:OnBlockAdded(characterId)
  self:MuteCharacter(characterId)
  self:DisplayMinorNotification("@ui_blocked_player")
end
function SocialMenu:OnBlockRemoved(characterId)
  self:UnmuteCharacter(characterId)
  self:DisplayMinorNotification("@ui_unblocked_player")
end
function SocialMenu:OnMuteAdded(characterId)
  self:MuteCharacter(characterId)
  self:DisplayMinorNotification("@ui_muted_player")
end
function SocialMenu:OnMuteRemoved(characterId)
  self:UnmuteCharacter(characterId)
  self:DisplayMinorNotification("@ui_unmuted_player")
end
function SocialMenu:MuteCharacter(characterId)
  if self:FindCharacterIdIndexInSection(characterId, self.section.Muted) ~= -1 then
    return
  end
  local data = {characterId = characterId, category = "Muted"}
  table.insert(self.sections[self.section.Muted].data, data)
  self:AddElementToSection(self.section.Muted, #self.sections[self.section.Muted].data - 1, 1)
end
function SocialMenu:UnmuteCharacter(characterId)
  self:RemoveItemByCharacterId(characterId, self.section.Muted)
end
function SocialMenu:DisplayMinorNotification(notificationText)
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = notificationText
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function SocialMenu:InitializeMuteList()
  local muteList = ChatComponentBus.Broadcast.GetSocialMutes()
  for i = 1, #muteList do
    local characterId = muteList[i]
    local data = {characterId = characterId, category = "Muted"}
    table.insert(self.sections[self.section.Muted].data, data)
  end
end
function SocialMenu:InitializeBlockList()
  local blockList = JavSocialComponentBus.Broadcast.GetSocialBlocks()
  for i = 1, #blockList do
    local blockData = blockList[i]
    local data = {characterId = blockData, category = "Blocked"}
    table.insert(self.sections[self.section.Blocked].data, data)
  end
end
function SocialMenu:BlockAdded(characterId)
  if self:FindCharacterIdIndexInSection(characterId, self.section.Blocked) ~= -1 then
    return
  end
  local data = {characterId = characterId, category = "Blocked"}
  table.insert(self.sections[self.section.Blocked].data, data)
  self:AddElementToSection(self.section.Blocked, #self.sections[self.section.Blocked].data - 1, 1)
end
function SocialMenu:BlockRemoved(characterId)
  self:RemoveItemByCharacterId(characterId, self.section.Blocked)
end
function SocialMenu:AlphabeticalSort(section)
  table.sort(self.sections[section].data, function(a, b)
    return a.playerId.playerName < b.playerId.playerName
  end)
end
function SocialMenu:FindPlayerIdIndexInSection(playerId, section)
  for i, data in ipairs(self.sections[section].data) do
    if data.playerId == playerId then
      return i
    end
  end
  return -1
end
function SocialMenu:FindCharacterIdIndexInSection(characterId, section)
  for i, data in ipairs(self.sections[section].data) do
    if data.playerId and data.playerId:GetCharacterIdString() == characterId or data.characterId == characterId then
      return i
    end
  end
  return -1
end
function SocialMenu:LastPlayerUpdated(characterId)
  local isOnline = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Social.LastUpdatedPlayer.IsOnline")
  local sections = {
    self.section.Online,
    self.section.Offline,
    self.section.FriendInvite
  }
  for i = 1, #sections do
    for j, data in ipairs(self.sections[sections[i]].data) do
      if data.playerId:GetCharacterIdString() == characterId and UiDynamicScrollBoxBus.Event.IsElementIndexInSectionVisible(self.ListHolder, sections[i] - 1, j - 1) then
        local entityId = UiDynamicScrollBoxBus.Event.GetEntityIdAtElementIndexInSection(self.ListHolder, sections[i] - 1, j - 1)
        local entity = self.registrar:GetEntityTable(entityId)
        entity:SetIsOnline(isOnline)
        local notificationData = NotificationData()
        notificationData.contextId = self.entityId
        notificationData.type = "Minor"
        local logTag = isOnline and "@ui_friendjoinedmessage" or "@ui_friendleftmessage"
        notificationData.text = GetLocalizedReplacementText(logTag, {
          playerName = data.playerId.playerName
        })
        UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
        return
      end
    end
  end
end
function SocialMenu:GetActiveSectionIndex(section)
  for i = 1, #self.activeSections do
    if section == self.activeSections[i] then
      return i
    end
  end
  return -1
end
function SocialMenu:UpdateHeaderCount(entity, section)
  if not entity then
    local entityId = UiDynamicScrollBoxBus.Event.GetSectionHeaderEntityId(self.ListHolder, self:GetActiveSectionIndex(section) - 1)
    entity = self.registrar:GetEntityTable(entityId)
    if not entity then
      return
    end
  end
  local numberOfPlayers = #self.sections[section].data
  entity:SetCountText(tostring(numberOfPlayers))
  UiElementBus.Event.SetIsEnabled(entity.Button, 0 < numberOfPlayers)
  UiCheckboxBus.Event.SetState(entity.Button, not self.sections[section].collapsed)
  if section <= self.section.EventInvite then
    if 0 < numberOfPlayers then
      UiImageBus.Event.SetColor(entity.CountBg, self.UIStyle.COLOR_RED_DARK)
      UiTextBus.Event.SetColor(entity.Count, self.UIStyle.COLOR_WHITE)
      UiTextBus.Event.SetColor(entity.AltCountText, self.UIStyle.COLOR_WHITE)
      UiImageBus.Event.SetSpritePathname(entity.entityId, "LyShineUI/Images/socialpane/social_inviteBgSelected.png")
    else
      UiImageBus.Event.SetColor(entity.CountBg, self.UIStyle.COLOR_TAN_DARK_NONUM)
      UiTextBus.Event.SetColor(entity.Count, self.UIStyle.COLOR_BLACK)
      UiTextBus.Event.SetColor(entity.AltCountText, self.UIStyle.COLOR_BLACK)
      UiImageBus.Event.SetSpritePathname(entity.entityId, "LyShineUI/Images/socialpane/social_inviteBg.png")
    end
  end
end
function SocialMenu:UpdateHeader(section)
  local header = UiDynamicScrollBoxBus.Event.GetSectionHeaderEntityId(self.ListHolder, section - 1)
  local headerTable = self.registrar:GetEntityTable(header)
  UiTextBus.Event.SetTextWithFlags(headerTable.Title, self.sections[section].headerTitle, eUiTextSet_SetLocalized)
  self:UpdateHeaderCount(headerTable, section)
end
function SocialMenu:OnPopupResult(result, eventId)
  if result == ePopupResult_No then
    if eventId == self.acceptGroupInviteWhileGroupedPopupEventId then
      GroupsRequestBus.Broadcast.RequestReplyToGroupInvite(self.pendingGroupInviteId, false)
      self.audioHelper:PlaySound(self.audioHelper.OnGuildNotificationDeline)
      self.pendingGroupInviteId = nil
    end
  elseif eventId == self.acceptGroupInviteWhileGroupedPopupEventId then
    GroupsRequestBus.Broadcast.RequestReplyToGroupInvite(self.pendingGroupInviteId, true)
    self.audioHelper:PlaySound(self.audioHelper.OnGuildNotificationAccept)
    self.pendingGroupInviteId = nil
  elseif eventId == self.acceptGuildInviteWhileGovernorPopupEventId then
    self:AcceptGuildInvite(self.pendingInviteGuildId)
    self.pendingInviteGuildId = nil
  elseif eventId == self.onInvitePlayerEventId then
    GroupsRequestBus.Broadcast.RequestGroupInvite(self.playerToInvite)
    self.playerToInvite = nil
  end
end
function SocialMenu:RemoveItemByGuildId(guildId, section)
  for i, data in ipairs(self.sections[section].data) do
    if data.guildId == guildId then
      UiNotificationsBus.Broadcast.RescindNotification(data.notificationId, true, true)
      table.remove(self.sections[section].data, i)
      local index = self:GetActiveSectionIndex(section)
      UiDynamicScrollBoxBus.Event.RemoveElementAtIndexFromSection(self.ListHolder, index - 1, i - 1)
      self:UpdateHeaderCount(nil, section)
      break
    end
  end
end
function SocialMenu:RemoveItemByCharacterId(characterId, section)
  local characterListItemRemoved = false
  for i, data in ipairs(self.sections[section].data) do
    local sectionItemCharacterId
    if data.playerId then
      sectionItemCharacterId = data.playerId:GetCharacterIdString()
    elseif data.characterId then
      sectionItemCharacterId = data.characterId
    else
      Debug.Log("ERR - SocialMenu:RemoveItemByCharacterId: no character id found for list item.")
    end
    if sectionItemCharacterId == characterId then
      if data.playerId and data.category == "Friend" then
        self:SendNotification(data.playerId.playerName, self.socialEventTypes.friendRemoved)
      end
      table.remove(self.sections[section].data, i)
      local index = self:GetActiveSectionIndex(section)
      UiDynamicScrollBoxBus.Event.RemoveElementAtIndexFromSection(self.ListHolder, index - 1, i - 1)
      self:UpdateHeaderCount(nil, section)
      characterListItemRemoved = true
    end
  end
  if #self.sections[section].data == 0 then
    self:RefreshActiveSections()
  end
  return characterListItemRemoved
end
function SocialMenu:OnHoverDropdownStart(entityId, actionName)
  self.ScriptedEntityTweener:Play(entityId, 0.11, {opacity = 1, ease = "QuadOut"})
  local fill = UiElementBus.Event.FindChildByName(entityId, "Fill")
  local parentElement = UiElementBus.Event.GetParent(entityId)
  local headerTextElement = UiElementBus.Event.FindChildByName(parentElement, "HeaderTitle")
  if headerTextElement then
    self.ScriptedEntityTweener:Play(headerTextElement, 0.1, {
      textColor = self.UIStyle.COLOR_TAN_LIGHT,
      ease = "QuadOut"
    })
  end
  if fill then
    self.ScriptedEntityTweener:Play(fill, 0.11, {opacity = 0.5, ease = "QuadOut"})
  end
end
function SocialMenu:OnHoverDropdownEnd(entityId, actionName)
  self.ScriptedEntityTweener:Play(entityId, 0.11, {opacity = 0.5, ease = "QuadOut"})
  local fill = UiElementBus.Event.FindChildByName(entityId, "Fill")
  if fill then
    self.ScriptedEntityTweener:Play(fill, 0.11, {opacity = 0, ease = "QuadOut"})
  end
  local parentElement = UiElementBus.Event.GetParent(entityId)
  local headerTextElement = UiElementBus.Event.FindChildByName(parentElement, "HeaderTitle")
  if headerTextElement then
    self.ScriptedEntityTweener:Play(headerTextElement, 0.1, {
      textColor = self.UIStyle.COLOR_TAN,
      ease = "QuadOut"
    })
  end
end
function SocialMenu:ToggleListButton(headerEntityId, shouldExpand)
  local fill = UiElementBus.Event.FindChildByName(headerEntityId, "Fill")
  UiElementBus.Event.SetIsEnabled(fill, not shouldExpand)
  local sectionIndex = UiDynamicScrollBoxBus.Event.GetSectionIndexOfChild(self.ListHolder, headerEntityId)
  local sectionInfo = self.sections[self.activeSections[sectionIndex + 1]]
  if sectionInfo.collapsed == not shouldExpand then
    return
  end
  sectionInfo.collapsed = not shouldExpand
  if shouldExpand then
    UiDynamicScrollBoxBus.Event.InsertElementsIntoSection(self.ListHolder, sectionIndex, 0, #sectionInfo.data)
  else
    UiDynamicScrollBoxBus.Event.RemoveElementsFromSection(self.ListHolder, sectionIndex, #sectionInfo.data)
  end
  local listHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.ListCategoryContainer)
  UiTransformBus.Event.SetLocalPositionY(self.NoFriendParent, listHeight + self.NOFRIENDS_SECTION_OFFSET)
end
function SocialMenu:ExpandList(entityId, actionName)
  self:ToggleListButton(entityId, true)
end
function SocialMenu:CollapseList(entityId, actionName)
  self:ToggleListButton(entityId, false)
end
function SocialMenu:UpdateListEntitiesWithReason()
  local index = self:GetActiveSectionIndex(self.section.Online)
  if index == -1 then
    return
  end
  for i = 1, #self.sections[self.section.Online].data do
    local entityId = UiDynamicScrollBoxBus.Event.GetEntityIdAtElementIndexInSection(self.ListHolder, index - 1, i - 1)
    local entity = self.registrar:GetEntityTable(entityId)
    self:UpdateListItemButtons(entity, true)
  end
end
function SocialMenu:UpdateListItemButtons(entity, isOnline)
  local showButtons = false
  local buttonData = {}
  if self.openReason == "GroupInvite" then
    buttonData.customCallback = "OnGroupInvite"
    buttonData.customLocText = "@ui_invite_to_group"
    buttonData.openReason = self.openReason
    local isGroupMate = LocalGroupRequestBus.Broadcast.IsGroupMate(entity.playerId:GetCharacterIdString())
    local isGroupFull = LocalGroupRequestBus.Broadcast.IsGroupFull()
    local myRaidId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Raid.Id")
    local isInRaid = myRaidId and myRaidId:IsValid()
    showButtons = isOnline and not isGroupMate and not isGroupFull and not isInRaid
  elseif self.openReason == "GuildInvite" then
    buttonData.customCallback = "OnGuildInvite"
    buttonData.customLocText = "@ui_invite_to_guild"
    buttonData.openReason = self.openReason
    if not entity.playerId then
      showButtons = true
    else
      showButtons = not GuildsComponentBus.Broadcast.IsGuildMate(entity.playerId:GetCharacterIdString())
    end
  end
  if showButtons then
    entity:SetButtons(buttonData)
  else
    entity:SetButtons()
  end
end
function SocialMenu:UpdatePlayerNameKey(oldName, newName, category)
  local sections = {}
  if category == "Matching" then
    return
  elseif category == "Friend" then
    if #self.sections[self.section.Online].data > 0 then
      table.insert(sections, self.sections[self.section.Online].data)
    end
    if 0 < #self.sections[self.section.Offline].data then
      table.insert(sections, self.sections[self.section.Offline].data)
    end
  else
    table.insert(sections, self.sections[self.section[category]].data)
  end
  for _, sectionData in pairs(sections) do
    for i, data in pairs(sectionData) do
      if data.playerId.playerName == oldName then
        local indexToInsert = 1
        for j = #sectionData, 1, -1 do
          if newName < sectionData[j].playerId.playerName then
            indexToInsert = j
            break
          end
        end
        data.playerId.playerName = newName
        table.remove(sectionData, i)
        table.insert(sectionData, indexToInsert, data)
        for index = indexToInsert, #sectionData do
          self:OnElementInSectionBecomingVisible(UiDynamicBus.Event.GetEntityIdAtElementIndexInSection(self.ListHolder, self:GetActiveSectionIndex(self.section[category]), index - 1), self.section[category] - 1, index - 1)
        end
      end
    end
  end
end
function SocialMenu:OnHoverSearchBar()
  self.ScriptedEntityTweener:Play(self.SearchbarBackground, 0.15, {opacity = 0.75, ease = "QuadOut"})
end
function SocialMenu:OnUnhoverSearchBar()
  self.ScriptedEntityTweener:Play(self.SearchbarBackground, 0.15, {opacity = 0.5, ease = "QuadOut"})
end
function SocialMenu:OnCursorPressed()
  self.pressCaptured = true
end
function SocialMenu:OnCursorReleased()
  if self.pressCaptured and not IsCursorOverUiEntity(self.entityId, 75) then
    self:SetEnabled(false)
  end
  self.pressCaptured = false
end
function SocialMenu:RejectAllInvites()
  local invitesList = JavSocialComponentBus.Broadcast.GetFriendInvites()
  for i = 1, #invitesList do
    local characterId = invitesList[i]
    JavSocialComponentBus.Broadcast.RequestFriendStatusChange(eFriendRequestType_Reject, characterId)
    self:RemoveItemByCharacterId(characterId, self.section.FriendInvite)
  end
  local count = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Group.InviteCount")
  local invitesNode = self.dataLayer:GetDataNode("Hud.LocalPlayer.Group.Invites")
  for i = 1, count or 0 do
    local inviteData = invitesNode[tostring(i)]:GetData()
    if inviteData then
      local inviteId = inviteData.inviteId
      GroupsRequestBus.Broadcast.RequestReplyToGroupInvite(inviteId, false)
      self:RemoveItemByCharacterId(characterId, self.section.GroupInvite)
      self:RemoveItemByCharacterId(characterId, self.section.EventInvite)
    end
  end
  count = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.InviteCount")
  local guildInvitesNode = self.dataLayer:GetDataNode("Hud.LocalPlayer.Guild.Invites")
  for i = 1, count or 0 do
    local inviteNode = guildInvitesNode[tostring(i)]
    if inviteNode then
      local guildId = inviteNode.Id:GetData()
      if guildId then
        GuildsComponentBus.Broadcast.RequestRejectGuildInvite(guildId)
      end
    end
  end
  self:UpdateInvitesListCount()
end
return SocialMenu
