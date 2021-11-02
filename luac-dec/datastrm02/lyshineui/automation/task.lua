local jsonParser = RequireScript("LyShineUI.json")
local InputQueue = RequireScript("LyShineUI.Automation.InputQueue")
local Logger = RequireScript("LyShineUI.Automation.Logger")
local ResultStatus = RequireScript("LyShineUI.Automation.ResultStatus")
local TaskResult = RequireScript("LyShineUI.Automation.TaskResult")
local Task = {}
Task.__index = Task
setmetatable(Task, {
  __call = function(cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end
})
function Task:_init(name, table, params)
  self.name = name
  self.table = table
  self.taskResults = {
    TaskResult(self.name, self.table.taskId)
  }
  self.stepNumber = 1
  self.currentStepObject = nil
  self.attempt = 1
  self.started = false
  self.finished = false
  self.params = params
end
function Task:SetParams()
  for key, value in pairs(self.params) do
    if string.lower(value) == "true" then
      self.table[key] = true
    elseif string.lower(value) == "false" then
      self.table[key] = false
    elseif tonumber(value) ~= nil then
      self.table[key] = tonumber(value)
    else
      self.table[key] = value
    end
  end
end
function Task:GetCurrentTaskResult()
  return self.taskResults[self.attempt]
end
function Task:Start()
  if not self.started then
    self.table:Setup()
    self.stepNumber = 1
    self:GetCurrentTaskResult():Start()
    self.started = true
  end
end
function Task:Finish(resultStatus)
  if not self.finished then
    self:GetCurrentTaskResult():SetStatus(resultStatus)
    self.currentStepObject = nil
    self.finished = true
  end
end
function Task:Execute()
  if self.stepNumber <= #self.table.steps then
    self.currentStepObject = self.table.steps[self.stepNumber]
    self.currentStepObject:Execute()
    if self.currentStepObject.finished then
      local stepResult = self.currentStepObject.stepResult
      Logger:Log("Step " .. self.currentStepObject.name .. " completed with result: " .. jsonParser.encode(stepResult))
      table.insert(self:GetCurrentTaskResult().stepResults, stepResult)
      if stepResult.status == ResultStatus.PASS then
        self.stepNumber = self.stepNumber + 1
      else
        self:Finish(ResultStatus.FAIL)
      end
    end
  elseif self.table.Verify ~= nil then
    local success = self.table:Verify()
    self:Finish(success and ResultStatus.PASS or ResultStatus.FAIL)
  else
    self:Finish(ResultStatus.PASS)
  end
end
function Task:ShouldRetry()
  local retrying = false
  if self.finished and self:GetCurrentTaskResult().status ~= ResultStatus.PASS and self.attempt < self.table.attempts then
    self.started = false
    self.finished = false
    self.attempt = self.attempt + 1
    table.insert(self.taskResults, TaskResult(self.name, self.table.taskId))
    Logger:Log("Retrying task (" .. tostring(self.attempt) .. "/" .. tostring(self.table.attempts) .. "): " .. self.name)
    retrying = true
  end
  return retrying
end
return Task
