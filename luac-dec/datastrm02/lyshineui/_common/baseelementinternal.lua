local BaseElement = {
  notificationHandlers = {}
}
local style = RequireScript("LyShineUI._Common.UIStyle")
local audioHelper = RequireScript("LyShineUI.AudioEvents")
local tweener = RequireScript("Scripts.ScriptedEntityTweener.ScriptedEntityTweener")
local registrar = RequireScript("LyShineUI.EntityRegistrar")
function BaseElement:OnActivate()
  self:BusConnect(UiInitializationBus, self.entityId)
  self.UIStyle = style
  self.audioHelper = audioHelper
  self.ScriptedEntityTweener = tweener
  self.registrar = registrar
  self.dataLayer = RequireScript("LyShineUI.UiDataLayer")
  self.registrar:RegisterEntity(self)
  local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  if canvasId and canvasId:IsValid() then
    self:InGamePostActivate()
  end
end
function BaseElement:OnInit()
end
function BaseElement:InGamePostActivate()
  if self.OnInit ~= nil then
    self:SetupTable(self, self.Properties, {})
    self:OnInit()
  end
end
function BaseElement:OnDeactivate()
  self.dataLayer:UnregisterObservers(self)
  self.registrar:UnregisterEntity(self)
  for _, handler in ipairs(self.notificationHandlers) do
    if handler.isDynamicBus then
      handler.bus.Disconnect(self.entityId, self)
    else
      handler:Disconnect()
    end
  end
  ClearTable(self.notificationHandlers)
  if self.OnShutdown ~= nil then
    self:OnShutdown()
  end
  local entityId = self.entityId
  ClearTable(self)
  self.entityId = entityId
end
function BaseElement:BusConnect(bus, param)
  if bus == nil then
    Log("Trying to connect a bus that is nil.\n" .. debug.traceback())
    return
  end
  local handler
  if bus == DynamicBus.UITickBus or bus == TickBus then
    handler = DynamicBus.UITickBus.Connect(self.entityId, self)
    handler.bus = DynamicBus.UITickBus
    handler.isDynamicBus = true
  elseif param == nil then
    handler = bus.Connect(self)
  else
    handler = bus.Connect(self, param)
  end
  table.insert(self.notificationHandlers, handler)
  return handler
end
function BaseElement:BusDisconnect(bushandler, param)
  if bushandler == nil then
    if type(self) ~= "table" then
      Log("BaseElement:BusDisconnect: Incorrectly calling BusDisconnect, did you mean to call self:BusDisconnect?\n" .. debug.traceback())
    end
    return
  end
  if bushandler.isDynamicBus then
    bushandler.bus.Disconnect(self.entityId, self)
  elseif param == nil then
    bushandler:Disconnect()
  else
    bushandler:Disconnect(param)
  end
  for index, handler in ipairs(self.notificationHandlers) do
    if handler == bushandler then
      table.remove(self.notificationHandlers, index)
      return
    end
  end
end
function BaseElement:CreateNewElement(newElement)
  Merge(newElement, BaseElement, true)
end
function BaseElement:SetupTable(parent, obj, subkeys)
  for i, variable in pairs(obj) do
    if type(variable) == "userdata" and i ~= "entityId" then
      local newtable = self.registrar:GetEntityTable(variable)
      if newtable ~= nil then
        parent[i] = newtable
      else
        parent[i] = variable
      end
    elseif type(variable) == "table" then
      parent[i] = {}
      table.insert(subkeys, i)
      self:SetupTable(parent[i], variable, subkeys)
    else
      parent[i] = variable
    end
  end
  local baseTable = getmetatable(self)
  local tableToSearch = baseTable.Properties
  for i = 1, #subkeys do
    tableToSearch = tableToSearch[subkeys[i]]
  end
  if #parent == 0 and not tableToSearch.default then
    for key, variable in pairs(tableToSearch) do
      if not obj[key] then
        parent[key] = variable.default
      end
    end
  end
  table.remove(subkeys)
end
return BaseElement
