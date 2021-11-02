local CraftRefiningInfo = {
  Properties = {
    skillText = {
      default = EntityId()
    },
    skillDesc = {
      default = EntityId()
    },
    bonusText = {
      default = EntityId()
    }
  },
  recipeData = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CraftRefiningInfo)
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
function CraftRefiningInfo:OnInit()
end
function CraftRefiningInfo:SetData(data)
  self.recipeData = data
  local reqTradeskill = CraftingRequestBus.Broadcast.GetRecipeTradeskill(data.id)
  local level = CraftingRequestBus.Broadcast.GetRecipeTradeskillLevel(data.id)
  UiTextBus.Event.SetText(self.Properties.skillText, level)
  local keys = vector_basic_string_char_char_traits_char()
  keys:push_back("value")
  local values = vector_basic_string_char_char_traits_char()
  values:push_back("@ui_" .. string.lower(reqTradeskill))
  UiTextBus.Event.SetTextWithFlags(self.Properties.skillDesc, LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacements("@ui_skill_level", keys, values), eUiTextSet_SetLocalized)
  local bonusPct = 0
  UiTextBus.Event.SetText(self.Properties.bonusText, string.format("%0.2f%%", bonusPct))
end
return CraftRefiningInfo
