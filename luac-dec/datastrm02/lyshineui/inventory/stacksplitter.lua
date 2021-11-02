local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
local StackSplitter = {
  Properties = {
    SplitterFrame = {
      default = EntityId()
    },
    DraggableHolder = {
      default = EntityId()
    },
    LeaveStackItemLayout = {
      default = EntityId()
    },
    LeaveStackWeightText = {
      default = EntityId()
    },
    TakeStackWeightText = {
      default = EntityId()
    },
    WeightIcon = {
      default = EntityId()
    },
    TakeStackAmount = {
      default = EntityId()
    },
    TakeStackText = {
      default = EntityId()
    },
    TakeStackGlow = {
      default = EntityId()
    },
    Slider = {
      default = EntityId()
    }
  }
}
BaseScreen:CreateNewScreen(StackSplitter)
function StackSplitter:OnInit()
  BaseScreen.OnInit(self)
  LyShineDataLayerBus.Broadcast.SetData("Hud.StackSplitter", self.entityId)
  self.draggableSize = {width = 60, height = 60}
  self:BusConnect(UiSliderNotificationBus, self.Properties.Slider)
  self:BusConnect(UiTextInputNotificationBus, self.Properties.TakeStackAmount)
  local weightStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_CASLON,
    fontSize = 22,
    fontColor = self.UIStyle.COLOR_GRAY_60,
    fontEffect = self.UIStyle.FONT_EFFECT_DROPSHADOW
  }
  SetTextStyle(self.LeaveStackWeightText, weightStyle)
  SetTextStyle(self.TakeStackWeightText, weightStyle)
  UiImageBus.Event.SetColor(self.WeightIcon, self.UIStyle.FONT_STYLE_WEIGHT_MAX_VALUE.fontColor)
  UiImageBus.Event.SetAlpha(self.entityId, 0.5)
  self.takeStackGlowTimeline = self.ScriptedEntityTweener:TimelineCreate()
  self.takeStackGlowTimeline:Add(self.TakeStackGlow, 0.55, {opacity = 0.4, ease = "QuadInOut"})
  self.takeStackGlowTimeline:Add(self.TakeStackGlow, 1, {
    opacity = 0.14,
    ease = "QuadInOut",
    onComplete = function()
      self.takeStackGlowTimeline:Play(0)
    end
  })
end
function StackSplitter:OnShutdown()
  self.ScriptedEntityTweener:TimelineDestroy(self.takeStackGlowTimeline)
end
function StackSplitter:ItemUpdateDragData(entityId)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.StackSize", self.stackSize)
end
function StackSplitter:UpdateTakeStackValue(value)
  value = math.floor(value + 0.5)
  local maxQuantity = self:GetMaxQuantity()
  UiTextInputBus.Event.SetText(self.Properties.TakeStackAmount, value)
  self:UpdateWeightText(maxQuantity, value)
  self.clonedTable.ItemLayout:SetQuantity(value)
  self.LeaveStackItemLayout:SetQuantity(maxQuantity - value)
  self.stackSize = value
end
function StackSplitter:UpdateWeightText(maxQuantity, stackSize)
  local takeStackWeight = self.maxWeight / maxQuantity * stackSize
  local takeWeightText = GetFormattedNumber(takeStackWeight / 10, 1)
  local leaveWeightText = GetFormattedNumber((self.maxWeight - takeStackWeight) / 10, 1)
  UiTextBus.Event.SetText(self.Properties.TakeStackWeightText, takeWeightText)
  UiTextBus.Event.SetText(self.Properties.LeaveStackWeightText, leaveWeightText)
  self:SetContainerWeightData(takeStackWeight)
end
function StackSplitter:OnTextInputChange(text)
  if text == "" then
    return
  end
  local value = math.floor(tonumber(text) or 0)
  value = math.max(1, math.min(self:GetMaxQuantity(), value))
  self:UpdateTakeStackValue(value)
  self.Slider:SetSliderValue(value)
end
function StackSplitter:OnSliderValueChanging(value)
  self:OnSliderValueChanged(value)
end
function StackSplitter:OnSliderValueChanged(value)
  self:UpdateTakeStackValue(value)
end
function StackSplitter:GetMaxQuantity()
  if not self.original or not self.original.ItemLayout.mItemData_quantity then
    return 0
  end
  return self.original.ItemLayout.mItemData_quantity
end
function StackSplitter:Invoke(draggable)
  local children = UiElementBus.Event.GetChildren(self.Properties.DraggableHolder)
  for i = 1, #children do
    UiElementBus.Event.DestroyElement(children[i])
  end
  self.original = draggable
  local maxQuantity = self:GetMaxQuantity()
  if maxQuantity <= 1 then
    return
  end
  local remainSize = math.floor(maxQuantity / 2)
  local newStackSize = maxQuantity - remainSize
  UiTextInputBus.Event.SetText(self.Properties.TakeStackAmount, newStackSize)
  self:SetupDataPaths(self.original.ItemLayout)
  self.currentMode = self.original.ItemLayout.mCurrentMode
  self.maxWeight = self.original.ItemLayout:GetTooltipDisplayInfo().weight
  self:UpdateWeightText(maxQuantity, newStackSize)
  UiSliderBus.Event.SetMinValue(self.Properties.Slider, 1)
  self.Slider:SetMaxValue(maxQuantity)
  self.Slider:SetSliderValue(newStackSize)
  local canvasSize = UiCanvasBus.Event.GetCanvasSize(self.canvasId)
  local draggableRect = UiTransformBus.Event.GetViewportSpaceRect(draggable.entityId)
  local left = draggableRect:GetCenterX() - draggableRect:GetWidth() / 2
  local top = draggableRect:GetCenterY() - draggableRect:GetHeight() / 2
  local popupRect = UiTransformBus.Event.GetViewportSpaceRect(self.SplitterFrame)
  local popupSize = {
    x = popupRect:GetWidth(),
    y = popupRect:GetHeight()
  }
  local minimumEdgeMargin = 12
  local leaveStackRect = UiTransformBus.Event.GetViewportSpaceRect(self.Properties.LeaveStackItemLayout)
  local leaveStackOffset = {
    x = leaveStackRect:GetCenterX() - leaveStackRect:GetWidth() / 2 - (popupRect:GetCenterX() - popupSize.x / 2),
    y = leaveStackRect:GetCenterY() - leaveStackRect:GetHeight() / 2 - (popupRect:GetCenterY() - popupSize.y / 2)
  }
  local x = Math.Clamp(left - leaveStackOffset.x, 0, canvasSize.x - popupSize.x - minimumEdgeMargin)
  local y = Math.Clamp(top - leaveStackOffset.y, 0, canvasSize.y - popupSize.y - minimumEdgeMargin)
  UiTransformBus.Event.SetLocalPosition(self.Properties.SplitterFrame, Vector2(x, y))
  UiCanvasBus.Event.SetEnabled(self.canvasId, true)
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  local newEntityId = UiCanvasBus.Event.CloneElement(self.canvasId, self.original.entityId, self.Properties.DraggableHolder, EntityId())
  if newEntityId:IsValid() then
    self.clonedTable = self.registrar:GetEntityTable(newEntityId)
    self.clonedTable.ItemLayout:SetItemByDescriptor(self.original.ItemLayout.mItemData_itemDescriptor)
    Merge(self.clonedTable.ItemLayout, self.original.ItemLayout, false, true, false)
    self.clonedTable:SetIsStackSplitClone(self.original)
    self.clonedTable.ItemLayout:SetQuantity(newStackSize)
    self.clonedTable.ItemLayout:SetQuantityEnabled(false)
    local draggablePos = UiTransformBus.Event.GetViewportPosition(self.Properties.DraggableHolder)
    local offsets = UiOffsets(0, 0, self.draggableSize.width, self.draggableSize.height)
    UiTransform2dBus.Event.SetOffsets(newEntityId, offsets)
    UiTransform2dBus.Event.SetAnchorsScript(newEntityId, UiAnchors(0, 0, 0, 0))
    UiInteractableBus.Event.SetIsHandlingEvents(draggable.entityId, false)
    local itemDescriptor = self.clonedTable.ItemLayout.mItemData_itemDescriptor
    if itemDescriptor ~= nil then
      self.LeaveStackItemLayout:SetItemByDescriptor(itemDescriptor)
      self.LeaveStackItemLayout:SetQuantityEnabled(true)
      self.LeaveStackItemLayout:SetQuantity(remainSize)
    end
  end
  self.takeStackGlowTimeline:Play(0)
end
function StackSplitter:SetupDataPaths(itemLayout)
  if not self.dataPaths then
    self.dataPaths = {
      [itemLayout.MODE_TYPE_EQUIPPED] = "Hud.StackSplitter.EquippedStackWeight",
      [itemLayout.MODE_TYPE_CONTAINER] = "Hud.StackSplitter.ContainerStackWeight",
      [itemLayout.MODE_TYPE_INVENTORY] = "Hud.StackSplitter.InventoryStackWeight"
    }
  end
end
function StackSplitter:SetContainerWeightData(value)
  if not self.dataPaths then
    return
  end
  local dataPath = self.dataPaths[self.currentMode]
  if dataPath then
    LyShineDataLayerBus.Broadcast.SetData(dataPath, value)
  end
end
function StackSplitter:Hide()
  if self.original then
    UiInteractableBus.Event.SetIsHandlingEvents(self.original.entityId, true)
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  self:SetContainerWeightData(0)
  self.takeStackGlowTimeline:Stop()
end
function StackSplitter:OnClose()
  self:Hide()
end
return StackSplitter
