local PlayerVFX_Heal = {
  Properties = {
    ParticleSpawn_01 = {
      default = "",
      description = "Sets the Particle path"
    },
    ParticleStop_01 = {
      default = true,
      description = "true is default; true = stops Emitter & Particles; false = stops Emitter only"
    },
    ParticleJoint_01 = {
      default = "Xform",
      description = "Joint on Local Player"
    }
  },
  localPlayerId = nil
}
local ParticleNormal = Vector3(0, 0, 0)
function PlayerVFX_Heal:OnActivate()
  self.triggerAreaHandler = TriggerAreaNotificationBus.Connect(self, self.entityId)
end
function PlayerVFX_Heal:OnDeactivate()
  self:StopParticles()
  self.triggerAreaHandler:Disconnect()
  self.triggerAreaHandler = nil
end
function PlayerVFX_Heal:OnTriggerAreaEntered(enteringEntityId)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(enteringEntityId) == true then
    self.localPlayerId = enteringEntityId
    self:SpawnParticle(enteringEntityId, self.Properties.ParticleJoint_01, self.Properties.ParticleSpawn_01)
    MaterialOverrideBus.Event.StartOverride(self.localPlayerId, 2861383205)
  end
end
function PlayerVFX_Heal:OnTriggerAreaExited(exitingEntityId)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(exitingEntityId) == true then
    self:StopParticles()
  end
end
function PlayerVFX_Heal:StopParticles()
  if self.localPlayerId then
    self:StopParticle(self.localPlayerId, self.Properties.ParticleJoint_01, self.Properties.ParticleSpawn_01, self.Properties.ParticleStop_01)
    MaterialOverrideBus.Event.StopOverride(self.localPlayerId, 2861383205)
    self.localPlayerId = nil
  end
end
function PlayerVFX_Heal:SpawnParticle(entityId, jointName, spawnName)
  if jointName ~= "" and spawnName ~= "" then
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(entityId, jointName, spawnName, ParticleNormal, true, EmitterFollow_IgnoreRotation)
  end
end
function PlayerVFX_Heal:StopParticle(entityId, jointName, spawnName, stop)
  if jointName ~= "" and spawnName ~= "" then
    ParticleManagerBus.Broadcast.StopParticleAtJoint(entityId, jointName, spawnName, stop)
  end
end
return PlayerVFX_Heal
