local TaxInfo = {
  Properties = {
    LabelText = {
      default = EntityId()
    },
    ValueText1 = {
      default = EntityId()
    },
    ValueText2 = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TaxInfo)
function TaxInfo:SetTaxInfo(label, value1, value2)
  UiTextBus.Event.SetTextWithFlags(self.Properties.LabelText, label, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ValueText1, value1, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetText(self.Properties.ValueText2, value2)
end
return TaxInfo
