local DominionCommon = {
  preConquestTimeSeconds = 900,
  preWarDuration = nil,
  siegeDuration = nil
}
local style = RequireScript("LyShineUI._Common.UIStyle")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
DominionCommon.WarPhaseToData = {
  [eWarPhase_PreWar] = {
    color = style.COLOR_WAR_PHASE_SCOUTING,
    text = "@ui_warphase_scouting"
  },
  [eWarPhase_War] = {
    color = style.COLOR_WAR_PHASE_BATTLE,
    text = "@ui_warphase_battle"
  },
  [eWarPhase_Conquest] = {
    color = style.COLOR_WAR_PHASE_CONQUEST,
    text = "@ui_warphase_conquest"
  },
  [eWarPhase_Resolution] = {
    color = style.COLOR_WAR_PHASE_RESOLUTION,
    text = "@ui_warphase_resolution"
  },
  [eWarPhase_Complete] = {
    color = style.COLOR_WHITE,
    text = ""
  }
}
function IsAtWarWithGuild(guildId)
  return guildId and guildId:IsValid() and WarDataClientRequestBus.Broadcast.IsAtWarWithGuild(guildId)
end
function CanModifyWarWithGuild(guildId)
  if guildId and guildId:IsValid() then
    local warId = WarDataClientRequestBus.Broadcast.GetWarId(guildId)
    return WarRequestBus.Broadcast.CanModifyWar(warId)
  end
  return false
end
function DominionCommon:GetPreWarDuration()
  if not self.preWarDuration then
    self.preWarDuration = WarRequestBus.Broadcast.GetWarPhaseDuration(eWarPhase_PreWar):ToSeconds()
  end
  return self.preWarDuration
end
function DominionCommon:GetSiegeDuration()
  if not self.siegeDuration then
    self.siegeDuration = WarRequestBus.Broadcast.GetWarPhaseDuration(eWarPhase_Conquest):ToSeconds()
  end
  return self.siegeDuration
end
function DominionCommon:IsFriendlyWithRaid(raidId)
  if raidId and raidId:IsValid() then
    local myRaidId = dataLayer:GetDataFromNode("Hud.LocalPlayer.Raid.Id")
    if myRaidId and myRaidId:IsValid() then
      return myRaidId == raidId
    end
  end
  return false
end
function DominionCommon:IsAtWarWithRaid(raidId)
  if raidId and raidId:IsValid() then
    local myRaidId = dataLayer:GetDataFromNode("Hud.LocalPlayer.Raid.Id")
    if myRaidId and myRaidId:IsValid() then
      if myRaidId == raidId then
        return false
      end
      local warDetails = WarDataServiceBus.Broadcast.GetWarForRaid(raidId)
      if warDetails and warDetails:IsValid() and warDetails:IsWarActive() and (myRaidId == warDetails:GetAttackerRaidId() or myRaidId == warDetails:GetDefenderRaidId()) then
        return true
      end
    end
  end
  return false
end
function DominionCommon:GetWarDetailsFromGuildId(guildId)
  local warId = WarDataClientRequestBus.Broadcast.GetWarId(guildId)
  return WarDataClientRequestBus.Broadcast.GetWarDetails(warId)
end
function DominionCommon:GetWarDetails()
  local myRaidId = dataLayer:GetDataFromNode("Hud.LocalPlayer.Raid.Id")
  if myRaidId and myRaidId:IsValid() then
    return WarDataServiceBus.Broadcast.GetWarForRaid(myRaidId)
  end
  return nil
end
function DominionCommon:GetWarPhaseColor(resolutionPhase)
  return self.WarPhaseToData[resolutionPhase].color
end
function DominionCommon:GetWarDeclarationRequirementText(guildId, warCost)
  local requiresTerritory = WarRequestBus.Broadcast.DoesWarRequireTerritory()
  local territoryText = ""
  local guildHasTerritories = false
  if requiresTerritory then
    guildHasTerritories = WarRequestBus.Broadcast.DoesGuildHaveTerritories(guildId)
    territoryText = guildHasTerritories and "@ui_wardeclarationpopup_territorytext" or "@ui_wardeclarationpopup_noterritorytext"
  end
  local hasPermission = GuildsComponentBus.Broadcast.HasPrivilege(eGuildPrivilegeId_Declare_War)
  local permissionsText
  if not hasPermission then
    local rank = GuildsComponentBus.Broadcast.GetPlayerRankName()
    permissionsText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_wardeclarationpopup_nopermission", rank)
  else
    permissionsText = "@ui_wardeclarationpopup_permission"
  end
  local playerWallet = dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.Amount") or 0
  local hasMoney = warCost <= playerWallet
  local moneyText = "@ui_cantdeclarewar_sufficientfunds"
  if not hasMoney then
    if not self.coinImgText then
      local coinIconPath = "LyShineUI\\Images\\Icon_Crown"
      local coinIconXPadding = 5
      self.coinImgText = string.format("<img src=\"%s\" xPadding=\"%d\"></img>", coinIconPath, coinIconXPadding)
    end
    moneyText = GetLocalizedReplacementText("@ui_cantdeclarewar_insufficientfunds", {
      cost = GetLocalizedCurrency(warCost),
      coinImage = self.coinImgText
    })
  end
  return GetLocalizedReplacementText("@ui_wardeclaration_requirements_format", {
    territoryText = AddTextColorMarkup(territoryText, guildHasTerritories and style.COLOR_WHITE or style.COLOR_INSUFFICIENT_QUANTITY),
    permissionsText = AddTextColorMarkup(permissionsText, hasPermission and style.COLOR_WHITE or style.COLOR_INSUFFICIENT_QUANTITY),
    moneyText = AddTextColorMarkup(moneyText, hasMoney and style.COLOR_WHITE or style.COLOR_INSUFFICIENT_QUANTITY)
  })
end
function DominionCommon:IsAtWarScoutingPhase(guildId, returnTimeText, useShorthandString)
  local warId = WarDataClientRequestBus.Broadcast.GetWarId(guildId)
  local warDetails = WarDataClientRequestBus.Broadcast.GetWarDetails(warId)
  if warDetails:GetWarPhase() == eWarPhase_PreWar and returnTimeText then
    local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
    local scoutingTimeSeconds = warDetails:GetPhaseEndTime():Subtract(now):ToSeconds()
    return true, useShorthandString and timeHelpers:ConvertToLargestTimeEstimate(scoutingTimeSeconds) or timeHelpers:ConvertToShorthandString(scoutingTimeSeconds, true)
  else
    return warDetails:GetWarPhase() == eWarPhase_PreWar
  end
end
function DominionCommon:GetTimeUntilWarEndText(guildId, useShorthandString)
  local warEndTimePoint = WarRequestBus.Broadcast.GetWarEndTime(WarDataClientRequestBus.Broadcast.GetWarId(guildId))
  local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
  local warRemainingTimeSeconds = warEndTimePoint:Subtract(now):ToSeconds()
  local timeUntilWarEnd
  if useShorthandString then
    timeUntilWarEnd = timeHelpers:ConvertToLargestTimeEstimate(warRemainingTimeSeconds)
  else
    timeUntilWarEnd = timeHelpers:ConvertToShorthandString(warRemainingTimeSeconds, true)
  end
  return timeUntilWarEnd
end
function DominionCommon:GetWarPhaseText(warPhase)
  if warPhase and self.WarPhaseToData[warPhase] then
    return self.WarPhaseToData[warPhase].text
  end
end
function DominionCommon:GetSiegeWindowText(siegeTime, showWindow, showSeconds)
  local startOfDay = timeHelpers:GetUtcStartOfDay()
  local startTime = startOfDay + siegeTime * timeHelpers.secondsInHour
  if showWindow then
    local endTime = startTime + self:GetSiegeDuration()
    local timeIntervalString = GetLocalizedReplacementText("@ui_time_interval_format", {
      startTime = timeHelpers:GetLocalizedServerTime(startTime, false),
      endTime = timeHelpers:GetLocalizedServerTime(endTime, true)
    })
    return timeIntervalString
  end
  return timeHelpers:GetLocalizedServerTime(startTime)
end
function DominionCommon:GetTimeToSiegeText(siegeStartTime)
  local now = timeHelpers:ServerSecondsSinceEpoch()
  local timeUntilStart = siegeStartTime - now
  return timeHelpers:ConvertSecondsToHrsMinSecString(timeUntilStart)
end
function DominionCommon:GetNextSiegeWindowText(siegeTime, showSeconds, isShortDate)
  local now = timeHelpers:ServerSecondsSinceEpoch()
  local warStartTime = now + self:GetPreWarDuration()
  local siegeStartTime = warStartTime - warStartTime % timeHelpers.secondsInDay + siegeTime * timeHelpers.secondsInHour
  if warStartTime >= siegeStartTime then
    siegeStartTime = siegeStartTime + timeHelpers.secondsInDay
  end
  local dateString = isShortDate and timeHelpers:GetLocalizedAbbrevDate(siegeStartTime) or timeHelpers:GetLocalizedLongDate(siegeStartTime)
  local relativeStartTime = siegeStartTime - timeHelpers:GetUtcStartOfDay()
  local timeString = self:GetSiegeWindowText(relativeStartTime / timeHelpers.secondsInHour, self:GetSiegeDuration() / timeHelpers.secondsInHour, showSeconds)
  local dateTimeString = GetLocalizedReplacementText("@ui_date_time_format", {date = dateString, time = timeString})
  return dateTimeString
end
return DominionCommon
