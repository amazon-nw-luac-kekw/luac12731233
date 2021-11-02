local StoreGridItem = {
  Properties = {
    StoreProductElement = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(StoreGridItem)
function StoreGridItem:OnInit()
  BaseElement.OnInit(self)
end
function StoreGridItem:OnShutdown()
end
function StoreGridItem:GetElementWidth()
  return UiLayoutCellBus.Event.GetTargetWidth(self.entityId)
end
function StoreGridItem:GetElementHeight()
  return UiLayoutCellBus.Event.GetTargetHeight(self.entityId)
end
function StoreGridItem:GetHorizontalSpacing()
  return 15
end
function StoreGridItem:OnClicked()
  self.itemData.cb(self.itemData.context, self)
end
function StoreGridItem:SetGridItemData(itemData)
  self.itemData = itemData
  if not itemData then
    UiElementBus.Event.SetIsEnabled(self.Properties.StoreProductElement, false)
    return
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.StoreProductElement, true)
  self.StoreProductElement:SetStoreProductData(itemData)
end
return StoreGridItem
