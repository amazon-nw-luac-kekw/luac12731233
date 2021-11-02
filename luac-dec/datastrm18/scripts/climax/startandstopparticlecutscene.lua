local StartAndStopParticleCutscene = {
  Properties = {
    StartSequenceName = {default = ""},
    StopSequenceName = {default = ""},
    AttachedToEntity = {
      default = EntityId()
    }
  }
}
function StartAndStopParticleCutscene:OnActivate()
  if self.Properties.AttachedToEntity:IsValid() then
    self.cinematicHandler = CinematicEventBus.Connect(self)
  end
end
function StartAndStopParticleCutscene:OnCinematicStateChanged(cinematicName, state)
  if self.Properties.StartSequenceName == cinematicName and state == eMovieEvent_Started then
    ParticleComponentRequestBus.Event.Enable(self.Properties.AttachedToEntity, true)
  elseif self.Properties.StopSequenceName == cinematicName and state == eMovieEvent_Stopped then
    ParticleComponentRequestBus.Event.Enable(self.Properties.AttachedToEntity, false)
  end
end
function StartAndStopParticleCutscene:OnDeactivate()
  if self.cinematicHandler then
    self.cinematicHandler:Disconnect()
    self.cinematicHandler = nil
  end
end
return StartAndStopParticleCutscene
