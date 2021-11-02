local ContractBrowser_ConfirmTransactionPopup_AdditionalInfo = {
  Properties = {
    Label = {
      default = EntityId()
    },
    Description = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ContractBrowser_ConfirmTransactionPopup_AdditionalInfo)
function ContractBrowser_ConfirmTransactionPopup_AdditionalInfo:OnInit()
  BaseElement.OnInit(self)
end
function ContractBrowser_ConfirmTransactionPopup_AdditionalInfo:OnShutdown()
end
function ContractBrowser_ConfirmTransactionPopup_AdditionalInfo:SetAdditionalInfo(isVisible, labelText, descriptionText)
  UiElementBus.Event.SetIsEnabled(self.entityId, isVisible)
  UiLayoutCellBus.Event.SetTargetHeight(self.entityId, isVisible and 55 or 0)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Label, labelText, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Description, descriptionText, eUiTextSet_SetLocalized)
end
return ContractBrowser_ConfirmTransactionPopup_AdditionalInfo
