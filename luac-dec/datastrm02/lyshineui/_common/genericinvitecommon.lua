local GenericInviteCommon = {
  duelCrc = 2612307810,
  tradeCrc = 2115650406,
  activityData = {
    default = {},
    [2612307810] = {
      icon = "lyshineui/images/icons/misc/icon_duel.dds"
    }
  },
  groupConfirmationPopupId = "GroupConfirmationPopupId"
}
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
function GenericInviteCommon:RequestReplyToInvite(accept)
  local rootEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  PlayerGenericInviteComponentRequestBus.Event.RequestReplyToInvite(rootEntityId, accept)
end
function GenericInviteCommon:RequestSendNewInvite(activityCrc, forwardType, characterId, notificationTitle)
  local inviteRequest = GenericInviteRequest()
  inviteRequest.activityCrc = activityCrc
  inviteRequest.forwardType = forwardType
  inviteRequest.targetCharacterIdString = characterId
  local rootEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  PlayerGenericInviteComponentRequestBus.Event.RequestSendNewInvite(rootEntityId, inviteRequest)
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = notificationTitle
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function GenericInviteCommon:RequestSendNewDuelInvite(characterId)
  local showGroupConfirmation = false
  if not LocalGroupRequestBus.Broadcast.IsGroupMate(characterId) then
    local localPlayerGroupId = dataLayer:GetDataFromNode("Hud.LocalPlayer.Group.Id")
    local localPlayerIsInGroup = localPlayerGroupId and localPlayerGroupId:IsValid()
    local remotePlayerGroupId = GroupsRequestBus.Broadcast.GetRemotePlayerGroupId(characterId)
    local remotePlayerIsInGroup = remotePlayerGroupId and remotePlayerGroupId:IsValid()
    showGroupConfirmation = localPlayerIsInGroup or remotePlayerIsInGroup
  end
  if showGroupConfirmation then
    PopupWrapper:RequestPopupWithParams({
      title = "@ui_duel_group_popup_title",
      message = "@ui_duel_group_popup_message",
      eventId = self.groupConfirmationPopupId,
      callerSelf = self,
      callback = function(self, result, eventId)
        if eventId == self.groupConfirmationPopupId and (result == ePopupResult_Yes or result == ePopupResult_No) then
          local forwardType = result == ePopupResult_Yes and eForwardType_Group or eForwardType_Solo
          self:RequestSendNewInvite(2612307810, forwardType, characterId, "@ui_duel_notification_invite_sent")
        end
      end,
      buttonsYesNo = true,
      yesButtonText = "@ui_duel_group_popup_yes_button",
      noButtonText = "@ui_duel_group_popup_no_button"
    })
  else
    self:RequestSendNewInvite(2612307810, eForwardType_Solo, characterId, "@ui_duel_notification_invite_sent")
  end
end
function GenericInviteCommon:ValidateEligibility(activityCrc, remotePlayerId)
  local rootEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  local playerPosition = dataLayer:GetDataFromNode("Hud.LocalPlayer.Position")
  local inviteStaticData = PlayerGenericInviteComponentRequestBus.Event.GetInviteStaticData(rootEntityId, activityCrc)
  local localPlayerResult = PlayerGenericInviteComponentRequestBus.Event.ValidateEligibilityByEntityId(rootEntityId, activityCrc, playerPosition, rootEntityId)
  if localPlayerResult ~= eGenericInviteEligibility_Success then
    return false, self:GetEligibilityErrorMessage(activityCrc, localPlayerResult, nil, inviteStaticData.minLevel, inviteStaticData.maxDistance)
  end
  if remotePlayerId then
    local remotePlayerCharacterIdString = remotePlayerId:GetCharacterIdString()
    local isBlocked = JavSocialComponentBus.Broadcast.IsPlayerBlocked(remotePlayerCharacterIdString)
    local isMuted = ChatComponentBus.Broadcast.IsPlayerMuted(remotePlayerCharacterIdString)
    if isBlocked or isMuted then
      local message
      if activityCrc == self.tradeCrc then
        message = "@ui_p2ptrading_failmessage_blocked"
      elseif activityCrc == self.duelCrc then
        message = "@ui_duel_failmessage_blocked"
      end
      return false, message
    end
    local remotePlayerResult = PlayerGenericInviteComponentRequestBus.Event.ValidateEligibilityByCharacterId(rootEntityId, activityCrc, playerPosition, remotePlayerCharacterIdString)
    if remotePlayerResult ~= eGenericInviteEligibility_Success then
      return false, self:GetEligibilityErrorMessage(activityCrc, remotePlayerResult, remotePlayerId.playerName, inviteStaticData.minLevel, inviteStaticData.maxDistance)
    end
  end
  return true
end
function GenericInviteCommon:GetEligibilityErrorMessage(activityCrc, result, otherPlayerName, minLevelRequirement, distanceRequirement)
  if activityCrc == self.duelCrc then
    return self:GetDuelEligibilityErrorMessage(result, otherPlayerName, minLevelRequirement, distanceRequirement)
  end
  if activityCrc == self.tradeCrc then
    return self:GetTradeEligibilityErrorMessage(result, otherPlayerName, minLevelRequirement, distanceRequirement)
  end
end
function GenericInviteCommon:GetDuelEligibilityErrorMessage(result, otherPlayerName, minLevelRequirement, distanceRequirement)
  local isLocalPlayer = not otherPlayerName
  if result == eGenericInviteEligibility_Failed_Offline then
    return GetLocalizedReplacementText("@ui_duel_failmessage_target_notonline", {playerName = otherPlayerName})
  elseif result == eGenericInviteEligibility_Failed_Blocked then
    return "@ui_duel_failmessage_blocked"
  elseif result == eGenericInviteEligibility_Failed_GameMode then
    if isLocalPlayer then
      local rootPlayerId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
      local isInDuel = GameModeParticipantComponentRequestBus.Event.IsInGameMode(rootPlayerId, 2612307810)
      if isInDuel then
        return "@ui_duel_failmessage_alreadyinduel"
      else
        local dungeonGameModeId = GameModeParticipantComponentRequestBus.Event.GetCurrentDungeonGameModeId(rootPlayerId)
        if dungeonGameModeId ~= 0 then
          return "@ui_duel_failmessage_in_dungeon"
        else
          return "@ui_duel_failmessage_in_other_gamemode"
        end
      end
    else
      return GetLocalizedReplacementText("@ui_duel_failmessage_target_induel", {playerName = otherPlayerName})
    end
  elseif result == eGenericInviteEligibility_Failed_Dead then
    if isLocalPlayer then
      return "@ui_duel_failmessage_dead"
    else
      return GetLocalizedReplacementText("@ui_duel_failmessage_target_dead", {playerName = otherPlayerName})
    end
  elseif result == eGenericInviteEligibility_Failed_PendingInvite then
    if isLocalPlayer then
      return "@ui_duel_failmessage_pendinginvite"
    else
      return GetLocalizedReplacementText("@ui_duel_failmessage_target_pendinginvite", {playerName = otherPlayerName})
    end
  elseif result == eGenericInviteEligibility_Failed_Sanctuary then
    if isLocalPlayer then
      return "@ui_duel_failmessage_sanctuary"
    else
      return GetLocalizedReplacementText("@ui_duel_failmessage_target_sanctuary", {playerName = otherPlayerName})
    end
  elseif result == eGenericInviteEligibility_Failed_Event then
    if isLocalPlayer then
      return "@ui_duel_failmessage_event"
    else
      return GetLocalizedReplacementText("@ui_duel_failmessage_target_event", {playerName = otherPlayerName})
    end
  elseif result == eGenericInviteEligibility_Failed_Level then
    if isLocalPlayer then
      return GetLocalizedReplacementText("@ui_duel_failmessage_level", {level = minLevelRequirement})
    else
      return GetLocalizedReplacementText("@ui_duel_failmessage_target_level", {playerName = otherPlayerName, level = minLevelRequirement})
    end
  elseif result == eGenericInviteEligibility_Failed_Distance then
    return GetLocalizedReplacementText("@ui_duel_failmessage_outofrange", {distance = distanceRequirement})
  elseif result == eGenericInviteEligibility_Failed_FastTravelChanneling then
    return "@ui_duel_failmessage_fasttravelchanneling"
  end
  if isLocalPlayer then
    return "@ui_duel_failmessage_generic"
  else
    return GetLocalizedReplacementText("@ui_duel_failmessage_target_generic", {playerName = otherPlayerName})
  end
end
function GenericInviteCommon:GetTradeEligibilityErrorMessage(result, otherPlayerName, minLevelRequirement, distanceRequirement)
  local isLocalPlayer = not otherPlayerName
  if result == eGenericInviteEligibility_Failed_Offline then
    return GetLocalizedReplacementText("@ui_p2ptrading_failmessage_target_notonline", {playerName = otherPlayerName})
  elseif result == eGenericInviteEligibility_Failed_Blocked then
    return "@ui_p2ptrading_failmessage_blocked"
  elseif result == eGenericInviteEligibility_Failed_GameMode then
    if isLocalPlayer then
      return "@ui_p2ptrading_failmessage_alreadyintrade"
    else
      return GetLocalizedReplacementText("@ui_p2ptrading_failmessage_target_intrade", {playerName = otherPlayerName})
    end
  elseif result == eGenericInviteEligibility_Failed_Dead then
    if isLocalPlayer then
      return "@ui_p2ptrading_failmessage_dead"
    else
      return GetLocalizedReplacementText("@ui_p2ptrading_failmessage_target_dead", {playerName = otherPlayerName})
    end
  elseif result == eGenericInviteEligibility_Failed_PendingInvite then
    if isLocalPlayer then
      return "@ui_p2ptrading_failmessage_pendinginvite"
    else
      return GetLocalizedReplacementText("@ui_p2ptrading_failmessage_target_pendinginvite", {playerName = otherPlayerName})
    end
  elseif result == eGenericInviteEligibility_Failed_Event then
    if isLocalPlayer then
      return "@ui_p2ptrading_failmessage_event"
    else
      return GetLocalizedReplacementText("@ui_p2ptrading_failmessage_target_event", {playerName = otherPlayerName})
    end
  elseif result == eGenericInviteEligibility_Failed_Level then
    if isLocalPlayer then
      return GetLocalizedReplacementText("@ui_p2ptrading_failmessage_level", {level = minLevelRequirement})
    else
      return GetLocalizedReplacementText("@ui_p2ptrading_failmessage_target_level", {playerName = otherPlayerName, level = minLevelRequirement})
    end
  elseif result == eGenericInviteEligibility_Failed_Distance then
    return GetLocalizedReplacementText("@ui_p2ptrading_failmessage_outofrange", {distance = distanceRequirement})
  elseif result == eGenericInviteEligibility_Failed_FastTravelChanneling then
    return "@ui_p2ptrading_failmessage_fasttravelchanneling"
  end
  if isLocalPlayer then
    return "@ui_p2ptrading_failmessage_generic"
  else
    return GetLocalizedReplacementText("@ui_p2ptrading_failmessage_target_generic", {playerName = otherPlayerName})
  end
end
function GenericInviteCommon:GetGenericInviteNotificationData(activityCrc, forwardType, playerName, isGroupMate)
  if activityCrc == self.duelCrc then
    return self:GetDuelGenericInviteNotificationData(activityCrc, forwardType, playerName, isGroupMate)
  end
  if activityCrc == self.tradeCrc then
    return self:GetTradeGenericInviteNotificationData(activityCrc, playerName)
  end
end
function GenericInviteCommon:GetDuelGenericInviteNotificationData(activityCrc, forwardType, playerName, isGroupMate)
  local title, locTag
  if forwardType == eForwardType_Solo then
    title = "@ui_duel_invite_notification_title"
    locTag = "@ui_duel_invite_notification_text"
  else
    title = "@ui_duel_invite_group_notification_title"
    locTag = isGroupMate and "@ui_duel_invite_own_group_notification_text" or "@ui_duel_invite_other_group_notification_text"
  end
  local text = GetLocalizedReplacementText(locTag, {playerName = playerName})
  local icon
  local activityData = self.activityData[activityCrc]
  if activityData then
    icon = activityData.icon
  end
  return title, text, icon
end
function GenericInviteCommon:GetTradeGenericInviteNotificationData(activityCrc, playerName)
  local title = "@ui_p2ptrading_invite_notification_title"
  local locTag = "@ui_p2ptrading_invite_notification_text"
  local text = GetLocalizedReplacementText(locTag, {playerName = playerName})
  local icon
  local activityData = self.activityData[activityCrc]
  if activityData then
    icon = activityData.icon
  end
  return title, text, icon
end
function GenericInviteCommon:HandleInviteFailed(reason)
  local activityCrc = dataLayer:GetDataFromNode("Hud.LocalPlayer.GenericInvite.ActivityCrc")
  local isDuel = activityCrc == self.duelCrc
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  if reason == eGenericInviteEnd_Eligibility_Failed then
    notificationData.text = isDuel and "@ui_duel_failmessage_eligibility_failed" or "@ui_p2ptrading_failmessage_eligibility_failed"
  elseif reason == eGenericInviteEnd_System_Error then
    notificationData.text = isDuel and "@ui_duel_failmessage_system_error" or "@ui_p2ptrading_failmessage_system_error"
  elseif reason == eGenericInviteEnd_Cancelled then
    notificationData.text = isDuel and "@ui_duel_failmessage_cancelled" or "@ui_p2ptrading_failmessage_cancelled"
  elseif reason == eGenericInviteEnd_Participant_Blocked then
    notificationData.text = isDuel and "@ui_duel_failmessage_blocked" or "@ui_p2ptrading_failmessage_blocked"
  elseif reason == eGenericInviteEnd_Participant_FastTravel_Channeling then
    notificationData.text = isDuel and "@ui_duel_failmessage_fasttravelchanneling" or "@ui_p2ptrading_failmessage_fasttravelchanneling"
  elseif reason == eGenericInviteEnd_Insufficient_Participants then
    notificationData.text = isDuel and "@ui_duel_failmessage_declined" or "@ui_p2ptrading_failmessage_declined"
  else
    notificationData.text = isDuel and "@ui_duel_failmessage_system_error" or "@ui_p2ptrading_failmessage_system_error"
  end
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
return GenericInviteCommon
