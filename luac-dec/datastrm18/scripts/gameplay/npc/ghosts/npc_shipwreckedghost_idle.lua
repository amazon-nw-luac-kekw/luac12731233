NPC_Shipwreckedghost_Idle = {
  Properties = {
    NPC = {
      default = EntityId()
    }
  }
}
function NPC_Shipwreckedghost_Idle:OnActivate()
  self.isOnLocalPlayer = PlayerComponentRequestsBus.Event.IsLocalPlayer(self.Properties.NPC) == true
  self.meshNotificiationHandler = MeshComponentNotificationBus.Connect(self, self.Properties.NPC)
end
function NPC_Shipwreckedghost_Idle:OnDeactivate()
  self.meshNotificiationHandler:Disconnect()
  self:VFX_Off()
end
function NPC_Shipwreckedghost_Idle:VFX_On()
  self:VFX_Off()
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, "c_spine2_BND", "cFX_npc_GhostShipwrecked.Idle_Electric01", Vector3(0, 0, 0), self.isOnLocalPlayer, EmitterFollow)
end
function NPC_Shipwreckedghost_Idle:VFX_Off()
  ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, "c_spine2_BND", "cFX_npc_GhostShipwrecked.Idle_Electric01", false)
end
function NPC_Shipwreckedghost_Idle:OnMeshCreated()
  self:VFX_On()
end
return NPC_Shipwreckedghost_Idle
