PlayerState_Fishing = {
  Properties = {
    Player = {
      default = EntityId(),
      description = "Player EntityId",
      order = 1
    },
    audioEntity = {
      default = EntityId(),
      description = "Audio EntityId",
      order = 2
    },
    soundName = {
      default = "",
      description = "",
      order = 3
    },
    Particle_Fail = {
      default = "cFX_Fishing.Fail",
      order = 4
    },
    Particle_Splash = {
      default = "cFX_Fishing.Splash_01",
      order = 5
    },
    Particle_Idle = {
      default = "cFX_Fishing.Idle_01",
      order = 6
    },
    Particle_Nibble = {
      default = "cFX_Fishing.Nibble",
      order = 7
    },
    Particle_Bite = {
      default = "cFX_Fishing.Bite",
      order = 8
    },
    Particle_ReelFighting = {
      default = "cFX_Fishing.Fighting",
      order = 9
    },
    Particle_ReelTired = {
      default = "cFX_Fishing.Tired",
      order = 10
    }
  },
  emitters = {
    bobber = {id = 0},
    fish = {id = 0}
  }
}
function PlayerState_Fishing:OnActivate()
  self.isOnLocalPlayer = PlayerComponentRequestsBus.Event.IsLocalPlayer(self.Properties.Player) == true
  if not self.isOnLocalPlayer then
    return
  end
  local dataLayer = RequireScript("LyShineUI.UiDataLayer")
  self.FishingNotificationsBus = nil
  self.FishingNotificationsBus = FishingNotificationsBus.Connect(self, self.Properties.Player)
  self.audioOptions = AudioTriggerOptions()
  self.audioOptions.obstructionType = eAudioObstructionType_SingleRay
  self.fishingStateEffectFunctions = {
    [eFishingState_Unequipped] = self.OnUnequipped,
    [eFishingState_Equipped] = self.OnEquipped,
    [eFishingState_ApplyingBait] = self.OnApplyingBait,
    [eFishingState_CastStart] = self.OnCastStart,
    [eFishingState_CastEnd] = self.OnCastEnd,
    [eFishingState_CastHitWater] = self.OnCastHitWater,
    [eFishingState_FishingStarted] = self.OnFishingStarted,
    [eFishingState_FishNibbleWindowOpen] = self.OnFishNibbleWindowOpen,
    [eFishingState_FishBiteWindowOpen] = self.OnFishBiteWindowOpen,
    [eFishingState_HookHit] = self.OnHookHit,
    [eFishingState_ReelingActive] = self.OnReelingActive,
    [eFishingState_ReelingRecover] = self.OnReelingRecover,
    [eFishingState_Failed_CastHitLand] = self.OnCastHitLand,
    [eFishingState_Failed_HookMissedTooEarly] = self.OnHookMissedTooEarly,
    [eFishingSTate_Failed_HookMissedTooLate] = self.OnHookMissedTooLate,
    [eFishingState_Failed_LineBreak] = self.OnLineBreak,
    [eFishingState_Failed_FishSwamAway] = self.OnFishSwamAway,
    [eFishingState_Succeeded_FishCaught] = self.OnFishCaught,
    [eFishingState_FishingEnded] = self.OnFishingEnded
  }
end
function PlayerState_Fishing:OnDeactivate()
  if self.FishingNotificationsBus ~= nil then
    self.FishingNotificationsBus:Disconnect()
  end
end
function PlayerState_Fishing:StartParticleAtBobberPosition(emitter, particle, killOld)
  killOld = killOld or false
  self:StopEmitter(emitter, killOld)
  if particle ~= nil and particle ~= "" then
    local direction = TransformBus.Event.GetWorldRotationQuaternion(self.Properties.Player) * Vector3(0, 0, 1)
    emitter.id = ParticleManagerBus.Broadcast.SpawnParticle(particle, self.bobberPosition, direction, true)
  end
end
function PlayerState_Fishing:StartParticleAttachedToEntity(emitter, particle, entityId, killOld)
  killOld = killOld or false
  self:StopEmitter(emitter, killOld)
  if particle ~= nil and particle ~= "" and entityId ~= nil and entityId:IsValid() then
    emitter.id = ParticleManagerBus.Broadcast.SpawnParticleAttachedToEntity(entityId, particle, Vector3(0, 0, 1), true, EmitterFollow_IgnoreRotation)
  end
end
function PlayerState_Fishing:StopEmitter(emitter, kill)
  if emitter ~= nil and emitter.id ~= nil then
    ParticleManagerBus.Broadcast.StopParticle(emitter.id, kill)
    emitter.id = nil
  end
end
function PlayerState_Fishing:OnFishTired()
  if not self.Properties.Player or not self.isOnLocalPlayer then
    return
  end
  self.fishEntityId = FishingRequestsBus.Event.GetFishEntityId(self.Properties.Player)
  if self.fishEntityId:IsValid() then
    self:StartParticleAttachedToEntity(self.emitters.fish, self.Properties.Particle_ReelTired, self.fishEntityId)
  end
end
function PlayerState_Fishing:OnFishFighting()
  if not self.Properties.Player or not self.isOnLocalPlayer then
    return
  end
  self.fishEntityId = FishingRequestsBus.Event.GetFishEntityId(self.Properties.Player)
  if self.fishEntityId:IsValid() then
    self:StartParticleAttachedToEntity(self.emitters.fish, self.Properties.Particle_ReelFighting, self.fishEntityId)
  end
end
function PlayerState_Fishing:OnFishingStateChanged(fishingState)
  if not self.Properties.Player or not self.isOnLocalPlayer then
    return
  end
  local effectFunction = self.fishingStateEffectFunctions[fishingState]
  if effectFunction then
    effectFunction(self)
  end
end
function PlayerState_Fishing:OnUnequipped()
end
function PlayerState_Fishing:OnEquipped()
end
function PlayerState_Fishing:OnApplyingBait()
end
function PlayerState_Fishing:OnCastStart()
  if self.Properties.Player then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.Player, "Play_UI_Fishg_Clicks")
  end
end
function PlayerState_Fishing:OnCastEnd()
  if self.Properties.Player then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.Player, "Stop_UI_Fishg_Clicks")
  end
end
function PlayerState_Fishing:OnCastHitWater()
  if self.Properties.Player then
    self.bobberPosition = FishingRequestsBus.Event.GetBobberPosition(self.Properties.Player)
    self:StartParticleAtBobberPosition(self.emitters.bobber, self.Properties.Particle_Splash)
    AudioUtilsBus.Broadcast.ExecuteAudioTriggerAtPositionWithOptions("Play_Fishg_BobberImpact", self.bobberPosition, self.audioOptions)
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.Player, "Stop_Fishg_LineTension")
  end
end
function PlayerState_Fishing:OnFishingStarted()
  if self.Properties.Player then
    self.bobberPosition = FishingRequestsBus.Event.GetBobberPosition(self.Properties.Player)
    self:StartParticleAtBobberPosition(self.emitters.bobber, self.Properties.Particle_Idle)
  end
end
function PlayerState_Fishing:OnFishNibbleWindowOpen()
  if self.Properties.Player then
    self.bobberPosition = FishingRequestsBus.Event.GetBobberPosition(self.Properties.Player)
    self:StartParticleAtBobberPosition(self.emitters.bobber, self.Properties.Particle_Nibble)
    AudioUtilsBus.Broadcast.ExecuteAudioTriggerAtPositionWithOptions("Play_Fishg_BobberDrag", self.bobberPosition, self.audioOptions)
  end
end
function PlayerState_Fishing:OnFishBiteWindowOpen()
  if self.Properties.Player then
    self.bobberPosition = FishingRequestsBus.Event.GetBobberPosition(self.Properties.Player)
    self:StartParticleAtBobberPosition(self.emitters.bobber, self.Properties.Particle_Bite)
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.Player, "Play_Fishg_LineTension")
  end
end
function PlayerState_Fishing:OnHookHit()
  if self.Properties.Player then
    local kill = false
    self:StopEmitter(self.emitters.bobber, kill)
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.Player, "Play_Fishg_RodRattle")
  end
end
function PlayerState_Fishing:OnReelingActive()
  if self.Properties.Player then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.Player, "Play_Fishg_Reel")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.Player, "Stop_Fishg_LineTension")
  end
end
function PlayerState_Fishing:OnReelingRecover()
  if self.Properties.Player then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.Player, "Stop_Fishg_Reel")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.Player, "Play_Fishg_LineTension")
  end
end
function PlayerState_Fishing:OnCastHitLand()
  if self.Properties.Player then
    self.bobberPosition = FishingRequestsBus.Event.GetBobberPosition(self.Properties.Player)
    self:StartParticleAtBobberPosition(self.emitters.bobber, self.Properties.Particle_Fail)
    AudioUtilsBus.Broadcast.ExecuteAudioTriggerAtPositionWithOptions("Play_Fishg_BobberImpact", self.bobberPosition, self.audioOptions)
  end
end
function PlayerState_Fishing:OnHookMissedTooEarly()
  if self.Properties.Player then
    self.bobberPosition = FishingRequestsBus.Event.GetBobberPosition(self.Properties.Player)
    self:StartParticleAttachedToEntity(self.emitters.bobber, self.Properties.Particle_Fail)
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.Player, "Stop_Fishg_LineTension")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.Player, "Stop_Fishg_Reel")
  end
end
function PlayerState_Fishing:OnHookMissedTooLate()
  if self.Properties.Player then
    self.bobberPosition = FishingRequestsBus.Event.GetBobberPosition(self.Properties.Player)
    self:StartParticleAttachedToEntity(self.emitters.bobber, self.Properties.Particle_Fail)
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.Player, "Stop_Fishg_LineTension")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.Player, "Stop_Fishg_Reel")
  end
end
function PlayerState_Fishing:OnLineBreak()
  if self.Properties.Player then
    self.bobberPosition = FishingRequestsBus.Event.GetBobberPosition(self.Properties.Player)
    self:StartParticleAtBobberPosition(self.emitters.bobber, self.Properties.Particle_Fail)
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.Player, "Stop_Fishg_LineTension")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.Player, "Stop_Fishg_Reel")
    AudioUtilsBus.Broadcast.ExecuteAudioTriggerAtPositionWithOptions("Play_Fishg_BobberImpact", self.bobberPosition, self.audioOptions)
  end
end
function PlayerState_Fishing:OnFishSwamAway()
  if self.Properties.Player then
    self.bobberPosition = FishingRequestsBus.Event.GetBobberPosition(self.Properties.Player)
    self:StartParticleAtBobberPosition(self.emitters.bobber, self.Properties.Particle_Fail)
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.Player, "Stop_Fishg_LineTension")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.Player, "Stop_Fishg_Reel")
  end
end
function PlayerState_Fishing:OnFishCaught()
  if self.Properties.Player then
    self.bobberPosition = FishingRequestsBus.Event.GetBobberPosition(self.Properties.Player)
    self:StartParticleAttachedToEntity(self.emitters.fish, self.Properties.Particle_Splash)
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.Player, "Stop_Fishg_LineTension")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.Player, "Stop_Fishg_Reel")
  end
end
function PlayerState_Fishing:OnFishingEnded()
  if self.Properties.Player then
    self:StartParticleAttachedToEntity(self.emitters.fish, self.Properties.Particle_Splash)
    local kill = false
    for k, v in pairs(self.emitters) do
      self:StopEmitter(v, kill)
    end
    self.fishEntityId = nil
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.Player, "Stop_UI_Fishg_Clicks")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.Player, "Stop_Fishg_LineTension")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.Player, "Stop_Fishg_Reel")
  end
end
return PlayerState_Fishing
