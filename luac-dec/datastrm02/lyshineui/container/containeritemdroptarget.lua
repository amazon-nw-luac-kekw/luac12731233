local ContainerItemDropTarget = {
  Properties = {}
}
function ContainerItemDropTarget:OnActivate()
  self.dropTargetHandler = UiDropTargetNotificationBus.Connect(self, self.entityId)
  self.commonFunctions = RequireScript("LyShineUI.CommonDragDrop")
  self.dataLayer = RequireScript("LyShineUI.UiDataLayer")
  self.dataLayer:RegisterObserver(self, "UIFeatures.g_uiItemBreadcrumbsActive", function(self, dataNode)
    self.enableBreadcrumbs = dataNode:GetData()
  end)
  self.enableBreadcrumbs = self.dataLayer:GetDataNode("UIFeatures.g_uiItemBreadcrumbsActive"):GetData()
  if self.enableBreadcrumbs then
    Debug.Log("IBC: ContainerItemDropTarget OnActivate")
  end
end
function ContainerItemDropTarget:OnDeactivate()
  self.dropTargetHandler:Disconnect()
  self.commonFunctions = nil
  if self.enableBreadcrumbs then
    Debug.Log("IBC: ContainerItemDropTarget OnDeactivate")
  end
  self.dataLayer:UnregisterObserver(self, "UIFeatures.g_uiItemBreadcrumbsActive")
  self.dataLayer = nil
end
function ContainerItemDropTarget:OnDropHoverStart(draggable)
  self.commonFunctions:OnDropHoverStart(self.entityId, draggable)
end
function ContainerItemDropTarget:OnDropHoverEnd(draggable)
  self.commonFunctions:OnDropHoverEnd(self.entityId, draggable)
end
function ContainerItemDropTarget:OnDrop(draggable)
  local slotContainer = UiElementBus.Event.GetParent(self.entityId)
  local targetSlotId = UiElementBus.Event.GetIndexOfChildByEntityId(slotContainer, self.entityId)
  local targetContainerId = ItemListBus.Event.GetContainerEntityId(slotContainer)
  self.commonFunctions:OnContainerDrop(draggable, targetSlotId, targetContainerId, false)
end
return ContainerItemDropTarget
