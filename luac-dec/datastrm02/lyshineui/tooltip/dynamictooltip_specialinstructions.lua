local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local DynamicTooltip_SpecialInstructions = {
  Properties = {
    Text = {
      default = EntityId()
    }
  }
}
BaseElement:CreateNewElement(DynamicTooltip_SpecialInstructions)
function DynamicTooltip_SpecialInstructions:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.Properties.Text, self.UIStyle.FONT_STYLE_FLAVOR_TEXT)
end
function DynamicTooltip_SpecialInstructions:SetItem(itemTable, equipSlot, compareTo)
  if itemTable and itemTable.tooltipLayout and type(itemTable.tooltipLayout.SpecialInstructions) == "string" and string.len(itemTable.tooltipLayout.SpecialInstructions) > 0 then
    UiTextBus.Event.SetTextWithFlags(self.Properties.Text, itemTable.tooltipLayout.SpecialInstructions, eUiTextSet_SetLocalized)
    return self.parent:ResizeTextInFrame(self.entityId, self.Properties.Text)
  end
  return 0
end
return DynamicTooltip_SpecialInstructions
