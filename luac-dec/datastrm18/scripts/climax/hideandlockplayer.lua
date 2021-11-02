local HideAndLockPlayer = {
  Properties = {
    Hide = {default = true},
    HandleStartAndEnd = {default = false},
    Trigger = {
      default = EntityId()
    },
    SequenceName = {default = ""}
  }
}
function HideAndLockPlayer:OnActivate()
  if self.Properties.SequenceName ~= "" then
    self.cinematicHandler = CinematicEventBus.Connect(self)
  elseif self.Properties.Trigger:IsValid() then
    self.triggerAreaHandler = TriggerAreaNotificationBus.Connect(self, self.Properties.Trigger)
  else
    LyShineScriptBindRequestBus.Broadcast.HideAndLockPlayer(self.Properties.Hide)
    LocalPlayerUIRequestsBus.Broadcast.SetIsInCutscene(self.Properties.Hide)
  end
end
function HideAndLockPlayer:OnCinematicStateChanged(cinematicName, state)
  if self.Properties.SequenceName == cinematicName then
    if state == eMovieEvent_Started and self.Properties.HandleStartAndEnd == true then
      LyShineScriptBindRequestBus.Broadcast.HideAndLockPlayer(not self.Properties.Hide)
      LocalPlayerUIRequestsBus.Broadcast.SetIsInCutscene(not self.Properties.Hide)
    elseif state == eMovieEvent_Stopped then
      LyShineScriptBindRequestBus.Broadcast.HideAndLockPlayer(self.Properties.Hide)
      LocalPlayerUIRequestsBus.Broadcast.SetIsInCutscene(self.Properties.Hide)
      if self.cinematicHandler then
        self.cinematicHandler:Disconnect()
        self.cinematicHandler = nil
      end
    end
  end
end
function HideAndLockPlayer:OnTriggerAreaEntered(enteringEntityId)
  LyShineScriptBindRequestBus.Broadcast.HideAndLockPlayer(self.Properties.Hide)
  LocalPlayerUIRequestsBus.Broadcast.SetIsInCutscene(self.Properties.Hide)
  if self.triggerAreaHandler then
    self.triggerAreaHandler:Disconnect()
    self.triggerAreaHandler = nil
  end
end
return HideAndLockPlayer
