require("Scripts._Common.Common")
local EventSenderBase = {
  Properties = {
    eventsToSend = {
      default = {
        ScriptBindScriptEvent()
      },
      description = "List of events to send.",
      order = 1000
    }
  }
}
function EventSenderBase:SendEvent()
  for idx, event in pairs(self.Properties.eventsToSend) do
    if not EntityId.IsValid(event.entityId) then
      event.entityId = self.entityId
    end
    ScriptComponentRequestBus.Event.CallFunction(ScriptComponentId(event.entityId, event.scriptId), event.eventName)
  end
end
function CreateEventSender(subClassTable)
  Merge(subClassTable, EventSenderBase, true)
end
return EventSenderBase
