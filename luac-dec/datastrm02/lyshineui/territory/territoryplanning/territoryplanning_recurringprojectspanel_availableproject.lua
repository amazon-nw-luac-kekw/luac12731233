local TerritoryPlanning_RecurringProjectsPanel_AvailableProject = {
  Properties = {
    HeaderContainer = {
      default = EntityId()
    },
    HeaderText = {
      default = EntityId()
    },
    ProjectButton = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TerritoryPlanning_RecurringProjectsPanel_AvailableProject)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function TerritoryPlanning_RecurringProjectsPanel_AvailableProject:OnInit()
  BaseElement.OnInit(self)
end
function TerritoryPlanning_RecurringProjectsPanel_AvailableProject:OnShutdown()
end
function TerritoryPlanning_RecurringProjectsPanel_AvailableProject:GetElementWidth()
  return UiTransform2dBus.Event.GetLocalWidth(self.entityId)
end
function TerritoryPlanning_RecurringProjectsPanel_AvailableProject:GetElementHeight(gridItemData)
  if gridItemData and gridItemData.rowType.name == "header" then
    return UiTransform2dBus.Event.GetLocalHeight(self.Properties.HeaderContainer)
  end
  return UiLayoutCellBus.Event.GetTargetHeight(self.Properties.ProjectButton)
end
function TerritoryPlanning_RecurringProjectsPanel_AvailableProject:GetHorizontalSpacing()
  return 15
end
function TerritoryPlanning_RecurringProjectsPanel_AvailableProject:SetGridItemData(gridItemData)
  UiElementBus.Event.SetIsEnabled(self.entityId, gridItemData ~= nil)
  if not gridItemData then
    return
  end
  self.rowType = gridItemData.rowType
  local isHeader = self.rowType.name == "header"
  UiElementBus.Event.SetIsEnabled(self.Properties.HeaderContainer, isHeader)
  UiElementBus.Event.SetIsEnabled(self.Properties.ProjectButton, not isHeader)
  if self.rowType.name == "header" then
    UiTextBus.Event.SetTextWithFlags(self.Properties.HeaderText, gridItemData.categoryData, eUiTextSet_SetLocalized)
  else
    self.ProjectButton:SetGridItemData(gridItemData.projectData)
  end
end
return TerritoryPlanning_RecurringProjectsPanel_AvailableProject
