require("Scripts.Events.EventSenderBase")
local EventTriggerAreaEntered = {
  Properties = {
    onlyTriggeredByLocalPlayer = {
      default = true,
      description = "Whether or not the event should only be sent when the local player enters the trigger area.",
      order = 0
    }
  }
}
CreateEventSender(EventTriggerAreaEntered)
function EventTriggerAreaEntered:OnActivate()
  self.triggerAreaBusHandler = TriggerAreaNotificationBus.Connect(self, self.entityId)
end
function EventTriggerAreaEntered:OnDeactivate()
  self.triggerAreaBusHandler:Disconnect()
end
function EventTriggerAreaEntered:OnTriggerAreaEntered(entityId)
  if not self.Properties.onlyTriggeredByLocalPlayer or PlayerComponentRequestsBus.Event.IsLocalPlayer(entityId) then
    self:SendEvent()
  end
end
return EventTriggerAreaEntered
