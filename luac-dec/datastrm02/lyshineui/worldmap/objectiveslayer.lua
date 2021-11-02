local ObjectivesLayer = {
  Properties = {},
  isValidZoom = true,
  ICON_SLICE = "LyShineUI\\WorldMap\\SimpleObjectiveIcon",
  MAX_OBJECTIVE_ICONS = 340,
  EXTRA_POI_OBJECTIVES_LABEL_SLICE = "LyShineUI\\WorldMap\\ExtraPoiObjectivesLabel",
  MAX_EXTRA_POI_OBJECTIVES_LABELS = 40,
  MAX_ZOOM_LEVEL = 16,
  POI_OBJECTIVE_OFFSET_MULTIPLIER_X = 20,
  POI_OBJECTIVE_OFFSET_MULTIPLIER_Y = -15,
  POI_OBJECTIVE_OFFSET_EXPONENT = 1,
  MAX_VISIBLE_ICONS_PER_POI = 3,
  MAX_PINNED_OBJECTIVES = 6,
  pinIcon = "lyshineui/images/map/icon/icon_pin.dds",
  journalIcon = "lyshineui/images/map/icon/icon_journal.dds"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
local ObjectiveTypeData = RequireScript("LyShineUI.Objectives/ObjectiveTypeData")
local ObjectivesDataHandler = RequireScript("LyShineUI._Common.ObjectivesDataHandler")
local Spawner = RequireScript("LyShineUI._Common.Spawner")
BaseElement:CreateNewElement(ObjectivesLayer)
Spawner:AttachSpawner(ObjectivesLayer)
function ObjectivesLayer:OnInit()
  BaseElement.OnInit(self)
  self.cachedIcons = {}
  self.cachedExtraPoiObjectivesLabels = {}
  self.taskToPoiInfoMap = {}
  self.poiToTasksMap = {}
  self.poiObjectivesXOffsets = {}
  for i = 1, self.MAX_VISIBLE_ICONS_PER_POI do
    self.poiObjectivesXOffsets[i] = {}
    for j = 1, i do
      local xOffsetIndex = j * 2 - (i / 2 + 0.5) * 2
      self.poiObjectivesXOffsets[i][j] = xOffsetIndex * self.POI_OBJECTIVE_OFFSET_MULTIPLIER_X
    end
  end
  local rightmostIconXOffsetIndex = self.MAX_VISIBLE_ICONS_PER_POI * 2 - (self.MAX_VISIBLE_ICONS_PER_POI / 2 + 0.5) * 2
  self.extraPoiObjectivesLabelXOffset = (rightmostIconXOffsetIndex + 2) * self.POI_OBJECTIVE_OFFSET_MULTIPLIER_X
  self.iconTypes = mapTypes.iconTypes
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.ObjectiveEntityId", self.OnObjectiveEntityIdChanged)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Map.ZoomLevelMPP.Map", self.OnZoomLevelChanged)
  if not self.spawnerNotificationBusHandler then
    self.spawnerNotificationBusHandler = self:BusConnect(UiSpawnerNotificationBus, self.entityId)
  end
  for i = 1, self.MAX_EXTRA_POI_OBJECTIVES_LABELS do
    self:SpawnSlice(self.entityId, self.EXTRA_POI_OBJECTIVES_LABEL_SLICE, self.OnExtraPoiObjectivesLabelSpawned)
  end
  for i = 1, self.MAX_OBJECTIVE_ICONS do
    self:SpawnSlice(self.entityId, self.ICON_SLICE, self.OnIconSpawned)
  end
  DynamicBus.ObjectivesLayer.Connect(self.entityId, self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
    if playerEntityId then
      if self.delayUpdateAvailableObjectiveIcons then
        self.UpdateAvailableObjectiveIcons()
        self.delayUpdateAvailableObjectiveIcons = nil
      end
      if self.delayUpdatePublishedLocations then
        self:UpdatePublishedLocations()
        self.delayUpdatePublishedLocations = nil
      end
    end
  end)
end
function ObjectivesLayer:SetMarkersLayer(markersLayer)
  self.markersLayer = markersLayer
  if not self.mapComponentEventBusHandler then
    self.mapComponentEventBusHandler = self:BusConnect(MapComponentEventBus)
  end
  self.poiCapitalPositions = {}
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.LandmarkDataReady", function(self, ready)
    if ready and #self.poiCapitalPositions == 0 then
      local settlements = MapComponentBus.Broadcast.GetSettlements()
      self:InitPoiCapitals(settlements)
      local outposts = MapComponentBus.Broadcast.GetOutposts()
      self:InitPoiCapitals(outposts)
    end
  end)
end
function ObjectivesLayer:InitPoiCapitals(poiCapitols)
  for i = 1, #poiCapitols do
    local poiCapitalData = poiCapitols[i]
    local settlementId = poiCapitalData.settlementId
    local radius = 0
    local landmarksVector = MapComponentBus.Broadcast.GetLandmarksInTerritory(settlementId)
    if landmarksVector then
      for j = 1, #landmarksVector do
        local landmarkData = landmarksVector[j]
        if landmarkData.landmarkType == eTerritoryLandmarkType_Settlement or landmarkData.landmarkType == eTerritoryLandmarkType_Outpost then
          radius = landmarkData.radius
          break
        end
      end
    end
    if radius == 0 then
      radius = 160
    end
    table.insert(self.poiCapitalPositions, {
      worldPosition = Vector3(poiCapitalData.worldPosition.x, poiCapitalData.worldPosition.y, 0),
      radiusSq = radius * radius
    })
  end
end
function ObjectivesLayer:SetWorldMapData(worldMapData, visibleWorldBounds)
  local enablePOILayer = worldMapData.hidePOILayer ~= true
  UiElementBus.Event.SetIsEnabled(self.entityId, enablePOILayer)
  if not enablePOILayer then
    return
  end
  for i = 1, #self.cachedIcons do
    if self.cachedIcons[i].iconData and self.cachedIcons[i].iconData.id then
      if self.taskToPoiInfoMap[self.cachedIcons[i].iconData.id:ToString()] then
        self:RemoveObjectiveIconFromPoi(self.cachedIcons[i])
      end
      self.cachedIcons[i]:Reset()
    end
  end
  if self.uiLoadingComplete then
    self:UpdatePublishedLocations()
  end
  self:UpdateAvailableObjectiveIcons()
end
function ObjectivesLayer:OnShutdown()
  if self.uiLoaderHandler then
    DynamicBus.UiLoader.Disconnect(self.entityId, self)
    self.uiLoaderHandler = nil
  end
  DynamicBus.ObjectivesLayer.Disconnect(self.entityId, self)
end
function ObjectivesLayer:OnIconSpawned(entity)
  UiTransform2dBus.Event.SetLocalHeight(entity.entityId, 96)
  UiTransform2dBus.Event.SetLocalWidth(entity.entityId, 96)
  table.insert(self.cachedIcons, entity)
  if #self.cachedIcons == self.MAX_OBJECTIVE_ICONS then
    self:UpdatePublishedLocations()
  end
end
function ObjectivesLayer:OnExtraPoiObjectivesLabelSpawned(entity)
  UiTransform2dBus.Event.SetLocalHeight(entity.entityId, 40)
  UiTransform2dBus.Event.SetLocalWidth(entity.entityId, 40)
  table.insert(self.cachedExtraPoiObjectivesLabels, entity)
end
function ObjectivesLayer:OnActiveObjectiveIconHover(rows, iconData)
  self.playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  local objectiveTaskInstanceId = iconData.id
  local objectiveId = objectiveTaskInstanceId.objectiveInstanceId
  local readyToComplete = ObjectivesComponentRequestBus.Event.IsObjectiveReadyForCompletion(self.playerEntityId, objectiveId)
  local description = iconData.descriptionText
  local taskDescription = ObjectiveTaskRequestBus.Event.GetDescription(objectiveTaskInstanceId)
  taskDescription = taskDescription or ""
  local poiInfo = self.taskToPoiInfoMap[objectiveTaskInstanceId:ToString()]
  if poiInfo then
    for _, taskInstanceId in pairs(poiInfo.extraTaskList) do
      local curTaskDescription = ObjectiveTaskRequestBus.Event.GetDescription(taskInstanceId)
      if taskDescription == "" and curTaskDescription and curTaskDescription ~= "" then
        taskDescription = "<font color=\"#edc63e\" face=\"lyshineui/fonts/nimbus_semibold.font\">" .. curTaskDescription .. "</font>"
      elseif curTaskDescription and curTaskDescription ~= "" then
        taskDescription = taskDescription .. [[


<font color="#edc63e" face="lyshineui/fonts/nimbus_semibold.font">]] .. curTaskDescription .. "</font>"
      end
    end
  end
  if taskDescription and taskDescription ~= "" then
    local creationParams = ObjectiveRequestBus.Event.GetCreationParams(objectiveId)
    if creationParams.missionId ~= 0 then
      taskDescription = ObjectivesDataHandler:GetLocalizedDescText(taskDescription, creationParams)
    end
    description = description .. [[


<font color="#edc63e" face="lyshineui/fonts/nimbus_semibold.font">]] .. taskDescription .. "</font>"
  end
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  table.insert(rows, {
    type = flyoutMenu.ROW_TYPE_PointOfInterest,
    header = iconData.titleText,
    subtext = description,
    status = readyToComplete and "@ui_ready_to_complete" or nil,
    statusColor = self.UIStyle.COLOR_YELLOW_GREEN_BRIGHT
  })
  local isPinned = ObjectivesComponentRequestBus.Event.IsObjectiveTracked(self.playerEntityId, objectiveId)
  local pinnedObjectiveList = ObjectivesComponentRequestBus.Event.GetTrackedObjectives(self.objectiveEntityId)
  table.insert(rows, {
    type = flyoutMenu.ROW_TYPE_Button,
    isEnabled = true,
    buttonText = isPinned and "@ui_unpin_objective" or "@ui_pin_objective",
    icon = self.pinIcon,
    bottomPadding = 10,
    callbackTable = self,
    callback = function(self)
      ObjectivesComponentRequestBus.Event.SetObjectiveTracked(self.playerEntityId, objectiveId, not isPinned)
      local notificationData = NotificationData()
      notificationData.type = "Minor"
      notificationData.text = isPinned and "@ui_unpin_objective_message" or "@ui_pin_objective_message"
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    end
  })
  table.insert(rows, {
    type = flyoutMenu.ROW_TYPE_Button,
    isEnabled = true,
    buttonText = "@ui_view_journal",
    icon = self.journalIcon,
    callbackTable = self,
    callback = function(self)
      DynamicBus.JournalScreen.Broadcast.OpenToObjectiveId(objectiveId)
    end
  })
end
function ObjectivesLayer:OnObjectiveEntityIdChanged(entityId)
  if entityId == nil then
    return
  end
  if self.objectivesComponentBusHandler then
    self:BusDisconnect(self.objectivesComponentBusHandler)
  end
  self.objectivesComponentBusHandler = self:BusConnect(ObjectivesComponentNotificationsBus, entityId)
  self.objectiveEntityId = entityId
  if self.uiLoaderHandler then
    DynamicBus.UiLoader.Disconnect(self.entityId, self)
  end
  self.uiLoaderHandler = DynamicBus.UiLoader.Connect(self.entityId, self)
end
function ObjectivesLayer:UpdatePublishedLocations()
  if not self.playerEntityId then
    self.delayUpdatePublishedLocations = true
    return
  end
  if #self.cachedIcons ~= self.MAX_OBJECTIVE_ICONS or self.uiLoaderHandler then
    return
  end
  ObjectiveTaskRequestBus.Broadcast.RequestPublishPoiLocations()
  ObjectivesComponentRequestBus.Event.RequestPublishPoiLocations(self.playerEntityId)
  NpcComponentRequestBus.Broadcast.RequestPublishNpcStates()
end
function ObjectivesLayer:OnUiLoadingComplete()
  if self.uiLoaderHandler then
    self.uiLoaderHandler = nil
    DynamicBus.UiLoader.Disconnect(self.entityId, self)
  end
  self.uiLoadingComplete = true
  self:UpdatePublishedLocations()
end
function ObjectivesLayer:SetIsVisible(isVisible)
  self.isVisible = isVisible
  if isVisible then
    self:OnObjectivesChanged()
  end
end
function ObjectivesLayer:DisplayAvailableObjectiveIcon(objectiveData, iconPath, isInProgressObjective)
  local availableIcon = self:GetFirstAvailableIcon()
  if not availableIcon then
    return
  end
  for i = 1, #self.cachedIcons do
    local curIconData = self.cachedIcons[i].iconData
    if curIconData and curIconData.isActiveObjective and curIconData.npcId == objectiveData.npcId then
      return
    elseif curIconData and not curIconData.isActiveObjective and curIconData.objectiveData and curIconData.objectiveData.npcId == objectiveData.npcId then
      if not curIconData.isInProgressObjective or isInProgressObjective then
        return
      else
        availableIcon = self.cachedIcons[i]
        break
      end
    end
  end
  local anchors = self.markersLayer:WorldPositionToAnchors(objectiveData.worldPosition)
  local iconData = {
    isActiveObjective = false,
    imageFGPath = iconPath,
    dataManager = self,
    anchors = anchors,
    objectiveData = objectiveData,
    worldPosition = objectiveData.worldPosition,
    isInProgressObjective = isInProgressObjective
  }
  availableIcon:SetData(iconData)
  availableIcon:SetFlyoutMenuOverride(self, self.OnAvailableObjectiveIconHover)
end
function ObjectivesLayer:OnAvailableObjectiveIconHover(rows, iconData)
  local objectiveData = iconData.objectiveData
  local objectiveId = objectiveData.objectiveId
  local isInProgress = false
  local staticObjectiveData
  if objectiveId then
    staticObjectiveData = ObjectivesDataManagerBus.Broadcast.GetObjectiveData(objectiveId)
  else
    staticObjectiveData = ObjectiveRequestBus.Event.GetObjectiveData(objectiveData.objectiveInstanceId)
    isInProgress = true
  end
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  table.insert(rows, {
    type = flyoutMenu.ROW_TYPE_PointOfInterest,
    header = staticObjectiveData.title,
    subtext = staticObjectiveData.description,
    status = isInProgress and "@ui_inprogress" or "@ui_available_quest",
    statusColor = self.UIStyle.COLOR_YELLOW_GOLD
  })
end
function ObjectivesLayer:UpdateAvailableObjectiveIcons()
  if not self.playerEntityId then
    self.delayUpdateAvailableObjectiveIcons = true
    return
  end
  for i = 1, #self.cachedIcons do
    if self.cachedIcons[i].iconData and not self.cachedIcons[i].iconData.isActiveObjective then
      if self.cachedIcons[i].iconData.id and self.taskToPoiInfoMap[self.cachedIcons[i].iconData.id:ToString()] then
        self:RemoveObjectiveIconFromPoi(self.cachedIcons[i])
      end
      self.cachedIcons[i]:Reset()
    end
  end
  local inProgressObjectivesWithTurnIn = {}
  local objectives = ObjectivesComponentRequestBus.Event.GetObjectives(self.playerEntityId)
  for i = 1, #objectives do
    local objectiveInstanceId = objectives[i]
    local objectiveData = ObjectiveRequestBus.Event.GetObjectiveData(objectiveInstanceId)
    if objectiveData.npcDestinationId and objectiveData.npcDestinationId ~= "" then
      local isObjectiveReadyToTurnIn = ObjectivesComponentRequestBus.Event.IsObjectiveReadyForCompletion(self.playerEntityId, objectiveInstanceId)
      if not isObjectiveReadyToTurnIn and not objectiveData.hideIncompleteTurnin then
        table.insert(inProgressObjectivesWithTurnIn, {
          objectiveInstanceId = objectiveInstanceId,
          npcId = objectiveData.npcDestinationId
        })
      end
    end
  end
  local territories = MapComponentBus.Broadcast.GetTerritories()
  for i = 1, #territories do
    local territoryPrismData = territories[i]
    local territoryId = territoryPrismData.id
    local availableObjectives = ObjectivesDataHandler:GetAvailableObjectivesByTerritoryId(territoryId)
    local availableObjectiveIcon = ObjectiveTypeData.ObjectiveStates.Available.iconPath
    for _, objectiveData in ipairs(availableObjectives) do
      self:DisplayAvailableObjectiveIcon(objectiveData, availableObjectiveIcon, false)
    end
    if 0 < #inProgressObjectivesWithTurnIn then
      local npcPositionsInTerritory = ObjectivesDataHandler:GetNpcPositionsInTerritory(territoryId)
      for _, objectiveData in ipairs(inProgressObjectivesWithTurnIn) do
        if npcPositionsInTerritory[objectiveData.npcId] then
          objectiveData.territoryId = territoryId
          objectiveData.worldPosition = npcPositionsInTerritory[objectiveData.npcId]
          self:DisplayAvailableObjectiveIcon(objectiveData, "LyShineUI\\Images\\Icons\\Objectives\\icon_questInProgress.dds", true)
          break
        end
      end
    end
  end
end
function ObjectivesLayer:GetFirstAvailableIcon()
  for i = 1, #self.cachedIcons do
    if self.cachedIcons[i] and not self.cachedIcons[i].iconData then
      return self.cachedIcons[i]
    end
  end
end
function ObjectivesLayer:GetFirstAvailableExtraPoiObjectivesLabel()
  for i = 1, #self.cachedExtraPoiObjectivesLabels do
    if self.cachedExtraPoiObjectivesLabels[i] and not self.cachedExtraPoiObjectivesLabels[i].isEnabled then
      return self.cachedExtraPoiObjectivesLabels[i]
    end
  end
end
function ObjectivesLayer:AddObjectiveIconToPoi(icon, attachedPoi)
  if not (attachedPoi ~= 0 and icon) or self.taskToPoiInfoMap[icon.iconData.id:ToString()] then
    return
  end
  local taskIdString = icon.iconData.id:ToString()
  if not self.poiToTasksMap[attachedPoi] then
    self.poiToTasksMap[attachedPoi] = {}
  end
  local poiTaskList = self.poiToTasksMap[attachedPoi]
  local sortingPos = ObjectivesComponentRequestBus.Event.GetObjectiveSortingPos(self.objectiveEntityId, icon.iconData.id.objectiveInstanceId)
  self.taskToPoiInfoMap[taskIdString] = {
    poi = attachedPoi,
    icon = icon,
    sortingPos = sortingPos,
    shouldHide = false,
    extraTaskList = {}
  }
  if sortingPos < 0 or #poiTaskList == 0 then
    table.insert(poiTaskList, taskIdString)
  else
    for i, curTaskIdString in ipairs(poiTaskList) do
      if self.taskToPoiInfoMap[curTaskIdString].sortingPos == -1 or sortingPos < self.taskToPoiInfoMap[curTaskIdString].sortingPos then
        table.insert(poiTaskList, i, taskIdString)
        break
      elseif i == #poiTaskList then
        table.insert(poiTaskList, taskIdString)
        break
      end
    end
  end
  self:UpdateObjectiveIconsAtPoi(attachedPoi)
end
function ObjectivesLayer:RemoveTaskFromIcon(objectiveTaskInstanceId, icon)
  local poiInfo = self.taskToPoiInfoMap[icon.iconData.id:ToString()]
  local taskString = objectiveTaskInstanceId:ToString()
  if not (icon and poiInfo) or not poiInfo.extraTaskList[taskString] then
    return false
  end
  poiInfo.extraTaskList[taskString] = nil
  return true
end
function ObjectivesLayer:RemoveObjectiveIconFromPoi(icon, onlyRemoveTask)
  if not icon or not self.taskToPoiInfoMap[icon.iconData.id:ToString()] then
    return true
  end
  local taskIdString = icon.iconData.id:ToString()
  local attachedPoi = self.taskToPoiInfoMap[taskIdString].poi
  local extraTaskList = self.taskToPoiInfoMap[taskIdString].extraTaskList
  local poiTaskList = self.poiToTasksMap[attachedPoi]
  if onlyRemoveTask then
    local newMainTaskId, newMainTaskIdString
    for taskString, taskInstanceId in pairs(extraTaskList) do
      newMainTaskId = taskInstanceId
      newMainTaskIdString = taskString
      break
    end
    if newMainTaskId then
      icon.iconData.id = newMainTaskId
      extraTaskList[newMainTaskIdString] = nil
      if poiTaskList then
        for i, curTaskIdString in ipairs(poiTaskList) do
          if curTaskIdString == taskIdString then
            poiTaskList[i] = newMainTaskIdString
            break
          end
        end
      end
      self.taskToPoiInfoMap[newMainTaskIdString] = self.taskToPoiInfoMap[taskIdString]
      self.taskToPoiInfoMap[taskIdString] = nil
      return false
    end
  end
  UiTransformBus.Event.SetLocalPosition(icon.entityId, Vector2(0, 0))
  if poiTaskList then
    for i, curTaskIdString in ipairs(poiTaskList) do
      if curTaskIdString == taskIdString then
        table.remove(poiTaskList, i)
        break
      end
    end
    if #poiTaskList == 0 then
      poiTaskList = nil
    end
  end
  self.taskToPoiInfoMap[taskIdString] = nil
  if attachedPoi and attachedPoi ~= 0 then
    self:UpdateObjectiveIconsAtPoi(attachedPoi)
  end
  return true
end
function ObjectivesLayer:UpdateObjectiveIconsAtPoi(attachedPoi)
  local poiTaskList = self.poiToTasksMap[attachedPoi]
  if attachedPoi == 0 or not poiTaskList then
    return
  end
  local numIconsAtPoi = #poiTaskList
  local territoryDef = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(attachedPoi)
  local discoveredAchievementId = territoryDef.discoveredAchievementId
  local isPoiDiscovered = discoveredAchievementId and discoveredAchievementId ~= 0 and AchievementRequestBus.Event.IsAchievementUnlocked(self.playerEntityId, discoveredAchievementId)
  local yOffset = isPoiDiscovered and self.POI_OBJECTIVE_OFFSET_MULTIPLIER_Y or 0
  local scaleFactor = self.currentScale ^ self.POI_OBJECTIVE_OFFSET_EXPONENT
  if numIconsAtPoi > self.MAX_VISIBLE_ICONS_PER_POI then
    for i = self.MAX_VISIBLE_ICONS_PER_POI + 1, numIconsAtPoi do
      self.taskToPoiInfoMap[poiTaskList[i]].shouldHide = true
      UiElementBus.Event.SetIsEnabled(self.taskToPoiInfoMap[poiTaskList[i]].icon.entityId, false)
    end
    local randomIconForPoi = self.taskToPoiInfoMap[poiTaskList[1]].icon
    if not poiTaskList.extraPoiObjectivesLabel then
      poiTaskList.extraPoiObjectivesLabel = self:GetFirstAvailableExtraPoiObjectivesLabel()
      if poiTaskList.extraPoiObjectivesLabel then
        poiTaskList.extraPoiObjectivesLabel:SetIsEnabled(true)
        poiTaskList.extraPoiObjectivesLabel:SetAnchorsPosition(randomIconForPoi.iconData.anchors)
        poiTaskList.extraPoiObjectivesLabel:SetScale(self.currentScale)
      end
    end
    if poiTaskList.extraPoiObjectivesLabel then
      poiTaskList.extraPoiObjectivesLabel:SetNumExtraPoiObjectives(numIconsAtPoi - self.MAX_VISIBLE_ICONS_PER_POI)
      UiTransformBus.Event.SetLocalPosition(poiTaskList.extraPoiObjectivesLabel.entityId, Vector2(self.extraPoiObjectivesLabelXOffset * scaleFactor, yOffset * scaleFactor))
      local iconParent = UiElementBus.Event.GetParent(randomIconForPoi.entityId)
      UiElementBus.Event.Reparent(poiTaskList.extraPoiObjectivesLabel.entityId, iconParent, EntityId())
    end
  elseif poiTaskList.extraPoiObjectivesLabel then
    poiTaskList.extraPoiObjectivesLabel:SetIsEnabled(false)
    poiTaskList.extraPoiObjectivesLabel = nil
  end
  local numVisibleIcons = numIconsAtPoi < self.MAX_VISIBLE_ICONS_PER_POI and numIconsAtPoi or self.MAX_VISIBLE_ICONS_PER_POI
  for i = numVisibleIcons, 1, -1 do
    local iconEntityId = self.taskToPoiInfoMap[poiTaskList[i]].icon.entityId
    self.taskToPoiInfoMap[poiTaskList[i]].shouldHide = false
    UiElementBus.Event.SetIsEnabled(iconEntityId, true)
    UiTransformBus.Event.SetLocalPosition(iconEntityId, Vector2(self.poiObjectivesXOffsets[numVisibleIcons][i] * scaleFactor, yOffset * scaleFactor))
    local iconParent = UiElementBus.Event.GetParent(iconEntityId)
    UiElementBus.Event.Reparent(iconEntityId, iconParent, EntityId())
  end
end
function ObjectivesLayer:OnObjectiveSortingChanged()
  for _, poiInfo in pairs(self.taskToPoiInfoMap) do
    local sortingPos = ObjectivesComponentRequestBus.Event.GetObjectiveSortingPos(self.objectiveEntityId, poiInfo.icon.iconData.id.objectiveInstanceId)
    poiInfo.sortingPos = sortingPos
  end
  for poi, taskList in pairs(self.poiToTasksMap) do
    table.sort(taskList, function(a, b)
      return self.taskToPoiInfoMap[a].sortingPos >= 0 and (self.taskToPoiInfoMap[b].sortingPos < 0 or self.taskToPoiInfoMap[a].sortingPos < self.taskToPoiInfoMap[b].sortingPos)
    end)
    self:UpdateObjectiveIconsAtPoi(poi)
  end
end
function ObjectivesLayer:OnObjectiveTaskPositionAdded(objectiveTaskInstanceId, position, isTracked, attachedPoi)
  for i = 1, #self.cachedIcons do
    if self.cachedIcons[i].iconData and self.cachedIcons[i].iconData.id and self.cachedIcons[i].iconData.id == objectiveTaskInstanceId then
      local shouldUseExistingIcon = true
      local poiInfo = self.taskToPoiInfoMap[objectiveTaskInstanceId:ToString()]
      if poiInfo and poiInfo.poi ~= attachedPoi then
        shouldUseExistingIcon = self:RemoveObjectiveIconFromPoi(self.cachedIcons[i], true)
      end
      if shouldUseExistingIcon then
        local anchors = self.markersLayer:WorldPositionToAnchors(position)
        self.cachedIcons[i]:SetAnchorsPosition(anchors, position)
        self.cachedIcons[i].iconData.id = objectiveTaskInstanceId
        if attachedPoi ~= 0 then
          self:AddObjectiveIconToPoi(self.cachedIcons[i], attachedPoi)
        end
        return
      end
    end
  end
  local objectiveId = objectiveTaskInstanceId.objectiveInstanceId
  if not objectiveId then
    return
  end
  local taskIdString = objectiveTaskInstanceId:ToString()
  local addedTaskToExistingIcon = false
  for _, poiInfo in pairs(self.taskToPoiInfoMap) do
    if poiInfo.icon.iconData.id.objectiveInstanceId == objectiveId then
      if poiInfo.poi == attachedPoi then
        poiInfo.extraTaskList[taskIdString] = objectiveTaskInstanceId
        addedTaskToExistingIcon = true
      elseif poiInfo.extraTaskList[taskIdString] then
        poiInfo.extraTaskList[taskIdString] = nil
      end
    end
  end
  if addedTaskToExistingIcon then
    return
  end
  local availableIcon = self:GetFirstAvailableIcon()
  if not availableIcon then
    return
  end
  local objectiveTitle, description
  if objectiveId then
    local missionParams = ObjectiveRequestBus.Event.GetCreationParams(objectiveId)
    if missionParams then
      objectiveTitle, description = ObjectivesDataHandler:GetMissionTitleAndDescription(missionParams, objectiveId)
    end
  end
  local isPinned = ObjectivesComponentRequestBus.Event.IsObjectiveTracked(self.playerEntityId, objectiveId)
  local iconPath, iconColor, readyToTurnIn = ObjectiveTypeData:GetObjectiveIconByObjectiveInstanceId(objectiveId)
  local anchors = self.markersLayer:WorldPositionToAnchors(position)
  local iconData = {
    isActiveObjective = true,
    id = objectiveTaskInstanceId,
    titleText = objectiveTitle and objectiveTitle or "@objective_objective",
    descriptionText = description and description or "@objective_objective",
    imageFGColor = iconColor,
    imageFGPath = iconPath,
    dataManager = self,
    anchors = anchors,
    worldPosition = position,
    isPinned = isPinned
  }
  if ObjectivesComponentRequestBus.Event.IsObjectiveReadyForCompletion(self.playerEntityId, objectiveId) then
    local objectiveData = ObjectiveRequestBus.Event.GetObjectiveData(objectiveId)
    if objectiveData.npcDestinationId and objectiveData.npcDestinationId ~= "" then
      iconData.npcId = objectiveData.npcDestinationId
    end
  end
  availableIcon:SetData(iconData)
  availableIcon:SetFlyoutMenuOverride(self, self.OnActiveObjectiveIconHover)
  if attachedPoi ~= 0 then
    self:AddObjectiveIconToPoi(availableIcon, attachedPoi)
  end
  availableIcon:SetScale(self.currentScale)
end
function ObjectivesLayer:OnObjectiveTaskPositionsRemoved(objectiveTaskInstanceId)
  for i = 1, #self.cachedIcons do
    if self.cachedIcons[i].iconData and self.cachedIcons[i].iconData.id and self.cachedIcons[i].iconData.id == objectiveTaskInstanceId then
      local shouldResetIcon = true
      if self.taskToPoiInfoMap[objectiveTaskInstanceId:ToString()] then
        shouldResetIcon = self:RemoveObjectiveIconFromPoi(self.cachedIcons[i], true)
      end
      if shouldResetIcon then
        self.cachedIcons[i]:Reset()
      end
      break
    elseif self.cachedIcons[i].iconData and self.cachedIcons[i].iconData.id and self.cachedIcons[i].iconData.id.objectiveInstanceId == objectiveTaskInstanceId.objectiveInstanceId then
      local success = self:RemoveTaskFromIcon(objectiveTaskInstanceId, self.cachedIcons[i])
      if success then
        break
      end
    end
  end
end
function ObjectivesLayer:OnObjectiveRemoved(objectiveId)
  for i = 1, #self.cachedIcons do
    if self.cachedIcons[i].iconData and self.cachedIcons[i].iconData.id and self.cachedIcons[i].iconData.id.objectiveInstanceId == objectiveId then
      if self.taskToPoiInfoMap[self.cachedIcons[i].iconData.id:ToString()] then
        self:RemoveObjectiveIconFromPoi(self.cachedIcons[i])
      end
      self.cachedIcons[i]:Reset()
    end
  end
end
function ObjectivesLayer:OnObjectivesChanged()
  if not self.isVisible then
    return
  end
  for i = 1, #self.cachedIcons do
    local simpleObjectiveIcon = self.cachedIcons[i]
    local iconData = simpleObjectiveIcon.iconData
    if iconData and iconData.isActiveObjective then
      local objectiveTaskInstanceId = iconData.id
      local objectiveId = objectiveTaskInstanceId.objectiveInstanceId
      local isPinned = ObjectivesComponentRequestBus.Event.IsObjectiveTracked(self.playerEntityId, objectiveId)
      local objectiveIcon, iconColor, readyToTurnIn = ObjectiveTypeData:GetObjectiveIconByObjectiveInstanceId(objectiveId)
      simpleObjectiveIcon:SetMapIconImage(objectiveIcon)
      simpleObjectiveIcon:SetPinEnabled(isPinned)
    end
  end
  self:UpdateAvailableObjectiveIcons()
  self.isHidingObjectiveIcons = false
  self:UpdateVisibilityForZoomLevel(self.lastZoomLevel)
end
function ObjectivesLayer:GetObjectiveTasksByTerritoryId(territoryId)
  return self.poiToTasksMap[territoryId]
end
function ObjectivesLayer:GetObjectivePosition(objectiveInstanceId, findAll)
  local taskIds = ObjectiveRequestBus.Event.GetTasks(objectiveInstanceId)
  if not taskIds then
    return
  end
  local results
  if findAll then
    results = {}
  end
  for i = 1, #self.cachedIcons do
    local iconData = self.cachedIcons[i].iconData
    if iconData and iconData.isActiveObjective then
      local anythingFound = false
      for j = 1, #taskIds do
        local objectiveTaskInstanceId = taskIds[j]
        if self:FindMatchingWorldPosition(objectiveTaskInstanceId, iconData.id) then
          anythingFound = true
          if findAll then
            table.insert(results, iconData.worldPosition)
          else
            return iconData.worldPosition
          end
        end
      end
      if not anythingFound and iconData.id.objectiveInstanceId == objectiveInstanceId then
        if findAll then
          table.insert(results, iconData.worldPosition)
        else
          return iconData.worldPosition
        end
      end
    end
  end
  return results
end
function ObjectivesLayer:GetCompletableObjectivePosition(objectiveInstanceId)
  for i = 1, #self.cachedIcons do
    local iconData = self.cachedIcons[i].iconData
    if iconData and iconData.isActiveObjective and iconData.id.objectiveInstanceId == objectiveInstanceId then
      return iconData.worldPosition
    end
  end
  return nil
end
function ObjectivesLayer:FindMatchingWorldPosition(taskId, taskIdToMatch)
  if taskIdToMatch == taskId then
    return true
  end
  local subtaskIds = ObjectiveTaskRequestBus.Event.GetTasks(taskId)
  for i = 1, #subtaskIds do
    return self:FindMatchingWorldPosition(subtaskIds[i], taskIdToMatch)
  end
  return false
end
function ObjectivesLayer:OnZoomLevelChanged(zoomLevel)
  if not zoomLevel then
    return
  end
  local isValidZoom = zoomLevel <= self.MAX_ZOOM_LEVEL
  if isValidZoom ~= self.isValidZoom then
    UiElementBus.Event.SetIsEnabled(self.entityId, isValidZoom)
    self.isValidZoom = isValidZoom
  end
  if self.isValidZoom then
    if zoomLevel <= 0.25 then
      self.currentScale = 1
    elseif zoomLevel <= 0.5 then
      self.currentScale = 0.5
    elseif zoomLevel <= 2 then
      self.currentScale = 0.5
    elseif zoomLevel <= 4 then
      self.currentScale = 0.5
    else
      self.currentScale = 0.3
    end
    for i = 1, #self.cachedIcons do
      if self.cachedIcons[i].iconData then
        self.cachedIcons[i]:SetScale(self.currentScale)
      end
    end
    for i = 1, #self.cachedExtraPoiObjectivesLabels do
      if self.cachedExtraPoiObjectivesLabels[i].isEnabled then
        self.cachedExtraPoiObjectivesLabels[i]:SetScale(self.currentScale)
      end
    end
    for poi, _ in pairs(self.poiToTasksMap) do
      self:UpdateObjectiveIconsAtPoi(poi)
    end
    self:UpdateVisibilityForZoomLevel(zoomLevel)
    self.lastZoomLevel = zoomLevel
  end
end
function ObjectivesLayer:UpdateVisibilityForZoomLevel(zoomLevel)
  local stationIconZoomLevel = 0.5
  if self.isHidingObjectiveIcons and zoomLevel <= stationIconZoomLevel then
    self.isHidingObjectiveIcons = false
    for i = 1, #self.cachedIcons do
      local icon = self.cachedIcons[i]
      local iconData = icon.iconData
      if iconData then
        if iconData.id and (not self.taskToPoiInfoMap[iconData.id:ToString()] or not self.taskToPoiInfoMap[iconData.id:ToString()].shouldHide) then
          UiElementBus.Event.SetIsEnabled(icon.entityId, true)
        elseif not iconData.isActiveObjective then
          UiElementBus.Event.SetIsEnabled(icon.entityId, true)
        end
      end
    end
  elseif not self.isHidingObjectiveIcons and zoomLevel > stationIconZoomLevel then
    self.isHidingObjectiveIcons = true
    for j = 1, #self.cachedIcons do
      local icon = self.cachedIcons[j]
      local iconData = icon.iconData
      if iconData then
        for _, settlementData in ipairs(self.poiCapitalPositions) do
          iconData.worldPosition.z = 0
          if iconData.worldPosition:GetDistanceSq(settlementData.worldPosition) < settlementData.radiusSq then
            UiElementBus.Event.SetIsEnabled(icon.entityId, false)
            break
          end
        end
      end
    end
  end
end
return ObjectivesLayer
