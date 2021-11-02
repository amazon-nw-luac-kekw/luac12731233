local CraftingInventoryCache = {
  itemCache = {},
  categoryCache = {},
  missionItemCache = {},
  itemDescriptor = ItemDescriptor(),
  paperDollSlots = {
    ePaperDollSlotTypes_QuickSlot1,
    ePaperDollSlotTypes_QuickSlot2,
    ePaperDollSlotTypes_QuickSlot3,
    ePaperDollSlotTypes_QuickSlot4
  }
}
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
function CraftingInventoryCache:SetInventoryId(inventoryId)
  self.inventoryId = inventoryId
end
function CraftingInventoryCache:SetPlayerId(playerId)
  self.playerEntityId = playerId
  dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.ItemsToProcure")
  dataLayer:RegisterAndExecuteObserver(self, "Hud.LocalPlayer.ItemsToProcure.RefCount", function(self, dataNode)
    self.missionItemCache = {}
    local isItemToProcure = false
    local childNames = dataNode:GetChildrenNames()
    for i = 1, #childNames do
      local childName = childNames[i]
      local childNode = dataNode[childName]
      local instanceIdCount = childNode:GetData()
      isItemToProcure = type(instanceIdCount) == "number" and 0 < instanceIdCount or false
      if isItemToProcure then
        local objectiveIdNode = dataLayer:GetDataNode("Hud.LocalPlayer.ItemsToProcure.ObjectiveIds." .. childName)
        if objectiveIdNode then
          local objectiveTaskIds = objectiveIdNode:GetChildren()
          for i = 1, #objectiveTaskIds do
            local objectiveInstanceId = objectiveTaskIds[i]:GetData()
            if objectiveInstanceId then
              table.insert(self.missionItemCache, Math.CreateCrc32(childName))
              break
            end
          end
        end
      end
    end
  end)
end
function CraftingInventoryCache:IsInCategoryTable(category, itemId)
  for _, itemTable in ipairs(self.categoryCache[category].items) do
    if itemTable.itemId == itemId then
      return true
    end
  end
  return false
end
function CraftingInventoryCache:IsMissionItem(itemId)
  return IsInsideTable(self.missionItemCache, itemId)
end
function CraftingInventoryCache:CacheItem(itemId, checkGlobalStorage)
  if not self.itemCache[itemId] then
    self.itemCache[itemId] = 0
    self.itemDescriptor.itemId = itemId
    self.itemCache[itemId] = ContainerRequestBus.Event.GetItemCount(self.inventoryId, self.itemDescriptor, false, true, checkGlobalStorage)
  end
  local categories = ItemDataManagerBus.Broadcast.GetIngredientCategories(itemId)
  for i = 1, #categories do
    local category = categories[i]
    if not self:IsInCategoryTable(categories[i], itemId) then
      local staticItemData = StaticItemDataManager:GetItem(itemId)
      local tier = 0 < staticItemData.tier and staticItemData.tier or 1
      table.insert(self.categoryCache[category].items, {itemId = itemId, tier = tier})
    end
  end
end
function CraftingInventoryCache:ResetCache(checkGlobalStorage)
  self.itemCache = {}
  self.categoryCache = {}
  if not self.inventoryId then
    return
  end
  local knownCategories = RecipeDataManagerBus.Broadcast.GetIngredientCategoryIds()
  for i = 1, #knownCategories do
    local category = knownCategories[i]
    if not self.categoryCache[category] then
      self.categoryCache[category] = {
        items = {}
      }
      local itemIdList = RecipeDataManagerBus.Broadcast.GetIngredientCategoryItemIds(category)
      for i = 1, #itemIdList do
        local staticItemData = StaticItemDataManager:GetItem(itemIdList[i])
        local tier = staticItemData.tier > 0 and staticItemData.tier or 1
        table.insert(self.categoryCache[category].items, {
          itemId = itemIdList[i],
          tier = tier
        })
      end
    end
  end
  local numSlots = ContainerRequestBus.Event.GetNumSlots(self.inventoryId) or 0
  for slotId = 0, numSlots do
    local slot = ContainerRequestBus.Event.GetSlotRef(self.inventoryId, slotId)
    if slot and slot:IsValid() then
      self:CacheItem(slot:GetItemId(), checkGlobalStorage)
    end
  end
  for _, slotName in ipairs(self.paperDollSlots) do
    local slot = PaperdollRequestBus.Event.GetSlot(self.inventoryId, slotName)
    if slot and slot:IsValid() then
      self:CacheItem(slot:GetItemId(), checkGlobalStorage)
    end
  end
  local outpostId = checkGlobalStorage and LocalPlayerUIRequestsBus.Broadcast.GetStorageKeyForGlobalStorage() or ""
  if 0 < string.len(outpostId) then
    local itemSlots = GlobalStorageRequestBus.Event.GetStorageContents(self.playerEntityId, outpostId)
    for i = 1, #itemSlots do
      local slot = itemSlots[i]
      if slot and slot:IsValid() then
        self:CacheItem(slot:GetItemId(), true)
      end
    end
  end
  for _, itemTable in pairs(self.categoryCache) do
    table.sort(itemTable.items, function(a, b)
      return a.tier < b.tier
    end)
  end
end
function CraftingInventoryCache:DebugPrintCache()
  Debug.Log("[CraftingInventoryCache:DebugPrintCache]")
  Debug.Log("Items")
  for itemId, quantity in pairs(self.itemCache) do
    local staticItemData = StaticItemDataManager:GetItem(itemId)
    Debug.Log(tostring(quantity) .. " " .. tostring(staticItemData.displayName) .. " (" .. tostring(itemId) .. ")")
  end
  Debug.Log("Categories")
  for categoryId, categoryTable in pairs(self.categoryCache) do
    local categoryData = CraftingCategoryDataManagerBus.Broadcast.GetCategoryDataById(categoryId)
    local categoryInfo = tostring(categoryData.displayText) .. " (" .. tostring(categoryId) .. ") ["
    for _, itemData in ipairs(categoryTable.items) do
      local staticItemData = StaticItemDataManager:GetItem(itemData.itemId)
      categoryInfo = categoryInfo .. tostring(staticItemData.displayName) .. ", "
    end
    Debug.Log(categoryInfo .. "]")
  end
end
function CraftingInventoryCache:FindCategoryIngredientOfTier(category, targetQuantity, targetTier, maxTier, isPrimary, alreadySelectedList)
  if self.categoryCache[category] then
    for _, itemTable in ipairs(self.categoryCache[category].items) do
      if (not isPrimary and targetTier <= itemTable.tier and maxTier >= itemTable.tier or isPrimary and itemTable.tier == targetTier) and not IsInsideTable(alreadySelectedList, itemTable.itemId) and self.itemCache[itemTable.itemId] and targetQuantity <= self.itemCache[itemTable.itemId] then
        return itemTable.itemId
      end
    end
    for _, itemTable in ipairs(self.categoryCache[category].items) do
      if (not isPrimary and targetTier <= itemTable.tier and maxTier >= itemTable.tier or isPrimary and itemTable.tier == targetTier) and not IsInsideTable(alreadySelectedList, itemTable.itemId) and self.itemCache[itemTable.itemId] and self.itemCache[itemTable.itemId] > 0 then
        return itemTable.itemId
      end
    end
    for tier = targetTier, 1, -1 do
      for _, itemTable in ipairs(self.categoryCache[category].items) do
        if (not isPrimary and maxTier >= itemTable.tier or isPrimary and itemTable.tier == targetTier) and not IsInsideTable(alreadySelectedList, itemTable.itemId) then
          return itemTable.itemId
        end
      end
    end
    for tier = targetTier, maxTier do
      for _, itemTable in ipairs(self.categoryCache[category].items) do
        if (not isPrimary and maxTier >= itemTable.tier or isPrimary and itemTable.tier == targetTier) and not IsInsideTable(alreadySelectedList, itemTable.itemId) then
          return itemTable.itemId
        end
      end
    end
  end
  return 0
end
function CraftingInventoryCache:GetItemCount(itemId)
  if self.itemCache[itemId] then
    return self.itemCache[itemId]
  end
  return 0
end
function CraftingInventoryCache:CheckIngredient(itemId, quantity, usedIngredients)
  if self.itemCache[itemId] then
    local oldIngredientCount = usedIngredients[itemId] and usedIngredients[itemId] or 0
    local totalIngredients = quantity + oldIngredientCount
    if totalIngredients <= self.itemCache[itemId] then
      return self.itemCache[itemId]
    end
  end
  return 0
end
function CraftingInventoryCache:CheckIngredients(recipeData)
  local usedIngredientQuantities = {}
  local usedIngredientIds = {}
  local isProcedural = RecipeDataManagerBus.Broadcast.IsRecipeProcedural(recipeData.id)
  for i = 1, #recipeData.ingredients do
    local ingredient = recipeData.ingredients[i]
    if ingredient.type == eIngredientType_Item then
      local quantity = self:CheckIngredient(ingredient.ingredientId, ingredient.quantity, usedIngredientQuantities)
      if quantity == 0 then
        return false
      elseif not usedIngredientQuantities[ingredient.ingredientId] then
        usedIngredientQuantities[ingredient.ingredientId] = 0
      end
      usedIngredientQuantities[ingredient.ingredientId] = usedIngredientQuantities[ingredient.ingredientId] + ingredient.quantity
    elseif ingredient.type == eIngredientType_CategoryOnly then
      if self.categoryCache[ingredient.ingredientId] then
        local hasEnoughIngredient = false
        local selectedItemId = 0
        local isPrimary = isProcedural and i == 1
        for _, itemTable in ipairs(self.categoryCache[ingredient.ingredientId].items) do
          if isPrimary and itemTable.tier == recipeData.baseTier or not isPrimary and not IsInsideTable(usedIngredientIds, itemTable.itemId) then
            local quantity = self:CheckIngredient(itemTable.itemId, ingredient.quantity, usedIngredientQuantities)
            if 0 < quantity then
              selectedItemId = itemTable.itemId
              table.insert(usedIngredientIds, selectedItemId)
              hasEnoughIngredient = true
              break
            end
          end
        end
        if not hasEnoughIngredient then
          return false
        elseif not usedIngredientQuantities[selectedItemId] then
          usedIngredientQuantities[selectedItemId] = 0
        end
        usedIngredientQuantities[selectedItemId] = usedIngredientQuantities[selectedItemId] + ingredient.quantity
      else
        return false
      end
    elseif ingredient.type == eIngredientType_Currency then
      local quantity = CategoricalProgressionRequestBus.Event.GetProgression(self.playerEntityId, ingredient.ingredientId)
      local required = ingredient.quantity
      if quantity < required then
        return false
      end
    end
  end
  return true
end
function CraftingInventoryCache:GetCategoryList(categoryId)
  local itemList = {}
  if self.categoryCache[categoryId] then
    for _, itemTable in ipairs(self.categoryCache[categoryId].items) do
      table.insert(itemList, {
        itemId = itemTable.itemId,
        quantity = self:GetItemCount(itemTable.itemId)
      })
    end
  end
  return itemList
end
return CraftingInventoryCache
