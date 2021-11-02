local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local Spawner = RequireScript("LyShineUI._Common.Spawner")
local TerritoriesLayer = {
  Properties = {},
  worldBounds = {
    left = 0,
    top = 0,
    width = 0,
    height = 0
  },
  playerLoc = Vector3(0, 0, 0),
  territoryDetectMinLevel = 3,
  lastCursorWorldPos = Vector3(0, 0, 0)
}
BaseElement:CreateNewElement(TerritoriesLayer)
Spawner:AttachSpawner(TerritoriesLayer)
function TerritoriesLayer:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self:BusConnect(UiSpawnerNotificationBus, self.entityId)
  self:BusConnect(UiCanvasNotificationBus, self.canvasId)
  self.zoomLevel = 1
  self.territories = {}
  self.territoriesById = {}
  self.registeredTerritories = {}
  self.lastHoverTerritory = 0
  self.logSettings = {"Map"}
end
function TerritoriesLayer:SetMagicMap(magicMap)
  self.MagicMap = magicMap
end
function TerritoriesLayer:SetWorldMapData(worldMapData, visibleBounds)
  self.worldMapData = worldMapData
  self.visibleBounds = visibleBounds
  for k, territoryOverlay in pairs(self.territories) do
    territoryOverlay.territoryInfo.anchors = self:WorldPositionToAnchors(territoryOverlay.territoryInfo.center)
    territoryOverlay.territoryInfo.isInBounds = self.MagicMap:IsWorldPositionInBounds(territoryOverlay.territoryInfo.center, worldMapData.bounds)
    territoryOverlay:SetTerritoryInfo(self, territoryOverlay.territoryInfo, self.zoomLevel)
  end
end
function TerritoriesLayer:SetIsMiniMap(isMiniMap)
  if isMiniMap then
    self.sourceType = self.sourceTypes.MiniMap
  end
end
function TerritoriesLayer:SetIsRespawnMap(isRespawnMap)
  if isRespawnMap then
    self.sourceType = self.sourceTypes.RespawnMap
  end
end
function TerritoriesLayer:CreateTerritoryOverlays()
  local territories = MapComponentBus.Broadcast.GetTerritories()
  self.territoriesToSpawn = 0
  for index = 1, #territories do
    local territory = territories[index]
    local territoryInfo = {
      index = index,
      id = territory.id,
      territoryName = territory.territoryName,
      dataNodeName = "",
      color = self.UIStyle.COLOR_BLACK,
      width = territory.width,
      height = territory.height,
      center = territory.position,
      positionId = self:GetTerritoryPositionId(territory.position),
      anchors = self:WorldPositionToAnchors(territory.position),
      isInBounds = true
    }
    if not self.territoriesById[territory.id] and not self.territories[territoryInfo.positionId] then
      self.territoriesToSpawn = self.territoriesToSpawn + 1
      self:SpawnSlice(self.entityId, "LyShineUI/WorldMap/TerritoryOverlay", self.OnTerritorySpawned, territoryInfo)
    end
  end
end
function TerritoriesLayer:GetTerritoryPositionId(position)
  return string.format("%.1f_%.1f", math.floor(position.x), math.floor(position.y))
end
function TerritoriesLayer:SetIsVisible(showing)
  if showing then
    self:UpdateTerritories()
  end
  for k, territoryOverlay in pairs(self.territories) do
    territoryOverlay:SetIsVisible(showing)
  end
end
function TerritoriesLayer:UpdateTerritories()
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.IsLandClaimManagerAvailable", function(self, isAvailable)
    if isAvailable == true then
      for k, territoryOverlay in pairs(self.territories) do
        local claimKey = territoryOverlay.territoryInfo.id
        local ownerData = LandClaimRequestBus.Broadcast.GetClaimOwnerData(claimKey)
        local territoryName = territoryOverlay.territoryInfo.territoryName
        territoryOverlay:SetSettlementKey(claimKey, ownerData, self.territoriesInitialized, territoryName)
      end
      self.territoriesInitialized = true
      self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.IsLandClaimManagerAvailable")
    end
  end)
end
function TerritoriesLayer:SetZoomLevel(zoomLevel)
  local unhover = zoomLevel < self.territoryDetectMinLevel and self.lastHoverTerritory ~= 0
  local checkHover = zoomLevel >= self.territoryDetectMinLevel
  self.zoomLevel = zoomLevel
  for _, territory in pairs(self.territories) do
    territory:SetZoomLevel(self.zoomLevel)
  end
  if unhover then
    if self.territoriesById[self.lastHoverTerritory] then
      self.territoriesById[self.lastHoverTerritory]:OnTerritoryInfoUnhover()
    end
    self.lastHoverTerritory = 0
  end
  if checkHover then
    self:OnMouseMove(self.lastCursorWorldPos)
  end
end
function TerritoriesLayer:OnTerritorySpawned(territory, territoryInfo)
  self.territoriesToSpawn = self.territoriesToSpawn - 1
  Log(self.logSettings, "OnTerritorySpawned. %d to go.", self.territoriesToSpawn)
  if self.territories[territoryInfo.positionId] then
    Log(self.logSettings, "Overlapping territory spawned at (%s)", territoryInfo.positionId)
    UiElementBus.Event.DestroyElement(territory.entityId)
    return
  end
  territory:SetTerritoryInfo(self, territoryInfo, self.zoomLevel)
  self.territories[territoryInfo.positionId] = territory
  self.territoriesById[territoryInfo.id] = territory
  if self.territoriesToSpawn == 0 then
    self.territoriesInitialized = false
    self:UpdateTerritories()
  end
end
function TerritoriesLayer:WorldPositionToAnchors(pos)
  local dx = (pos.x - self.visibleBounds.left) / self.visibleBounds.width
  local dy = (self.visibleBounds.top - pos.y) / self.visibleBounds.height
  local anchors = UiAnchors(dx, dy, dx, dy)
  return anchors
end
function TerritoriesLayer:OnMouseMove(worldPos)
  self.lastCursorWorldPos = worldPos
  if self.zoomLevel >= self.territoryDetectMinLevel then
    local territoryId = MapComponentBus.Broadcast.WorldPosToTerritoryLoRes(worldPos)
    if territoryId ~= self.lastHoverTerritory then
      if self.lastHoverTerritory ~= 0 and self.territoriesById[self.lastHoverTerritory] then
        self.territoriesById[self.lastHoverTerritory]:OnTerritoryInfoUnhover()
      end
      if territoryId ~= 0 and self.territoriesById[territoryId] then
        self.territoriesById[territoryId]:OnTerritoryInfoHover()
      end
      self.lastHoverTerritory = territoryId
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.CurrentHoveredTerritory.ClaimKey", territoryId)
    end
  end
end
return TerritoriesLayer
