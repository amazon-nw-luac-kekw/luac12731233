local RaycastBatcher = {
  raycastCount = {},
  uniqueIdToDeferredRaycasts = {},
  raycastsToExecute = {},
  maxRaycastsPerTick = 5,
  ticksToWait = 5
}
function RaycastBatcher:BatchRaycast(uniqueId, worldPosition, timePointMs, callbackInfo)
  if not self.raycastCount[timePointMs] then
    ClearTable(self.raycastCount)
    self.raycastCount[timePointMs] = 0
  end
  self.raycastCount[timePointMs] = self.raycastCount[timePointMs] + 1
  self:ClearQueuedRaycast(uniqueId)
  local doRaycast = self.raycastCount[timePointMs] < self.maxRaycastsPerTick
  if not doRaycast then
    self.uniqueIdToDeferredRaycasts[uniqueId] = {
      worldPosition = worldPosition,
      callbackInfo = callbackInfo,
      tickCount = 0
    }
  end
  return doRaycast, LyShineManagerBus.Broadcast.ProjectToScreen(worldPosition, false, doRaycast)
end
function RaycastBatcher:ClearQueuedRaycast(uniqueId)
  self.uniqueIdToDeferredRaycasts[uniqueId] = nil
end
function RaycastBatcher:Tick(timePointMs)
  if self.lastTimePoint == timePointMs then
    return
  end
  self.lastTimePoint = timePointMs
  ClearTable(self.raycastsToExecute)
  for uniqueId, raycastInfo in pairs(self.uniqueIdToDeferredRaycasts) do
    raycastInfo.tickCount = raycastInfo.tickCount + 1
    if raycastInfo.tickCount > self.ticksToWait then
      self.raycastsToExecute[uniqueId] = raycastInfo
    end
  end
  for uniqueId, raycastInfo in pairs(self.raycastsToExecute) do
    self:ClearQueuedRaycast(uniqueId)
    local didRaycast, result = self:BatchRaycast(uniqueId, raycastInfo.worldPosition, timePointMs, raycastInfo.callbackInfo)
    if didRaycast then
      raycastInfo.callbackInfo.callbackFunc(raycastInfo.callbackInfo.callingSelf, result)
    end
  end
end
return RaycastBatcher
