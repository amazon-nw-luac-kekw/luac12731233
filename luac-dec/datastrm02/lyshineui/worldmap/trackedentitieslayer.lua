local TrackedEntitiesLayer = {
  Properties = {},
  ICON_SLICE_TRACKED = "LyShineUI\\WorldMap\\TrackedEntityIcon",
  ICON_SLICE_POI = "LyShineUI\\WorldMap\\PointOfInterestIcon",
  icons = {},
  pendingIcons = {},
  dungeonRegionIcons = {}
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local Spawner = RequireScript("LyShineUI._Common.Spawner")
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
BaseElement:CreateNewElement(TrackedEntitiesLayer)
Spawner:AttachSpawner(TrackedEntitiesLayer)
function TrackedEntitiesLayer:OnInit()
  BaseElement.OnInit(self)
  self.iconTypes = mapTypes.iconTypes
end
function TrackedEntitiesLayer:OnTick(deltaTime, timePoint)
  if self.isVisible then
    self:UpdateEntityMarkerPositions()
  end
end
function TrackedEntitiesLayer:OnShutdown()
  if self.spawnerNotificationBusHandler then
    self:BusDisconnect(self.spawnerNotificationBusHandler)
    self.spawnerNotificationBusHandler = nil
  end
  if self.mapComponentEventBusHandler then
    self:BusDisconnect(self.mapComponentEventBusHandler)
    self.mapComponentEventBusHandler = nil
  end
  if self.tickBusHandler then
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
  end
end
function TrackedEntitiesLayer:SetMarkersLayer(markersLayer)
  self.markersLayer = markersLayer
end
function TrackedEntitiesLayer:SetWorldMapData(worldMapData, visibleWorldBounds)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Map.Filter." .. self.markersLayer.sourceType .. ".EntityTrackingIcon", self.OnMapFilterChanged)
  if self.dataId ~= worldMapData.id then
    self:DestroyDungeonIcons()
  end
  self.dataId = worldMapData.id
  self:UpdateEntityMarkerAnchors()
  if not self.spawnerNotificationBusHandler then
    self.spawnerNotificationBusHandler = self:BusConnect(UiSpawnerNotificationBus, self.entityId)
  end
  if not self.mapComponentEventBusHandler then
    self.mapComponentEventBusHandler = self:BusConnect(MapComponentEventBus)
  end
end
function TrackedEntitiesLayer:OnMapFilterChanged(isVisible)
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
function TrackedEntitiesLayer:SetIsVisible(isVisible)
  if isVisible == self.isVisible then
    return
  end
  self.isVisible = isVisible
  if isVisible then
    if not self.tickBusHandler and #self.icons > 0 then
      self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
    end
  elseif self.tickBusHandler then
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
  end
end
function TrackedEntitiesLayer:FindMapIconForEntity(entityId)
  for i = 1, #self.icons do
    local icon = self.icons[i]
    if icon and icon.iconData and icon.iconData.entityId and icon.iconData.entityId.value == entityId.value then
      return true, icon, i
    end
  end
  return false
end
function TrackedEntitiesLayer:FindPendingIconForEntity(entityId)
  for i = 1, #self.pendingIcons do
    local icon = self.pendingIcons[i]
    if icon and icon.value == entityId.value then
      return true, icon, i
    end
  end
  return false
end
function TrackedEntitiesLayer:AddEntityIconToMap(entityId, imagePath, tooltipTitle, tooltipDescription)
  local isDungeonRegionText = false
  local position = Vector2(TransformBus.Event.GetWorldX(entityId), TransformBus.Event.GetWorldY(entityId))
  local iconData
  if imagePath == "" and tooltipTitle ~= "" then
    iconData = {
      index = 0,
      descriptionText = tooltipDescription,
      titleText = tooltipTitle,
      textColor = self.UIStyle.COLOR_WHITE,
      dataManager = self,
      poiLevel = 0,
      mapIconPath = "",
      anchors = self.markersLayer:WorldPositionToAnchors(position),
      worldPosition = position,
      isHotspot = false,
      tooltipBackground = nil,
      dungeonRegionText = true
    }
    isDungeonRegionText = true
  else
    if self:FindMapIconForEntity(entityId) then
      return
    end
    if self:FindPendingIconForEntity(entityId) then
      return
    end
    iconData = {
      entityId = entityId,
      titleText = tooltipTitle,
      descriptionText = tooltipDescription,
      mapIconPath = imagePath,
      dataManager = self,
      position = position
    }
  end
  if not isDungeonRegionText then
    table.insert(self.pendingIcons, entityId)
    self:SpawnSlice(self.entityId, self.ICON_SLICE_TRACKED, self.OnIconSpawned, iconData)
  else
    self:SpawnSlice(self.entityId, self.ICON_SLICE_POI, self.OnIconSpawned, iconData)
  end
end
function TrackedEntitiesLayer:RemoveEntityIconFromMap(entityId)
  local isPending, pendingIcon, pendingIndex = self:FindPendingIconForEntity(entityId)
  if isPending then
    UiElementBus.Event.DestroyElement(pendingIcon.entityId)
    table.remove(self.pendingIcons, pendingIndex)
  end
  local isActive, activeIcon, activeIndex = self:FindMapIconForEntity(entityId)
  if isActive then
    UiElementBus.Event.DestroyElement(activeIcon.entityId)
    table.remove(self.icons, activeIndex)
  end
end
function TrackedEntitiesLayer:OnIconSpawned(entity, iconData)
  if iconData.dungeonRegionText then
    table.insert(self.dungeonRegionIcons, entity)
  else
    local isPending, icon, i = self:FindPendingIconForEntity(iconData.entityId)
    if isPending then
      table.remove(self.pendingIcons, i)
    else
      local isActive, activeIcon, activeIndex = self:FindMapIconForEntity(iconData.entityId)
      table.remove(self.icons, activeIndex)
      UiElementBus.Event.DestroyElement(entity.entityId)
      return
    end
    table.insert(self.icons, entity)
  end
  entity:SetData(iconData)
  if not iconData.dungeonRegionText then
    entity:OnPositionChanged(iconData.position)
  end
end
function TrackedEntitiesLayer:UpdateEntityMarkerPositions()
  for i = 1, #self.icons do
    local iconEntity = self.icons[i]
    if iconEntity.iconData then
      local entityId = iconEntity.iconData.entityId
      if entityId then
        local x = TransformBus.Event.GetWorldX(entityId)
        local y = TransformBus.Event.GetWorldY(entityId)
        if not x or not y then
          UiElementBus.Event.DestroyElement(entityId)
          table.remove(self.icons, i)
        else
          local newPos = Vector2(x, y)
          if not newPos:IsClose(iconEntity.iconData.position) and iconEntity.OnPositionChanged then
            iconEntity:OnPositionChanged(newPos)
          end
        end
      end
    end
  end
end
function TrackedEntitiesLayer:UpdateEntityMarkerAnchors()
  for i = 1, #self.icons do
    local iconEntity = self.icons[i]
    if iconEntity.iconData then
      local entityId = iconEntity.iconData.entityId
      if entityId then
        local x = TransformBus.Event.GetWorldX(entityId)
        local y = TransformBus.Event.GetWorldY(entityId)
        if not x or not y then
          UiElementBus.Event.DestroyElement(entityId)
          table.remove(self.icons, i)
        else
          local anchors = self.markersLayer:WorldPositionToAnchors(iconEntity.iconData.position)
          UiTransform2dBus.Event.SetAnchorsScript(self.icons[i].entityId, anchors)
        end
      end
    end
  end
end
function TrackedEntitiesLayer:DestroyDungeonIcons()
  for i = 1, #self.dungeonRegionIcons do
    UiElementBus.Event.DestroyElement(self.dungeonRegionIcons[i].entityId)
  end
  ClearTable(self.dungeonRegionIcons)
end
return TrackedEntitiesLayer
