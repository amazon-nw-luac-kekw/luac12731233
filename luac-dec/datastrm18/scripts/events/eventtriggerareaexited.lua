require("Scripts.Events.EventSenderBase")
local EventTriggerAreaExited = {
  Properties = {
    onlyTriggeredByLocalPlayer = {
      default = true,
      description = "Whether or not the event should only be sent when the local player exits the trigger area.",
      order = 0
    }
  }
}
CreateEventSender(EventTriggerAreaExited)
function EventTriggerAreaExited:OnActivate()
  self.triggerAreaBusHandler = TriggerAreaNotificationBus.Connect(self, self.entityId)
end
function EventTriggerAreaExited:OnDeactivate()
  self.triggerAreaBusHandler:Disconnect()
end
function EventTriggerAreaExited:OnTriggerAreaExited(entityId)
  if not self.Properties.onlyTriggeredByLocalPlayer or PlayerComponentRequestsBus.Event.IsLocalPlayer(entityId) then
    self:SendEvent()
  end
end
return EventTriggerAreaExited
