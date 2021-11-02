local EndFTUE = {
  Properties = {}
}
function EndFTUE:OnActivate()
  self.cinematicHandler = CinematicEventBus.Connect(self)
end
function EndFTUE:OnCinematicStateChanged(cinematicName, state)
  if cinematicName == "CapExplo_Sequence" and state == eMovieEvent_Stopped then
    GameRequestsBus.Broadcast.ProceedToNewWorld(false)
    self.cinematicHandler:Disconnect()
    self.cinematicHandler = nil
  end
end
function EndFTUE:OnDeactivate()
  if self.cinematicHandler then
    self.cinematicHandler:Disconnect()
    self.cinematicHandler = nil
  end
end
return EndFTUE
