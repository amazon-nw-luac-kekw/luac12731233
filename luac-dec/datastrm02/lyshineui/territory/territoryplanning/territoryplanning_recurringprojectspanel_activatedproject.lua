local TerritoryPlanning_RecurringProjectsPanel_ActivatedProject = {
  Properties = {
    Icon = {
      default = EntityId()
    },
    RadialProgress = {
      default = EntityId()
    },
    ProgressText = {
      default = EntityId()
    },
    TitleText = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TerritoryPlanning_RecurringProjectsPanel_ActivatedProject)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function TerritoryPlanning_RecurringProjectsPanel_ActivatedProject:OnInit()
  BaseElement.OnInit(self)
end
function TerritoryPlanning_RecurringProjectsPanel_ActivatedProject:OnShutdown()
end
function TerritoryPlanning_RecurringProjectsPanel_ActivatedProject:GetElementWidth()
  return UiLayoutCellBus.Event.GetTargetWidth(self.entityId)
end
function TerritoryPlanning_RecurringProjectsPanel_ActivatedProject:GetElementHeight()
  return UiLayoutCellBus.Event.GetTargetHeight(self.entityId)
end
function TerritoryPlanning_RecurringProjectsPanel_ActivatedProject:GetHorizontalSpacing()
  return 15
end
function TerritoryPlanning_RecurringProjectsPanel_ActivatedProject:SetGridItemData(projectData)
  UiElementBus.Event.SetIsEnabled(self.entityId, projectData ~= nil)
  if projectData then
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, projectData.image)
    UiTextBus.Event.SetTextWithFlags(self.Properties.TitleText, projectData.buttonLabel, eUiTextSet_SetLocalized)
    local duration = timeHelpers:ConvertToTwoLargestTimeEstimate(projectData.remainingDurSec)
    local durationText = GetLocalizedReplacementText("@ui_leaderboard_time_left", {time = duration})
    UiTextBus.Event.SetTextWithFlags(self.Properties.ProgressText, durationText, eUiTextSet_SetAsIs)
    local percent = math.max(0, projectData.remainingDurSec / projectData.totalDurationSec)
    local fillAmount = 1 - percent
    UiImageBus.Event.SetFillAmount(self.Properties.RadialProgress, fillAmount)
  end
  self.projectData = projectData
end
return TerritoryPlanning_RecurringProjectsPanel_ActivatedProject
