local GemDropTarget = {
  Properties = {}
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(GemDropTarget)
local registrar = RequireScript("LyShineUI.EntityRegistrar")
local CommonFunctions = require("LyShineUI.CommonDragDrop")
function GemDropTarget:OnInit()
  BaseElement.OnInit(self)
  self.callbacks = {}
  self.invalidDropCallbacks = {}
  self.validClasses = {}
end
function GemDropTarget:SetGemDropTargetEnabled(isEnabled)
  if self.isEnabled == isEnabled then
    return
  end
  self.isEnabled = isEnabled
  UiElementBus.Event.SetIsEnabled(self.entityId, isEnabled)
  if isEnabled then
    if not self.dropTargetHandler then
      self.dropTargetHandler = self:BusConnect(UiDropTargetNotificationBus, self.entityId)
    end
  elseif self.dropTargetHandler then
    self:BusDisconnect(self.dropTargetHandler)
    self.dropTargetHandler = nil
  end
end
function GemDropTarget:IsValid()
  if not self.isEnabled then
    return false
  end
  for class, valid in pairs(self.validClasses) do
    if valid then
      return true
    end
  end
  return false
end
function GemDropTarget:SetGemDropTargetIsValid(itemClass, isValid)
  self.validClasses[itemClass] = isValid
end
function GemDropTarget:SetCallback(itemClass, command, table)
  self.callbacks[itemClass] = {callback = command, callbackTable = table}
end
function GemDropTarget:SetOnInvalidDropCallback(itemClass, command, table)
  self.invalidDropCallbacks[itemClass] = {callback = command, callbackTable = table}
end
function GemDropTarget:OnDropHoverStart(draggable)
  if not self:IsValid() then
    return
  end
  CommonFunctions:OnDropHoverStart(self.entityId, draggable)
end
function GemDropTarget:OnDropHoverEnd(draggable)
  if not self:IsValid() then
    return
  end
  CommonFunctions:OnDropHoverEnd(self.entityId, draggable)
end
function GemDropTarget:OnDrop(draggable)
  if not self:IsValid() then
    local draggableTable = registrar:GetEntityTable(draggable)
    for itemClass, callbackInfo in pairs(self.invalidDropCallbacks) do
      if draggableTable:HasItemClass(itemClass) then
        callbackInfo.callback(callbackInfo.callbackTable)
        return
      end
    end
    return
  end
  if CommonFunctions:IsValidDrop(draggable) then
    local draggableTable = registrar:GetEntityTable(draggable)
    if draggableTable:IsSelectedForTrade() or draggableTable:IsInTradeContainer() then
      return
    end
    for itemClass, callbackInfo in pairs(self.callbacks) do
      if draggableTable:HasItemClass(itemClass) then
        callbackInfo.callback(callbackInfo.callbackTable)
        return
      end
    end
  end
end
return GemDropTarget
