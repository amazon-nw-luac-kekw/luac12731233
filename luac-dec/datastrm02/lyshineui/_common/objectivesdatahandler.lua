local ObjectivesDataHandler = {}
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local DifficultyColors = RequireScript("LyShineUI._Common.DifficultyColors")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local UIStyle = RequireScript("LyShineUI._Common.UIStyle")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
function ObjectivesDataHandler:OnActivate()
end
function ObjectivesDataHandler:OnDeactivate()
end
function ObjectivesDataHandler:Reset()
  self:OnDeactivate()
end
function ObjectivesDataHandler:HasArenaObjective()
  local playerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  local isInArena = false
  local objectives = ObjectivesComponentRequestBus.Event.GetObjectives(playerEntityId)
  for i = 1, #objectives do
    local objectiveId = objectives[i]
    local objectiveType = ObjectiveRequestBus.Event.GetType(objectiveId)
    if objectiveType == eObjectiveType_Arena then
      local objectiveEntityId = ObjectiveRequestBus.Event.GetOwningEntityId(objectiveId)
      isInArena = ArenaRequestBus.Event.IsArenaActive(objectiveEntityId) == true
      if isInArena then
        break
      end
    end
  end
  return isInArena
end
function ObjectivesDataHandler:GetMissionTitleAndDescription(objectiveParams, objectiveId, showTerritoryName)
  local titleString = ""
  local descriptionString = ""
  local subtitleString = ""
  local difficultyLevel = 0
  local territoryString
  if objectiveId then
    if showTerritoryName then
      local data = ObjectiveRequestBus.Event.GetObjectiveData(objectiveId)
      local territoryId = self:GetTerritoryIdForNpc(data.npcDestinationId)
      if territoryId ~= 0 then
        local territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(territoryId)
        territoryString = GetLocalizedReplacementText("@objective_subtitle_locationwithcolor", {
          color = ColorRgbaToHexString(UIStyle.COLOR_WHITE),
          territoryName = territoryName
        })
      end
    end
    difficultyLevel = ObjectiveRequestBus.Event.GetDifficultyLevel(objectiveId)
  end
  local missionData = ObjectivesDataManagerBus.Broadcast.GetMissionData(objectiveParams.missionId)
  if string.len(missionData.titleOverride) == 0 and string.len(missionData.descriptionOverride) == 0 then
    if objectiveId then
      titleString = ObjectiveRequestBus.Event.GetTitle(objectiveId)
      descriptionString = self:GetDescription(objectiveId, objectiveParams, missionData)
    end
  else
    local destinationData = self:GetDestination(objectiveParams.destinationOverride)
    local destination = ""
    if destinationData then
      destination = destinationData.nameLocalizationKey
      territoryString = GetLocalizedReplacementText("@objective_subtitle_locationwithcolor", {
        color = ColorRgbaToHexString(UIStyle.COLOR_WHITE),
        territoryName = destination
      })
    end
    local territoryName = ""
    if missionData.territoryIdOverride ~= 0 then
      local territoryDefn = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(missionData.territoryIdOverride)
      territoryName = territoryDefn.nameLocalizationKey
      territoryString = GetLocalizedReplacementText("@objective_subtitle_locationwithcolor", {
        color = ColorRgbaToHexString(UIStyle.COLOR_WHITE),
        territoryName = territoryName
      })
    end
    local poiName = ""
    if 0 < #missionData.poiTagsOverride then
      local territoryDefn = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinitionByPoiTag(missionData.poiTagsOverride[1])
      poiName = territoryDefn.nameLocalizationKey
    end
    local replacementKeys = {
      enemyName = "@VC_" .. missionData.taskKillContributionOverride,
      killAmount = tostring(missionData.taskKillContributionQtyOverride),
      destinationName = destination,
      itemName = StaticItemDataManager:GetItemName(missionData.taskHaveItemsOverride),
      itemAmount = tostring(missionData.taskHaveItemsQtyOverride),
      giveItemName = StaticItemDataManager:GetItemName(missionData.taskGiveItemOverride),
      time = tostring(missionData.taskTimerOverride),
      territoryID = territoryName,
      POITags = poiName
    }
    titleString = GetLocalizedReplacementText(missionData.titleOverride, replacementKeys)
    descriptionString = GetLocalizedReplacementText(missionData.descriptionOverride, replacementKeys)
  end
  local difficultyString
  if difficultyLevel and 0 < difficultyLevel then
    local difficultyColor = DifficultyColors:GetColor(difficultyLevel)
    difficultyString = GetLocalizedReplacementText("@objective_recommendedlevelwithcolor", {
      color = ColorRgbaToHexString(difficultyColor),
      level = difficultyLevel
    })
  end
  if territoryString and difficultyString then
    subtitleString = GetLocalizedReplacementText([[
@objective_subtitle_locationanddifficulty

]], {territory = territoryString, difficulty = difficultyString})
  elseif territoryString then
    subtitleString = string.format([[
%s

]], territoryString)
  elseif difficultyString then
    subtitleString = string.format([[
%s

]], difficultyString)
  end
  if string.len(titleString) == 0 and string.len(descriptionString) == 0 then
    Debug.Log("[ObjectivesDataHandler:GetMissionTitleAndDescription] return nil, nil")
    return nil, nil
  end
  return titleString, subtitleString .. descriptionString
end
function ObjectivesDataHandler:GetDestination(destinationId)
  if not self.destinationList then
    self.destinationList = MapComponentBus.Broadcast.GetOutposts()
  end
  if not self.claimList then
    self.claimList = MapComponentBus.Broadcast.GetClaims()
  end
  for i = 1, #self.destinationList do
    if destinationId == self.destinationList[i].id then
      return self.destinationList[i]
    end
  end
  for i = 1, #self.claimList do
    if destinationId == self.claimList[i].id then
      return self.claimList[i]
    end
  end
  return nil
end
function ObjectivesDataHandler:GetDescription(objectiveId, objectiveParams)
  local descText = ObjectiveRequestBus.Event.GetDescription(objectiveId)
  if objectiveParams.missionId ~= 0 then
    return self:GetLocalizedDescText(descText, objectiveParams)
  else
    local playerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    local currentMissionObjectiveId = ObjectivesComponentRequestBus.Event.GetCurrentMissionObjectiveId(playerEntityId)
    if currentMissionObjectiveId == objectiveId then
      return self:GetLocalizedDescText(descText)
    end
  end
  return descText
end
function ObjectivesDataHandler:GetLocalizedDescText(descText, objectiveParams, missionData)
  if not missionData then
    if objectiveParams then
      missionData = ObjectivesDataManagerBus.Broadcast.GetMissionData(objectiveParams.missionId)
    else
      local playerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
      local currentMissionId = ObjectivesComponentRequestBus.Event.GetCurrentMissionId(playerEntityId)
      missionData = ObjectivesDataManagerBus.Broadcast.GetMissionData(currentMissionId)
    end
  end
  local destination = ""
  if objectiveParams then
    local destinationData = self:GetDestination(objectiveParams.destinationOverride)
    if destinationData then
      destination = destinationData.nameLocalizationKey
    else
      local originTerritoryDefn = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(objectiveParams.originTerritoryId)
      destination = originTerritoryDefn.nameLocalizationKey
    end
  end
  local territoryName = ""
  if missionData.territoryIdOverride ~= 0 then
    local territoryDefn = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(missionData.territoryIdOverride)
    territoryName = territoryDefn.nameLocalizationKey
  end
  local poiName = ""
  if 0 < #missionData.poiTagsOverride then
    local poiDefn = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinitionByPoiTag(missionData.poiTagsOverride[1])
    poiName = poiDefn.nameLocalizationKey
  end
  return GetLocalizedReplacementText(descText, {
    enemyName = "@VC_" .. missionData.taskKillContributionOverride,
    killAmount = tostring(missionData.taskKillContributionQtyOverride),
    itemName = StaticItemDataManager:GetItemName(missionData.taskHaveItemsOverride),
    itemAmount = tostring(missionData.taskHaveItemsQtyOverride),
    giveItemName = StaticItemDataManager:GetItemName(missionData.taskGiveItemOverride),
    time = tostring(missionData.taskTimerOverride),
    destinationName = destination,
    territoryID = territoryName,
    POITags = poiName
  })
end
function ObjectivesDataHandler:GetAvailableObjectivesByTerritoryId(territoryId, refreshCache)
  if not self.questDataCache then
    self.questDataCache = {}
  end
  local questsByTerritoryId = self.questDataCache[territoryId]
  if not questsByTerritoryId then
    questsByTerritoryId = {}
    self.questDataCache[territoryId] = questsByTerritoryId
  end
  if not refreshCache then
    return questsByTerritoryId
  else
    ClearTable(questsByTerritoryId)
    local playerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    local quests = ObjectivesComponentRequestBus.Event.GetAvailableQuestsByTerritoryId(playerEntityId, territoryId, true)
    for i = 1, #quests do
      local questData = quests[i]
      table.insert(questsByTerritoryId, {
        npcId = questData.npcId,
        objectiveId = questData.objectiveId,
        worldPosition = questData.worldPosition
      })
    end
  end
  return questsByTerritoryId
end
ObjectivesDataHandler.settlementBoundsToleranceSq = 30625
function ObjectivesDataHandler:GetCompletableObjectivesNearPositionCount(worldPosition)
  local playerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  local objectives = ObjectivesComponentRequestBus.Event.GetObjectives(playerEntityId)
  local posVec2 = Vector2(0, 0)
  local numCompletableObjectives = 0
  local atLeastOnePinned = false
  for i = 1, #objectives do
    local objectiveInstanceId = objectives[i]
    local canCompleteObjective = ObjectivesComponentRequestBus.Event.IsObjectiveReadyForCompletion(playerEntityId, objectiveInstanceId)
    if canCompleteObjective then
      local pos = DynamicBus.ObjectivesLayer.Broadcast.GetCompletableObjectivePosition(objectiveInstanceId, false)
      if pos then
        posVec2.x = pos.x
        posVec2.y = pos.y
        if posVec2:GetDistanceSq(worldPosition) < self.settlementBoundsToleranceSq then
          numCompletableObjectives = numCompletableObjectives + 1
          atLeastOnePinned = atLeastOnePinned or ObjectivesComponentRequestBus.Event.IsObjectiveTracked(playerEntityId, objectiveInstanceId)
        end
      end
    end
  end
  return numCompletableObjectives, atLeastOnePinned
end
function ObjectivesDataHandler:GetNpcPositionsInTerritory(territoryId)
  if not self.npcDataCache then
    self.npcDataCache = {}
  end
  if not self.npcDataCache[territoryId] then
    self.npcDataCache[territoryId] = {}
    local playerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    local allNpcsInThisTerritory = ObjectivesComponentRequestBus.Event.GetAvailableQuestsByTerritoryId(playerEntityId, territoryId, false)
    for i = 1, #allNpcsInThisTerritory do
      local npcData = allNpcsInThisTerritory[i]
      self.npcDataCache[territoryId][npcData.npcId] = npcData.worldPosition
    end
  end
  return self.npcDataCache[territoryId]
end
function ObjectivesDataHandler:GetTerritoryIdForNpc(npcId)
  local territories = MapComponentBus.Broadcast.GetTerritories()
  for i = 1, #territories do
    local territoryPrismData = territories[i]
    local territoryId = territoryPrismData.id
    local npcPositionsInTerritory = self:GetNpcPositionsInTerritory(territoryId)
    if npcPositionsInTerritory[npcId] then
      return territoryId
    end
  end
  return 0
end
return ObjectivesDataHandler
