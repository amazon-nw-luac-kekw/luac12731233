local LogMessage = RequireScript("LyShineUI.Automation.LogMessage")
local Logger = {}
function Logger:Log(message)
  local Runner = RequireScript("LyShineUI.Automation.Automation")
  local logMessage = LogMessage(message)
  Debug.Log(logMessage:DeserializedMessage())
  if Runner.currentTask ~= nil then
    table.insert(Runner.currentTask:GetCurrentTaskResult().log, logMessage)
  end
end
return Logger
