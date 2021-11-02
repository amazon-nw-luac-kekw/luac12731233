NPC_AncientReaver_Idle = {
  Properties = {
    NPC = {
      default = EntityId()
    }
  }
}
function NPC_AncientReaver_Idle:OnActivate()
  self.isOnLocalPlayer = PlayerComponentRequestsBus.Event.IsLocalPlayer(self.Properties.NPC) == true
  self.meshNotificiationHandler = MeshComponentNotificationBus.Connect(self, self.Properties.NPC)
end
function NPC_AncientReaver_Idle:OnDeactivate()
  self.meshNotificiationHandler:Disconnect()
  self:VFX_Off()
end
function NPC_AncientReaver_Idle:VFX_On()
  self:VFX_Off()
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, "Spine2", "cFX_npc_Ancient.Idle_Chest_Guardian", Vector3(0, 0, 0), self.isOnLocalPlayer, EmitterFollow)
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, "Head", "cFX_npc_Ancient.Idle_Head_Guardian", Vector3(0, 0, 0), self.isOnLocalPlayer, EmitterFollow_IgnoreRotation)
end
function NPC_AncientReaver_Idle:VFX_Off()
  ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, "Spine2", "cFX_npc_Ancient.Idle_Chest_Guardian", false)
  ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, "Head", "cFX_npc_Ancient.Idle_Head_Guardian", false)
end
function NPC_AncientReaver_Idle:OnMeshCreated()
  self:VFX_On()
end
return NPC_AncientReaver_Idle
