local Profiler = {
  tags = {},
  tracks = {}
}
function Profiler:RadTmBegin(tagId)
  LyShineManagerBus.Broadcast.ProfileBegin(tagId)
end
function Profiler:RadTmEnd(tagId)
  LyShineManagerBus.Broadcast.ProfileEnd(tagId)
end
function Profiler:RadTmFunc(tagId, functionToCall)
  self:RadTmBegin(tagId)
  functionToCall()
  self:RadTmEnd(tagId)
end
function Profiler:TagStart(tagId, logStart)
  self.tags[tagId] = self:GetTimeNs()
  if logStart then
    Debug.Log("Lua Profiler: [" .. tostring(tagId) .. "] start\n")
  end
end
function Profiler:TagEnd(tagId)
  local timeSpentMs = self:GetTimeNs():Subtract(self.tags[tagId]):ToMillisecondsUnrounded()
  Debug.Log("Lua Profiler: [" .. tostring(tagId) .. "] = " .. tostring(timeSpentMs) .. "ms\n")
  self.tags[tagId] = nil
end
local curTag
function Profiler:Tag(tagId)
  if curTag then
    self:TagEnd(curTag)
  end
  if curTag ~= tagId then
    self:TagStart(tagId)
    curTag = tagId
  else
    curTag = nil
  end
end
function Profiler:TagFunc(tagId, functionToCall)
  self:TagStart(tagId)
  functionToCall()
  self:TagEnd(tagId)
end
function Profiler:TagFuncMulti(tagId, functionToCall, timesToCall)
  self:TagStart(tagId)
  for i = 1, timesToCall do
    functionToCall()
  end
  self:TagEnd(tagId)
end
function Profiler:GetTimeNs()
  return WallClockTimePoint:Now()
end
function Profiler:TrackStart(trackId)
  local track = self.tracks[trackId] or {
    count = 0,
    totalTime = 0,
    maxTime = 0
  }
  track.begin = self:GetTimeNs()
  self.tracks[trackId] = track
end
function Profiler:TrackEnd(trackId, updateFrequency, keepDataAfterLog)
  local track = self.tracks[trackId]
  if not track then
    Debug.Log(string.foramt("Profiler:TrackEnd called for track %s that was not found", tostring(trackId)))
    return
  end
  if not track.begin then
    Debug.Log(string.foramt("Profiler:TrackEnd called without begin for track %s", tostring(trackId)))
    return
  end
  local timeSpentMs = self:GetTimeNs():Subtract(track.begin):ToMillisecondsUnrounded()
  track.totalTime = track.totalTime + timeSpentMs
  track.count = track.count + 1
  track.maxTime = math.max(track.maxTime, timeSpentMs)
  updateFrequency = updateFrequency or 300
  if type(updateFrequency) ~= "number" or updateFrequency == 0 or track.count % updateFrequency == 0 then
    Debug.Log(string.format("Lua Profiler: [%s] recorded %d times. Avg = %sms, Max = %sms", trackId, track.count, track.totalTime / track.count, track.maxTime))
    if not keepDataAfterLog then
      track.count = 0
      track.maxTime = 0
      track.totalTime = 0
    end
  end
  track.begin = nil
end
return Profiler
