local SettlementIconsLayer = {
  Properties = {}
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(SettlementIconsLayer)
function SettlementIconsLayer:OnInit()
  self.isLandmarkDataReady = false
  self.settlementIcons = {}
  local idx = 1
  repeat
    local iconEntity = UiElementBus.Event.FindChildByName(self.entityId, string.format("CollapsibleSettlementIcon%d", idx))
    local settlementIcon = self.registrar:GetEntityTable(iconEntity)
    if settlementIcon then
      if not self.csiPrototype then
        self.csiPrototype = settlementIcon
      else
        table.insert(self.settlementIcons, settlementIcon)
      end
    end
    idx = idx + 1
  until not settlementIcon
end
function SettlementIconsLayer:SetMarkersLayer(markersLayer)
  self.markersLayer = markersLayer
  self.iconTypes = markersLayer.iconTypes
  self.sourceType = markersLayer.sourceType
end
function SettlementIconsLayer:SetWorldMapData(worldMapData, visibleWorldBounds)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.LandmarkDataReady", function(self, ready)
    if self.isLandmarkDataReady ~= ready then
      self.isLandmarkDataReady = ready
      if ready then
        self:AddMapSettlements()
      else
        ObjectiveInteractorRequestBus.Broadcast.UpdateLandmarkDataAvailability()
      end
    elseif ready then
      if self.iconCount == 0 then
        self:AddMapSettlements()
      end
      self:UpdateSettlementsVisibility()
    end
  end)
  self:SetZoomLevel(self.markersLayer.currentZoomLevel)
end
function SettlementIconsLayer:SetIsVisible(isVisible)
  if isVisible then
    for i = 1, #self.settlementIcons do
      self.settlementIcons[i]:SetSettlementIconVisible(isVisible)
      self.settlementIcons[i]:SetClaimPointIconVisible(isVisible)
    end
  end
end
function SettlementIconsLayer:SetZoomLevel(zoomLevel)
  for i = 1, #self.settlementIcons do
    self.settlementIcons[i]:SetZoomLevel(zoomLevel)
  end
end
function SettlementIconsLayer:AddSettlementIcon(iconData)
  local icon = self.settlementIcons[self.iconCount + 1]
  if not icon then
    local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
    local parent = UiElementBus.Event.GetParent(self.csiPrototype.entityId)
    icon = CloneUiElement(canvasId, self.registrar, self.csiPrototype.entityId, parent, false)
    self.settlementIcons[self.iconCount + 1] = icon
  end
  if icon then
    self.iconCount = self.iconCount + 1
    icon:SetSettlementIcon(self.markersLayer, iconData)
    UiElementBus.Event.SetIsEnabled(icon.entityId, true)
  end
end
function SettlementIconsLayer:UpdateSettlementsVisibility()
  for i = 1, #self.settlementIcons do
    self.settlementIcons[i]:UpdateAnchorsAndVisiblity()
  end
end
function SettlementIconsLayer:AddMapSettlements()
  self.iconCount = 0
  local outpostsAndSettlements = ObjectiveInteractorRequestBus.Broadcast.GetOutpostDestinations()
  if outpostsAndSettlements then
    for i = 1, #outpostsAndSettlements do
      local locationData = outpostsAndSettlements[i]
      local definition = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(locationData.territoryId)
      local iconType = definition.isTerritory and self.iconTypes.Settlement or self.iconTypes.Outpost
      local iconData = {
        iconType = iconType,
        actorId = locationData.id,
        worldPosition = locationData.worldPosition,
        name = locationData.nameLocalizationKey,
        territoryId = locationData.territoryId,
        anchors = UiAnchors(0.5, 0.5, 0.5, 0.5),
        parentEntity = self.entityId,
        sourceType = self.sourceType
      }
      self:AddSettlementIcon(iconData)
    end
  end
  local claims = ObjectiveInteractorRequestBus.Broadcast.GetClaimDestinations()
  if claims then
    for i = 1, #claims do
      local locationData = claims[i]
      local iconData = {
        iconType = self.iconTypes.Territory,
        actorId = locationData.id,
        worldPosition = locationData.worldPosition,
        name = locationData.nameLocalizationKey,
        territoryId = locationData.territoryId,
        anchors = UiAnchors(0.5, 0.5, 0.5, 0.5),
        parentEntity = self.entityId,
        sourceType = self.sourceType
      }
      self:AddSettlementIcon(iconData)
    end
  end
end
return SettlementIconsLayer
