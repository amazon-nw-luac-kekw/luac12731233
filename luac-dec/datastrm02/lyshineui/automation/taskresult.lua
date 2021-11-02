local ResultStatus = RequireScript("LyShineUI.Automation.ResultStatus")
local TaskResult = {}
TaskResult.__index = TaskResult
setmetatable(TaskResult, {
  __call = function(cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end
})
function TaskResult:_init(name, id)
  self.taskName = name
  self.taskId = id
  self.startTime = nil
  self.stopTime = nil
  self.status = nil
  self.exception = nil
  self.stepResults = {}
  self.log = {}
end
function TaskResult:Start()
  self.startTime = os.time()
end
function TaskResult:SetStatus(resultStatus)
  self.stopTime = os.time()
  self.status = resultStatus
end
return TaskResult
