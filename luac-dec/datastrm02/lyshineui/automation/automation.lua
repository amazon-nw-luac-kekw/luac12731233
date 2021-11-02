local Automation = {
  tasks = {},
  taskNumber = 0,
  currentTask = nil,
  defaultTimeout = 120
}
local InputQueue = RequireScript("LyShineUI.Automation.InputQueue")
local Logger = RequireScript("LyShineUI.Automation.Logger")
local Task = RequireScript("LyShineUI.Automation.Task")
local TaskResult = RequireScript("LyShineUI.Automation.TaskResult")
local ResultStatus = RequireScript("LyShineUI.Automation.ResultStatus")
local jsonParser = RequireScript("LyShineUI.json")
local MenuStack = RequireScript("LyShineUI.Automation.MenuStack")
local TimerHandler = RequireScript("LyShineUI.Automation.Utilities.TimerHandler")
local InventoryUtility = RequireScript("LyShineUI.Automation.Utilities.InventoryUtility")
local PopupUtility = RequireScript("LyShineUI.Automation.Utilities.PopupUtility")
local SocialUtility = RequireScript("LyShineUI.Automation.Utilities.SocialUtility")
local ChatUtility = RequireScript("LyShineUI.Automation.Utilities.ChatUtility")
local PlayerUtility = RequireScript("LyShineUI.Automation.Utilities.PlayerUtility")
function Automation:Init(entityId)
  self.entityId = entityId
  self.tasklist = {
    "CloseLegal",
    "ConnectToWorld",
    "WaitForLoad",
    "EquipAllSlots",
    "UnEquipAllSlots",
    "GroupInvite",
    "SetCharacterName",
    "ExecuteStuckChatCommand"
  }
end
function Automation:SetupAutomation(taskName, params)
  Logger:Log("Info: SetupUIAutomation for " .. taskName)
  if #self.tasks ~= 0 then
    ClearTable(self.tasks)
    self:OnShutdown()
  end
  if taskName and taskName ~= "" then
    local automationTable = require("LyShineUI.Automation.Tasks." .. taskName)
    table.insert(self.tasks, Task(taskName, automationTable, params))
    if not automationTable.timeout then
      automationTable.timeout = self.defaultTimeout
    end
  else
    Logger:Log("No task name was passed in, loading all tasks from tasklist in Automation.lua")
    for _, name in pairs(self.tasklist) do
      Logger:Log("Info: Adding Task: " .. name)
      table.insert(self.tasks, Task(name, require("LyShineUI.Automation.Tasks." .. name)))
    end
  end
  Logger:Log("Info: Number of Tasks: " .. #self.tasks)
end
function Automation:BeginAutomation()
  Logger:Log("Info: Automation begin")
  self.tickHandler = TickBus.Connect(self)
  self.taskNumber = 1
  MenuStack:Init()
  TimerHandler:Init()
end
function Automation:ResetAutomation()
  Logger:Log("Info: Automation reset")
  if self.tasks[self.taskNumber] then
    self.tasks[self.taskNumber].table:Cleanup()
  end
  self.taskNumber = 0
  self.currentTask = nil
  MenuStack:Clear()
end
function Automation:CanProcess()
  return InputQueue:IsQueueEmpty() and not MenuStack:IsProcessing()
end
function Automation:PrepareData()
  Logger:Log("Info: Preparing utilities")
  local isInMainMenu = GameRequestsBus.Broadcast.IsInMainMenu()
  if not isInMainMenu then
    Logger:Log("Info: Game not in MainMenu")
    InputQueue:Initialize()
    InventoryUtility:Initialize()
    PopupUtility:Initialize()
    SocialUtility:Initialize()
    ChatUtility:Initialize()
    PlayerUtility:Initialize()
  end
end
function Automation:Cleanup(currentTaskTable)
  Logger:Log("Info: Cleanup")
  currentTaskTable:Cleanup()
  MenuStack:Clear()
end
function Automation:OnTick(delta, timePoint)
  if self:CanProcess() then
    self.currentTask = self.tasks[self.taskNumber]
    if self.currentTask then
      if not self.currentTask.started then
        self:PrepareData()
        self.currentTask:SetParams()
        self.currentTask:Start()
      end
      if not self.currentTask.finished and self:CanProcess() then
        self.currentTask:Execute()
      end
      if self.currentTask.finished then
        self:Cleanup(self.currentTask.table)
        local retrying = self.currentTask:ShouldRetry()
        if not retrying then
          self.taskNumber = self.taskNumber + 1
          local chunkSize = 480
          for i, taskResult in pairs(self.currentTask.taskResults) do
            local jsonResultString = jsonParser.encode(taskResult)
            local chunkTotal = math.floor(#jsonResultString / chunkSize) + 1
            local chunkCounter = 1
            for j = 1, #jsonResultString, chunkSize do
              Debug.Log("Attempt #" .. i .. "(" .. chunkCounter .. "/" .. chunkTotal .. "): " .. string.sub(jsonResultString, j, j + chunkSize - 1))
              chunkCounter = chunkCounter + 1
            end
          end
          local taskSucceeded = self.currentTask:GetCurrentTaskResult().status == ResultStatus.PASS
          if taskSucceeded then
            Logger:Log("Task: " .. self.currentTask.name .. " : success")
          else
            Logger:Log("Task: " .. self.currentTask.name .. " : fail")
          end
        end
      end
    else
      self:OnShutdown()
      self.taskNumber = 0
    end
  end
end
function Automation:OnShutdown()
  Logger:Log("Info: Automation shutdown")
  if self.tickHandler then
    self.tickHandler:Disconnect()
    self.tickHandler = nil
  end
  InputQueue:Shutdown()
  MenuStack:Shutdown()
  TimerHandler:Shutdown()
end
return Automation
