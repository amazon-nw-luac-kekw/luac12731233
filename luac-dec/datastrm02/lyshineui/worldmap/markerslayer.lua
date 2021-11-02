local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local contractsDataHandler = RequireScript("LyShineUI._Common.ContractsDataHandler")
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
local MarkersLayer = {
  Properties = {
    IconPrototype = {
      default = EntityId()
    },
    SiegeClaimPointsLayer = {
      default = EntityId()
    },
    OutpostRushMapLayer = {
      default = EntityId()
    },
    PointsOfInterestLayer = {
      default = EntityId()
    },
    SettlementIconsLayer = {
      default = EntityId()
    },
    FastTravelLayer = {
      default = EntityId()
    },
    TrackedEntitiesLayer = {
      default = EntityId()
    },
    ObjectivesLayer = {
      default = EntityId()
    },
    GlobalMapEntitiesLayer = {
      default = EntityId()
    },
    ZoomFilters = {
      level1 = {
        LocalPlayer = {default = true},
        GroupMember = {default = true},
        Respawn = {default = true},
        EntityTrackingIcon = {default = false},
        PointOfInterest = {default = false},
        Territory = {default = false},
        PersonalPin = {default = true},
        Waypoint = {default = true},
        Death = {default = true},
        GroupWaypoint = {default = true},
        GroupLeaderPositions = {default = true},
        FactionInfluence = {default = true}
      },
      level2 = {
        LocalPlayer = {default = true},
        GroupMember = {default = true},
        Respawn = {default = true},
        EntityTrackingIcon = {default = false},
        PointOfInterest = {default = false},
        Territory = {default = false},
        PersonalPin = {default = true},
        Waypoint = {default = true},
        Death = {default = true},
        GroupWaypoint = {default = true},
        GroupLeaderPositions = {default = true},
        FactionInfluence = {default = true}
      },
      level3 = {
        LocalPlayer = {default = true},
        GroupMember = {default = true},
        Respawn = {default = true},
        EntityTrackingIcon = {default = false},
        PointOfInterest = {default = false},
        Territory = {default = false},
        PersonalPin = {default = true},
        Waypoint = {default = true},
        Death = {default = true},
        GroupWaypoint = {default = true},
        GroupLeaderPositions = {default = true},
        FactionInfluence = {default = true}
      },
      level4 = {
        LocalPlayer = {default = true},
        GroupMember = {default = true},
        Respawn = {default = true},
        EntityTrackingIcon = {default = false},
        PointOfInterest = {default = false},
        Territory = {default = false},
        PersonalPin = {default = true},
        Waypoint = {default = true},
        Death = {default = true},
        GroupWaypoint = {default = true},
        GroupLeaderPositions = {default = true},
        FactionInfluence = {default = true}
      },
      level5 = {
        LocalPlayer = {default = true},
        GroupMember = {default = true},
        Respawn = {default = true},
        EntityTrackingIcon = {default = false},
        PointOfInterest = {default = false},
        Territory = {default = false},
        PersonalPin = {default = true},
        Waypoint = {default = true},
        Death = {default = true},
        GroupWaypoint = {default = true},
        GroupLeaderPositions = {default = true},
        FactionInfluence = {default = true}
      },
      level6 = {
        LocalPlayer = {default = true},
        GroupMember = {default = true},
        Respawn = {default = true},
        EntityTrackingIcon = {default = false},
        PointOfInterest = {default = false},
        Territory = {default = false},
        PersonalPin = {default = true},
        Waypoint = {default = true},
        Death = {default = true},
        GroupWaypoint = {default = true},
        GroupLeaderPositions = {default = true},
        FactionInfluence = {default = true}
      },
      level7 = {
        LocalPlayer = {default = true},
        GroupMember = {default = true},
        Respawn = {default = true},
        EntityTrackingIcon = {default = false},
        PointOfInterest = {default = false},
        Territory = {default = false},
        PersonalPin = {default = true},
        Waypoint = {default = true},
        Death = {default = true},
        GroupWaypoint = {default = true},
        GroupLeaderPositions = {default = true},
        FactionInfluence = {default = true}
      }
    },
    RegionLabels = {
      map_regionText_terraVitaeAeternum = {
        position = {
          default = Vector2(4552, 2639)
        },
        scaleMod = {default = 11}
      }
    },
    IconLayers = {
      Respawn = {
        default = EntityId()
      },
      LocalPlayer = {
        default = EntityId()
      },
      GroupMember = {
        default = EntityId()
      },
      EntityTrackingIcon = {
        default = EntityId()
      },
      PointOfInterest = {
        default = EntityId()
      },
      PersonalPin = {
        default = EntityId()
      },
      Waypoint = {
        default = EntityId()
      },
      Territory = {
        default = EntityId()
      },
      Death = {
        default = EntityId()
      },
      GroupWaypoint = {
        default = EntityId()
      }
    },
    OptionFilters = {
      LocalPlayer = {default = true},
      GroupMember = {default = true},
      Respawn = {default = true},
      EntityTrackingIcon = {default = true},
      PointOfInterest = {default = true},
      Territory = {default = true},
      PersonalPin = {default = true},
      Waypoint = {default = true},
      Death = {default = true},
      GroupWaypoint = {default = true},
      FactionInfluence = {default = true}
    }
  },
  mapFilters = {},
  visibleWorldBounds = {
    left = 0,
    top = 0,
    width = 0,
    height = 0
  },
  playerLoc = Vector3(0, 0, 0),
  outpostIndexes = {},
  protectionRadiusText = "@ui_settlementprotectionradius",
  simplePOIs = {},
  newPOIs = {}
}
BaseElement:CreateNewElement(MarkersLayer)
function MarkersLayer:OnInit()
  BaseElement.OnInit(self)
  self.iconTypes = mapTypes.iconTypes
  self.sourceTypes = mapTypes.sourceTypes
  self.dataLayer = dataLayer
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.mapComponentEventBusHandler = self:BusConnect(MapComponentEventBus)
  self.groupsUINotificationBusHandler = self:BusConnect(GroupsUINotificationBus)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableTerritoryMechanics", function(self, enableTerritoryMechanics)
    self.enableTerritoryMechanics = enableTerritoryMechanics
  end)
  self.playerLoc = Vector3(0, 0, 0)
  self.homePointsData = {}
  self.currentZoomLevel = 1
  self.mapIcons = {}
  self.onDemandDatalayerPaths = {}
  self.sourceType = self.sourceTypes.Map
  self.mapIcons[self.iconTypes.AttackNotification] = {}
  local iconData = {
    index = 1,
    iconType = self.iconTypes.AttackNotification,
    dataManagerId = self.entityId,
    parentEntity = self.entityId,
    sourceType = self.sourceType
  }
  local clonedEntityId = UiCanvasBus.Event.CloneElement(self.canvasId, self.Properties.IconPrototype, self.entityId, EntityId())
  local entity = self.registrar:GetEntityTable(clonedEntityId)
  self:SetMapIconData(entity, iconData)
  self.mapIcons[self.iconTypes.RaidGroupLeader] = {}
  local maxGroups = GroupsRequestBus.Broadcast.GetMaxNumGroupsPerRaid()
  if maxGroups then
    for i = 1, maxGroups do
      local iconData = {
        index = i,
        iconType = self.iconTypes.RaidGroupLeader,
        dataManagerId = self.entityId,
        parentEntity = self.entityId,
        sourceType = self.sourceType
      }
      local clonedEntityId = UiCanvasBus.Event.CloneElement(self.canvasId, self.Properties.IconPrototype, self.entityId, EntityId())
      local entity = self.registrar:GetEntityTable(clonedEntityId)
      self:SetMapIconData(entity, iconData)
    end
  end
  self.subLayers = {
    self.PointsOfInterestLayer,
    self.SettlementIconsLayer,
    self.FastTravelLayer,
    self.TrackedEntitiesLayer,
    self.GlobalMapEntitiesLayer,
    self.ObjectivesLayer,
    self.SiegeClaimPointsLayer,
    self.OutpostRushMapLayer
  }
end
function MarkersLayer:OnShutdown()
  if self.dataLayer then
    self.dataLayer:UnregisterObservers(self)
    self.dataLayer = nil
  end
end
function MarkersLayer:SetMagicMap(magicMap)
  self.MagicMap = magicMap
  for k, layer in ipairs(self.subLayers) do
    if type(layer) == "table" then
      layer:SetMarkersLayer(self)
    end
  end
end
function MarkersLayer:SetWorldMapData(worldMapData, visibleWorldBounds)
  self.worldMapData = worldMapData
  self.visibleWorldBounds = visibleWorldBounds
  self.dataLayer:RegisterObserver(self, "Hud.LocalPlayer.PlayerName", self.OnPlayerNameChanged, false, true)
  self:UpdateMapFilters()
  self:UpdateMapIconCount(self.iconTypes.LocalPlayer, 1)
  self:UpdateMapIconCount(self.iconTypes.Waypoint, 1)
  self:UpdateMapIconCount(self.iconTypes.Death, 1)
  self:UpdateMapIconCount(self.iconTypes.AttackNotification, 1)
  self:UpdateRegionLabels()
  for k, layer in ipairs(self.subLayers) do
    if type(layer) == "table" then
      layer:SetWorldMapData(worldMapData, visibleWorldBounds)
    end
  end
  if self.sourceType ~= self.sourceTypes.MainMenu then
    self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_enablePOIDebugText", function(self, isPOIDebugTextEnabled)
      self.isPOIDebugTextEnabled = isPOIDebugTextEnabled
    end)
    self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_enableContracts", function(self, isContractsEnabled)
      self.isContractsEnabled = isContractsEnabled
    end)
    self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_enablePOIDiscovery", function(self, isPOIDiscoveryEnabled)
      self.isPOIDiscoveryEnabled = isPOIDiscoveryEnabled
      if not self.worldDataSet then
        if (self.sourceType == self.sourceTypes.Map or self.sourceType == self.sourceTypes.RespawnMap) and not self.mapIconsAttachedToEntities then
          ShowOnMapUIComponentRequestBus.Broadcast.UpdateVisibility(true)
        end
        self.worldDataSet = true
      end
    end)
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Group.MaxMembers", self.OnSetMaxGroupMembers)
  end
end
function MarkersLayer:SetSourceType(sourceType)
  self.sourceType = sourceType
  if sourceType ~= self.sourceTypes.Map and sourceType == self.sourceTypes.MainMenu then
    if self.mapComponentEventBusHandler then
      self:BusDisconnect(self.mapComponentEventBusHandler)
      self.mapComponentEventBusHandler = nil
    end
    if self.groupsUINotificationBusHandler then
      self:BusDisconnect(self.groupsUINotificationBusHandler)
      self.groupsUINotificationBusHandler = nil
    end
  end
end
function MarkersLayer:OnSetMaxGroupMembers(maxGroupMembers)
  if maxGroupMembers then
    self:UpdateMapIconCount(self.iconTypes.GroupMember, maxGroupMembers)
    self:UpdateMapIconCount(self.iconTypes.GroupWaypoint, maxGroupMembers)
  end
end
function MarkersLayer:OnPlayerNameChanged(dataNode)
  if dataNode:GetData() then
    self.playerName = dataNode:GetData()
  end
end
function MarkersLayer:UpdateRegionLabels()
  self.mapIcons[self.iconTypes.Region] = {}
  for key, region in pairs(self.Properties.RegionLabels) do
    if type(region.position) ~= "userdata" then
      return
    end
    local anchors = self:WorldPositionToAnchors(region.position)
    local iconData = {
      index = key,
      iconType = self.iconTypes.Region,
      dataManagerId = self.entityId,
      parentEntity = self.entityId,
      sourceType = self.sourceType,
      anchors = anchors,
      imageFGColor = Color(1, 1, 1),
      imageFGPath = "LyShineUI/Images/Map/" .. tostring(key) .. ".png",
      scalesWithZoom = true,
      scale = region.scaleMod,
      minScale = region.scaleMod,
      maxScale = 9 + region.scaleMod
    }
    local clonedEntityId = UiCanvasBus.Event.CloneElement(self.canvasId, self.Properties.IconPrototype, self.entityId, EntityId())
    local entity = self.registrar:GetEntityTable(clonedEntityId)
    self:SetMapIconData(entity, iconData)
  end
end
function MarkersLayer:UpdateRespawnPoints(countNode)
  local mapIconCount = 0
  local count = countNode or 0
  local homepointIndices = {}
  for i = 1, count do
    local homePointType = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HomePoints." .. i .. ".Type")
    if homePointType == "Private" or homePointType == "Camp" then
      mapIconCount = mapIconCount + 1
      table.insert(homepointIndices, i)
    end
  end
  self:UpdateMapIconCount(self.iconTypes.Respawn, mapIconCount, homepointIndices)
end
function MarkersLayer:SetZoomFilter(zoomLevel)
  if self.Properties.ZoomFilters["level" .. zoomLevel] == nil then
    Debug.Log("[MarkersLayer:SetZoomFilter] Invalid zoom level: " .. tostring(zoomLevel))
    return
  end
  if self.currentZoomLevel ~= zoomLevel then
    self.currentZoomLevel = zoomLevel
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
    self:UpdateMapFilters()
  end
  if self.Properties.SettlementIconsLayer:IsValid() then
    self.SettlementIconsLayer:SetZoomLevel(zoomLevel)
  end
  if self.Properties.OutpostRushMapLayer:IsValid() then
    self.OutpostRushMapLayer:SetZoomLevel(zoomLevel)
  end
end
function MarkersLayer:SetOptionFilter(iconType, isEnabled)
  if self.Properties.OptionFilters[iconType] == nil then
    Debug.Log("[MarkersLayer:SetOptionFilter] Invalid option filter: " .. tostring(iconType))
    return
  end
  if self.Properties.OptionFilters[iconType] ~= isEnabled then
    self.Properties.OptionFilters[iconType] = isEnabled
    self:UpdateMapFilters()
  end
end
function MarkersLayer:UpdateMapFilters()
  if not self.updatedFilters then
    self.updatedFilters = {}
  end
  ClearTable(self.updatedFilters)
  local currentZoomFilter = self.Properties.ZoomFilters["level" .. self.currentZoomLevel]
  for zoomType, zoomEnabled in pairs(currentZoomFilter) do
    local weightedFilter = self.Properties.OptionFilters[zoomType]
    if not zoomEnabled and weightedFilter ~= zoomEnabled then
      weightedFilter = zoomEnabled
    end
    if weightedFilter ~= self.mapFilters[zoomType] then
      self.updatedFilters[zoomType] = weightedFilter
    end
    self.mapFilters[zoomType] = weightedFilter
  end
  for iconType, isEnabled in pairs(self.updatedFilters) do
    LyShineDataLayerBus.Broadcast.SetData("Map.Filter." .. self.sourceType .. "." .. tostring(iconType), isEnabled)
  end
end
function MarkersLayer:WorldPositionToAnchors(pos)
  local dx = (pos.x - self.visibleWorldBounds.left) / self.visibleWorldBounds.width
  local dy = (self.visibleWorldBounds.top - pos.y) / self.visibleWorldBounds.height
  local anchors = UiAnchors(dx, dy, dx, dy)
  return anchors
end
function MarkersLayer:OnHoverStart(entityId, actionName)
  self.audioHelper:PlaySound(self.audioHelper.OnHover_MarkersLayer)
end
function MarkersLayer:OnOkPressed(entityId, actionName)
  self.audioHelper:PlaySound(self.audioHelper.Accept)
end
function MarkersLayer:SetRespondingToDataUpdates(isResponding)
  if isResponding then
    if self.sourceType ~= self.sourceTypes.MainMenu then
      self.onDemandDatalayerPaths["Hud.LocalPlayer.Guild.LastBuildableAttacked.AttackingGuild"] = self.UpdateAttackNotification
      self.onDemandDatalayerPaths["Hud.LocalPlayer.HomePoints.Count"] = self.UpdateRespawnPoints
      self.onDemandDatalayerPaths["Hud.LocalPlayer.Raid.Id"] = self.UpdateRaid
      self.onDemandDatalayerPaths["Hud.LocalPlayer.Group.Id"] = self.UpdateGroup
    end
    self.onDemandDatalayerPaths["Hud.LocalPlayer.Position"] = self.UpdateLocalPlayerPosition
    self.onDemandDatalayerPaths["Hud.LocalPlayer.PlayerHeading"] = self.UpdateLocalPlayerRotation
    for path, callback in pairs(self.onDemandDatalayerPaths) do
      self.dataLayer:RegisterAndExecuteDataObserver(self, path, callback)
    end
  else
    for path, callback in pairs(self.onDemandDatalayerPaths) do
      self.dataLayer:UnregisterObserver(self, path)
    end
    ClearTable(self.onDemandDatalayerPaths)
  end
end
function MarkersLayer:SetIsVisible(isVisible)
  if self.isVisible == isVisible then
    return
  end
  self.isVisible = isVisible
  if isVisible and self.isContractsEnabled and self.sourceType ~= self.sourceTypes.MainMenu then
    self:UpdateOutposts()
  end
  if self.Properties.PointsOfInterestLayer:IsValid() then
    self.PointsOfInterestLayer:SetIsVisible(isVisible)
  end
  if self.Properties.TrackedEntitiesLayer:IsValid() then
    self.TrackedEntitiesLayer:SetIsVisible(isVisible)
  end
  if self.Properties.GlobalMapEntitiesLayer:IsValid() then
    self.GlobalMapEntitiesLayer:SetIsVisible(isVisible)
  end
  if self.Properties.ObjectivesLayer:IsValid() then
    self.ObjectivesLayer:SetIsVisible(isVisible)
  end
  if self.Properties.SettlementIconsLayer:IsValid() then
    self.SettlementIconsLayer:SetIsVisible(isVisible)
  end
  if self.Properties.FastTravelLayer:IsValid() then
    self.FastTravelLayer:SetIsVisible(isVisible)
  end
  for iconType, iconsOfType in pairs(self.mapIcons) do
    for i = 1, #iconsOfType do
      local icon = iconsOfType[i]
      if icon then
        icon:OnIsShowingChanged(isVisible)
      end
    end
  end
end
function MarkersLayer:UpdateOutposts()
  if not self.mapIcons[self.iconTypes.PointOfInterest] then
    return
  end
  local outposts = MapComponentBus.Broadcast.GetOutposts()
  for i = 1, #outposts do
    local capitalIndex = self.outpostIndexes[outposts[i].monikerId]
    local entity = self.mapIcons[self.iconTypes.PointOfInterest][capitalIndex]
    if entity and entity.iconData and outposts[i].monikerId == entity.iconData.monikerId then
      entity.iconData.outpostId = outposts[i].id
      local contractCount = AggregateContractCountRequestBus.Broadcast.GetAggregateContractCount(outposts[i].id)
      self:UpdateOutpostContractCount(capitalIndex, contractCount)
    end
  end
end
function MarkersLayer:UpdateOutpostContractCount(outpostIndex, numContracts)
  local iconEntity = self.mapIcons[self.iconTypes.PointOfInterest][outpostIndex]
  if not iconEntity then
    Debug.Log("UpdateOutpostContractCount: iconEntity not available for outpost at index: " .. tostring(outpostIndex))
    return
  end
  iconEntity:SetContractCounts(numContracts)
end
function MarkersLayer:UpdateRaid(raidId)
  local groupIds = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Raid.GroupIds")
  local myGroupId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Group.Id")
  if raidId and raidId:IsValid() and groupIds and myGroupId and myGroupId:IsValid() then
    for i, icon in ipairs(self.mapIcons[self.iconTypes.RaidGroupLeader]) do
      if not myGroupId:Equal(groupIds[i]) then
        icon:SetRaidGroupData(groupIds[i])
      end
    end
  else
    for i, icon in ipairs(self.mapIcons[self.iconTypes.RaidGroupLeader]) do
      icon:SetRaidGroupData(GroupId())
    end
  end
end
function MarkersLayer:UpdateGroup(groupId)
  local isInGroup = groupId and groupId:IsValid()
  if not isInGroup then
    self:UpdateLocalPlayerColor(1)
  end
end
function MarkersLayer:UpdateAttackNotification(attackingGuildName)
  if self.mapIcons.AttackNotification and self.mapIcons.AttackNotification[1] and attackingGuildName and attackingGuildName ~= "" then
    self.mapIcons.AttackNotification[1]:UpdateAttackNotification(attackingGuildName)
  end
end
function MarkersLayer:RemoveIconsOfType(iconType)
  local icons = self.mapIcons[iconType]
  if icons then
    for index, iconData in pairs(icons) do
      if iconData.entityId then
        UiElementBus.Event.DestroyElement(iconData.entityId)
      end
      icons[index] = nil
    end
  end
end
function MarkersLayer:UpdateMapIconCount(iconType, count, customData)
  if not self.mapIcons[iconType] then
    self.mapIcons[iconType] = {}
  end
  local oldCount = #self.mapIcons[iconType]
  if count < oldCount then
    for i = count + 1, oldCount do
      UiElementBus.Event.DestroyElement(self.mapIcons[iconType][i].entityId)
      self.mapIcons[iconType][i] = nil
    end
  else
    local parentEntity = self.Properties.IconLayers[iconType] or self.entityId
    for i = oldCount + 1, count do
      local iconData = {
        index = i,
        iconType = iconType,
        dataManagerId = self.entityId,
        parentEntity = parentEntity,
        sourceType = self.sourceType,
        customData = customData
      }
      local clonedEntityId = UiCanvasBus.Event.CloneElement(self.canvasId, self.Properties.IconPrototype, self.entityId, EntityId())
      local entity = self.registrar:GetEntityTable(clonedEntityId)
      self:SetMapIconData(entity, iconData)
    end
  end
end
function MarkersLayer:HighlightPOI(id, showDistance)
  local capitalIndex = self.outpostIndexes[id]
  if self.mapIcons.PointOfInterest[capitalIndex] then
    self.mapIcons.PointOfInterest[capitalIndex]:ShowHighlight(showDistance, Color(1, 0.5, 0))
  end
end
function MarkersLayer:ClearHighlightPOI(id)
  local capitalIndex = self.outpostIndexes[id]
  if self.mapIcons.PointOfInterest[capitalIndex] then
    self.mapIcons.PointOfInterest[capitalIndex]:ClearHighlight()
  end
end
function MarkersLayer:PulseAllNewPOIs()
  for id, isNew in pairs(self.newPOIs) do
    self:PulseNewPOI(id)
  end
end
function MarkersLayer:ClearAllNewPOIs()
  for id, isNew in pairs(self.newPOIs) do
    self:ClearNewPOI(id)
  end
end
function MarkersLayer:PulseNewPOI(id)
  local poiIconTable = self.mapIcons.PointOfInterest[id]
  local isNewPoi = self.newPOIs[id] or false
  if poiIconTable and isNewPoi then
    local startColor = self.UIStyle.COLOR_TAN_LIGHT
    local endColor = self.UIStyle.COLOR_TAN_LIGHT
    local pulseRadius = 50
    poiIconTable:CreatePulse(startColor, endColor, pulseRadius)
  end
end
function MarkersLayer:ClearNewPOI(id)
  self.newPOIs[id] = nil
  local poiIconTable = self.mapIcons.PointOfInterest[id]
  if poiIconTable then
    poiIconTable:ClearPulse()
  end
end
function MarkersLayer:SetMapIconData(entity, iconData)
  if not self.mapIcons[iconData.iconType] then
    UiElementBus.Event.DestroyElement(entity.entityId)
    Debug.Log("SetMapIconData: map icon has invalid type (" .. tostring(iconData.iconType) .. ")")
    return
  end
  if iconData.index then
    self.mapIcons[iconData.iconType][iconData.index] = entity
    if iconData.iconType == self.iconTypes.PointOfInterest and iconData.isNew then
      self.newPOIs[iconData.index] = true
      if self.isVisible then
        self:PulseNewPOI(iconData.index)
      end
    end
  elseif iconData.addToMapIconsList then
    if not self.mapIcons[iconData.iconType] then
      self.mapIcons[iconData.iconType] = {}
    end
    table.insert(self.mapIcons[iconData.iconType], entity)
  end
  entity:SetData(iconData)
  UiElementBus.Event.Reparent(entity.entityId, iconData.parentEntity, EntityId())
end
function MarkersLayer:UpdateLocalPlayerColor(groupIndex)
  if self.groupIndex == groupIndex then
    return
  end
  self.groupIndex = groupIndex
  local color = self.UIStyle.COLOR_GROUP_MEMBERS[groupIndex]
  if self.mapIcons[self.iconTypes.LocalPlayer] and self.mapIcons[self.iconTypes.LocalPlayer][1] then
    self.mapIcons[self.iconTypes.LocalPlayer][1]:SetColorOverride(color)
  end
  if self.mapIcons[self.iconTypes.Waypoint] and self.mapIcons[self.iconTypes.Waypoint][1] then
    self.mapIcons[self.iconTypes.Waypoint][1]:SetColorOverride(color)
  end
end
function MarkersLayer:UpdateLocalPlayerRotation(rotation)
  if self.mapIcons[self.iconTypes.LocalPlayer] and self.mapIcons[self.iconTypes.LocalPlayer][1] then
    self.mapIcons[self.iconTypes.LocalPlayer][1]:SetRotationZ(rotation)
  end
end
function MarkersLayer:UpdateLocalPlayerPosition(pos)
  if self.mapIcons[self.iconTypes.LocalPlayer] and self.mapIcons[self.iconTypes.LocalPlayer][1] then
    self.mapIcons[self.iconTypes.LocalPlayer][1]:OnPositionChanged(pos)
  end
end
function MarkersLayer:CapitalizeText(text)
  return text:gsub("^%l", string.upper)
end
return MarkersLayer
