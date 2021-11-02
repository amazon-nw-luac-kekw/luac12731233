local RecipeListRowElement = {
  Properties = {
    Text = {
      default = EntityId()
    }
  },
  recipeId = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(RecipeListRowElement)
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
function RecipeListRowElement:OnInit()
  BaseElement.OnInit(self)
end
function RecipeListRowElement:SetRecipe(recipeId)
  self.recipeId = recipeId
  if self.recipeId then
    local recipeData = RecipeDataManagerBus.Broadcast.GetCraftingRecipeData(self.recipeId)
    local displayName = StaticItemDataManager:GetItemName(recipeData.resultItemId)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Text, displayName, eUiTextSet_SetLocalized)
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.Text, "", eUiTextSet_SetAsIs)
  end
end
function RecipeListRowElement:SetCallback(context, callback)
  self.context = context
  self.callback = callback
end
function RecipeListRowElement:OnFocus()
end
function RecipeListRowElement:OnUnfocus()
end
function RecipeListRowElement:OnPress()
  if self.callback then
    self.callback(self.context, self.recipeId)
  end
end
return RecipeListRowElement
