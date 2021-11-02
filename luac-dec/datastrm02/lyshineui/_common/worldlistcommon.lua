local WorldListCommon = {
  SORT_BYNONE = 0,
  SORT_BYNAME_ASC = 1,
  SORT_BYNAME_DESC = 2,
  SORT_BYLASTPLAYED_ASC = 3,
  SORT_BYLASTPLAYED_DESC = 4,
  SORT_BYPOPULATION_ASC = 5,
  SORT_BYPOPULATION_DESC = 6,
  SORT_BYWORLDSET_ASC = 7,
  SORT_BYWORLDSET_DESC = 8,
  SORT_BYCHARACTER_ASC = 9,
  SORT_BYCHARACTER_DESC = 10,
  SORT_BYWAIT_ASC = 11,
  SORT_BYWAIT_DESC = 12,
  SORT_BYFRIENDS_ASC = 13,
  SORT_BYFRIENDS_DESC = 14,
  SORT_BYQUEUE_ASC = 15,
  SORT_BYQUEUE_DESC = 16,
  SORT_BYRECOMMENDED = 17,
  POPULATION_LOW = 0,
  POPULATION_MED = 1,
  POPULATION_HIGH = 2,
  populationTolerance = 100,
  defaultWorldCharName = "-",
  worldSetImageId = {}
}
local registrar = RequireScript("LyShineUI.EntityRegistrar")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function WorldListCommon:GetSortByRecommendedWorld()
  return function(first, second)
    local firstDown = first.worldData.publicStatusCode ~= 0
    local secondDown = second.worldData.publicStatusCode ~= 0
    if firstDown == secondDown then
      if first.lastPlayed == second.lastPlayed then
        if first.numFriends == second.numFriends then
          local isFirstFull = first.worldData.connectionCount >= first.worldData.maxConnectionCount
          local isSecondfull = second.worldData.connectionCount >= second.worldData.maxConnectionCount
          if isFirstFull == isSecondfull then
            local roundedFirstPop = math.floor(first.populationCount / self.populationTolerance)
            local roundedSecondPop = math.floor(second.populationCount / self.populationTolerance)
            if roundedFirstPop == roundedSecondPop then
              return first.worldData.worldMetrics.queueSize < second.worldData.worldMetrics.queueSize
            else
              return roundedFirstPop < roundedSecondPop
            end
          else
            return isSecondfull
          end
        else
          return first.numFriends > second.numFriends
        end
      elseif first.lastPlayed == 0 then
        return false
      elseif second.lastPlayed == 0 then
        return true
      else
        return first.lastPlayed < second.lastPlayed
      end
    else
      return secondDown
    end
  end
end
function WorldListCommon:ReturnDefaultSort(first, second, isDescending)
  if isDescending then
    local temp = first
    first = second
    second = temp
  end
  if first.worldData.worldMetrics.queueWaitTimeSec == second.worldData.worldMetrics.queueWaitTimeSec then
    if first.worldSetName == second.worldSetName then
      return first.worldData.name < second.worldData.name
    else
      return first.worldSetName < second.worldSetName
    end
  else
    return first.worldData.worldMetrics.queueWaitTimeSec < second.worldData.worldMetrics.queueWaitTimeSec
  end
end
function WorldListCommon:SortWorldList(sortType, worldList)
  if sortType == self.SORT_BYRECOMMENDED then
    table.sort(worldList, self:GetSortByRecommendedWorld())
  elseif sortType == self.SORT_BYNAME_ASC then
    table.sort(worldList, function(first, second)
      if first.worldSetName == second.worldSetName then
        return first.worldData.name < second.worldData.name
      end
      return first.worldSetName < second.worldSetName
    end)
  elseif sortType == self.SORT_BYNAME_DESC then
    table.sort(worldList, function(first, second)
      if first.worldSetName == second.worldSetName then
        return first.worldData.name > second.worldData.name
      end
      return first.worldSetName > second.worldSetName
    end)
  elseif sortType == self.SORT_BYLASTPLAYED_ASC then
    table.sort(worldList, function(first, second)
      if first.lastPlayed == second.lastPlayed then
        return self:ReturnDefaultSort(first, second, false)
      elseif first.lastPlayed == 0 then
        return false
      elseif second.lastPlayed == 0 then
        return true
      else
        return first.lastPlayed < second.lastPlayed
      end
    end)
  elseif sortType == self.SORT_BYLASTPLAYED_DESC then
    table.sort(worldList, function(first, second)
      if first.lastPlayed == second.lastPlayed then
        return self:ReturnDefaultSort(first, second, true)
      elseif first.lastPlayed == 0 then
        return false
      elseif second.lastPlayed == 0 then
        return true
      else
        return first.lastPlayed > second.lastPlayed
      end
    end)
  elseif sortType == self.SORT_BYPOPULATION_ASC then
    table.sort(worldList, function(first, second)
      if first.population == second.population then
        return self:ReturnDefaultSort(first, second, false)
      end
      return first.population < second.population
    end)
  elseif sortType == self.SORT_BYPOPULATION_DESC then
    table.sort(worldList, function(first, second)
      if first.population == second.population then
        return self:ReturnDefaultSort(first, second, true)
      end
      return first.population > second.population
    end)
  elseif sortType == self.SORT_BYWORLDSET_ASC then
    table.sort(worldList, function(first, second)
      if first.worldSetName == second.worldSetName then
        return self:ReturnDefaultSort(first, second, false)
      end
      return first.worldSetName < second.worldSetName
    end)
  elseif sortType == self.SORT_BYWORLDSET_DESC then
    table.sort(worldList, function(first, second)
      if first.worldSetName == second.worldSetName then
        return self:ReturnDefaultSort(first, second, true)
      end
      return first.worldSetName > second.worldSetName
    end)
  elseif sortType == self.SORT_BYCHARACTER_ASC then
    table.sort(worldList, function(first, second)
      if first.characterName == second.characterName then
        return self:ReturnDefaultSort(first, second, false)
      end
      return first.characterName < second.characterName
    end)
  elseif sortType == self.SORT_BYCHARACTER_DESC then
    table.sort(worldList, function(first, second)
      if first.characterName == second.characterName then
        return self:ReturnDefaultSort(first, second, true)
      end
      return first.characterName > second.characterName
    end)
  elseif sortType == self.SORT_BYWAIT_ASC then
    table.sort(worldList, function(first, second)
      return self:ReturnDefaultSort(first, second, false)
    end)
  elseif sortType == self.SORT_BYWAIT_DESC then
    table.sort(worldList, function(first, second)
      return self:ReturnDefaultSort(first, second, true)
    end)
  elseif sortType == self.SORT_BYFRIENDS_ASC then
    table.sort(worldList, function(first, second)
      if first.numFriends == second.numFriends then
        return self:ReturnDefaultSort(first, second, false)
      end
      return first.numFriends < second.numFriends
    end)
  elseif sortType == self.SORT_BYFRIENDS_DESC then
    table.sort(worldList, function(first, second)
      if first.numFriends == second.numFriends then
        return self:ReturnDefaultSort(first, second, true)
      end
      return first.numFriends > second.numFriends
    end)
  elseif sortType == self.SORT_BYQUEUE_ASC then
    table.sort(worldList, function(first, second)
      if first.worldData.worldMetrics.queueSize == second.worldData.worldMetrics.queueSize then
        return self:ReturnDefaultSort(first, second, false)
      end
      return first.worldData.worldMetrics.queueSize < second.worldData.worldMetrics.queueSize
    end)
  elseif sortType == self.SORT_BYQUEUE_DESC then
    table.sort(worldList, function(first, second)
      if first.worldData.worldMetrics.queueSize == second.worldData.worldMetrics.queueSize then
        return self:ReturnDefaultSort(first, second, true)
      end
      return first.worldData.worldMetrics.queueSize > second.worldData.worldMetrics.queueSize
    end)
  end
end
function WorldListCommon:GetWorldName(worldId, worldList)
  for _, world in ipairs(worldList) do
    if world.worldData.worldId == worldId then
      return world.worldData.name
    end
  end
  return ""
end
function WorldListCommon:ParseDate(inputDate)
  local offset = tonumber(os.date("%z"))
  local direction = offset < 0 and -1 or 1
  offset = math.abs(offset)
  local offsetMinutes = offset % 100
  local offsetSeconds = direction * (math.floor(offset / 100) * timeHelpers.minutesInHour + offsetMinutes) * timeHelpers.secondsInMinute
  local dateStrings = StringSplit(inputDate, "T")
  local dayStrings = StringSplit(dateStrings[1], "-")
  local timeStrings = StringSplit(dateStrings[2], ":")
  local mergeTime = os.time({
    year = dayStrings[1],
    month = dayStrings[2],
    day = dayStrings[3],
    hour = timeStrings[1],
    min = timeStrings[2],
    sec = timeStrings[3]
  })
  return mergeTime + offsetSeconds
end
function WorldListCommon:UpdateWorldAndCharacterData(worldList, characterData, pendingWorldMergeList)
  local sortByLastPlayed = false
  local characterDataTable = {}
  for _, world in ipairs(worldList) do
    local characterName = self.defaultWorldCharName
    world.characterCount = 0
    for j = 1, #characterData do
      local charData = characterData[j]
      if charData.worldId == world.worldData.worldId then
        sortByLastPlayed = true
        world.characterCount = world.characterCount + 1
        if world.lastPlayed == 0 or charData.publishedElapsedSeconds < world.lastPlayed then
          world.lastPlayed = charData.publishedElapsedSeconds
          if world.lastPlayed == 0 then
            world.lastPlayed = 86400
          end
        end
        characterName = charData.name
        table.insert(characterDataTable, charData)
      end
    end
    world.characterName = characterName
    for k = 1, #pendingWorldMergeList do
      if world.worldData.worldId == pendingWorldMergeList[k].sourceWorldId then
        world.mergeDestinationName = self:GetWorldName(pendingWorldMergeList[k].destinationWorldId, worldList)
        world.mergeTime = self:ParseDate(pendingWorldMergeList[k].mergeTime)
      end
    end
  end
  local worldIdToFriends = GameRequestsBus.Broadcast.GetSteamPresenceFriendsWorldInfo()
  local numFriendsPerWorld = {}
  for i = 1, #worldIdToFriends do
    local worldId = worldIdToFriends[i].worldId
    if worldId and worldId ~= "" then
      if not numFriendsPerWorld[worldId] then
        numFriendsPerWorld[worldId] = 0
      end
      numFriendsPerWorld[worldId] = numFriendsPerWorld[worldId] + 1
    end
  end
  for _, world in ipairs(worldList) do
    world.populationCount = world.population
    if world.worldData.worldMetrics.worldPopulationStatus == "high" then
      world.population = self.POPULATION_HIGH
    elseif world.worldData.worldMetrics.worldPopulationStatus == "medium" then
      world.population = self.POPULATION_MED
    else
      world.population = self.POPULATION_LOW
    end
    local numFriendsInWorld = numFriendsPerWorld[world.worldData.worldId]
    world.numFriends = numFriendsInWorld and numFriendsInWorld or 0
  end
  return sortByLastPlayed, characterDataTable
end
function WorldListCommon:WorldVectorToTable(worlds)
  local worldList = {}
  for i = 1, #worlds do
    local newWorld = WorldMetadata()
    newWorld.status = worlds[i].status
    newWorld.publicStatusCode = worlds[i].publicStatusCode
    newWorld.connectionCount = worlds[i].connectionCount
    newWorld.maxConnectionCount = worlds[i].maxConnectionCount
    newWorld.worldId = worlds[i].worldId
    newWorld.worldSet = worlds[i].worldSet
    newWorld.maxAccountCharacters = worlds[i].maxAccountCharacters
    newWorld.name = worlds[i].name
    newWorld.worldMetrics = worlds[i].worldMetrics
    newWorld.version = worlds[i].version
    table.insert(worldList, {
      worldData = newWorld,
      worldSetName = worlds[i].worldSet,
      population = 0,
      characterCount = 0,
      lastPlayed = 0,
      groupLastPlayed = 32000000,
      mergeTime = 0,
      imageId = self:GetWorldSetImageId(worlds[i].worldSet)
    })
  end
  return worldList
end
function WorldListCommon:GetWorldSetImageId(worldSet)
  local imageId = 1
  local isFound = false
  for i = 1, #self.worldSetImageId do
    if self.worldSetImageId[i] == worldSet then
      isFound = true
      imageId = i
      break
    end
  end
  if not isFound then
    table.insert(self.worldSetImageId, worldSet)
    imageId = #self.worldSetImageId
  end
  return imageId
end
function WorldListCommon:UpdateWorldDataWithCMS(worldListData, worldCMSData)
  if 0 < #worldListData and 0 < #worldCMSData.worldDescriptions then
    for _, world in ipairs(worldListData) do
      local logWarning = true
      for j = 1, #worldCMSData.worldDescriptions do
        if world.worldData.worldId == worldCMSData.worldDescriptions[j].worldId then
          world.worldData.name = worldCMSData.worldDescriptions[j].name
          for k = 1, #worldCMSData.setsData do
            if world.worldData.worldSet == worldCMSData.setsData[k].setId then
              if worldCMSData.setsData[k].name and worldCMSData.setsData[k].name ~= "" then
                world.worldSetName = worldCMSData.setsData[k].name
              end
              break
            end
          end
          logWarning = false
          break
        end
      end
      if logWarning then
        Debug.Log("[OnWorldCMSDataSet] No world cms data available for world id:  " .. world.worldData.worldId)
      end
    end
  end
end
function WorldListCommon:ReselectWorldIdInList(serverListEntity, selectedWorldId)
  local childList = UiElementBus.Event.GetChildren(serverListEntity)
  for i = 1, #childList do
    local childEntityId = childList[i]
    if childEntityId:IsValid() then
      local buttonTable = registrar:GetEntityTable(childEntityId)
      if buttonTable and buttonTable.worldInfo then
        local worldId = buttonTable.worldInfo.worldData.worldId
        if worldId == selectedWorldId then
          UiRadioButtonGroupBus.Event.SetState(serverListEntity, childEntityId, true)
          buttonTable:OnSelected()
        else
          UiRadioButtonGroupBus.Event.SetState(serverListEntity, childEntityId, false)
          buttonTable:OnUnselected()
        end
      end
    end
  end
end
return WorldListCommon
