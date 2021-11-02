NPC_Dryad_Idle = {
  Properties = {
    NPC = {
      default = EntityId()
    }
  }
}
function NPC_Dryad_Idle:OnActivate()
  self.isOnLocalPlayer = PlayerComponentRequestsBus.Event.IsLocalPlayer(self.Properties.NPC) == true
  self.meshNotificiationHandler = MeshComponentNotificationBus.Connect(self, self.Properties.NPC)
end
function NPC_Dryad_Idle:OnDeactivate()
  self.meshNotificiationHandler:Disconnect()
  self:VFX_Off()
end
function NPC_Dryad_Idle:VFX_On()
  self:VFX_Off()
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, "Head", "cFX_npc_BogMonster.Idle_Head", Vector3(0, 0, 0), self.isOnLocalPlayer, EmitterFollow)
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, "Spine3", "cFX_npc_BogMonster.Idle", Vector3(0, 0, 0), self.isOnLocalPlayer, EmitterFollow)
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, "Eye_left_BND", "cFX_npc_BogMonster.Idle_Eyes", Vector3(0, 0, 0), self.isOnLocalPlayer, EmitterFollow)
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, "Eye_right_BND", "cFX_npc_BogMonster.Idle_Eyes", Vector3(0, 0, 0), self.isOnLocalPlayer, EmitterFollow)
end
function NPC_Dryad_Idle:VFX_Off()
  ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, "Head", "cFX_npc_BogMonster.Idle_Head", false)
  ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, "Spine3", "cFX_npc_BogMonster.Idle", false)
  ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, "Eye_left_BND", "cFX_npc_BogMonster.Idle_Eyes", false)
  ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, "Eye_right_BND", "cFX_npc_BogMonster.Idle_Eyes", false)
end
function NPC_Dryad_Idle:OnMeshCreated()
  self:VFX_On()
end
return NPC_Dryad_Idle
