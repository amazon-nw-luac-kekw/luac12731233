local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local RosterTab = {
  Properties = {
    Tab = {
      default = EntityId()
    },
    MemberScrollBox = {
      default = EntityId()
    },
    MemberListContent = {
      default = EntityId()
    },
    SortName = {
      default = EntityId()
    },
    SortRank = {
      default = EntityId()
    },
    SortOnline = {
      default = EntityId()
    },
    TotalMemberText = {
      default = EntityId()
    },
    OnlineMemberText = {
      default = EntityId()
    },
    NoGovernorText = {
      default = EntityId()
    },
    BecomeGovernorButton = {
      default = EntityId()
    },
    Spinner = {
      default = EntityId()
    }
  },
  maxGuildMembers = 50,
  sortOption = "OnlineAsc",
  members = {},
  rankNames = {},
  onlineMemberNames = {}
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(RosterTab)
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
function RosterTab:OnInit()
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self:BusConnect(UiCanvasNotificationBus, self.canvasId)
  self:BusConnect(UiDynamicScrollBoxDataBus, self.Properties.MemberScrollBox)
  self:BusConnect(UiDynamicScrollBoxElementNotificationBus, self.Properties.MemberScrollBox)
  self.socialDataHandler = SocialDataHandler
  self.socialDataHandler:OnActivate()
  self.maxGuildMembers = ConfigProviderEventBus.Broadcast.GetInt("javelin.social.max-guild-size")
  self:UpdateMemberSortButtons()
  self.SortName:SetCallback("OnSortName", self)
  self.SortName:SetText("@ui_name")
  self.SortRank:SetCallback("OnSortRank", self)
  self.SortRank:SetText("@ui_rank")
  self.SortOnline:SetCallback("OnSortOnline", self)
  self.SortOnline:SetText("@ui_online")
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Guild.LastAddedMember.CharacterIdString", self.OnMemberAdded)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Guild.LastRemovedMember.CharacterIdString", self.OnMemberRemoved)
  local registerDataObserver = self.dataLayer.RegisterDataObserver
  local registerDataCallback = self.dataLayer.RegisterDataCallback
  self.visibleOnlyDataLayerPaths = {}
  self.visibleOnlyDataLayerPaths["Hud.LocalPlayer.PlayerName"] = {
    callback = self.UpdateLocalPlayerName,
    regFunction = registerDataObserver
  }
  self.visibleOnlyDataLayerPaths["Hud.LocalPlayer.Guild.Rank"] = {
    callback = self.OnLocalPlayerRankChanged,
    regFunction = registerDataObserver
  }
  self.visibleOnlyDataLayerPaths["Hud.LocalPlayer.Guild.GuildWarCount"] = {
    callback = self.RefreshMemberList,
    regFunction = registerDataObserver
  }
  self.visibleOnlyDataLayerPaths["Hud.LocalPlayer.Guild.LastUpdatedMember.CharacterIdString"] = {
    callback = self.OnMemberUpdated,
    regFunction = registerDataCallback
  }
  self.visibleOnlyDataLayerPaths["Hud.LocalPlayer.Social.LastUpdatedPlayer.PlayerId"] = {
    callback = self.OnPlayerDataUpdated,
    regFunction = registerDataCallback
  }
  if self.Properties.BecomeGovernorButton:IsValid() then
    self.BecomeGovernorButton:SetText("@ui_becomegovernor")
    self.BecomeGovernorButton:SetCallback(self.SubmitBecomeGovernor, self)
    self.BecomeGovernorButton:SetTextStyle(self.UIStyle.FONT_STYLE_BUTTON_SIMPLE_CTA)
    self.BecomeGovernorButton:SetBackgroundColor(self.UIStyle.COLOR_BUTTON_SIMPLE_CTA)
    self.BecomeGovernorButton:SetBackgroundOpacity(self.UIStyle.BUTTON_SIMPLE_CTA_OPACITY)
    self.BecomeGovernorButton:SetSoundOnPress(self.audioHelper.Crest_Submit)
    self.BecomeGovernorButton:SetButtonBgTexture(self.BecomeGovernorButton.BG_TEXTURE_STYLE_COLOR_BACKGROUND)
    self.BecomeGovernorButton:SetTextAlignment(self.BecomeGovernorButton.TEXT_ALIGN_LEFT)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.NoGovernorText, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.BecomeGovernorButton, false)
end
function RosterTab:OnShutdown()
  self.socialDataHandler:OnDeactivate()
end
function RosterTab:RegisterObservers()
  for path, data in pairs(self.visibleOnlyDataLayerPaths) do
    data.regFunction(self.dataLayer, self, path, data.callback)
  end
end
function RosterTab:UnregisterObservers()
  for path, _ in pairs(self.visibleOnlyDataLayerPaths) do
    self.dataLayer:UnregisterObserver(self, path)
  end
end
function RosterTab:SetGuildMenuEntityId(guildMenuEntityId)
  self.guildMenuEntityId = guildMenuEntityId
end
function RosterTab:SetVisible(isVisible)
  if self.isVisible == isVisible then
    return
  end
  self.isVisible = isVisible
  if isVisible then
    self.localPlayerName = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.PlayerName")
    self:RegisterObservers()
    self:UpdatePermissions()
    self:UpdateMembers()
  else
    TimingUtils:StopDelay(self)
    self.delayTimer = nil
    self:SetSpinnerShowing(false)
    self:UnregisterObservers()
    local childElements = UiElementBus.Event.GetChildren(self.Properties.MemberListContent)
    for i = 1, #childElements do
      local memberListItem = self.registrar:GetEntityTable(childElements[i])
      memberListItem:HideRankChangeDropdown()
    end
  end
end
function RosterTab:SetSpinnerShowing(isShowing)
  if self.spinnerIsShowing == isShowing then
    return
  end
  self.spinnerIsShowing = isShowing
  UiElementBus.Event.SetIsEnabled(self.Properties.Spinner, isShowing)
  if isShowing then
    self.ScriptedEntityTweener:Play(self.Properties.Spinner, 2.5, {rotation = 0}, {timesToPlay = -1, rotation = 359})
  else
    self.ScriptedEntityTweener:Stop(self.Properties.Spinner)
  end
end
function RosterTab:UpdatePermissions()
  self.isGuildLeader = GuildsComponentBus.Broadcast.IsGuildMaster()
  self.hasPromotePrivilege = GuildsComponentBus.Broadcast.HasPrivilege(eGuildPrivilegeId_Member_Promote)
  self.hasDemotePrivilege = GuildsComponentBus.Broadcast.HasPrivilege(eGuildPrivilegeId_Member_Demote)
  self.hasKickPrivilege = GuildsComponentBus.Broadcast.HasPrivilege(eGuildPrivilegeId_Member_Remove)
end
function RosterTab:UpdateMembers()
  self.members = {}
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.MemberScrollBox)
  local memberCharacterIds = GuildsComponentBus.Broadcast.GetGuildMemberCharacterIds()
  self:SetSpinnerShowing(true)
  self.socialDataHandler:GetPlayers_ServerCall(self, self.UpdateMembers_OnGetMemberData, self.UpdateMembers_OnGetMemberDataFailed, memberCharacterIds)
end
function RosterTab:UpdateMembers_OnGetMemberData(memberResults)
  if self.delayTimer then
    TimingUtils:StopDelay(self)
  end
  if memberResults then
    for i = 1, #memberResults do
      local memberResult = memberResults[i]
      if memberResult then
        local characterIdString = memberResult:GetCharacterIdString()
        local isActive = JavSocialComponentBus.Broadcast.IsCachedPlayerActive(characterIdString)
        table.insert(self.members, {playerId = memberResult, isActive = isActive})
      end
    end
  end
  self:SetSpinnerShowing(false)
  self:RefreshMemberList()
end
function RosterTab:UpdateMembers_OnGetMemberDataFailed(reason, memberResults)
  self:UpdateMembers_OnGetMemberData(memberResults)
end
function RosterTab:OnPlayerIdReady(result)
  local playerId
  if 0 < #result then
    playerId = result[1].playerId
  else
    Log("ERR - RosterTab:OnPlayerIdReady: Player not found.")
    return
  end
  return playerId
end
function RosterTab:OnMemberAdded_OnPlayerIdReady(result)
  local playerId = self:OnPlayerIdReady(result)
  if playerId then
    local characterIdString = playerId:GetCharacterIdString()
    local isActive = JavSocialComponentBus.Broadcast.IsCachedPlayerActive(characterIdString)
    table.insert(self.members, {playerId = playerId, isActive = isActive})
    local notificationData = NotificationData()
    notificationData.contextId = self.entityId
    notificationData.type = "Minor"
    notificationData.text = GetLocalizedReplacementText("@ui_guildmemberjoinedmessage", {
      playerName = "<font color=" .. ColorRgbaToHexString(self.UIStyle.COLOR_TAN) .. ">" .. playerId.playerName .. "</font>"
    })
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    self:WriteGuildMessageToLocalChat("@ui_guildmemberjoinedmessage", playerId.playerName)
  end
  self:SetSpinnerShowing(false)
  self:RefreshMemberList()
end
function RosterTab:OnMemberAdded_OnPlayerIdFailed(reason)
  if reason == eSocialRequestFailureReasonThrottled then
    Log("ERR - RosterTab:OnMemberAdded_OnPlayerIdFailed: Throttled.")
  elseif reason == eSocialRequestFailureReasonTimeout then
    Log("ERR - RosterTab:OnMemberAdded_OnPlayerIdFailed: Timeout.")
  end
  self:SetSpinnerShowing(false)
end
function RosterTab:WriteGuildMessageToLocalChat(locTag, playerName)
  local chatMessage = BaseGameChatMessage()
  chatMessage.type = eChatMessageType_Guild_Announce
  chatMessage.body = GetLocalizedReplacementText(locTag, {playerName = playerName})
  ChatComponentBus.Broadcast.WriteMessageToLocalChat(chatMessage)
end
function RosterTab:RefreshMemberList()
  self.numMembersOnline = 0
  for _, memberEntry in pairs(self.members) do
    local memberData = GuildsComponentBus.Broadcast.GetGuildMemberData(memberEntry.playerId:GetCharacterIdString())
    if memberData.isOnline then
      self.numMembersOnline = self.numMembersOnline + 1
    end
  end
  self:RefreshMembersOnlineText()
  self:RefreshGuildMasterExpiredText()
  local function compare(first, second)
    if self.sortOption == "NameDesc" then
      return first.playerId.playerName:lower() > second.playerId.playerName:lower()
    elseif self.sortOption == "NameAsc" then
      return first.playerId.playerName:lower() < second.playerId.playerName:lower()
    end
    local firstMemberData = GuildsComponentBus.Broadcast.GetGuildMemberData(first.playerId:GetCharacterIdString())
    local secondMemberData = GuildsComponentBus.Broadcast.GetGuildMemberData(second.playerId:GetCharacterIdString())
    if self.sortOption == "RankAsc" and firstMemberData.rank ~= secondMemberData.rank then
      return firstMemberData.rank < secondMemberData.rank
    elseif self.sortOption == "RankDesc" and firstMemberData.rank ~= secondMemberData.rank then
      return firstMemberData.rank > secondMemberData.rank
    elseif self.sortOption == "OnlineAsc" then
      if firstMemberData.isOnline ~= secondMemberData.isOnline then
        return firstMemberData.isOnline
      elseif not firstMemberData.isOnline then
        return firstMemberData.lastOnlineTime < secondMemberData.lastOnlineTime
      end
    elseif self.sortOption == "OnlineDesc" and firstMemberData.isOnline ~= secondMemberData.isOnline then
      return secondMemberData.isOnline
    end
    return first.playerId.playerName < second.playerId.playerName
  end
  table.sort(self.members, compare)
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.MemberScrollBox)
end
function RosterTab:RefreshMembersOnlineText()
  local onlineString = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_guildmembersonline", tostring(self.numMembersOnline))
  UiTextBus.Event.SetText(self.Properties.OnlineMemberText, onlineString)
  local totalString = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_guildmemberstotal", tostring(#self.members) .. " / " .. tostring(self.maxGuildMembers))
  UiTextBus.Event.SetText(self.Properties.TotalMemberText, totalString)
  if not self.memberTextSet then
    self.memberTextSet = true
    self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Options.Localization.Language", function(self, setLang)
      self:RefreshMembersOnlineText()
    end)
  end
end
function RosterTab:RefreshGuildMasterExpiredText()
  local guildMasterActiveResult = GuildsComponentBus.Broadcast.IsGuildMasterActive()
  local isGuildSecondinCommand = GuildsComponentBus.Broadcast.IsGuildRank(1)
  local showBecomeGovernorButton = isGuildSecondinCommand and guildMasterActiveResult ~= eGuildMasterActiveResult_StillActive
  if guildMasterActiveResult == eGuildMasterActiveResult_Expired_CharacterDeleted then
    UiTextBus.Event.SetTextWithFlags(self.Properties.NoGovernorText, "@ui_governorexpire_deleted", eUiTextSet_SetLocalized)
  elseif guildMasterActiveResult == eGuildMasterActiveResult_Expired_CharacterOfflineTooLong then
    UiTextBus.Event.SetTextWithFlags(self.Properties.NoGovernorText, "@ui_governorexpire_offline", eUiTextSet_SetLocalized)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.NoGovernorText, guildMasterActiveResult ~= eGuildMasterActiveResult_StillActive)
  UiElementBus.Event.SetIsEnabled(self.Properties.BecomeGovernorButton, showBecomeGovernorButton)
end
function RosterTab:GetNumElements()
  return self.members and #self.members or 0
end
function RosterTab:OnElementBecomingVisible(rootEntity, index)
  if not self.members then
    return
  end
  local memberEntry = self.members[index + 1]
  if not memberEntry then
    return
  end
  local memberPlayerId = memberEntry.playerId
  local memberCharacterId = memberPlayerId:GetCharacterIdString()
  local memberPlayerName = memberPlayerId.playerName
  local memberData = GuildsComponentBus.Broadcast.GetGuildMemberData(memberCharacterId)
  if not UiElementBus.Event.IsEnabled(rootEntity) then
    UiElementBus.Event.SetIsEnabled(rootEntity, true)
  end
  local memberListItem = self.registrar:GetEntityTable(rootEntity)
  local isLocalPlayer = memberPlayerName == self.localPlayerName
  local playerNameText = memberPlayerName
  memberListItem:SetName(playerNameText)
  memberListItem:SetIsOnline(memberData.isOnline or isLocalPlayer)
  memberListItem:SetPlayerIconId(memberPlayerId)
  memberListItem:SetLastOnlineTime(memberData.lastOnlineTime)
  local memberRank = memberData.rank
  if not self.rankNames[memberRank] then
    self.rankNames[memberRank] = GuildsComponentBus.Broadcast.GetRankName(memberRank)
  end
  memberListItem:SetRank(self.rankNames[memberRank], tostring(memberRank + 1))
  memberListItem:SetIsLocalPlayer(isLocalPlayer)
  if not isLocalPlayer then
    local localPlayerRank = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Rank")
    local warCount = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.GuildWarCount")
    local isAtWar = 0 < warCount
    memberListItem:UpdateRankChangeDropdown(memberCharacterId, memberRank, localPlayerRank, self.hasPromotePrivilege, self.hasDemotePrivilege, isAtWar)
    memberListItem:SetGuildMenuEntityId(self.guildMenuEntityId)
    memberListItem:SetRankChangeCallback(function(self, newRank)
      self:OnRankChange(memberPlayerId, memberRank, newRank)
    end, self)
    local canKick = self.hasKickPrivilege and GuildsComponentBus.Broadcast.CanRemoveMember(memberCharacterId)
    memberListItem:SetCanKick(canKick)
    if canKick then
      memberListItem:SetKickCallback(function(self)
        local eventId = "KickMember"
        local title = "@ui_kickfromcompany"
        local message = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_kickguildmember_confirm", memberPlayerName)
        PopupWrapper:RequestPopup(ePopupButtons_YesNo, title, message, eventId, self, function(self, result, eventId)
          if result == ePopupResult_Yes then
            GuildsComponentBus.Broadcast.RequestRemoveGuildMember(memberCharacterId)
          end
        end)
      end, self)
      memberListItem:SetKickTooltip(nil)
    elseif not self.hasKickPrivilege then
      memberListItem:SetKickTooltip("@ui_cantkick_lackpermission")
    else
      memberListItem:SetKickTooltip("@ui_cantkick_lackpermissionforrank")
    end
  end
end
function RosterTab:OnMemberAdded(characterIdString)
  self:SetSpinnerShowing(true)
  self.socialDataHandler:GetPlayerIdentification_ServerCall(self, self.OnMemberAdded_OnPlayerIdReady, self.OnMemberAdded_OnPlayerIdFailed, characterIdString)
end
function RosterTab:OnMemberRemoved(characterIdString)
  for i = 1, #self.members do
    local memberEntry = self.members[i]
    if memberEntry.playerId:GetCharacterIdString() == characterIdString then
      local wasKicked = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.LastRemovedMember.WasKicked")
      local locTag = wasKicked and "@ui_guildmemberremovedmessage" or "@ui_guildmemberleftmessage"
      local notificationData = NotificationData()
      notificationData.contextId = self.entityId
      notificationData.type = "Minor"
      notificationData.text = GetLocalizedReplacementText(locTag, {
        playerName = "<font color=" .. ColorRgbaToHexString(self.UIStyle.COLOR_TAN) .. ">" .. memberEntry.playerId.playerName .. "</font>"
      })
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
      self:WriteGuildMessageToLocalChat(locTag, memberEntry.playerId.playerName)
      if self.isVisible then
        table.remove(self.members, i)
        self:RefreshMemberList()
      end
      break
    end
  end
end
function RosterTab:OnMemberUpdated(characterIdString)
  for i = 1, #self.members do
    local memberEntry = self.members[i]
    if memberEntry.playerId:GetCharacterIdString() == characterIdString then
      self:RefreshMemberList()
      break
    end
  end
end
function RosterTab:OnPlayerDataUpdated(playerId)
  for i = 1, #self.members do
    local memberEntry = self.members[i]
    if memberEntry.playerId:GetCharacterIdString() == playerId:GetCharacterIdString() then
      self:RefreshMemberList()
      break
    end
  end
end
function RosterTab:UpdateLocalPlayerName(localPlayerName)
  self.localPlayerName = localPlayerName
  self:RefreshMemberList()
end
function RosterTab:OnLocalPlayerRankChanged()
  self:UpdatePermissions()
  self:RefreshMemberList()
end
function RosterTab:UpdateMemberSortButtons()
  if self.sortOption == "NameAsc" then
    self.SortName:SetSelectedAscending()
  elseif self.sortOption == "NameDesc" then
    self.SortName:SetSelectedDescending()
  else
    self.SortName:SetDeselected()
  end
  if self.sortOption == "RankAsc" then
    self.SortRank:SetSelectedAscending()
  elseif self.sortOption == "RankDesc" then
    self.SortRank:SetSelectedDescending()
  else
    self.SortRank:SetDeselected()
  end
  if self.sortOption == "OnlineAsc" then
    self.SortOnline:SetSelectedAscending()
  elseif self.sortOption == "OnlineDesc" then
    self.SortOnline:SetSelectedDescending()
  else
    self.SortOnline:SetDeselected()
  end
end
function RosterTab:OnAction(entityId, actionName)
  if type(self[actionName]) == "function" then
    self[actionName](self, entityId, actionName)
  end
end
function RosterTab:OnMyGuildTabSelected()
  self.audioHelper:PlaySound(self.audioHelper.Roster_MyGuildTabSelected)
end
function RosterTab:OnRosterTabSelected()
  self.audioHelper:PlaySound(self.audioHelper.Roster_Tab_Selected)
end
function RosterTab:OnRankChange(playerId, oldRank, newRank)
  if newRank < oldRank then
    self:OnMemberPromote(playerId, newRank)
  elseif oldRank < newRank then
    GuildsComponentBus.Broadcast.RequestSetGuildMemberRank(playerId:GetCharacterIdString(), newRank)
  end
end
function RosterTab:OnMemberPromote(playerId, newRank)
  if newRank == 0 then
    if not self.isGuildLeader then
      return
    end
    local playerName = playerId.playerName
    local guildName = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Name")
    local eventId = "PromoteToGM"
    local title = "@ui_promotetoguildmaster_confirm_title"
    local message = GetLocalizedReplacementText("@ui_promotetoguildmaster_confirm", {memberName = playerName, guildName = guildName})
    PopupWrapper:RequestPopup(ePopupButtons_YesNo, title, message, eventId, self, function(self, result, eventId)
      if result == ePopupResult_Yes then
        GuildsComponentBus.Broadcast.RequestSetGuildMemberRank(playerId:GetCharacterIdString(), 0)
      end
    end)
  else
    GuildsComponentBus.Broadcast.RequestSetGuildMemberRank(playerId:GetCharacterIdString(), newRank)
  end
end
function RosterTab:OnSortName()
  if self.sortOption == "NameAsc" then
    self.sortOption = "NameDesc"
  else
    self.sortOption = "NameAsc"
  end
  self:RefreshMemberList()
  self:UpdateMemberSortButtons()
end
function RosterTab:OnSortRank()
  if self.sortOption == "RankAsc" then
    self.sortOption = "RankDesc"
  else
    self.sortOption = "RankAsc"
  end
  self:RefreshMemberList()
  self:UpdateMemberSortButtons()
end
function RosterTab:OnSortOnline()
  if self.sortOption == "OnlineAsc" then
    self.sortOption = "OnlineDesc"
  else
    self.sortOption = "OnlineAsc"
  end
  self:RefreshMemberList()
  self:UpdateMemberSortButtons()
end
function RosterTab:OnStartEdit()
  SetActionmapsForTextInput(self.canvasId, true)
end
function RosterTab:OnEndEdit()
  SetActionmapsForTextInput(self.canvasId, false)
end
function RosterTab:SubmitBecomeGovernor()
  GuildsComponentBus.Broadcast.RequestSetGuildMasterRank()
end
return RosterTab
