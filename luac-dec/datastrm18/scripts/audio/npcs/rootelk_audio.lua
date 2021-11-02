local commonNPC_audio = RequireScript("Scripts.Audio.NPCs.commonNPC_audio")
local ElkScript = {
  Properties = {}
}
Merge(ElkScript, commonNPC_audio, false)
function ElkScript:OnActivate()
  commonNPC_audio.OnActivate(self)
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, "Play_Elk01_Breathing")
  if TagComponentRequestBus.Event.HasTag(self.entityId, 1435361449) then
    AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityId, "Gender", "Male")
  else
    AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityId, "Gender", "Female")
  end
end
function ElkScript:OnDeactivate()
  commonNPC_audio.OnDeactivate(self)
end
return ElkScript
