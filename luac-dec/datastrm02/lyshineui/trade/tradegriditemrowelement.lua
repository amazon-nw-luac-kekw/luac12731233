local TradeGridItemRowElement = {
  Properties = {
    ItemDraggable = {
      default = EntityId()
    }
  },
  slotId = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TradeGridItemRowElement)
function TradeGridItemRowElement:OnInit()
  BaseElement.OnInit(self)
end
function TradeGridItemRowElement:OnShutdown()
end
function TradeGridItemRowElement:GetElementWidth()
  return 68
end
function TradeGridItemRowElement:GetElementHeight()
  return 68
end
function TradeGridItemRowElement:GetHeaderElementHeight()
  return UiTransform2dBus.Event.GetLocalHeight(self.Properties.HeaderContainer)
end
function TradeGridItemRowElement:GetHorizontalSpacing()
  return 4
end
function TradeGridItemRowElement:SetGridItemData(data)
  if not data then
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemDraggable, false)
    return
  end
  self.slotId = data.slotId
  self.callbackSelf = data.callbackSelf
  self.callbackFunction = data.callbackFunction
  self.ItemDraggable:SetCanDrag(data.isSending)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ItemDraggable, data.isSending)
  self.ItemDraggable:SetIsInTradeContainer(true)
  self.ItemDraggable.ItemLayout:SetModeType(self.ItemDraggable.ItemLayout.MODE_TYPE_P2P_TRADING)
  self.ItemDraggable.ItemLayout:SetItem(data.slot)
  if data.isSending then
    self.ItemDraggable.ItemLayout:SetSlotName(data.slotId)
  else
    self.ItemDraggable.ItemLayout:SetTooltipEnabled(true)
  end
  self.ItemDraggable.ItemLayout:SetQuantity(data.quantity)
  UiElementBus.Event.SetIsEnabled(self.Properties.ItemDraggable, true)
  if data.callbackSelf and data.registerFunction then
    data.registerFunction(data.callbackSelf, self)
  end
end
function TradeGridItemRowElement:OnItemPress(item)
  if self.callbackSelf and self.callbackFunction then
    self.callbackFunction(self.callbackSelf, self.slotId)
  end
end
return TradeGridItemRowElement
