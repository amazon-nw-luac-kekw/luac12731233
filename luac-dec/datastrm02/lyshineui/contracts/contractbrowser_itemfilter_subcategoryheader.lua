local ContractBrowser_ItemFilter_SubCategoryHeader = {
  Properties = {
    Label = {
      default = EntityId(),
      order = 1
    },
    LabelTextContainer = {
      default = EntityId(),
      order = 1
    },
    LabelDivider = {
      default = EntityId(),
      order = 1
    },
    DescText = {
      default = EntityId(),
      order = 1
    },
    DescTextContainer = {
      default = EntityId(),
      order = 1
    },
    Image = {
      default = EntityId(),
      order = 2
    },
    ImageBg = {
      default = EntityId(),
      order = 2
    },
    ButtonContainer = {
      default = EntityId(),
      order = 3
    },
    Button1 = {
      default = EntityId(),
      order = 4
    },
    Button2 = {
      default = EntityId(),
      order = 4
    },
    RecipeContainer = {
      default = EntityId(),
      order = 5
    },
    RecipeLabel = {
      default = EntityId(),
      order = 5
    },
    RecipeDivider = {
      default = EntityId(),
      order = 5
    },
    RecipeButtonHolder = {
      default = EntityId(),
      order = 5
    },
    DisabledRecipeButtonHolder = {
      default = EntityId(),
      order = 5
    }
  },
  totalHeight = 150,
  maxRecipeIngredients = 7,
  itemIconPath = "LyShineUI\\Images\\Icons\\Items_HiRes\\%s.dds",
  itemSmallIconPath = "LyShineUI\\Images\\Icons\\Items\\%s\\%s.dds",
  recipeButtonSlice = "LyShineUI\\Contracts\\ContractBrowser_ItemFilter_SubCategoryButton",
  IconPathRoot = "lyShineui/images/"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ContractBrowser_ItemFilter_SubCategoryHeader)
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(ContractBrowser_ItemFilter_SubCategoryHeader)
function ContractBrowser_ItemFilter_SubCategoryHeader:OnInit()
  BaseElement.OnInit(self)
  self.currencyIcons = {}
  self.currencyIcons[2817455512] = self.IconPathRoot .. "icons/items_hires/repairpartst1.dds"
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
  end)
  self:BusConnect(UiSpawnerNotificationBus, self.DisabledRecipeButtonHolder)
  for i = 1, self.maxRecipeIngredients do
    self:SpawnSlice(self.DisabledRecipeButtonHolder, self.recipeButtonSlice, nil, nil)
  end
  local recipeContainerSpacing = UiLayoutColumnBus.Event.GetSpacing(self.RecipeContainer)
  local recipeLabelTargetHeight = UiLayoutCellBus.Event.GetTargetHeight(self.RecipeLabel)
  local recipeDividerTargetHeight = UiLayoutCellBus.Event.GetTargetHeight(self.RecipeDivider)
  self.recipeHeaderHeight = recipeContainerSpacing + recipeLabelTargetHeight + recipeDividerTargetHeight
  self.Button1:SetButtonStyle(self.Button1.BUTTON_STYLE_CTA)
  self.Button2:SetButtonStyle(self.Button2.BUTTON_STYLE_CTA)
end
function ContractBrowser_ItemFilter_SubCategoryHeader:OnShutdown()
end
function ContractBrowser_ItemFilter_SubCategoryHeader:SetVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.entityId, isVisible)
  UiLayoutCellBus.Event.SetTargetHeight(self.entityId, isVisible and self.totalHeight or 0)
end
function ContractBrowser_ItemFilter_SubCategoryHeader:SetHeaderData(imagePath, imageHeight, label, button1Data, button2Data, recipeData, isDeepestLevel, description, outposts, itemId)
  if isDeepestLevel then
    UiTextBus.Event.SetHorizontalTextAlignment(self.Properties.Label, self.UIStyle.TEXT_HALIGN_CENTER)
    UiTextBus.Event.SetFontSize(self.Properties.Label, 26)
    UiElementBus.Event.SetIsEnabled(self.Properties.LabelDivider, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.DescTextContainer, true)
  else
    UiTextBus.Event.SetHorizontalTextAlignment(self.Properties.Label, self.UIStyle.TEXT_HALIGN_LEFT)
    UiTextBus.Event.SetFontSize(self.Properties.Label, 28)
    UiElementBus.Event.SetIsEnabled(self.Properties.LabelDivider, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.DescTextContainer, false)
  end
  local isImageDefined = imagePath and imagePath ~= ""
  local imageHeight = isImageDefined and imageHeight or 0
  local buttonHeight = (button1Data or button2Data) and 190 or 0
  local descHeight = 0
  UiLayoutCellBus.Event.SetTargetHeight(self.Properties.ImageBg, imageHeight)
  UiElementBus.Event.SetIsEnabled(self.Properties.ImageBg, isImageDefined)
  if isImageDefined then
    UiImageBus.Event.SetSpritePathname(self.Properties.Image, imagePath)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.LabelTextContainer, label ~= nil)
  local labelTextHeight = 72
  if label then
    UiTextBus.Event.SetTextWithFlags(self.Properties.Label, label, eUiTextSet_SetLocalized)
    labelTextHeight = UiTextBus.Event.GetTextHeight(self.Properties.Label) + 41
  end
  local labelHeight = label and labelTextHeight or 0
  UiLayoutCellBus.Event.SetTargetHeight(self.Properties.LabelTextContainer, labelHeight)
  if description then
    UiTextBus.Event.SetTextWithFlags(self.Properties.DescText, LyShineScriptBindRequestBus.Broadcast.LocalizeWithDataSheetData(description), eUiTextSet_SetLocalized)
    descHeight = UiTextBus.Event.GetTextHeight(self.Properties.DescText)
  end
  UiLayoutCellBus.Event.SetTargetHeight(self.Properties.DescTextContainer, descHeight)
  UiLayoutCellBus.Event.SetTargetHeight(self.Properties.ButtonContainer, buttonHeight)
  UiElementBus.Event.SetIsEnabled(self.Properties.Button1, button1Data ~= nil)
  if button1Data then
    self.Button1:SetText(button1Data.text)
    self.Button1:SetCallback(button1Data.callbackFn, button1Data.callbackSelf)
    self.Button1:SetEnabled(button1Data.hasItem)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.Button2, button2Data ~= nil)
  if button2Data then
    self.Button2:SetText(button2Data.text)
    self.Button2:SetCallback(button2Data.callbackFn, button2Data.callbackSelf)
    local shouldBeEnabled, disableReason = button2Data:ShouldBeEnabled()
    self.Button2:SetEnabled(shouldBeEnabled)
    local tooltip
    if not shouldBeEnabled then
      tooltip = disableReason
    end
    self.Button2:SetTooltip(tooltip)
  end
  self.itemId = itemId
  local recipeHeight = 0
  if recipeData then
    local recipe = RecipeDataManagerBus.Broadcast.GetCraftingRecipeDataByResult(recipeData.resultItemId)
    if recipe and 0 < #recipe.ingredients then
      self:SetNumRecipeButtons(#recipe.ingredients)
      local childElements = UiElementBus.Event.GetChildren(self.RecipeButtonHolder)
      local firstButtonHeight = UiTransform2dBus.Event.GetLocalHeight(childElements[1])
      for i = 1, #recipe.ingredients do
        if i <= #childElements then
          local ingredient = recipe.ingredients[i]
          local recipeButtonTable = self.registrar:GetEntityTable(childElements[i])
          local ingredientImagePath
          local itemName = ""
          local itemId = 0
          local itemType = "Resource"
          local enabled = false
          if ingredient.type == eIngredientType_CategoryAny or ingredient.type == eIngredientType_CategoryOnly then
            local categoryData = CraftingCategoryDataManagerBus.Broadcast.GetCategoryDataById(ingredient.ingredientId)
            itemName = categoryData.displayText
            ingredientImagePath = self.IconPathRoot .. categoryData.imagePath .. ".dds"
          elseif ingredient.type == eIngredientType_Currency then
            if self.currencyIcons[ingredient.ingredientId] then
              ingredientImagePath = self.currencyIcons[ingredient.ingredientId]
            else
              ingredientImagePath = self.IconPathRoot .. "crafting/itemBgCircleNone.dds"
            end
            local progressionData = CategoricalProgressionRequestBus.Event.GetCategoricalProgressionData(self.playerEntityId, ingredient.ingredientId)
            itemName = progressionData.displayName
          else
            local staticItem = StaticItemDataManager:GetItem(ingredient.ingredientId)
            itemId = staticItem.key
            itemType = staticItem.itemType
            itemName = ItemDataManagerBus.Broadcast.GetDisplayName(Math.CreateCrc32(itemId))
            ingredientImagePath = string.format(self.itemSmallIconPath, itemType, staticItem.iconPath)
            enabled = true
          end
          local buttonData = {
            text = itemName,
            imagePath = ingredientImagePath,
            imageWidth = 92,
            numOrdersData = {itemId = itemId},
            filterId = ingredient.ingredientId,
            callbackFn = recipeData.cb,
            callbackSelf = recipeData.cbTable,
            selectedOutposts = outposts,
            buttonHeight = 62,
            displayImage = true,
            itemType = itemType,
            hideItemBg = false,
            enabled = enabled
          }
          recipeButtonTable:SetSubcategoryDisplay(buttonData)
          recipeButtonTable:SetVisible(true)
        end
      end
      local buttonHolderHeight = firstButtonHeight * #recipe.ingredients
      recipeHeight = self.recipeHeaderHeight + buttonHolderHeight
    end
  end
  UiLayoutCellBus.Event.SetTargetHeight(self.Properties.RecipeContainer, recipeHeight)
  UiElementBus.Event.SetIsEnabled(self.Properties.RecipeContainer, 0 < recipeHeight)
  self.totalHeight = imageHeight + labelHeight + descHeight + buttonHeight + recipeHeight
  UiLayoutCellBus.Event.SetTargetHeight(self.entityId, self.totalHeight)
  return self.totalHeight
end
function ContractBrowser_ItemFilter_SubCategoryHeader:OnHeaderHoverStart()
  if self.itemId then
    local itemDescriptor = ItemDescriptor()
    itemDescriptor.itemId = self.itemId
    local tdi = StaticItemDataManager:GetTooltipDisplayInfo(itemDescriptor, nil)
    DynamicBus.TooltipsRequestBus.Broadcast.ShowTooltip(tdi, self)
    self.audioHelper:PlaySound(self.audioHelper.Crafting_Material_Hover)
  end
end
function ContractBrowser_ItemFilter_SubCategoryHeader:OnHeaderHoverEnd()
  DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
end
function ContractBrowser_ItemFilter_SubCategoryHeader:SetNumRecipeButtons(numButtons)
  local currentButtons = UiElementBus.Event.GetNumChildElements(self.RecipeButtonHolder)
  if numButtons > currentButtons then
    local numButtonsToAdd = numButtons - currentButtons
    for i = 1, numButtonsToAdd do
      local button = UiElementBus.Event.GetChild(self.DisabledRecipeButtonHolder, 0)
      UiElementBus.Event.Reparent(button, self.RecipeButtonHolder, EntityId())
    end
  end
  if numButtons < currentButtons then
    local numButtonsToRemove = currentButtons - numButtons
    for i = 1, numButtonsToRemove do
      local button = UiElementBus.Event.GetChild(self.RecipeButtonHolder, 0)
      UiElementBus.Event.Reparent(button, self.DisabledRecipeButtonHolder, EntityId())
    end
  end
end
return ContractBrowser_ItemFilter_SubCategoryHeader
