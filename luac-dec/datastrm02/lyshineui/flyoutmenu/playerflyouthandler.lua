local PlayerFlyoutHandler = {
  PFH = {
    onLeavePopupEventId = "Popup_OnLeave",
    onInvitePlayerEventId = "Popup_OnInvitePlayer",
    onMutePlayerEventId = "Popup_OnPlayerIconMutePlayer",
    onUnmutePlayerEventId = "Popup_OnPlayerIconUnmutePlayer",
    onMutePlayerPingsEventId = "Popup_OnPlayerIconMutePlayerPings",
    onUnmutePlayerPingsEventId = "Popup_OnPlayerIconUnmutePlayerPings",
    onBlockPlayerEventId = "Popup_OnPlayerIconBlockPlayer",
    onUnblockPlayerEventId = "Popup_OnPlayerIconUnblockPlayer",
    playerToMute = nil,
    playerToUnmute = nil,
    playerToBlock = nil,
    playerToUnblock = nil,
    localPlayerUIRequestsBusHandler = nil,
    isSpectatable = false,
    isShowingFlyout = false,
    maxRetries = 5,
    currentRetries = 0,
    retryDelay = 2,
    scale = 1,
    ignoreHoverExit = false,
    socialComponentBusReady = false
  }
}
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local registrar = RequireScript("LyShineUI.EntityRegistrar")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local genericInviteCommon = RequireScript("LyShineUI._Common.GenericInviteCommon")
local GameModeCommon = RequireScript("LyShineUI._Common.GameModeCommon")
function PlayerFlyoutHandler:AttachPlayerFlyoutHandler(attachToTable)
  Merge(attachToTable, PlayerFlyoutHandler, true)
end
function PlayerFlyoutHandler:InitPlayerFlyoutHandler(isHandlingSocialComponentReady)
  if not isHandlingSocialComponentReady then
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.JavSocialComponentBus.IsReady", self.PFH_SocialComponentBusIsReady)
  end
end
function PlayerFlyoutHandler:PFH_OnRetry()
  self:PFH_RequestPlayerIconData()
  self.PFH.currentRetries = self.PFH.currentRetries + 1
  if self.PFH.currentRetries > self.PFH.maxRetries then
    self:PFH_SetIsRetrying(false)
  else
    TimingUtils:Delay(self.PFH.retryDelay, self, self.PFH_OnRetry)
  end
end
function PlayerFlyoutHandler:PFH_ResetRetries()
  self.PFH.currentRetries = 0
  self.PFH.iconLoaded = false
  self:PFH_SetIsRetrying(false)
end
function PlayerFlyoutHandler:PFH_SetIsRetrying(isRetrying)
  if isRetrying and self.PFH.currentRetries < self.PFH.maxRetries and not self.PFH.iconLoaded then
    TimingUtils:StopDelay(self)
    TimingUtils:Delay(self.PFH.retryDelay, self, self.PFH_OnRetry)
  else
    TimingUtils:StopDelay(self)
  end
end
function PlayerFlyoutHandler:PFH_SetFlyoutCallbacks(callbackTable, showCallback, closeCallback)
  self.PFH.flyoutCallbacks = {
    callbackTable = callbackTable,
    showCallback = showCallback,
    closeCallback = closeCallback
  }
end
function PlayerFlyoutHandler:PFH_SetPlayerIconDataCallbacks(callbackTable, successCallback, failCallback)
  self.PFH.playerIconDataCallbacks = {
    callbackTable = callbackTable,
    successCallback = successCallback,
    failCallback = failCallback
  }
end
function PlayerFlyoutHandler:PFH_SetPlayerLevelDataCallbacks(callbackTable, successCallback, failCallback)
  self.PFH.playerLevelDataCallbacks = {
    callbackTable = callbackTable,
    successCallback = successCallback,
    failCallback = failCallback
  }
end
function PlayerFlyoutHandler:PFH_SetPlayerFactionDataCallbacks(callbackTable, successCallback, failCallback)
  self.PFH.playerFactionDataCallbacks = {
    callbackTable = callbackTable,
    successCallback = successCallback,
    failCallback = failCallback
  }
end
function PlayerFlyoutHandler:PFH_SetPlayerFaction(faction)
  self.PFH.playerFaction = faction
  self.PFH.isPlayerFactionOverridden = true
  if self.PFH.isShowingFlyout then
    self:PFH_PopulateFlyoutMenu(self.PFH.flyoutOwnerEntityId)
  end
end
function PlayerFlyoutHandler:PFH_SetPlayerLevel(level)
  self.PFH.playerLevel = level
  self.PFH.isPlayerLevelOverridden = true
end
function PlayerFlyoutHandler:PFH_SetPlayerIcon(playerIcon)
  self.PFH.playerIcon = playerIcon:Clone()
  self.PFH.isPlayerIconOverridden = playerIcon ~= nil
end
function PlayerFlyoutHandler:PFH_GetPlayerIcon()
  return self.PFH.playerIcon
end
function PlayerFlyoutHandler:PFH_SetPlayerId(playerId)
  if not playerId or not playerId.playerName then
    Debug.Log("[PlayerFlyoutHandler:PFH_SetPlayerId] Failed to set player data due to invalid playerId :: " .. tostring(self.PFH.playerId.playerName))
    return
  end
  self.PFH.playerId = playerId
  if not self.PFH.simplePlayerId then
    self.PFH.simplePlayerId = SimplePlayerIdentification()
  end
  self.PFH.simplePlayerId.characterIdString = self.PFH.playerId:GetCharacterIdString()
  self.PFH.simplePlayerId.playerName = self.PFH.playerId.playerName
  self:PFH_ResetRetries()
  if not self.PFH.isPlayerIconOverridden then
    self:PFH_RequestPlayerIconData()
  end
  if not self.PFH.isPlayerLevelOverridden then
    if self.PFH.socialComponentBusReady then
      self:PFH_RequestPlayerLevelData()
    else
      self.PFH.updateLevel = true
    end
  end
  self.PFH.isLocalPlayer = playerId.playerName == dataLayer:GetDataFromNode("Hud.LocalPlayer.PlayerName")
  if not self.PFH.isPlayerFactionOverridden then
    if self.PFH.socialComponentBusReady then
      self:PFH_RequestPlayerFactionData()
    else
      self.PFH.updateFaction = true
    end
  end
  if self.PFH.socialComponentBusReady then
    self:PFH_RequestPlayerGuildData()
  else
    self.PFH.updateGuild = true
  end
end
function PlayerFlyoutHandler:PFH_ShowFlyoutForPlayerId(playerId, flyoutOwnerEntityId, forceRefresh)
  local differentId = self.PFH.playerId ~= playerId
  if forceRefresh or differentId then
    self.PFH.playerId = nil
    if differentId or not self.PFH.isPlayerIconOverridden then
      self.PFH.playerIcon = nil
    end
    if differentId or not self.PFH.isPlayerLevelOverridden then
      self.PFH.playerLevel = nil
    end
    if differentId or not self.PFH.isPlayerFactionOverridden then
      self.PFH.playerFaction = nil
    end
    self:PFH_SetPlayerId(playerId)
  end
  self:PFH_ShowFlyout(flyoutOwnerEntityId)
end
function PlayerFlyoutHandler:PFH_ShowFlyout(flyoutOwnerEntityId)
  if not self.PFH.playerId then
    Debug.Log("[PlayerFlyoutHandler:PFH_ShowFlyout] invalid playerId")
    return
  end
  self.PFH.isSpectatable = false
  self:PFH_PopulateFlyoutMenu(flyoutOwnerEntityId)
  if self.PFH.isGroupMate then
    local isSpectatorModeEnabled = ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-spectator") and not FtueSystemRequestBus.Broadcast.IsFtue()
    if isSpectatorModeEnabled then
      if self.PFH.localPlayerUIRequestsBusHandler == nil then
        self.PFH.localPlayerUIRequestsBusHandler = LocalPlayerEventsBus.Connect(self)
      end
      LocalPlayerUIRequestsBus.Broadcast.RequestCanSpectatePlayer(self.PFH.simplePlayerId)
    end
  end
  if self.PFH.flyoutCallbacks and self.PFH.flyoutCallbacks.callbackTable and type(self.PFH.flyoutCallbacks.showCallback) == "function" then
    self.PFH.flyoutCallbacks.showCallback(self.PFH.flyoutCallbacks.callbackTable)
  end
end
function PlayerFlyoutHandler:PFH_RequestPlayerIconData()
  if not self.PFH.playerId then
    return
  end
  self.PFH.playerIcon = nil
  return SocialDataHandler:GetRemotePlayerIconData_ServerCall(self, self.PFH_OnRemotePlayerIconDataReady, self.PFH_OnRemotePlayerIconDataFailed, self.PFH.playerId:GetCharacterIdString())
end
function PlayerFlyoutHandler:PFH_OnRemotePlayerIconDataReady(result)
  if #result == 0 then
    self:PFH_SetIsRetrying(true)
    local playerName = self.PFH.playerId and self.PFH.playerId.playerName or ""
    Log("ERR - PlayerFlyoutHandler:PFH_OnRemotePlayerIconDataReady: No result icons :: " .. tostring(playerName))
    return
  end
  self.PFH.playerIcon = result[1].playerIcon:Clone()
  if self.PFH.isShowingFlyout then
    self:PFH_PopulateFlyoutMenu(self.PFH.flyoutOwnerEntityId)
  end
  self:PFH_SetIsRetrying(false)
  if self.PFH.playerIconDataCallbacks and self.PFH.playerIconDataCallbacks.callbackTable and type(self.PFH.playerIconDataCallbacks.successCallback) == "function" then
    self.PFH.playerIconDataCallbacks.successCallback(self.PFH.playerIconDataCallbacks.callbackTable)
  end
  self.PFH.iconLoaded = true
end
function PlayerFlyoutHandler:PFH_OnRemotePlayerIconDataFailed(reason)
  if reason == eSocialRequestFailureReasonThrottled then
    Log("ERR - PlayerFlyoutHandler:PFH_OnRemotePlayerIconDataFailed: Throttled")
  elseif reason == eSocialRequestFailureReasonTimeout then
    Log("ERR - PlayerFlyoutHandler:PFH_OnRemotePlayerIconDataFailed: Timed Out")
  end
  if self.PFH.playerIconDataCallbacks and self.PFH.playerIconDataCallbacks.callbackTable and type(self.PFH.playerIconDataCallbacks.failCallback) == "function" then
    self.PFH.playerIconDataCallbacks.failCallback(self.PFH.playerIconDataCallbacks.callbackTable)
  end
end
function PlayerFlyoutHandler:PFH_RequestPlayerLevelData()
  self.PFH.playerLevel = 0
  return SocialDataHandler:GetRemotePlayerLevelData_ServerCall(self, self.PFH_OnRemotePlayerLevelDataReady, self.PFH_OnRemotePlayerlevelDataFailed, self.PFH.playerId:GetCharacterIdString())
end
function PlayerFlyoutHandler:PFH_OnRemotePlayerLevelDataReady(result)
  if #result == 0 then
    Log("ERR - PlayerFlyoutHandler:PFH_OnRemotePlayerLevelDataReady: Level not found:: " .. self.PFH.playerId.playerName)
    return
  end
  self.PFH.playerLevel = result[1].playerLevel + 1
  if self.PFH.isShowingFlyout then
    self:PFH_PopulateFlyoutMenu(self.PFH.flyoutOwnerEntityId)
  end
  if self.PFH.playerLevelDataCallbacks and self.PFH.playerLevelDataCallbacks.callbackTable and type(self.PFH.playerLevelDataCallbacks.successCallback) == "function" then
    self.PFH.playerLevelDataCallbacks.successCallback(self.PFH.playerLevelDataCallbacks.callbackTable)
  end
end
function PlayerFlyoutHandler:PFH_OnRemotePlayerLevelDataFailed(reason)
  if reason == eSocialRequestFailureReasonThrottled then
    Log("ERR - PlayerFlyoutHandler:PFH_OnRemotePlayerLevelDataFailed: Throttled")
  elseif reason == eSocialRequestFailureReasonTimeout then
    Log("ERR - PlayerFlyoutHandler:PFH_OnRemotePlayerLevelDataFailed: Timed Out")
  end
  if self.PFH.playerLevelDataCallbacks and self.PFH.playerLevelDataCallbacks.callbackTable and type(self.PFH.playerLevelDataCallbacks.failCallback) == "function" then
    self.PFH.playerLevelDataCallbacks.failCallback(self.PFH.playerLevelDataCallbacks.callbackTable)
  end
end
function PlayerFlyoutHandler:PFH_RequestPlayerFactionData()
  self.PFH.playerFaction = eFactionType_None
  return SocialDataHandler:GetRemotePlayerFaction_ServerCall(self, self.PFH_OnRemotePlayerFactionDataReady, self.PFH_OnRemotePlayerFactionDataFailed, self.PFH.playerId:GetCharacterIdString())
end
function PlayerFlyoutHandler:PFH_OnRemotePlayerFactionDataReady(result)
  if #result == 0 then
    Log("ERR - PlayerFlyoutHandler:PFH_OnRemotePlayerFactionDataReady: Faction not found:: " .. self.PFH.playerId.playerName)
    return
  end
  self.PFH.playerFaction = result[1].playerFaction
  if self.PFH.isShowingFlyout then
    self:PFH_PopulateFlyoutMenu(self.PFH.flyoutOwnerEntityId)
  end
  if self.PFH.playerFactionDataCallbacks and self.PFH.playerFactionDataCallbacks.callbackTable and type(self.PFH.playerFactionDataCallbacks.successCallback) == "function" then
    self.PFH.playerFactionDataCallbacks.successCallback(self.PFH.playerFactionDataCallbacks.callbackTable)
  end
end
function PlayerFlyoutHandler:PFH_OnRemotePlayerFactionDataFailed(reason)
  if reason == eSocialRequestFailureReasonThrottled then
    Log("ERR - PlayerFlyoutHandler:PFH_OnRemotePlayerFactionDataFailed: Throttled")
  elseif reason == eSocialRequestFailureReasonTimeout then
    Log("ERR - PlayerFlyoutHandler:PFH_OnRemotePlayerFactionDataFailed: Timed Out")
  end
  if self.PFH.playerFactionDataCallbacks and self.PFH.playerFactionDataCallbacks.callbackTable and type(self.PFH.playerFactionDataCallbacks.failCallback) == "function" then
    self.PFH.playerFactionDataCallbacks.failCallback(self.PFH.playerFactionDataCallbacks.callbackTable)
  end
end
function PlayerFlyoutHandler:PFH_RequestPlayerGuildData()
  self.PFH.guildId = nil
  self.PFH.guildName = ""
  self.PFH.guildCrestData = nil
  SocialDataHandler:GetRemotePlayerGuildId_ServerCall(self, self.PFH_OnRemotePlayerGuildIdReady, self.PFH_OnRemotePlayerGuildIdFailed, self.PFH.playerId:GetCharacterIdString())
end
function PlayerFlyoutHandler:PFH_OnRemotePlayerGuildIdReady(result)
  if #result == 0 then
    Log("ERR - PlayerFlyoutHandler:PFH_OnRemotePlayerGuildIdReady: GuildId not found:: " .. self.PFH.playerId.playerName)
    return
  end
  self.PFH.guildId = result[1].playerGuildId
  if self.PFH.guildId and self.PFH.guildId:IsValid() then
    SocialDataHandler:GetGuildDetailedData_ServerCall(self, self.PFH_OnRemotePlayerGuildDataReady, self.PFH_OnRemotePlayerGuildDataFailed, self.PFH.guildId)
  end
end
function PlayerFlyoutHandler:PFH_OnRemotePlayerGuildIdFailed(reason)
  if reason == eSocialRequestFailureReasonThrottled then
    Log("ERR - PlayerFlyoutHandler:PFH_OnRemotePlayerGuildIdFailed: Throttled")
  elseif reason == eSocialRequestFailureReasonTimeout then
    Log("ERR - PlayerFlyoutHandler:PFH_OnRemotePlayerGuildIdFailed: Timed Out")
  end
end
function PlayerFlyoutHandler:PFH_OnRemotePlayerGuildDataReady(result)
  local guildData
  if 0 < #result then
    guildData = type(result[1]) == "table" and result[1].guildData or result[1]
  else
    Log("ERR - PlayerFlyoutHandler:PFH_OnRemotePlayerGuildDataReady: GuildData request returned with no data")
    return
  end
  if guildData and guildData:IsValid() then
    self.PFH.guildName = guildData.guildName
    self.PFH.guildCrestData = guildData.crestData
    if self.PFH.isShowingFlyout then
      self:PFH_PopulateFlyoutMenu(self.PFH.flyoutOwnerEntityId)
    end
  end
end
function PlayerFlyoutHandler:PFH_OnRemotePlayerGuildDataFailed(reason)
  if reason == eSocialRequestFailureReasonThrottled then
    Log("ERR - PlayerFlyoutHandler:PFH_OnRemotePlayerGuildDataFailed: Throttled")
  elseif reason == eSocialRequestFailureReasonTimeout then
    Log("ERR - PlayerFlyoutHandler:PFH_OnRemotePlayerGuildDataFailed: Timed Out")
  end
end
function PlayerFlyoutHandler:PFH_SetChatMessage(message)
  self.PFH.chatMessage = message
end
function PlayerFlyoutHandler:PFH_PopulateFlyoutMenu(openingEntityId)
  self.PFH.flyoutOwnerEntityId = openingEntityId or self.entityId
  local flyoutMenu = GetFlyoutMenu(dataLayer, registrar)
  local characterId = self.PFH.playerId:GetCharacterIdString()
  local isFriend = JavSocialComponentBus.Broadcast.IsFriend(characterId)
  local rows = {}
  local optionsRow = {
    type = flyoutMenu.ROW_TYPE_Options,
    context = self,
    sections = {
      [1] = {
        title = "@ui_social",
        options = {}
      },
      [2] = {
        title = "@ui_group_moderation",
        options = {}
      },
      [3] = {
        title = "@ui_moderation",
        options = {}
      }
    }
  }
  local hasOptions = false
  local isMuted = ChatComponentBus.Broadcast.IsPlayerMuted(characterId)
  local isBlocked = JavSocialComponentBus.Broadcast.IsPlayerBlocked(characterId)
  local playerIconBg = self.UIStyle.COLOR_GRAY_70
  if self.PFH.playerFaction and FactionCommon.factionInfoTable[self.PFH.playerFaction] then
    playerIconBg = FactionCommon.factionInfoTable[self.PFH.playerFaction].crestBgColor
  end
  table.insert(rows, {
    type = flyoutMenu.ROW_TYPE_PlayerHeader,
    name = self.PFH.playerId.playerName,
    icon = self.PFH.playerIcon,
    iconBg = playerIconBg,
    guildName = self.PFH.guildName,
    crest = self.PFH.guildCrestData,
    level = self.PFH.playerLevel
  })
  if self.PFH.isStreaming then
    table.insert(rows, {
      type = flyoutMenu.ROW_TYPE_StreamingStatus,
      markerId = self.PFH.markerId
    })
  end
  if self.PFH.isLocalPlayer then
    local groupId = dataLayer:GetDataFromNode("Hud.LocalPlayer.Group.Id")
    if groupId and groupId:IsValid() then
      local playerRootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
      local canLeaveGroup = true
      local leaveGroupTooltip
      if GameRequestsBus.Broadcast.IsInDungeonGameMode() then
        canLeaveGroup = false
        leaveGroupTooltip = "@ui_cannotleavegroup_in_dungeon"
      elseif PlayerArenaRequestBus.Event.IsInArena(playerRootEntityId) then
        canLeaveGroup = false
        leaveGroupTooltip = "@ui_cannotleavegroup_in_arena"
      end
      table.insert(optionsRow.sections[2].options, {
        buttonText = "@ui_leavegroup",
        tooltipText = leaveGroupTooltip,
        callback = self.PFH_LeaveGroup,
        enabled = canLeaveGroup
      })
      hasOptions = true
    end
  else
    local localPlayerFaction = dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
    local isSameFaction = self.PFH.playerFaction == localPlayerFaction
    self.PFH.isGroupMate = LocalGroupRequestBus.Broadcast.IsGroupMate(characterId)
    local isGroupFull = LocalGroupRequestBus.Broadcast.IsGroupFull()
    local playerRootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
    local isPvpGroup = FactionRequestBus.Event.IsPvpFlaggedOrPending(playerRootEntityId)
    local myRaidId = dataLayer:GetDataFromNode("Hud.LocalPlayer.Raid.Id")
    local isInRaid = myRaidId and myRaidId:IsValid()
    if isBlocked then
      table.insert(optionsRow.sections[3].options, {
        buttonText = "@ui_unblock_player",
        callback = self.PFH_OnUnblockPlayer,
        enabled = isBlocked
      })
    else
      table.insert(optionsRow.sections[1].options, {
        buttonText = "@ui_chat_name_whisper",
        callback = self.PFH_OnWhisperPlayer,
        enabled = true,
        onlineCheckCharacterIdString = characterId
      })
      if isMuted then
        table.insert(optionsRow.sections[3].options, {
          buttonText = "@ui_unmute_player",
          callback = self.PFH_OnUnmutePlayer,
          enabled = isMuted
        })
      else
        table.insert(optionsRow.sections[3].options, {
          buttonText = "@ui_mute_player",
          callback = self.PFH_OnMutePlayer,
          enabled = not isMuted
        })
      end
      table.insert(optionsRow.sections[3].options, {
        buttonText = "@ui_block_player",
        callback = self.PFH_OnBlockPlayer,
        enabled = not isBlocked
      })
    end
    if isFriend then
      table.insert(optionsRow.sections[1].options, {
        buttonText = "@ui_removefriend",
        callback = self.PFH_OnFriendRemove,
        enabled = isFriend
      })
    elseif JavSocialComponentBus.Broadcast.IsPendingFriendRequest(characterId) then
      table.insert(optionsRow.sections[1].options, {
        buttonText = "@ui_acceptfriendinvite",
        callback = self.PFH_OnAcceptFriendInvite,
        enabled = true
      })
      table.insert(optionsRow.sections[1].options, {
        buttonText = "@ui_rejectfriendinvite",
        callback = self.PFH_OnRejectFriendInvite,
        enabled = true
      })
    else
      table.insert(optionsRow.sections[1].options, {
        buttonText = "@ui_addfriend",
        callback = self.PFH_OnFriendInvite,
        enabled = not isFriend
      })
    end
    local groupInviteTooltip
    if self.PFH.isGroupMate then
      groupInviteTooltip = "@ui_cannotinviteingroup"
    elseif isGroupFull then
      groupInviteTooltip = "@ui_cannotinvitegroupfull"
    elseif isInRaid then
      groupInviteTooltip = "@ui_cannotinviteinraid"
    elseif isPvpGroup and not isSameFaction then
      groupInviteTooltip = "@ui_cannotinvitein_pvp_wrong_faction"
    end
    local canInviteToGroup = not self.PFH.isGroupMate and not isGroupFull and not isInRaid and (not isPvpGroup or isSameFaction)
    table.insert(optionsRow.sections[1].options, {
      buttonText = "@ui_invitetogroup",
      tooltipText = groupInviteTooltip,
      callback = self.PFH_OnGroupInvite,
      data = self.PFH.playerId,
      enabled = canInviteToGroup,
      onlineCheckCharacterIdString = characterId
    })
    local p2pTradingEnabled = self.dataLayer:GetDataFromNode("javelin.enable-p2p-trading")
    if p2pTradingEnabled then
      local canInviteToTrade, tradeInviteTooltip = genericInviteCommon:ValidateEligibility(2115650406, self.PFH.playerId)
      table.insert(optionsRow.sections[1].options, {
        buttonText = "@ui_p2ptrading_initiate_trade",
        tooltipText = tradeInviteTooltip,
        tickCallback = self.PFH_OnTradeButtonTick,
        callback = self.PFH_OnInititateTrade,
        enabled = canInviteToTrade
      })
    end
    local groupKickEnabled = ConfigProviderEventBus.Broadcast.GetBool("javelin.social.group-kick-enabled")
    if groupKickEnabled and self.PFH.isGroupMate then
      local kickCooldownInSeconds = ConfigProviderEventBus.Broadcast.GetInt("javelin.social.group-kick-cooldown-ms") / 1000
      local canVoteKick = true
      local voteKickTooltip = GetLocalizedReplacementText("@ui_votekick_tooltip", {
        cooldown = timeHelpers:ConvertToVerboseDurationString(kickCooldownInSeconds)
      })
      local groupId = dataLayer:GetDataFromNode("Hud.LocalPlayer.Group.Id")
      local isKickImmune = GroupDataRequestBus.Event.GetMemberIsKickImmune(groupId, characterId)
      local isKickVoteActive = DynamicBus.SocialPaneBus.Broadcast.IsKickVoteActive()
      if isKickImmune then
        canVoteKick = false
        voteKickTooltip = "@ui_votekick_disabled_immune"
      elseif isInRaid then
        canVoteKick = false
        voteKickTooltip = "@ui_votekick_disabled_inevent"
      elseif isKickVoteActive then
        canVoteKick = false
        voteKickTooltip = "@ui_votekick_disabled_voteinprogress"
      end
      table.insert(optionsRow.sections[2].options, {
        buttonText = "@ui_votekick",
        tooltipText = voteKickTooltip,
        callback = self.PFH_VoteKick,
        data = self.PFH.playerId,
        enabled = canVoteKick
      })
    end
    local guildId = dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Id")
    local isInGuild = guildId and guildId:IsValid()
    local isGuildMate = GuildsComponentBus.Broadcast.IsGuildMate(characterId)
    local canInviteToCompany = not isGuildMate and localPlayerFaction ~= eFactionType_None and isSameFaction and isInGuild
    local companyInviteTooltip
    if not canInviteToCompany then
      if isGuildMate then
        companyInviteTooltip = "@ui_inguild_invite_error"
      elseif self.PFH.playerFaction == eFactionType_None then
        companyInviteTooltip = "@ui_nofaction_invite_error"
      elseif self.PFH.playerFaction ~= localPlayerFaction then
        companyInviteTooltip = "@ui_faction_invite_error"
      elseif not isInGuild then
        companyInviteTooltip = "@ui_cantinvite_noguild"
      end
    end
    table.insert(optionsRow.sections[1].options, {
      buttonText = "@ui_invitetoguild",
      tooltipText = companyInviteTooltip,
      callback = self.PFH_OnGuildInvite,
      enabled = canInviteToCompany
    })
    local duelsEnabled = self.dataLayer:GetDataFromNode("javelin.enable-game-mode-duels")
    if duelsEnabled then
      local canInviteToDuel, duelInviteTooltip = genericInviteCommon:ValidateEligibility(2612307810, self.PFH.playerId)
      table.insert(optionsRow.sections[1].options, {
        buttonText = "@ui_duel_player",
        tooltipText = duelInviteTooltip,
        tickCallback = self.PFH_OnDuelButtonTick,
        callback = self.PFH_OnDuelPlayer,
        enabled = canInviteToDuel
      })
    end
    if self.PFH.isGroupMate then
      local isPingMuted = GroupsRequestBus.Broadcast.GetIsPingMuted(characterId)
      if isPingMuted then
        table.insert(optionsRow.sections[2].options, {
          buttonText = "@ui_unmute_player_pings",
          callback = self.PFH_OnUnmutePings,
          enabled = true
        })
      else
        table.insert(optionsRow.sections[2].options, {
          buttonText = "@ui_mute_player_pings",
          callback = self.PFH_OnMutePings,
          enabled = true
        })
      end
    end
    if self.PFH.isStreaming and self.PFH.twitchChannel then
      table.insert(optionsRow.sections[1].options, {
        buttonText = "@ui_viewtwitchstream",
        callback = self.PFH_OnViewTwitchStream,
        enabled = self.PFH.isStreaming
      })
    end
    if self.PFH.isSpectatable then
      table.insert(optionsRow.sections[1].options, {
        buttonText = "@ui_spectate",
        callback = self.PFH_OnSpectate,
        enabled = true
      })
    end
    local enableReport = dataLayer:GetDataFromNode("UIFeatures.g_uiEnableReportPlayer")
    if enableReport then
      table.insert(optionsRow.sections[3].options, {
        buttonText = "@ui_report",
        callback = self.PFH_OnReport,
        enabled = true
      })
    end
    hasOptions = true
  end
  if hasOptions then
    table.insert(rows, optionsRow)
  end
  local currentState = LyShineManagerBus.Broadcast.GetCurrentState()
  local permissions = DynamicBus.Raid.Broadcast.GetPlayerPermissions()
  if currentState == 1468490675 and permissions > eRaidPermission_Normal then
    table.insert(rows, {
      type = flyoutMenu.ROW_TYPE_Subheader,
      header = "@ui_army_menu"
    })
    local raidOptionsRow = {
      type = flyoutMenu.ROW_TYPE_Options,
      optionsRowActionSuffix = "Raid",
      context = self,
      options = {}
    }
    if not self.isStandby then
      if permissions == eRaidPermission_Leader then
        local promoteTooltip
        if self.permissions >= eRaidPermission_Leader then
          promoteTooltip = "@ui_promote_disabled_max_tooltip"
        end
        local demoteTooltip
        if self.permissions <= eRaidPermission_Normal then
          demoteTooltip = "@ui_demote_disabled_min_tooltip"
        end
        table.insert(raidOptionsRow.options, {
          buttonText = "@ui_promote",
          tooltipText = promoteTooltip,
          callback = self.PFH_OnNewPermissions,
          data = {
            groupIndex = self.groupIndex,
            indexInGroup = self.indexInGroup,
            playerId = self.playerId,
            characterId = self.characterId,
            permission = self.permissions + 1
          },
          enabled = self.permissions < eRaidPermission_Leader
        })
        table.insert(raidOptionsRow.options, {
          buttonText = "@ui_demote",
          tooltipText = demoteTooltip,
          callback = self.PFH_OnNewPermissions,
          data = {
            groupIndex = self.groupIndex,
            indexInGroup = self.indexInGroup,
            playerId = self.playerId,
            characterId = self.characterId,
            permission = self.permissions - 1
          },
          enabled = self.permissions > eRaidPermission_Normal
        })
        hasOptions = true
      end
      if permissions >= eRaidPermission_Assistant then
        table.insert(raidOptionsRow.options, {
          buttonText = "@ui_remove_army",
          callback = self.OnRemove,
          data = {
            groupIndex = self.groupIndex,
            indexInGroup = self.indexInGroup,
            playerId = self.playerId,
            characterId = self.characterId
          },
          enabled = true
        })
        hasOptions = true
      end
    end
    local isInvasion = DynamicBus.Raid.Broadcast.IsInvasion()
    if not self.PFH.isLocalPlayer then
      local kickTooltipText
      if isInvasion then
        kickTooltipText = "@ui_kick_disabled_invasion"
      end
      table.insert(raidOptionsRow.options, {
        buttonText = "@ui_kick_army",
        tooltipText = kickTooltipText,
        callback = self.OnKick,
        data = {
          groupIndex = self.groupIndex,
          indexInGroup = self.indexInGroup,
          playerId = self.playerId,
          characterId = self.characterId
        },
        enabled = not isInvasion
      })
      hasOptions = true
    end
    table.insert(rows, raidOptionsRow)
  end
  if not self.PFH.isShowingFlyout then
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
    flyoutMenu:SetClosedCallback(self, self.PFH_OnFlyoutMenuClosed)
    flyoutMenu:EnableFlyoutDelay(false)
    flyoutMenu:SetOpenLocation(self.PFH.flyoutOwnerEntityId, self.PFH.locationPreference, self.PFH.scale)
    self.PFH.isShowingFlyout = true
  end
  flyoutMenu:SetRowData(rows)
  if not hasOptions then
    flyoutMenu:SourceHoverOnly()
  end
  flyoutMenu:SetAllowPositionalExitHover(not self.PFH.stopPositionalExitHover)
  flyoutMenu:SetIgnoreHoverExit(self.PFH.ignoreHoverExit)
end
function PlayerFlyoutHandler:PFH_OnNewPermissions(data)
  DynamicBus.Raid.Broadcast.SetPlayerPermissions(data)
end
function PlayerFlyoutHandler:PFH_OnFlyoutMenuClosed()
  self.PFH.isShowingFlyout = false
  self.PFH.chatMessage = nil
  if self.PFH.localPlayerUIRequestsBusHandler ~= nil then
    self.PFH.localPlayerUIRequestsBusHandler:Disconnect()
    self.PFH.localPlayerUIRequestsBusHandler = nil
  end
  if self.PFH.flyoutCallbacks and self.PFH.flyoutCallbacks.callbackTable and type(self.PFH.flyoutCallbacks.closeCallback) == "function" then
    self.PFH.flyoutCallbacks.closeCallback(self.PFH.flyoutCallbacks.callbackTable)
  end
end
function PlayerFlyoutHandler:PFH_OnAcceptFriendInvite()
  JavSocialComponentBus.Broadcast.RequestFriendStatusChange(eFriendRequestType_Accept, self.PFH.simplePlayerId:GetCharacterIdString())
end
function PlayerFlyoutHandler:PFH_OnRejectFriendInvite()
  JavSocialComponentBus.Broadcast.RequestFriendStatusChange(eFriendRequestType_Reject, self.PFH.simplePlayerId:GetCharacterIdString())
end
function PlayerFlyoutHandler:PFH_OnGroupInvite()
  local playerRootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  local isInOutpostRushQueue = GameModeParticipantComponentRequestBus.Event.IsInQueueForGameMode(playerRootEntityId, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
  if isInOutpostRushQueue then
    self.playerToInvite = self.PFH.simplePlayerId:GetCharacterIdString()
    PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_invitetogroup", "@ui_queuewarning_invite", self.PFH.onInvitePlayerEventId, self, self.PFH_OnPopupResult)
  else
    GroupsRequestBus.Broadcast.RequestGroupInvite(self.PFH.simplePlayerId:GetCharacterIdString())
  end
end
function PlayerFlyoutHandler:PFH_OnFriendInvite()
  JavSocialComponentBus.Broadcast.RequestFriendStatusChange(eFriendRequestType_Invite, self.PFH.simplePlayerId:GetCharacterIdString())
  local notificationData = NotificationData()
  notificationData.type = "FriendInvite"
  notificationData.title = "@ui_friendrequesttitle"
  notificationData.text = GetLocalizedReplacementText("@ui_friendrequestsendermessage", {
    playerName = self.PFH.simplePlayerId.playerName
  })
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function PlayerFlyoutHandler:PFH_OnDuelButtonTick(flyoutMenuOption)
  if self.PFH.isShowingFlyout and self.PFH.playerId then
    local canInviteToTrade, tradeInviteTooltip = genericInviteCommon:ValidateEligibility(2612307810, self.PFH.playerId)
    flyoutMenuOption:SetIsHandlingEvents(canInviteToTrade)
    flyoutMenuOption:SetTooltip(tradeInviteTooltip)
  end
end
function PlayerFlyoutHandler:PFH_OnDuelPlayer()
  genericInviteCommon:RequestSendNewDuelInvite(self.PFH.simplePlayerId:GetCharacterIdString())
end
function PlayerFlyoutHandler:PFH_OnTradeButtonTick(flyoutMenuOption)
  if self.PFH.isShowingFlyout and self.PFH.playerId then
    local canInviteToTrade, tradeInviteTooltip = genericInviteCommon:ValidateEligibility(2115650406, self.PFH.playerId)
    flyoutMenuOption:SetIsHandlingEvents(canInviteToTrade)
    flyoutMenuOption:SetTooltip(tradeInviteTooltip)
  end
end
function PlayerFlyoutHandler:PFH_OnInititateTrade()
  genericInviteCommon:RequestSendNewInvite(2115650406, eForwardType_Solo, self.PFH.simplePlayerId:GetCharacterIdString(), "@ui_p2ptrading_trade_notification_sent")
end
function PlayerFlyoutHandler:PFH_OnFriendRemove()
  JavSocialComponentBus.Broadcast.RequestFriendStatusChange(eFriendRequestType_Remove, self.PFH.simplePlayerId:GetCharacterIdString())
end
function PlayerFlyoutHandler:PFH_OnGuildInvite()
  GuildsComponentBus.Broadcast.RequestGuildInvite(self.PFH.simplePlayerId:GetCharacterIdString())
end
function PlayerFlyoutHandler:PFH_OnJoinGroupChannel()
  DynamicBus.SocialPaneBus.Broadcast.JoinGroupVoip()
end
function PlayerFlyoutHandler:PFH_OnLeaveGroupChannel()
  DynamicBus.SocialPaneBus.Broadcast.JoinWorldVoip()
end
function PlayerFlyoutHandler:PFH_OnViewTwitchStream()
  if self.PFH.twitchChannel and self.PFH.twitchChannel ~= "" then
    OptionsDataBus.Broadcast.OpenTwitchStreamInBrowser(self.PFH.twitchChannel)
  end
end
function PlayerFlyoutHandler:PFH_OnSpectate()
  LocalPlayerUIRequestsBus.Broadcast.RequestSpectatePlayer(self.PFH.simplePlayerId:GetCharacterIdString())
end
function PlayerFlyoutHandler:PFH_OnReport()
  DynamicBus.ReportPlayerBus.Broadcast.OpenReport(self.PFH.playerId, self.PFH.chatMessage)
end
function PlayerFlyoutHandler:PFH_OnWhisperPlayer()
  DynamicBus.ChatBus.Broadcast.OpenWhisperToPlayer(self.PFH.playerId.playerName)
end
function PlayerFlyoutHandler:PFH_OnDeclareWar()
  local enableDominion = dataLayer:GetDataFromNode("UIFeatures.g_enableDominion")
  if enableDominion then
    warDeclarationPopupHelper:ShowWarDeclarationPopup(self.PFH.guildId, self.PFH.guildName, self.PFH.guildCrestData, 0)
  end
end
function PlayerFlyoutHandler:PFH_OnMutePlayer()
  self.PFH.playerToMute = self.PFH.simplePlayerId:GetCharacterIdString()
  local muteConfirmPlayerName = GetLocalizedReplacementText("@ui_mute_confirm", {
    playerName = self.PFH.simplePlayerId.playerName
  })
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_mute_player", muteConfirmPlayerName, self.PFH.onMutePlayerEventId, self, self.PFH_OnPopupResult)
end
function PlayerFlyoutHandler:PFH_OnUnmutePlayer()
  self.PFH.playerToUnmute = self.PFH.simplePlayerId:GetCharacterIdString()
  local unmuteConfirmPlayerName = GetLocalizedReplacementText("@ui_mute_confirm", {
    playerName = self.PFH.simplePlayerId.playerName
  })
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_unmute_player", unmuteConfirmPlayerName, self.PFH.onUnmutePlayerEventId, self, self.PFH_OnPopupResult)
end
function PlayerFlyoutHandler:PFH_OnMutePings()
  self.PFH.playerPingsToMute = self.PFH.simplePlayerId:GetCharacterIdString()
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_mute_player_pings", "@ui_mute_pings_confirm", self.PFH.onMutePlayerPingsEventId, self, self.PFH_OnPopupResult)
end
function PlayerFlyoutHandler:PFH_OnUnmutePings()
  self.PFH.playerPingsToMute = self.PFH.simplePlayerId:GetCharacterIdString()
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_unmute_player_pings", "@ui_unmute_pings_confirm", self.PFH.onUnmutePlayerPingsEventId, self, self.PFH_OnPopupResult)
end
function PlayerFlyoutHandler:PFH_OnBlockPlayer()
  self.PFH.playerToBlock = self.PFH.simplePlayerId:GetCharacterIdString()
  local blockConfirmPlayerName = GetLocalizedReplacementText("@ui_block_confirm", {
    playerName = self.PFH.simplePlayerId.playerName
  })
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_block_player", blockConfirmPlayerName, self.PFH.onBlockPlayerEventId, self, self.PFH_OnPopupResult)
end
function PlayerFlyoutHandler:PFH_OnUnblockPlayer()
  self.PFH.playerToUnblock = self.PFH.simplePlayerId:GetCharacterIdString()
  local unblockConfirmPlayerName = GetLocalizedReplacementText("@ui_unblock_confirm", {
    playerName = self.PFH.simplePlayerId.playerName
  })
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_unblock_player", unblockConfirmPlayerName, self.PFH.onUnblockPlayerEventId, self, self.PFH_OnPopupResult)
end
function PlayerFlyoutHandler:PFH_LeaveGroup()
  local message = "@ui_leavegrouppopupmessage"
  local playerRootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  local isInOutpostRushQueue = GameModeParticipantComponentRequestBus.Event.IsInQueueForGameMode(playerRootEntityId, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
  if isInOutpostRushQueue then
    message = "@ui_queuewarning_leave"
  else
    local groupId = dataLayer:GetDataFromNode("Hud.LocalPlayer.Group.Id")
    local groupDungeonInstanceState = GroupDataRequestBus.Event.GetGroupDungeonInstanceState(groupId)
    if groupDungeonInstanceState == DungeonInstanceState_Queued then
      local gameModeId = GroupDataRequestBus.Event.GetDungeonGameModeId(groupId)
      local gameModeData = GameModeParticipantComponentRequestBus.Event.GetGameModeStaticData(playerRootEntityId, gameModeId)
      message = GetLocalizedReplacementText("@ui_queue_leave_group_confirm_message", {
        minGroupSize = gameModeData.minGroupSize
      })
    end
  end
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_leavegrouppopuptitle", message, self.PFH.onLeavePopupEventId, self, self.PFH_OnPopupResult)
end
function PlayerFlyoutHandler:PFH_VoteKick()
  GroupsRequestBus.Broadcast.RequestInitiateKickVotePlayer(self.PFH.simplePlayerId:GetCharacterIdString())
end
function PlayerFlyoutHandler:PFH_OnPopupResult(result, eventId)
  if result ~= ePopupResult_Yes then
    return
  end
  if eventId == self.PFH.onLeavePopupEventId then
    GroupsRequestBus.Broadcast.RequestLeaveGroup()
  elseif eventId == self.PFH.onInvitePlayerEventId then
    GroupsRequestBus.Broadcast.RequestGroupInvite(self.playerToInvite)
    self.playerToInvite = nil
  elseif eventId == self.PFH.onMutePlayerEventId then
    ChatComponentBus.Broadcast.SendSetChatMute(self.PFH.playerToMute, false)
    self.PFH.playerToMute = nil
  elseif eventId == self.PFH.onUnmutePlayerEventId then
    ChatComponentBus.Broadcast.SendClearChatMute(self.PFH.playerToUnmute, false)
    self.PFH.playerToUnmute = nil
  elseif eventId == self.PFH.onBlockPlayerEventId then
    JavSocialComponentBus.Broadcast.RequestSetSocialBlock(self.PFH.playerToBlock)
    self.PFH.playerToBlock = nil
  elseif eventId == self.PFH.onUnblockPlayerEventId then
    JavSocialComponentBus.Broadcast.RequestClearSocialBlock(self.PFH.playerToUnblock)
    self.PFH.playerToUnblock = nil
  elseif eventId == self.PFH.onMutePlayerPingsEventId or eventId == self.PFH.onUnmutePlayerPingsEventId then
    GroupsRequestBus.Broadcast.SetPingMute(self.PFH.playerPingsToMute, eventId == self.PFH.onMutePlayerPingsEventId)
    self.PFH.playerPingsToMute = nil
  end
end
function PlayerFlyoutHandler:PFH_OnRequestCanSpectateResponse(canSpectate)
  self.PFH.isSpectatable = canSpectate
  if canSpectate then
    self:PFH_PopulateFlyoutMenu(self.PFH.flyoutOwnerEntityId)
  end
end
function PlayerFlyoutHandler:PFH_SocialComponentBusIsReady(isReady)
  self.PFH.socialComponentBusReady = isReady
  if not isReady then
    return
  end
  if self.PFH.updateGuild then
    self.PFH.updateGuild = false
    self:PFH_RequestPlayerGuildData()
  end
  if self.PFH.updateFaction then
    self.PFH.updateFaction = false
    self:PFH_RequestPlayerFactionData()
  end
  if self.PFH.updateLevel then
    self.PFH.updateLevel = false
    self:PFH_RequestPlayerLevelData()
  end
end
return PlayerFlyoutHandler
