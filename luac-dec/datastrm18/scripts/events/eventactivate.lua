require("Scripts.Events.EventSenderBase")
require("Scripts.Utils.TimingUtils")
local EventActivate = {
  Properties = {}
}
CreateEventSender(EventActivate)
function EventActivate:OnActivate()
  TimingUtils:DelayFrames(self.entityId, 1, function()
    self:SendEvent()
  end)
end
return EventActivate
