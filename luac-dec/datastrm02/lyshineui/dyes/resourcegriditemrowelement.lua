local ResourceGridItemRowElement = {
  Properties = {
    ItemLayout = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ResourceGridItemRowElement)
function ResourceGridItemRowElement:OnInit()
  BaseElement.OnInit(self)
end
function ResourceGridItemRowElement:OnShutdown()
end
function ResourceGridItemRowElement:GetElementWidth()
  return 60
end
function ResourceGridItemRowElement:GetElementHeight()
  return 60
end
function ResourceGridItemRowElement:GetHeaderElementHeight()
  return UiTransform2dBus.Event.GetLocalHeight(self.Properties.HeaderContainer)
end
function ResourceGridItemRowElement:GetHorizontalSpacing()
  return 0
end
function ResourceGridItemRowElement:SetGridItemData(data)
  if not data then
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemLayout, false)
    return
  end
  self.ItemLayout:SetCallback(data.callbackSelf, data.callbackFunction)
  self.ItemLayout:SetIsItemDraggable(true)
  self.ItemLayout:SetTooltipEnabled(true)
  self.ItemLayout:SetItemByDescriptor(data.slot:GetItemDescriptor())
  self.ItemLayout:SetLayout(self.ItemLayout.UIStyle.ITEM_LAYOUT_CIRCLE)
  UiElementBus.Event.SetIsEnabled(self.Properties.ItemLayout, true)
end
return ResourceGridItemRowElement
