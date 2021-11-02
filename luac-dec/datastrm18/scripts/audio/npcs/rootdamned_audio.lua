local commonNPC_audio = RequireScript("Scripts.Audio.NPCs.commonNPC_audio")
local DamnedScript = {
  Properties = {}
}
Merge(DamnedScript, commonNPC_audio, false)
function DamnedScript:OnActivate()
  commonNPC_audio.OnActivate(self)
end
function DamnedScript:OnDeactivate()
  commonNPC_audio.OnDeactivate(self)
end
return DamnedScript
