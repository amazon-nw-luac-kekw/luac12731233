TimingUtils = {
  timersForOwner = {},
  numTimers = 0
}
function TimingUtils:Delay(ownerId, time, functionToCall, loop, hold)
  TimingUtils:CreateTimer(ownerId, time, functionToCall, loop, hold, true)
end
function TimingUtils:DelayFrames(ownerId, frames, functionToCall, loop, hold)
  TimingUtils:CreateTimer(ownerId, frames, functionToCall, loop, hold, false)
end
function TimingUtils:CreateTimer(ownerId, time, functionToCall, loop, hold, inSeconds)
  if not TimingUtils.tickBusHandler then
    TimingUtils.tickBusHandler = TickBus.Connect(TimingUtils)
  end
  local timer = {}
  timer.time = time
  timer.currentTime = time
  timer.functionToCall = functionToCall
  timer.loop = loop or false
  timer.hold = hold or 0
  timer.inSeconds = inSeconds
  local ownerKey = tostring(ownerId)
  local ownerTable = TimingUtils.timersForOwner[ownerKey]
  if not ownerTable then
    ownerTable = {}
    ownerTable.entityBusHandler = EntityBus.Connect(TimingUtils, ownerId)
    ownerTable.timers = {}
    TimingUtils.timersForOwner[ownerKey] = ownerTable
  end
  table.insert(ownerTable.timers, timer)
  TimingUtils.numTimers = TimingUtils.numTimers + 1
end
function TimingUtils:OnTick(deltaTime, timePoint)
  for ownerKey, ownerTable in pairs(TimingUtils.timersForOwner) do
    for idx = #ownerTable.timers, 1, -1 do
      local timer = ownerTable.timers[idx]
      if timer.inSeconds then
        timer.currentTime = timer.currentTime - deltaTime
      else
        timer.currentTime = timer.currentTime - 1
      end
      if timer.currentTime <= 0 then
        if timer.loop then
          timer.currentTime = timer.time + timer.hold + (timer.inSeconds and 0 or 1)
        else
          table.remove(TimingUtils.timersForOwner[ownerKey].timers, idx)
          TimingUtils.numTimers = TimingUtils.numTimers - 1
        end
        timer.functionToCall()
      end
    end
    if #ownerTable.timers == 0 then
      ownerTable.entityBusHandler:Disconnect()
      TimingUtils.timersForOwner[ownerKey] = nil
    end
  end
  if TimingUtils.numTimers == 0 and TimingUtils.tickBusHandler then
    TimingUtils.tickBusHandler:Disconnect()
    TimingUtils.tickBusHandler = nil
  end
end
function TimingUtils:OnEntityDeactivated(entityId)
  TimingUtils:ClearAllTimersForOwner(entityId)
end
function TimingUtils:ClearAllTimersForOwner(ownerId)
  local ownerKey = tostring(ownerId)
  local ownerTable = TimingUtils.timersForOwner[ownerKey]
  if ownerTable then
    ownerTable.entityBusHandler:Disconnect()
    TimingUtils.numTimers = TimingUtils.numTimers - #ownerTable.timers
    TimingUtils.timersForOwner[ownerKey] = nil
    if TimingUtils.numTimers == 0 and TimingUtils.tickBusHandler then
      TimingUtils.tickBusHandler:Disconnect()
      TimingUtils.tickBusHandler = nil
    end
  end
end
