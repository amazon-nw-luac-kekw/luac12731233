NPC_TorsoBoss_Idle = {
  Properties = {
    NPC = {
      default = EntityId()
    }
  },
  VFX_Idle_1 = "cFX_npc_TorsoBoss.Idle_01",
  VFX_Idle_2 = "cFX_npc_TorsoBoss.Idle_02"
}
function NPC_TorsoBoss_Idle:OnActivate()
  self.isOnLocalPlayer = PlayerComponentRequestsBus.Event.IsLocalPlayer(self.Properties.NPC) == true
  self.meshNotificiationHandler = MeshComponentNotificationBus.Connect(self, self.Properties.NPC)
end
function NPC_TorsoBoss_Idle:OnDeactivate()
  self.meshNotificiationHandler:Disconnect()
  self:VFX_Off()
end
function NPC_TorsoBoss_Idle:VFX_On()
  self:VFX_Off()
  ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(self.Properties.NPC, "VFX_Eye", self.VFX_Idle_1, Vector3(0, 0, 0), self.isOnLocalPlayer, EmitterFollow)
  ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(self.Properties.NPC, "VFX_Connection_Elbow_R2", self.VFX_Idle_2, Vector3(0, 0, 0), self.isOnLocalPlayer, EmitterFollow)
  ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(self.Properties.NPC, "VFX_Connection_Elbow_R1", self.VFX_Idle_2, Vector3(0, 0, 0), self.isOnLocalPlayer, EmitterFollow)
  ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(self.Properties.NPC, "VFX_Connection_Wrist_R", self.VFX_Idle_2, Vector3(0, 0, 0), self.isOnLocalPlayer, EmitterFollow)
  ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(self.Properties.NPC, "VFX_Connection_Wrist_L", self.VFX_Idle_2, Vector3(0, 0, 0), self.isOnLocalPlayer, EmitterFollow)
  ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(self.Properties.NPC, "VFX_Connection_Hand_R", self.VFX_Idle_2, Vector3(0, 0, 0), self.isOnLocalPlayer, EmitterFollow)
  ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(self.Properties.NPC, "VFX_Connection_Hand_L", self.VFX_Idle_2, Vector3(0, 0, 0), self.isOnLocalPlayer, EmitterFollow)
end
function NPC_TorsoBoss_Idle:VFX_Off()
  ParticleManagerBus.Broadcast.StopParticleAtAttachment(self.Properties.NPC, "VFX_Eye", self.VFX_Idle_1, false)
  ParticleManagerBus.Broadcast.StopParticleAtAttachment(self.Properties.NPC, "VFX_Connection_Elbow_R2", self.VFX_Idle_2, false)
  ParticleManagerBus.Broadcast.StopParticleAtAttachment(self.Properties.NPC, "VFX_Connection_Elbow_R1", self.VFX_Idle_2, false)
  ParticleManagerBus.Broadcast.StopParticleAtAttachment(self.Properties.NPC, "VFX_Connection_Wrist_R", self.VFX_Idle_2, false)
  ParticleManagerBus.Broadcast.StopParticleAtAttachment(self.Properties.NPC, "VFX_Connection_Wrist_L", self.VFX_Idle_2, false)
  ParticleManagerBus.Broadcast.StopParticleAtAttachment(self.Properties.NPC, "VFX_Connection_Hand_R", self.VFX_Idle_2, false)
  ParticleManagerBus.Broadcast.StopParticleAtAttachment(self.Properties.NPC, "VFX_Connection_Hand_L", self.VFX_Idle_2, false)
end
function NPC_TorsoBoss_Idle:OnMeshCreated()
  self:VFX_On()
end
return NPC_TorsoBoss_Idle
