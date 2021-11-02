local GlobalMapEntitiesLayer = {
  Properties = {},
  ICON_SLICE_POI = "LyShineUI\\WorldMap\\GlobalMapEntityIcon",
  cachedDarknessIcons = 60,
  currentTerritory = -1,
  hoveredTerritory = -1,
  maxUpdateCount = 10
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local Spawner = RequireScript("LyShineUI._Common.Spawner")
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
BaseElement:CreateNewElement(GlobalMapEntitiesLayer)
Spawner:AttachSpawner(GlobalMapEntitiesLayer)
function GlobalMapEntitiesLayer:OnInit()
  BaseElement.OnInit(self)
  self.markerData = {}
  self.visibleIcons = {}
  self.uiIconCache = {}
  self.iconTypes = mapTypes.iconTypes
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Group.MemberCount", self.UpdateEncounterIcons)
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Progression.Level", self.UpdateEncounterIcons)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey", function(self, claimKey)
    if claimKey then
      self.currentTerritory = claimKey
      self:StartTick()
    end
  end)
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.CurrentHoveredTerritory.ClaimKey", function(self, claimKey)
    self.hoveredTerritory = claimKey
    self:StartTick()
  end)
  for i = 1, self.cachedDarknessIcons do
    self:SpawnSlice(self.entityId, self.ICON_SLICE_POI, self.OnIconSpawned)
  end
end
function GlobalMapEntitiesLayer:SetMarkersLayer(markersLayer)
  if self.markersLayer then
    return
  end
  self.markersLayer = markersLayer
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Map.Filter." .. self.markersLayer.sourceType .. ".EntityTrackingIcon", self.OnMapFilterChanged)
  if not self.spawnerNotificationBusHandler then
    self.spawnerNotificationBusHandler = self:BusConnect(UiSpawnerNotificationBus, self.entityId)
  end
end
function GlobalMapEntitiesLayer:SetWorldMapData(worldMapData, visibleWorldBounds)
  local enablePOILayer = worldMapData.hidePOILayer ~= true
  UiElementBus.Event.SetIsEnabled(self.entityId, enablePOILayer)
end
function GlobalMapEntitiesLayer:OnIconSpawned(entity)
  table.insert(self.uiIconCache, entity)
  entity:ClearIconData()
  if #self.uiIconCache >= self.cachedDarknessIcons then
    self.globalMapDataHandler = self:BusConnect(GlobalMapDataManagerNotificationBus)
    GlobalMapDataManagerRequestBus.Broadcast.RequestGlobalMapData()
  end
end
function GlobalMapEntitiesLayer:OnMapFilterChanged(isVisible)
  if isVisible ~= nil then
    if isVisible then
      UiElementBus.Event.SetIsEnabled(self.entityId, true)
    end
    self.ScriptedEntityTweener:Play(self.entityId, 0.15, {
      opacity = isVisible and 1 or 0,
      ease = "QuadOut",
      onComplete = function()
        if not isVisible then
          UiElementBus.Event.SetIsEnabled(self.entityId, false)
        end
      end
    })
  end
end
function GlobalMapEntitiesLayer:SetIsVisible(isVisible)
  if isVisible == self.isVisible then
    return
  end
  self.isVisible = isVisible
  if isVisible then
    self:StartTick()
  else
    self:StopTick()
  end
end
function GlobalMapEntitiesLayer:OnTick(deltaTime, timePoint)
  local numProcessed = 0
  for i = 1, #self.markerData do
    local markerData = self.markerData[i]
    if markerData.containingTerritoryId == self.currentTerritory or markerData.containingTerritoryId == self.hoveredTerritory then
      if not markerData.icon then
        markerData.icon = self:GetAvailableIconFromCache()
        if markerData.icon then
          markerData.icon:SetGlobalMapIconData(markerData.iconData)
          numProcessed = numProcessed + 1
        end
      end
    elseif markerData.icon then
      self:ReturnIconToCache(markerData.icon.entityId)
      markerData.icon = nil
      numProcessed = numProcessed + 1
    end
    if numProcessed >= self.maxUpdateCount then
      return
    end
  end
  if numProcessed == 0 then
    self:StopTick()
  end
end
function GlobalMapEntitiesLayer:StartTick()
  if self.isVisible and self.tickHandler == nil then
    self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function GlobalMapEntitiesLayer:StopTick()
  self:BusDisconnect(self.tickHandler)
  self.tickHandler = nil
end
function GlobalMapEntitiesLayer:UpdateEncounterIcons()
  for _, icon in pairs(self.visibleIcons) do
    if icon:IsEnabled() then
      icon:UpdateIconPath()
    end
  end
end
function GlobalMapEntitiesLayer:OnGlobalMapDataAdded(worldEntityId, mapData)
  local markerData = self:GetMarkerData(worldEntityId)
  if markerData then
    return
  end
  local containingTerritoryId = MapComponentBus.Broadcast.GetContainingTerritory(Vector3(mapData.worldPosition.x, mapData.worldPosition.y, 0))
  local markerData = {
    worldEntityId = worldEntityId,
    containingTerritoryId = containingTerritoryId,
    iconData = {
      position = mapData.worldPosition,
      territoryId = mapData.territoryId,
      spawnerTag = mapData.spawnerTag,
      dataManager = self
    }
  }
  table.insert(self.markerData, markerData)
  self:StartTick()
end
function GlobalMapEntitiesLayer:OnGlobalMapDataRemoved(worldEntityId)
  for i = 1, #self.markerData do
    local markerData = self.markerData[i]
    if markerData.worldEntityId == worldEntityId then
      if markerData.icon then
        self:ReturnIconToCache(markerData.icon.entityId)
        markerData.icon = nil
      end
      table.remove(self.markerData, i)
      break
    end
  end
end
function GlobalMapEntitiesLayer:OnGlobalMapDataUpdated(worldEntityId, mapData)
  local markerData = self:GetMarkerData(worldEntityId)
  if markerData then
    markerData.iconData.position = mapData.worldPosition
    markerData.iconData.territoryId = mapData.territoryId
    markerData.iconData.spawnerTag = mapData.spawnerTag
    if markerData.icon then
      markerData.icon:SetGlobalMapIconData(markerData.iconData)
    else
      self:StartTick()
    end
  end
end
function GlobalMapEntitiesLayer:GetAvailableIconFromCache()
  local icon = table.remove(self.uiIconCache)
  if icon then
    self.visibleIcons[tostring(icon.entityId)] = icon
    return icon
  end
  return nil
end
function GlobalMapEntitiesLayer:ReturnIconToCache(entityId)
  local entityIdStr = tostring(entityId)
  local icon = self.visibleIcons[entityIdStr]
  if icon then
    icon:ClearIconData()
    table.insert(self.uiIconCache, icon)
    self.visibleIcons[entityIdStr] = nil
  end
end
function GlobalMapEntitiesLayer:GetMarkerData(worldEntityId)
  for i = 1, #self.markerData do
    local markerData = self.markerData[i]
    if markerData.worldEntityId == worldEntityId then
      return markerData
    end
  end
  return nil
end
return GlobalMapEntitiesLayer
