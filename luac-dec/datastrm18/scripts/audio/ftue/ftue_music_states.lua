local music_states = {}
function music_states:OnActivate()
  self.trackEventHandler = SequenceComponentNotificationBus.Connect(self, self.entityId)
end
function music_states:OnDeactivate()
  if self.trackEventHandler ~= nil then
    self.trackEventHandler:Disconnect()
  end
end
function music_states:OnTrackEventTriggered(event, value)
  if event ~= nil and value ~= nil then
    AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState(tostring(event), tostring(value))
  end
end
return music_states
