local dataLayer = RequireScript("LyShineUI.UiDataLayer")
WeaponEffectBase = {
  EffectTypes = {Particle = 1, Audio = 2},
  effectGroups = {},
  effectEventBusHandler = nil,
  isDeactivating = false,
  idleOnActivateIfUnsheathed = true,
  idleOnActivateAlways = false,
  isVisible = true
}
function WeaponEffectBase:OnActivate()
  self.effectEventBusHandler = WeaponEffectEventBus.Connect(self, self.entityId)
  self:PreloadAudio()
  self.ownerEntityId = WeaponRequestBus.Event.GetOwnerEntityId(self.entityId)
  self.localPlayerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  self.isVisible = not WeaponRequestBus.Event.IsForcedHidden(self.entityId)
  if not self.isVisible and not self.tickBusHandler then
    self.tickBusHandler = TickBus.Connect(self)
  end
  local isSheathed = WeaponRequestBus.Event.IsSheathed(self.entityId)
  if self.isVisible and isSheathed == false and self.idleOnActivateIfUnsheathed or self.idleOnActivateAlways then
    self:EnableEffectGroup("idle", true)
  end
  WeaponRequestBus.Event.NotifyWeaponEffectScriptLoaded(self.entityId)
end
function WeaponEffectBase:OnDeactivate()
  if self.effectEventBusHandler ~= nil then
    self.effectEventBusHandler:Disconnect()
  end
  self:UnloadAudio()
  self.isDeactivating = true
  for effectGroupName, effectGroup in pairs(self.effectGroups) do
    self:EnableEffectGroup(effectGroupName, false)
  end
  if self.tickBusHandler then
    self.tickBusHandler:Disconnect()
    self.tickBusHandler = nil
  end
end
function WeaponEffectBase:EnableEffectGroup(effectGroupName, enable)
  local effectGroup = self.effectGroups[effectGroupName]
  if effectGroup ~= nil then
    for i = 1, #effectGroup do
      local effect = effectGroup[i]
      if effect.type == WeaponEffectBase.EffectTypes.Particle then
        if enable then
          self:StartParticle(effect)
        elseif not enable then
          if effectGroupName == "idle" and self.isDeactivating then
            self:StopParticle(effect)
          else
            self:StopParticle(effect)
          end
        end
      elseif effect.type == WeaponEffectBase.EffectTypes.Audio then
        if enable then
          if effectGroupName ~= "idle" then
            self:TriggerAudio(effect.startTriggerName, true)
          else
            self:TriggerIdleAudio(effect.startTriggerName, true)
          end
        elseif effectGroupName ~= "idle" then
          self:TriggerAudio(effect.stopTriggerName, false)
        else
          self:TriggerIdleAudio(effect.stopTriggerName, false)
        end
      else
        Debug.Warning("Invalid weapon effect type '" .. effect.type .. "' for effect group '" .. effectGroupName .. "'")
      end
    end
  else
    Debug.Warning("Invalid weapon effect group name '" .. effectGroupName .. "'")
  end
end
function WeaponEffectBase:StartParticle(particle)
  self:StopParticle(particle)
  local entityIdToSpawnOn = self.entityId
  if particle.playOnOwner ~= nil and particle.playOnOwner == true then
    entityIdToSpawnOn = self.ownerEntityId
  end
  if particle.particleName ~= nil and particle.particleName ~= "" then
    if particle.jointName ~= nil then
      if particle.positionOffset ~= nil and particle.rotationDeg ~= nil and particle.scale ~= nil then
        particle.emitterId = ParticleManagerBus.Broadcast.SpawnParticleAtJointOffset(entityIdToSpawnOn, particle.jointName, particle.particleName, particle.positionOffset, particle.rotationDeg, particle.scale, false, particle.followType)
      else
        particle.emitterId = ParticleManagerBus.Broadcast.SpawnParticleAtJoint(entityIdToSpawnOn, particle.jointName, particle.particleName, Vector3(0, 0, 0), false, particle.followType)
      end
    elseif particle.attachmentName ~= nil then
      if particle.positionOffset ~= nil and particle.rotationDeg ~= nil and particle.scale ~= nil then
        particle.emitterId = ParticleManagerBus.Broadcast.SpawnParticleAtAttachmentOffset(entityIdToSpawnOn, particle.attachmentName, particle.particleName, particle.positionOffset, particle.rotationDeg, particle.scale, false, particle.followType)
      else
        particle.emitterId = ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(entityIdToSpawnOn, particle.attachmentName, particle.particleName, Vector3(0, 0, 0), false, particle.followType)
      end
    else
      local pos = TransformBus.Event.GetWorldTranslation(entityIdToSpawnOn)
      local direction = TransformBus.Event.GetWorldRotationQuaternion(entityIdToSpawnOn) * Vector3(0, 1, 0)
      particle.emitterId = ParticleManagerBus.Broadcast.SpawnParticle(particle.particleName, pos, direction, false)
    end
  end
end
function WeaponEffectBase:StopParticle(particle)
  if particle.emitterId ~= nil then
    ParticleManagerBus.Broadcast.StopParticle(particle.emitterId, particle.killOnStop)
    particle.emitterId = nil
  end
end
function WeaponEffectBase:PreloadAudio()
  for effectGroupName, effectGroup in pairs(self.effectGroups) do
    for i = 1, #effectGroup do
      local effect = effectGroup[i]
      if effect.type == WeaponEffectBase.EffectTypes.Audio and effect.preloadName ~= nil and effect.preloadName ~= "" then
        AudioPreloadComponentRequestBus.Event.LoadPreload(self.entityId, effect.preloadName)
      end
    end
  end
end
function WeaponEffectBase:UnloadAudio()
  for effectGroupName, effectGroup in pairs(self.effectGroups) do
    for i = 1, #effectGroup do
      local effect = effectGroup[i]
      if effect.type == WeaponEffectBase.EffectTypes.Audio and effect.preloadName ~= nil and effect.preloadName ~= "" then
        AudioPreloadComponentRequestBus.Event.UnloadPreload(self.entityId, effect.preloadName)
      end
    end
  end
end
function WeaponEffectBase:TriggerAudio(triggerName, enable)
  if triggerName ~= nil and triggerName ~= "" then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, triggerName)
  end
  if enable then
    AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.ownerEntityId, "rtpc_Duck_Regular_Wpn", 1)
  elseif self.ownerEntityId ~= nil then
    AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.ownerEntityId, "rtpc_Duck_Regular_Wpn", 0)
  end
end
function WeaponEffectBase:TriggerIdleAudio(triggerName, enable)
  if triggerName == nil or triggerName ~= "" then
  end
end
function WeaponEffectBase:OnTick(deltaTime, timePoint)
  if not self.isVisible then
    self.isVisible = not WeaponRequestBus.Event.IsForcedHidden(self.entityId)
    if self.isVisible then
      local isSheathed = WeaponRequestBus.Event.IsSheathed(self.entityId)
      if isSheathed == false and self.idleOnActivateIfUnsheathed or self.idleOnActivateAlways then
        self:EnableEffectGroup("idle", true)
      end
      if self.tickBusHandler then
        self.tickBusHandler:Disconnect()
        self.tickBusHandler = nil
      end
    end
  end
end
return WeaponEffectBase
