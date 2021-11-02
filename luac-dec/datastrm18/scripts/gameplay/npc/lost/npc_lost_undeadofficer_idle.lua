NPC_Lost_Undeadofficer_Idle = {
  Properties = {
    NPC = {
      default = EntityId()
    }
  }
}
function NPC_Lost_Undeadofficer_Idle:OnActivate()
  self.isOnLocalPlayer = PlayerComponentRequestsBus.Event.IsLocalPlayer(self.Properties.NPC) == true
  self.meshNotificiationHandler = MeshComponentNotificationBus.Connect(self, self.Properties.NPC)
end
function NPC_Lost_Undeadofficer_Idle:OnDeactivate()
  self.meshNotificiationHandler:Disconnect()
  self:VFX_Off()
end
function NPC_Lost_Undeadofficer_Idle:VFX_On()
  self:VFX_Off()
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, "reference_look", "cFX_npc_Undeadofficer.Lightningshield", Vector3(0, 0, 0), self.isOnLocalPlayer, EmitterFollow)
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, "Eye_left_BND", "cFX_npc_Undeadofficer.Eyes01", Vector3(0, 0, 0), self.isOnLocalPlayer, EmitterFollow)
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, "Eye_right_BND", "cFX_npc_Undeadofficer.Eyes01", Vector3(0, 0, 0), self.isOnLocalPlayer, EmitterFollow)
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, "right_index_2", "cFX_npc_Undeadofficer.Lightning_Hands", Vector3(0, 0, 0), self.isOnLocalPlayer, EmitterFollow)
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, "left_index_2", "cFX_npc_Undeadofficer.Lightning_Hands", Vector3(0, 0, 0), self.isOnLocalPlayer, EmitterFollow)
end
function NPC_Lost_Undeadofficer_Idle:VFX_Off()
  ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, "reference_look", "cFX_npc_Undeadofficer.Lightningshield", false)
  ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, "Eye_left_BND", "cFX_npc_Undeadofficer.Eyes01", false)
  ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, "Eye_right_BND", "cFX_npc_Undeadofficer.Eyes01", false)
  ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, "right_index_2", "cFX_npc_Undeadofficer.Lightning_Hands", false)
  ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, "left_index_2", "cFX_npc_Undeadofficer.Lightning_Hands", false)
end
function NPC_Lost_Undeadofficer_Idle:OnMeshCreated()
  self:VFX_On()
end
return NPC_Lost_Undeadofficer_Idle
