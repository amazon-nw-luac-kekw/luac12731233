local SocialDataHandler = {}
function SocialDataHandler:OnActivate()
  if not self.socialDataNotificationHandler then
    self.socialDataNotificationHandler = SocialDataNotificationsBus.Connect(self)
    self.guildDataNotificationHandler = GuildDataNotificationsBus.Connect(self)
    self.callbacks = {}
  end
end
function SocialDataHandler:OnDeactivate()
end
function SocialDataHandler:Reset()
  local clearCallbacks = false
  if self.socialDataNotificationHandler then
    self.socialDataNotificationHandler:Disconnect()
    self.socialDataNotificationHandler = nil
    clearCallbacks = true
  end
  if self.guildDataNotificationHandler then
    self.guildDataNotificationHandler:Disconnect()
    self.guildDataNotificationHandler = nil
    clearCallbacks = true
  end
  if clearCallbacks then
    ClearTable(self.callbacks)
  end
end
function SocialDataHandler:AddCallback(requestId, cb)
  if not self.callbacks[tostring(requestId)] then
    self.callbacks[tostring(requestId)] = {cb}
  else
    table.insert(self.callbacks[tostring(requestId)], cb)
  end
end
function SocialDataHandler:GetPlayers_ServerCall(callingSelf, cb, failedCb, characterIdStrings)
  if self.getPlayersRequestId then
    failedCb(callingSelf, eSocialRequestFailureReasonThrottled)
    return
  end
  self.pendingGetPlayersRequest = {
    callingSelf = callingSelf,
    cb = cb,
    failedCb = failedCb
  }
  self.pendingGetPlayersResults = {}
  local missingCharacterIdStrings = vector_basic_string_char_char_traits_char()
  for i = 1, #characterIdStrings do
    local characterIdString = characterIdStrings[i]
    local cached = JavSocialComponentBus.Broadcast.IsPlayerCached(characterIdString)
    if not cached then
      missingCharacterIdStrings:push_back(characterIdString)
    else
      local simplePlayerId = JavSocialComponentBus.Broadcast.GetCachedPlayerIdentification(characterIdString)
      table.insert(self.pendingGetPlayersResults, simplePlayerId)
    end
  end
  if 0 < #missingCharacterIdStrings then
    self:RequestGetPlayers_ServerCall(self, self.OnGetPlayersSuccess, self.OnGetPlayersFailed, missingCharacterIdStrings)
  else
    self:OnGetPlayersFailed(nil)
  end
end
function SocialDataHandler:OnGetPlayersSuccess(results)
  for i = 1, #results do
    local playerDataView = results[i]
    table.insert(self.pendingGetPlayersResults, playerDataView.playerId)
  end
  local pendingRequest = self.pendingGetPlayersRequest
  pendingRequest.cb(pendingRequest.callingSelf, self.pendingGetPlayersResults)
  self.getPlayersRequestId = nil
  self.pendingGetPlayersRequest = {}
  self.pendingGetPlayersResults = {}
end
function SocialDataHandler:OnGetPlayersFailed(reason)
  local pendingRequest = self.pendingGetPlayersRequest
  pendingRequest.failedCb(pendingRequest.callingSelf, reason, self.pendingGetPlayersResults)
  self.getPlayersRequestId = nil
  self.pendingGetPlayersRequest = {}
  self.pendingGetPlayersResults = {}
end
function SocialDataHandler:RequestGetPlayers_ServerCall(callingSelf, cb, failedCb, characterIdStrings)
  self.getPlayersRequestId = JavSocialComponentBus.Broadcast.RequestGetPlayers_ServerCall(characterIdStrings)
  self:AddCallback(self.getPlayersRequestId, {
    callingSelf = callingSelf,
    cb = cb,
    failedCb = failedCb
  })
end
function SocialDataHandler:RequestSearchPlayers_ServerCall(callingSelf, cb, failedCb, prefix, maxResults)
  local requestId = JavSocialComponentBus.Broadcast.RequestSearchPlayers_ServerCall(prefix, maxResults)
  self:AddCallback(requestId, {
    callingSelf = callingSelf,
    cb = cb,
    failedCb = failedCb
  })
end
function SocialDataHandler:GetPlayerIdentification_ServerCall(callingSelf, cb, failedCb, characterId)
  local asyncResult = JavSocialComponentBus.Broadcast.GetPlayerIdentification_ServerCall(characterId)
  if asyncResult.dataReady then
    local resultTable = {}
    resultTable[1] = {
      playerId = asyncResult.data:Clone()
    }
    cb(callingSelf, resultTable)
    return true
  else
    local requestId = asyncResult.dataRequestId:Clone()
    self:AddCallback(requestId, {
      callingSelf = callingSelf,
      cb = cb,
      failedCb = failedCb
    })
    return false
  end
end
function SocialDataHandler:GetPlayerIdentificationByName_ServerCall(callingSelf, cb, failedCb, playerName)
  local asyncResult = JavSocialComponentBus.Broadcast.GetPlayerIdentificationByName_ServerCall(playerName)
  if asyncResult.dataReady then
    local resultTable = {}
    resultTable[1] = {
      playerId = asyncResult.data:Clone()
    }
    cb(callingSelf, resultTable)
    return true
  else
    local requestId = asyncResult.dataRequestId:Clone()
    self:AddCallback(requestId, {
      callingSelf = callingSelf,
      cb = cb,
      failedCb = failedCb
    })
    return false
  end
end
function SocialDataHandler:GetRemotePlayerIconData_ServerCall(callingSelf, cb, failedCb, characterIdString)
  local asyncResult = JavSocialComponentBus.Broadcast.GetRemotePlayerIconData_ServerCall(characterIdString)
  if asyncResult.dataReady then
    local resultTable = {}
    resultTable[1] = {
      playerIcon = asyncResult.data:Clone()
    }
    cb(callingSelf, resultTable)
    return true
  else
    local requestId = asyncResult.dataRequestId:Clone()
    self:AddCallback(requestId, {
      callingSelf = callingSelf,
      cb = cb,
      failedCb = failedCb
    })
    return false
  end
end
function SocialDataHandler:GetRemotePlayerLevelData_ServerCall(callingSelf, cb, failedCb, characterIdString)
  local asyncResult = JavSocialComponentBus.Broadcast.GetRemotePlayerLevelData_ServerCall(characterIdString)
  if asyncResult.dataReady then
    local resultTable = {}
    resultTable[1] = {
      playerLevel = asyncResult.dataCopy
    }
    cb(callingSelf, resultTable)
    return true
  else
    local requestId = asyncResult.dataRequestId:Clone()
    self:AddCallback(requestId, {
      callingSelf = callingSelf,
      cb = cb,
      failedCb = failedCb
    })
    return false
  end
end
function SocialDataHandler:GetRemotePlayerOnlineStatus_ServerCall(callingSelf, cb, failedCb, characterIdString)
  local asyncResult = JavSocialComponentBus.Broadcast.GetRemotePlayerOnlineStatus_ServerCall(characterIdString)
  if asyncResult.dataReady then
    local resultTable = {}
    resultTable[1] = {
      isOnline = asyncResult.dataCopy
    }
    cb(callingSelf, resultTable)
    return true
  else
    local requestId = asyncResult.dataRequestId:Clone()
    self:AddCallback(requestId, {
      callingSelf = callingSelf,
      cb = cb,
      failedCb = failedCb
    })
    return false
  end
end
function SocialDataHandler:GetRemotePlayerFaction_ServerCall(callingSelf, cb, failedCb, characterIdString)
  local asyncResult = JavSocialComponentBus.Broadcast.GetRemotePlayerFaction_ServerCall(characterIdString)
  if asyncResult.dataReady then
    local resultTable = {}
    resultTable[1] = {
      playerFaction = asyncResult.dataCopy
    }
    cb(callingSelf, resultTable)
    return true
  else
    local requestId = asyncResult.dataRequestId:Clone()
    self:AddCallback(requestId, {
      callingSelf = callingSelf,
      cb = cb,
      failedCb = failedCb
    })
    return false
  end
end
function SocialDataHandler:GetRemotePlayerGuildId_ServerCall(callingSelf, cb, failedCb, characterIdString)
  local asyncResult = JavSocialComponentBus.Broadcast.GetRemotePlayerGuildId_ServerCall(characterIdString)
  if asyncResult.dataReady then
    local resultTable = {}
    resultTable[1] = {
      playerGuildId = asyncResult.dataCopy
    }
    cb(callingSelf, resultTable)
    return true
  else
    local requestId = asyncResult.dataRequestId:Clone()
    self:AddCallback(requestId, {
      callingSelf = callingSelf,
      cb = cb,
      failedCb = failedCb
    })
    return false
  end
end
function SocialDataHandler:OnPlayerDataReceived(resultId, playerResults)
  self:ExecuteSocialDataHandlerCallback(resultId, playerResults)
end
function SocialDataHandler:RequestListGuildsByName_ServerCall(callingSelf, cb, failedCb, order, maxResults, pageKey)
  local requestId = GuildsComponentBus.Broadcast.RequestListGuildsByName_ServerCall(order, maxResults, pageKey)
  self:AddCallback(requestId, {
    callingSelf = callingSelf,
    cb = cb,
    failedCb = failedCb
  })
end
function SocialDataHandler:RequestListGuildsByMembers_ServerCall(callingSelf, cb, failedCb, order, maxResults, pageKey)
  local requestId = GuildsComponentBus.Broadcast.RequestListGuildsByMembers_ServerCall(order, maxResults, pageKey)
  self:AddCallback(requestId, {
    callingSelf = callingSelf,
    cb = cb,
    failedCb = failedCb
  })
end
function SocialDataHandler:RequestListGuildsByClaims_ServerCall(callingSelf, cb, failedCb, order, maxResults, pageKey)
  local requestId = GuildsComponentBus.Broadcast.RequestListGuildsByClaims_ServerCall(order, maxResults, pageKey)
  self:AddCallback(requestId, {
    callingSelf = callingSelf,
    cb = cb,
    failedCb = failedCb
  })
end
function SocialDataHandler:RequestGetGuilds_ServerCall(callingSelf, cb, failedCb, guildIds)
  local requestId = GuildsComponentBus.Broadcast.RequestGetGuilds_ServerCall(guildIds)
  self:AddCallback(requestId, {
    callingSelf = callingSelf,
    cb = cb,
    failedCb = failedCb
  })
end
function SocialDataHandler:RequestLandClaimScoreDataForGuild_ServerCall(callingSelf, cb, failedCb, guildId)
  local requestId = JavSocialComponentBus.Broadcast.RequestLandClaimScoreDataForGuild_ServerCall(guildId)
  self:AddCallback(requestId, {
    callingSelf = callingSelf,
    cb = cb,
    failedCb = failedCb
  })
end
function SocialDataHandler:RequestGuildNameAvailability_ServerCall(callingSelf, cb, failedCb, name)
  local requestId = GuildsComponentBus.Broadcast.RequestGuildNameAvailability_ServerCall(name)
  self:AddCallback(requestId, {
    callingSelf = callingSelf,
    cb = cb,
    failedCb = failedCb
  })
end
function SocialDataHandler:GetGuildDetailedData_ServerCall(callingSelf, cb, failedCb, guildId)
  local asyncResult = GuildsComponentBus.Broadcast.GetOtherGuildData_ServerCall(guildId)
  if asyncResult.dataReady then
    local resultTable = {}
    resultTable[1] = {
      guildData = asyncResult.data:Clone()
    }
    cb(callingSelf, resultTable)
    return true
  else
    local requestId = asyncResult.dataRequestId:Clone()
    self:AddCallback(requestId, {
      callingSelf = callingSelf,
      cb = cb,
      failedCb = failedCb
    })
    return false
  end
end
function SocialDataHandler:GetWarCost_ServerCall(callingSelf, cb, failedCb, guildId, warCampTier)
  warCampTier = warCampTier or 0
  local dataLayer = RequireScript("LyShineUI.UiDataLayer")
  local territoryId = dataLayer:GetDataFromNode("Hud.LocalPlayer.WarDeclarationPopup.TerritoryId")
  local asyncResult = GuildsComponentBus.Broadcast.GetOtherGuildData_ServerCall(guildId)
  if asyncResult.dataReady then
    local warDeclarationCost = WarRequestBus.Broadcast.GetWarDeclarationCost_PRIVATE(guildId, territoryId, warCampTier)
    local warId = WarDataClientRequestBus.Broadcast.GetWarId(guildId)
    cb(callingSelf, warDeclarationCost)
    return true
  else
    local requestId = asyncResult.dataRequestId:Clone()
    self:AddCallback(requestId, {
      callingSelf = callingSelf,
      cb = function(results)
        local warDeclarationCost = WarRequestBus.Broadcast.GetWarDeclarationCost_PRIVATE(guildId, territoryId, warCampTier)
        local warId = WarDataClientRequestBus.Broadcast.GetWarId(guildId)
        cb(callingSelf, warDeclarationCost, warCampTier)
      end,
      failedCb = failedCb
    })
    return false
  end
end
function SocialDataHandler:GetTreasuryData_ServerCall(callingSelf, cb, failedCb)
  local treasuryData = GuildsComponentBus.Broadcast.GetGuildTreasuryData()
  cb(callingSelf, treasuryData)
  return true
end
function SocialDataHandler:OnOtherGuildDataReceived(resultId, guildResults)
  self:ExecuteSocialDataHandlerCallback(resultId, guildResults)
end
function SocialDataHandler:OnOrderedOtherGuildDataReceived(resultId, guildResults, pageKey)
  self:ExecuteSocialDataHandlerCallback(resultId, guildResults, pageKey)
end
function SocialDataHandler:OnGuildNameAvailable(resultId, name, available)
  self:ExecuteSocialDataHandlerCallback(resultId, name, available)
end
function SocialDataHandler:OnWarsForGuildReceived(resultId, guildId, wars)
  self:ExecuteSocialDataHandlerCallback(resultId, guildId, wars)
end
function SocialDataHandler:OnLandClaimScoreDataForGuildReceived(resultId, guildId, scoreData)
  self:ExecuteSocialDataHandlerCallback(resultId, guildId, scoreData)
end
function SocialDataHandler:OnGuildTreasuryDataReceived(resultId, treasuryData)
  self:ExecuteSocialDataHandlerCallback(resultId, treasuryData)
end
function SocialDataHandler:OnDataRequestFailed(resultId, reason)
  self:ExecuteSocialDataHandlerErrorCallback(resultId, reason)
end
function SocialDataHandler:ExecuteSocialDataHandlerCallback(resultId, results, additionalData)
  local requestCallbacks = self.callbacks[tostring(resultId)]
  if requestCallbacks then
    for k, cbData in ipairs(requestCallbacks) do
      if type(cbData.cb) == "function" then
        cbData.cb(cbData.callingSelf, results, additionalData)
      end
    end
    self.callbacks[tostring(resultId)] = nil
  end
end
function SocialDataHandler:ExecuteSocialDataHandlerErrorCallback(resultId, reason)
  local requestCallbacks = self.callbacks[tostring(resultId)]
  if requestCallbacks then
    for k, cbData in ipairs(requestCallbacks) do
      if type(cbData.failedCb) == "function" then
        cbData.failedCb(cbData.callingSelf, reason)
      end
    end
    self.callbacks[tostring(resultId)] = nil
  end
end
return SocialDataHandler
