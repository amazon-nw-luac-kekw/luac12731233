local SpawnSoundAtLocation = {
  Properties = {
    shouldUseSelf = {
      default = false,
      description = "True = the sound plays off itself; False = Sound is spawned on a dummy object - this is a fix for sounds truncating on spell slices",
      order = 1
    },
    LocationEntityId = {
      default = EntityId(),
      description = "Entity you want to use the location of",
      order = 2
    },
    AudioPreload = {
      default = "",
      description = "Name of bank you need to load",
      order = 3
    },
    OnActivate_AudioTriggerName = {
      default = "",
      description = "Name of the ATL event to play when the AOE slice activates",
      order = 4
    }
  }
}
function SpawnSoundAtLocation:OnActivate()
  if self.Properties.AudioPreload ~= nil then
    AudioPreloadComponentRequestBus.Event.LoadPreload(self.entityId, self.Properties.AudioPreload)
  end
  if self.Properties.shouldUseSelf then
    AudioTriggerComponentRequestBus.Event.SetAudioContinuesToPlayAfterEntityDestruction(self.entityId, 1)
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, self.Properties.OnActivate_AudioTriggerName)
  else
    local soundLocation = TransformBus.Event.GetWorldTranslation(self.Properties.LocationEntityId)
    local audioOptions = AudioTriggerOptions()
    audioOptions.obstructionType = eAudioObstructionType_SingleRay
    AudioUtilsBus.Broadcast.ExecuteAudioTriggerAtPositionWithOptions(self.Properties.OnActivate_AudioTriggerName, soundLocation, audioOptions)
  end
end
function SpawnSoundAtLocation:OnDeactivate()
  if self.Properties.AudioPreload ~= nil then
    AudioPreloadComponentRequestBus.Event.UnloadPreload(self.entityId, self.Properties.AudioPreload)
  end
end
return SpawnSoundAtLocation
