local TriggerCinematicEvent = {
  Properties = {
    Trigger = {
      default = EntityId(),
      description = "Entity containing a Trigger Area component."
    },
    Sequence = {
      default = EntityId(),
      description = "Entity containing the sequence to play."
    },
    SequenceName = {
      default = "",
      description = "Name of sequence to play if no entity is available"
    },
    TriggerOnce = {
      default = true,
      description = "Only trigger this once"
    },
    Camera = {
      default = EntityId()
    }
  }
}
function TriggerCinematicEvent:OnActivate()
  if self.Properties.Trigger:IsValid() then
    self.triggerAreaHandler = TriggerAreaNotificationBus.Connect(self, self.Properties.Trigger)
  else
    if self.Properties.Camera:IsValid() then
      JavCameraControllerRequestBus.Broadcast.MakeActiveView(0, 0, 0)
      CameraRequestBus.Event.MakeActiveView(self.Properties.Camera, 1.25, 1.25, 1.25)
    end
    if self.Properties.Sequence:IsValid() then
      SequenceComponentRequestBus.Event.Play(self.Properties.Sequence)
    else
      CinematicRequestBus.Broadcast.PlaySequenceByName(self.Properties.SequenceName)
    end
  end
end
function TriggerCinematicEvent:OnDeactivate()
  if self.triggerAreaHandler ~= nil then
    self.triggerAreaHandler:Disconnect()
    self.triggerAreaHandler = nil
  end
end
function TriggerCinematicEvent:OnTriggerAreaEntered(enteringEntityId)
  if self.Properties.Camera:IsValid() then
    JavCameraControllerRequestBus.Broadcast.MakeActiveView(0, 0, 0)
    CameraRequestBus.Event.MakeActiveView(self.Properties.Camera, 1.25, 1.25, 1.25)
  end
  if self.Properties.Sequence:IsValid() then
    SequenceComponentRequestBus.Event.Play(self.Properties.Sequence)
  else
    CinematicRequestBus.Broadcast.PlaySequenceByName(self.Properties.SequenceName)
  end
  if self.Properties.TriggerOnce and self.triggerAreaHandler ~= nil then
    self.triggerAreaHandler:Disconnect()
    self.triggerAreaHandler = nil
  end
end
return TriggerCinematicEvent
