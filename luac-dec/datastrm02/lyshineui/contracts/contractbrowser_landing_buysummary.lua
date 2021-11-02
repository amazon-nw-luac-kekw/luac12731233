local ContractBrowser_Landing_BuySummary = {
  Properties = {
    NumListings = {
      default = EntityId()
    },
    ItemSearchBar = {
      default = EntityId()
    },
    OutpostFilter = {
      default = EntityId()
    },
    FilterItemButtons = {
      default = EntityId()
    },
    BrowseButton = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ContractBrowser_Landing_BuySummary)
local contractsDataHandler = RequireScript("LyShineUI._Common.ContractsDataHandler")
function ContractBrowser_Landing_BuySummary:OnInit()
  BaseElement.OnInit(self)
  self.ItemSearchBar:SetSelectedCallback(function(self, itemData)
    self.itemData = itemData
    self:ExecuteCallback()
  end, self)
  local function endEditCallback()
    self.ItemSearchBar:ClearSearchField()
  end
  self.ItemSearchBar:SetEndEditCallback(endEditCallback, self)
  local filterList = ItemDataManagerBus.Broadcast.GetFilteredCategoryList("", "", "", "")
  local numFilterList = #filterList
  local childElements = UiElementBus.Event.GetChildren(self.Properties.FilterItemButtons)
  for i = 1, #childElements do
    if i <= numFilterList then
      local buySummary = self.registrar:GetEntityTable(childElements[i])
      local categoryKey = filterList[i]
      local categoryStr = string.format("@CategoryData_%s", categoryKey)
      local categoryIcon = string.format("LyShineUI\\Images\\Icons\\ItemTypes\\%s.dds", "itemType_" .. categoryKey)
      buySummary:SetFilterItemButtonData(categoryStr, categoryIcon, self, function()
        self.filterCategory = categoryKey
        self:ExecuteCallback()
      end)
    end
  end
  self.BrowseButton:SetText("@ui_browse_listings")
  self.BrowseButton:SetCallback(self.ExecuteCallback, self)
end
function ContractBrowser_Landing_BuySummary:OnSummaryOpen()
  self.itemData = nil
  self.filterCategory = nil
  contractsDataHandler:GetNumItemContracts(self, function(self, sellOrdersText)
    UiTextBus.Event.SetTextWithFlags(self.Properties.NumListings, sellOrdersText, eUiTextSet_SetLocalized)
  end, nil, {
    contractType = eContractType_Buy,
    itemCategory = "",
    itemFamily = "",
    itemGroup = "",
    itemId = ""
  })
end
function ContractBrowser_Landing_BuySummary:SetCallback(table, command)
  self.callback = command
  self.callbackTable = table
end
function ContractBrowser_Landing_BuySummary:ExecuteCallback()
  if self.callback ~= nil and self.callbackTable ~= nil then
    self.callback(self.callbackTable, self.itemData, self.filterCategory)
  end
end
return ContractBrowser_Landing_BuySummary
