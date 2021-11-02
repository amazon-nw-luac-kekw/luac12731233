local ObjectiveDataHelper = {
  REWARD_TYPES = {
    FACTION_REPUTATION = 0,
    CURRENCY = 1,
    XP = 2,
    ITEM = 3,
    COMMUNITY_POINTS = 4,
    TERRITORY_STANDING = 5,
    CATEGORICAL = 6,
    AZOTH = 7,
    FACTION_INFLUENCE = 8,
    RECIPE = 9,
    FACTION_TOKENS = 10
  }
}
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
function ObjectiveDataHelper:DebugLogObjective(objectiveId, includeTasks, includeRewards)
  local outString = ""
  local objectiveType = ObjectiveRequestBus.Event.GetType(objectiveId)
  local objective = {
    title = ObjectiveRequestBus.Event.GetTitle(objectiveId),
    description = ObjectiveRequestBus.Event.GetDescription(objectiveId),
    taskIds = ObjectiveRequestBus.Event.GetTasks(objectiveId),
    tasks = {},
    type = ObjectiveRequestBus.Event.GetType(objectiveId)
  }
  local objectiveTypeString = "unknown"
  local allTypes = {
    [eObjectiveType_CommunityGoal] = "community",
    [eObjectiveType_Crafting] = "crafting (recipe)",
    [eObjectiveType_Darkness_Minor] = "darkness",
    [eObjectiveType_Darkness_Major] = "darkness",
    [eObjectiveType_Journey] = "journey",
    [eObjectiveType_Mission] = "faction mission",
    [eObjectiveType_Objective] = "generic objective (indicates a problem)",
    [eObjectiveType_POI] = "POI",
    [eObjectiveType_Dungeon] = "dungeon",
    [eObjectiveType_Quest] = "quest",
    [eObjectiveType_DefendObject] = "defendobject",
    [eObjectiveType_DynamicPOI] = "dynamicpoi"
  }
  for typeIndex, typeString in pairs(allTypes) do
    if objective.type == typeIndex then
      objectiveTypeString = typeString
      break
    end
  end
  if objective.taskIds ~= nil then
    for i = 1, #objective.taskIds do
      local task = {
        description = ObjectiveTaskRequestBus.Event.GetDescription(objective.taskIds[i]),
        itemDescriptor = ObjectiveTaskRequestBus.Event.GetUIData(objective.taskIds[i], "ItemDescriptor")
      }
      table.insert(objective.tasks, task)
    end
  end
  outString = "[DEBUG] Objective: " .. LyShineScriptBindRequestBus.Broadcast.LocalizeText(objective.title) .. "\n"
  outString = outString .. "[DEBUG] \ttype: " .. objectiveTypeString .. " (" .. tostring(objective.type) .. ")\n"
  outString = outString .. "[DEBUG] \tdescription: " .. LyShineScriptBindRequestBus.Broadcast.LocalizeText(objective.description) .. "\n"
  if includeTasks ~= false then
    outString = outString .. "[DEBUG] \ttasks:\n"
    for i = 1, #objective.tasks do
      outString = outString .. "[DEBUG] \t\t" .. LyShineScriptBindRequestBus.Broadcast.LocalizeText(objective.tasks[i].description) .. "\n"
      if objective.tasks[i].itemDescriptor then
        outString = outString .. "[DEBUG] \t\t\t" .. tostring(objective.tasks[i].itemDescriptor:GetItemKey()) .. "\n"
      end
    end
  end
  if includeRewards ~= false then
    local rewards = self:GetRewardData(objectiveId)
    local rewardTypes = {
      [self.REWARD_TYPES.FACTION_REPUTATION] = "faction reputation",
      [self.REWARD_TYPES.CURRENCY] = "coin currency",
      [self.REWARD_TYPES.XP] = "xp",
      [self.REWARD_TYPES.ITEM] = "item",
      [self.REWARD_TYPES.COMMUNITY_POINTS] = "community points",
      [self.REWARD_TYPES.TERRITORY_STANDING] = "territory standing",
      [self.REWARD_TYPES.FACTION_INFLUENCE] = "faction influence",
      [self.REWARD_TYPES.FACTION_TOKENS] = "faction tokens"
    }
    outString = outString .. "[DEBUG] \trewards:\n"
    for i = 1, #rewards do
      outString = outString .. "[DEBUG] \t\t" .. rewardTypes[rewards[i].type] .. ": " .. tostring(rewards[i]) .. "\n"
    end
  end
  Debug.Log(outString)
end
function ObjectiveDataHelper:GetRewardEventData(objectiveId, missionId)
  if not objectiveId then
    Debug.Log("[WARNING] Attempted to get reward data without an objectiveId")
    return {}
  end
  if missionId then
    local missionData = ObjectivesDataManagerBus.Broadcast.GetMissionData(missionId)
    if missionData.successGameEventIdOverride ~= GetNilCrc() then
      return self:GetGameEventDataWithObjectiveRewardData(missionData.successGameEventIdOverride, missionData.objectiveId)
    end
  end
  local objectiveData
  objectiveData = ObjectiveRequestBus.Event.GetObjectiveData(objectiveId)
  if not (objectiveData and objectiveData.id) or not objectiveData.successGameEventId then
    return {}
  end
  return self:GetGameEventDataWithObjectiveRewardData(objectiveData.successGameEventId, Math.CreateCrc32(objectiveData.id))
end
function ObjectiveDataHelper:GetRewardData(objectiveId, missionId)
  if not objectiveId then
    Debug.Log("[WARNING] Attempted to get reward data without an objectiveId")
    return {}
  end
  if missionId then
    local missionData = ObjectivesDataManagerBus.Broadcast.GetMissionData(missionId)
    if missionData.successGameEventIdOverride ~= GetNilCrc() then
      successRewardDataId = missionData.successGameEventIdOverride
      local successRewardData = self:GetGameEventDataWithObjectiveRewardData(successRewardDataId, missionData.objectiveId)
      return self:GetRewardDataFromGameEventData(successRewardData)
    end
  end
  local objectiveData
  objectiveData = ObjectiveRequestBus.Event.GetObjectiveData(objectiveId)
  return self:GetRewardDataFromObjectiveData(objectiveData)
end
function ObjectiveDataHelper:GetRewardDataFromCrc(objectiveCrcId, missionId)
  if not objectiveCrcId then
    Debug.Log("[WARNING] Attempted to get reward data without an objectiveCrcId")
    return {}
  end
  if missionId then
    local missionData = ObjectivesDataManagerBus.Broadcast.GetMissionData(missionId)
    if missionData.successGameEventIdOverride ~= GetNilCrc() then
      successRewardDataId = missionData.successGameEventIdOverride
      local successRewardData = self:GetGameEventDataWithObjectiveRewardData(successRewardDataId, missionData.objectiveId)
      return self:GetRewardDataFromGameEventData(successRewardData)
    end
  end
  local objectiveData
  objectiveData = ObjectivesDataManagerBus.Broadcast.GetObjectiveData(objectiveCrcId)
  return self:GetRewardDataFromObjectiveData(objectiveData)
end
function ObjectiveDataHelper:GetDefinitionFromExternalObjective(objectiveId)
  local owningEntityId = ObjectiveRequestBus.Event.GetOwningEntityId(objectiveId)
  local localPlayerId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  if localPlayerId == owningEntityId then
    return
  end
  local definitionId = TerritoryDataProviderRequestBus.Event.GetTerritoryId(owningEntityId)
  definitionId = definitionId or TerritoryComponentRequestBus.Event.GetTerritoryId(owningEntityId)
  if definitionId then
    return TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(definitionId)
  end
end
function ObjectiveDataHelper:GetRewardDataFromObjectiveData(objectiveData)
  if not (objectiveData and objectiveData.id) or not objectiveData.successGameEventId then
    return {}
  end
  local successRewardData = self:GetGameEventDataWithObjectiveRewardData(objectiveData.successGameEventId, Math.CreateCrc32(objectiveData.id))
  local objectiveRewards = self:GetRewardDataFromGameEventData(successRewardData)
  if objectiveData.achievementId ~= 0 then
    local recipeId = RecipeDataManagerBus.Broadcast.GetRecipeIdByAchievementId(objectiveData.achievementId)
    if recipeId ~= 0 then
      local reward = {
        type = self.REWARD_TYPES.RECIPE,
        value = recipeId
      }
      table.insert(objectiveRewards, reward)
    end
  end
  return objectiveRewards
end
function ObjectiveDataHelper:GetRewardDataFromGameEventData(successRewardData)
  local objectiveRewards = {}
  if successRewardData.progressionReward > 0 then
    local reward = {
      type = self.REWARD_TYPES.XP,
      value = successRewardData.progressionReward
    }
    table.insert(objectiveRewards, reward)
  end
  if 0 < successRewardData.categoricalProgressionReward then
    local localPlayerId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    local progressionData = CategoricalProgressionRequestBus.Event.GetCategoricalProgressionData(localPlayerId, successRewardData.categoricalProgressionId)
    local curRank = CategoricalProgressionRequestBus.Event.GetRank(localPlayerId, successRewardData.categoricalProgressionId)
    local rankData = CategoricalProgressionRequestBus.Event.GetRankData(localPlayerId, successRewardData.categoricalProgressionId, curRank + successRewardData.categoricalProgressionReward)
    local rankDisplayValue = rankData.displayName == "" and successRewardData.categoricalProgressionReward or LyShineScriptBindRequestBus.Broadcast.LocalizeText(rankData.displayName)
    if type(rankDisplayValue) == "number" then
      rankDisplayValue = GetLocalizedNumber(rankDisplayValue)
    end
    local reward = {
      type = self.REWARD_TYPES.CATEGORICAL,
      value = successRewardData.categoricalProgressionReward,
      categoricalProgressionId = successRewardData.categoricalProgressionId,
      displayName = progressionData.displayName,
      displayValue = rankDisplayValue,
      iconPath = progressionData.iconPath,
      shouldShowAsObjectiveReward = progressionData.showAsObjectiveReward
    }
    table.insert(objectiveRewards, reward)
  end
  if 0 < string.len(successRewardData.currencyRewardRange) and successRewardData.currencyRewardRange ~= "0" then
    local reward = {
      type = self.REWARD_TYPES.CURRENCY,
      value = GetLocalizedCurrency(successRewardData.currencyRewardRange)
    }
    table.insert(objectiveRewards, reward)
  end
  local playerFaction = dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
  if playerFaction ~= eFactionType_None and successRewardData.factionReputation and 0 < successRewardData.factionReputation then
    local reward = {
      type = self.REWARD_TYPES.FACTION_REPUTATION,
      value = successRewardData.factionReputation
    }
    table.insert(objectiveRewards, reward)
  end
  if playerFaction ~= eFactionType_None and successRewardData.factionTokens and 0 < successRewardData.factionTokens then
    local reward = {
      type = self.REWARD_TYPES.FACTION_TOKENS,
      value = successRewardData.factionTokens
    }
    table.insert(objectiveRewards, reward)
  end
  if playerFaction ~= eFactionType_None and successRewardData.factionInfluenceAmount and 0 < successRewardData.factionInfluenceAmount then
    local reward = {
      type = self.REWARD_TYPES.FACTION_INFLUENCE,
      value = 0
    }
    table.insert(objectiveRewards, reward)
  end
  if 0 < successRewardData.territoryStanding then
    local reward = {
      type = self.REWARD_TYPES.TERRITORY_STANDING,
      value = successRewardData.territoryStanding
    }
    table.insert(objectiveRewards, reward)
  end
  if successRewardData.itemReward and 0 < #successRewardData.itemReward then
    local reward = {
      type = self.REWARD_TYPES.ITEM,
      value = successRewardData.itemReward
    }
    table.insert(objectiveRewards, reward)
  end
  if successRewardData.azothReward and 0 < successRewardData.azothReward then
    local reward = {
      type = self.REWARD_TYPES.AZOTH,
      value = GetFormattedNumber(successRewardData.azothReward)
    }
    table.insert(objectiveRewards, reward)
  end
  return objectiveRewards
end
function ObjectiveDataHelper:GetGameEventDataWithObjectiveRewardData(gameEventId, objectiveCrcId)
  local gameEventData = GameEventRequestBus.Broadcast.GetGameSystemData(gameEventId)
  local combinedData = GameEventRequestBus.Broadcast.CreateCopyOfGameEventData(gameEventData)
  if objectiveCrcId then
    local rewardsFromObjectiveData = ObjectivesDataManagerBus.Broadcast.GetObjectiveRewards(objectiveCrcId)
    if rewardsFromObjectiveData then
      combinedData.progressionReward = combinedData.progressionReward + rewardsFromObjectiveData.experienceReward
      if string.len(rewardsFromObjectiveData.itemRewardId) > 0 and rewardsFromObjectiveData.itemRewardIsGive and 0 < rewardsFromObjectiveData.itemRewardQuantity then
        if 0 < string.len(combinedData.itemReward) then
          Debug.Log("ERROR: there must not be an item specified in objective rewards and success game event rewards for objectiveId: " .. tostring(objectiveCrcId))
        end
        combinedData.itemReward = rewardsFromObjectiveData.itemRewardId
      end
    end
  end
  return combinedData
end
return ObjectiveDataHelper
