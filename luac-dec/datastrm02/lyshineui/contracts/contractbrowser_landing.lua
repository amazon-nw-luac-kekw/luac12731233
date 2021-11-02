local ContractBrowser_Landing = {
  Properties = {
    BuySection = {
      default = EntityId()
    },
    SellSection = {
      default = EntityId()
    },
    ClaimCharterItem = {
      default = EntityId()
    },
    ClaimCharterButton = {
      default = EntityId()
    },
    ConfirmedKillsButton = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ContractBrowser_Landing)
local contractsDataHandler = RequireScript("LyShineUI._Common.ContractsDataHandler")
function ContractBrowser_Landing:OnInit()
  BaseElement.OnInit(self)
  local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  local id = UiCanvasBus.Event.FindElementByName(canvasId, "ContractList")
  self.ContractBrowser = self.registrar:GetEntityTable(id)
  id = UiCanvasBus.Event.FindElementByName(canvasId, "ConfirmTransactionPopup")
  self.TransactionPopup = self.registrar:GetEntityTable(id)
  self.BuySection:SetCallback(self, function(self, itemData, filterCategory)
    self:SetContractLandingVisibility(false)
    self.ContractBrowser:OnBrowseTabSelected()
    if itemData then
      DynamicBus.ContractBrowser_BrowseTab.Broadcast.OnSearchItemSelected(itemData)
    elseif filterCategory then
      DynamicBus.ContractBrowser_BrowseTab.Broadcast.OnSearchItemSelected({category = filterCategory})
    end
  end)
  self.SellSection:SetCallback(self, function()
    self:SetContractLandingVisibility(false)
    self.ContractBrowser:OnSellTabSelected()
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.OnLocalPlayerSet", function(self, isSet)
    if isSet then
      local buyableNpcContracts = contractsDataHandler:CurrencyConversionToContracts(false)
      local currencyConversionId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.CurrencyConversionEntityId")
      local inventoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
      self.ClaimCharterButton:SetText("@ui_view_details")
      for _, contractData in pairs(buyableNpcContracts) do
        contractData.quantity = 1
        contractData.price = CurrencyConversionRequestBus.Event.GetPrice(currencyConversionId, contractData.itemDescriptor, true)
        self.ClaimCharterItem:SetItemByDescriptor(contractData.itemDescriptor)
        self.ClaimCharterButton:SetCallback(function()
          self.TransactionPopup:SetConfirmationData(true, contractData, self, function(self, contractData, quantity)
            contractsDataHandler:FulfillContract(contractData, quantity, self, function(self)
              self.TransactionPopup:SetConfirmPopupVisibility(false, true)
              DynamicBus.EncumbranceBus.Broadcast.PlayCraftAnimation("@ui_added_to_inventory", 2)
              self.audioHelper:PlaySound(self.audioHelper.Crafting_Inventory_Add)
            end, function()
            end)
          end)
        end, self)
        break
      end
    end
  end)
  self.ConfirmedKillsButton:SetCallback(function()
  end, self)
end
function ContractBrowser_Landing:SetContractLandingVisibility(isVisible)
  if isVisible ~= self.isVisible then
    self.isVisible = isVisible
    local entityParentId = UiElementBus.Event.GetParent(self.entityId)
    UiElementBus.Event.SetIsEnabled(entityParentId, isVisible)
    if isVisible then
      self.BuySection:OnSummaryOpen()
      self.SellSection:OnSummaryOpen()
    end
  end
end
return ContractBrowser_Landing
