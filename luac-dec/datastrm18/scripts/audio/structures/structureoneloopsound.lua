local OneLoopSoundScript = {
  Properties = {
    preloadName = {
      default = "",
      description = "Name of the preload.",
      order = 0
    },
    rootEntity = {
      default = EntityId(),
      description = "Root EntityId",
      order = 1
    }
  }
}
function OneLoopSoundScript:OnActivate()
  self.triggerAreaBusHandler = TriggerAreaNotificationBus.Connect(self, self.Properties.rootEntity)
end
function OneLoopSoundScript:OnTriggerAreaEntered(entityId)
  if TagComponentRequestBus.Event.HasTag(entityId, 2866540111) and PlayerComponentRequestsBus.Event.IsLocalPlayer then
    AudioPreloadComponentRequestBus.Event.LoadPreload(self.entityId, self.Properties.preloadName)
    AudioTriggerComponentRequestBus.Event.Play(self.entityId)
  end
end
function OneLoopSoundScript:OnTriggerAreaExited(entityId)
  if TagComponentRequestBus.Event.HasTag(entityId, 2866540111) and PlayerComponentRequestsBus.Event.IsLocalPlayer then
    AudioTriggerComponentRequestBus.Event.Stop(self.entityId)
    AudioPreloadComponentRequestBus.Event.UnloadPreload(self.entityId, self.Properties.preloadName)
  end
end
function OneLoopSoundScript:OnDeactivate()
  AudioTriggerComponentRequestBus.Event.KillAllTriggers(self.entityId)
  AudioPreloadComponentRequestBus.Event.UnloadPreload(self.entityId, self.Properties.preloadName)
  self.triggerAreaBusHandler:Disconnect()
end
return OneLoopSoundScript
