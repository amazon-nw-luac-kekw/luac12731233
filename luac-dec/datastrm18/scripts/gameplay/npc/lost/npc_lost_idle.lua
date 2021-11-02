local WeaponEffectBase = RequireScript("Scripts.Gameplay.NPC.NPC_Base_Idle")
NPC_Lost_Idle = {}
function NPC_Lost_Idle:VFX_On()
  self:VFX_Off()
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, "Neck", "cFX_npc_Lost.Idle01", Vector3(0, 0, 0), self.isOnLocalPlayer, EmitterFollow)
end
function NPC_Lost_Idle:VFX_Off()
  ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, "Neck", "cFX_npc_Lost.Idle01", false)
end
Merge(NPC_Lost_Idle, NPC_Base_Idle, true)
return NPC_Lost_Idle
