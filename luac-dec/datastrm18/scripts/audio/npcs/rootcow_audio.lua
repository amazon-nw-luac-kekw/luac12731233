local commonNPC_audio = RequireScript("Scripts.Audio.NPCs.commonNPC_audio")
local CowAudio = {
  Properties = {}
}
Merge(CowAudio, commonNPC_audio, false)
function CowAudio:OnActivate()
  commonNPC_audio.OnActivate(self)
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, "Play_Cow_Flies")
end
function CowAudio:OnDeactivate()
  commonNPC_audio.OnDeactivate(self)
end
return CowAudio
