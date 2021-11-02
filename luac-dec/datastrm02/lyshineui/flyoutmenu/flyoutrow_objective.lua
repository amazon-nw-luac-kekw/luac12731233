local FlyoutRow_Objective = {
  Properties = {
    QuestAvailableIcon = {
      default = EntityId()
    },
    QuestAvailableCount = {
      default = EntityId()
    },
    QuestAvailableText = {
      default = EntityId()
    },
    QuestTurnInIcon = {
      default = EntityId()
    },
    QuestTurnInCount = {
      default = EntityId()
    },
    QuestTurnInText = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FlyoutRow_Objective)
function FlyoutRow_Objective:OnInit()
  BaseElement.OnInit(self)
end
function FlyoutRow_Objective:SetData(data)
  if not data then
    Log("[FlyoutRow_Objective] Error: invalid data passed to SetData")
    return
  end
  if data.questAvailableCount then
    UiTextBus.Event.SetText(self.Properties.QuestAvailableCount, data.questAvailableCount)
    if data.questAvailableCount > 0 then
      UiFaderBus.Event.SetFadeValue(self.Properties.QuestAvailableIcon, 1)
    else
      UiFaderBus.Event.SetFadeValue(self.Properties.QuestAvailableIcon, 0.3)
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.QuestAvailableText, data.questAvailableCount == 1 and "@ui_quest_available" or "@ui_quests_available", eUiTextSet_SetLocalized)
  end
  if data.questTurnInCount then
    UiTextBus.Event.SetText(self.Properties.QuestTurnInCount, data.questTurnInCount)
    if 0 < data.questTurnInCount then
      UiFaderBus.Event.SetFadeValue(self.Properties.QuestTurnInIcon, 1)
    else
      UiFaderBus.Event.SetFadeValue(self.Properties.QuestTurnInIcon, 0.3)
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.QuestTurnInText, data.questTurnInCount == 1 and "@ui_quest_ready" or "@ui_quests_ready", eUiTextSet_SetLocalized)
  end
end
return FlyoutRow_Objective
