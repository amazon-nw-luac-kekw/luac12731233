local IngredientRowV4 = {
  Properties = {
    ItemLayout = {
      default = EntityId()
    },
    CategoryIcon = {
      default = EntityId()
    },
    Quantity = {
      default = EntityId()
    },
    IngredientName = {
      default = EntityId()
    },
    TypeName = {
      default = EntityId()
    },
    IngredientSelectorBg = {
      default = EntityId()
    },
    ItemFocus = {
      default = EntityId()
    },
    Tooltip = {
      default = EntityId()
    },
    IsPrimary = {default = false}
  },
  required = 0,
  quantity = 0,
  displayName = ""
}
local ItemCommon = RequireScript("LyShineUI._Common.ItemCommon")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(IngredientRowV4)
function IngredientRowV4:OnInit()
  BaseElement.OnInit(self)
  self.sufficientQuantityString = string.format("<font color=\"#%2x%2x%2x\">", self.UIStyle.COLOR_WHITE.r * 255, self.UIStyle.COLOR_WHITE.g * 255, self.UIStyle.COLOR_WHITE.b * 255) .. "%d</font>"
  self.insufficientQuantityString = string.format("<font color=\"#%2x%2x%2x\">", self.UIStyle.COLOR_INSUFFICIENT_QUANTITY.r * 255, self.UIStyle.COLOR_INSUFFICIENT_QUANTITY.g * 255, self.UIStyle.COLOR_INSUFFICIENT_QUANTITY.b * 255) .. "%d</font>"
  UiTextBus.Event.SetColor(self.IngredientName, self.UIStyle.COLOR_GRAY_60)
  self.ItemLayout:SetModeType(self.ItemLayout.MODE_TYPE_CRAFTING)
  self.ItemLayout:SetQuantityEnabled(false)
  self.ItemLayout:SetTooltipEnabled(true)
  self.ItemLayout:SetIsHandlingEvents(true)
  self.materials = {}
  self.currencyIcons = {}
  self.currencyIcons[2817455512] = "lyshineui/images/icons/items_hires/repairpartst1.dds"
  self.currencyIcons[928006727] = "lyshineui/images/icons/misc/icon_azothCurrency.dds"
  self.itemDescriptor = ItemDescriptor()
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
  end)
end
function IngredientRowV4:SetRecipePanel(recipePanel)
  self.RecipePanel = recipePanel
end
function IngredientRowV4:SetInventoryCache(cache)
  self.InventoryCache = cache
end
function IngredientRowV4:OpenItemSelector()
  local position = UiTransformBus.Event.GetViewportPosition(self.entityId)
  local itemList = self.InventoryCache:GetCategoryList(self.entry.ingredientId)
  local primaryTooltipText = "@cr_tooltip_primary"
  self.RecipePanel.CategoryItemSelector:SetCallback(self.ChooseItem, self)
  self.RecipePanel.CategoryItemSelector:SetHeader(self.entry.ingredientId, self.entry.quantity)
  self.RecipePanel.CategoryItemSelector:SetDescription(self.Properties.IsPrimary and primaryTooltipText or self.secondaryTooltipText)
  local otherCategoryItems = self.RecipePanel:GetOtherCategoryIngredients(self)
  self.RecipePanel.CategoryItemSelector:Show(self.RecipePanel.recipeData.id, self.RecipePanel.maximumResourceTier, self.Properties.IsPrimary, itemList, self.itemDescriptor.itemId, otherCategoryItems)
end
function IngredientRowV4:ChooseItem(itemId)
  local ingredientChanged = self.itemDescriptor.itemId ~= itemId
  self.itemDescriptor.itemId = itemId
  self:UpdateQuantity()
  if ingredientChanged then
    self.RecipePanel:OnIngredientChanged(true)
  end
  self:SetDescription()
end
function IngredientRowV4:UpdateQuantity()
  local inventoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
  self.quantity = 0
  if self.itemDescriptor and self.itemDescriptor:IsValid() then
    self.quantity = self.InventoryCache:GetItemCount(self.itemDescriptor.itemId)
  elseif self.isCategory then
    local itemList = self.InventoryCache:GetCategoryList(self.entry.ingredientId)
    for _, itemTable in pairs(itemList) do
      if itemTable.quantity > self.quantity then
        self.quantity = itemTable.quantity
      end
    end
  elseif self.isCurrency then
    self.quantity = CategoricalProgressionRequestBus.Event.GetProgression(self.playerEntityId, self.entry.ingredientId)
  end
  if self.itemDescriptorValid or self.isCurrency then
    SetTextStyle(self.Properties.Quantity, self.UIStyle.FONT_STYLE_CRAFTING_INGREDIENT_AMOUNT)
    local formatString = ""
    if self.quantity >= self.required then
      formatString = self.sufficientQuantityString .. " / %d"
    else
      formatString = self.insufficientQuantityString .. " / %d"
    end
    local quantityString = string.format(formatString, self.quantity, self.required)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Quantity, quantityString, eUiTextSet_SetLocalized)
    local quantityWidth = UiTextBus.Event.GetTextWidth(self.Properties.Quantity)
    local maxIngredientNameWidth = 218
    local padding = 7
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.IngredientName, maxIngredientNameWidth - quantityWidth - padding)
  end
end
function IngredientRowV4:HasEnoughSelectedMaterial(multiplier)
  if not self.enabled then
    return true
  end
  local quantityToMake = multiplier and multiplier or 1
  local quantity = 0
  if self.itemDescriptor:IsValid() then
    quantity = self.InventoryCache:GetItemCount(self.itemDescriptor.itemId)
    return quantity >= self.required * quantityToMake
  elseif self.isCurrency then
    quantity = CategoricalProgressionRequestBus.Event.GetProgression(self.playerEntityId, self.entry.ingredientId)
    return quantity >= self.required * quantityToMake
  end
  return false
end
function IngredientRowV4:SetDescription()
  if self.isCategory or self.itemDescriptor and self.itemDescriptor:IsValid() then
    self.required = self.entry.quantity
    if self.isCategory then
      local categoryData = CraftingCategoryDataManagerBus.Broadcast.GetCategoryDataById(self.entry.ingredientId)
      local typeText = categoryData.displayText
      if self.Properties.IsPrimary then
        typeText = typeText .. " @crafting_primary_ingredient"
        local primaryTooltipText = "@cr_tooltip_primary"
        self.Tooltip:SetSimpleTooltip(primaryTooltipText)
      else
        self.isCraftAll = CraftingRequestBus.Broadcast.IsRecipeCraftAll(self.RecipePanel.recipeData.id) or CraftingRequestBus.Broadcast.IsRecipeRefining(self.RecipePanel.recipeData.id)
        self.secondaryTooltipText = self.isCraftAll and "@cr_tooltip_secondary_non_gear" or "@cr_tooltip_secondary_gear"
        self.Tooltip:SetSimpleTooltip(self.secondaryTooltipText)
      end
      UiTextBus.Event.SetTextWithFlags(self.Properties.TypeName, typeText, eUiTextSet_SetLocalized)
    end
    if self.itemDescriptor:IsValid() then
      self.itemDescriptorValid = true
      self.displayName = self.itemDescriptor:GetDisplayName()
      UiTextBus.Event.SetTextWithFlags(self.Properties.IngredientName, self.displayName, eUiTextSet_SetLocalized)
      self.ItemLayout:SetItemByDescriptor(self.itemDescriptor)
      UiElementBus.Event.SetIsEnabled(self.Properties.ItemLayout, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.CategoryIcon, false)
    else
      self.itemDescriptorValid = false
      UiTextBus.Event.SetTextWithFlags(self.Properties.IngredientName, "", eUiTextSet_SetLocalized)
      UiImageBus.Event.SetSpritePathname(self.Properties.CategoryIcon, "lyshineui/images/crafting/itemBgCircleNone.dds")
      SetTextStyle(self.Properties.Quantity, self.UIStyle.FONT_STYLE_BODY_NEW_WHITE)
      UiTextBus.Event.SetTextWithFlags(self.Properties.Quantity, "@crafting_select_resources", eUiTextSet_SetLocalized)
      UiElementBus.Event.SetIsEnabled(self.Properties.ItemLayout, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.CategoryIcon, true)
    end
    self:UpdateQuantity()
    self.notEnoughIngredients = self.quantity < self.required
    if self.notEnoughIngredients then
      UiTextBus.Event.SetColor(self.Properties.IngredientName, self.UIStyle.COLOR_INSUFFICIENT_QUANTITY)
    else
      UiTextBus.Event.SetColor(self.Properties.IngredientName, self.UIStyle.COLOR_GRAY_70)
    end
  elseif self.isCurrency then
    self.required = self.entry.quantity
    local progressionData = CategoricalProgressionRequestBus.Event.GetCategoricalProgressionData(self.playerEntityId, self.entry.ingredientId)
    if self.currencyIcons[self.entry.ingredientId] then
      UiImageBus.Event.SetSpritePathname(self.Properties.CategoryIcon, self.currencyIcons[self.entry.ingredientId])
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.IngredientName, progressionData.displayName, eUiTextSet_SetLocalized)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemLayout, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.CategoryIcon, true)
    self:UpdateQuantity()
    self.notEnoughIngredients = self.quantity < self.required
    if self.notEnoughIngredients then
      UiTextBus.Event.SetColor(self.Properties.IngredientName, self.UIStyle.COLOR_INSUFFICIENT_QUANTITY)
    else
      UiTextBus.Event.SetColor(self.Properties.IngredientName, self.UIStyle.COLOR_GRAY_70)
    end
  else
    self.required = 0
  end
end
function IngredientRowV4:SetEnabled(enable)
  self.enabled = enable
  UiElementBus.Event.SetIsEnabled(self.entityId, enable)
end
function IngredientRowV4:SetIngredientEntry(entry)
  self.entry = entry
  self.isCategory = self.entry.type == eIngredientType_CategoryAny or self.entry.type == eIngredientType_CategoryOnly
  self.isCurrency = self.entry.type == eIngredientType_Currency
  self.quantity = 0
  UiElementBus.Event.SetIsEnabled(self.Properties.TypeName, self.isCategory)
  if self.isCategory then
    UiTransformBus.Event.SetLocalPositionY(self.Properties.Quantity, 0)
    self.ItemLayout:SetCallback(self, self.OnPress)
  else
    UiTransformBus.Event.SetLocalPositionY(self.Properties.Quantity, -10)
    self.ItemLayout:SetCallback()
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.IngredientSelectorBg, self.isCategory)
  self.itemDescriptor = self.entry:CreateItemDescriptor()
  if self.itemDescriptor:IsValid() then
    self.itemDescriptor = ItemCommon:GetFullDescriptorFromId(self.itemDescriptor.itemId)
  else
    self.ItemLayout:ClearItemData()
  end
  self:SetDescription()
end
function IngredientRowV4:OnFocus()
  if not self.isCategory then
    return
  end
  self.Tooltip:OnTooltipSetterHoverStart()
  if self.timeline == nil then
    self.timeline = self.ScriptedEntityTweener:TimelineCreate()
    self.timeline:Add(self.Properties.ItemFocus, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.45})
    self.timeline:Add(self.Properties.ItemFocus, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
    self.timeline:Add(self.Properties.ItemFocus, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 1,
      onComplete = function()
        self.timeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.ItemFocus, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ItemFocus, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 1,
    delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
    onComplete = function()
      self.timeline:Play()
    end
  })
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Material_Hover)
end
function IngredientRowV4:OnUnfocus()
  self.ScriptedEntityTweener:Play(self.Properties.ItemFocus, 0.3, {opacity = 0, ease = "QuadOut"})
  self.Tooltip:OnTooltipSetterHoverEnd()
end
function IngredientRowV4:OnPress()
  if not self.isCategory then
    return
  end
  self:OpenItemSelector()
  self.Tooltip:OnTooltipSetterHoverEnd()
  self.audioHelper:PlaySound(self.audioHelper.Play_UI_Crafting_Item_Select)
end
function IngredientRowV4:IsCategoryIngredient()
  return self.isCategory
end
function IngredientRowV4:GetSelectedQuantity()
  return self.quantity
end
function IngredientRowV4:GetSelectedItemDescriptor()
  return self.itemDescriptor
end
function IngredientRowV4:GetSelectedItemId()
  return self.itemDescriptor.itemId
end
function IngredientRowV4:OnShutdown()
  if self.timeline then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
    self.timeline = nil
  end
end
return IngredientRowV4
