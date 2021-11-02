FireProjectile_DurationElapsedEffects = {
  notificationBusHandler = nil,
  FireTrailParticle = "cFX_Magic.Elemental.Fire.Projectile_Trail",
  NoHitParticle = "cFX_Magic.Elemental.Fire.Projectile_NoHit",
  ParticleId = nil
}
function FireProjectile_DurationElapsedEffects:OnActivate()
  self.notificationBusHandler = ProjectileNotificationBus.Connect(self, self.entityId)
end
function FireProjectile_DurationElapsedEffects:OnProjectileUnbindFromContext()
  if self.notificationBusHandler ~= nil then
    self.notificationBusHandler:Disconnect()
  end
end
function FireProjectile_DurationElapsedEffects:OnProjectileDurationElapsed(position)
  ParticleManagerBus.Broadcast.SpawnParticle(self.NoHitParticle, position, Vector3(0, 0, 1), false)
  AudioUtilsBus.Broadcast.ExecuteAudioTriggerAtPositionWithOcclusion("Play_Gauntlet_Fireball_Explo_Air", position, eAudioObstructionType_SingleRay)
end
return FireProjectile_DurationElapsedEffects
