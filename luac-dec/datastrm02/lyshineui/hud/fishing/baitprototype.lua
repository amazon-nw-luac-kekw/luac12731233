local BaitPrototype = {
  Properties = {
    item = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(BaitPrototype)
function BaitPrototype:OnInit()
  BaseElement.OnInit(self)
end
function BaitPrototype:GetElementWidth()
  return 70
end
function BaitPrototype:GetElementHeight()
  return 70
end
function BaitPrototype:GetHorizontalSpacing()
  return 11
end
function BaitPrototype:SetGridItemData(data)
  if not data then
    UiElementBus.Event.SetIsEnabled(self.Properties.item, false)
    return
  end
  self.item:SetCallback(data.callbackSelf, data.callbackFunction)
  self.item:SetTooltipEnabled(true)
  self.item:SetIsItemDraggable(true)
  self.item:SetItemByDescriptor(data.itemDescriptor)
  self.item:SetLayout(self.item.UIStyle.ITEM_LAYOUT_CIRCLE)
  UiElementBus.Event.SetIsEnabled(self.Properties.item, true)
end
return BaitPrototype
