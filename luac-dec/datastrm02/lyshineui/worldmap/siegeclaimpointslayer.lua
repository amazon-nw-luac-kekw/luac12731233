local SiegeClaimPointsLayer = {
  Properties = {
    ClaimPointStatusIconA = {
      default = EntityId()
    },
    ClaimPointStatusIconB = {
      default = EntityId()
    },
    ClaimPointStatusIconC = {
      default = EntityId()
    },
    KeepStatusIcon = {
      default = EntityId()
    }
  }
}
local SiegeMarkerData = RequireScript("LyShineUI.Markers.SiegeMarkerData")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(SiegeClaimPointsLayer)
function SiegeClaimPointsLayer:OnInit()
  BaseElement.OnInit(self)
  self.raidId = RaidId()
  self.siegeIcons = {}
  self.siegeIcons[eFortSpawnId_CapturePoint_A] = self.ClaimPointStatusIconA
  self.siegeIcons[eFortSpawnId_CapturePoint_B] = self.ClaimPointStatusIconB
  self.siegeIcons[eFortSpawnId_CapturePoint_C] = self.ClaimPointStatusIconC
  self.siegeIcons[eFortSpawnId_CapturePoint_Claim] = self.KeepStatusIcon
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Raid.Id", function(self, raidId)
    if raidId and raidId:IsValid() then
      self.raidId = raidId
    end
  end)
end
function SiegeClaimPointsLayer:SetMarkersLayer(markersLayer)
  self.markersLayer = markersLayer
  self:EnableSiegeMarkers(false)
  if self.groupsNotificationBusHandler then
    self:BusDisconnect(self.groupsNotificationBusHandler)
    self.groupsNotificationBusHandler = nil
  end
  if self.siegeWarfareBus then
    self:BusDisconnect(self.siegeWarfareBus)
    self.siegeWarfareBus = nil
  end
  self.siegeStructures = {}
  self.groupsNotificationBusHandler = self:BusConnect(GroupsUINotificationBus)
end
function SiegeClaimPointsLayer:SetWorldMapData(worldMapData, visibleWorldBounds)
end
function SiegeClaimPointsLayer:EnableSiegeMarkers(enable)
  self.siegeMarkersVisible = enable
  UiElementBus.Event.SetIsEnabled(self.entityId, enable)
  UiElementBus.Event.SetIsEnabled(self.Properties.ClaimPointStatusIconA, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.ClaimPointStatusIconB, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.ClaimPointStatusIconC, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.KeepStatusIcon, false)
end
function SiegeClaimPointsLayer:OnSiegeWarfareStarted(warId)
  self:EnableSiegeMarkers(true)
  local warDetails = WarDataClientRequestBus.Broadcast.GetWarDetails(warId)
  local attackingRaidId = warDetails:GetAttackerRaidId()
  local defendingRaidId = warDetails:GetDefenderRaidId()
  self.isAttacking = self.raidId == attackingRaidId
  self.claimStartingColor = self.isAttacking and self.UIStyle.COLOR_CONQUEST_RED or self.UIStyle.COLOR_CONQUEST_BLUE
  self.claimTargetColor = self.isAttacking and self.UIStyle.COLOR_CONQUEST_BLUE or self.UIStyle.COLOR_CONQUEST_RED
  ClearTable(self.siegeStructures)
  if self.siegeWarfareBus then
    SiegeWarfareDataComponentRequestBus.Broadcast.RequestExistingStateNotifications()
  else
    self.siegeWarfareBus = self:BusConnect(SiegeWarfareDataComponentNotificationBus)
  end
end
function SiegeClaimPointsLayer:OnSiegeWarfareEnded(isWinner, resolutionPhaseEndTimePoint)
  self:OnSiegeWarfareCompleted()
end
function SiegeClaimPointsLayer:OnSiegeWarfareCompleted()
  self:EnableSiegeMarkers(false)
  if self.siegeWarfareBus then
    self:BusDisconnect(self.siegeWarfareBus)
    self.siegeWarfareBus = nil
  end
end
function SiegeClaimPointsLayer:OnCapturePointStateChange(entityId, capturePointState)
  if not self.siegeIcons[capturePointState.fortSpawnId] then
    return
  end
  local index = capturePointState.fortSpawnId
  if not self.siegeStructures[index] then
    local markerData = {
      position = Vector3(0, 0, 0),
      state = -1,
      fillPct = -1,
      marker = self.siegeIcons[capturePointState.fortSpawnId],
      fortSpawnId = capturePointState.fortSpawnId
    }
    if SiegeMarkerData.siegeData[capturePointState.fortSpawnId].text ~= nil then
      markerData.name = SiegeMarkerData.siegeData[capturePointState.fortSpawnId].text
      markerData.marker:SetName(markerData.name)
    elseif SiegeMarkerData.siegeData[capturePointState.fortSpawnId].icon ~= nil then
      markerData.icon = SiegeMarkerData.siegeData[capturePointState.fortSpawnId].icon
      markerData.marker:SetIcon(markerData.icon)
    end
    self.siegeStructures[capturePointState.fortSpawnId] = markerData
    self.siegeStructures[index].position = capturePointState.worldPos
    local anchors = self.markersLayer:WorldPositionToAnchors(self.siegeStructures[index].position)
    UiTransform2dBus.Event.SetAnchorsScript(self.siegeStructures[index].marker.entityId, anchors)
    UiElementBus.Event.SetIsEnabled(self.siegeStructures[index].marker.entityId, self.siegeMarkersVisible)
    self.siegeStructures[index].marker:SetMeterColor(self.claimTargetColor)
    self.siegeStructures[index].marker:SetMeterBGColor(self.claimStartingColor)
  end
  if self.siegeStructures[index].state ~= capturePointState.stateFlags then
    self.siegeStructures[index].state = capturePointState.stateFlags
    self.siegeStructures[index].marker:SetState(self.siegeStructures[index].state)
  end
  if self.siegeStructures[index].fillPct ~= capturePointState.fillPct then
    self.siegeStructures[index].fillPct = capturePointState.fillPct
    self.siegeStructures[index].marker:SetProgress(self.siegeStructures[index].fillPct)
  end
end
return SiegeClaimPointsLayer
