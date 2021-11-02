local CraftingSummaryList = {
  Properties = {
    Content = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CraftingSummaryList)
function CraftingSummaryList:OnInit()
  BaseElement.OnInit(self)
  self.itemSlotList = {}
  self:BusConnect(UiDynamicScrollBoxDataBus, self.entityId)
  self:BusConnect(UiDynamicScrollBoxElementNotificationBus, self.entityId)
end
function CraftingSummaryList:SetItemSlots(itemSlotList)
  self.itemSlotList = itemSlotList
  UiDynamicScrollBoxBus.Event.RefreshContent(self.entityId)
end
function CraftingSummaryList:SetSalvageCallback(callback, table)
  self.salvageCallback = callback
  self.salvageCallbackTable = table
end
function CraftingSummaryList:OnSalvage(itemSlot)
  if self.salvageCallback then
    self.salvageCallback(self.salvageCallbackTable, itemSlot)
  end
end
function CraftingSummaryList:GetNumElements()
  return #self.itemSlotList
end
function CraftingSummaryList:OnElementBecomingVisible(rootEntity, index)
  if not self.itemSlotList then
    return
  end
  local dataTable = self.itemSlotList[index + 1]
  local entityTable = self.registrar:GetEntityTable(rootEntity)
  entityTable:SetItemSlot(dataTable, self.OnSalvage, self)
end
return CraftingSummaryList
