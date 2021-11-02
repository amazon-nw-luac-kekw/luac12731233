local DynamicTooltip_DisclaimerText = {
  Properties = {
    Text = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(DynamicTooltip_DisclaimerText)
function DynamicTooltip_DisclaimerText:OnInit()
  self.LogSettings = {"Tooltips"}
  BaseElement.OnInit(self)
  SetTextStyle(self.Properties.Text, self.UIStyle.FONT_STYLE_DISCLAIMER_TEXT)
end
function DynamicTooltip_DisclaimerText:SetItem(itemTable, equipSlot, compareTo)
  if itemTable and type(itemTable.disclaimerText) == "string" and string.len(itemTable.disclaimerText) > 0 then
    UiTextBus.Event.SetTextWithFlags(self.Properties.Text, itemTable.disclaimerText, eUiTextSet_SetLocalized)
    return self.parent:ResizeTextInFrame(self.entityId, self.Properties.Text)
  end
  return 0
end
return DynamicTooltip_DisclaimerText
