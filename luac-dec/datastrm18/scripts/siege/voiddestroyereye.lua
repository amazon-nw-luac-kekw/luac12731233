VoidDestroyerEye = {
  beamAttackBusHandler = nil,
  rootEntityId = nil,
  Properties = {
    beamSourceEntity = {
      default = EntityId(),
      description = "Beam Source EntityId",
      order = 1
    },
    beamHitEntity = {
      default = EntityId(),
      description = "Beam Hit EntityId",
      order = 2
    }
  }
}
function VoidDestroyerEye:OnActivate()
  self.deltaTime = 0
  self.onSetBeamActive = 0
  self.rootEntityId = TransformBus.Event.GetRootId(self.entityId)
  self.beamAttackBusHandler = BeamAttackComponentNotificationBus.Connect(self, self.rootEntityId)
  if self.tickBusHandler == nil then
    self.tickBusHandler = TickBus.Connect(self)
  end
end
function VoidDestroyerEye:OnDeactivate()
  if self.tickBusHandler ~= nil then
    self.tickBusHandler:Disconnect()
    self.tickBusHandler = nil
  end
  if self.beamAttackBusHandler ~= nil then
    self.beamAttackBusHandler:Disconnect()
  end
end
function VoidDestroyerEye:OnSetBeamActive(nameCRC, active)
  self.nameCRC = nameCRC
  if active then
    self.onSetBeamActive = self.onSetBeamActive + 1
  else
    self.onSetBeamActive = self.onSetBeamActive - 1
  end
  if nameCRC == 298341484 and self.onSetBeamActive == 0 then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.beamSourceEntity, "Play_SFX_CorruptedVoidSpike_Beam_ChargeUp")
  end
  if not active then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.beamHitEntity, "Stop_SFX_CorruptedVoidSpike_Beam_LockOn")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.beamHitEntity, "Stop_SFX_CorruptedVoidSpike_Beam_Damage")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.beamSourceEntity, "Stop_SFX_CorruptedVoidSpike_Beam_Eye1")
  end
  if nameCRC == 688205597 and active then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.beamHitEntity, "Stop_SFX_CorruptedVoidSpike_Beam_Damage")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.beamSourceEntity, "Play_SFX_CorruptedVoidSpike_Beam_Eye1")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.beamHitEntity, "Play_SFX_CorruptedVoidSpike_Beam_LockOn")
  elseif nameCRC == 298341484 and active then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.beamHitEntity, "Play_SFX_CorruptedVoidSpike_Beam_Damage")
  elseif nameCRC == 298341484 and not active then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.beamHitEntity, "Stop_SFX_CorruptedVoidSpike_Beam_Damage")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.beamHitEntity, "Stop_SFX_CorruptedVoidSpike_Beam_Eye1")
  end
end
function VoidDestroyerEye:OnTick(deltaTime, timePoint)
  self.deltaTime = self.deltaTime + deltaTime
  if self.deltaTime > 0.1 and self.onSetBeamActive > 0 and self.nameCRC ~= nil then
    local hitPos = BeamAttackComponentRequestBus.Event.GetBeamHitPos(self.rootEntityId, self.nameCRC)
    if self.Properties.beamHitEntity ~= nil and hitPos ~= nil then
      TransformBus.Event.SetWorldTranslation(self.Properties.beamHitEntity, hitPos)
    end
    self.deltaTime = 0
  end
end
return VoidDestroyerEye
