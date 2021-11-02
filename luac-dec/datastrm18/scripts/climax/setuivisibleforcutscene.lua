local SetUIVisibleForCutscene = {
  Properties = {
    SequenceName = {default = ""}
  },
  currentState = 0
}
function SetUIVisibleForCutscene:OnActivate()
  self.cinematicHandler = CinematicEventBus.Connect(self)
end
function SetUIVisibleForCutscene:OnCinematicStateChanged(cinematicName, state)
  if self.Properties.SequenceName == cinematicName then
    if state ~= self.currentState and state ~= eMovieEvent_Stopped then
      self.currentState = state
      DynamicBus.FtueMessageBus.Broadcast.SetElementVisibleForFtue(false)
      UIInputRequestsBus.Broadcast.SetActionMapEnabled("ui", false)
      UIInputRequestsBus.Broadcast.SetActionMapEnabled("default", false)
      if cinematicName == "VistaCutscene" then
        DynamicBus.TutorialMessage.Broadcast.OnTutorialActivated("outro", false, "", false, false, 0, {}, {}, {}, 0, 0)
      end
    elseif state == eMovieEvent_Stopped then
      DynamicBus.FtueMessageBus.Broadcast.SetElementVisibleForFtue(true)
      UIInputRequestsBus.Broadcast.SetActionMapEnabled("ui", true)
      UIInputRequestsBus.Broadcast.SetActionMapEnabled("default", true)
    end
  end
end
function SetUIVisibleForCutscene:OnDeactivate()
  if self.cinematicHandler then
    self.cinematicHandler:Disconnect()
    self.cinematicHandler = nil
  end
end
return SetUIVisibleForCutscene
