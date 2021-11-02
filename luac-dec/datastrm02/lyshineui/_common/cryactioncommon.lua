local CryActionCommon = {}
function CryActionCommon:OnActivate()
  self.cryActionHandlers = {}
  self.actionNameToCallbacks = {}
end
function CryActionCommon:OnDeactivate()
  if self.cryActionHandlers then
    for _, handler in pairs(self.cryActionHandlers) do
      handler:Disconnect()
    end
    ClearTable(self.cryActionHandlers)
  end
  if self.actionNameToCallbacks then
    ClearTable(self.actionNameToCallbacks)
  end
end
function CryActionCommon:RegisterActionListener(callerSelf, actionName, priority, callerFunction)
  local sortedCallbacks = self.actionNameToCallbacks[actionName]
  if not sortedCallbacks then
    sortedCallbacks = {}
    self.actionNameToCallbacks[actionName] = sortedCallbacks
  end
  self:UnregisterActionListener(callerSelf, actionName)
  local callbackData = {
    priority = priority,
    callerSelf = callerSelf,
    callerFunction = callerFunction
  }
  table.insert(sortedCallbacks, callbackData)
  table.sort(sortedCallbacks, function(a, b)
    return a.priority > b.priority
  end)
  if not self.cryActionHandlers[actionName] then
    self.cryActionHandlers[actionName] = CryActionNotificationsBus.Connect(self, actionName)
  end
end
function CryActionCommon:UnregisterActionListener(callerSelf, actionName)
  local sortedCallbacks = self.actionNameToCallbacks[actionName]
  if not sortedCallbacks then
    return
  end
  for index, callbackData in ipairs(sortedCallbacks) do
    if callbackData.callerSelf == callerSelf then
      table.remove(sortedCallbacks, index)
      if #sortedCallbacks == 0 then
        local handler = self.cryActionHandlers[actionName]
        handler:Disconnect()
        self.cryActionHandlers[actionName] = nil
        self.actionNameToCallbacks[actionName] = nil
      end
      break
    end
  end
end
function CryActionCommon:OnCryAction(actionName, value)
  local sortedCallbacks = self.actionNameToCallbacks[actionName]
  for _, callbackData in pairs(sortedCallbacks) do
    local inputHandled = callbackData.callerFunction(callbackData.callerSelf, actionName, value)
    if inputHandled then
      return
    end
  end
end
return CryActionCommon
