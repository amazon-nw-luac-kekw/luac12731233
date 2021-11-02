local CraftingTreeView = {
  Properties = {
    ScrollBox = {
      default = EntityId()
    },
    Content = {
      default = EntityId()
    },
    Background = {
      default = EntityId()
    },
    ActiveFiltersIndicator = {
      default = EntityId()
    },
    ActiveFiltersIndicatorText = {
      default = EntityId()
    },
    ProgressSpinner = {
      default = EntityId()
    },
    CraftingRecipePanel = {
      default = EntityId()
    },
    CraftingStatsPanel = {
      default = EntityId()
    }
  },
  SORT_BY_NAME = 0,
  SORT_BY_LEVEL = 1,
  SORT_BY_TIER = 2,
  SORT_BY_GEAR_SCORE = 3,
  SORT_BY_XP = 4,
  FILTER_NAME = 1,
  FILTER_MATERIALS = 2,
  FILTER_SKILL = 3,
  FILTER_STATIONLEVEL = 4,
  FILTER_TIER1 = 5,
  FILTER_TIER2 = 6,
  FILTER_TIER3 = 7,
  FILTER_TIER4 = 8,
  FILTER_TIER5 = 9,
  VISIBILITY_PASS_QUESTS = 1,
  VISIBILITY_PASS_UNLOCKED = 2,
  VISIBILITY_PASS_LOCKED = 3,
  listItemBgIndex = 0,
  sortType = nil,
  listItemHeight = 40
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CraftingTreeView)
local profiler = RequireScript("LyShineUI._Common.Profiler")
local InventoryCache = RequireScript("LyShineUI.Crafting.CraftingInventoryCache")
local CraftingSortInfo = RequireScript("LyShineUI.Crafting.CraftingSortInfo")
local contractsDataHandler = RequireScript("LyShineUI._Common.ContractsDataHandler")
function CraftingTreeView:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  CraftingSortInfo:Initialize()
  self.InventoryCache = InventoryCache
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.InventoryEntityId", function(self, data)
    if data then
      self.InventoryCache:SetInventoryId(data)
      self.InventoryCache:ResetCache(false)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
    self.InventoryCache:SetPlayerId(self.playerEntityId)
  end)
  self:BusConnect(UiDynamicScrollBoxDataBus, self.Properties.ScrollBox)
  self:BusConnect(UiDynamicScrollBoxElementNotificationBus, self.Properties.ScrollBox)
  DynamicBus.InventoryCacheBus.Connect(self.entityId, self)
  self.activeFilters = {
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  }
  self.masterRecipeList = {}
  local recipes = RecipeDataManagerBus.Broadcast.GetRecipes()
  for i = 1, #recipes do
    table.insert(self.masterRecipeList, RecipeDataManagerBus.Broadcast.GetCraftingRecipeData(recipes[i]))
  end
  self.recipes = {}
  self.recipeStructureList = {}
  self.questRootItem = {
    showInTree = true,
    itemData = {
      id = 0,
      text = "@crafting_quest_recipes",
      depth = 0,
      expanded = true,
      hasChildren = {
        true,
        false,
        false
      }
    }
  }
  self.unlockedRootItem = {
    showInTree = true,
    itemData = {
      id = 0,
      text = "@crafting_tree_learned",
      depth = 0,
      expanded = true,
      hasChildren = {
        false,
        true,
        false
      }
    }
  }
  self.lockedRootItem = {
    showInTree = true,
    itemData = {
      id = 0,
      locked = true,
      text = "@crafting_tree_unlearned",
      depth = 0,
      expanded = true,
      hasChildren = {
        false,
        false,
        true
      }
    }
  }
end
function CraftingTreeView:OnShutdown()
  DynamicBus.InventoryCacheBus.Disconnect(self.entityId, self)
end
function CraftingTreeView:QueryInventoryCache(itemId)
  return self.InventoryCache:GetItemCount(itemId)
end
function CraftingTreeView:SetCraftingScreen(craftingScreenTable)
  self.craftingScreen = craftingScreenTable
end
function CraftingTreeView:UpdateFilterIndicator(amount, max)
  local enabled = 0 < amount
  self.ScriptedEntityTweener:Play(self.Properties.ActiveFiltersIndicator, 0.1, {
    opacity = enabled and 1 or 0,
    ease = "QuadOut"
  })
  if enabled then
    UiTextBus.Event.SetText(self.Properties.ActiveFiltersIndicatorText, amount)
  end
end
function CraftingTreeView:BuildStructureList()
  self.recipeStructureList = {}
  local passLists = {
    [self.VISIBILITY_PASS_QUESTS] = {},
    [self.VISIBILITY_PASS_UNLOCKED] = {},
    [self.VISIBILITY_PASS_LOCKED] = {}
  }
  local childIndex = 1
  for station, stateTable in pairs(self.recipes) do
    for visibilityPass = self.VISIBILITY_PASS_QUESTS, self.VISIBILITY_PASS_LOCKED do
      local rootTable
      if visibilityPass == self.VISIBILITY_PASS_QUESTS then
        rootTable = self.questRootItem
      elseif visibilityPass == self.VISIBILITY_PASS_UNLOCKED then
        rootTable = self.unlockedRootItem
      else
        rootTable = self.lockedRootItem
      end
      if rootTable.showInTree then
        rootTable.itemData.id = childIndex
        rootTable.itemData.hasChildren[self.VISIBILITY_PASS_QUESTS] = visibilityPass == self.VISIBILITY_PASS_QUESTS and stateTable.itemData.hasChildren[self.VISIBILITY_PASS_QUESTS]
        rootTable.itemData.hasChildren[self.VISIBILITY_PASS_UNLOCKED] = visibilityPass == self.VISIBILITY_PASS_UNLOCKED and stateTable.itemData.hasChildren[self.VISIBILITY_PASS_UNLOCKED]
        rootTable.itemData.hasChildren[self.VISIBILITY_PASS_LOCKED] = visibilityPass == self.VISIBILITY_PASS_LOCKED and stateTable.itemData.hasChildren[self.VISIBILITY_PASS_LOCKED]
        childIndex = childIndex + 1
        if rootTable.itemData.expanded and rootTable.itemData.hasChildren[visibilityPass] then
          for category, categoryTable in pairs(stateTable.children) do
            if visibilityPass == self.VISIBILITY_PASS_UNLOCKED and categoryTable.itemData.hasChildren[self.VISIBILITY_PASS_UNLOCKED] then
              categoryTable.itemData.id = childIndex
              table.insert(passLists[visibilityPass], categoryTable)
              childIndex = childIndex + 1
            end
            if (categoryTable.itemData.expanded or visibilityPass ~= self.VISIBILITY_PASS_UNLOCKED) and categoryTable.itemData.hasChildren[visibilityPass] then
              for group, groupTable in pairs(categoryTable.children) do
                if visibilityPass == self.VISIBILITY_PASS_UNLOCKED and groupTable.itemData.hasChildren[self.VISIBILITY_PASS_UNLOCKED] then
                  groupTable.itemData.id = childIndex
                  table.insert(passLists[visibilityPass], groupTable)
                  childIndex = childIndex + 1
                end
                if (groupTable.itemData.expanded or visibilityPass ~= self.VISIBILITY_PASS_UNLOCKED) and groupTable.itemData.hasChildren[visibilityPass] then
                  local bgIndex = 0
                  for index, itemTable in ipairs(groupTable.children) do
                    if (visibilityPass == self.VISIBILITY_PASS_QUESTS and itemTable.itemData.recipeData.isTemporary or not (visibilityPass ~= self.VISIBILITY_PASS_UNLOCKED or itemTable.itemData.recipeData.isTemporary) and itemTable.itemData.isRecipeKnown or visibilityPass == self.VISIBILITY_PASS_LOCKED and not itemTable.itemData.recipeData.isTemporary and not itemTable.itemData.isRecipeKnown) and itemTable.itemData.visible then
                      itemTable.itemData.id = childIndex
                      itemTable.itemData.isSelected = self.selectedRecipeId and self.selectedRecipeId == itemTable.itemData.recipeData.id
                      itemTable.itemData.sortMethod = self.sortType
                      itemTable.itemData.locked = visibilityPass == self.VISIBILITY_PASS_LOCKED
                      if visibilityPass ~= self.VISIBILITY_PASS_LOCKED then
                        bgIndex = bgIndex + 1
                        itemTable.itemData.bgIndex = bgIndex
                      end
                      table.insert(passLists[visibilityPass], itemTable)
                      childIndex = childIndex + 1
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  local sortFunction = function(first, second)
    return first.itemData.filterText < second.itemData.filterText
  end
  if self.sortType == self.SORT_BY_LEVEL then
    function sortFunction(first, second)
      return first.itemData.recipeData.recipeLevel < second.itemData.recipeData.recipeLevel
    end
  elseif self.sortType == self.SORT_BY_TIER then
    function sortFunction(first, second)
      return first.itemData.tier < second.itemData.tier
    end
  elseif self.sortType == self.SORT_BY_GEAR_SCORE then
    function sortFunction(first, second)
      if first.itemData.gearScoreOverride > 0 and second.itemData.gearScoreOverride == 0 then
        return first.itemData.gearScoreOverride <= second.itemData.minGearScore
      elseif first.itemData.gearScoreOverride == 0 and second.itemData.gearScoreOverride > 0 then
        return first.itemData.minGearScore < second.itemData.gearScoreOverride
      elseif first.itemData.gearScoreOverride > 0 and second.itemData.gearScoreOverride > 0 then
        return first.itemData.gearScoreOverride < second.itemData.gearScoreOverride
      elseif first.itemData.minGearScore == second.itemData.minGearScore then
        return first.itemData.maxGearScore < second.itemData.maxGearScore
      else
        return first.itemData.minGearScore < second.itemData.minGearScore
      end
    end
  elseif self.sortType == self.SORT_BY_XP then
    function sortFunction(first, second)
      return first.itemData.xp < second.itemData.xp
    end
  end
  table.sort(passLists[self.VISIBILITY_PASS_QUESTS], sortFunction)
  table.sort(passLists[self.VISIBILITY_PASS_LOCKED], sortFunction)
  if self.questRootItem.showInTree then
    table.insert(self.recipeStructureList, self.questRootItem)
    for i = 1, #passLists[self.VISIBILITY_PASS_QUESTS] do
      table.insert(self.recipeStructureList, passLists[self.VISIBILITY_PASS_QUESTS][i])
    end
  end
  if self.unlockedRootItem.showInTree then
    table.insert(self.recipeStructureList, self.unlockedRootItem)
    for i = 1, #passLists[self.VISIBILITY_PASS_UNLOCKED] do
      table.insert(self.recipeStructureList, passLists[self.VISIBILITY_PASS_UNLOCKED][i])
    end
  end
  if self.lockedRootItem.showInTree then
    table.insert(self.recipeStructureList, self.lockedRootItem)
    for i = 1, #passLists[self.VISIBILITY_PASS_LOCKED] do
      passLists[self.VISIBILITY_PASS_LOCKED][i].itemData.bgIndex = i
      table.insert(self.recipeStructureList, passLists[self.VISIBILITY_PASS_LOCKED][i])
    end
  end
end
function CraftingTreeView:UpdateSelection(recipeId)
  self.selectedRecipeId = recipeId
  for i = 1, #self.recipeStructureList do
    if self.recipeStructureList[i].itemData.depth == 3 then
      self.recipeStructureList[i].itemData.isSelected = self.selectedRecipeId and self.selectedRecipeId == self.recipeStructureList[i].itemData.recipeData.id
    end
  end
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.ScrollBox)
end
function CraftingTreeView:SetCurrentStation(currentStationName)
  self.stationType = string.lower(string.sub(currentStationName, 1, string.len(currentStationName) - 1))
  self.stationLevel = string.sub(currentStationName, -1)
  self.isCamp = self.stationType == "camp"
  local outpostId = self.isCamp and "" or LocalPlayerUIRequestsBus.Broadcast.GetStorageKeyForGlobalStorage()
  if string.len(outpostId) == 0 then
    self:SetupStation()
  else
    self.recipeStructureList = {}
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftingRecipePanel, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftingStatsPanel, false)
    UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.ScrollBox)
    self:SetupStation()
    contractsDataHandler:RequestStorageData(outpostId, self, self.SetupStation)
  end
end
function CraftingTreeView:SetupStation()
  InventoryCache:ResetCache(not self.isCamp)
  self.recipes = {}
  local stationName = ""
  local stationNames = {}
  local entryCount = 0
  local emptyIngredients = vector_Crc32()
  for i = 1, #self.masterRecipeList do
    local data = self.masterRecipeList[i]
    if data and data.listedByDefault and data.numStationTypes ~= 0 then
      local stations = RecipeDataManagerBus.Broadcast.GetStationsFromCraftingRecipe(data.id)
      local sortInfo = RecipeDataManagerBus.Broadcast.GetCraftingCategoryData(data.id)
      local craftingCategory = 0 < string.len(sortInfo.craftingCategory) and sortInfo.craftingCategory or "No Category"
      local craftingGroup = 0 < string.len(sortInfo.craftingGroup) and sortInfo.craftingGroup or "No Group"
      for j = 1, #stations do
        stationName = string.sub(stations[j], 1, #stations[j] - 1)
        local stationLevel = string.sub(stations[j], -1)
        if stationName == self.stationType then
          if self.recipes[stationName] == nil then
            self.recipes[stationName] = {
              children = {},
              itemData = {
                id = 0,
                text = stationName,
                depth = 0,
                expanded = true,
                hasChildren = {
                  true,
                  true,
                  true
                }
              }
            }
          end
          local categoryTable
          for _, table in ipairs(self.recipes[stationName].children) do
            if table.category == craftingCategory then
              categoryTable = table
              break
            end
          end
          if categoryTable == nil then
            categoryTable = {
              children = {},
              category = craftingCategory,
              itemData = {
                id = 0,
                text = craftingCategory,
                depth = 1,
                expanded = true,
                hasChildren = {
                  true,
                  true,
                  true
                }
              }
            }
            table.insert(self.recipes[stationName].children, categoryTable)
          end
          local groupTable
          for _, table in ipairs(categoryTable.children) do
            if table.group == craftingGroup then
              groupTable = table
              break
            end
          end
          if groupTable == nil then
            groupTable = {
              children = {},
              group = craftingGroup,
              itemData = {
                id = 0,
                text = craftingGroup,
                depth = 2,
                expanded = true,
                hasChildren = {
                  true,
                  true,
                  true
                }
              }
            }
            table.insert(categoryTable.children, groupTable)
          end
          local recipeCrc = Math.CreateCrc32(data.id)
          local itemTier = 0
          local isProcedural = RecipeDataManagerBus.Broadcast.IsRecipeProcedural(data.id)
          local hasCooldown = CraftingRequestBus.Broadcast.HasCooldown(recipeCrc)
          local displayIngredients = RecipeDataManagerBus.Broadcast.GetRecipeDisplayIngredients(recipeCrc)
          local itemData, displayName, xp, resultItemId
          if isProcedural then
            resultItemId = CraftingRequestBus.Broadcast.GetProceduralCraftingResult(data.id, vector_Crc32())
            itemData = ItemDataManagerBus.Broadcast.GetItemData(resultItemId)
            displayName = data.name
            itemTier = tonumber(string.sub(data.id, -1)) or 1
          else
            resultItemId = Math.CreateCrc32(data.resultItemId)
            itemData = ItemDataManagerBus.Broadcast.GetItemData(resultItemId)
            displayName = itemData.displayName
            itemTier = itemData.tier
          end
          local isMissionItem = InventoryCache:IsMissionItem(resultItemId)
          local gameEventData = GameEventRequestBus.Broadcast.GetGameSystemData(Math.CreateCrc32(data.gameEventId))
          if gameEventData.isValid then
            xp = gameEventData.categoricalProgressionReward * data:GetIngredientCount()
          else
            xp = 0
          end
          local localDisplayIngredients = {}
          if 0 < #displayIngredients then
            for k = 1, #displayIngredients do
              table.insert(localDisplayIngredients, displayIngredients[k])
            end
          end
          local additionalFilterText = LyShineScriptBindRequestBus.Broadcast.LocalizeText(RecipeDataManagerBus.Broadcast.GetAdditionalFilterText(recipeCrc))
          table.insert(groupTable.children, {
            itemData = {
              id = 0,
              filterText = string.lower(LyShineScriptBindRequestBus.Broadcast.LocalizeText(displayName)),
              additionalFilterText = string.lower(additionalFilterText),
              depth = 3,
              expanded = true,
              recipeData = data,
              recipeIdCrc = recipeCrc,
              isProcedural = isProcedural,
              hasCooldown = hasCooldown,
              tier = itemTier,
              stationName = stationName,
              requiredStationLevel = stationLevel,
              hasIngredients = InventoryCache:CheckIngredients(data),
              displayIngredients = localDisplayIngredients,
              visible = true,
              isRecipeKnown = true,
              isSelected = false,
              isMissionItem = isMissionItem,
              minGearScore = itemData.gearScoreRange.minValue,
              maxGearScore = itemData.gearScoreRange.maxValue,
              gearScoreOverride = itemData.gearScoreOverride,
              xp = xp
            }
          })
        end
      end
    end
  end
  for station, stationTable in pairs(self.recipes) do
    for _, categoryTable in ipairs(stationTable.children) do
      table.sort(categoryTable.children, function(a, b)
        local aPriority = CraftingSortInfo.GroupPriorityOrder[a.itemData.text]
        local bPriority = CraftingSortInfo.GroupPriorityOrder[b.itemData.text]
        if aPriority and bPriority then
          return aPriority < bPriority
        else
          return bPriority == nil
        end
      end)
    end
    table.sort(stationTable.children, function(a, b)
      local aPriority = CraftingSortInfo.CategoryPriorityOrder[a.itemData.text]
      local bPriority = CraftingSortInfo.CategoryPriorityOrder[b.itemData.text]
      if aPriority and bPriority then
        return aPriority < bPriority
      else
        return bPriority == nil
      end
    end)
  end
  self:SortItems(self.sortType or self.SORT_BY_LEVEL)
  self:FilterTreeView()
  local selectedItem = false
  for i = 1, #self.recipeStructureList do
    if self.recipeStructureList[i].itemData.recipeData then
      selectedItem = true
      self:RecipeListSelectCallback(self.recipeStructureList[i].itemData.recipeData, self.recipeStructureList[i].itemData.recipeData.id)
      break
    end
  end
  if selectedItem == false then
    UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.ScrollBox)
  end
  UiScrollBoxBus.Event.SetScrollOffsetY(self.Properties.ScrollBox, 0)
end
function CraftingTreeView:FindProceduralRecipe(recipeName, tier)
  local baseRecipeName = string.sub(recipeName, 1, string.len(recipeName) - 1)
  local baseRecipeTier = tonumber(string.sub(recipeName, -1))
  if type(baseRecipeTier) == "number" then
    local newRecipeName = baseRecipeName .. tostring(tier)
    for station, stationTable in pairs(self.recipes) do
      for category, categoryTable in pairs(stationTable.children) do
        for group, groupTable in pairs(categoryTable.children) do
          for item, itemTable in pairs(groupTable.children) do
            if itemTable.itemData.recipeData.id == newRecipeName then
              return itemTable.itemData.recipeData
            end
          end
        end
      end
    end
  end
end
function CraftingTreeView:DebugPrintRecipeList()
  Debug.Log("RecipeList\n")
  for _, stationTable in pairs(self.recipes) do
    Debug.Log("  " .. stationTable.itemData.text)
    for _, categoryTable in ipairs(stationTable.children) do
      Debug.Log("    " .. categoryTable.itemData.text)
      for _, groupTable in ipairs(categoryTable.children) do
        Debug.Log("      " .. groupTable.itemData.text)
        for _, itemTable in ipairs(groupTable.children) do
          Debug.Log("          " .. tostring(itemTable.itemData.filterText))
        end
      end
    end
  end
end
function CraftingTreeView:GetNumElements()
  return self.recipeStructureList and #self.recipeStructureList or 0
end
function CraftingTreeView:OnElementBecomingVisible(rootEntity, index)
  if not self.recipeStructureList then
    return
  end
  local dataTable = self.recipeStructureList[index + 1]
  local entityTable = self.registrar:GetEntityTable(rootEntity)
  entityTable:SetData(dataTable.itemData)
  entityTable:SetCraftingView(self)
  if dataTable.itemData.depth < entityTable.DEPTH_RECIPE then
    entityTable:SetBackgroundEnabled(false)
    entityTable:SetExpandCallback(self.RecipeListExpandCallback, self)
  else
    entityTable:SetBackgroundEnabled(true)
    entityTable:SetRecipeSelectCallback(self.RecipeListSelectCallback, self)
  end
end
function CraftingTreeView:SortByName(first, second)
  return first.itemData.filterText < second.itemData.filterText
end
function CraftingTreeView:SortByTier(first, second)
  return first.itemData.recipeData.itemTier < second.itemData.recipeData.itemTier
end
function CraftingTreeView:SortByLevel(first, second)
  return first.itemData.recipeData.recipeLevel < second.itemData.recipeData.recipeLevel
end
function CraftingTreeView:SortItems(sortType)
  self.sortType = sortType
  local sortFunction = function(first, second)
    return first.itemData.filterText < second.itemData.filterText
  end
  if sortType == self.SORT_BY_LEVEL then
    function sortFunction(first, second)
      return first.itemData.recipeData.recipeLevel < second.itemData.recipeData.recipeLevel
    end
  elseif sortType == self.SORT_BY_TIER then
    function sortFunction(first, second)
      return first.itemData.tier < second.itemData.tier
    end
  elseif sortType == self.SORT_BY_GEAR_SCORE then
    function sortFunction(first, second)
      if first.itemData.gearScoreOverride > 0 and second.itemData.gearScoreOverride == 0 then
        return first.itemData.gearScoreOverride <= second.itemData.minGearScore
      elseif first.itemData.gearScoreOverride == 0 and second.itemData.gearScoreOverride > 0 then
        return first.itemData.minGearScore < second.itemData.gearScoreOverride
      elseif first.itemData.gearScoreOverride > 0 and second.itemData.gearScoreOverride > 0 then
        return first.itemData.gearScoreOverride < second.itemData.gearScoreOverride
      elseif first.itemData.minGearScore == second.itemData.minGearScore then
        return first.itemData.maxGearScore < second.itemData.maxGearScore
      else
        return first.itemData.minGearScore < second.itemData.minGearScore
      end
    end
  elseif self.sortType == self.SORT_BY_XP then
    function sortFunction(first, second)
      return first.itemData.xp < second.itemData.xp
    end
  end
  local childIndex = 0
  for station, stateTable in pairs(self.recipes) do
    for category, categoryTable in pairs(stateTable.children) do
      for group, groupTable in pairs(categoryTable.children) do
        table.sort(groupTable.children, sortFunction)
      end
    end
  end
  self:BuildStructureList()
  UiElementBus.Event.SetIsEnabled(self.Properties.ProgressSpinner, false)
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.ScrollBox)
end
function CraftingTreeView:SetFilter(filterId, active, arg)
  self.activeFilters[filterId] = active
  if filterId == self.FILTER_NAME then
    self.filterText = active and string.lower(arg) or ""
  end
end
function CraftingTreeView:ClearAllFilters()
  for i = self.FILTER_NAME, #self.activeFilters do
    self.activeFilters[i] = false
  end
  self.filterText = ""
  self:FilterTreeView()
end
function CraftingTreeView:IsItemVisible(itemTable)
  local isVisible = true
  isVisible = self.activeFilters[self.FILTER_NAME] and isVisible and (string.match(itemTable.itemData.filterText, self.filterText) or string.match(itemTable.itemData.additionalFilterText, self.filterText))
  if isVisible and self.activeFilters[self.FILTER_MATERIALS] and isVisible then
    isVisible = itemTable.itemData.hasIngredients
  end
  if isVisible and self.activeFilters[self.FILTER_SKILL] then
    local skillLevel = CraftingRequestBus.Broadcast.GetRecipeTradeskillLevel(itemTable.itemData.recipeData.id)
    isVisible = isVisible and skillLevel >= itemTable.itemData.recipeData.recipeLevel
  end
  isVisible = isVisible
  isVisible = isVisible and (self.activeFilters[self.FILTER_TIER1] or self.activeFilters[self.FILTER_TIER2] or self.activeFilters[self.FILTER_TIER3] or self.activeFilters[self.FILTER_TIER4] or self.activeFilters[self.FILTER_TIER5]) and isVisible and (self.activeFilters[self.FILTER_TIER1] and itemTable.itemData.tier == 1 or self.activeFilters[self.FILTER_TIER2] and itemTable.itemData.tier == 2 or self.activeFilters[self.FILTER_TIER3] and itemTable.itemData.tier == 3 or self.activeFilters[self.FILTER_TIER4] and itemTable.itemData.tier == 4 or self.activeFilters[self.FILTER_TIER5] and itemTable.itemData.tier == 5)
  if isVisible and #itemTable.itemData.displayIngredients > 0 then
    for i = 1, #itemTable.itemData.displayIngredients do
      isVisible = isVisible and 0 < InventoryCache:GetItemCount(itemTable.itemData.displayIngredients[i])
    end
  end
  if isVisible and itemTable.itemData.recipeData.requiredAchievement ~= 0 then
    isVisible = AchievementRequestBus.Event.IsAchievementUnlocked(self.playerEntityId, itemTable.itemData.recipeData.requiredAchievement)
  end
  return isVisible
end
function CraftingTreeView:RefreshTreeView()
  InventoryCache:ResetCache(not self.isCamp)
  self:FilterTreeView(true)
end
function CraftingTreeView:FilterTreeView(keepExpanded)
  self.potentialSelectedItemData = nil
  self.needsNewSelection = true
  self.questRootItem.showInTree = false
  self.unlockedRootItem.showInTree = false
  self.lockedRootItem.showInTree = false
  self.questRootItem.itemData.expanded = true
  self.unlockedRootItem.itemData.expanded = true
  self.lockedRootItem.itemData.expanded = true
  for station, stateTable in pairs(self.recipes) do
    local stateHasQuestChildren = false
    local stateHasUnlockedChildren = false
    local stateHasLockedChildren = false
    if not keepExpanded then
      stateTable.itemData.expanded = true
    end
    for category, categoryTable in pairs(stateTable.children) do
      local categoryHasQuestChildren = false
      local categoryHasUnlockedChildren = false
      local categoryHasLockedChildren = false
      if not keepExpanded then
        categoryTable.itemData.expanded = true
      end
      for group, groupTable in pairs(categoryTable.children) do
        local groupHasQuestChildren = false
        local groupHasUnlockedChildren = false
        local groupHasLockedChildren = false
        if not keepExpanded then
          groupTable.itemData.expanded = true
        end
        for index, itemTable in ipairs(groupTable.children) do
          local hasIngredients = InventoryCache:CheckIngredients(itemTable.itemData.recipeData)
          itemTable.itemData.hasIngredients = hasIngredients and itemTable.itemData.requiredStationLevel <= self.stationLevel
          itemTable.itemData.visible = self:IsItemVisible(itemTable)
          itemTable.itemData.isRecipeKnown = CraftingRequestBus.Broadcast.IsRecipeKnown(itemTable.itemData.recipeData.id, true)
          if itemTable.itemData.visible then
            if itemTable.itemData.recipeData.id == self.selectedRecipeId then
              self.needsNewSelection = false
            elseif self.needsNewSelection and not self.potentialSelectedItemData then
              self.potentialSelectedItemData = itemTable.itemData.recipeData
            end
          end
          if itemTable.itemData.recipeData.isTemporary then
            local hasDisplayIngredients = true
            for i = 1, #itemTable.itemData.displayIngredients do
              hasDisplayIngredients = hasDisplayIngredients and InventoryCache:GetItemCount(itemTable.itemData.displayIngredients[i]) > 0
            end
            if hasDisplayIngredients and itemTable.itemData.visible then
              self.questRootItem.showInTree = true
              stateHasQuestChildren = true
              categoryHasQuestChildren = true
              groupHasQuestChildren = true
            end
          elseif itemTable.itemData.visible then
            if itemTable.itemData.isRecipeKnown then
              self.unlockedRootItem.showInTree = true
              stateHasUnlockedChildren = true
              categoryHasUnlockedChildren = true
              groupHasUnlockedChildren = true
            else
              self.lockedRootItem.showInTree = true
              stateHasLockedChildren = true
              categoryHasLockedChildren = true
              groupHasLockedChildren = true
            end
          end
        end
        groupTable.itemData.hasChildren[self.VISIBILITY_PASS_QUESTS] = groupHasQuestChildren
        groupTable.itemData.hasChildren[self.VISIBILITY_PASS_UNLOCKED] = groupHasUnlockedChildren
        groupTable.itemData.hasChildren[self.VISIBILITY_PASS_LOCKED] = groupHasLockedChildren
      end
      categoryTable.itemData.hasChildren[self.VISIBILITY_PASS_QUESTS] = categoryHasQuestChildren
      categoryTable.itemData.hasChildren[self.VISIBILITY_PASS_UNLOCKED] = categoryHasUnlockedChildren
      categoryTable.itemData.hasChildren[self.VISIBILITY_PASS_LOCKED] = categoryHasLockedChildren
    end
    stateTable.itemData.hasChildren[self.VISIBILITY_PASS_QUESTS] = stateHasQuestChildren
    stateTable.itemData.hasChildren[self.VISIBILITY_PASS_UNLOCKED] = stateHasUnlockedChildren
    stateTable.itemData.hasChildren[self.VISIBILITY_PASS_LOCKED] = stateHasLockedChildren
  end
  if self.needsNewSelection and self.potentialSelectedItemData then
    self.selectedRecipeId = self.potentialSelectedItemData.id
    if self.craftingScreen then
      self.craftingScreen:SelectRecipe(self.potentialSelectedItemData)
    end
  end
  self:BuildStructureList()
  local showRecipePanel = self.questRootItem.showInTree or self.unlockedRootItem.showInTree or self.lockedRootItem.showInTree
  UiElementBus.Event.SetIsEnabled(self.Properties.CraftingRecipePanel, showRecipePanel)
  UiElementBus.Event.SetIsEnabled(self.Properties.CraftingStatsPanel, showRecipePanel)
  UiElementBus.Event.SetIsEnabled(self.Properties.ProgressSpinner, false)
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.ScrollBox)
  UiScrollBoxBus.Event.SetScrollOffsetY(self.Properties.ScrollBox, 0)
end
function CraftingTreeView:RecipeListExpandCallback(id)
  self.recipeStructureList[id].itemData.expanded = not self.recipeStructureList[id].itemData.expanded
  self:BuildStructureList()
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.ScrollBox)
end
function CraftingTreeView:RecipeListSelectCallback(recipeData, selectedRecipeId)
  self.selectedRecipeId = selectedRecipeId
  if self.craftingScreen then
    self.craftingScreen:SelectRecipe(recipeData)
  end
  self:BuildStructureList()
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.ScrollBox)
end
function CraftingTreeView:SetLastHoveredItem(entityId)
  self.lastHoveredItem = entityId
end
function CraftingTreeView:GetLastHoveredItem()
  return self.lastHoveredItem
end
return CraftingTreeView
