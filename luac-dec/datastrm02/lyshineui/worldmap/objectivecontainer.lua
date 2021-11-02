local ObjectiveContainer = {
  Properties = {
    Title = {
      default = EntityId()
    },
    Description = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ObjectiveContainer)
function ObjectiveContainer:OnInit()
  BaseElement.OnInit(self)
end
function ObjectiveContainer:SetMissionId(missionId)
  self.missionId = missionId
  local objectiveData = ObjectivesDataManagerBus.Broadcast.GetMissionObjectiveData(missionId)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Title, objectiveData.title, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Description, objectiveData.description, eUiTextSet_SetLocalized)
end
function ObjectiveContainer:SetVisibility(isVisible)
  if self.isVisible == isVisible then
    return
  end
  self.isVisible = isVisible
  UiElementBus.Event.SetIsEnabled(self.entityId, self.isVisible)
end
function ObjectiveContainer:IsVisible()
  return self.isVisible
end
return ObjectiveContainer
