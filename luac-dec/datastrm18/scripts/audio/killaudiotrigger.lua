local KillAudioTrigger = {
  Properties = {
    audioTriggerName = {
      default = "",
      description = "Name of audio trigger to kill. If left blank, will kill all triggers on this entity.",
      order = 0
    }
  }
}
function KillAudioTrigger:KillAudioTrigger()
  if self.Properties.audioTriggerName == "" then
    AudioTriggerComponentRequestBus.Event.KillAllTriggers(self.entityId)
  else
    AudioTriggerComponentRequestBus.Event.KillTrigger(self.entityId, self.Properties.audioTriggerName)
  end
end
function KillAudioTrigger:Stop()
  AudioTriggerComponentRequestBus.Event.Stop(self.entityId)
end
return KillAudioTrigger
