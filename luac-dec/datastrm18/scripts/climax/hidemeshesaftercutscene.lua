local HideMeshesAfterCutscene = {
  Properties = {
    Meshes = {
      default = {
        EntityId()
      }
    },
    SequenceName = {default = ""},
    Show = {default = false},
    ChangeOnCutsceneStart = {default = false}
  }
}
function HideMeshesAfterCutscene:OnActivate()
  self.cinematicHandler = CinematicEventBus.Connect(self)
end
function HideMeshesAfterCutscene:OnCinematicStateChanged(cinematicName, state)
  if self.Properties.SequenceName == cinematicName and (state == eMovieEvent_Stopped and self.Properties.ChangeOnCutsceneStart == false or state == eMovieEvent_Started and self.Properties.ChangeOnCutsceneStart == true) then
    self:UpdateVisibility(self.Properties.Show)
  end
end
function HideMeshesAfterCutscene:UpdateVisibility(show)
  for _, entityId in pairs(self.Properties.Meshes) do
    MeshComponentRequestBus.Event.SetVisibility(entityId, show)
    if self.cinematicHandler then
      self.cinematicHandler:Disconnect()
      self.cinematicHandler = nil
    end
  end
end
function HideMeshesAfterCutscene:OnDeactivate()
  if self.cinematicHandler then
    self.cinematicHandler:Disconnect()
    self.cinematicHandler = nil
  end
end
return HideMeshesAfterCutscene
