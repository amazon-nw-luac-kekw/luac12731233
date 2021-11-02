local ItemDraggableStackSplit = {
  Properties = {
    DraggableRoot = {
      default = EntityId()
    },
    StackSplitButton = {
      default = EntityId()
    },
    TextInput = {
      default = EntityId()
    },
    HoverBG = {
      default = EntityId()
    },
    StackSplitArrow = {
      default = EntityId()
    }
  },
  originalDraggableTable = nil,
  lastOnPressedTime = nil,
  lastOnPressPos = nil,
  lastQuantity = nil,
  clonedTable = nil,
  clickToleranceMs = 350,
  dragMaxDistance = 200,
  idleTimeOutSec = 2,
  currentIdleTimeSec = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ItemDraggableStackSplit)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function ItemDraggableStackSplit:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self:BusConnect(UiInteractableNotificationBus, self.StackSplitButton)
  UiElementBus.Event.SetIsEnabled(self.StackSplitButton, false)
end
function ItemDraggableStackSplit:SetIsStackSplitClone(originalDraggableTable)
  self.isClone = true
  self.originalDraggableTable = originalDraggableTable
  self:BusConnect(UiTextInputNotificationBus, self.TextInput)
  self:BusConnect(CursorNotificationBus)
  self:BusConnect(DynamicBus.UITickBus)
  UiElementBus.Event.SetIsEnabled(self.HoverBG, true)
  self:SetCurrentQuantity(math.floor(self.originalDraggableTable.ItemLayout.mItemData_quantity / 2))
  local anchors = UiAnchors(0, 0, 1, 1)
  UiTransform2dBus.Event.SetAnchorsScript(self.StackSplitButton, anchors)
  local offsets = UiOffsets(0, 0, 0, 0)
  UiTransform2dBus.Event.SetOffsets(self.StackSplitButton, offsets)
  self.ScriptedEntityTweener:Set(self.StackSplitButton, {opacity = 0})
  UiElementBus.Event.SetIsEnabled(self.StackSplitButton, true)
  self:OnPressed()
end
function ItemDraggableStackSplit:OnCursorPressed()
  if not self:IsMouseOverDraggable() then
    self:DestroyStackSplitDraggable()
  end
end
function ItemDraggableStackSplit:OnCursorReleased()
  if self.isClone then
    self.isScrubbingQuantity = false
  end
end
function ItemDraggableStackSplit:CanStackSplit()
  return not self.isClone and self:GetMaxQuantity() > 1
end
function ItemDraggableStackSplit:OnDraggableRootHover(isHoverStart)
  if self:CanStackSplit() then
    if isHoverStart then
      self.ScriptedEntityTweener:Stop(self.StackSplitButton)
      UiElementBus.Event.SetIsEnabled(self.StackSplitButton, true)
    else
      self.checkStackSplitFade = true
      if not self.tickBusHandler then
        self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
      end
    end
  end
end
function ItemDraggableStackSplit:OnHoverStart()
  if self:CanStackSplit() then
    UiElementBus.Event.SetIsEnabled(self.HoverBG, true)
  elseif self.isClone then
    self.updateArrow = true
  end
end
function ItemDraggableStackSplit:OnHoverEnd()
  if self:CanStackSplit() then
    UiElementBus.Event.SetIsEnabled(self.HoverBG, false)
  elseif self.isClone then
    self.updateArrow = false
  end
end
function ItemDraggableStackSplit:OnPressed()
  if self.clonedTable then
    return
  end
  if not self.isClone then
    if self:GetMaxQuantity() > 1 then
      local newEntityId = UiCanvasBus.Event.CloneElement(self.canvasId, self.DraggableRoot.entityId, EntityId(), EntityId())
      if newEntityId:IsValid() then
        UiTransformBus.Event.SetScaleToDevice(newEntityId, true)
        self.clonedTable = self.registrar:GetEntityTable(newEntityId)
        Merge(self.clonedTable.ItemLayout, self.DraggableRoot.ItemLayout, false, true, false)
        self.clonedTable:SetIsStackSplitClone(self.DraggableRoot)
        local draggablePos = UiTransformBus.Event.GetViewportPosition(self.DraggableRoot.entityId)
        UiTransformBus.Event.SetViewportPosition(newEntityId, draggablePos + Vector2(-25, -15))
        self:OnStackSplitEnable(true)
      end
    end
    self.audioHelper:PlaySound(self.audioHelper.OnItemStackSplit)
  else
    self.lastOnPressedTime = timeHelpers:ServerNow()
    self.lastOnPressPos = CursorBus.Broadcast.GetCursorPosition().x
    self.lastQuantity = self:GetCurrentQuantity()
    self.isScrubbingQuantity = true
  end
end
function ItemDraggableStackSplit:OnReleased()
  if self.isClone and self.lastOnPressedTime then
    local clickDurationMs = timeHelpers:ServerNow():Subtract(self.lastOnPressedTime):ToMillisecondsUnrounded()
    if clickDurationMs <= self.clickToleranceMs then
      UiInteractableBus.Event.SetIsHandlingEvents(self.TextInput, true)
      UiCanvasBus.Event.SetActiveInteractable(self.canvasId, self.TextInput, false)
      UiTextInputBus.Event.BeginEdit(self.TextInput)
      UiTextInputBus.Event.SetSelectionRange(self.TextInput, 0, UiTextBus.Event.GetText(self.TextInput):len(), self.UIStyle.COLOR_WHITE)
    end
    self.lastOnPressedTime = nil
    self.isScrubbingQuantity = false
  end
end
function ItemDraggableStackSplit:OnTick(deltaTime)
  if self.isClone then
    if self.isScrubbingQuantity then
      local currentCursorPos = CursorBus.Broadcast.GetCursorPosition()
      local currentDistance = currentCursorPos.x - self.lastOnPressPos
      local delta = math.floor(self:GetMaxQuantity() * (currentDistance / self.dragMaxDistance))
      local currentQuantity = self:GetCurrentQuantity()
      if currentQuantity ~= self.lastQuantity + delta then
        self:SetCurrentQuantity(self.lastQuantity + delta)
      end
    elseif self:IsMouseOverDraggable() or UiInteractableBus.Event.IsHandlingEvents(self.TextInput) or g_isDragging then
      self.currentIdleTimeSec = 0
    else
      self.currentIdleTimeSec = self.currentIdleTimeSec + deltaTime
      if self.currentIdleTimeSec > self.idleTimeOutSec then
        self:DestroyStackSplitDraggable()
      end
    end
    local showArrow = self.updateArrow or self.isScrubbingQuantity
    UiElementBus.Event.SetIsEnabled(self.StackSplitArrow, showArrow)
    if showArrow then
      UiTransformBus.Event.SetViewportPosition(self.StackSplitArrow, CursorBus.Broadcast.GetCursorPosition())
    end
  elseif self.checkStackSplitFade and not self:IsMouseOverEntity(self.StackSplitButton) then
    UiElementBus.Event.SetIsEnabled(self.StackSplitButton, false)
    self.checkStackSplitFade = false
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
  end
end
function ItemDraggableStackSplit:OnStackSplitEnable(isEnabled)
  self.DraggableRoot.ItemLayout:SetDimVisible(isEnabled)
  UiInteractableBus.Event.SetIsHandlingEvents(self.StackSplitButton, not isEnabled)
  UiInteractableBus.Event.SetIsHandlingEvents(self.DraggableRoot.entityId, not isEnabled)
  if not isEnabled then
    self.DraggableRoot.ItemLayout:SetQuantity(self:GetMaxQuantity())
    self.clonedTable = nil
  end
end
function ItemDraggableStackSplit:OnShutdown()
  if self.isClone then
    self.originalDraggableTable.StackSplitter:OnStackSplitEnable(false)
  end
  if self.clonedTable then
    UiElementBus.Event.DestroyElement(self.clonedTable.entityId)
    self.clonedtable = nil
  end
end
function ItemDraggableStackSplit:DestroyStackSplitDraggable()
  self.originalDraggableTable.ItemLayout:SetQuantity(self:GetMaxQuantity())
  UiElementBus.Event.DestroyElement(self.DraggableRoot.entityId)
end
function ItemDraggableStackSplit:OnTextInputEndEdit(textInput)
  local num = tonumber(textInput)
  num = num or self:GetMaxQuantity()
  self:SetCurrentQuantity(num)
  UiInteractableBus.Event.SetIsHandlingEvents(self.TextInput, false)
end
function ItemDraggableStackSplit:GetMaxQuantity()
  if not self.DraggableRoot.ItemLayout.mItemData_quantity then
    return 0
  end
  return self.DraggableRoot.ItemLayout.mItemData_quantity
end
function ItemDraggableStackSplit:SetCurrentQuantity(num)
  local maxQuantity = self:GetMaxQuantity()
  local clampedNum = Clamp(num, 1, maxQuantity)
  local currentQuantity = self:GetCurrentQuantity()
  if clampedNum ~= currentQuantity then
    self.audioHelper:PlaySound(self.audioHelper.OnSliderChanged)
  end
  UiTextBus.Event.SetText(self.TextInput, tostring(clampedNum))
  self.originalDraggableTable.ItemLayout:SetQuantity(maxQuantity - clampedNum)
end
function ItemDraggableStackSplit:GetCurrentQuantity()
  return tonumber(UiTextBus.Event.GetText(self.TextInput)) or 0
end
function ItemDraggableStackSplit:IsMouseOverDraggable()
  return self:IsMouseOverEntity(self.DraggableRoot.entityId)
end
function ItemDraggableStackSplit:IsMouseOverEntity(entityId)
  local screenPoint = CursorBus.Broadcast.GetCursorPosition()
  local point = UiTransformBus.Event.ViewportPointToLocalPoint(entityId, screenPoint)
  if not point then
    return false
  end
  local width = UiTransform2dBus.Event.GetLocalWidth(entityId)
  local height = UiTransform2dBus.Event.GetLocalHeight(entityId)
  local padding = 15
  return point.x > -padding and point.x < width + padding and point.y > -padding and point.y < height + padding
end
return ItemDraggableStackSplit
