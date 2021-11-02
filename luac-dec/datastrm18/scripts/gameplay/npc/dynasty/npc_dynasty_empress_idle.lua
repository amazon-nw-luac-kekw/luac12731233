NPC_Dynasty_Empress_Idle = {
  Properties = {
    NPC = {
      default = EntityId()
    }
  }
}
function NPC_Dynasty_Empress_Idle:OnActivate()
  self.isOnLocalPlayer = PlayerComponentRequestsBus.Event.IsLocalPlayer(self.Properties.NPC) == true
  self.meshNotificiationHandler = MeshComponentNotificationBus.Connect(self, self.Properties.NPC)
end
function NPC_Dynasty_Empress_Idle:OnDeactivate()
  self.meshNotificiationHandler:Disconnect()
  self:VFX_Off()
end
function NPC_Dynasty_Empress_Idle:VFX_On()
  self:VFX_Off()
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, "bind_neck_a", "cFX_npc_Dynasty_Empress.Idle", Vector3(0, 0, 0), self.isOnLocalPlayer, EmitterFollow)
end
function NPC_Dynasty_Empress_Idle:VFX_Off()
  ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, "bind_neck_a", "cFX_npc_Dynasty_Empress.Idle", false)
end
function NPC_Dynasty_Empress_Idle:OnMeshCreated()
  self:VFX_On()
end
return NPC_Dynasty_Empress_Idle
