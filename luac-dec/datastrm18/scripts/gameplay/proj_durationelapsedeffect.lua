Proj_DurationElapsedEffect = {
  notificationBusHandler = nil,
  ParticleId = nil,
  audioTriggerOptions = nil,
  Properties = {
    audioEntity = {
      default = EntityId(),
      description = "Audio EntityId",
      order = 1
    },
    soundName = {
      default = "Play_Gauntlet_Fireball_Explo_Air",
      description = "Audio trigger when projectile dies",
      order = 2
    },
    NoHitParticle = {
      default = "cFX_LifeStaff.Proj_Impact",
      description = "Particle when projectile dies",
      order = 3
    },
    FireTrailParticle = {
      default = "cFX_FireStaff.Proj_Trail",
      description = "Particle trail",
      order = 4
    }
  }
}
function Proj_DurationElapsedEffect:OnActivate()
  self.notificationBusHandler = ProjectileNotificationBus.Connect(self, self.entityId)
  if not self.audioTriggerOptions then
    self.audioTriggerOptions = AudioTriggerOptions()
  end
  self.audioTriggerOptions.obstructionType = GetImpactAudioOcclusionType(self.Properties.audioEntity)
end
function Proj_DurationElapsedEffect:OnDeactivate()
  if self.notificationBusHandler ~= nil then
    self.notificationBusHandler:Disconnect()
  end
end
function Proj_DurationElapsedEffect:OnProjectileDurationElapsed(position)
  ParticleManagerBus.Broadcast.SpawnParticle(self.Properties.NoHitParticle, position, Vector3(0, 0, 1), false)
  AudioUtilsBus.Broadcast.ExecuteAudioTriggerAtPositionWithOptions(self.Properties.soundName, position, self.audioTriggerOptions)
end
return Proj_DurationElapsedEffect
