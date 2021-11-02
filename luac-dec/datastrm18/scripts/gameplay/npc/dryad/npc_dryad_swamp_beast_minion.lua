local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local NPC_Dryad_Swamp_Beast_Minion = {}
function NPC_Dryad_Swamp_Beast_Minion:OnActivate()
  self.characterEventBusHandler = CharacterEventBus.Connect(self, self.entityId)
end
function NPC_Dryad_Swamp_Beast_Minion:OnDeactivate()
  if self.emitterId then
    ParticleManagerBus.Broadcast.StopParticle(self.emitterId, false)
    self.emitterId = nil
  end
  if self.characterEventBusHandler ~= nil then
    self.characterEventBusHandler:Disconnect()
    self.characterEventBusHandler = nil
  end
end
function NPC_Dryad_Swamp_Beast_Minion:TriggerCharacterEvent(string, bool)
  if string == "MinionRecall" then
    local sourceSpawnerEntityId = SpawnerRequestBus.Event.GetSourceSpawnerEntityId(self.entityId)
    if sourceSpawnerEntityId:IsValid() then
      self.emitterId = ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.entityId, "Spine2", "cFX_npc_SwampDryadBeast.Summon_Minion_Consume", Vector3(0, 1, 0), false, EmitterFollow_IgnoreRotation)
      local offset = Vector3(0, 0, 3.15)
      ParticleManagerBus.Broadcast.SetTargetEntity(self.emitterId, sourceSpawnerEntityId, offset)
    end
  end
end
return NPC_Dryad_Swamp_Beast_Minion
