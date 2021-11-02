local PlayerVitalScript = {
  Properties = {}
}
function PlayerVitalScript:OnActivate()
  if self.VitalsComponentBusHandler == nil then
    self.VitalsComponentBusHandler = VitalsComponentNotificationBus.Connect(self, TransformBus.Event.GetRootId(self.entityId))
  end
  if self.StaminaComponentBusHandler == nil then
    self.StaminaComponentBusHandler = StaminaComponentNotificationBus.Connect(self, self.entityId)
  end
  self.rootPlayerEntity = TransformBus.Event.GetRootId(self.entityId)
  self.isLocalPlayer = PlayerComponentRequestsBus.Event.IsLocalPlayer(self.rootPlayerEntity)
  if self.isLocalPlayer == true then
    if VitalsComponentRequestBus.Event.IsDeathsDoor(self.entityId) then
      DynamicBus.mixStateBus.Event.onMixStateChanged(self.rootPlayerEntity, "DeathsDoor")
    elseif VitalsComponentRequestBus.Event.IsDead(self.entityId) then
      DynamicBus.mixStateBus.Event.onMixStateChanged(self.rootPlayerEntity, "Dead")
    else
      DynamicBus.mixStateBus.Event.onMixStateChanged(self.rootPlayerEntity, "Default")
    end
  end
end
function PlayerVitalScript:OnHealthChanged(float)
  local currentHealth = Math.Round(float)
  local healthMax = VitalsComponentRequestBus.Event.GetHealthMax(self.entityId)
  local healthRTPC = currentHealth * 100 / healthMax
  AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.rootPlayerEntity, "Health", healthRTPC)
end
function PlayerVitalScript:OnDrinkChanged(float)
  local thirstValue = Math.Round(float)
  AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.rootPlayerEntity, "Thirst", thirstValue)
end
function PlayerVitalScript:OnFoodChanged(float)
  local hungerValue = Math.Round(float)
  AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.rootPlayerEntity, "Hunger", hungerValue)
end
function PlayerVitalScript:OnStaminaChanged(float)
  local staminaValue = Math.Round(float)
  AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.rootPlayerEntity, "Stamina", staminaValue)
end
function PlayerVitalScript:OnDeathsDoorChanged(bool, float)
  if self.isLocalPlayer == true then
    if bool == true then
      DynamicBus.mixStateBus.Event.onMixStateChanged(self.rootPlayerEntity, "DeathsDoor")
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.rootPlayerEntity, "Play_Impact_DeathsDoor_LocPlayer")
    else
      DynamicBus.mixStateBus.Event.onMixStateChanged(self.rootPlayerEntity, "Default")
    end
  end
end
function PlayerVitalScript:OnDeath()
  if self.isLocalPlayer == true then
    DynamicBus.mixStateBus.Event.onMixStateChanged(self.rootPlayerEntity, "Dead")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.rootPlayerEntity, "Play_Impact_Death_LocPlayer")
  end
end
function PlayerVitalScript:OnRespawn()
  if self.isLocalPlayer == true then
    DynamicBus.mixStateBus.Event.onMixStateChanged(self.rootPlayerEntity, "Default")
  end
end
function PlayerVitalScript:OnDeactivate()
  if self.VitalsComponentBusHandler ~= nil then
    self.VitalsComponentBusHandler:Disconnect()
    self.VitalsComponentBusHandler = nil
  end
  if self.StaminaComponentBusHandler ~= nil then
    self.StaminaComponentBusHandler:Disconnect()
    self.StaminaComponentBusHandler = nil
  end
end
return PlayerVitalScript
