local FastTravelLayer = {
  Properties = {},
  ICON_SLICE_FAST_TRAVEL = "LyShineUI\\WorldMap\\FastTravelIcon"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local Spawner = RequireScript("LyShineUI._Common.Spawner")
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
BaseElement:CreateNewElement(FastTravelLayer)
Spawner:AttachSpawner(FastTravelLayer)
function FastTravelLayer:OnInit()
  BaseElement.OnInit(self)
  self.iconTypes = mapTypes.iconTypes
  self.icons = {}
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId then
      self.playerEntityId = playerEntityId
    end
  end)
end
function FastTravelLayer:OnShutdown()
  if self.spawnerNotificationBusHandler then
    self:BusDisconnect(self.spawnerNotificationBusHandler)
    self.spawnerNotificationBusHandler = nil
  end
  if self.mapComponentEventBusHandler then
    self:BusDisconnect(self.mapComponentEventBusHandler)
    self.mapComponentEventBusHandler = nil
  end
end
function FastTravelLayer:SetMarkersLayer(markersLayer)
  self.markersLayer = markersLayer
  if not self.spawnerNotificationBusHandler then
    self.spawnerNotificationBusHandler = self:BusConnect(UiSpawnerNotificationBus, self.entityId)
  end
  if not self.mapComponentEventBusHandler then
    self.mapComponentEventBusHandler = self:BusConnect(MapComponentEventBus)
  end
end
function FastTravelLayer:SetWorldMapData(worldMapData, visibleWorldBounds)
  for _, iconTable in pairs(self.icons) do
    iconTable.iconData.anchors = self.markersLayer:WorldPositionToAnchors(iconTable.iconData.worldPosition)
    iconTable:SetData(iconTable.iconData)
  end
  local fastTravelPoints = MapComponentBus.Broadcast.GetFastTravelPointPOIIds()
  for i = 1, #fastTravelPoints do
    self:UpdateFastTravelPoint(fastTravelPoints[i])
  end
end
function FastTravelLayer:OnMapFilterChanged(isVisible)
  if isVisible == nil then
    return
  end
  for _, iconTable in pairs(self.icons) do
    iconTable:SetFilterVisibility(isVisible)
  end
end
function FastTravelLayer:UpdateFastTravelPoint(POIId)
  if not self.icons[POIId] then
    local landmarkData = MapComponentBus.Broadcast.GetFirstLandmarkByType(POIId, eTerritoryLandmarkType_FastTravelPoint)
    local territoryDefn = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(POIId)
    local titleText = territoryDefn.nameLocalizationKey
    local descriptionText = "@ui_spirit_shrine_desc"
    local iconData = {
      index = POIId,
      descriptionText = descriptionText,
      titleText = titleText,
      dataManager = self,
      anchors = self.markersLayer:WorldPositionToAnchors(landmarkData.worldPosition),
      worldPosition = landmarkData.worldPosition
    }
    self:SpawnSlice(self.entityId, self.ICON_SLICE_FAST_TRAVEL, self.OnIconSpawned, iconData)
  end
end
function FastTravelLayer:SetIsVisible(isVisible)
  self.isVisible = isVisible
  for i = 1, #self.icons do
    self.icons[i]:SetIsVisible(isVisible)
  end
end
function FastTravelLayer:OnIconSpawned(entity, iconData)
  self.icons[iconData.index] = entity
  entity:SetData(iconData)
end
return FastTravelLayer
