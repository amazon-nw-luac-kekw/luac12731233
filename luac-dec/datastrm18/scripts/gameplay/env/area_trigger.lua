local ActivateEntity = {
  Properties = {
    EnteringAreaEvent = {
      default = EventData()
    },
    ExitingAreaEvent = {
      default = EventData()
    }
  }
}
function ActivateEntity:OnActivate()
  self.triggerAreaHandler = TriggerAreaNotificationBus.Connect(self, self.entityId)
end
function ActivateEntity:OnDeactivate()
  self.triggerAreaHandler:Disconnect()
  self.triggerAreaHandler = nil
end
function ActivateEntity:OnTriggerAreaEntered(enteringEntityId)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(enteringEntityId) == true then
    self.Properties.EnteringAreaEvent:ExecuteEvent()
  end
end
function ActivateEntity:OnTriggerAreaExited(exitingEntityId)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(exitingEntityId) == true then
    self.Properties.ExitingAreaEvent:ExecuteEvent()
  end
end
return ActivateEntity
