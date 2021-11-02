local ClickRecognizer = {
  doubleClickTimeTolerance = 0.5,
  singleClickTimeTolerance = 0.3,
  timeSinceLastClick = 0,
  timeClickDown = 0,
  lastClickedEntity = EntityId(),
  invalidEntityId = EntityId(),
  isCurrentlyClicking = false,
  isLeftMouseClick = false,
  isRightMouseClick = false,
  doubleClickMovementTolerance = 1000
}
function ClickRecognizer:OnActivate(callingSelf, onPressedActionName, onReleasedActionName, onDoubleClickFn, onRightClickFn, onClickFn)
  if not self.callerData then
    self.callerData = {}
    self.notificationHandlers = {}
  end
  if #self.notificationHandlers == 0 then
    self.notificationHandlers[#self.notificationHandlers + 1] = TickBus.Connect(self)
    self.notificationHandlers[#self.notificationHandlers + 1] = CursorNotificationBus.Connect(self)
  end
  local canvasNotificationHandler = UiCanvasNotificationBus.Connect(self, callingSelf.canvasId)
  local actionNames = {}
  actionNames[onPressedActionName] = self.OnPressed
  actionNames[onReleasedActionName] = self.OnReleased
  self.callerData[tostring(callingSelf.canvasId)] = {
    actionNames = actionNames,
    callingSelf = callingSelf,
    onDoubleClickFn = onDoubleClickFn,
    onRightClickFn = onRightClickFn,
    onClickFn = onClickFn,
    canvasNotificationHandler = canvasNotificationHandler
  }
end
function ClickRecognizer:OnDeactivate(callingSelf)
  local callerData = self.callerData[tostring(callingSelf.canvasId)]
  if callerData then
    callerData.canvasNotificationHandler:Disconnect()
    self.callerData[tostring(callingSelf.canvasId)] = nil
  end
  local isCallerDataEmpty = true
  for k, v in pairs(self.callerData) do
    isCallerDataEmpty = false
    break
  end
  if isCallerDataEmpty then
    for index, handler in ipairs(self.notificationHandlers) do
      handler:Disconnect()
    end
    ClearTable(self.notificationHandlers)
  end
end
function ClickRecognizer:GetCallerData(entityId)
  local canvasId = UiElementBus.Event.GetCanvas(entityId)
  return self.callerData[tostring(canvasId)]
end
function ClickRecognizer:OnTick(deltaTime, timePoint)
  if self.isCurrentlyClicking then
    self.timeClickDown = self.timeClickDown + deltaTime
    local screenPos = CursorBus.Broadcast.GetCursorPosition()
    self.cursorMovementDelta = self.cursorMovementDelta + self.lastCursorPos:GetDistanceSq(screenPos)
  end
  self.timeSinceLastClick = self.timeSinceLastClick + deltaTime
end
local mouseButtonLeftId = 3524587339
local mouseButtonRightId = 369457006
function ClickRecognizer:OnCursorPressed(inputName)
  self.isLeftMouseClick = inputName == mouseButtonLeftId
  self.isRightMouseClick = inputName == mouseButtonRightId
end
function ClickRecognizer:OnAction(entityId, actionName)
  local callerData = self:GetCallerData(entityId)
  local fn = callerData.actionNames[actionName]
  if fn and type(fn) == "function" then
    fn(self, entityId, actionName)
  end
end
function ClickRecognizer:OnPressed(entityId)
  self.timeClickDown = 0
  self.isCurrentlyClicking = true
  self.cursorMovementDelta = 0
  self.lastCursorPos = CursorBus.Broadcast.GetCursorPosition()
end
function ClickRecognizer:OnReleased(entityId)
  if self.lastClickedEntity == entityId and self.isLeftMouseClick and self.timeSinceLastClick < self.doubleClickTimeTolerance and self.cursorMovementDelta < self.doubleClickMovementTolerance then
    local callerData = self:GetCallerData(entityId)
    callerData.onDoubleClickFn(callerData.callingSelf, entityId)
    self.lastClickedEntity = self.invalidEntityId
    self.isCurrentlyClicking = false
    return
  end
  if self.timeClickDown <= self.singleClickTimeTolerance then
    local callerData = self:GetCallerData(entityId)
    if self.isLeftMouseClick and callerData.onClickFn then
      callerData.onClickFn(callerData.callingSelf, entityId)
    end
    if self.isRightMouseClick and callerData.onRightClickFn then
      callerData.onRightClickFn(callerData.callingSelf, entityId)
    end
  end
  self.lastClickedEntity = entityId
  self.timeSinceLastClick = 0
  self.isCurrentlyClicking = false
end
return ClickRecognizer
