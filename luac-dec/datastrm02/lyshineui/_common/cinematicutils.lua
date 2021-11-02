local CinematicUtils = {}
CinematicUtils.cinematicData = {}
function CinematicUtils:PlayCinematic(cinematicName, callbackSelf, onCompleteCallback)
  if not self.cinematicHandler then
    self.cinematicHandler = CinematicEventBus.Connect(self)
  end
  CinematicRequestBus.Broadcast.PlaySequenceByName(cinematicName)
  if callbackSelf and onCompleteCallback then
    if not self.cinematicData[cinematicName] then
      self.cinematicData[cinematicName] = {}
    end
    local cinematicData = self.cinematicData[cinematicName]
    table.insert(cinematicData, {callbackSelf = callbackSelf, onCompleteCallback = onCompleteCallback})
  end
end
function CinematicUtils:StopSequence(cinematicName)
  CinematicRequestBus.Broadcast.StopSequence(cinematicName)
end
function CinematicUtils:OnCinematicStateChanged(cinematicName, state)
  if state == eMovieEvent_Stopped or state == eMovieEvent_Aborted or state == eMovieEvent_BeyondEnd then
    local cinematicData = self.cinematicData[cinematicName]
    if cinematicData then
      for _, callback in ipairs(cinematicData) do
        callback.onCompleteCallback(callback.callbackSelf, cinematicName, state)
      end
      self.cinematicData[cinematicName] = nil
      local numData = CountAssociativeTable(self.cinematicData)
      if numData <= 0 and self.cinematicHandler then
        self.cinematicHandler:Disconnect()
        self.cinematicHandler = nil
      end
    end
  end
end
function CinematicUtils:Reset()
  ClearTable(self.cinematicData)
  if self.cinematicHandler then
    self.cinematicHandler:Disconnect()
    self.cinematicHandler = nil
  end
end
return CinematicUtils
