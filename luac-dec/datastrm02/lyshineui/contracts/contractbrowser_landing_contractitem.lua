local ContractBrowser_Landing_ContractItem = {
  Properties = {
    Number = {
      default = EntityId()
    },
    ItemLayout = {
      default = EntityId()
    },
    ItemName = {
      default = EntityId()
    },
    Quantity = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ContractBrowser_Landing_ContractItem)
function ContractBrowser_Landing_ContractItem:OnInit()
  BaseElement.OnInit(self)
end
function ContractBrowser_Landing_ContractItem:OnShutdown()
end
function ContractBrowser_Landing_ContractItem:SetContractItemData(index, itemData)
  UiElementBus.Event.SetIsEnabled(self.entityId, itemData ~= nil)
  if itemData then
    UiTextBus.Event.SetText(self.Properties.Number, tostring(index))
    self.ItemLayout:SetItemByDescriptor(itemData.descriptor)
    UiTextBus.Event.SetTextWithFlags(self.Properties.ItemName, itemData.name, eUiTextSet_SetLocalized)
    local locText = GetLocalizedReplacementText("@ui_quantitywithx", {
      quantity = tostring(itemData.quantity)
    })
    UiTextBus.Event.SetText(self.Properties.Quantity, locText)
  end
end
return ContractBrowser_Landing_ContractItem
