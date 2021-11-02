local ContractBrowser_Landing_ContractFilterItem = {
  Properties = {
    ItemIcon = {
      default = EntityId()
    },
    ItemName = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ContractBrowser_Landing_ContractFilterItem)
function ContractBrowser_Landing_ContractFilterItem:OnInit()
  BaseElement.OnInit(self)
end
function ContractBrowser_Landing_ContractFilterItem:OnShutdown()
end
function ContractBrowser_Landing_ContractFilterItem:SetFilterItemButtonData(categoryName, categoryIcon, callbackSelf, callbackFunction)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ItemName, categoryName, eUiTextSet_SetLocalized)
  UiImageBus.Event.SetSpritePathname(self.Properties.ItemIcon, categoryIcon)
  self.callbackSelf = callbackSelf
  self.callbackFunction = callbackFunction
end
function ContractBrowser_Landing_ContractFilterItem:OnClick()
  if self.callbackSelf ~= nil then
    self.callbackFunction(self.callbackSelf)
  end
end
return ContractBrowser_Landing_ContractFilterItem
