local depleted = {
  Properties = {}
}
function depleted:OnActivate()
  if self.AudioTriggerBusHandler == nil then
    self.AudioTriggerBusHandler = AudioTriggerComponentNotificationBus.Connect(self, self.entityId)
  end
end
function depleted:OnTriggerFinished(bool)
  AudioPreloadComponentRequestBus.Event.Unload(self.entityId)
  self.AudioTriggerBusHandler:Disconnect()
  self.AudioTriggerBusHandler = nil
end
function depleted:OnDeactivate()
  if self.AudioTriggerBusHandler ~= nil then
    self.AudioTriggerBusHandler:Disconnect()
    self.AudioTriggerBusHandler = nil
  end
end
return depleted
