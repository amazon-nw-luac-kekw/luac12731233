local ContractBrowser_NoContractsContainer = {
  Properties = {
    Label = {
      default = EntityId()
    },
    Button1 = {
      default = EntityId()
    },
    Button2 = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ContractBrowser_NoContractsContainer)
function ContractBrowser_NoContractsContainer:OnInit()
  BaseElement.OnInit(self)
end
function ContractBrowser_NoContractsContainer:OnShutdown()
end
function ContractBrowser_NoContractsContainer:ToggleNoContractsVisibility(isVisible, labelText, button1Data, button2Data)
  UiElementBus.Event.SetIsEnabled(self.entityId, isVisible)
  if isVisible then
    UiTextBus.Event.SetTextWithFlags(self.Properties.Label, labelText, eUiTextSet_SetLocalized)
    UiElementBus.Event.SetIsEnabled(self.Properties.Button1, button1Data ~= nil)
    if button1Data then
      self.Button1:SetButtonStyle(self.Button1.BUTTON_STYLE_DEFAULT)
      self.Button1:SetText(button1Data.text)
      self.Button1:SetCallback(button1Data.callbackFn, button1Data.callbackSelf)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.Button2, button2Data ~= nil)
    if button2Data then
      self.Button2:SetButtonStyle(self.Button2.BUTTON_STYLE_DEFAULT)
      self.Button2:SetText(button2Data.text)
      self.Button2:SetCallback(button2Data.callbackFn, button2Data.callbackSelf)
      UiElementBus.Event.SetIsEnabled(self.Properties.Button2, true)
      self.ScriptedEntityTweener:Set(self.Properties.Button1, {x = -145})
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.Button2, false)
      self.ScriptedEntityTweener:Set(self.Properties.Button1, {x = 0})
    end
  end
end
return ContractBrowser_NoContractsContainer
