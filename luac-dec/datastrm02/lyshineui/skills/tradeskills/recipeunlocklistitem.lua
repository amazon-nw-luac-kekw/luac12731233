local RecipeUnlockListItem = {
  Properties = {
    ItemLayout = {
      default = EntityId()
    },
    ItemName = {
      default = EntityId()
    },
    SkillText = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    }
  },
  tradeskillIconPrefix = "lyshineui/images/icons/tradeskills/large/"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(RecipeUnlockListItem)
function RecipeUnlockListItem:OnInit()
  BaseElement.OnInit(self)
  self.ItemLayout:SetModeType(self.ItemLayout.MODE_TYPE_EQUIPPED)
end
function RecipeUnlockListItem:SetRecipe(recipeUnlockData, delay)
  if delay then
    self.ScriptedEntityTweener:Play(self.entityId, 0.1, {opacity = 0}, {
      opacity = 1,
      ease = "QuadOut",
      delay = delay
    })
  else
    self.ScriptedEntityTweener:Set(self.entityId, {opacity = 1})
  end
  local isProcedural = RecipeDataManagerBus.Broadcast.IsRecipeProcedural(recipeUnlockData.recipeData.id)
  local resultItemId
  local skillLevel = tostring(recipeUnlockData.requiredLevel)
  if isProcedural then
    local ingredients = vector_Crc32()
    resultItemId = CraftingRequestBus.Broadcast.GetProceduralCraftingResult(recipeUnlockData.recipeData.id, vector_Crc32())
    skillLevel = skillLevel .. "+"
  else
    resultItemId = Math.CreateCrc32(recipeUnlockData.recipeData.resultItemId)
  end
  local itemDescriptor = ItemDescriptor()
  itemDescriptor.itemId = resultItemId
  self.ItemLayout:SetItemByDescriptor(itemDescriptor)
  self.ItemLayout:SetTooltipEnabled(true)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ItemName, itemDescriptor:GetDisplayName(), eUiTextSet_SetLocalized)
  UiTextBus.Event.SetColor(self.Properties.ItemName, recipeUnlockData.unlocked and self.UIStyle.COLOR_WHITE or self.UIStyle.COLOR_GRAY_50)
  UiImageBus.Event.SetSpritePathname(self.Properties.Icon, self.tradeskillIconPrefix .. recipeUnlockData.recipeData.tradeskill .. ".dds")
  local skillText = GetLocalizedReplacementText("@tradeskill_required_level", {skillLevel = skillLevel})
  UiTextBus.Event.SetTextWithFlags(self.Properties.SkillText, skillText, eUiTextSet_SetLocalized)
  local color = recipeUnlockData.unlocked and self.UIStyle.COLOR_WHITE or self.UIStyle.COLOR_GRAY_50
  UiTextBus.Event.SetColor(self.Properties.SkillText, color)
  UiImageBus.Event.SetColor(self.Properties.Icon, color)
end
return RecipeUnlockListItem
