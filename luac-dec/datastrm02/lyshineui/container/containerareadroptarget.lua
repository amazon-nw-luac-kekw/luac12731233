local CommonFunctions = RequireScript("LyShineUI.CommonDragDrop")
local ContainerAreaDropTarget = {
  Properties = {
    DropTargetHighlight = {
      default = EntityId()
    },
    PlayerInventory = {default = false}
  },
  containerId = EntityId(),
  isLootDrop = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ContainerAreaDropTarget)
function ContainerAreaDropTarget:OnInit()
  BaseElement.OnInit(self)
  self.dropTargetHandler = UiDropTargetNotificationBus.Connect(self, self.entityId)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiItemBreadcrumbsActive", function(self, enabled)
    self.enableBreadcrumbs = enabled
  end)
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.ItemDragging.GemSlotId", self.UpdateIsDraggingGem)
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.ItemDragging.RepairKitSlotId", self.UpdateIsDraggingRepairKit)
  if self.enableBreadcrumbs then
    Debug.Log("IBC: ContainerAreaDropTarget OnActivate")
  end
end
function ContainerAreaDropTarget:UpdateIsDraggingGem(gemSlotId)
  self.isDraggingGem = gemSlotId ~= -1
  self:UpdateDropTargetEnabledState()
end
function ContainerAreaDropTarget:UpdateIsDraggingRepairKit(repairKitSlotId)
  self.isDraggingRepairKit = repairKitSlotId ~= -1
  self:UpdateDropTargetEnabledState()
end
function ContainerAreaDropTarget:UpdateDropTargetEnabledState()
  local containerType = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ItemDragging.ContainerType")
  local isCorrectContainerType = containerType == eItemDragContext_Inventory and self.Properties.PlayerInventory or containerType == eItemDragContext_Container and not self.Properties.PlayerInventory
  if isCorrectContainerType then
    UiElementBus.Event.SetIsEnabled(self.entityId, not self.isDraggingGem and not self.isDraggingRepairKit)
  end
end
function ContainerAreaDropTarget:SetContainer(containerId, isLootDrop)
  self.containerId = containerId
  self.isLootDrop = isLootDrop
end
function ContainerAreaDropTarget:OnShutdown()
  self.dropTargetHandler:Disconnect()
  if self.enableBreadcrumbs then
    Debug.Log("IBC: ContainerAreaDropTarget OnDeactivate")
  end
  self.dataLayer:UnregisterObserver(self, "UIFeatures.g_uiItemBreadcrumbsActive")
end
function ContainerAreaDropTarget:OnDropHoverStart(draggable)
  CommonFunctions:OnDropHoverStart(self.entityId, draggable)
  UiElementBus.Event.SetIsEnabled(self.Properties.DropTargetHighlight, true)
  self.ScriptedEntityTweener:Play(self.Properties.DropTargetHighlight, 0.15, {opacity = 1, ease = "QuadOut"})
end
function ContainerAreaDropTarget:OnDropHoverEnd(draggable)
  CommonFunctions:OnDropHoverEnd(self.entityId, draggable)
  self.ScriptedEntityTweener:Play(self.Properties.DropTargetHighlight, 0.25, {
    opacity = 0,
    ease = "QuadOut",
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.Properties.DropTargetHighlight, false)
    end
  })
end
function ContainerAreaDropTarget:OnDrop(draggable)
  if self.Properties.PlayerInventory then
    CommonFunctions:OnInventoryDrop(draggable, 0)
  else
    CommonFunctions:OnContainerDrop(draggable, 0, self.containerId, self.isLootDrop)
  end
end
return ContainerAreaDropTarget
