Common_StructureEffects = {
  projectileSpawnerBusHandler = nil,
  lowAmmoEmitterId = nil,
  structureEventBusHandler = nil,
  Properties = {
    turretEntity = {
      default = EntityId(),
      description = "Turret EntityId",
      order = 1
    },
    audioEntity = {
      default = EntityId(),
      description = "Audio EntityId where all sounds should play from",
      order = 2
    },
    fireAudioTrigger = {
      default = "",
      description = "Sound playing when firing",
      order = 3
    },
    OnInteractStartAudioTrigger = {
      default = "",
      description = "Sound playing when entering the structure",
      order = 4
    },
    OnInteractEndAudioTrigger = {
      default = "",
      description = "Sound playing when leaving the structure",
      order = 5
    },
    fireParticle = {
      default = "",
      description = "VFX particle name to spawn when firing",
      order = 6
    },
    lowAmmoAmount = {
      default = "",
      description = "VFX particle name to spawn when firing",
      order = 7
    },
    lowAmmoParticleName = {
      default = "",
      description = "VFX particle name to spawn when firing",
      order = 8
    }
  }
}
function Common_StructureEffects:OnActivate()
  self.isLocalPlayer = false
  self:SetAudioRemote()
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
function Common_StructureEffects:OnDeactivate()
  self:HideLowAmmoDisplay()
  self.isLocalPlayer = false
  self:SetAudioRemote()
  if self.projectileSpawnerBusHandler ~= nil then
    self.projectileSpawnerBusHandler:Disconnect()
  end
  if self.structureEventBusHandler ~= nil then
    self.structureEventBusHandler:Disconnect()
  end
end
function Common_StructureEffects:OnProjectileSpawned()
  if self.Properties.fireParticle ~= nil then
    local spawnTM = TransformBus.Event.GetWorldTM(self.entityId)
    ParticleManagerBus.Broadcast.SpawnParticle(self.Properties.fireParticle, spawnTM:GetTranslation(), spawnTM:GetColumn(1), false)
  end
  if self.isLocalPlayer == false then
    self:SetAudioRemote()
  else
    self:SetAudioLocalPlayer()
  end
  if self.Properties.audioEntity ~= nil then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.audioEntity, self.Properties.fireAudioTrigger)
  end
end
function Common_StructureEffects:OnInteractStart()
  self.isLocalPlayer = true
  self:SetAudioLocalPlayer()
  if self.Properties.OnInteractStartAudioTrigger ~= nil then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.audioEntity, self.Properties.OnInteractStartAudioTrigger)
  end
end
function Common_StructureEffects:OnInteractEnd()
  self.isLocalPlayer = false
  self:SetAudioRemote()
  if self.Properties.OnInteractEndAudioTrigger ~= nil then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.audioEntity, self.Properties.OnInteractEndAudioTrigger)
  end
end
function Common_StructureEffects:OnAmmoCountChanged(prevAmount, newAmount)
end
function Common_StructureEffects:ShowLowAmmoDisplay()
  if self.lowAmmoEmitterId == nil then
    local pos = TransformBus.Event.GetWorldTranslation(self.entityId)
    local direction = TransformBus.Event.GetWorldRotationQuaternion(self.entityId) * Vector3(0, -2, 0)
    pos = pos + Vector3(0, 0, 2) + direction
    if self.Properties.lowAmmoParticleName ~= nil then
      self.lowAmmoEmitterId = ParticleManagerBus.Broadcast.SpawnParticle(self.Properties.lowAmmoParticleName, pos, direction, false)
    end
  end
end
function Common_StructureEffects:HideLowAmmoDisplay()
  if self.lowAmmoEmitterId ~= nil then
    ParticleManagerBus.Broadcast.StopParticle(self.lowAmmoEmitterId, false)
    self.lowAmmoEmitterId = nil
  end
end
function Common_StructureEffects:SetAudioLocalPlayer()
  if self.Properties.audioEntity ~= nil then
    AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.Properties.audioEntity, "NetworkType", 0)
  end
end
function Common_StructureEffects:SetAudioRemote()
  if self.Properties.audioEntity ~= nil then
    AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.Properties.audioEntity, "NetworkType", 50)
  end
end
function Common_StructureEffects:SetAudioNPC()
  if self.Properties.audioEntity ~= nil then
    AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.Properties.audioEntity, "NetworkType", 100)
  end
end
return Common_StructureEffects
