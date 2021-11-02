local TradeSkills_Crafting = {
  Properties = {
    DetailPanel = {
      default = EntityId()
    },
    BackButton = {
      default = EntityId()
    },
    RecipeUnlockListScrollbox = {
      default = EntityId()
    }
  },
  currentLevel = 0,
  listItemHeight = 57
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TradeSkills_Crafting)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function TradeSkills_Crafting:OnInit()
  BaseElement.OnInit(self)
  self.BackButton:SetText("@ui_back")
  self.BackButton:SetButtonSingleIconPath("lyshineui/images/icons/misc/icon_back.dds")
  self.BackButton:SetButtonSingleIconSize(16)
  self.BackButton:PositionButtonSingleIconToText()
  self.BackButton:SetCallback(self.BackClick, self)
  self:BusConnect(UiDynamicScrollBoxDataBus, self.Properties.RecipeUnlockListScrollbox)
  self:BusConnect(UiDynamicScrollBoxElementNotificationBus, self.Properties.RecipeUnlockListScrollbox)
end
function TradeSkills_Crafting:GetNumElements()
  return #self.skillsData
end
function TradeSkills_Crafting:OnElementBecomingVisible(rootEntity, index)
  if not self.skillsData then
    return
  end
  local dataTable = self.skillsData[index + 1]
  local entityTable = self.registrar:GetEntityTable(rootEntity)
  local delay = not self.scrollboxChanged and index * 0.03
  entityTable:SetRecipe(dataTable, delay)
end
function TradeSkills_Crafting:SetScrollboxChanged()
  self.scrollboxChanged = true
end
function TradeSkills_Crafting:SetVisible(visible, skillData)
  self.scrollboxChanged = not visible
  UiScrollBoxBus.Event.SetScrollOffset(self.Properties.RecipeUnlockListScrollbox, Vector2(0, 0))
  if self.screenVisibleCallback and self.screenVisibleCallbackTable then
    self.screenVisibleCallback(self.screenVisibleCallbackTable, self, visible)
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, visible)
  if not visible then
    return
  end
  local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  local maxRank = CategoricalProgressionRequestBus.Event.GetMaxRank(playerEntityId, skillData.tableId)
  local rankToUse = maxRank < skillData.currentLevel and maxRank or skillData.currentLevel
  local staticRankData = CategoricalProgressionRequestBus.Event.GetStaticTradeskillRankData(playerEntityId, skillData.tableId, rankToUse)
  local currentProgress = CategoricalProgressionRequestBus.Event.GetProgression(playerEntityId, skillData.tableId)
  local requiredProgress = CategoricalProgressionRequestBus.Event.GetMaxPointsForRank(playerEntityId, skillData.tableId, skillData.currentLevel)
  self.currentLevel = skillData.currentLevel
  self.DetailPanel:OnSetDetailPanel({
    currentLevel = skillData.currentLevel,
    progressPercent = skillData.progressPercent,
    currentXp = currentProgress,
    nextLevelXp = requiredProgress,
    maxRank = maxRank
  }, skillData.locName, skillData.icon)
  local gearScoreBonuses = {}
  for i = 1, 5 do
    table.insert(gearScoreBonuses, staticRankData:GearScoreBonusByTier(i))
  end
  self.DetailPanel:SetGearScoreBonuses(skillData.descText, gearScoreBonuses)
  self.DetailPanel:SetRequirements(skillData.requireText, skillData.requireSubText, skillData.requireIcon, skillData.requireSubText2, skillData.requireIcon2, true)
  self.skillsData = {}
  local recipes = RecipeDataManagerBus.Broadcast.GetCraftingRecipesForTradeskill(skillData.name)
  for i = 1, #recipes do
    local recipeData = RecipeDataManagerBus.Broadcast.GetCraftingRecipeData(recipes[i])
    if recipeData.knownByDefault and recipeData.listedByDefault then
      local requiredLevel = math.max(0, CraftingRequestBus.Broadcast.GetTradeskillLevelRequiredForRecipeLevel(recipeData.tradeskill, recipeData.recipeLevel))
      table.insert(self.skillsData, {
        recipeData = recipeData,
        requiredLevel = requiredLevel,
        unlocked = currentProgress >= requiredLevel
      })
    end
  end
  table.sort(self.skillsData, function(a, b)
    if a.requiredLevel == b.requiredLevel then
      return a.recipeData.id < b.recipeData.id
    else
      return a.requiredLevel < b.requiredLevel
    end
  end)
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.RecipeUnlockListScrollbox)
  self.ScriptedEntityTweener:PlayFromC(self.entityId, 0.3, {opacity = 0}, tweenerCommon.fadeInQuadOut)
end
function TradeSkills_Crafting:SetBackClick(clickTable, clickFunc)
  self.clickTable = clickTable
  self.clickFunc = clickFunc
end
function TradeSkills_Crafting:BackClick()
  self.clickFunc(self.clickTable)
end
function TradeSkills_Crafting:SetScreenVisibleCallback(callbackFn, callbackTable)
  self.screenVisibleCallback = callbackFn
  self.screenVisibleCallbackTable = callbackTable
end
return TradeSkills_Crafting
