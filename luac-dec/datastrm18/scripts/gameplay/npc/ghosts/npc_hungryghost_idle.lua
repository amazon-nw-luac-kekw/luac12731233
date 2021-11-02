NPC_Hungryghost_Idle = {
  Properties = {
    NPC = {
      default = EntityId()
    }
  }
}
function NPC_Hungryghost_Idle:OnActivate()
  self.isOnLocalPlayer = PlayerComponentRequestsBus.Event.IsLocalPlayer(self.Properties.NPC) == true
  self.meshNotificiationHandler = MeshComponentNotificationBus.Connect(self, self.Properties.NPC)
end
function NPC_Hungryghost_Idle:OnDeactivate()
  self.meshNotificiationHandler:Disconnect()
  self:VFX_Off()
end
function NPC_Hungryghost_Idle:VFX_On()
  self:VFX_Off()
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, "c_spine2_BND", "cFX_npc_GhostHunger.Idle", Vector3(0, 0, 0), self.isOnLocalPlayer, EmitterFollow)
end
function NPC_Hungryghost_Idle:VFX_Off()
  ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, "c_spine2_BND", "cFX_npc_GhostHunger.Idle", false)
end
function NPC_Hungryghost_Idle:OnMeshCreated()
  self:VFX_On()
end
return NPC_Hungryghost_Idle
