local PointsOfInterestLayer = {
  Properties = {},
  ICON_SLICE_POI = "LyShineUI\\WorldMap\\PointOfInterestIcon",
  DEFAULT_BACKGROUND = "lyShineui/images/map/tooltipimages/mapTooltip_territory"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local Spawner = RequireScript("LyShineUI._Common.Spawner")
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
BaseElement:CreateNewElement(PointsOfInterestLayer)
Spawner:AttachSpawner(PointsOfInterestLayer)
function PointsOfInterestLayer:OnInit()
  BaseElement.OnInit(self)
  self.iconTypes = mapTypes.iconTypes
  self.icons = {}
  self.pendingIcons = {}
  self.newIcons = {}
  self.hotspots = {}
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_enablePOIDiscovery", function(self, isPOIDiscoveryEnabled)
    self.isPOIDiscoveryEnabled = isPOIDiscoveryEnabled
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId then
      self.playerEntityId = playerEntityId
    end
  end)
end
function PointsOfInterestLayer:OnShutdown()
  if self.spawnerNotificationBusHandler then
    self:BusDisconnect(self.spawnerNotificationBusHandler)
    self.spawnerNotificationBusHandler = nil
  end
  if self.mapComponentEventBusHandler then
    self:BusDisconnect(self.mapComponentEventBusHandler)
    self.mapComponentEventBusHandler = nil
  end
end
function PointsOfInterestLayer:SetMarkersLayer(markersLayer)
  self.markersLayer = markersLayer
  if not self.spawnerNotificationBusHandler then
    self.spawnerNotificationBusHandler = self:BusConnect(UiSpawnerNotificationBus, self.entityId)
  end
  if not self.mapComponentEventBusHandler then
    self.mapComponentEventBusHandler = self:BusConnect(MapComponentEventBus)
  end
end
function PointsOfInterestLayer:SetWorldMapData(worldMapData, visibleWorldBounds)
  local enablePOILayer = worldMapData.hidePOILayer ~= true
  UiElementBus.Event.SetIsEnabled(self.entityId, enablePOILayer)
  if not enablePOILayer then
    return
  end
  if self.dataId ~= worldMapData.id then
    self:RemoveGameModePOIs()
  end
  self.dataId = worldMapData.id
  for _, iconTable in pairs(self.icons) do
    iconTable.iconData.anchors = self.markersLayer:WorldPositionToAnchors(iconTable.iconData.worldPosition)
    iconTable:SetData(iconTable.iconData)
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Map.Filter." .. self.markersLayer.sourceType .. ".PointOfInterest", function(self, isVisible)
    self:OnMapFilterChanged(isVisible)
  end)
  simplePOIs = MapComponentBus.Broadcast.GetSimplePOIs()
  for i = 1, #simplePOIs do
    self:UpdateDiscoveredPOI(simplePOIs[i], true)
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.CurrentAreaTerritory.SmallestContainingId", function(self, territoryId)
    if territoryId and self.hotspots[territoryId] then
      local landmarkData = MapComponentBus.Broadcast.GetFirstLandmarkByType(territoryId, eTerritoryLandmarkType_FishingHotspot)
      local level = FishingRequestsBus.Event.GetRequiredLevelByHotspotId(self.playerEntityId, Math.CreateCrc32(landmarkData.landmarkData))
      local shouldShow = level < CategoricalProgressionRequestBus.Event.GetRank(self.playerEntityId, 1975517117)
      self.hotspots[territoryId].isEnabled = shouldShow
      self.hotspots[territoryId]:UpdateVisibility()
    end
  end)
end
function PointsOfInterestLayer:OnMapFilterChanged(isVisible)
  if isVisible == nil then
    return
  end
  for _, iconTable in pairs(self.icons) do
    iconTable:SetFilterVisibility(isVisible)
  end
end
function PointsOfInterestLayer:UpdateDiscoveredPOI(poiData, isInitialUpdate)
  if poiData.outpostId ~= "" then
    return
  end
  if poiData.mapIconPath ~= "" or poiData.isArea then
    if self.icons[poiData.id] then
      if poiData.isDiscovered or poiData.isCharted then
        self.icons[poiData.id]:UpdateCurrentState(poiData.isDiscovered, poiData.isCharted)
      else
        UiElementBus.Event.DestroyElement(self.icons[poiData.id].entityId)
        self.icons[poiData.id] = nil
        return
      end
    elseif self.pendingIcons[poiData.id] then
      self.pendingIcons[poiData.id].isDiscovered = poiData.isDiscovered
      self.pendingIcons[poiData.id].isCharted = poiData.isCharted
    else
      if not poiData.isDiscovered and not poiData.isCharted then
        return
      end
      local titleText, descriptionText, tooltipBackground, gameModeId
      if poiData.nameLocalizationKey ~= "" then
        titleText = poiData.nameLocalizationKey
        descriptionText = poiData.nameLocalizationKey .. "_description"
      end
      if poiData.tooltipBackground ~= "" then
        tooltipBackground = string.gsub(poiData.tooltipBackground, "%.png$", ".dds")
      else
        local territoryId = MapComponentBus.Broadcast.GetContainingTerritory(Vector3(poiData.position.x, poiData.position.y, 0))
        if territoryId ~= 0 then
          tooltipBackground = self.DEFAULT_BACKGROUND .. tostring(territoryId) .. ".dds"
        end
      end
      if not LyShineScriptBindRequestBus.Broadcast.IsFileExists(tooltipBackground) then
        tooltipBackground = nil
      end
      local isHotspot = false
      if string.find(poiData.mapIconPath, "fish_hotspot") then
        isHotspot = true
      end
      if poiData.gameMode ~= "" then
        gameModeId = Math.CreateCrc32(poiData.gameMode)
      end
      local iconData = {
        index = poiData.id,
        descriptionText = descriptionText,
        titleText = titleText,
        dataManager = self,
        isArea = poiData.isArea,
        mapIconPath = poiData.mapIconPath,
        settlementId = poiData.settlementId,
        anchors = self.markersLayer:WorldPositionToAnchors(poiData.position),
        worldPosition = poiData.position,
        isHotspot = isHotspot,
        groupSize = poiData.groupSize,
        tooltipBackground = tooltipBackground,
        gameModeId = gameModeId
      }
      if not isInitialUpdate and poiData.isDiscovered and not poiData.isCharted then
        self.newIcons[poiData.id] = true
      end
      self.pendingIcons[poiData.id] = {
        isDiscovered = poiData.isDiscovered,
        isCharted = poiData.isCharted
      }
      self:SpawnSlice(self.entityId, self.ICON_SLICE_POI, self.OnIconSpawned, iconData)
    end
  end
end
function PointsOfInterestLayer:SetIsVisible(isVisible)
  self.isVisible = isVisible
  for index, _ in pairs(self.newIcons) do
    self:UpdateIconPulse(index)
  end
end
function PointsOfInterestLayer:UpdateIconPulse(index)
  if self.icons[index] and self.newIcons[index] then
    if self.isVisible then
      self.icons[index]:CreatePulse()
    else
      self.icons[index]:ClearPulse()
      self.newIcons[index] = nil
    end
  end
end
function PointsOfInterestLayer:OnIconSpawned(entity, iconData)
  self.icons[iconData.index] = entity
  if iconData.isHotspot then
    self.hotspots[iconData.index] = entity
  end
  if self.pendingIcons[iconData.index] then
    if not self.pendingIcons[iconData.index].isDiscovered and not self.pendingIcons[iconData.index].isCharted then
      UiElementBus.Event.DestroyElement(entity.entityId)
      self.icons[iconData.index] = nil
      self.pendingIcons[iconData.index] = nil
      return
    end
    iconData.isDiscovered = self.pendingIcons[iconData.index].isDiscovered
    iconData.isCharted = self.pendingIcons[iconData.index].isCharted
    self.pendingIcons[iconData.index] = nil
  end
  entity:SetData(iconData)
  if self.isVisible then
    entity:CreatePulse()
  end
end
function PointsOfInterestLayer:RemoveGameModePOIs()
  for key, iconTable in pairs(self.icons) do
    if iconTable.iconData.gameModeId then
      UiElementBus.Event.DestroyElement(iconTable.entityId)
      self.icons[key] = nil
    end
  end
end
return PointsOfInterestLayer
