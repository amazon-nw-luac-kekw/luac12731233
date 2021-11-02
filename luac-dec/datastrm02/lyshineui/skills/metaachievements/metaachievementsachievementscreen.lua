local MetaAchievementsAchievementScreen = {
  Properties = {
    CategoryTitle = {
      default = EntityId()
    },
    MetaAchievementsAchievementGrid = {
      default = EntityId()
    },
    MetaAchievementsAchievementItem = {
      default = EntityId()
    },
    NoCompletedAchievementsText = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(MetaAchievementsAchievementScreen)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function MetaAchievementsAchievementScreen:OnInit()
  BaseElement.OnInit(self)
  self.MetaAchievementsAchievementGrid:Initialize(self.MetaAchievementsAchievementItem)
  self.MetaAchievementsAchievementGrid:OnListDataSet(nil)
  UiTextBus.Event.SetTextWithFlags(self.Properties.NoCompletedAchievementsText, "@ui_meta_achievements_no_completed", eUiTextSet_SetLocalized)
end
function MetaAchievementsAchievementScreen:SetScreenVisible(isVisible)
  if isVisible then
    self.ScriptedEntityTweener:PlayFromC(self.entityId, 0.3, {opacity = 0}, tweenerCommon.fadeInQuadOut)
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, isVisible)
end
function MetaAchievementsAchievementScreen:OnUpdateAchievements(categoryTitle, newAchievements)
  UiTextBus.Event.SetTextWithFlags(self.Properties.CategoryTitle, categoryTitle, eUiTextSet_SetLocalized)
  local noAchievements = #newAchievements == 0
  UiElementBus.Event.SetIsEnabled(self.Properties.NoCompletedAchievementsText, noAchievements)
  self.MetaAchievementsAchievementGrid:OnListDataSet(newAchievements)
end
function MetaAchievementsAchievementScreen:TransitionIn()
  self:SetScreenVisible(true)
  self.audioHelper:PlaySound(self.audioHelper.MetaAchievements_List_Category_Select)
end
function MetaAchievementsAchievementScreen:TransitionOut()
  self:SetScreenVisible(false)
end
return MetaAchievementsAchievementScreen
