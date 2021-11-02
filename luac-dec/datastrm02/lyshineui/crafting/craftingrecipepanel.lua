local CraftingRecipePanel = {
  Properties = {
    Header = {
      ItemName = {
        default = EntityId()
      },
      ItemIcon = {
        default = EntityId()
      },
      ItemRarityBg = {
        default = EntityId()
      },
      ItemRarity = {
        default = EntityId()
      },
      ItemTier = {
        default = EntityId()
      },
      Description = {
        default = EntityId()
      },
      RarityEffect3 = {
        default = EntityId()
      },
      RarityEffect4 = {
        default = EntityId()
      },
      HeaderRune2 = {
        default = EntityId()
      },
      HeaderRune3 = {
        default = EntityId()
      }
    },
    IngredientList = {
      default = {
        EntityId()
      }
    },
    PerkIngredient = {
      Panel = {
        default = EntityId(),
        order = 1
      },
      ItemIcon = {
        default = EntityId(),
        order = 2
      },
      ItemIconBg = {
        default = EntityId(),
        order = 3
      },
      TitleText = {
        default = EntityId(),
        order = 4
      },
      Description = {
        default = EntityId(),
        order = 5
      },
      Quantity = {
        default = EntityId(),
        order = 6
      }
    },
    CurrencyIngredient = {
      Panel = {
        default = EntityId(),
        order = 1
      },
      ItemIcon = {
        default = EntityId(),
        order = 2
      },
      TitleText = {
        default = EntityId(),
        order = 3
      },
      Description = {
        default = EntityId(),
        order = 4
      }
    },
    OptionalResources = {
      InputBlocker = {
        default = EntityId()
      },
      AzothSelector = {
        default = EntityId()
      },
      PerkItemSelector = {
        default = EntityId()
      }
    },
    NoPerksText = {
      default = EntityId()
    },
    CategoryItemSelector = {
      default = EntityId()
    },
    RecipeRune1 = {
      default = EntityId()
    },
    RecipeRune2 = {
      default = EntityId()
    },
    RecipeRune3 = {
      default = EntityId()
    },
    CraftingStatsPanel = {
      default = EntityId()
    },
    CraftingScreen = {
      default = EntityId()
    }
  },
  quantityToMake = 1,
  MAXIMUM_CRAFT_JOBS = 10000,
  ICON_AZOTH = "lyshineui/images/crafting/itemIconAzoth.dds",
  ICON_NONE = "lyshineui/images/crafting/itemBgCircleNone.dds",
  ICON_EMPTY = "lyshineui/images/crafting/itemBgCircleEmpty.dds"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CraftingRecipePanel)
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local ItemCommon = RequireScript("LyShineUI._Common.ItemCommon")
function CraftingRecipePanel:OnInit()
  BaseElement.OnInit(self)
  self.MAXIMUM_CRAFT_JOBS = ConfigProviderEventBus.Broadcast.GetInt("javelin.max-crafting-jobs")
  self.availableInventorySpace = 0
  self.OptionalResources.PerkItemSelector:SetCallback(self.SelectPerkItem, self)
  self.OptionalResources.PerkItemSelector:SetCloseCallback(self.HidePerkItemFlyout, self)
  self.OptionalResources.AzothSelector:SetCallback(self.SelectPerkUpgradeLevel, self)
  self.OptionalResources.AzothSelector:SetCloseCallback(self.HideCurrencyFlyout, self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.InventoryEntityId", function(self, data)
    if data then
      self.inventoryId = data
    end
  end)
  self:SetVisualElements()
end
function CraftingRecipePanel:SetVisualElements()
  SetTextStyle(self.Properties.Header.ItemRarity, self.UIStyle.FONT_STYLE_TOOLTIP_RARITY)
  SetTextStyle(self.Properties.Header.ItemTier, self.UIStyle.FONT_STYLE_TOOLTIP_TIER)
  SetTextStyle(self.Properties.Header.Description, self.UIStyle.FONT_STYLE_FLAVOR_TEXT)
  SetTextStyle(self.Properties.NoPerksText, self.UIStyle.FONT_STYLE_CRAFTING_NO_PERKS)
  UiTextBus.Event.SetFontEffect(self.Properties.Header.Description, 0)
  local animDuration = 80
  self.ScriptedEntityTweener:Play(self.Properties.Header.HeaderRune2, animDuration, {rotation = 0}, {timesToPlay = -1, rotation = 359})
  self.ScriptedEntityTweener:Play(self.Properties.Header.HeaderRune3, animDuration, {rotation = 0}, {timesToPlay = -1, rotation = -359})
  self.ScriptedEntityTweener:Play(self.Properties.RecipeRune1, animDuration, {rotation = 0}, {timesToPlay = -1, rotation = 359})
  self.ScriptedEntityTweener:Play(self.Properties.RecipeRune2, animDuration, {rotation = 0}, {timesToPlay = -1, rotation = -359})
  self.ScriptedEntityTweener:Play(self.Properties.RecipeRune3, animDuration, {rotation = 0}, {timesToPlay = -1, rotation = 359})
  self.PerkIngredient.Panel:SetCallback(self.ShowPerkItemFlyout, self)
  self.CurrencyIngredient.Panel:SetCallback(self.ShowCurrencyFlyout, self)
  self.PerkIngredient.Panel:SetTooltip("@crafting_perkselectiondesc")
  self.CurrencyIngredient.Panel:SetTooltip("@crafting_azothbonus_tooltip")
  self.CategoryItemSelector:SetShowCallback(function(self)
    self:SetScrimVisible(true)
  end, self)
  self.CategoryItemSelector:SetHideCallback(function(self)
    self:SetScrimVisible(false)
  end, self)
end
function CraftingRecipePanel:SetInventoryCache(cache)
  self.InventoryCache = cache
  for i = 0, #self.IngredientList do
    self.IngredientList[i]:SetRecipePanel(self)
    self.IngredientList[i]:SetInventoryCache(cache)
  end
end
function CraftingRecipePanel:CloseSelector()
  self.CategoryItemSelector:Hide()
end
function CraftingRecipePanel:OnIngredientChanged(playFlash)
  if not self.updatingExistingRecipe then
    self:UpdateRecipe(self.recipeData, true, playFlash)
  end
end
function CraftingRecipePanel:Refresh()
  if self.recipeData then
    for i = 0, #self.IngredientList do
      local isVisible = i < #self.recipeData.ingredients
      if isVisible then
        self.IngredientList[i]:UpdateQuantity()
      end
    end
    self:UpdateRecipe(self.recipeData, false)
  end
  if self.recipeData ~= nil then
    local newQuantity = self:GetQuantityToMake()
    self.CraftingStatsPanel.QuantityWidget:UpdateQuantities()
    local maxQuantity = self:GetMaxQuantity()
    if newQuantity > maxQuantity then
      newQuantity = maxQuantity
    end
    self.CraftingStatsPanel.QuantityWidget:SetSliderValue(newQuantity)
  end
end
function CraftingRecipePanel:SetHeader()
  self.showNoPerksText = true
  local itemData = ItemDataManagerBus.Broadcast.GetItemData(self.resultItemId)
  local displayName = itemData.displayName
  if self.isProcedural then
    displayName = self.recipeData.name
  end
  if self.quantityPerCraft > 1 then
    displayName = displayName .. " " .. GetLocalizedReplacementText("@ui_quantitywithx", {
      quantity = self.quantityPerCraft
    })
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.Header.ItemName, displayName, eUiTextSet_SetLocalized)
  local displayNameMinHeight = 75
  local getDisplayNameHeight = UiTextBus.Event.GetTextHeight(self.Properties.Header.ItemName)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.Header.ItemName, math.max(getDisplayNameHeight, displayNameMinHeight))
  local description = LyShineScriptBindRequestBus.Broadcast.LocalizeWithDataSheetData(itemData.description)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Header.Description, description, eUiTextSet_SetLocalized)
  local iconPath = "lyShineui/images/icons/items_hires/" .. itemData.icon .. ".dds"
  UiImageBus.Event.SetSpritePathname(self.Properties.Header.ItemIcon, iconPath)
  UiElementBus.Event.SetIsEnabled(self.Properties.Header.RarityEffect3, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.Header.RarityEffect4, false)
  UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.Header.RarityEffect3, 0)
  UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.Header.RarityEffect4, 0)
  UiFlipbookAnimationBus.Event.Stop(self.Properties.Header.RarityEffect3)
  UiFlipbookAnimationBus.Event.Stop(self.Properties.Header.RarityEffect4)
  local itemDescriptor = ItemCommon:GetFullDescriptorFromId(self.resultItemId)
  local fullImagePath = "lyshineui/images/crafting/crafting_itemraritybglarge0.dds"
  if itemDescriptor:UsesRarity() then
    local rarityLevel = itemDescriptor:GetRarityLevel()
    local raritySuffix = tostring(rarityLevel)
    local rarityText = "@RarityLevel" .. raritySuffix .. "_DisplayName"
    local rarityColor = string.format("COLOR_TOOLTIP_RARITY_LEVEL_%s", raritySuffix)
    fullImagePath = "lyshineui/images/crafting/crafting_itemraritybglarge" .. raritySuffix .. ".dds"
    UiTextBus.Event.SetTextWithFlags(self.Properties.Header.ItemRarity, rarityText, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetColor(self.Properties.Header.ItemRarity, self.UIStyle[rarityColor])
    UiTextBus.Event.SetColor(self.Properties.Header.ItemName, self.UIStyle[rarityColor])
    UiElementBus.Event.SetIsEnabled(self.Properties.Header.ItemRarity, true)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.Header.ItemTier, 0)
    if rarityLevel == 3 then
      UiElementBus.Event.SetIsEnabled(self.Properties.Header.RarityEffect3, true)
      UiFlipbookAnimationBus.Event.Start(self.Properties.Header.RarityEffect3)
    elseif rarityLevel == 4 then
      UiElementBus.Event.SetIsEnabled(self.Properties.Header.RarityEffect4, true)
      UiFlipbookAnimationBus.Event.Start(self.Properties.Header.RarityEffect4)
    end
  else
    UiTextBus.Event.SetColor(self.Properties.Header.ItemName, self.UIStyle.COLOR_RARITY_GRAY)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.Header.ItemTier, -20)
    UiElementBus.Event.SetIsEnabled(self.Properties.Header.ItemRarity, false)
  end
  UiImageBus.Event.SetSpritePathname(self.Properties.Header.ItemRarityBg, fullImagePath)
  local itemTier = ItemDataManagerBus.Broadcast.GetTierNumber(itemDescriptor.itemId)
  local itemTierText = "@cr_tier " .. "<img src=\"lyshineui/images/crafting/crafting_tier_" .. itemTier .. "\" scale=\"0.75\" yOffset=\"0\" />"
  UiTextBus.Event.SetTextWithFlags(self.Properties.Header.ItemTier, itemTierText, eUiTextSet_SetLocalized)
  UiElementBus.Event.SetIsEnabled(self.Properties.PerkIngredient.Panel, self.isProcedural and self.canHavePerks)
  if self.isProcedural and self.canHavePerks then
    self.showNoPerksText = false
    local perkCostOffset = self.selectedPerkItem ~= 0 and 1 or 0
    if self.perkUpgradeLevel > self.maximumPerks - perkCostOffset then
      self.perkUpgradeLevel = self.maximumPerks - perkCostOffset
    end
    self.availableSpecialItems = 0
    if self.resultItemId ~= 0 then
      self.OptionalResources.PerkItemSelector:Prepopulate(self.resultItemId, self.selectedPerkItem)
      self.availableSpecialItems = self.OptionalResources.PerkItemSelector:GetAvailableItemCount()
    end
    self:UpdateSpecialIngredient()
  end
  self:UpdateUpgradeCost()
  UiElementBus.Event.SetIsEnabled(self.Properties.NoPerksText, self.showNoPerksText)
end
function CraftingRecipePanel:SetRecipe(recipeData)
  self.selectedPerkItem = 0
  self.availableSpecialItems = 0
  self.selectedPerkItemType = ePerkType_Invalid
  self.perkUpgradeLevel = 0
  self.maximumPerks = 0
  self:UpdateRecipe(recipeData, false)
end
function CraftingRecipePanel:UpdateRecipe(recipeData, keepSelectedIngredients, playFlash)
  local oldIngredients = {}
  if self.recipeData then
    oldIngredients = self.recipeData.ingredients
  end
  self.recipeData = recipeData
  self.recipeIdCrc = Math.CreateCrc32(self.recipeData.id)
  self.isProcedural = RecipeDataManagerBus.Broadcast.IsRecipeProcedural(self.recipeData.id)
  self.hasCooldown = CraftingRequestBus.Broadcast.HasCooldown(self.recipeIdCrc)
  self.perkUpgradeCost = CraftingRequestBus.Broadcast.GetPerkCostForLocalPlayer(self.recipeData.id)
  local reqTradeskill = CraftingRequestBus.Broadcast.GetRecipeTradeskill(self.recipeData.id)
  local activeTradeskill = Math.CreateCrc32(tostring(reqTradeskill))
  local tradeskillLevel = CategoricalProgressionRequestBus.Event.GetRank(self.playerEntityId, activeTradeskill)
  local rankData = CategoricalProgressionRequestBus.Event.GetStaticTradeskillRankData(self.playerEntityId, activeTradeskill, tradeskillLevel)
  local resultItemId = CraftingRequestBus.Broadcast.GetRecipeResultId(self.recipeData.id)
  self.maximumResourceTier = rankData.resourceTierUnlock
  local selectedItems = {}
  table.insert(selectedItems, resultItemId)
  local primaryIngredientId = 0
  self.updatingExistingRecipe = true
  for i = 0, #self.IngredientList do
    local ingredientTable = self.IngredientList[i]
    local isVisible = i < #self.recipeData.ingredients
    ingredientTable:SetEnabled(isVisible)
    if isVisible then
      local isNew = i >= #oldIngredients or i < #oldIngredients and self.recipeData.ingredients[i + 1].ingredientId ~= oldIngredients[i + 1].ingredientId
      local selectedItemId = 0
      local ingredientEntry = self.recipeData.ingredients[i + 1]
      if keepSelectedIngredients and not isNew then
        selectedItemId = ingredientTable:GetSelectedItemId()
        if self.isProcedural then
          if ingredientTable.Properties.IsPrimary then
            primaryIngredientId = selectedItemId
          elseif primaryIngredientId ~= 0 and primaryIngredientId == selectedItemId then
            selectedItemId = 0
          end
        end
      end
      if 0 < self.recipeData.baseTier and ingredientEntry.type == eIngredientType_CategoryOnly and selectedItemId == 0 then
        selectedItemId = self.InventoryCache:FindCategoryIngredientOfTier(ingredientEntry.ingredientId, ingredientEntry.quantity, self.recipeData.baseTier, self.maximumResourceTier, ingredientTable.Properties.IsPrimary, selectedItems)
      end
      ingredientTable:SetIngredientEntry(ingredientEntry)
      if ingredientEntry.type == eIngredientType_CategoryOnly and selectedItemId ~= 0 then
        ingredientTable:ChooseItem(selectedItemId)
        table.insert(selectedItems, selectedItemId)
      end
    end
  end
  self.updatingExistingRecipe = false
  if self.isProcedural then
    local ingredients = self:GetIngredients()
    self.resultItemId = CraftingRequestBus.Broadcast.GetProceduralCraftingResult(self.recipeData.id, ingredients)
  else
    self.resultItemId = Math.CreateCrc32(self.recipeData.resultItemId)
  end
  local itemData = ItemDataManagerBus.Broadcast.GetItemData(self.resultItemId)
  self.resultItemTier = itemData.tier
  self.quantityPerCraft = CraftingRequestBus.Broadcast.GetRecipeOutputQuantity(self.recipeData.id)
  self.availableInventorySpace = ContainerRequestBus.Event.GetSpaceToCraft(self.inventoryId, self.resultItemId)
  self.CraftingStatsPanel.QuantityWidget:UpdateQuantities()
  local craftAll = CraftingRequestBus.Broadcast.IsRecipeCraftAll(self.recipeData.id) or CraftingRequestBus.Broadcast.IsRecipeRefining(self.recipeData.id)
  if not craftAll then
    self.CraftingStatsPanel.QualityBar:SetRecipeData(self.recipeData, self.resultItemId, self.resultItemTier, self:GetIngredients(), playFlash)
  end
  self.canHavePerks = ItemDataManagerBus.Broadcast.CanHavePerks(self.resultItemId)
  self.maximumPerks = self.canHavePerks and LocalPlayerUIRequestsBus.Broadcast.GetMaximumPerksByTierAndGearscore(itemData.tier, self.CraftingStatsPanel.QualityBar:GetMaxGearScoreRoll()) or 0
  local maxPossiblePerks = 0
  for i = 1, 5 do
    local perkBucketType = ItemDataManagerBus.Broadcast.GetPerkBucketType(self.resultItemId, i)
    if perkBucketType ~= ePerkType_Invalid then
      maxPossiblePerks = maxPossiblePerks + 1
    end
  end
  maxPossiblePerks = maxPossiblePerks + itemData:GetPerkCount()
  if maxPossiblePerks < self.maximumPerks then
    self.maximumPerks = maxPossiblePerks
  end
  self:CheckCanCraft()
  self.quantityToMake = 1
  self.CraftingStatsPanel.QuantityWidget:SetRecipeTable(self)
  self.CraftingStatsPanel.QuantityWidget:SetData(recipeData)
  self:SetHeader()
  self:HidePerkItemFlyout()
end
function CraftingRecipePanel:HasEnoughResources()
  local quantityToCheck = self.quantityToMake > 0 and self.quantityToMake or 1
  local hasIngredients = true
  for i = 0, #self.IngredientList do
    hasIngredients = hasIngredients and self.IngredientList[i]:HasEnoughSelectedMaterial(quantityToCheck)
  end
  if self.selectedPerkItem ~= 0 then
    local perkIngredientCount = self.InventoryCache:GetItemCount(self.selectedPerkItem)
    hasIngredients = hasIngredients and quantityToCheck <= perkIngredientCount
  end
  if 0 < self.perkUpgradeLevel then
    local requiredCurrency = self.perkUpgradeLevel * self.perkUpgradeCost * quantityToCheck
    local azothAmount = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.AzothAmount") or 0
    hasIngredients = hasIngredients and requiredCurrency <= azothAmount
  end
  return hasIngredients
end
function CraftingRecipePanel:GetCalculatedInventorySpace()
  return self.availableInventorySpace / self.quantityPerCraft
end
function CraftingRecipePanel:GetMaxQuantity()
  if self.recipeData == nil then
    return 0
  end
  local maxQuantity = -1
  for i = 1, #self.recipeData.ingredients do
    local quantity = math.floor(self.IngredientList[i - 1]:GetSelectedQuantity() / self.recipeData.ingredients[i].quantity)
    if maxQuantity == -1 then
      maxQuantity = quantity
    elseif quantity < maxQuantity then
      maxQuantity = quantity
    end
  end
  if self.selectedPerkItem ~= 0 then
    local perkIngredientCount = self.InventoryCache:GetItemCount(self.selectedPerkItem)
    if maxQuantity > perkIngredientCount then
      maxQuantity = perkIngredientCount
    end
  end
  if 0 < self.perkUpgradeLevel then
    local requiredCurrency = self.perkUpgradeLevel * self.perkUpgradeCost
    local azothAmount = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.AzothAmount") or 0
    local quantity = math.floor(azothAmount / requiredCurrency)
    if maxQuantity > quantity then
      maxQuantity = quantity
    end
  end
  local totalPrice = CraftingRequestBus.Broadcast.GetCraftingFeeOnCurrentTerritory(self.recipeData.id, maxQuantity)
  local totalCurrency = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.Amount")
  if totalPrice > totalCurrency then
    local singlePrice = CraftingRequestBus.Broadcast.GetCraftingFeeOnCurrentTerritory(self.recipeData.id, 1)
    local quantity = math.floor(totalCurrency / singlePrice)
    if maxQuantity > quantity then
      maxQuantity = quantity
    end
  end
  if self.hasCooldown then
    local remainingCooldownCount = CraftingRequestBus.Broadcast.GetRemainingCooldownCount(self.recipeIdCrc)
    maxQuantity = math.min(maxQuantity, remainingCooldownCount)
  end
  if maxQuantity > self.availableInventorySpace then
    maxQuantity = self.availableInventorySpace
  end
  if maxQuantity > self.MAXIMUM_CRAFT_JOBS then
    maxQuantity = self.MAXIMUM_CRAFT_JOBS
  end
  return maxQuantity
end
function CraftingRecipePanel:CheckCanCraft()
  self.canCraft = true
  local hasEnoughResources = self:HasEnoughResources()
  if not hasEnoughResources then
    self.canCraft = false
  end
  local quantityToCheck = self.quantityToMake > 0 and self.quantityToMake or 1
  local isOnCooldown = CraftingRequestBus.Broadcast.IsRecipeOnCooldown(self.recipeData.id, quantityToCheck)
  if isOnCooldown then
    self.canCraft = false
  end
  if self.canCraft and self.availableInventorySpace == 0 then
    self.canCraft = false
  end
  local totalPrice = CraftingRequestBus.Broadcast.GetCraftingFeeOnCurrentTerritory(self.recipeData.id, self.quantityToMake)
  if self.canCraft and totalPrice > self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.Amount") then
    self.canCraft = false
  end
  if self.canCraft then
    local ingredients = self:GetIngredients()
    self.canCraft = CraftingRequestBus.Broadcast.CanCraftRecipe(self.recipeData.id, ingredients)
  end
  self.CraftingStatsPanel:SetCraftingParams(self.recipeData, self.resultItemId, self.resultItemTier, self:GetIngredients(), self.quantityToMake, self.selectedPerkItem, self.maximumPerks, self.perkUpgradeLevel)
  self.CraftingStatsPanel:SetCanCraft(self.canCraft, hasEnoughResources)
end
function CraftingRecipePanel:GetOtherCategoryIngredients(openingIngredientTable)
  local categorySelectedItems = {}
  for i = 1, #self.recipeData.ingredients do
    local ingredientTable = self.IngredientList[i - 1]
    if openingIngredientTable ~= ingredientTable and ingredientTable:IsCategoryIngredient() then
      local itemId = ingredientTable:GetSelectedItemId()
      table.insert(categorySelectedItems, itemId)
    end
  end
  return categorySelectedItems
end
function CraftingRecipePanel:GetPrimaryIngredient()
  local ingredientTable = self.IngredientList[0]
  if ingredientTable:IsCategoryIngredient() then
    return ingredientTable:GetSelectedItemId()
  end
  return 0
end
function CraftingRecipePanel:GetPrimaryIngredientTier()
  local ingredientTable = self.IngredientList[0]
  local itemId = ingredientTable:GetSelectedItemId()
  if itemId ~= 0 then
    local itemData = StaticItemDataManager:GetItem(itemId)
    return itemData.tier
  end
  return self.resultItemTier
end
function CraftingRecipePanel:GetCategoryIngredients()
  local categorySelectedItems = vector_Crc32()
  for i = 1, #self.recipeData.ingredients do
    local ingredientTable = self.IngredientList[i - 1]
    if ingredientTable:IsCategoryIngredient() then
      local itemId = ingredientTable:GetSelectedItemId()
      categorySelectedItems:push_back(itemId)
    end
  end
  return categorySelectedItems
end
function CraftingRecipePanel:GetIngredients()
  local ingredients = vector_Crc32()
  for i = 1, #self.recipeData.ingredients do
    local ingredientTable = self.IngredientList[i - 1]
    local itemId = ingredientTable:GetSelectedItemId()
    ingredients:push_back(itemId)
  end
  return ingredients
end
function CraftingRecipePanel:SetCraftQuantity(quantity)
  self.quantityToMake = math.floor(quantity)
  self.CraftingScreen:SetCraftQuantity(quantity)
  self:CheckCanCraft()
end
function CraftingRecipePanel:GetRecipeData()
  return self.recipeData
end
function CraftingRecipePanel:GetResultItemId()
  return self.resultItemId
end
function CraftingRecipePanel:GetResultItemTier()
  return self.resultItemTier
end
function CraftingRecipePanel:GetPerkItem()
  return self.selectedPerkItem
end
function CraftingRecipePanel:GetPerkUpgradeLevel()
  if self.selectedPerkItemType == ePerkType_Inherent and self.attributeBucketIndex >= 0 and self.perkUpgradeLevel > self.attributeBucketIndex or self.selectedPerkItemType == ePerkType_Gem and 0 <= self.gemBucketIndex and self.perkUpgradeLevel > self.gemBucketIndex or self.selectedPerkItemType == ePerkType_Generated and 0 <= self.firstPerkBucketIndex and self.perkUpgradeLevel > self.firstPerkBucketIndex then
    Debug.Log("[CraftingRecipePanel:GetPerkUpgradeLevel] Upgrade Affected. Add 1.")
    return self.perkUpgradeLevel + 1
  end
  return self.perkUpgradeLevel
end
function CraftingRecipePanel:GetQuantityToMake()
  return self.quantityToMake
end
function CraftingRecipePanel:IsFlyoutOpen()
  return self.flyoutOpen
end
function CraftingRecipePanel:CloseFlyouts()
  if self.flyoutOpen then
    self:SetScrimVisible(false)
    DynamicBus.StationPropertiesBus.Broadcast.SetTransparent(false)
    DynamicBus.StationPropertiesBus.Broadcast.SetBackgroundTransparent(false)
    self.OptionalResources.PerkItemSelector:Hide()
    self.OptionalResources.AzothSelector:Hide()
    self.CategoryItemSelector:Hide()
  end
end
function CraftingRecipePanel:SetScrimVisible(isVisible)
  if isVisible then
    self.flyoutOpen = true
    UiElementBus.Event.SetIsEnabled(self.Properties.OptionalResources.InputBlocker, true)
    self.ScriptedEntityTweener:Play(self.Properties.OptionalResources.InputBlocker, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  else
    self.ScriptedEntityTweener:Play(self.Properties.OptionalResources.InputBlocker, 0.15, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.Properties.OptionalResources.InputBlocker, false)
        self.flyoutOpen = false
      end
    })
  end
end
function CraftingRecipePanel:SelectPerkItem(itemDescriptor)
  self.attributeBucketIndex = -1
  self.gemBucketIndex = -1
  self.firstPerkBucketIndex = -1
  local bucketIndex = 0
  for i = 1, self.maximumPerks do
    local perkBucketType = ItemDataManagerBus.Broadcast.GetPerkBucketType(self.resultItemId, i)
    if perkBucketType ~= ePerkType_Invalid then
      bucketIndex = bucketIndex + 1
    end
    if perkBucketType == ePerkType_Inherent and self.attributeBucketIndex < 0 then
      self.attributeBucketIndex = bucketIndex
    elseif perkBucketType == ePerkType_Gem and self.gemBucketIndex < 0 then
      self.gemBucketIndex = bucketIndex
    elseif perkBucketType == ePerkType_Generated and self.firstPerkBucketIndex < 0 then
      self.firstPerkBucketIndex = bucketIndex
    end
  end
  local newPerkItemId = itemDescriptor.itemId
  if newPerkItemId == 0 then
    self.selectedPerkItemType = ePerkType_Invalid
  elseif CraftingRequestBus.Broadcast.IsSpecialItemAttributePerk(newPerkItemId) then
    if self.selectedPerkItemType == ePerkType_Invalid and self.perkUpgradeLevel >= self.attributeBucketIndex then
      self.perkUpgradeLevel = self.perkUpgradeLevel - 1
    end
    self.selectedPerkItemType = ePerkType_Inherent
  elseif CraftingRequestBus.Broadcast.IsSpecialItemGemSlotPerk(newPerkItemId) then
    if self.selectedPerkItemType == ePerkType_Invalid and self.perkUpgradeLevel >= self.gemBucketIndex then
      self.perkUpgradeLevel = self.perkUpgradeLevel - 1
    end
    self.selectedPerkItemType = ePerkType_Gem
  else
    if self.selectedPerkItemType == ePerkType_Invalid and self.perkUpgradeLevel >= self.firstPerkBucketIndex then
      self.perkUpgradeLevel = self.perkUpgradeLevel - 1
    end
    self.selectedPerkItemType = ePerkType_Generated
  end
  if 0 > self.perkUpgradeLevel then
    self.perkUpgradeLevel = 0
  end
  self.selectedPerkItem = newPerkItemId
  self:UpdateSpecialIngredient()
  self:UpdateUpgradeCost()
  self.CraftingStatsPanel.QuantityWidget:UpdateQuantities()
  self:HidePerkItemFlyout()
end
function CraftingRecipePanel:UpdateSpecialIngredient()
  UiElementBus.Event.SetIsEnabled(self.Properties.PerkIngredient.ItemIcon, self.selectedPerkItem ~= 0)
  if self.selectedPerkItem == 0 then
    UiTextBus.Event.SetTextWithFlags(self.Properties.PerkIngredient.TitleText, "@crafting_specialtitle", eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.PerkIngredient.Description, "@crafting_specialdesc", eUiTextSet_SetLocalized)
    if self.availableSpecialItems == 1 then
      UiTextBus.Event.SetTextWithFlags(self.Properties.PerkIngredient.Quantity, "@crafting_perk_item_available", eUiTextSet_SetLocalized)
    else
      local text = GetLocalizedReplacementText("@crafting_perk_items_available", {
        amount = self.availableSpecialItems
      })
      UiTextBus.Event.SetTextWithFlags(self.Properties.PerkIngredient.Quantity, text, eUiTextSet_SetAsIs)
    end
    UiImageBus.Event.SetSpritePathname(self.Properties.PerkIngredient.ItemIconBg, self.ICON_NONE)
  else
    local staticItemData = StaticItemDataManager:GetItem(self.selectedPerkItem)
    local perkDescriptor = ItemDescriptor()
    perkDescriptor.itemId = self.selectedPerkItem
    UiTextBus.Event.SetTextWithFlags(self.Properties.PerkIngredient.TitleText, "@crafting_specialadded", eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.PerkIngredient.Description, perkDescriptor:GetDisplayName(), eUiTextSet_SetLocalized)
    UiImageBus.Event.SetSpritePathname(self.Properties.PerkIngredient.ItemIcon, "lyShineui/images/icons/items_hires/" .. staticItemData.icon .. ".dds")
    UiTextBus.Event.SetTextWithFlags(self.Properties.PerkIngredient.Quantity, "", eUiTextSet_SetAsIs)
    UiImageBus.Event.SetSpritePathname(self.Properties.PerkIngredient.ItemIconBg, self.ICON_EMPTY)
  end
end
function CraftingRecipePanel:ShowPerkItemFlyout()
  self:SetScrimVisible(true)
  DynamicBus.StationPropertiesBus.Broadcast.SetTransparent(true)
  DynamicBus.StationPropertiesBus.Broadcast.SetBackgroundTransparent(true)
  self.OptionalResources.PerkItemSelector:Show()
end
function CraftingRecipePanel:HidePerkItemFlyout()
  if self.flyoutOpen then
    self:SetScrimVisible(false)
    DynamicBus.StationPropertiesBus.Broadcast.SetTransparent(false)
    DynamicBus.StationPropertiesBus.Broadcast.SetBackgroundTransparent(false)
    self.OptionalResources.PerkItemSelector:Hide()
  end
end
function CraftingRecipePanel:SelectPerkUpgradeLevel(level)
  self.perkUpgradeLevel = level
  self.CraftingStatsPanel.QuantityWidget:UpdateQuantities()
  self:UpdateUpgradeCost()
  self:HideCurrencyFlyout()
end
function CraftingRecipePanel:UpdateUpgradeCost()
  UiElementBus.Event.SetIsEnabled(self.Properties.CurrencyIngredient.Panel, self.isProcedural and self.perkUpgradeCost > 0)
  local isEnabled = self.isProcedural and self.perkUpgradeCost > 0 and 0 < self.maximumPerks
  local tooltipText = isEnabled and "@crafting_azothbonus_tooltip" or "@crafting_azothbonus_tooltip_disabled"
  self.showNoPerksText = not isEnabled and self.showNoPerksText
  self.CurrencyIngredient.Panel:SetEnabled(isEnabled)
  self.CurrencyIngredient.Panel:SetTooltip(tooltipText)
  UiElementBus.Event.SetIsEnabled(self.Properties.CurrencyIngredient.ItemIcon, true)
  UiImageBus.Event.SetSpritePathname(self.Properties.CurrencyIngredient.ItemIcon, self.ICON_AZOTH)
  if 0 < self.perkUpgradeLevel then
    UiTextBus.Event.SetTextWithFlags(self.Properties.CurrencyIngredient.TitleText, "@crafting_azothadded", eUiTextSet_SetLocalized)
    local text = GetLocalizedReplacementText("@ui_quantitywithx", {
      quantity = self.perkUpgradeLevel * self.perkUpgradeCost
    })
    UiTextBus.Event.SetTextWithFlags(self.Properties.CurrencyIngredient.Description, text, eUiTextSet_SetLocalized)
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.CurrencyIngredient.TitleText, "@crafting_perktitle", eUiTextSet_SetLocalized)
    local text = GetLocalizedReplacementText("@ui_quantitywithx", {quantity = 0})
    UiTextBus.Event.SetTextWithFlags(self.Properties.CurrencyIngredient.Description, text, eUiTextSet_SetLocalized)
  end
end
function CraftingRecipePanel:ShowCurrencyFlyout()
  self:SetScrimVisible(true)
  local modifiedMaximum = self.maximumPerks - (self.selectedPerkItemType ~= ePerkType_Invalid and 1 or 0)
  local descriptor = ItemCommon:GetFullDescriptorFromId(self.resultItemId)
  local itemInfo = StaticItemDataManager:GetTooltipDisplayInfo(descriptor, nil)
  modifiedMaximum = modifiedMaximum - #itemInfo.perks
  local azothAmount = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.AzothAmount") or 0
  DynamicBus.StationPropertiesBus.Broadcast.SetTransparent(true)
  DynamicBus.StationPropertiesBus.Broadcast.SetBackgroundTransparent(true)
  self.OptionalResources.AzothSelector:SetupPopup(self.resultItemId, self.perkUpgradeCost, azothAmount, self.perkUpgradeLevel, self.selectedPerkItemType, modifiedMaximum)
  self.OptionalResources.AzothSelector:Show()
end
function CraftingRecipePanel:HideCurrencyFlyout()
  if self.flyoutOpen then
    self:SetScrimVisible(false)
    DynamicBus.StationPropertiesBus.Broadcast.SetTransparent(false)
    DynamicBus.StationPropertiesBus.Broadcast.SetBackgroundTransparent(false)
    self.OptionalResources.AzothSelector:Hide()
  end
end
function CraftingRecipePanel:OnShutdown()
  self.ScriptedEntityTweener:Stop(self.Properties.Header.HeaderRune2)
  self.ScriptedEntityTweener:Stop(self.Properties.Header.HeaderRune3)
  self.ScriptedEntityTweener:Stop(self.Properties.RecipeRune1)
  self.ScriptedEntityTweener:Stop(self.Properties.RecipeRune2)
  self.ScriptedEntityTweener:Stop(self.Properties.RecipeRune3)
  UiFlipbookAnimationBus.Event.Stop(self.Properties.Header.RarityEffect3)
  UiFlipbookAnimationBus.Event.Stop(self.Properties.Header.RarityEffect4)
end
return CraftingRecipePanel
