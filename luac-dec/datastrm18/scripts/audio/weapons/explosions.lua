local explosions = {
  Properties = {
    AdditionalPreload = {
      default = "",
      description = "Additional name of audio preload to execute.",
      order = 0
    },
    AdditionalSound = {
      default = "",
      description = "Additional name of audio trigger to execute.",
      order = 1
    },
    WeaponTypeRTPC = {
      default = 0,
      description = "Set the weapon type value to change the sound's behavior",
      order = 2
    }
  }
}
function explosions:OnActivate()
  local position = TransformBus.Event.GetWorldTranslation(self.entityId)
  local positionXY = Vector2.ConstructFromValues(position.x, position.y)
  local tractAtPosition = MapComponentBus.Broadcast.GetTractAtPosition(positionXY)
  AudioSwitchComponentRequestBus.Event.SetSwitchState(self.entityId, "Tract_switch", tostring(tractAtPosition))
  if self.Properties.WeaponTypeRTPC ~= 0 then
    AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.entityId, "WeaponType", self.Properties.WeaponTypeRTPC)
  end
  if self.Properties.AdditionalSound ~= nil and self.Properties.AdditionalPreload ~= nil then
    AudioPreloadComponentRequestBus.Event.LoadPreload(self.entityId, self.Properties.AdditionalPreload)
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, self.Properties.AdditionalSound)
  end
end
function explosions:OnDeactivate()
  if self.Properties.AdditionalPreload ~= nil then
    AudioPreloadComponentRequestBus.Event.UnloadPreload(self.entityId, self.Properties.AdditionalPreload)
  end
end
return explosions
