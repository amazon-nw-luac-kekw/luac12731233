local registrar = RequireScript("LyShineUI.EntityRegistrar")
local UiDataLayer = {}
UiDataLayer.currentCallbackId = 0
UiDataLayer.dataLayerCallbacks = {}
UiDataLayer.tableToCallbackIds = {}
function UiDataLayer:Activate()
  if self.dataLayerNotificationHandler == nil then
    self.dataLayerNotificationHandler = LyShineDataLayerNotificationsBus.Connect(self)
  end
end
function UiDataLayer:Deactivate()
  if self.dataLayerNotificationHandler then
    self.dataLayerNotificationHandler:Disconnect()
    self.dataLayerNotificationHandler = nil
    ClearTable(self.dataLayerCallbacks)
    ClearTable(self.tableToCallbackIds)
    self.currentCallbackId = 0
  end
end
function UiDataLayer:OnActivate()
end
function UiDataLayer:OnDeactivate()
end
function UiDataLayer:ValidateString(functionName, paramName, str)
  if str == nil or str == "" then
    assert(false, "UiDataLayer:" .. functionName .. " called with invalid parameter [" .. paramName .. "]")
  end
end
function UiDataLayer:OnCall(callingSelf, path, callbackFunction)
  self:RegisterAndExecuteCallback(callingSelf, path, callbackFunction)
end
function UiDataLayer:OnChange(callingSelf, path, callbackFunction)
  self:RegisterAndExecuteObserver(callingSelf, path, callbackFunction)
end
function UiDataLayer:GetNode(path)
  return self:GetDataNode(path)
end
function UiDataLayer:Call(pathCrc, param1, param2, param3)
  local nodeId
  if param3 then
    nodeId = LyShineDataLayerBus.Broadcast.CallThree(pathCrc, param1, param2, param3)
  elseif param2 then
    nodeId = LyShineDataLayerBus.Broadcast.CallTwo(pathCrc, param1, param2)
  elseif param1 then
    nodeId = LyShineDataLayerBus.Broadcast.CallOne(pathCrc, param1)
  else
    nodeId = LyShineDataLayerBus.Broadcast.Call(pathCrc)
  end
  if not nodeId then
    return nil
  end
  return self:GetDataNodeTable(nodeId)
end
function UiDataLayer:CallUnsafe(pathCrc, param1, param2, param3)
  local node = self:Call(pathCrc, param1, param2, param3)
  if node then
    return node:GetData()
  else
    return nil
  end
end
function UiDataLayer:ClearDataTree(pathCrc)
  LyShineDataLayerBus.Broadcast.ClearDataTree(pathCrc)
end
function UiDataLayer:RegisterAndExecuteCallback(callingSelf, path, callbackFunction)
  self:RegisterObserver(callingSelf, path, callbackFunction, true, true)
end
function UiDataLayer:RegisterAndExecuteDataCallback(callingSelf, path, callbackFunction)
  self:RegisterObserver(callingSelf, path, callbackFunction, true, true, true)
end
function UiDataLayer:RegisterCallback(callingSelf, path, callbackFunction, callNow)
  self:RegisterObserver(callingSelf, path, callbackFunction, true, false)
end
function UiDataLayer:RegisterDataCallback(callingSelf, path, callbackFunction, callNow)
  self:RegisterObserver(callingSelf, path, callbackFunction, true, false, true)
end
function UiDataLayer:RegisterAndExecuteObserver(callingSelf, path, callbackFunction)
  self:RegisterObserver(callingSelf, path, callbackFunction, false, true)
end
function UiDataLayer:RegisterAndExecuteDataObserver(callingSelf, path, callbackFunction)
  self:RegisterObserver(callingSelf, path, callbackFunction, false, true, true)
end
function UiDataLayer:RegisterDataObserver(callingSelf, path, callbackFunction)
  self:RegisterObserver(callingSelf, path, callbackFunction, false, false, true)
end
function UiDataLayer:RegisterObserver(callingSelf, path, callbackFunction, alwaysNotify, callNow, returnRawData)
  local callbackUuid = self:CreateCallback(callingSelf, callbackFunction)
  LyShineDataLayerBus.Broadcast.RegisterObserver(path, callbackUuid, alwaysNotify == true, returnRawData == true)
  if not self.tableToCallbackIds[callingSelf] then
    self.tableToCallbackIds[callingSelf] = {}
  end
  if self.tableToCallbackIds[callingSelf][path] then
    self:UnregisterObserver(callingSelf, path)
  end
  self.tableToCallbackIds[callingSelf][path] = callbackUuid
  if callNow then
    local data
    if returnRawData then
      data = LyShineDataLayerBus.Broadcast.GetDataFromNode(path)
    else
      data = LyShineDataLayerBus.Broadcast.GetData(path)
    end
    self:CallCallback(callbackUuid, data, returnRawData)
  end
end
function UiDataLayer:UnregisterObservers(callingSelf)
  local registeredObservers = self.tableToCallbackIds[callingSelf]
  if registeredObservers then
    for path, _ in pairs(registeredObservers) do
      self:UnregisterObserver(callingSelf, path)
    end
  end
end
function UiDataLayer:UnregisterObserver(callingSelf, path)
  if not self.tableToCallbackIds[callingSelf] or not self.tableToCallbackIds[callingSelf][path] then
    return
  end
  local callbackUuid = self.tableToCallbackIds[callingSelf][path]
  if callbackUuid then
    LyShineDataLayerBus.Broadcast.UnregisterObserver(path, callbackUuid)
    self.tableToCallbackIds[callingSelf][path] = nil
  end
end
function UiDataLayer:GetDataNode(path)
  local dataNodeId = LyShineDataLayerBus.Broadcast.GetData(path)
  if not dataNodeId or dataNodeId == 0 then
    return nil
  else
    return self:GetDataNodeTable(dataNodeId)
  end
end
function UiDataLayer:GetData(path)
  return self:GetDataFromNode(path)
end
function UiDataLayer:GetDataFromNode(path)
  return LyShineDataLayerBus.Broadcast.GetDataFromNode(path)
end
function UiDataLayer:SetScreenNameOverride(screenName, override)
  g_screenNameOverrides[screenName] = override
end
function UiDataLayer:GetScreenNameOverride(screenName)
  return g_screenNameOverrides[screenName] or screenName
end
function UiDataLayer:GetRequestScreenDatapath(screenName)
  return "Hud.LocalPlayer.Screens." .. screenName .. ".SetScreenEnabled"
end
function UiDataLayer:GetIsScreenOpenDatapath(screenName)
  return "Hud.LocalPlayer.Screens." .. screenName .. ".IsScreenEnabled"
end
function UiDataLayer:GetEntityTableDatapath(entityIdentifier)
  return "Datalayer.EntityTables." .. entityIdentifier
end
function UiDataLayer:RegisterEntity(entityIdentifier, entityId)
  if not entityId and not entityId:IsValid() then
    Debug.Log("Trying to register " .. entityIdentifier .. " with invalid entityId " .. tostring(entityId))
    return
  end
  LyShineDataLayerBus.Broadcast.SetData(self:GetEntityTableDatapath(entityIdentifier), entityId)
end
function UiDataLayer:UnregisterEntity(entityIdentifier)
  LyShineDataLayerBus.Broadcast.SetData(self:GetEntityTableDatapath(entityIdentifier), EntityId())
end
function UiDataLayer:GetEntityTable(entityIdentifier)
  local screenEntityId = self:GetDataFromNode(self:GetEntityTableDatapath(entityIdentifier))
  if not screenEntityId then
    return nil
  end
  return registrar:GetEntityTable(screenEntityId)
end
function UiDataLayer:RegisterOpenEvent(screenName, canvasId)
  if not screenName or screenName == "" then
    Debug.Log("WARNING: UiDataLayer:RegisterOpenEvent, failed. Invalid screenName")
  else
    self:RegisterForOpen(self:GetRequestScreenDatapath(screenName), canvasId)
    return screenName
  end
end
function UiDataLayer:RegisterOnScreenOpen(screenName, canvasId)
  self:RegisterForOpen(self:GetIsScreenOpenDatapath(screenName), canvasId)
end
function UiDataLayer:DeregisterOnScreenOpen(screenName)
  self:UnregisterObserver(self, self:GetIsScreenOpenDatapath(screenName))
end
function UiDataLayer:RegisterForOpen(dataPath, canvasId)
  self:RegisterCallback(self, dataPath, function(self, dataNode)
    local shouldShow = dataNode:GetData()
    if shouldShow then
      LyShineManagerBus.Broadcast.TryShowById(canvasId)
    else
      LyShineManagerBus.Broadcast.TryHideById(canvasId)
    end
  end)
end
function UiDataLayer:IsScreenOpen(screenName)
  return self:GetDataNode(self:GetIsScreenOpenDatapath(screenName)):GetData()
end
function UiDataLayer:SetScreenEnabled(screenName, enabled)
  screenName = self:GetScreenNameOverride(screenName)
  if enabled == nil then
    Debug.Log("UiDataLayer:SetScreenEnabled - nil 'enabled' value passed")
  end
  LyShineDataLayerBus.Broadcast.SetData(self:GetRequestScreenDatapath(screenName), enabled)
end
function UiDataLayer:CreateCallback(callingSelf, fnCallback)
  self.currentCallbackId = self.currentCallbackId + 1
  local callbackId = self.currentCallbackId
  self.dataLayerCallbacks[callbackId] = {callingSelf, fnCallback}
  return callbackId
end
function UiDataLayer:RemoveCallback(callbackId)
  self.dataLayerCallbacks[callbackId] = nil
end
function UiDataLayer:CallCallback(callbackId, data, returnRawData)
  local callbackDef = self.dataLayerCallbacks[callbackId]
  if callbackDef ~= nil then
    local callbackSelf = callbackDef[1]
    local callbackFunction = callbackDef[2]
    local toReturn
    if returnRawData then
      toReturn = data
    else
      toReturn = self:GetDataNodeTable(data)
    end
    callbackFunction(callbackSelf, toReturn)
  end
end
function UiDataLayer:CallDataCallback(callbackId, data)
  self:CallCallback(callbackId, data, true)
end
function UiDataLayer:LogPath(path)
  local dataNode = self:GetDataNode(path)
  if dataNode then
    self:Log(dataNode, path)
  end
end
function UiDataLayer:Log(dataNode, name, depth)
  if depth == nil then
    depth = 0
  end
  local prefix = " "
  local toPrint = ""
  for i = 0, depth do
    toPrint = toPrint .. prefix
  end
  if #dataNode:GetChildren() == 0 then
    toPrint = toPrint .. tostring(name) .. " = " .. tostring(dataNode:GetData())
    Debug.Log(toPrint)
  else
    local names = dataNode:GetChildrenNames()
    Debug.Log(toPrint .. name .. " = {")
    for index, node in ipairs(dataNode:GetChildren()) do
      self:Log(node, names[index], depth + 1)
    end
    Debug.Log(toPrint .. "}")
  end
end
local NodeTableGetData = function(tableSelf)
  local data = DataLayerNodeBus.Event.GetData(tableSelf.dataNodeId)
  return data
end
local NodeTableGetChildren = function(tableSelf)
  local childNames = DataLayerNodeBus.Event.GetChildren(tableSelf.dataNodeId)
  local children = {}
  for i = 1, #childNames do
    local childName = childNames[i]
    children[i] = tableSelf[childName]
  end
  return children
end
local NodeTableGetChildrenNames = function(tableSelf)
  local childNames = DataLayerNodeBus.Event.GetChildren(tableSelf.dataNodeId)
  return childNames
end
local NodeTableMetaTable = {
  __index = function(t, key)
    local childDataNodeId = DataLayerNodeBus.Event.GetChild(t.dataNodeId, key)
    if not childDataNodeId or childDataNodeId == 0 then
      local fullPath = DataLayerNodeBus.Event.GetFullPath(t.dataNodeId)
      if fullPath and key then
        local childPath = fullPath .. "." .. key
        Debug.Log("Perf warning, dynamically creating child node " .. childPath)
        Debug.Log(debug.traceback())
        childDataNodeId = LyShineDataLayerBus.Broadcast.GetData(childPath)
      end
    end
    if not childDataNodeId or childDataNodeId == 0 then
      return nil
    else
      return t.dataLayerTable:GetDataNodeTable(childDataNodeId)
    end
  end
}
function UiDataLayer:GetDataNodeTable(dataNodeId)
  local dataNodeTable = {
    dataLayerTable = self,
    dataNodeId = dataNodeId,
    GetData = NodeTableGetData,
    GetChildren = NodeTableGetChildren,
    GetChildrenNames = NodeTableGetChildrenNames
  }
  setmetatable(dataNodeTable, NodeTableMetaTable)
  return dataNodeTable
end
function UiDataLayer:RegisterMultiObserver(callingSelf, paths, callbackFunction)
  local returnedData = {}
  for i = 1, #paths do
    local path = paths[i]
    self:RegisterDataObserver(callingSelf, path, function(self, cbData)
      returnedData[i] = cbData
      callbackFunction(callingSelf, returnedData)
    end)
  end
end
function UiDataLayer:RegisterMultiCallback(callingSelf, paths, callbackFunction)
  local returnedData = {}
  for i = 1, #paths do
    local path = paths[i]
    self:RegisterDataCallback(callingSelf, path, function(self, cbData)
      returnedData[i] = cbData
      callbackFunction(callingSelf, returnedData)
    end)
  end
end
function UiDataLayer:RegisterAndExecuteMultiObserver(callingSelf, paths, callbackFunction)
  local returnedData = {}
  for i = 1, #paths do
    local path = paths[i]
    self:RegisterAndExecuteDataObserver(callingSelf, path, function(self, cbData)
      returnedData[i] = cbData
      callbackFunction(callingSelf, returnedData)
    end)
  end
end
function UiDataLayer:RegisterAndExecuteMultiCallback(callingSelf, paths, callbackFunction)
  local returnedData = {}
  for i = 1, #paths do
    local path = paths[i]
    self:RegisterAndExecuteDataCallback(callingSelf, path, function(self, cbData)
      returnedData[i] = cbData
      callbackFunction(callingSelf, returnedData)
    end)
  end
end
return UiDataLayer
