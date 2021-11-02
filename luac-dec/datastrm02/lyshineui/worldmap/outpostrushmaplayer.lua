local OutpostRushMapLayer = {
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
    },
    CollapsibleSettlementIconA = {
      default = EntityId()
    },
    CollapsibleSettlementIconB = {
      default = EntityId()
    },
    CollapsibleSettlementIconC = {
      default = EntityId()
    }
  },
  dataLayer_localPlayerTeamIdx = "LocalPlayer.teamIdx",
  dataLayer_winningTeamIdxId = tostring(1116393986),
  dataLayer_teamScore1Id = 3535581758,
  dataLayer_teamScore2Id = 1270211460,
  dataLayer_timeLimitTimerId = "Timer_" .. tostring(2400096598),
  dataLayer_timerBoss = "Timer_" .. tostring(3888164413),
  dataLayer_gameState = "State"
}
local SiegeMarkerData = RequireScript("LyShineUI.Markers.SiegeMarkerData")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local BitwiseHelper = RequireScript("LyShineUI._Common.BitwiseHelpers")
local TimeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local GameModeCommon = RequireScript("LyShineUI._Common.GameModeCommon")
BaseElement:CreateNewElement(OutpostRushMapLayer)
function OutpostRushMapLayer:OnInit()
  BaseElement.OnInit(self)
  self.capturePointInfo = {
    {
      statusDataLayerId = tostring(1150146850),
      locationDataLayerId = tostring(3862203027) .. ".position",
      position = Vector3(0, 0, 0),
      text = "A"
    },
    {
      statusDataLayerId = tostring(3389185729),
      locationDataLayerId = tostring(2134760233) .. ".position",
      position = Vector3(0, 0, 0),
      text = "B"
    },
    {
      statusDataLayerId = tostring(111730271),
      locationDataLayerId = tostring(138079167) .. ".position",
      position = Vector3(0, 0, 0),
      text = "C"
    }
  }
  self.localPlayerRaidId = RaidId()
  self.siegeIcons = {
    self.ClaimPointStatusIconA,
    self.ClaimPointStatusIconB,
    self.ClaimPointStatusIconC
  }
  self.outpostIcons = {
    self.CollapsibleSettlementIconA,
    self.CollapsibleSettlementIconB,
    self.CollapsibleSettlementIconC
  }
  self.poiIcons = {}
  local iconIdx = 1
  while true do
    local entityId = UiElementBus.Event.FindChildByName(self.entityId, string.format("PointOfInterestIcon%d", iconIdx))
    if entityId and entityId:IsValid() then
      table.insert(self.poiIcons, self.registrar:GetEntityTable(entityId))
      UiElementBus.Event.SetIsEnabled(entityId, false)
      iconIdx = iconIdx + 1
    else
      break
    end
  end
  local portalIconEntityId = UiElementBus.Event.FindChildByName(self.entityId, "PortalIcon")
  UiElementBus.Event.SetIsEnabled(portalIconEntityId, false)
  self.portalPoiIcon = self.registrar:GetEntityTable(portalIconEntityId)
  local bossIconEntityId = UiElementBus.Event.FindChildByName(self.entityId, "BossIcon")
  UiElementBus.Event.SetIsEnabled(bossIconEntityId, false)
  self.bossPoiIcon = self.registrar:GetEntityTable(bossIconEntityId)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Raid.Id", function(self, raidId)
    if raidId and raidId:IsValid() then
      self.localPlayerRaidId = raidId
    end
  end)
end
function OutpostRushMapLayer:SetMarkersLayer(markersLayer)
  self.markersLayer = markersLayer
  self:EnableOutpostMarkers(false)
  self.siegeStructures = {}
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, rootEntityId)
    if rootEntityId then
      self.localPlayerEntityId = rootEntityId
      if self.participantBusHandler then
        self.participantBusHandler:Disconnect()
        self.participantBusHandler = nil
      end
      self.participantBusHandler = self:BusConnect(GameModeParticipantComponentNotificationBus, rootEntityId)
      self.categoricalProgressionHandler = self:BusConnect(CategoricalProgressionNotificationBus, rootEntityId)
    end
  end)
end
function OutpostRushMapLayer:SetZoomLevel(zoomLevel)
  for i = 1, #self.outpostIcons do
    self.outpostIcons[i]:SetZoomLevel(zoomLevel)
  end
end
function OutpostRushMapLayer:SetWorldMapData(worldMapData, visibleWorldBounds)
  for i, capturePoint in ipairs(self.capturePointInfo) do
    local anchors = self.markersLayer:WorldPositionToAnchors(self.capturePointInfo[i].position)
    UiTransform2dBus.Event.SetAnchorsScript(self.siegeIcons[i].entityId, anchors)
    self.siegeIcons[i]:SetName(self.capturePointInfo[i].text, nil, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
  end
  for i, poiIcon in ipairs(self.poiIcons) do
    if poiIcon.iconData then
      poiIcon:UpdateAnchors(self.markersLayer:WorldPositionToAnchors(poiIcon.iconData.position))
    end
  end
  for i, outpostIcon in ipairs(self.outpostIcons) do
    outpostIcon:UpdateAnchorsAndVisiblity()
  end
  if self.portalPoiIcon and self.portalPoiIcon.iconData then
    self.portalPoiIcon:UpdateAnchors(self.markersLayer:WorldPositionToAnchors(self.portalPoiIcon.iconData.position))
  end
  if self.bossPoiIcon and self.bossPoiIcon.iconData then
    self.bossPoiIcon:UpdateAnchors(self.markersLayer:WorldPositionToAnchors(self.bossPoiIcon.iconData.position))
  end
end
function OutpostRushMapLayer:GetGameModeDataPath(valueName)
  return "GameMode." .. tostring(self.gameModeEntityId) .. "." .. valueName
end
function OutpostRushMapLayer:EnableOutpostMarkers(enable)
  self.siegeMarkersVisible = enable
  UiElementBus.Event.SetIsEnabled(self.entityId, enable)
  UiElementBus.Event.SetIsEnabled(self.Properties.ClaimPointStatusIconA, enable)
  UiElementBus.Event.SetIsEnabled(self.Properties.ClaimPointStatusIconB, enable)
  UiElementBus.Event.SetIsEnabled(self.Properties.ClaimPointStatusIconC, enable)
end
function OutpostRushMapLayer:OnEnteredGameMode(gameModeEntityId, gameModeId)
  if gameModeId ~= 2444859928 then
    return
  end
  self.gameModeEntityId = gameModeEntityId
  self.dataLayer:RegisterAndExecuteDataObserver(self, self:GetGameModeDataPath("AzothPortalTotal"), function(self, total)
    self.portalTotal = total
  end)
  self:EnableOutpostMarkers(true)
  if self.localPlayerRaidId ~= nil and self.localPlayerRaidId:IsValid() then
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    UiFaderBus.Event.SetFadeValue(self.entityId, 1)
  end
  self.localPlayerTeamIdx = nil
  self.dataLayer:RegisterAndExecuteDataObserver(self, self:GetGameModeDataPath(self.dataLayer_localPlayerTeamIdx), function(self, localPlayerTeamIdx)
    if self.localPlayerTeamIdx ~= nil then
      return
    end
    self.localPlayerTeamIdx = localPlayerTeamIdx
    if self.localPlayerTeamIdx ~= nil then
      for i = 1, #self.siegeIcons do
        self.siegeIcons[i]:SetMeterBGColor(self.UIStyle.COLOR_BLACK)
        self.siegeIcons[i]:SetMeterColor(self.UIStyle.COLOR_BLUE)
        self.siegeIcons[i]:SetProgress(0)
      end
      if self.portalScoreKey then
        self.dataLayer:UnregisterObserver(self, self.portalScoreKey)
      end
      self.portalScoreKey = self:GetGameModeDataPath(tostring(Math.CreateCrc32("PortalTeam" .. tostring(localPlayerTeamIdx + 1))))
      self.dataLayer:RegisterAndExecuteDataObserver(self, self.portalScoreKey, function(self, score)
        self:UpdatePortalScore(score and score or 0)
      end)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self:GetGameModeDataPath(self.dataLayer_timerBoss), function(self, time)
    self:UpdateBossTimer(time and time or 0)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self:GetGameModeDataPath(self.dataLayer_gameState), function(self, state)
    local showStatusText = state == 2231901092
    UiElementBus.Event.SetIsEnabled(self.portalPoiIcon.Properties.TextBG, showStatusText)
    UiElementBus.Event.SetIsEnabled(self.portalPoiIcon.Properties.Text, showStatusText)
    UiElementBus.Event.SetIsEnabled(self.bossPoiIcon.Properties.TextBG, showStatusText)
    UiElementBus.Event.SetIsEnabled(self.bossPoiIcon.Properties.Text, showStatusText)
  end)
  for i = 1, #self.capturePointInfo do
    self.dataLayer:RegisterAndExecuteDataObserver(self, self:GetGameModeDataPath(self.capturePointInfo[i].statusDataLayerId), function(self, status)
      if status then
        local owningTeamIdx = BitwiseHelper:And(status, OutpostRush_CapturePointStatusMask)
        if owningTeamIdx == 0 or owningTeamIdx == 1 then
          self:UpdateCapturePointOwningTeamIdx(self.siegeIcons[i], owningTeamIdx)
        end
        local contestingTeamIdx = BitwiseHelper:And(BitwiseHelper:RShift(status, OutpostRush_CapturePointStatusBitsPerField), OutpostRush_CapturePointStatusMask)
        if contestingTeamIdx == 0 or contestingTeamIdx == 1 then
          self:UpdateCapturePointContestingTeamIdx(self.siegeIcons[i], contestingTeamIdx)
        end
        local fillValue = BitwiseHelper:And(BitwiseHelper:RShift(status, OutpostRush_CapturePointStatusBitsPerField * 2), OutpostRush_CapturePointStatusMask)
        if 0 <= fillValue and fillValue <= 100 then
          self:UpdateCapturePointFillPct(self.siegeIcons[i], fillValue)
        end
      end
    end)
    self.dataLayer:RegisterAndExecuteDataObserver(self, self:GetGameModeDataPath(self.capturePointInfo[i].locationDataLayerId), function(self, position)
      if position then
        self.capturePointInfo[i].position = position
        local anchors = self.markersLayer:WorldPositionToAnchors(self.capturePointInfo[i].position)
        UiTransform2dBus.Event.SetAnchorsScript(self.siegeIcons[i].entityId, anchors)
        self.outpostIcons[i]:SetOutpostRushIcon(self.markersLayer, {
          position = position,
          outpostIdx = i,
          GetGameModeDataPath = function(valueName)
            return self:GetGameModeDataPath(valueName)
          end
        })
      end
    end)
  end
  local POI_DATA = {
    {
      pathBase = "OR_Arena_Boss_%02d",
      count = 1,
      mapIconPath = "lyshineui/images/hud/outpostrush/iconiceboss.dds",
      tooltipBackground = "lyshineui/images/map/tooltipimages/mapTooltip_outpostRush_iceBoss.dds",
      titleText = "@ui_or_boss",
      descriptionText = "@ui_or_boss_desc",
      keepText = true,
      backgroundWidth = 60,
      specificIcon = self.bossPoiIcon
    },
    {
      pathBase = "OR_Den_Wolf_%02d",
      count = 2,
      mapIconPath = "lyshineui/images/map/icon/pois/wolf_den.dds",
      tooltipBackground = "lyshineui/images/map/tooltipimages/mapTooltip_outpostRush_wolfDen.dds",
      titleText = "@ui_or_wolf_den",
      descriptionText = "@ui_or_wolf_den_desc"
    },
    {
      pathBase = "OR_Grove_Dryad_%02d",
      count = 2,
      mapIconPath = "lyshineui/images/map/icon/pois/angryearth_grove.dds",
      tooltipBackground = "lyshineui/images/map/tooltipimages/mapTooltip_outpostRush_grove.dds",
      titleText = "@ui_or_dryad_grove",
      descriptionText = "@ui_or_dryad_grove_desc"
    },
    {
      pathBase = "OR_Mine_Withered_%02d",
      count = 2,
      mapIconPath = "lyshineui/images/map/icon/pois/mine.dds",
      tooltipBackground = "lyshineui/images/map/tooltipimages/mapTooltip_outpostRush_mine.dds",
      titleText = "@ui_or_withered_mine",
      descriptionText = "@ui_or_withered_mine_desc"
    },
    {
      pathBase = "OR_Portal_Corrupted_%02d",
      count = 1,
      mapIconPath = "lyshineui/images/hud/outpostrush/iconportal.dds",
      tooltipBackground = "lyshineui/images/map/tooltipimages/mapTooltip_outpostRush_portal.dds",
      titleText = "@ui_or_corrupted_portal",
      descriptionText = "@ui_or_corrupted_portal_desc",
      keepText = true,
      backgroundWidth = 120,
      specificIcon = self.portalPoiIcon
    }
  }
  local poiIdx = 1
  for i, poiData in ipairs(POI_DATA) do
    for j = 1, poiData.count do
      local path = tostring(Math.CreateCrc32(string.format(poiData.pathBase, j - 1))) .. ".position"
      local poiIcon
      if poiData.specificIcon then
        poiIcon = poiData.specificIcon
      else
        poiIcon = self.poiIcons[poiIdx]
        poiIdx = poiIdx + 1
      end
      self.dataLayer:RegisterAndExecuteDataObserver(self, self:GetGameModeDataPath(path), function(self, position)
        if position then
          local iconData = {
            index = 0,
            position = position,
            anchors = self.markersLayer:WorldPositionToAnchors(position),
            isDiscovered = true,
            isCharted = true,
            groupSize = 0,
            minSize = 0,
            mapIconPath = poiData.mapIconPath,
            tooltipBackground = poiData.tooltipBackground,
            titleText = poiData.titleText,
            descriptionText = poiData.descriptionText,
            descriptionTextTimerCompleted = poiData.descriptionTextTimerCompleted,
            descriptionTextTimerInit = poiData.descriptionTextTimerInit,
            timeRemainingNode = poiData.timeRemainingNode,
            keepText = poiData.keepText,
            backgroundWidth = poiData.backgroundWidth
          }
          if poiIcon then
            poiIcon:SetData(iconData)
            UiElementBus.Event.SetIsEnabled(poiIcon.entityId, true)
          else
            Debug.Log("ERROR: Not enough POI Icons in OutpostRushMapLayer. Add more to the canvas.")
          end
        end
      end)
    end
  end
end
function OutpostRushMapLayer:OnExitedGameMode(gameModeEntityId)
  if gameModeEntityId ~= self.gameModeEntityId then
    return
  end
  self:EnableOutpostMarkers(false)
  self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(self.dataLayer_localPlayerTeamIdx))
  self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(self.dataLayer_teamScore1Id))
  self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(self.dataLayer_teamScore2Id))
  self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(self.dataLayer_winningTeamIdxId))
  self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(self.dataLayer_timeLimitTimerId))
  self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(self.dataLayer_timerBoss))
  self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(self.dataLayer_gameState))
  self.dataLayer:UnregisterObserver(self, self.portalScoreKey)
  self.portalScoreKey = nil
  for i = 1, #self.capturePointInfo do
    self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(self.capturePointInfo[i].statusDataLayerId))
    self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(self.capturePointInfo[i].locationDataLayerId))
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  self.gameModeEntityId = nil
end
function OutpostRushMapLayer:OnReceivedEventFromServer(gameModeEntityId, eventId, value)
  if gameModeEntityId ~= self.gameModeEntityId then
    return
  end
  if eventId == 359135707 then
  end
end
function OutpostRushMapLayer:UpdateCapturePointOwningTeamIdx(claimIcon, teamIdx)
  local color = self.UIStyle.COLOR_BLACK
  local isLocalPlayerTeamIdx
  if teamIdx and self.localPlayerTeamIdx then
    isLocalPlayerTeamIdx = teamIdx == self.localPlayerTeamIdx
    if isLocalPlayerTeamIdx then
      color = self.UIStyle.COLOR_BLUE
    else
      color = self.UIStyle.COLOR_RED
    end
  end
  claimIcon:SetName(claimIcon:GetName(), isLocalPlayerTeamIdx, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
  claimIcon:SetMeterBGColor(color)
end
function OutpostRushMapLayer:UpdateCapturePointContestingTeamIdx(claimIcon, teamIdx)
  local color = self.UIStyle.COLOR_RED
  if teamIdx and self.localPlayerTeamIdx and teamIdx == self.localPlayerTeamIdx then
    color = self.UIStyle.COLOR_BLUE
  end
  claimIcon:SetMeterColor(color)
end
function OutpostRushMapLayer:UpdateCapturePointFillPct(claimIcon, fillValue)
  claimIcon:SetProgress(fillValue / 100)
end
function OutpostRushMapLayer:UpdatePortalScore(score)
  if self.portalPoiIcon then
    local scoreText = GetLocalizedReplacementText("@ui_outpost_rush_portal_score", {
      current = tostring(score),
      total = self.portalTotal
    })
    self.portalPoiIcon:UpdateText(scoreText)
  end
end
function OutpostRushMapLayer:UpdateBossTimer(timeRemaining)
  if self.bossPoiIcon then
    local secondsRemaining = math.max(math.ceil(timeRemaining / 1000), 0)
    if 0 < secondsRemaining then
      local _, _, minutes, seconds = TimeHelpers:ConvertSecondsToDaysHoursMinutesSeconds(secondsRemaining)
      local timerText = string.format("%d:%02d", minutes, seconds)
      self.bossPoiIcon:UpdateText(timerText)
    else
      self.bossPoiIcon:UpdateText("@ui_outpost_rush_boss_alive")
    end
  end
end
return OutpostRushMapLayer
