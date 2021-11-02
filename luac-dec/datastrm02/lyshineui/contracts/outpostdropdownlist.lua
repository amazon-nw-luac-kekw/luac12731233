local OutpostDropdownList = {
  Properties = {
    ShowingText = {
      default = EntityId()
    },
    OutpostFilterDropdown = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(OutpostDropdownList)
local contractsDataHandler = RequireScript("LyShineUI._Common.ContractsDataHandler")
function OutpostDropdownList:OnInit()
  BaseElement.OnInit(self)
  self.OutpostFilterDropdown:SetDropdownListHeight(400)
  self.OutpostFilterDropdown:SetCallback(self.OnOutpostFilterChange, self)
  self.OutpostFilterDropdown:SetItemsReadyCallback(self.OnItemsReady, self)
  self.OutpostFilterDropdown:SetDropdownScreenCanvasId(self.Properties.OutpostFilterDropdown)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.IsWorldDataAvailable", function(isAvailable)
    if isAvailable then
      self:RefreshOutpostList()
    end
  end)
  self:BusConnect(UiElementNotificationBus, self.entityId)
end
function OutpostDropdownList:OnShutdown()
end
function OutpostDropdownList:OnUiElementAndAncestorsEnabledChanged(isEnabled)
  if not isEnabled then
    self:CollapseDropdown()
  end
end
function OutpostDropdownList:CollapseDropdown()
  UiDropdownBus.Event.Collapse(self.Properties.OutpostFilterDropdown)
end
function OutpostDropdownList:SetShowingTextVisibility(isEnabled)
  UiElementBus.Event.SetIsEnabled(self.Properties.ShowingText, isEnabled)
end
function OutpostDropdownList:RefreshCapitalDistances()
  local localPlayerPosition = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Position")
  for i = 2, #self.outpostList do
    self.outpostList[i].textRight = GetLocalizedDistance(localPlayerPosition, self.outpostList[i].position)
    self.OutpostFilterDropdown:SetRightText(i, self.outpostList[i].textRight)
  end
  self:ResetOutpostFilter()
end
function OutpostDropdownList:RefreshOutpostList()
  self.outpostList = contractsDataHandler:GetOutpostList()
  self.OutpostFilterDropdown:SetListData(self.outpostList)
end
function OutpostDropdownList:OnOutpostFilterChange(data, isChecked)
  self.outpostList[data.itemIndex].isChecked = isChecked
  if data.itemIndex == 1 then
    for i = 2, #self.outpostList do
      self.OutpostFilterDropdown:SetCheckboxState(i, isChecked)
      self.outpostList[i].isChecked = isChecked
    end
  end
  if data.itemIndex > 1 and not isChecked and self.outpostList[1].isChecked then
    self.OutpostFilterDropdown:SetCheckboxState(1, false)
    self.outpostList[1].isChecked = false
  end
  local refreshContracts = true
  self:UpdateOutpostFilter(refreshContracts)
end
function OutpostDropdownList:OnItemsReady()
  self:ResetOutpostFilter()
end
function OutpostDropdownList:ResetOutpostFilter()
  local outpostId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.OutpostId")
  if not outpostId then
    return
  end
  for i = 2, #self.outpostList do
    local isCurrentOutpost = self.outpostList[i].outpostId and self.outpostList[i].outpostId == outpostId
    self.OutpostFilterDropdown:SetCheckboxState(i, isCurrentOutpost)
    self.outpostList[i].isChecked = isCurrentOutpost
    if isCurrentOutpost then
      self.outpostList[i].textRight = ""
    end
  end
  local refreshContracts = false
  self:UpdateOutpostFilter(refreshContracts)
end
function OutpostDropdownList:UpdateOutpostFilter(refreshContracts)
  local noneKey = "@ui_selectallouposts"
  local firstSelected = noneKey
  local numSelected = 0
  for i = 2, #self.outpostList do
    if self.outpostList[i].isChecked then
      if firstSelected == noneKey then
        firstSelected = self.outpostList[i].text
      end
      numSelected = numSelected + 1
    end
  end
  local labelText = firstSelected
  local skipLocalization = false
  if 1 < numSelected then
    labelText = GetLocalizedReplacementText("@ui_outpostselectorlabelmore", {
      outpostName = firstSelected,
      numOtherOutposts = tostring(numSelected - 1)
    })
    skipLocalization = true
  end
  self.OutpostFilterDropdown:SetText(labelText, skipLocalization)
  self:ExecuteCallback(refreshContracts)
end
function OutpostDropdownList:GetSelectedOutposts()
  local selectedOutpostIds = {}
  for _, outpostData in pairs(self.outpostList) do
    if outpostData.isChecked then
      table.insert(selectedOutpostIds, outpostData.outpostId)
    end
  end
  return selectedOutpostIds
end
function OutpostDropdownList:SetCallback(func, table)
  self.cbFunction = func
  self.cbTable = table
end
function OutpostDropdownList:ExecuteCallback(refreshContracts)
  self.cbFunction(self.cbTable, refreshContracts)
end
return OutpostDropdownList
