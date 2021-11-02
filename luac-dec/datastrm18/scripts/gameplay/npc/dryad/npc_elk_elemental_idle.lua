NPC_Elk_elemental_Idle = {
  Properties = {
    NPC = {
      default = EntityId()
    }
  }
}
function NPC_Elk_elemental_Idle:OnActivate()
  self.isOnLocalPlayer = PlayerComponentRequestsBus.Event.IsLocalPlayer(self.Properties.NPC) == true
  self.meshNotificiationHandler = MeshComponentNotificationBus.Connect(self, self.Properties.NPC)
end
function NPC_Elk_elemental_Idle:OnDeactivate()
  self.meshNotificiationHandler:Disconnect()
  self:VFX_Off()
end
function NPC_Elk_elemental_Idle:VFX_On()
  self:VFX_Off()
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, "spine_2_jnt", "cFX_npc_ElkElemental.Idle", Vector3(0, 0, 0), self.isOnLocalPlayer, EmitterFollow)
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, "head_look_jnt", "cFX_npc_ElkElemental.eyes", Vector3(0, 0, 0), self.isOnLocalPlayer, EmitterFollow)
end
function NPC_Elk_elemental_Idle:VFX_Off()
  ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, "spine_2_jnt", "cFX_npc_ElkElemental.Idle", false)
  ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, "head_look_jnt", "cFX_npc_ElkElemental.eyes", false)
end
function NPC_Elk_elemental_Idle:OnMeshCreated()
  self:VFX_On()
end
return NPC_Elk_elemental_Idle
