local UITimingUtils = {}
UITimingUtils.delayedFunctionData = {}
function UITimingUtils:Delay(time, callingTable, functionToCall, loop, hold)
  return self:CreateTimer(callingTable, time, functionToCall, loop, hold, true, false)
end
function UITimingUtils:DelayFrames(frames, callingTable, functionToCall, loop, hold)
  return self:CreateTimer(callingTable, frames, functionToCall, loop, hold, false, false)
end
function UITimingUtils:UpdateForDuration(duration, callingTable, functionToCall)
  return self:CreateTimer(callingTable, duration, functionToCall, nil, nil, true, true)
end
function UITimingUtils:CreateTimer(callingTable, time, functionToCall, loop, hold, inSeconds, updateEveryTick)
  if not callingTable then
    Debug.Log("Error: Calling create timer without a callingTable")
    Debug.Log(debug.traceback())
    return
  end
  if not time then
    Debug.Log("Error: Calling create timer without a valid time")
    Debug.Log(debug.traceback())
    return
  end
  if not functionToCall then
    Debug.Log("Error: Calling create timer without a valid callback")
    Debug.Log(debug.traceback())
    return
  end
  local timer = {}
  timer.time = time
  timer.currentTime = time
  timer.functionToCall = functionToCall
  timer.loop = loop or false
  timer.hold = hold or 0
  timer.inSeconds = inSeconds
  timer.updateEveryTick = updateEveryTick or false
  local ownerTable = self.delayedFunctionData[callingTable]
  if not ownerTable then
    ownerTable = {}
    self.delayedFunctionData[callingTable] = ownerTable
  end
  table.insert(ownerTable, timer)
  return timer
end
function UITimingUtils:StopDelay(callingTable, functionToCall)
  local ownerTable = self.delayedFunctionData[callingTable]
  if ownerTable then
    if functionToCall == nil then
      self.delayedFunctionData[callingTable] = nil
    else
      for idx = #ownerTable, 1, -1 do
        local timer = ownerTable[idx]
        if timer.functionToCall == functionToCall then
          table.remove(ownerTable, idx)
        end
      end
    end
  end
end
function UITimingUtils:OnTick(deltaTime, timePoint)
  for callingTable, ownerTable in pairs(self.delayedFunctionData) do
    for idx = #ownerTable, 1, -1 do
      local timer = ownerTable[idx]
      if timer.inSeconds then
        timer.currentTime = timer.currentTime - deltaTime
      else
        timer.currentTime = timer.currentTime - 1
      end
      local progress = timer.time > 0 and (timer.time - timer.currentTime) / timer.time or 0
      progress = Math.Clamp(progress, 0, 1)
      if timer.currentTime <= 0 then
        if timer.loop then
          timer.currentTime = timer.time + timer.hold + (timer.inSeconds and 0 or 1)
        else
          table.remove(self.delayedFunctionData[callingTable], idx)
        end
        timer.functionToCall(callingTable, progress)
      elseif timer.updateEveryTick then
        timer.functionToCall(callingTable, progress)
      end
    end
    if self.delayedFunctionData[callingTable] and #self.delayedFunctionData[callingTable] == 0 then
      self.delayedFunctionData[callingTable] = nil
    end
  end
end
function UITimingUtils:Reset()
  ClearTable(self.delayedFunctionData)
end
return UITimingUtils
