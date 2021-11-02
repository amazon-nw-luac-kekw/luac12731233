CorruptCowLauncherEffects = {
  projectileSpawnerBusHandler = nil,
  fireParticle = "Inv_CowLauncher.Proj_Muzzle",
  fireAudioTrigger = "Play_Trebuchet_FireLaunch",
  Properties = {
    audioEntity = {
      default = EntityId(),
      description = "Audio EntityId",
      order = 1
    }
  }
}
function CorruptCowLauncherEffects:OnActivate()
  self.projectileSpawnerBusHandler = ProjectileSpawnerNotificationBus.Connect(self, self.entityId)
end
function CorruptCowLauncherEffects:OnDeactivate()
  if self.projectileSpawnerBusHandler ~= nil then
    self.projectileSpawnerBusHandler:Disconnect()
  end
end
function CorruptCowLauncherEffects:OnProjectileSpawned()
  if self.fireParticle ~= nil then
    local spawnTM = TransformBus.Event.GetWorldTM(self.entityId)
    ParticleManagerBus.Broadcast.SpawnParticle(self.fireParticle, spawnTM:GetTranslation(), spawnTM:GetColumn(1), false)
  end
  if self.Properties.audioEntity ~= nil then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.audioEntity, self.fireAudioTrigger)
  end
end
return CorruptCowLauncherEffects
