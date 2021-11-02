local TerritoryLogTab = {
  Properties = {
    CheckboxList = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TerritoryLogTab)
function TerritoryLogTab:OnInit()
  BaseElement.OnInit(self)
  self.territoryLogFilterCheckboxes = {
    {
      id = "1",
      text = "@ui_territoryupkeep",
      isChecked = true
    },
    {
      id = "2",
      text = "@ui_town_project",
      isChecked = true
    },
    {
      id = "3",
      text = "@ui_territorylevel",
      isChecked = true
    },
    {
      id = "4",
      text = "@ui_war",
      isChecked = true
    },
    {
      id = "5",
      text = "@ui_companypaycheck",
      isChecked = false
    },
    {
      id = "6",
      text = "@ui_tax_management",
      isChecked = false
    }
  }
  self.CheckboxList:SetLabel("")
  self.CheckboxList:SetCallback(self.OnTerritoryLogCheckboxChange, self)
  self.CheckboxList:InitCheckboxes(self.territoryLogFilterCheckboxes)
end
function TerritoryLogTab:OnTerritoryLogCheckboxChange()
end
function TerritoryLogTab:OnScreenOpened()
end
function TerritoryLogTab:OnShutdown()
end
return TerritoryLogTab
