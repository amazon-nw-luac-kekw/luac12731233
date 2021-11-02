OverheatEffects = {
  projectileSpawnerBusHandler = nil,
  structureEventBusHandler = nil,
  overheatParticleId = nil,
  Properties = {
    turretEntity = {
      default = EntityId(),
      description = "Root structure EntityId",
      order = 1
    },
    audioEntity = {
      default = EntityId(),
      description = "Audio EntityId where all sounds should play from",
      order = 2
    },
    overheatStartAudioTrigger = {
      default = "",
      description = "Sound starting to play when overheating just started",
      order = 3
    },
    overheatEndAudioTrigger = {
      default = "",
      description = "Sound starting to play when overheating is over",
      order = 4
    },
    overheatMaxAudioTrigger = {
      default = "",
      description = "Sound starting to play when overheating reached Max value",
      order = 5
    },
    overheatReadyAudioTrigger = {
      default = "",
      description = "Sound starting to play when the weapon is ready",
      order = 6
    },
    simpleAnimEntity = {
      default = EntityId(),
      description = "Simple Animation EntityId",
      order = 7
    },
    overheatParticle = {
      default = "",
      description = "VFX particle name to spawn when overheating",
      order = 8
    },
    particleAttachment = {
      default = "",
      description = "VFX particle attachment for overheating particle",
      order = 9
    }
  }
}
function OverheatEffects:OnActivate()
  self.projectileSpawnerBusHandler = ProjectileSpawnerNotificationBus.Connect(self, self.entityId)
  self.structureEventBusHandler = TurretEventBus.Connect(self, self.Properties.turretEntity)
  if self.projectileSpawnerBusHandler == nil then
    Debug.Log("No projectile event handler")
  end
  if self.structureEventBusHandler == nil then
    Debug.Log("No structure event handler")
  end
  if self.Properties.audioEntity == nil then
    Debug.Log("No audio entity")
  end
end
function OverheatEffects:OnDeactivate()
  if self.projectileSpawnerBusHandler ~= nil then
    self.projectileSpawnerBusHandler:Disconnect()
  end
  if self.structureEventBusHandler ~= nil then
    self.structureEventBusHandler:Disconnect()
  end
end
function OverheatEffects:OnProjectileSpawned()
  local animInfo = AnimatedLayer("repeater_spin_stop", 0, false, 1.2, 0)
  SimpleAnimationComponentRequestBus.Event.StartAnimation(self.Properties.simpleAnimEntity, animInfo)
end
function OverheatEffects:OnInteractStart()
  if self.Properties.overheatStartAudioTrigger ~= nil and self.Properties.audioEntity ~= nil then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.audioEntity, self.Properties.overheatStartAudioTrigger)
  end
  if self.OnInteractStartAudioTrigger ~= nil and self.Properties.audioEntity ~= nil then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.audioEntity, self.OnInteractStartAudioTrigger)
  end
end
function OverheatEffects:OnInteractEnd()
  if self.Properties.overheatEndAudioTrigger ~= nil then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.audioEntity, self.Properties.overheatEndAudioTrigger)
  end
  if self.OnInteractEndAudioTrigger ~= nil then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.audioEntity, self.OnInteractEndAudioTrigger)
  end
end
function OverheatEffects:OnOverheatStart(meshEntityId, projectileSpawnerPosition, projectileSpawnerFacing)
  if self.Properties.overheatParticle ~= nil and self.overheatParticleId == nil then
    self.overheatParticleId = ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(meshEntityId, self.Properties.particleAttachment, self.Properties.overheatParticle, projectileSpawnerFacing, false, EmitterFollow)
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.audioEntity, self.Properties.overheatMaxAudioTrigger)
end
function OverheatEffects:OnOverheatEnd(meshEntityId, projectileSpawnPosition, projectileSpawnFacing)
  if self.overheatParticleId ~= nil then
    ParticleManagerBus.Broadcast.StopParticle(self.overheatParticleId, false)
    self.overheatParticleId = nil
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.audioEntity, self.Properties.overheatReadyAudioTrigger)
end
function OverheatEffects:OnHeatChanged(meshEntityId, oldHeatPercentage, newHeatPercentage)
  if oldHeatPercentage <= newHeatPercentage then
    AudioSwitchComponentRequestBus.Event.SetSwitchState(self.Properties.audioEntity, "Over_Heat", "On")
  else
    AudioSwitchComponentRequestBus.Event.SetSwitchState(self.Properties.audioEntity, "Over_Heat", "Off")
  end
  AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.Properties.audioEntity, "OverHeat", oldHeatPercentage)
end
return OverheatEffects
