local CategoryItemSelector = {
  Properties = {
    Quantity = {
      default = EntityId()
    },
    ItemName = {
      default = EntityId()
    },
    FilterCheckbox = {
      default = EntityId()
    },
    Scrollbox = {
      default = EntityId()
    },
    Content = {
      default = EntityId()
    },
    ButtonClose = {
      default = EntityId()
    },
    FrameMultiBg = {
      default = EntityId()
    },
    FrameHeader = {
      default = EntityId()
    },
    ListFrame = {
      default = EntityId()
    },
    Description = {
      default = EntityId()
    }
  },
  callbackFunction = nil,
  callbackTable = nil,
  showCallbackFunction = nil,
  showCallbackTable = nil,
  hideCallbackFunction = nil,
  hideCallbackTable = nil,
  headerAndFrameHeight = 150,
  gridSize = 60,
  gridSpacing = 8,
  selectedItemId = 0,
  showAllItems = false,
  visible = false
}
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CategoryItemSelector)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function CategoryItemSelector:OnInit()
  BaseElement:OnInit(self)
  self.FilterCheckbox:SetText("@crafting_showowned")
  self.FilterCheckbox:SetElementWidth()
  self.FilterCheckbox:SetState(true)
  self.FilterCheckbox:SetCallback(self, self.OnFilterChanged)
  self.sufficientQuantityString = string.format("<font color=\"#%2x%2x%2x\">", self.UIStyle.COLOR_WHITE.r * 255, self.UIStyle.COLOR_WHITE.g * 255, self.UIStyle.COLOR_WHITE.b * 255) .. "%d</font>"
  self.insufficientQuantityString = string.format("<font color=\"#%2x%2x%2x\">", self.UIStyle.COLOR_INSUFFICIENT_QUANTITY.r * 255, self.UIStyle.COLOR_INSUFFICIENT_QUANTITY.g * 255, self.UIStyle.COLOR_INSUFFICIENT_QUANTITY.b * 255) .. "%d</font>"
  UiDynamicLayoutBus.Event.SetNumChildElements(self.Content, 12)
  self.FrameHeader:SetTextAlignment(self.FrameHeader.TEXT_ALIGN_CENTER)
  self.FrameHeader:SetHeaderStyle(self.FrameHeader.HEADER_STYLE_DEFAULT_NO_OUTLINE)
  self.FrameMultiBg:SetFrameStyle(self.FrameMultiBg.FRAME_STYLE_DEFAULT_NO_OUTLINE)
  self.ButtonClose:SetCallback(self.Hide, self)
  self.ListFrame:SetLineVisible(true)
  self.ListFrame:SetFrameTextureVisible(false)
  self.ListFrame:SetLineColor(self.UIStyle.COLOR_TAN)
  UiTextBus.Event.SetColor(self.Properties.Description, self.UIStyle.COLOR_TAN)
end
function CategoryItemSelector:OnFilterChanged(isChecked)
  self.showAllItems = not isChecked
  self:BuildItemList()
end
function CategoryItemSelector:SetPositionY(y)
  local position = UiTransformBus.Event.GetViewportPosition(self.entityId)
  position.y = y
  UiTransformBus.Event.SetViewportPosition(self.entityId, position)
end
function CategoryItemSelector:SetHeader(categoryId, requiredQuantity)
  self.requiredQuantity = requiredQuantity
  self.selectedQuantity = 0
  local categoryData = CraftingCategoryDataManagerBus.Broadcast.GetCategoryDataById(categoryId)
  local title = GetLocalizedReplacementText("@crafting_category_select_title", {
    type = categoryData.displayText
  })
  self.FrameHeader:SetText(title)
end
function CategoryItemSelector:UpdateSelection()
  local formatString = ""
  if self.selectedQuantity >= self.requiredQuantity then
    formatString = self.sufficientQuantityString .. " / %d"
  else
    formatString = self.insufficientQuantityString .. " / %d"
  end
  local quantityString = string.format(formatString, self.selectedQuantity, self.requiredQuantity)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Quantity, quantityString, eUiTextSet_SetLocalized)
  if self.selectedItemId ~= 0 then
    local itemDescriptor = ItemDescriptor()
    itemDescriptor.itemId = self.selectedItemId
    UiTextBus.Event.SetTextWithFlags(self.Properties.ItemName, itemDescriptor:GetDisplayName(), eUiTextSet_SetLocalized)
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.ItemName, "", eUiTextSet_SetLocalized)
  end
end
function CategoryItemSelector:IsVisible()
  return self.visible
end
function CategoryItemSelector:SetDescription(text)
  if text ~= nil then
    UiTextBus.Event.SetTextWithFlags(self.Properties.Description, text, eUiTextSet_SetLocalized)
  else
    UiTextBus.Event.SetText(self.Properties.Description, "")
  end
end
function CategoryItemSelector:Show(recipeId, maximumTier, isPrimaryIngredient, itemList, selectedItemId, selectedList)
  self.visible = true
  self.recipeId = recipeId
  self.maximumTier = maximumTier
  self.isPrimaryIngredient = isPrimaryIngredient
  local isProcedural = RecipeDataManagerBus.Broadcast.IsRecipeProcedural(self.recipeId)
  self.selectedItemId = selectedItemId
  self.selectedList = selectedList
  self.staticItemDataList = {}
  local recipeHasItemOfTier = {
    true,
    true,
    true,
    true,
    true
  }
  if isPrimaryIngredient and isProcedural then
    for i = 1, #recipeHasItemOfTier do
      recipeHasItemOfTier[i] = CraftingRequestBus.Broadcast.GetRecipeHasResultofTier(self.recipeId, i)
    end
  end
  for i = 1, #itemList do
    local staticItemData = StaticItemDataManager:GetItem(itemList[i].itemId)
    local isValidRecipeTier = not isPrimaryIngredient or staticItemData.tier == 0 or recipeHasItemOfTier[staticItemData.tier]
    local isUsed = IsInsideTable(self.selectedList, itemList[i].itemId) and self.selectedItemId ~= itemList[i].itemId and (not isProcedural or not self.isPrimaryIngredient)
    local enabled = (not isProcedural or staticItemData.tier <= self.maximumTier and isValidRecipeTier) and not isUsed
    table.insert(self.staticItemDataList, {
      id = itemList[i].itemId,
      sortKey = staticItemData.key,
      quantity = itemList[i].quantity,
      enabled = enabled,
      isUsed = isUsed
    })
  end
  self:BuildItemList()
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  self.ScriptedEntityTweener:Play(self.entityId, 0.3, {opacity = 0, y = -10}, {
    opacity = 1,
    y = 0,
    ease = "QuadOut"
  })
  if self.showCallbackFunction ~= nil and self.showCallbackTable ~= nil and type(self.showCallbackFunction) == "function" then
    self.showCallbackFunction(self.showCallbackTable, self.selectedItemId)
  end
end
function CategoryItemSelector:BuildItemList()
  resultItemId = CraftingRequestBus.Broadcast.GetRecipeResultId(self.recipeId)
  local itemCount = 0
  for i = 1, #self.staticItemDataList do
    if (self.showAllItems or 0 < self.staticItemDataList[i].quantity) and self.staticItemDataList[i].id ~= resultItemId then
      itemCount = itemCount + 1
    end
  end
  UiDynamicLayoutBus.Event.SetNumChildElements(self.Properties.Content, itemCount)
  UiElementBus.Event.SetIsEnabled(self.Properties.Scrollbox, 0 < itemCount)
  if 0 < itemCount then
    local itemIndex = 1
    for i = 1, #self.staticItemDataList do
      if (self.showAllItems or 0 < self.staticItemDataList[i].quantity) and self.staticItemDataList[i].id ~= resultItemId then
        local child = UiElementBus.Event.GetChild(self.Properties.Content, itemIndex - 1)
        local itemLayout = self.registrar:GetEntityTable(child)
        if itemLayout ~= nil then
          itemLayout:SetModeType(itemLayout.MODE_TYPE_CONTAINER)
          local itemDescriptor = ItemDescriptor()
          itemDescriptor.itemId = self.staticItemDataList[i].id
          itemDescriptor.quantity = self.staticItemDataList[i].quantity
          if self.selectedItemId == itemDescriptor.itemId then
            self.selectedQuantity = self.staticItemDataList[i].quantity
          end
          itemLayout:SetItemByDescriptor(itemDescriptor)
          itemLayout:EnableHighlight(self.staticItemDataList[i].enabled and itemDescriptor.itemId == self.selectedItemId)
          itemLayout:SetDimVisible(not self.staticItemDataList[i].enabled)
          itemLayout:SetTooltipEnabled(true)
          if not self.staticItemDataList[i].enabled then
            itemLayout:SetCallback()
          else
            itemLayout:SetCallback(self, self.HandleSelection)
          end
        end
        itemIndex = itemIndex + 1
      end
    end
  end
  self:UpdateSelection()
end
function CategoryItemSelector:Hide()
  self.visible = false
  self.ScriptedEntityTweener:Play(self.entityId, 0.15, {
    opacity = 0,
    ease = "QuadOut",
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.entityId, false)
    end
  })
  if self.hideCallbackFunction ~= nil and self.hideCallbackTable ~= nil and type(self.hideCallbackFunction) == "function" then
    self.hideCallbackFunction(self.hideCallbackTable, self.selectedItemId)
  end
end
function CategoryItemSelector:SetCallback(callback, callingTable)
  self.callbackFunction = callback
  self.callbackTable = callingTable
end
function CategoryItemSelector:SetShowCallback(callback, callingTable)
  self.showCallbackFunction = callback
  self.showCallbackTable = callingTable
end
function CategoryItemSelector:SetHideCallback(callback, callingTable)
  self.hideCallbackFunction = callback
  self.hideCallbackTable = callingTable
end
function CategoryItemSelector:HandleSelection(itemLayout)
  self.selectedItemId = itemLayout.itemId
  self.selectedQuantity = itemLayout:GetQuantity()
  self:UpdateSelection()
  local childElements = UiElementBus.Event.GetChildren(self.Properties.Content)
  for i = 1, #childElements do
    local childLayout = self.registrar:GetEntityTable(childElements[i])
    childLayout:EnableHighlight(childLayout.itemId == itemLayout.itemId)
  end
  if self.callbackFunction ~= nil and self.callbackTable ~= nil and type(self.callbackFunction) == "function" then
    self.callbackFunction(self.callbackTable, self.selectedItemId)
  end
  itemLayout:OnUnfocus()
  self:Hide()
end
return CategoryItemSelector
