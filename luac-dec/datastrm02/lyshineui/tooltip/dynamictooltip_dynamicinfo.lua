local DynamicTooltip_DynamicInfo = {
  Properties = {
    Text = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(DynamicTooltip_DynamicInfo)
function DynamicTooltip_DynamicInfo:OnInit()
  self.LogSettings = {"Tooltips"}
  BaseElement.OnInit(self)
end
function DynamicTooltip_DynamicInfo:SetItem(itemTable, equipSlot, compareTo)
  SetTextStyle(self.Properties.Text, self.UIStyle.FONT_STYLE_FLAVOR_TEXT)
  if itemTable and type(itemTable.dynamicInfoText) == "string" and string.len(itemTable.dynamicInfoText) > 0 then
    UiTextBus.Event.SetTextWithFlags(self.Properties.Text, itemTable.dynamicInfoText, eUiTextSet_SetLocalized)
    local color = itemTable.dynamicInfoColor
    if color then
      UiTextBus.Event.SetColor(self.Properties.Text, color)
    end
    return self.parent:ResizeTextInFrame(self.entityId, self.Properties.Text)
  end
  return 0
end
return DynamicTooltip_DynamicInfo
