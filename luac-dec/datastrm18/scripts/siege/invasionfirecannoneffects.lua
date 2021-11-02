FireTrebuchetEffects = {
  projectileSpawnerBusHandler = nil,
  fireParticle = "Inv_FireCannon.Proj_Muzzle",
  fireAudioTrigger = "Play_Cannon_Shoot",
  Properties = {
    audioEntity = {
      default = EntityId(),
      description = "Audio EntityId",
      order = 1
    }
  }
}
function FireTrebuchetEffects:OnActivate()
  self.projectileSpawnerBusHandler = ProjectileSpawnerNotificationBus.Connect(self, self.entityId)
end
function FireTrebuchetEffects:OnDeactivate()
  if self.projectileSpawnerBusHandler ~= nil then
    self.projectileSpawnerBusHandler:Disconnect()
  end
end
function FireTrebuchetEffects:OnProjectileSpawned()
  if self.fireParticle ~= nil then
    local spawnTM = TransformBus.Event.GetWorldTM(self.entityId)
    ParticleManagerBus.Broadcast.SpawnParticle(self.fireParticle, spawnTM:GetTranslation(), spawnTM:GetColumn(1), false)
  end
  if self.Properties.audioEntity ~= nil then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.audioEntity, self.fireAudioTrigger)
  end
end
return FireTrebuchetEffects
