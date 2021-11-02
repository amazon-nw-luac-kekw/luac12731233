local DyeDiscovery = {
  Properties = {
    RecipeDynamicScrollBox = {
      default = EntityId()
    },
    ResourceDynamicGrid = {
      default = EntityId()
    },
    ResourceItemPrototype = {
      default = EntityId()
    },
    Ingredient1 = {
      default = EntityId()
    },
    Ingredient2 = {
      default = EntityId()
    },
    Ingredient3 = {
      default = EntityId()
    },
    Ingredient4 = {
      default = EntityId()
    },
    ColorPreview = {
      default = EntityId()
    },
    ColorName = {
      default = EntityId()
    },
    QuantitySlider = {
      default = EntityId()
    },
    CraftButton = {
      default = EntityId()
    }
  },
  MAX_INGREDIENT_COUNT = 4,
  recipeEntries = {},
  recipeAchievementList = {}
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(DyeDiscovery)
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
function DyeDiscovery:OnInit()
  BaseScreen.OnInit(self)
  DynamicBus.DyeDiscoveryBus.Connect(self.entityId, self)
  self:BusConnect(UiDynamicScrollBoxDataBus, self.Properties.RecipeDynamicScrollBox)
  self:BusConnect(UiDynamicScrollBoxElementNotificationBus, self.Properties.RecipeDynamicScrollBox)
  self.CraftButton:SetCallback(self.OnCraft, self)
  self.QuantitySlider:HideCrownIcons()
  self:ClearPreview()
  for i = 1, self.MAX_INGREDIENT_COUNT do
    local ingredient = self["Ingredient" .. tostring(i)]
    ingredient:SetCallback(self, self.OnIngredientPress)
    ingredient:SetIsItemDraggable(true)
    ingredient:SetTooltipEnabled(true)
    UiElementBus.Event.SetIsEnabled(ingredient.entityId, false)
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, data)
    self.playerEntityId = data
    if not self.playerEntityId then
      return
    end
    local recipes = RecipeDataManagerBus.Broadcast.GetRecipesByCategory("Dyes")
    for i = 1, #recipes do
      local recipeData = RecipeDataManagerBus.Broadcast.GetCraftingRecipeData(recipes[i])
      local achievementId = recipeData:GetAchievementId()
      local achievementKey = tostring(achievementId)
      self.recipeEntries[achievementKey] = {
        recipeId = recipes[i],
        isUnlocked = AchievementRequestBus.Event.IsAchievementUnlocked(self.playerEntityId, achievementId)
      }
      table.insert(self.recipeAchievementList, achievementKey)
      self:OnAchievementChanged(achievementId, "Dye", self.recipeEntries[achievementKey].isUnlocked, true)
    end
    self:BusConnect(LocalPlayerEventsBus)
    self.ResourceDynamicGrid:Initialize(self.ResourceItemPrototype, nil)
  end)
end
function DyeDiscovery:OnShutdown()
  BaseScreen.OnShutdown(self)
  DynamicBus.DyeDiscoveryBus.Disconnect(self.entityId, self)
end
function DyeDiscovery:RegisterObservers()
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.InventoryEntityId", function(self, data)
    if not data then
      return
    end
    if self.inventoryId then
      self:BusDisconnect(self.inventoryBus)
    end
    self.inventoryId = data
    self.inventoryBus = self:BusConnect(ContainerEventBus, self.inventoryId)
  end)
end
function DyeDiscovery:UnregisterObservers()
  if self.inventoryId then
    self:BusDisconnect(self.inventoryBus)
  end
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.HudComponent.InventoryEntityId")
end
function DyeDiscovery:OnAchievementChanged(achievementId, category, isUnlocked, isInit)
  if category ~= "Dye" then
    return
  end
  if not isInit and LyShineManagerBus.Broadcast.GetCurrentState() ~= 1343302363 then
    Debug.Log("Warning: DyeDiscovery:OnAchievementChanged - received a Dye achievement event while not in DyeDiscovery screen")
  end
  local achievementKey = tostring(achievementId)
  if self.recipeEntries[achievementKey] then
    self.recipeEntries[achievementKey].isUnlocked = isUnlocked
    UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.RecipeDynamicScrollBox)
  else
    Debug.Log("Warning: DyeDiscovery:OnAchievementChanged - found a Dye achievement with no matching recipe")
  end
end
function DyeDiscovery:GetNumElements()
  local count = 0
  for _, recipeEntry in pairs(self.recipeEntries) do
    count = count + (recipeEntry.isUnlocked and 1 or 0)
  end
  return count
end
function DyeDiscovery:OnElementBecomingVisible(rootEntity, index)
  local entry = self.registrar:GetEntityTable(rootEntity)
  for i = 1, #self.recipeAchievementList do
    local recipeEntry = self.recipeEntries[self.recipeAchievementList[i]]
    if recipeEntry.isUnlocked then
      index = index - 1
      if index < 0 then
        entry:SetRecipe(recipeEntry.recipeId)
        entry:SetCallback(self, self.OnRecipePress)
        return
      end
    end
  end
end
function DyeDiscovery:OnEscapeKeyPressed()
  LyShineManagerBus.Broadcast.ExitState(1343302363)
end
function DyeDiscovery:UpdateResourceList()
  if not self.inventoryId then
    return
  end
  local numSlots = ContainerRequestBus.Event.GetNumSlots(self.inventoryId) or 0
  local listData = {}
  for i = 1, numSlots do
    local slotId = i - 1
    local slot = ContainerRequestBus.Event.GetSlotRef(self.inventoryId, slotId)
    if slot and slot:IsValid() and not slot:HasItemClass(eItemClass_LootContainer) and (slot:HasItemClass(eItemClass_UI_Material) or slot:HasItemClass(eItemClass_UI_Consumable)) then
      table.insert(listData, {
        callbackSelf = self,
        callbackFunction = self.OnResourcePress,
        slot = slot
      })
    end
  end
  self.ResourceDynamicGrid:OnListDataSet(listData)
end
function DyeDiscovery:OnSlotUpdate(localSlotId, slot, updateReason)
  self:UpdateResourceList()
  if updateReason == eItemContainerSync_ItemCreated and self.recipeData and slot:GetItemId() == Math.CreateCrc32(self.recipeData.resultItemId) then
    self:UpdateRecipePreview()
    self:UpdateQuantitySlider()
  end
end
function DyeDiscovery:UpdateRecipePreview()
  if not self.recipeData then
    self:ClearPreview()
    return
  end
  local colorIndex = ItemDataManagerBus.Broadcast.GetColorIndex(Math.CreateCrc32(self.recipeData.resultItemId))
  local color = ItemDataManagerBus.Broadcast.GetDyeColor(colorIndex)
  UiImageBus.Event.SetColor(self.Properties.ColorPreview, color)
  local displayName = StaticItemDataManager:GetItemName(self.recipeData.resultItemId)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ColorName, displayName, eUiTextSet_SetLocalized)
end
function DyeDiscovery:UpdateQuantitySlider()
  if not self.recipeData then
    self.QuantitySlider:SetSliderMinValue(1)
    self.QuantitySlider:SetSliderMaxValue(1)
    self.QuantitySlider:SetSliderValue(1)
    self.CraftButton:SetEnabled(true)
    UiTextBus.Event.SetText(self.QuantitySlider.SliderMaxValueText, "?")
    return
  end
  if CraftingRequestBus.Broadcast.CanCraftRecipe(self.recipeData.id) then
    local inventoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
    local maxQuantity = -1
    for i = 1, #self.recipeData.ingredients do
      local quantity = ContainerRequestBus.Event.GetIngredientCount(inventoryId, self.recipeData.ingredients[i], true, true, false)
      maxQuantity = maxQuantity == -1 and quantity or math.min(maxQuantity, quantity)
    end
    maxQuantity = maxQuantity == -1 and 0 or maxQuantity
    local minQuantity = math.min(1, maxQuantity)
    self.QuantitySlider:SetSliderMinValue(minQuantity)
    self.QuantitySlider:SetSliderMaxValue(maxQuantity)
    local value = Math.Clamp(self.QuantitySlider:GetSliderValue(), minQuantity, maxQuantity)
    self.QuantitySlider:SetSliderValue(value)
    local craftingFee = CraftingRequestBus.Broadcast.GetCraftingFeeOnCurrentTerritory(self.recipeData.id, 1)
    self.CraftButton:SetText(GetLocalizedReplacementText("@ui_craft_fee", {fee = craftingFee}))
    self.CraftButton:SetEnabled(0 < maxQuantity)
  else
    self.QuantitySlider:SetSliderMinValue(0)
    self.QuantitySlider:SetSliderMaxValue(0)
    self.QuantitySlider:SetSliderValue(0)
    self.CraftButton:SetEnabled(false)
  end
end
function DyeDiscovery:OnRecipePress(recipeId)
  if not recipeId then
    return
  end
  self.recipeData = RecipeDataManagerBus.Broadcast.GetCraftingRecipeData(recipeId)
  self:UpdateRecipePreview()
  self:ClearIngredients()
  for i = 1, #self.recipeData.ingredients do
    local ingredient = self["Ingredient" .. tostring(i)]
    UiElementBus.Event.SetIsEnabled(ingredient.entityId, true)
    ingredient:SetItemByDescriptor(self.recipeData.ingredients[i])
    ingredient:SetLayout(ingredient.UIStyle.ITEM_LAYOUT_CIRCLE)
    ingredient:SetQuantityEnabled(false)
  end
  self:UpdateQuantitySlider()
end
function DyeDiscovery:OnIngredientPress(ingredient)
  UiElementBus.Event.SetIsEnabled(ingredient.entityId, false)
  self:ClearPreview()
end
function DyeDiscovery:OnResourcePress(resource)
  for i = 1, self.MAX_INGREDIENT_COUNT do
    local ingredient = self["Ingredient" .. tostring(i)]
    if not UiElementBus.Event.IsEnabled(ingredient.entityId) then
      UiElementBus.Event.SetIsEnabled(ingredient.entityId, true)
      ingredient:SetItemByDescriptor(resource.mItemData_itemDescriptor)
      ingredient:SetLayout(ingredient.UIStyle.ITEM_LAYOUT_CIRCLE)
      ingredient:SetQuantityEnabled(false)
      self:ClearPreview()
      break
    end
  end
end
function DyeDiscovery:ClearIngredients()
  for i = 1, self.MAX_INGREDIENT_COUNT do
    local ingredient = self["Ingredient" .. tostring(i)]
    UiElementBus.Event.SetIsEnabled(ingredient.entityId, false)
  end
end
function DyeDiscovery:ClearPreview()
  self.recipeData = nil
  self:UpdateQuantitySlider()
  UiImageBus.Event.SetColor(self.Properties.ColorPreview, ColorRgba(0, 0, 0, 0))
  UiTextBus.Event.SetTextWithFlags(self.Properties.ColorName, "?", eUiTextSet_SetAsIs)
end
function DyeDiscovery:OnCraft()
  if not self.recipeData then
    local ingredientNames = vector_basic_string_char_char_traits_char()
    for i = 1, self.MAX_INGREDIENT_COUNT do
      local ingredient = self["Ingredient" .. tostring(i)]
      if UiElementBus.Event.IsEnabled(ingredient.entityId) then
        ingredientNames:push_back(ingredient.itemName)
      end
    end
    local recipes = RecipeDataManagerBus.Broadcast.GetRecipesByIngredients(ingredientNames, "Dyes")
    if 0 < #recipes then
      if 1 < #recipes then
        Debug.Log("Warning: DyeDiscovery:OnCraft - more than one matching recipe found")
      end
      self.recipeData = RecipeDataManagerBus.Broadcast.GetCraftingRecipeData(recipes[1])
      if CraftingRequestBus.Broadcast.CanCraftRecipe(self.recipeData.id) then
        CraftingRequestBus.Broadcast.CraftRecipe(self.recipeData.id, 1, 0, 0, {})
        self.CraftButton:SetEnabled(false)
      end
    else
      UiImageBus.Event.SetColor(self.Properties.ColorPreview, ColorRgba(0, 0, 0, 0))
      UiTextBus.Event.SetTextWithFlags(self.Properties.ColorName, "@dye_crafting_invalid", eUiTextSet_SetLocalized)
      self.CraftButton:SetEnabled(true)
    end
  elseif CraftingRequestBus.Broadcast.CanCraftRecipe(self.recipeData.id) then
    local quantityToCraft = self.QuantitySlider:GetSliderValue()
    CraftingRequestBus.Broadcast.CraftRecipe(self.recipeData.id, quantityToCraft, 0, 0, {})
    self.CraftButton:SetEnabled(false)
  end
end
function DyeDiscovery:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  self:RegisterObservers()
  self:UpdateResourceList()
end
function DyeDiscovery:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  self:UnregisterObservers()
  self:ClearPreview()
  self:ClearIngredients()
end
return DyeDiscovery
