NPC_DamnedBear_Idle = {
  Properties = {
    NPC = {
      default = EntityId()
    }
  }
}
function NPC_DamnedBear_Idle:OnActivate()
  self.isOnLocalPlayer = PlayerComponentRequestsBus.Event.IsLocalPlayer(self.Properties.NPC) == true
  self.meshNotificiationHandler = MeshComponentNotificationBus.Connect(self, self.Properties.NPC)
end
function NPC_DamnedBear_Idle:OnDeactivate()
  self.meshNotificiationHandler:Disconnect()
  self:VFX_Off()
end
function NPC_DamnedBear_Idle:VFX_On()
  self:VFX_Off()
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, "neck_2_jnt", "cFX_npc_Damned.Idle02", Vector3(0, 0, 0), self.isOnLocalPlayer, EmitterFollow)
end
function NPC_DamnedBear_Idle:VFX_Off()
  ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, "neck_2_jnt", "cFX_npc_Damned.Idle02", false)
end
function NPC_DamnedBear_Idle:OnMeshCreated()
  self:VFX_On()
end
return NPC_DamnedBear_Idle
