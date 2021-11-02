local CommonFunctions = RequireScript("LyShineUI.CommonDragDrop")
local TradeAreaDropTarget = {
  Properties = {
    DropTargetHighlight = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TradeAreaDropTarget)
function TradeAreaDropTarget:OnInit()
  BaseElement.OnInit(self)
  self.dropTargetHandler = UiDropTargetNotificationBus.Connect(self, self.entityId)
end
function TradeAreaDropTarget:OnShutdown()
  self.dropTargetHandler:Disconnect()
end
function TradeAreaDropTarget:SetCallback(callback, table)
  self.callback = callback
  self.callbackTable = table
end
function TradeAreaDropTarget:OnDropHoverStart(draggable)
  CommonFunctions:OnDropHoverStart(self.entityId, draggable)
  if self.Properties.DropTargetHighlight:IsValid() then
    UiElementBus.Event.SetIsEnabled(self.Properties.DropTargetHighlight, true)
    self.ScriptedEntityTweener:Play(self.Properties.DropTargetHighlight, 0.15, {opacity = 1, ease = "QuadOut"})
  end
end
function TradeAreaDropTarget:OnDropHoverEnd(draggable)
  CommonFunctions:OnDropHoverEnd(self.entityId, draggable)
  if self.Properties.DropTargetHighlight:IsValid() then
    self.ScriptedEntityTweener:Play(self.Properties.DropTargetHighlight, 0.25, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.Properties.DropTargetHighlight, false)
      end
    })
  end
end
function TradeAreaDropTarget:OnDrop(draggable)
  if not CommonFunctions:IsValidDrop(draggable) then
    return
  end
  if self.callback ~= nil and self.callbackTable ~= nil then
    local draggableData = CommonFunctions:GetDraggableData()
    self.callback(self.callbackTable, draggableData.sourceContainerId, draggableData.sourceSlotId, draggableData.containerType, draggableData.stackSize)
  end
end
return TradeAreaDropTarget
