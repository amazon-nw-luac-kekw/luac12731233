local ContractBrowser_Landing_SellSummary = {
  Properties = {
    NumListings = {
      default = EntityId()
    },
    ItemList = {
      default = EntityId()
    },
    AdditionalItemsLabel = {
      default = EntityId()
    },
    SellItemsButton = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ContractBrowser_Landing_SellSummary)
local contractsDataHandler = RequireScript("LyShineUI._Common.ContractsDataHandler")
function ContractBrowser_Landing_SellSummary:OnInit()
  BaseElement.OnInit(self)
  self.SellItemsButton:SetText("@ui_sell_items")
end
function ContractBrowser_Landing_SellSummary:OnSummaryOpen()
  contractsDataHandler:GetNumItemContracts(self, function(self, sellOrdersText)
    UiTextBus.Event.SetTextWithFlags(self.Properties.NumListings, sellOrdersText, eUiTextSet_SetLocalized)
  end, nil, {
    contractType = eContractType_Sell,
    itemCategory = "",
    itemFamily = "",
    itemGroup = "",
    itemId = ""
  })
  contractsDataHandler:RequestInventoryItemData(self, function(self, inventoryItems, hiddenDamagedItems)
    local childElements = UiElementBus.Event.GetChildren(self.Properties.ItemList)
    for i = 1, #childElements do
      local sellItemSummary = self.registrar:GetEntityTable(childElements[i])
      sellItemSummary:SetContractItemData(i, inventoryItems[i])
    end
    local numAdditional = math.max(#inventoryItems - #childElements, 0)
    UiTextBus.Event.SetTextWithFlags(self.Properties.AdditionalItemsLabel, tostring(numAdditional), eUiTextSet_SetLocalized)
  end)
end
function ContractBrowser_Landing_SellSummary:SetCallback(table, command)
  self.SellItemsButton:SetCallback(command, table)
end
return ContractBrowser_Landing_SellSummary
