local CraftingAttribute = {
  Properties = {
    Amount = {
      default = EntityId()
    },
    Label = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CraftingAttribute)
function CraftingAttribute:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.Properties.Amount, self.UIStyle.FONT_STYLE_CRAFTING_ATTRIBUTE)
  SetTextStyle(self.Properties.Label, self.UIStyle.FONT_STYLE_CRAFTING_ATTRIBUTE_LABEL)
end
function CraftingAttribute:SetAttributes(attributeTable)
  if not attributeTable then
    return
  end
  for _, statData in ipairs(attributeTable) do
    if statData.amount > 0 then
      UiTextBus.Event.SetText(self.Properties.Amount, statData.amount)
      UiTextBus.Event.SetTextWithFlags(self.Properties.Label, statData.attribute, eUiTextSet_SetLocalized)
    end
  end
end
return CraftingAttribute
