local DarknessWaveBlast = {
  Properties = {
    distanceThreshold = {
      default = 40,
      description = "Player distance from object required to spawn sound",
      order = 1
    },
    wwiseBank = {
      default = "",
      description = "Soundbank name",
      order = 2
    },
    wwiseEvent = {
      default = "",
      description = "Event to trigger",
      order = 3
    },
    spawnSound = {
      default = false,
      description = "should we spawn a sound at a location, or use a bone? If true, make sure preload is set to audioload in the ATL!",
      order = 4
    },
    distanceBehindPlayer = {
      default = 10,
      description = "Distance opposite the source that the sound should spawn",
      order = 5
    }
  }
}
function DarknessWaveBlast:OnActivate()
  self.dataLayer = RequireScript("LyShineUI.UiDataLayer")
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId ~= nil then
      self.playerEntityId = playerEntityId
    end
  end)
  local playerLocation = TransformBus.Event.GetWorldTranslation(self.playerEntityId)
  self.parentEntityId = TransformBus.Event.GetParentId(self.entityId)
  self.parentWorldPosition = TransformBus.Event.GetWorldTranslation(self.parentEntityId)
  if self.parentWorldPosition ~= nil then
    TransformBus.Event.SetWorldTranslation(self.entityId, self.parentWorldPosition)
  end
  self.shockwaveWorldPosition = TransformBus.Event.GetWorldTranslation(self.entityId)
  local distance = Vector3.GetDistance(playerLocation, self.shockwaveWorldPosition)
  local difference = playerLocation - self.shockwaveWorldPosition
  if distance <= self.Properties.distanceThreshold and distance ~= nil then
    Vector3.Normalize(difference)
    difference = difference * self.Properties.distanceBehindPlayer
    playerLocation.x = playerLocation.x + difference.x
    playerLocation.y = playerLocation.y + difference.y
    playerLocation.z = playerLocation.z + 2
    if not self.Properties.spawnSound then
      AudioPreloadComponentRequestBus.Event.LoadPreload(self.entityId, self.Properties.wwiseBank)
      local rtpcValue = distance / 344
      AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.entityId, "RTPC_Shockwave_Delay", rtpcValue)
      TransformBus.Event.SetWorldTranslation(self.entityId, playerLocation)
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, self.Properties.wwiseEvent)
    else
      local audioOptions = AudioTriggerOptions()
      AudioUtilsBus.Broadcast.ExecuteAudioTriggerAtPositionWithOptions(self.Properties.wwiseEvent, playerLocation, audioOptions)
    end
  else
    return
  end
end
function DarknessWaveBlast:OnDeactivate()
  AudioPreloadComponentRequestBus.Event.UnloadPreload(self.entityId, self.Properties.wwiseBank)
  if self.dataLayer then
    self.dataLayer:UnregisterObservers(self)
    self.dataLayer = nil
  end
end
return DarknessWaveBlast
