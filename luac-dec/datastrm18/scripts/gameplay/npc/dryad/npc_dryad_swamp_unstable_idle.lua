NPC_Dryad_Swamp_Unstable_Idle = {
  Properties = {
    NPC = {
      default = EntityId()
    }
  }
}
function NPC_Dryad_Swamp_Unstable_Idle:OnActivate()
  self.isOnLocalPlayer = PlayerComponentRequestsBus.Event.IsLocalPlayer(self.Properties.NPC) == true
  self.meshNotificiationHandler = MeshComponentNotificationBus.Connect(self, self.Properties.NPC)
end
function NPC_Dryad_Swamp_Unstable_Idle:OnDeactivate()
  self.meshNotificiationHandler:Disconnect()
  self:VFX_Off()
end
function NPC_Dryad_Swamp_Unstable_Idle:VFX_On()
  self:VFX_Off()
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, "Neck", "cFX_npc_SwampFiend.Unstable_Idle", Vector3(0, 0, 0), self.isOnLocalPlayer, EmitterFollow)
end
function NPC_Dryad_Swamp_Unstable_Idle:VFX_Off()
  ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, "Neck", "cFX_npc_SwampFiend.Unstable_Idle", false)
end
function NPC_Dryad_Swamp_Unstable_Idle:OnMeshCreated()
  self:VFX_On()
end
return NPC_Dryad_Swamp_Unstable_Idle
