local ActivateEntity = {
  Properties = {
    Particle_01 = {
      default = "",
      description = "Set the 1st particle path"
    },
    Particle_01_Stop = {
      default = true,
      description = "true = stops emitter & particles; false = stops emitter only"
    },
    Particle_02 = {
      default = "",
      description = "Set the 2nd particle path"
    },
    Particle_02_Stop = {
      default = true,
      description = "true = stops emitter & particles; false = stops emitter only"
    }
  }
}
function ActivateEntity:OnActivate()
  self.triggerAreaHandler = TriggerAreaNotificationBus.Connect(self, self.entityId)
end
function ActivateEntity:OnDeactivate()
  self.triggerAreaHandler:Disconnect()
  self.triggerAreaHandler = nil
end
function ActivateEntity:OnTriggerAreaEntered(enteringEntityId)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(enteringEntityId) == true then
    local ParticlePos = TransformBus.Event.GetWorldTranslation(self.entityId)
    local ParticleNormal = Vector3(0, 0, 1)
    self.particleId_01 = ParticleManagerBus.Broadcast.SpawnParticle(self.Properties.Particle_01, ParticlePos, ParticleNormal, self.entityId)
    self.particleId_02 = ParticleManagerBus.Broadcast.SpawnParticle(self.Properties.Particle_02, ParticlePos, ParticleNormal, self.entityId)
  end
end
function ActivateEntity:OnTriggerAreaExited(exitingEntityId)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(exitingEntityId) == true then
    ParticleManagerBus.Broadcast.StopParticle(self.particleId_01, self.Properties.Particle_01_Stop)
    ParticleManagerBus.Broadcast.StopParticle(self.particleId_02, self.Properties.Particle_02_Stop)
  end
end
return ActivateEntity
