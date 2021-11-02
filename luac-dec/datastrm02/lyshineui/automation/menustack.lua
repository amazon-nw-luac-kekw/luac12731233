local Logger = RequireScript("LyShineUI.Automation.Logger")
local DataLayer = RequireScript("LyShineUI.UiDataLayer")
local MenuStack = {
  AlwaysVerifyState = false,
  AlwaysVerifyScreen = false,
  WaitForVerify = false,
  Initialized = false,
  ProcessTimer = 0,
  ProcessInputInterval = 0.25
}
local Stack = {}
local ExecutionQueue = {}
local CurrentOperation
local function Log(msg)
  Logger:Log("[MenuStack] " .. tostring(msg))
end
local function VerifyState_Internal(forced)
  if MenuStack.AlwaysVerifyState or forced then
    local expectedState = 0
    if not MenuStack:IsEmpty() then
      local menu = MenuStack:Peek()
      if not menu.state then
        Log("Warning: Udefined state when verifing " .. menu.name)
        return false
      end
      expectedState = menu.state
    end
    local currentState = LyShineManagerBus.Broadcast.GetCurrentState()
    local verified = currentState == expectedState
    if not verified and MenuStack.AlwaysVerifyState and not forced then
      Log("Warning: UI is in an incorrect state, expected " .. expectedState .. ", got: " .. currentState)
    end
    return verified
  end
  return true
end
local function VerifyScreen_Internal(forced)
  if (MenuStack.AlwaysVerifyScreen or forced) and not MenuStack:IsEmpty() then
    local openedScreen = MenuStack:Peek().name
    local verified = MenuStack:IsScreenOpen(openedScreen)
    if not verified and MenuStack.AlwaysVerifyScreen and not forced then
      Log("Warning: Expected UI screen " .. openedScreen .. " not opened")
    end
    return verified
  end
  return true
end
local function Verify_Internal()
  return VerifyState_Internal(false) and VerifyScreen_Internal(false)
end
function MenuStack:VerifyState()
  return VerifyState_Internal(true)
end
function MenuStack:VerifyScreen()
  return VerifyScreen_Internal(true)
end
function MenuStack:IsScreenOpen(screen)
  return DataLayer:IsScreenOpen(screen)
end
function MenuStack:Init()
  if not self.Initialized then
    self.Initialized = true
    self.TickHandler = TickBus.Connect(self)
  end
end
function MenuStack:Shutdown()
  self.Initialized = false
  if self.TickHandler then
    self.TickHandler:Disconnect()
    self.TickHandler = nil
  end
end
local function ProcessQueue(verified)
  if (CurrentOperation == nil or coroutine.status(CurrentOperation) == "dead") and 0 < #ExecutionQueue and verified then
    CurrentOperation = table.remove(ExecutionQueue)
  end
  if CurrentOperation and coroutine.status(CurrentOperation) ~= "dead" then
    coroutine.resume(CurrentOperation)
  end
end
local function AddToQueue(operation)
  if operation then
    table.insert(ExecutionQueue, 1, coroutine.create(operation))
  else
    table.insert(ExecutionQueue, 1, nil)
  end
end
function MenuStack:OnTick(delta)
  local verified = Verify_Internal()
  if not self.WaitForVerify then
    if self.ProcessTimer >= self.ProcessInputInterval then
      verified = true
      self.ProcessTimer = self.ProcessTimer - self.ProcessInputInterval
    else
      self.ProcessTimer = self.ProcessTimer + delta
    end
  end
  ProcessQueue(verified)
end
function MenuStack:Push(openFunction, menuName, closeFunction, uiState)
  if menuName == nil then
    error("Error: Invalid item pushed to menu stack!")
  end
  local menu = {
    name = menuName,
    closeFunction = closeFunction,
    state = uiState
  }
  table.insert(Stack, menu)
  AddToQueue(openFunction)
end
function MenuStack:Swap(openFunction, menuName, closeFunction, uiState)
  if menuName == nil then
    error("Error: Invalid item pushed to menu stack!")
  end
  if self:IsEmpty() then
    self:Push(openFunction, menuName, closeFunction, uiState)
  else
    Stack[self:Count()] = {
      name = menuName,
      closeFunction = closeFunction,
      state = uiState
    }
    AddToQueue(openFunction)
  end
end
function MenuStack:Pop()
  local menu = table.remove(Stack)
  AddToQueue(function()
    Log("Info: Closing " .. menu.name)
    if menu.closeFunction ~= nil then
      menu.closeFunction()
    end
  end)
end
function MenuStack:Peek()
  return Stack[self:Count()]
end
function MenuStack:Count()
  return #Stack
end
function MenuStack:PopUntil(menuName, keepOnTop)
  while not self:IsEmpty() do
    local menu = self:Peek()
    if menu.name == menuName then
      if not keepOnTop then
        self:Pop()
      end
      return
    end
    self:Pop()
  end
  Log("Warning: Stack is empty and " .. menuName .. " was not closed!")
end
function MenuStack:Clear()
  while not self:IsEmpty() do
    self:Pop()
  end
end
function MenuStack:IsOnStack(menuName)
  for i, v in ipairs(Stack) do
    if v.name == menuName then
      return true
    end
  end
  return false
end
function MenuStack:NumOnStack(menuName)
  local num = 0
  for i, v in ipairs(Stack) do
    if v.name == menuName then
      num = num + 1
    end
  end
  return num
end
function MenuStack:IsOnTop(menuName)
  return self:Peek().name == menuName
end
function MenuStack:IsEmpty()
  return self:Count() == 0
end
function MenuStack:IsProcessing()
  return 0 < #ExecutionQueue or CurrentOperation and coroutine.status(CurrentOperation) ~= "dead"
end
return MenuStack
