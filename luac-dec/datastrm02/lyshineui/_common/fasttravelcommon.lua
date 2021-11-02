local FastTravelCommon = {}
local UIStyle = RequireScript("LyShineUI._Common.UIStyle")
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
FastTravelCommon.fastTravelErrorToText = {
  [eCanFastTravelToSettlementResults_InCooldown] = "@ui_fast_travel_error_inCooldown",
  [eCanFastTravelToSettlementResults_InvalidDestinationTerritoryId] = "@ui_fast_travel_error_noDestination",
  [eCanFastTravelToSettlementResults_InvalidStartingTerritoryId] = "@ui_fast_travel_error_badStartLoc",
  [eCanFastTravelToSettlementResults_CantAfford] = "@ui_fast_travel_error_cantAfford",
  [eCanFastTravelToSettlementResults_IsEncumbered] = "@ui_fast_travel_error_encumbered",
  [eCanFastTravelToSettlementResults_IsDead] = "@ui_cannot_travel_dead",
  [eCanFastTravelToSettlementResults_InEncounter] = "@ui_cannot_travel_encounter",
  [eCanFastTravelToSettlementResults_InWar] = "@ui_cannot_travel_in_war"
}
function FastTravelCommon:GetCurrentlySetInnTerritoryId()
  local homePointsDataNode = dataLayer:GetDataNode("Hud.LocalPlayer.HomePoints")
  if homePointsDataNode then
    local homePointCount = homePointsDataNode.Count:GetData() or 0
    for i = 1, homePointCount do
      local currentDataNode = homePointsDataNode[tostring(i)]
      local respawnType = currentDataNode.Type:GetData()
      if respawnType == "Inn" then
        local innPosition = currentDataNode.Position:GetData()
        if innPosition then
          local recallToInn = true
          local territoryId = PlayerHousingClientRequestBus.Broadcast.GetFastTravelToTerritoryIdByPosition(innPosition, recallToInn)
          return territoryId
        end
      end
    end
  end
  return 0
end
function FastTravelCommon:GetCurrentlySetStartingBeachHomePointTerritoryId()
  local homePointsDataNode = dataLayer:GetDataNode("Hud.LocalPlayer.HomePoints")
  if homePointsDataNode then
    local homePointCount = homePointsDataNode.Count:GetData() or 0
    for i = 1, homePointCount do
      local currentDataNode = homePointsDataNode[tostring(i)]
      local respawnType = currentDataNode.Type:GetData()
      if respawnType == "StartingBeach" then
        local homePointPosition = currentDataNode.Position:GetData()
        if homePointPosition then
          local recallToInn = true
          local territoryId = PlayerHousingClientRequestBus.Broadcast.GetFastTravelToTerritoryIdByPosition(homePointPosition, recallToInn)
          return territoryId
        end
      end
    end
  end
  return 0
end
function FastTravelCommon:GetCurrentlySetInnCooldownTime(getWallClock)
  local homePointsDataNode = dataLayer:GetDataNode("Hud.LocalPlayer.HomePoints")
  if homePointsDataNode then
    local homePointCount = homePointsDataNode.Count:GetData() or 0
    for i = 1, homePointCount do
      local currentDataNode = homePointsDataNode[tostring(i)]
      local respawnType = currentDataNode.Type:GetData()
      if respawnType == "Inn" then
        local cooldownEnd = currentDataNode.CooldownEndWallClock:GetData()
        if cooldownEnd then
          if getWallClock then
            return cooldownEnd
          else
            local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
            return math.max(cooldownEnd:Subtract(now):ToSeconds(), 0)
          end
        end
      end
    end
  end
  if getWallClock then
    return LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
  else
    return 0
  end
end
return FastTravelCommon
