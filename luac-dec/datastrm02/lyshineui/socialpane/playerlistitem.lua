local PlayerListItem = {
  Properties = {
    PlayerIcon = {
      default = EntityId()
    },
    PlayerName = {
      default = EntityId()
    },
    PlayerStatus = {
      default = EntityId()
    },
    AcceptButton = {
      default = EntityId()
    },
    AcceptButtonTooltip = {
      default = EntityId()
    },
    RejectButton = {
      default = EntityId()
    },
    CustomButton = {
      default = EntityId()
    },
    CustomButtonText = {
      default = EntityId()
    },
    CustomButtonIcon = {
      default = EntityId()
    },
    OnlineIndicator = {
      default = EntityId()
    },
    GuildCrest = {
      default = EntityId()
    },
    ListSelect = {
      default = EntityId()
    },
    ErrorMessage = {
      default = EntityId()
    }
  },
  mWidth = 470,
  mHeight = 52,
  acceptButtonDisabledOpacity = 0.4,
  playerId = nil,
  acceptInviteWhileGroupedPopupEventId = "Popup_acceptInviteWhileGrouped",
  numMembers = 0,
  isOnline = nil,
  playerFaction = eFactionType_None
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(PlayerListItem)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local GameModeCommon = RequireScript("LyShineUI._Common.GameModeCommon")
function PlayerListItem:OnInit()
  BaseElement.OnInit(self)
  self.socialDataHandler = SocialDataHandler
  self.socialDataHandler:OnActivate()
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Social.LastUpdatedPlayer.PlayerId", self.OnLastUpdatedPlayer)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Faction", function(self, factionType)
    self.localPlayerFaction = factionType
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.PvpFlag", function(self, pvpFlag)
    if not pvpFlag then
      return
    end
    local playerRootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
    self.isPvpFlaggedOrPending = FactionRequestBus.Event.IsPvpFlaggedOrPending(playerRootEntityId)
    self:UpdateButtonVisibility()
  end)
end
function PlayerListItem:OnShutdown()
  self.socialDataHandler:OnDeactivate()
end
function PlayerListItem:SetListKey(value)
  self.listKey = value
end
function PlayerListItem:SetCategory(value)
  self.category = value
  if self.category == "FriendInvite" or self.category == "GroupInvite" or self.category == "GuildInvite" then
    UiTransform2dBus.Event.SetLocalWidth(self.ListSelect, 490)
  else
    UiTransform2dBus.Event.SetLocalWidth(self.ListSelect, 498)
  end
end
function PlayerListItem:OnGroupMemberCountUpdate(numMembers)
  self.numMembers = numMembers or 0
end
function PlayerListItem:OnPlayerIdentificationFailed(reason)
  if reason == eSocialRequestFailureReasonThrottled then
    Log("ERR - PlayerListItem:OnPlayerIdentificationFailed: Throttled, category: " .. tostring(self.category) .. ", key: " .. tostring(self.listKey))
  elseif reason == eSocialRequestFailureReasonTimeout then
    Log("ERR - PlayerListItem:OnPlayerIdentificationFailed: Timed Out, category: " .. tostring(self.category) .. ", key: " .. tostring(self.listKey))
  end
end
function PlayerListItem:OnPlayerIdentificationReady(result)
  local playerId
  if 0 < #result then
    playerId = result[1].playerId
  else
    Log("ERR - PlayerListItem:OnPlayerIdentificationReady: Player not found, category: " .. tostring(self.category) .. ", key: " .. tostring(self.listKey))
    return
  end
  if playerId then
    self:SetPlayerId(playerId)
  end
end
function PlayerListItem:OnRemotePlayerOnlineStatusFailed(reason)
  if reason == eSocialRequestFailureReasonThrottled then
    Log("ERR - PlayerListItem:OnRemotePlayerOnlineStatusFailed: Throttled, category: " .. tostring(self.category) .. ", key: " .. tostring(self.listKey))
  elseif reason == eSocialRequestFailureReasonTimeout then
    Log("ERR - PlayerListItem:OnRemotePlayerOnlineStatusFailed: Timed Out, category: " .. tostring(self.category) .. ", key: " .. tostring(self.listKey))
  end
end
function PlayerListItem:OnRemotePlayerOnlineStatusReady(result)
  if 0 < #result then
    self.isOnline = result[1].isOnline
    self:UpdateOnlineStatusUI()
  else
    Log("ERR - PlayerListItem:OnRemotePlayerOnlineStatusReady: Player not found, category: " .. tostring(self.category) .. ", key: " .. tostring(self.listKey))
    return
  end
end
function PlayerListItem:OnRemotePlayerFactionFailed(reason)
  if reason == eSocialRequestFailureReasonThrottled then
    Log("ERR - PlayerListItem:OnRemotePlayerFactionFailed: Throttled, category: " .. tostring(self.category) .. ", key: " .. tostring(self.listKey))
  elseif reason == eSocialRequestFailureReasonTimeout then
    Log("ERR - PlayerListItem:OnRemotePlayerFactionFailed: Timed Out, category: " .. tostring(self.category) .. ", key: " .. tostring(self.listKey))
  end
end
function PlayerListItem:OnRemotePlayerFactionReady(result)
  if 0 < #result then
    self.playerFaction = result[1].playerFaction
  else
    Log("ERR - PlayerListItem:OnRemotePlayerFactionReady: Player not found, category: " .. tostring(self.category) .. ", key: " .. tostring(self.listKey))
    return
  end
  self:UpdateButtonVisibility()
end
function PlayerListItem:SetData(data, parentTable)
  self.parentTable = parentTable
  self.isOnline = data.isOnline
  self.notificationId = data.notificationId
  self.guildId = data.guildId
  self.guildName = data.guildName
  self.playerName = data.playerName
  self.category = data.category
  self.isWarInvite = data.isWarInvite
  self.isPvPInvite = data.isPvPInvite
  self.isGameModeInvite = data.isGameModeInvite
  self.warId = data.warId
  self.gameModeId = data.gameModeId
  self.playerFaction = data.playerFaction
  self:SetButtons(data.buttonData)
  self:SetGuildCrest(data.guildCrest)
  if not data.playerId and not self.isWarInvite and not self.isGameModeInvite then
    local ready = false
    if data.characterId then
      ready = self.socialDataHandler:GetPlayerIdentification_ServerCall(self, self.OnPlayerIdentificationReady, self.OnPlayerIdentificationFailed, data.characterId)
    elseif data.playerName then
      ready = self.socialDataHandler:GetPlayerIdentificationByName_ServerCall(self, self.OnPlayerIdentificationReady, self.OnPlayerIdentificationFailed, data.playerName)
    else
      return
    end
    if not ready then
      UiElementBus.Event.SetIsEnabled(self.CustomButton, false)
      UiElementBus.Event.SetIsEnabled(self.AcceptButton, false)
      UiElementBus.Event.SetIsEnabled(self.RejectButton, false)
    end
  else
    self:SetPlayerId(data.playerId)
  end
end
function PlayerListItem:SetPlayerId(playerId)
  if playerId and not self.isWarInvite and not self.isGameModeInvite then
    self.playerId = playerId
    UiTextBus.Event.SetText(self.PlayerName, playerId.playerName)
    self.PlayerIcon:SetPlayerId(self.playerId)
    if self.guildName then
      self:SetGuildName()
    else
      self:UpdateOnlineStatus()
    end
    self:UpdateFaction()
  elseif self.isWarInvite then
    self.playerId = SimplePlayerIdentification()
    self.PlayerIcon:SetFlyoutEnabled(false)
    self.ScriptedEntityTweener:Set(self.OnlineIndicator, {opacity = 0})
    local warIconPath = "lyshineui/Images/Icons/Misc/icon_warBig.dds"
    self.PlayerIcon:SetSimpleIcon(warIconPath)
    local warDetails = WarDataClientRequestBus.Broadcast.GetWarDetails(self.warId)
    local inviteText = GetLocalizedReplacementText(warDetails:IsInvasion() and "@ui_invasion_invite_title" or "@ui_war_invite_title", {
      territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(warDetails:GetTerritoryId())
    })
    UiTextBus.Event.SetTextWithFlags(self.PlayerName, inviteText, eUiTextSet_SetAsIs)
    local siegeStartTime = warDetails:GetWarEndTime():Subtract(WallClockTimePoint()):ToSecondsRoundedUp() - WarRequestBus.Broadcast.GetWarPhaseDuration(eWarPhase_Resolution):ToSeconds() - WarRequestBus.Broadcast.GetWarPhaseDuration(eWarPhase_Conquest):ToSeconds()
    local statusText = timeHelpers:GetLocalizedDateTime(siegeStartTime, true)
    self:SetWarStatus(statusText)
  elseif self.isGameModeInvite then
    self.playerId = SimplePlayerIdentification()
    self.PlayerIcon:SetFlyoutEnabled(false)
    self.ScriptedEntityTweener:Set(self.OnlineIndicator, {opacity = 0})
    if self.gameModeId == GameModeCommon.GAMEMODE_OUTPOST_RUSH then
      local outpostRushIconPath = "lyshineui/Images/Icons/OutpostRush/icon_outpostRush_npc.dds"
      self.PlayerIcon:SetSimpleIcon(outpostRushIconPath)
      UiTextBus.Event.SetTextWithFlags(self.PlayerName, "@ui_outpost_rush_title", eUiTextSet_SetLocalized)
      UiTextBus.Event.SetTextWithFlags(self.PlayerStatus, "@ui_outpost_rush_invite_status", eUiTextSet_SetLocalized)
    end
  end
  self:UpdateButtonVisibility()
end
function PlayerListItem:RequestPlayerLevel()
  if self.PlayerIcon then
    self.PlayerIcon:RequestPlayerLevel()
  end
end
function PlayerListItem:OnLastUpdatedPlayer(playerId)
  if self.playerId and playerId:GetCharacterIdString() == self.playerId:GetCharacterIdString() and playerId.playerName ~= self.playerId.playerName then
    self.playerId = playerId
    UiTextBus.Event.SetText(self.PlayerName, playerId.playerName)
    self.PlayerIcon.playerId = playerId
    self.parentTable:UpdatePlayerNameKey(self.listKey, playerId.playerName, self.category)
  end
end
function PlayerListItem:UpdateButtonVisibility()
  local isSameFaction = self.playerFaction == self.localPlayerFaction
  local canInvite = self.openReason == "GroupInvite" and (not self.isPvpFlaggedOrPending or isSameFaction) or self.openReason == "GuildInvite" and self.playerFaction ~= eFactionType_None and isSameFaction
  local showErrorMessage = not canInvite and (self.openReason == "GroupInvite" or self.openReason == "GuildInvite")
  if showErrorMessage then
    if self.openReason == "GuildInvite" then
      if self.playerFaction == eFactionType_None then
        UiTextBus.Event.SetTextWithFlags(self.Properties.ErrorMessage, "@ui_nofaction_invite_error", eUiTextSet_SetLocalized)
      else
        UiTextBus.Event.SetTextWithFlags(self.Properties.ErrorMessage, "@ui_faction_invite_error", eUiTextSet_SetLocalized)
      end
    elseif self.openReason == "GroupInvite" then
      UiTextBus.Event.SetTextWithFlags(self.Properties.ErrorMessage, "@ui_faction_invite_error_pvp_group", eUiTextSet_SetLocalized)
    end
  end
  if self.category == "GroupInvite" and not self.isWarInvite and not self.isGameModeInvite then
    local canAccept = self.isPvPInvite == self.isPvpFlaggedOrPending
    local tooltip
    if not canAccept then
      tooltip = self.isPvPInvite and "@ui_acceptgroupinviteblocked_pvp" or "@ui_acceptgroupinviteblocked_pve"
    end
    self.acceptButtonDisabled = not canAccept
    self.AcceptButtonTooltip:SetSimpleTooltip(tooltip)
    local opacity = canAccept and 0.7 or self.acceptButtonDisabledOpacity
    self.ScriptedEntityTweener:Stop(self.Properties.AcceptButton)
    self.ScriptedEntityTweener:Set(self.Properties.AcceptButton, {opacity = opacity})
  else
    self.acceptButtonDisabled = false
    self.AcceptButtonTooltip:SetSimpleTooltip(nil)
    self.ScriptedEntityTweener:Stop(self.Properties.AcceptButton)
    self.ScriptedEntityTweener:Set(self.Properties.AcceptButton, {opacity = 0.7})
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.CustomButton, canInvite and self.customCallback ~= nil)
  UiElementBus.Event.SetIsEnabled(self.Properties.AcceptButton, self.acceptCallback ~= nil)
  UiElementBus.Event.SetIsEnabled(self.Properties.RejectButton, self.rejectCallback ~= nil)
  UiElementBus.Event.SetIsEnabled(self.Properties.ErrorMessage, showErrorMessage)
end
function PlayerListItem:SetButtons(buttonData)
  self.customCallback = nil
  self.acceptCallback = nil
  self.rejectCallback = nil
  self.openReason = nil
  if buttonData then
    if buttonData.customCallback and buttonData.customLocText then
      self.customCallback = buttonData.customCallback
      if buttonData.openReason then
        self.openReason = buttonData.openReason
      end
      self:OnButtonHoverEnd(self.CustomButton)
      UiTextBus.Event.SetTextWithFlags(self.CustomButtonText, buttonData.customLocText, eUiTextSet_SetLocalized)
    elseif buttonData.acceptCallback and buttonData.rejectCallback then
      self.acceptCallback = buttonData.acceptCallback
      self.rejectCallback = buttonData.rejectCallback
      self:OnButtonHoverEnd(self.AcceptButton)
      self:OnButtonHoverEnd(self.RejectButton)
    end
  end
  self:UpdateButtonVisibility()
end
function PlayerListItem:SetIsOnline(isOnline)
  self.isOnline = isOnline
  self:UpdateOnlineStatus()
end
function PlayerListItem:SetGuildId(newGuildId)
  self.guildId = newGuildId
end
function PlayerListItem:SetGuildName(newGuildName)
  if newGuildName then
    self.guildName = newGuildName
  end
  if self.guildName then
    UiTextBus.Event.SetText(self.PlayerStatus, self.guildName)
    self.ScriptedEntityTweener:Set(self.PlayerStatus, {
      textColor = self.UIStyle.COLOR_TAN_LIGHT
    })
  end
end
function PlayerListItem:SetWarStatus(statusText)
  UiTextBus.Event.SetText(self.PlayerStatus, statusText)
  self.ScriptedEntityTweener:Set(self.PlayerStatus, {
    textColor = self.UIStyle.COLOR_TAN_LIGHT
  })
end
function PlayerListItem:SetGuildCrest(newGuildCrest)
  if self.guildCrest ~= newGuildCrest then
    self.guildCrest = newGuildCrest
  end
  if self.guildCrest then
    self.GuildCrest:SetSmallIcon(self.guildCrest)
  end
  UiElementBus.Event.SetIsEnabled(self.GuildCrest.entityId, self.guildCrest ~= nil)
end
function PlayerListItem:UpdateOnlineStatus()
  if self.isOnline == nil then
    self.socialDataHandler:GetRemotePlayerOnlineStatus_ServerCall(self, self.OnRemotePlayerOnlineStatusReady, self.OnRemotePlayerOnlineStatusFailed, self.playerId:GetCharacterIdString())
    return
  end
  self:UpdateOnlineStatusUI()
end
function PlayerListItem:UpdateOnlineStatusUI()
  UiTextBus.Event.SetTextWithFlags(self.PlayerStatus, self.isOnline and "@ui_online" or "@ui_offline", eUiTextSet_SetLocalized)
  local targetColor = self.isOnline and self.UIStyle.COLOR_GREEN or self.UIStyle.COLOR_RED
  self.ScriptedEntityTweener:Set(self.PlayerStatus, {textColor = targetColor})
  self.ScriptedEntityTweener:Set(self.OnlineIndicator, {opacity = 1, imgColor = targetColor})
  if self.category == "Friend" then
    self.parentTable:UpdateFriendOnlineStatus(self.playerId:GetCharacterIdString(), self.isOnline)
  elseif self.category == "Matching" then
    self.parentTable:UpdateListItemButtons(self, self.isOnline)
  end
end
function PlayerListItem:UpdateFaction()
  self.playerFaction = eFactionType_None
  self.socialDataHandler:GetRemotePlayerFaction_ServerCall(self, self.OnRemotePlayerFactionReady, self.OnRemotePlayerFactionFailed, self.playerId:GetCharacterIdString())
end
function PlayerListItem:OnButtonHoverStart(entityId, actionName)
  if entityId == self.Properties.AcceptButton and self.acceptButtonDisabled then
    self.AcceptButtonTooltip:OnTooltipSetterHoverStart()
    return
  end
  self.ScriptedEntityTweener:Play(entityId, 0.18, {opacity = 1, ease = "QuadOut"})
  if entityId == self.Properties.CustomButton then
    self.ScriptedEntityTweener:Set(self.Properties.CustomButtonText, {
      textColor = self.UIStyle.COLOR_WHITE
    })
    self.ScriptedEntityTweener:Set(self.Properties.CustomButtonIcon, {
      imgColor = self.UIStyle.COLOR_WHITE
    })
  end
end
function PlayerListItem:OnButtonHoverEnd(entityId, actionName)
  local opacity = 0.7
  if entityId == self.Properties.AcceptButton then
    if self.acceptButtonDisabled then
      opacity = self.acceptButtonDisabledOpacity
    end
    self.AcceptButtonTooltip:OnTooltipSetterHoverEnd()
  end
  self.ScriptedEntityTweener:Play(entityId, 0.11, {opacity = opacity, ease = "QuadOut"})
  if entityId == self.Properties.CustomButton then
    self.ScriptedEntityTweener:Set(self.Properties.CustomButtonText, {
      textColor = self.UIStyle.COLOR_TAN
    })
    self.ScriptedEntityTweener:Set(self.Properties.CustomButtonIcon, {
      imgColor = self.UIStyle.COLOR_TAN
    })
  end
end
function PlayerListItem:PlayButtonSelect(entityId)
  self.ScriptedEntityTweener:Play(entityId, 0.21, {opacity = 0.85}, {opacity = 0.2, ease = "QuadOut"})
end
function PlayerListItem:OnAcceptSelect(entityId, actionName)
  if self.acceptButtonDisabled then
    return
  end
  self:PlayButtonSelect(self.AcceptButton)
  self.audioHelper:PlaySound(self.audioHelper.Accept)
  if self.acceptCallback ~= nil then
    local callbackParam = self.playerId
    if self.guildId then
      callbackParam = self.guildId
    end
    self.parentTable[self.acceptCallback](self.parentTable, callbackParam)
  end
end
function PlayerListItem:OnRejectSelect(entityId, actionName)
  self:PlayButtonSelect(self.RejectButton)
  self.audioHelper:PlaySound(self.audioHelper.Cancel)
  if self.rejectCallback ~= nil then
    local callbackParam = self.playerId
    if self.guildId then
      callbackParam = self.guildId
    end
    self.parentTable[self.rejectCallback](self.parentTable, callbackParam)
  end
end
function PlayerListItem:OnCustomSelect(entityId, actionName)
  self:PlayButtonSelect(self.CustomButton)
  self.audioHelper:PlaySound(self.audioHelper.Accept)
  if self.customCallback ~= nil then
    self.parentTable[self.customCallback](self.parentTable, self.playerId)
  end
end
return PlayerListItem
