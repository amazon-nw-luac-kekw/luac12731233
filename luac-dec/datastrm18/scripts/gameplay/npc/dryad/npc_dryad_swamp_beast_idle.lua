NPC_Dryad_Swamp_Beast_Idle = {
  Properties = {
    NPC = {
      default = EntityId()
    }
  }
}
function NPC_Dryad_Swamp_Beast_Idle:OnActivate()
  self.isOnLocalPlayer = PlayerComponentRequestsBus.Event.IsLocalPlayer(self.Properties.NPC) == true
  self.meshNotificiationHandler = MeshComponentNotificationBus.Connect(self, self.Properties.NPC)
end
function NPC_Dryad_Swamp_Beast_Idle:OnDeactivate()
  self.meshNotificiationHandler:Disconnect()
  self:VFX_Off()
end
function NPC_Dryad_Swamp_Beast_Idle:VFX_On()
  self:VFX_Off()
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.NPC, "bind_spine_c", "cFX_npc_SwampDryadBeast.Idle", Vector3(0, 0, 0), self.isOnLocalPlayer, EmitterFollow)
end
function NPC_Dryad_Swamp_Beast_Idle:VFX_Off()
  ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.NPC, "bind_spine_c", "cFX_npc_SwampDryadBeast.Idle", false)
end
function NPC_Dryad_Swamp_Beast_Idle:OnMeshCreated()
  self:VFX_On()
end
return NPC_Dryad_Swamp_Beast_Idle
