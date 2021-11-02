local BaseScreen = {screenHandler = nil}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(BaseScreen)
function BaseScreen:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self:BusConnect(UiCanvasNotificationBus, self.canvasId)
  self:BusConnect(LyShineManagerNotificationBus, self.canvasId)
  self.name = UiCanvasBus.Event.GetCanvasName(self.canvasId)
  self:OnConfigChanged()
  self:BusConnect(ConfigSystemEventBus)
end
function BaseScreen:OnConfigChanged()
  if ConfigProviderEventBus.Broadcast.GetBool("UIFeatures.enable-automation") and not self.screenHandler then
    self.screenHandler = DynamicBus[self.name].Connect(self.entityId, self)
  end
end
function BaseScreen:GetTable()
  return self
end
function BaseScreen:OnShutdown()
  if self.screenHandler then
    DynamicBus[self.name].Disconnect(self.entityId, self)
    self.screenHandler = nil
  end
  if self.OnScreenShutdown ~= nil then
    self:OnScreenShutdown()
  end
end
function BaseScreen:OnAction(entityId, action)
  local canvasName = UiCanvasBus.Event.GetCanvasName(self.canvasId)
  local entityName = UiElementBus.Event.GetName(entityId)
  local actionStr = string.format("%s, entity %s, onAction: %s", canvasName, entityName, action)
  self.dataLayer:Call(1600008420, actionStr)
  if string.find(action, ":") ~= nil then
    local actionSplitTable = StringSplit(action, ":")
    local actionScope = actionSplitTable[1]
    local actionFunction = actionSplitTable[2]
    local scopeTable
    if actionScope == "self" then
      scopeTable = self
    elseif actionScope == "entity" then
      scopeTable = self.registrar:GetEntityTable(entityId)
    elseif actionScope == "entityParent" then
      local entityParentId = UiElementBus.Event.GetParent(entityId)
      scopeTable = self.registrar:GetEntityTable(entityParentId)
    elseif actionScope == "ancestor" then
      local ancestorId = entityId
      while ancestorId:IsValid() do
        scopeTable = self.registrar:GetEntityTable(ancestorId)
        if scopeTable and type(scopeTable[actionFunction]) == "function" then
          break
        end
        ancestorId = UiElementBus.Event.GetParent(ancestorId)
      end
    else
      Log("BaseScreen.lua OnAction() ERROR - actionScope not found: " .. actionScope)
      return false
    end
    if scopeTable ~= nil and type(scopeTable[actionFunction]) == "function" then
      scopeTable[actionFunction](scopeTable, entityId)
      return true
    else
      local entityName = UiElementBus.Event.GetName(entityId)
      Log("BaseScreen.lua OnAction() ERROR - function not found: [" .. action .. "], entityName: [" .. tostring(entityName) .. "]")
      return false
    end
  end
  return false
end
function BaseScreen:CloneElement(sourceEntity, parentEntity, startEnabled)
  return CloneUiElement(self.canvasId, self.registrar, sourceEntity, parentEntity, startEnabled)
end
function BaseScreen:CreateNewScreen(newScreen)
  Merge(newScreen, BaseScreen, true)
end
return BaseScreen
