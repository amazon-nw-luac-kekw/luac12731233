local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local Spawner = RequireScript("LyShineUI._Common.Spawner")
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local SlashCommands = RequireScript("LyShineUI.SlashCommands")
local WorldMapData = {
  NewWorld_VitaeEterna = {
    id = "NewWorld_VitaeEterna",
    folder = "LyShineUI/WorldTiles/NewWorld_VitaeEterna",
    bounds = {
      left = 4416,
      top = 10496,
      width = 9920,
      height = 10496
    },
    minZoom = 1,
    maxZoom = 7
  },
  OutpostRush = {
    id = "OutpostRush",
    folder = "LyShineUI/WorldTiles/OutpostRush",
    bounds = {
      left = 921,
      top = 11588,
      width = 721,
      height = 970
    },
    minZoom = 1,
    maxZoom = 4,
    hidePOILayer = true
  },
  DevWorld = {
    id = "DevWorld",
    folder = "LyShineUI/WorldTiles/DevWorld",
    bounds = {
      left = 0,
      top = 2048,
      width = 2048,
      height = 2048
    },
    minZoom = 1,
    maxZoom = 6
  },
  NW_Dungeon_Windsward_00 = {
    id = "NW_Dungeon_Windsward_00",
    folder = "LyShineUI/WorldTiles/NW_Dungeon_Windsward_00",
    bounds = {
      left = 616,
      top = 1064,
      width = 360,
      height = 540
    },
    minZoom = 1,
    maxZoom = 4,
    hidePOILayer = true
  },
  NW_Dungeon_Edengrove_00 = {
    id = "NW_Dungeon_Edengrove_00",
    folder = "LyShineUI/WorldTiles/NW_Dungeon_Edengrove_00",
    bounds = {
      left = 336,
      top = 1616,
      width = 572,
      height = 600
    },
    minZoom = 1,
    maxZoom = 4,
    hidePOILayer = true
  },
  NW_Dungeon_Everfall_00 = {
    id = "NW_Dungeon_Everfall_00",
    folder = "LyShineUI/WorldTiles/NW_Dungeon_Everfall_00",
    bounds = {
      left = 324,
      top = 1080,
      width = 480,
      height = 540
    },
    minZoom = 1,
    maxZoom = 4,
    hidePOILayer = true
  },
  NW_Dungeon_RestlessShores_00 = {
    id = "NW_Dungeon_RestlessShores_00",
    folder = "LyShineUI/WorldTiles/NW_Dungeon_RestlessShores_00",
    bounds = {
      left = 176,
      top = 600,
      width = 600,
      height = 480
    },
    minZoom = 1,
    maxZoom = 4,
    hidePOILayer = true
  },
  NW_Dungeon_RestlessShores_01 = {
    id = "NW_Dungeon_RestlessShores_01",
    folder = "LyShineUI/WorldTiles/NW_Dungeon_RestlessShores_01",
    bounds = {
      left = 680,
      top = 1380,
      width = 564,
      height = 580
    },
    minZoom = 1,
    maxZoom = 4,
    hidePOILayer = true
  },
  NW_Dungeon_Reekwater_00 = {
    id = "NW_Dungeon_Reekwater_00",
    folder = "LyShineUI/WorldTiles/NW_Dungeon_Reekwater_00",
    bounds = {
      left = 640,
      top = 980,
      width = 360,
      height = 440
    },
    minZoom = 1,
    maxZoom = 4,
    hidePOILayer = true
  }
}
local MagicMap = {
  Properties = {
    TileCache = {
      default = EntityId()
    },
    TilePrototype = {
      default = EntityId()
    },
    ActionMapActivators = {
      default = {""}
    },
    UseActionMapActivators = {default = true},
    ContentElement = {
      default = EntityId()
    },
    MaskElement = {
      default = EntityId()
    },
    TerrainLayer = {
      default = EntityId()
    },
    Zooms = {
      default = {
        EntityId(),
        EntityId(),
        EntityId(),
        EntityId(),
        EntityId(),
        EntityId(),
        EntityId(),
        EntityId(),
        EntityId(),
        EntityId(),
        EntityId()
      }
    },
    MarkersLayer = {
      default = EntityId()
    },
    TerritoriesLayer = {
      default = EntityId()
    },
    ScaleText = {
      default = EntityId()
    },
    InitialZoomLevel = {default = 1},
    CenterTransitionDistanceThreshold = {default = 5},
    CenterTransitionRate = {default = 0.15},
    TransitionTime = {default = 0.25},
    IsMiniMap = {default = false},
    IsRespawnMap = {default = false},
    IsMainMenuMap = {default = false},
    BaseScaleWidth = {default = 200},
    WheelMoveDelay = {default = 1},
    GradientParent = {
      default = EntityId()
    },
    IsGradientVisible = {default = false},
    PingEntity = {
      default = EntityId()
    },
    PingIcon = {
      default = EntityId()
    },
    PingIconPulse = {
      default = EntityId()
    },
    DummyCenterTween = {
      default = EntityId()
    },
    WorldBounds = {
      left = {default = 0},
      top = {default = 4096},
      width = {default = 4096},
      height = {default = 4096}
    },
    TileSizeMeters = {
      width = {default = 256},
      height = {default = 256}
    },
    ConnectToDynamicBus = {default = false}
  },
  MOUSE_WHEEL_DELTA = 120,
  tiles = {},
  loadingTiles = {},
  currentLevel = 1,
  desiredLevel = 1,
  previousLevel = 1,
  previousDesiredLevel = 1,
  previousContentPosition = Vector2(0, 0),
  inTransition = 0,
  timeSinceLastWheel = 0,
  timeSinceStartDrag = 0,
  dragRate = 0,
  lastDragTickPos = Vector2(0, 0),
  currentDragTickPos = Vector2(0, 0),
  clickThreshold = 0.25,
  levelCount = 7,
  minLevel = 1,
  levelMPP = nil,
  contentPosition = Vector2(0, 0),
  tileHead = nil,
  tileTail = nil,
  tileCount = 0,
  worldBoundsInTiles = {
    left = 0,
    top = 0,
    width = 0,
    height = 0
  },
  windowWidth = 1860,
  windowHeight = 930,
  tileMax = 24,
  tileSizeInPixels = 1024,
  scaleOne = Vector2(1, 1),
  pivotCenter = Vector2(0.5, 0.5),
  vectorZero = Vector2:CreateZero(),
  debugShowCoords = false
}
BaseElement:CreateNewElement(MagicMap)
Spawner:AttachSpawner(MagicMap)
function MagicMap:OnInit()
  BaseElement.OnInit(self)
  self.sourceTypes = mapTypes.sourceTypes
  if LyShineScriptBindRequestBus.Broadcast.IsEditor() then
    self.MOUSE_WHEEL_DELTA = 240
  end
  self.windowWidth = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.windowHeight = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  self.tileMax = (math.ceil(self.windowWidth / self.tileSizeInPixels) + 1) * (math.ceil(self.windowHeight / self.tileSizeInPixels) + 1) * 2
  self.zoomToContentLevel = {
    1,
    2,
    3,
    4,
    5,
    6,
    7
  }
  self.virtualTilesPerTile = {
    1,
    2,
    4,
    8,
    16,
    32,
    64
  }
  self.levelMPP = {
    0.25,
    0.5,
    1,
    2,
    4,
    8,
    16
  }
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.filenameExistenceMap = {}
  self.cachedTiles = {
    self.TilePrototype
  }
  for i = 1, self.tileMax do
    local cloneEntity = UiCanvasBus.Event.CloneElement(self.canvasId, self.Properties.TilePrototype, self.Properties.TileCache, EntityId())
    clone = self.registrar:GetEntityTable(cloneEntity)
    table.insert(self.cachedTiles, clone)
  end
  self.sourceType = self.sourceTypes.Map
  if self.Properties.IsMiniMap then
    self.sourceType = self.sourceTypes.MiniMap
  elseif self.Properties.IsRespawnMap then
    self.sourceType = self.sourceTypes.RespawnMap
  elseif self.Properties.IsMainMenuMap then
    self.sourceType = self.sourceTypes.MainMenu
  end
  SlashCommands:RegisterSlashCommand("loadmap", self.OnSlashLoadMap, self)
  self.MarkersLayer:SetMagicMap(self)
  self.TerritoriesLayer:SetMagicMap(self)
  self.TerritoriesLayer:SetZoomLevel(self.desiredLevel)
  self.MarkersLayer:SetSourceType(self.sourceType)
  self:SetDefaultWorld()
  self:BusConnect(DynamicBus.UITickBus)
  self:BusConnect(UiScrollBoxNotificationBus, self.entityId)
  self:BusConnect(UiCanvasNotificationBus, self.canvasId)
  self:BusConnect(LyShineManagerNotificationBus, self.canvasId)
  self:BusConnect(CrySystemNotificationsBus)
  self:BusConnect(LoadScreenNotificationBus, self.entityId)
  DynamicBus.WorldMapDataBus.Connect(self.entityId, self)
  if self.ConnectToDynamicBus then
    DynamicBus.MagicMap.Connect(self.entityId, self)
  end
  self.lastRequest = nil
  UiElementBus.Event.SetIsEnabled(self.Properties.GradientParent, self.Properties.IsGradientVisible)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.showCoordsOnMap", function(self, showCoords)
    self.debugShowCoords = showCoords
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.IsLandClaimManagerAvailable", function(self, isAvailable)
    if isAvailable and self.worldMapData and not self.worldMapData.hidePOILayer then
      self.TerritoriesLayer:CreateTerritoryOverlays()
    end
  end)
  UiElementBus.Event.SetIsEnabled(self.Properties.PingEntity, false)
  self.isVisible = false
  self.onInitFinished = true
  local initCount = self.dataLayer:GetDataFromNode("Map.InitCount") or 0
  LyShineDataLayerBus.Broadcast.SetData("Map.InitCount", initCount + 1)
end
function MagicMap:SetDefaultWorld()
  if GameRequestsBus.Broadcast.IsDevWorld() then
    self:SetWorldMapData(WorldMapData.DevWorld)
  else
    self:SetWorldMapData(WorldMapData.NewWorld_VitaeEterna)
  end
end
function MagicMap:OnSlashLoadMap(args)
  local aliases = {
    main = "NewWorld_VitaeEterna",
    ["or"] = "OutpostRush",
    dw = "DevWorld",
    ["dung-w"] = "NW_Dungeon_Windsward_00"
  }
  if 2 <= #args then
    local worldId = args[2]
    local alias = string.lower(worldId)
    if aliases[alias] then
      worldId = aliases[alias]
    end
    self:SetWorldMapDataById(worldId)
  end
end
function MagicMap:IsWorldPositionInBounds(worldPosition, bounds)
  return worldPosition.x > bounds.left and worldPosition.x < bounds.left + bounds.width and worldPosition.y < bounds.top and worldPosition.y > bounds.top - bounds.height
end
function MagicMap:SetWorldMapDataById(id)
  if WorldMapData[id] then
    self:SetWorldMapData(WorldMapData[id])
  else
    Log("Invalid map id %s", tostring(id))
  end
end
function MagicMap:SetWorldMapData(worldMapData)
  self:ClearAllTiles()
  self.worldMapData = worldMapData
  local widthAdjust = self.windowWidth * self.levelMPP[self.levelCount]
  local heightAdjust = self.windowHeight * self.levelMPP[self.levelCount]
  self.visibleWorldBounds = {
    left = worldMapData.bounds.left,
    top = worldMapData.bounds.top,
    width = worldMapData.bounds.width,
    height = worldMapData.bounds.height
  }
  self.visibleWorldBounds.left = self.visibleWorldBounds.left - widthAdjust
  self.visibleWorldBounds.width = self.visibleWorldBounds.width + widthAdjust * 2
  self.visibleWorldBounds.top = self.visibleWorldBounds.top + heightAdjust
  self.visibleWorldBounds.height = self.visibleWorldBounds.height + heightAdjust * 2
  local bottomLeftTile = self:WorldPositionToTile({
    x = self.visibleWorldBounds.left,
    y = self.visibleWorldBounds.top - self.visibleWorldBounds.height
  }, false)
  local topRightTile = self:WorldPositionToTile({
    x = self.visibleWorldBounds.left + self.visibleWorldBounds.width,
    y = self.visibleWorldBounds.top
  }, true)
  self.worldBoundsInTiles.left = bottomLeftTile.tx
  self.worldBoundsInTiles.bottom = bottomLeftTile.ty
  self.worldBoundsInTiles.right = topRightTile.tx
  self.worldBoundsInTiles.top = topRightTile.ty
  self.worldBoundsInTiles.width = self.worldBoundsInTiles.right - self.worldBoundsInTiles.left + 1
  self.worldBoundsInTiles.height = self.worldBoundsInTiles.top - self.worldBoundsInTiles.bottom + 1
  for level = 1, self.levelCount do
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.Zooms[level], self.visibleWorldBounds.width / self.levelMPP[level])
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.Zooms[level], self.visibleWorldBounds.height / self.levelMPP[level])
    UiElementBus.Event.SetIsEnabled(self.Properties.Zooms[level], false)
  end
  self.desiredLevel = math.max(self.minLevel, math.min(self.Properties.InitialZoomLevel, self.levelCount))
  self:SetZoom(self.desiredLevel)
  self.MarkersLayer:SetWorldMapData(self.worldMapData, self.visibleWorldBounds)
  self.TerritoriesLayer:SetWorldMapData(self.worldMapData, self.visibleWorldBounds)
  self.TerritoriesLayer:SetZoomLevel(self.desiredLevel)
  self.TerritoriesLayer:SetIsVisible(not self.worldMapData.hidePOILayer)
  ShowOnMapUIComponentRequestBus.Broadcast.UpdateVisibility(true)
  self.lastRequest = nil
  self:UpdateVisibleTiles()
end
function MagicMap:UnloadTextures()
  for _, tile in pairs(self.tiles) do
    tile.object:UnloadTexture()
  end
end
function MagicMap:SetIsVisible(isVisible)
  self.isVisible = isVisible
  self:SetZoomEnabled(isVisible)
  if isVisible then
    if self.sourceType == self.sourceTypes.Map then
      DynamicBus.Map.Broadcast.OnMapShown()
    end
    for _, tile in pairs(self.tiles) do
      tile.object:ReloadTexture(self.filenameExistenceMap)
    end
  else
    if self.sourceType == self.sourceTypes.Map then
      DynamicBus.Map.Broadcast.OnShowPanel()
      DynamicBus.Map.Broadcast.OnMapHidden()
    end
    self:UnloadTextures()
  end
  if self.worldMapData and self.worldMapData.hidePOILayer then
    isVisible = false
  end
  self.TerritoriesLayer:SetIsVisible(isVisible)
end
function MagicMap:SetGradient(alpha)
  UiElementBus.Event.SetIsEnabled(self.Properties.GradientParent, true)
  local childElements = UiElementBus.Event.GetChildren(self.Properties.GradientParent)
  for i = 1, #childElements do
    UiImageBus.Event.SetAlpha(childElements[i], alpha)
  end
end
function MagicMap:IsShowingObjectiveData()
  local missionId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.OpenMapMission")
  return missionId ~= nil
end
function MagicMap:SetZoomEnabled(isEnabled)
  if isEnabled == self.isZoomEnabled then
    return
  end
  self.isZoomEnabled = isEnabled
  if isEnabled then
    self.scrollUpHandler = self:BusConnect(CryActionNotificationsBus, "ui_scroll_up")
    self.scrollDownHandler = self:BusConnect(CryActionNotificationsBus, "ui_scroll_down")
  else
    self:BusDisconnect(self.scrollUpHandler)
    self.scrollUpHandler = nil
    self:BusDisconnect(self.scrollDownHandler)
    self.scrollDownHandler = nil
  end
end
function MagicMap:OnCryAction(actionName, value)
  if DynamicBus.Map.Broadcast.IsCursorOnMapStorageContainer() then
    return
  end
  if DynamicBus.Map.Broadcast.IsCursorOnMapMenu() then
    return
  end
  if DynamicBus.Map.Broadcast.IsCursorOnTerritoryInfoContainer() then
    return
  end
  if DynamicBus.Map.Broadcast.IsCursorOnTownInfoContainer() then
    return
  end
  if DynamicBus.Map.Broadcast.IsCursorOnFortressInfoContainer() then
    return
  end
  if 0 < value then
    while 0 < value do
      self:OnMouseWheelUp()
      value = value - self.MOUSE_WHEEL_DELTA
    end
  else
    while value < 0 do
      self:OnMouseWheelDown()
      value = value + self.MOUSE_WHEEL_DELTA
    end
  end
end
function MagicMap:OnShutdown()
  TimingUtils:StopDelay(self)
  self:UnloadTextures()
  DynamicBus.WorldMapDataBus.Disconnect(self.entityId, self)
  if self.ConnectToDynamicBus then
    DynamicBus.MagicMap.Disconnect(self.entityId, self)
  end
  if self.timelinePulse then
    self.timelinePulse:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timelinePulse)
  end
end
function MagicMap:OnTick(deltaTime, timePoint)
  self.timeSinceLastWheel = self.timeSinceLastWheel + deltaTime
  if self.timeSinceLastWheel > self.Properties.WheelMoveDelay then
    self:UpdateSwipePosition()
    self:UpdateContentPosition()
  end
  if self.isDragging then
    self.dragRate = deltaTime
    self.timeSinceStartDrag = self.timeSinceStartDrag + deltaTime
    self.thirdLastDragTickPos = Vector2(self.secondLastDragTickPos.x, self.secondLastDragTickPos.y)
    self.secondLastDragTickPos = Vector2(self.lastDragTickPos.x, self.lastDragTickPos.y)
    self.lastDragTickPos = Vector2(self.currentDragTickPos.x, self.currentDragTickPos.y)
    self.currentDragTickPos = Vector2(self.contentPosition.x, self.contentPosition.y)
  elseif UiCanvasBus.Event.GetEnabled(self.canvasId) then
    local worldPos = self:GetCursorWorldPosition()
    if not self.lastWorldPos or self.lastWorldPos.x ~= worldPos.x or self.lastWorldPos.y ~= worldPos.y then
      self.TerritoriesLayer:OnMouseMove(worldPos)
      if self.debugShowCoords then
        local tile = self:WorldPositionToTile(worldPos, false)
        local tx = self:ConvertTileCoord(self.currentLevel, tile.tx)
        local ty = self:ConvertTileCoord(self.currentLevel, tile.ty)
        local filename = string.format("map_L%d_Y%03d_X%03d.png", self.currentLevel, ty, tx)
        UiTextBus.Event.SetText(self.Properties.ScaleText, string.format("%.0f, %.0f. Tile = %s", worldPos.x, worldPos.y, filename))
      end
    end
    self.lastWorldPos = worldPos
  end
end
function MagicMap:SetMiniMap(miniMap)
  if miniMap then
    self.sourceType = self.sourceTypes.MiniMap
    self:CenterToPlayer(true)
  end
end
function MagicMap:OnMouseWheelUp(entityId, actionName)
  self:OnMouseWheel(1)
end
function MagicMap:OnMouseWheelDown(entityId, actionName)
  self:OnMouseWheel(-1)
end
function MagicMap:OnMouseWheel(points)
  self.timeSinceLastWheel = 0
  local screenPoint = CursorBus.Broadcast.GetCursorPosition()
  local mapRect = UiTransformBus.Event.GetViewportSpaceRect(self.entityId)
  local viewPoint = UiTransformBus.Event.ViewportPointToLocalPoint(self.entityId, screenPoint)
  if 0 > viewPoint.x or viewPoint.x > mapRect:GetWidth() or 0 > viewPoint.y or viewPoint.y > mapRect:GetHeight() then
    return
  end
  local point = UiTransformBus.Event.ViewportPointToLocalPoint(self.Properties.ContentElement, screenPoint)
  local width = UiTransform2dBus.Event.GetLocalWidth(self.Properties.Zooms[self.currentLevel])
  local height = UiTransform2dBus.Event.GetLocalHeight(self.Properties.Zooms[self.currentLevel])
  self.zoomPivot = Vector2(point.x / width, point.y / height)
  self.zoomOffset = Vector2(point.x - width / 2, point.y - height / 2)
  if points < 0 then
    self:ZoomOut(true)
  end
  if 0 < points then
    self:ZoomIn(true)
  end
  DynamicBus.Map.Broadcast.OnScroll()
end
function MagicMap:UpdateSwipePosition()
  if not self.swipeVelocity then
    return
  end
  if self.swipeVelocity.x * self.swipeVelocity.x + self.swipeVelocity.y * self.swipeVelocity.y < 1 then
    self.swipeVelocity = nil
    return
  end
  local currentPosition = UiScrollBoxBus.Event.GetScrollOffset(self.entityId)
  currentPosition = currentPosition + self.swipeVelocity
  UiScrollBoxBus.Event.SetScrollOffset(self.entityId, currentPosition)
  self.swipeVelocity = self.swipeVelocity * 0.75
  self.contentPosition = self:ValidateContentPosition(currentPosition)
end
function MagicMap:UpdateContentPosition()
  if not self.contentPosition or self.inTransition > 0 then
    return
  end
  local currentPosition = UiScrollBoxBus.Event.GetScrollOffset(self.entityId)
  if currentPosition.x == self.contentPosition.x and currentPosition.y == self.contentPosition.y then
    return
  end
  if currentPosition:IsClose(self.contentPosition, self.Properties.CenterTransitionDistanceThreshold) then
    UiScrollBoxBus.Event.SetScrollOffset(self.entityId, self.contentPosition)
    self:UpdateVisibleTiles()
  else
    local newPosition = currentPosition:Lerp(self.contentPosition, self.Properties.CenterTransitionRate)
    UiScrollBoxBus.Event.SetScrollOffset(self.entityId, newPosition)
  end
end
function MagicMap:OnAction(entityId, actionName)
  if type(self[actionName]) == "function" then
    self[actionName](self, entityId, actionName)
  end
end
function MagicMap:ZoomIn(immediate)
  local count = 1
  if not immediate then
    count = 2
  end
  self.desiredLevel = math.max(self.minLevel, self.desiredLevel - count)
  self:TransitionToZoom(immediate)
  if self.currentLevel ~= self.desiredLevel then
    self.audioHelper:PlaySound(self.audioHelper.MapZoomIn)
  end
end
function MagicMap:ZoomOut(immediate)
  local count = 1
  if not immediate then
    count = 2
  end
  self.desiredLevel = math.min(self.worldMapData.maxZoom, self.desiredLevel + count)
  self:TransitionToZoom(immediate)
  if self.currentLevel ~= self.desiredLevel then
    self.audioHelper:PlaySound(self.audioHelper.MapZoomOut)
  end
end
function MagicMap:GetCursorWorldPosition()
  local point = UiTransformBus.Event.ViewportPointToLocalPoint(self.Properties.Zooms[self.currentLevel], CursorBus.Broadcast.GetCursorPosition())
  local width = UiTransform2dBus.Event.GetLocalWidth(self.Properties.Zooms[self.currentLevel])
  local height = UiTransform2dBus.Event.GetLocalHeight(self.Properties.Zooms[self.currentLevel])
  local anchor = Vector2(point.x / width, point.y / height)
  local worldPosition = Vector3(anchor.x * self.visibleWorldBounds.width + self.visibleWorldBounds.left, (anchor.y * self.visibleWorldBounds.height - self.visibleWorldBounds.top) * -1, 0)
  return worldPosition
end
function MagicMap:MapLeftClick(entityId, actionName)
  DynamicBus.Map.Broadcast.OnMapLeftClick()
  self.clickCausedDragging = false
  TimingUtils:StopDelay(self)
  TimingUtils:Delay(self.clickThreshold, self, function(self)
    if not self.clickCausedDragging then
      DynamicBus.Map.Broadcast.OnMapLeftClickRelease()
      if self.dataLayer:GetDataFromNode("UIFeatures.g_uiEnableTerritoryMechanics") then
        local hoveredKey = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentHoveredTerritory.ClaimKey")
        if hoveredKey and hoveredKey ~= "" then
          DynamicBus.Map.Broadcast.OnShowPanel(mapTypes.panelTypes.Territory, hoveredKey)
        end
      end
    end
  end)
end
function MagicMap:MapRightClick(entityId, actionName)
  local isInSpectatorMode = SpectatorUIRequestBus.Broadcast.IsInSpectatorMode()
  local worldPosition = self:GetCursorWorldPosition()
  if isInSpectatorMode then
    SpectatorUIRequestBus.Broadcast.RequestTeleport(worldPosition.x, worldPosition.y)
  else
    self:SetOrRemoveWaypoint(worldPosition)
  end
  self.audioHelper:PlaySound(self.audioHelper.MapWayPointSet)
end
function MagicMap:SetOrRemoveWaypoint(worldPosition)
  local wayPointPosition = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.WaypointPosition")
  local isActive = wayPointPosition and wayPointPosition:IsFinite() and wayPointPosition.x > 0 and 0 < wayPointPosition.y
  if isActive then
    local wayPointEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.WayPointEntityId")
    if wayPointEntityId then
      local screenPoint = CursorBus.Broadcast.GetCursorPosition()
      local point = UiTransformBus.Event.ViewportPointToLocalPoint(wayPointEntityId, screenPoint)
      local width = UiTransform2dBus.Event.GetLocalWidth(wayPointEntityId)
      local height = UiTransform2dBus.Event.GetLocalHeight(wayPointEntityId)
      point.y = point.y + height / 2
      if point.x >= 0 and width >= point.x and 0 <= point.y and height >= point.y then
        WaypointsRequestBus.Broadcast.RequestSetWaypoint(Vector3(0, 0, 0))
        return
      end
    end
  end
  WaypointsRequestBus.Broadcast.RequestSetWaypoint(worldPosition)
end
function MagicMap:TeleportPlayer()
  local worldPosition = self:GetCursorWorldPosition()
  LocalPlayerComponentRequestBus.Broadcast.TeleportPlayer(worldPosition)
end
function MagicMap:ValidateContentPosition(newContentPosition)
  if UiScrollBoxBus.Event.GetIsScrollingConstrained(self.entityId) then
    local currentContentPosition = UiScrollBoxBus.Event.GetScrollOffset(self.entityId)
    UiScrollBoxBus.Event.SetScrollOffset(self.entityId, newContentPosition)
    newContentPosition = UiScrollBoxBus.Event.GetScrollOffset(self.entityId)
    UiScrollBoxBus.Event.SetScrollOffset(self.entityId, currentContentPosition)
  else
    local contentWidth = self.worldMapData.bounds.width / self.levelMPP[self.currentLevel]
    local contentHeight = self.worldMapData.bounds.height / self.levelMPP[self.currentLevel]
    newContentPosition = Vector2(math.max(-contentWidth / 2, math.min(contentWidth / 2, newContentPosition.x)), math.max(-contentHeight / 2, math.min(contentHeight / 2, newContentPosition.y)))
  end
  return newContentPosition
end
function MagicMap:CenterToPosition(worldPos, snapToContentPosition, instant)
  if not self.MarkersLayer then
    return
  end
  local anchors = self.MarkersLayer:WorldPositionToAnchors(worldPos)
  local contentWidth = self.visibleWorldBounds.width / self.levelMPP[self.currentLevel]
  local contentHeight = self.visibleWorldBounds.height / self.levelMPP[self.currentLevel]
  self.contentPosition = self:ValidateContentPosition(Vector2(contentWidth * (0.5 - anchors.left), contentHeight * (0.5 - anchors.top)))
  if snapToContentPosition then
    do
      local origScroll = UiScrollBoxBus.Event.GetScrollOffset(self.entityId)
      local scrollDelta = self.contentPosition - origScroll
      if instant then
        local curScroll = Vector2(origScroll.x + scrollDelta.x, origScroll.y + scrollDelta.y)
        UiScrollBoxBus.Event.SetScrollOffset(self.entityId, curScroll)
      else
        self.ScriptedEntityTweener:Play(self.Properties.DummyCenterTween, 0.33, {opacity = 0}, {
          opacity = 1,
          ease = "QuadOut",
          onUpdate = function(currentValue, currentProgressPercent)
            local curScroll = Vector2(origScroll.x + scrollDelta.x * currentValue, origScroll.y + scrollDelta.y * currentValue)
            UiScrollBoxBus.Event.SetScrollOffset(self.entityId, curScroll)
          end
        })
      end
    end
  end
  self:UpdateVisibleTiles()
end
function MagicMap:CenterToPlayer(snapToContentPosition, instant)
  self:CenterToPosition(self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Position"), snapToContentPosition, instant)
end
function MagicMap:GetTileId(worldId, zoomLevel, tx, ty)
  return string.format("%s_%d_%d_%d", worldId, zoomLevel, tx, ty)
end
function MagicMap:ZoomLevelToContentLevel(zoomLevel)
  return self.zoomToContentLevel[zoomLevel]
end
function MagicMap:SetZoom(level, desiredLevelOverride)
  if desiredLevelOverride then
    self.desiredLevel = level
  end
  UiElementBus.Event.Reparent(self.Properties.Zooms[level], self.Properties.TerrainLayer, EntityId())
  UiTransformBus.Event.SetScale(self.Properties.Zooms[level], self.scaleOne)
  for i = 1, self.levelCount do
    UiElementBus.Event.SetIsEnabled(self.Properties.Zooms[i], i == level or i == self.currentLevel)
  end
  self.currentLevel = level
  self.ScriptedEntityTweener:Set(self.Properties.TerrainLayer, {
    opacity = level * 0.05 + 0.65
  })
  if self.MarkersLayer then
    self.MarkersLayer:SetZoomFilter(self:ZoomLevelToContentLevel(level))
  end
  LyShineDataLayerBus.Broadcast.SetData("Map.ZoomLevelMPP." .. self.sourceType, self.levelMPP[level])
  local contentWidth = self.visibleWorldBounds.width / self.levelMPP[level]
  local contentHeight = self.visibleWorldBounds.height / self.levelMPP[level]
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.ContentElement, contentWidth)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.ContentElement, contentHeight)
  UiScrollBoxBus.Event.SetScrollOffset(self.entityId, self.contentPosition)
  self.contentPosition = self:ValidateContentPosition(self.contentPosition)
  self:UpdateVisibleTiles()
  if not self.debugShowCoords then
    UiTextBus.Event.SetText(self.Properties.ScaleText, LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_distanceMeters", tostring(self.Properties.BaseScaleWidth * self.levelMPP[self.currentLevel])))
  end
  self:TransitionToZoom(true)
end
function MagicMap:ActivateZoomLevel(level, newContentPosition)
  for i = 1, self.levelCount do
    UiTransformBus.Event.SetPivot(self.Properties.Zooms[i], self.pivotCenter)
    UiTransformBus.Event.SetLocalPosition(self.Properties.Zooms[i], self.vectorZero)
    UiElementBus.Event.SetIsEnabled(self.Properties.Zooms[i], i == level or i == self.currentLevel)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.MarkersLayer, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.TerritoriesLayer, true)
  UiTransformBus.Event.SetScale(self.Properties.Zooms[level], self.scaleOne)
end
function MagicMap:OnTransitionToZoomComplete(level, newContentPosition)
  self:ActivateZoomLevel(level, newContentPosition)
  self.contentPosition = newContentPosition
  UiTransformBus.Event.SetPivot(self.Properties.MarkersLayer, self.pivotCenter)
  UiTransformBus.Event.SetScale(self.Properties.MarkersLayer, self.scaleOne)
  UiTransformBus.Event.SetPivot(self.Properties.TerritoriesLayer, self.pivotCenter)
  UiTransformBus.Event.SetScale(self.Properties.TerritoriesLayer, self.scaleOne)
  self:SetZoom(level)
  if level == self.desiredLevel then
    self.zoomPivot = nil
  end
  self.TerritoriesLayer:SetZoomLevel(level)
end
function MagicMap:HideNonCurrentLevels()
  for i = 1, self.levelCount do
    UiElementBus.Event.SetIsEnabled(self.Properties.Zooms[i], i == self.currentLevel)
  end
end
function MagicMap:TransitionToZoom(immediate)
  if self.inTransition > 0 then
    self.ScriptedEntityTweener:Stop(self.Properties.Zooms[self.previousLevel])
    self.ScriptedEntityTweener:Stop(self.Properties.MarkersLayer)
    self.ScriptedEntityTweener:Stop(self.Properties.TerritoriesLayer)
    self.inTransition = 0
    self:OnTransitionToZoomComplete(self.previousDesiredLevel, self.previousContentPosition)
  end
  if self.desiredLevel == self.currentLevel then
    self:HideNonCurrentLevels()
    return
  end
  local level = self.desiredLevel
  self:UpdateVisibleTiles(level)
  local contentSize = {width = 0, height = 0}
  if level < 1 or level > self.levelCount then
    return
  end
  if 0 < self.currentLevel then
    do
      local oldMPP = self.levelMPP[self.currentLevel]
      local newMPP = self.levelMPP[level]
      local scale = oldMPP / newMPP
      local contentWidth = self.visibleWorldBounds.width / oldMPP
      local contentHeight = self.visibleWorldBounds.height / oldMPP
      local position = UiScrollBoxBus.Event.GetScrollOffset(self.entityId)
      local pivot = Vector2(0.5 - position.x / contentWidth, 0.5 - position.y / contentHeight)
      local newContentPosition = Vector2(position.x * scale, position.y * scale)
      if self.zoomPivot and self.sourceType ~= self.sourceTypes.MiniMap then
        pivot = self.zoomPivot
        local zoomPoint = Vector2(pivot.x * contentWidth, pivot.y * contentHeight)
        local oldCenter = Vector2(contentWidth / 2 - position.x, contentHeight / 2 - position.y)
        local delta = Vector2(zoomPoint.x - oldCenter.x, zoomPoint.y - oldCenter.y)
        local newZoomPoint = Vector2(zoomPoint.x * scale, zoomPoint.y * scale)
        local newCenter = Vector2(newZoomPoint.x - delta.x, newZoomPoint.y - delta.y)
        newContentPosition = Vector2(contentWidth * scale / 2 - newCenter.x, contentHeight * scale / 2 - newCenter.y)
      end
      self.inTransition = 3
      for i = 1, self.levelCount do
        UiTransformBus.Event.SetPivot(self.Properties.Zooms[i], pivot)
        UiElementBus.Event.SetIsEnabled(self.Properties.Zooms[i], i == self.currentLevel)
      end
      local transitionTime = self.Properties.TransitionTime
      if immediate then
        transitionTime = 0.15
      end
      local function completeTransition()
        self.inTransition = self.inTransition - 1
        if self.inTransition == 0 then
          self:OnTransitionToZoomComplete(level, newContentPosition)
        end
      end
      self.ScriptedEntityTweener:StartAnimation({
        id = self.Properties.Zooms[self.currentLevel],
        duration = transitionTime,
        scaleX = scale,
        scaleY = scale,
        onComplete = completeTransition
      })
      UiTransformBus.Event.SetPivot(self.Properties.MarkersLayer, pivot)
      self.ScriptedEntityTweener:StartAnimation({
        id = self.Properties.MarkersLayer,
        duration = transitionTime,
        scaleX = scale,
        scaleY = scale,
        onComplete = completeTransition
      })
      UiTransformBus.Event.SetPivot(self.Properties.TerritoriesLayer, pivot)
      self.ScriptedEntityTweener:StartAnimation({
        id = self.Properties.TerritoriesLayer,
        duration = transitionTime,
        scaleX = scale,
        scaleY = scale,
        onComplete = completeTransition
      })
      self.previousDesiredLevel = self.desiredLevel
      self.previousLevel = self.currentLevel
      self.previousContentPosition = newContentPosition
    end
  else
    self:SetZoom(level)
  end
end
function MagicMap:WorldPositionToTile(worldPos, excludeFarEdge)
  local tile = {}
  local tx = worldPos.x / self.TileSizeMeters.width
  local ty = worldPos.y / self.TileSizeMeters.height
  tile.tx = math.floor(tx)
  tile.ty = math.floor(ty)
  if excludeFarEdge then
    if tx == tile.tx then
      tile.tx = tile.tx - 1
    end
    if ty == tile.ty then
      tile.ty = tile.ty - 1
    end
  end
  return tile
end
function MagicMap:GetTileBounds(zoomLevel, tx, ty)
  local bounds = {
    left = tx * self.TileSizeMeters.width,
    top = ty * self.TileSizeMeters.height,
    width = self.TileSizeMeters.width * self.virtualTilesPerTile[zoomLevel],
    height = self.TileSizeMeters.height * self.virtualTilesPerTile[zoomLevel]
  }
  return bounds
end
function MagicMap:GetTilePosition(zoomLevel, tx, ty)
  local centerX = self.visibleWorldBounds.left + self.visibleWorldBounds.width / 2
  local centerY = self.visibleWorldBounds.top - self.visibleWorldBounds.height / 2
  local tileBounds = self:GetTileBounds(zoomLevel, tx, ty)
  local position = Vector2((tileBounds.left - centerX) / self.levelMPP[zoomLevel], (centerY - tileBounds.top) / self.levelMPP[zoomLevel])
  position.y = position.y - tileBounds.height / self.levelMPP[zoomLevel] / 2
  position.x = position.x + tileBounds.width / self.levelMPP[zoomLevel] / 2
  return position
end
function MagicMap:ClearAllTiles()
  local tile = self.tileHead
  while tile do
    tile.object:UnloadTexture()
    self.tiles[tile.tileId] = nil
    table.insert(self.cachedTiles, tile.object)
    tile = tile.next
  end
  self.tileHead = nil
  self.tileTail = nil
  self.tileCount = 0
end
function MagicMap:PushTile(tile)
  if self.tileHead == tile then
    return
  end
  if self.tileHead == nil then
    self.tileHead = tile
    self.tileTail = tile
    self.tileCount = 1
  else
    if tile.prev or tile.next then
      if tile.prev then
        tile.prev.next = tile.next
      end
      if tile.next then
        tile.next.prev = tile.prev
      end
      self.tileCount = self.tileCount - 1
      if self.tileTail == tile then
        self.tileTail = tile.prev
      end
    end
    self.tileHead.prev = tile
    tile.next = self.tileHead
    tile.prev = nil
    self.tileHead = tile
    self.tileCount = self.tileCount + 1
    if self.tileCount > self.tileMax then
      local oldTile = self.tileTail
      if oldTile then
        oldTile.object:UnloadTexture()
        table.insert(self.cachedTiles, oldTile.object)
        self.tiles[oldTile.tileId] = nil
        self.tileTail = oldTile.prev
        self.tileTail.next = nil
        self.tileCount = self.tileCount - 1
        oldTile.prev = nil
        oldTile.next = nil
      end
    end
  end
end
function MagicMap:DumpList(reverse)
  local tile = self.tileHead
  if reverse then
    tile = self.tileTail
  end
  local count = 1
  if reverse then
    Debug.Log("Printing in reverse:")
  end
  while tile do
    Debug.Log(string.format("%d: Tile %s, entityId = %s", count, tile.tileId, tostring(tile.entityId)))
    if reverse then
      tile = tile.prev
    else
      tile = tile.next
    end
    count = count + 1
  end
end
function MagicMap:OnDumpDebug()
  self:DumpList(false)
end
function MagicMap:FindTileInList(tile)
  local cursor = self.tileHead
  local idx = 0
  while cursor do
    idx = idx + 1
    if cursor == tile then
      return idx
    end
    if idx > self.tileCount + 10 then
      return 0
    end
    cursor = cursor.next
  end
  return 0
end
function MagicMap:ValidateList()
  local tile = self.tileHead
  local count = 0
  local lastTileIsTail = false
  local tileCounts = {}
  while tile do
    lastTileIsTail = tile == self.tileTail
    count = count + 1
    if tileCounts[tile.tileId] then
      Debug.Log(string.format("tile %s already counted at %d, now at %d!", tile.tileId, tileCounts[tile.tileId], count))
    end
    tileCounts[tile.tileId] = count
    if not tile.prev and self.tileHead ~= tile then
      Debug.Log("Tile prev not set but should be!")
    end
    if self.tileHead == tile and tile.prev then
      Debug.Log("head tile has a prev!")
    end
    tile = tile.next
  end
  if not lastTileIsTail then
    Debug.Log([[
Last tile was not the tail


]])
    self:DumpList(false)
    self:DumpList(true)
  end
end
function MagicMap:ConvertTileCoord(level, tc)
  return tc - tc % self.virtualTilesPerTile[level]
end
function MagicMap:LoadTileRange(level, minx, miny, maxx, maxy)
  minx = self:ConvertTileCoord(level, minx)
  miny = self:ConvertTileCoord(level, miny)
  maxx = self:ConvertTileCoord(level, maxx)
  maxy = self:ConvertTileCoord(level, maxy)
  for y = miny, maxy, self.virtualTilesPerTile[level] do
    for x = minx, maxx, self.virtualTilesPerTile[level] do
      self:LoadVisibleTile(level, x, y)
    end
  end
end
function MagicMap:UpdateVisibleTiles(requestedLevel)
  local level = self.currentLevel
  local position = UiScrollBoxBus.Event.GetScrollOffset(self.entityId)
  local mpp = self.levelMPP[level]
  local centerPoint = {
    x = self.visibleWorldBounds.left + self.visibleWorldBounds.width / 2,
    y = self.visibleWorldBounds.top - self.visibleWorldBounds.height / 2
  }
  centerPoint.x = centerPoint.x - position.x * mpp
  centerPoint.y = centerPoint.y + position.y * mpp
  level = requestedLevel or self.currentLevel
  mpp = self.levelMPP[level]
  local topLeftPoint = {
    x = centerPoint.x - self.windowWidth * mpp / 2,
    y = centerPoint.y + self.windowHeight * mpp / 2
  }
  local bottomRightPoint = {
    x = centerPoint.x + self.windowWidth * mpp / 2,
    y = centerPoint.y - self.windowHeight * mpp / 2
  }
  local topLeftTile = self:WorldPositionToTile(topLeftPoint, false)
  local bottomRightTile = self:WorldPositionToTile(bottomRightPoint, true)
  local minx = self:ConvertTileCoord(level, math.max(self.worldBoundsInTiles.left, topLeftTile.tx))
  local miny = self:ConvertTileCoord(level, math.max(self.worldBoundsInTiles.bottom, bottomRightTile.ty))
  local maxx = self:ConvertTileCoord(level, math.min(self.worldBoundsInTiles.right, bottomRightTile.tx))
  local maxy = self:ConvertTileCoord(level, math.min(self.worldBoundsInTiles.top, topLeftTile.ty))
  if not self.lastRequest then
    self.lastRequest = {}
  elseif self.lastRequest.level == level and self.lastRequest.minx == minx and self.lastRequest.maxx == maxx and self.lastRequest.miny == miny and self.lastRequest.maxy == maxy then
    return
  end
  self.lastRequest.level = level
  self.lastRequest.minx = minx
  self.lastRequest.maxx = maxx
  self.lastRequest.miny = miny
  self.lastRequest.maxy = maxy
  self:LoadTileRange(level, minx, miny, maxx, maxy)
end
function MagicMap:OnMapTileSpawned(tileObject, tile)
  tile.entityId = tileObject.entityId
  tile.object = tileObject
  UiTransformBus.Event.SetLocalPosition(tile.entityId, tile.position)
  UiTransform2dBus.Event.SetLocalWidth(tile.entityId, self.tileSizeInPixels)
  UiTransform2dBus.Event.SetLocalHeight(tile.entityId, self.tileSizeInPixels)
  self.tiles[tile.tileId] = tile
  tileObject:SetTile(tile, self.isVisible, self.filenameExistenceMap)
  self.loadingTiles[tile.tileId] = nil
end
function MagicMap:LoadVisibleTile(zoomLevel, tx, ty)
  tx = self:ConvertTileCoord(zoomLevel, tx)
  ty = self:ConvertTileCoord(zoomLevel, ty)
  local tileId = self:GetTileId(self.worldMapData.id, zoomLevel, tx, ty)
  local tile = self.tiles[tileId] or self.loadingTiles[tileId]
  if not tile then
    tile = {}
    tile.worldMapData = self.worldMapData
    tile.tileId = tileId
    tile.zoomLevel = zoomLevel
    tile.contentLevel = self:ZoomLevelToContentLevel(zoomLevel)
    tile.tx = tx
    tile.ty = ty
    tile.worldBounds = self:GetTileBounds(zoomLevel, tx, ty)
    tile.position = self:GetTilePosition(zoomLevel, tx, ty)
    tile.next = nil
    tile.prev = nil
    self.loadingTiles[tileId] = tile
    local tileObject = table.remove(self.cachedTiles)
    UiElementBus.Event.Reparent(tileObject.entityId, self.Properties.Zooms[zoomLevel], EntityId())
    self:OnMapTileSpawned(tileObject, tile)
  end
  self:PushTile(tile)
end
function MagicMap:OnScrollOffsetChanging(offset)
  DynamicBus.Map.Broadcast.OnDrag(true)
  if self.currentLevel < 1 or self.currentLevel > self.levelCount then
    return
  end
  local previousContentPosition = Vector2(self.contentPosition.x, self.contentPosition.y)
  self.contentPosition = UiScrollBoxBus.Event.GetScrollOffset(self.entityId)
  if not self.isDragging then
    self.timeSinceStartDrag = 0
    self.lastDragTickPos = Vector2(previousContentPosition.x, previousContentPosition.y)
    self.secondLastDragTickPos = Vector2(previousContentPosition.x, previousContentPosition.y)
    self.thirdLastDragTickPos = Vector2(previousContentPosition.x, previousContentPosition.y)
    self.currentDragTickPos = Vector2(self.contentPosition.x, self.contentPosition.y)
  end
  self.isDragging = true
  self.clickCausedDragging = true
  self:UpdateVisibleTiles()
end
function MagicMap:OnScrollOffsetChanged(offset)
  DynamicBus.Map.Broadcast.OnDrag(false)
  if self.isDragging then
    if self.dragRate > 0 then
      local dragDelta = self.currentDragTickPos - self.thirdLastDragTickPos
      self.swipeVelocity = dragDelta / 3
      self.contentPosition = UiScrollBoxBus.Event.GetScrollOffset(self.entityId)
    end
    self.contentPosition = self:ValidateContentPosition(self.contentPosition)
  end
  self.isDragging = false
end
function MagicMap:PingAtLocation(pingIconPath, pingColor, worldLocation)
  UiImageBus.Event.SetSpritePathname(self.Properties.PingIcon, pingIconPath)
  UiImageBus.Event.SetColor(self.Properties.PingIconPulse, pingColor)
  if self.timelinePulse then
    self.timelinePulse:Stop()
    self.ScriptedEntityTweener:Set(self.Properties.PingIconPulse, {
      opacity = 1,
      scaleY = 1,
      scaleX = 1
    })
  end
  local anchors = self.MarkersLayer:WorldPositionToAnchors(worldLocation)
  UiTransform2dBus.Event.SetAnchorsScript(self.Properties.PingEntity, anchors)
  self.ScriptedEntityTweener:Stop(self.Properties.PingEntity)
  UiElementBus.Event.SetIsEnabled(self.Properties.PingEntity, true)
  self:SetPingVisible(true)
  self.ScriptedEntityTweener:Play(self.Properties.PingEntity, 2, {opacity = 1}, {
    opacity = 1,
    onComplete = function()
      self:SetPingVisible(false)
    end
  })
end
function MagicMap:SetPingVisible(isVisible)
  if isVisible then
    if not self.timelinePulse then
      self.timelinePulse = self.ScriptedEntityTweener:TimelineCreate()
      self.timelinePulse:Add(self.Properties.PingIconPulse, 0.8, {
        opacity = 0,
        scaleY = 2,
        scaleX = 2
      })
      self.timelinePulse:Add(self.Properties.PingIconPulse, 0.5, {opacity = 0})
      self.timelinePulse:Add(self.Properties.PingIconPulse, 0.01, {
        opacity = 1,
        scaleY = 1,
        scaleX = 1,
        onComplete = function()
          self.timelinePulse:Play()
        end
      })
    end
    self.timelinePulse:Play()
  else
    self.ScriptedEntityTweener:Play(self.Properties.PingEntity, 0.4, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.Properties.PingEntity, false)
        self.ScriptedEntityTweener:Set(self.Properties.PingIconPulse, {
          opacity = 1,
          scaleY = 1,
          scaleX = 1
        })
        if self.timelinePulse then
          self.timelinePulse:Stop()
        end
      end
    })
  end
end
function MagicMap:OnLevelUnload(crc)
  self.levelUnloaded = true
end
function MagicMap:OnLoadingScreenShown()
  self.prevMapData = self.worldMapData
end
function MagicMap:OnLoadingScreenDismissed()
  if self.worldMapData == self.prevMapData and self.levelUnloaded then
    self:SetDefaultWorld()
    local isAvailable = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.IsLandClaimManagerAvailable")
    if isAvailable and self.worldMapData and not self.worldMapData.hidePOILayer then
      self.TerritoriesLayer:CreateTerritoryOverlays()
    end
  end
  self.levelUnloaded = false
end
return MagicMap
