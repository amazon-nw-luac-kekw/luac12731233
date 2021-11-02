local ManyLoopsSoundScript = {
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
    },
    TriggerOnce = {default = false}
  }
}
function ManyLoopsSoundScript:OnActivate()
  self.triggerAreaBusHandler = TriggerAreaNotificationBus.Connect(self, self.Properties.rootEntity)
  self.alreadyTriggeredEnter = false
  self.alreadyTriggeredExit = false
end
function ManyLoopsSoundScript:OnTriggerAreaEntered(entityId)
  if TagComponentRequestBus.Event.HasTag(entityId, 2866540111) and PlayerComponentRequestsBus.Event.IsLocalPlayer and (not self.Properties.TriggerOnce or self.Properties.TriggerOnce and not self.alreadyTriggeredEnter) then
    if self.Properties.preloadName ~= "" then
      AudioPreloadComponentRequestBus.Event.LoadPreload(self.entityId, self.Properties.preloadName)
    end
    AudioTriggerComponentRequestBus.Event.Play(self.entityId)
    local children = TransformBus.Event.GetChildren(self.entityId)
    for i = 1, #children do
      local childEntityId = children[i]
      AudioTriggerComponentRequestBus.Event.Play(childEntityId)
    end
    self.alreadyTriggeredEnter = true
  end
end
function ManyLoopsSoundScript:OnTriggerAreaExited(entityId)
  if TagComponentRequestBus.Event.HasTag(entityId, 2866540111) and PlayerComponentRequestsBus.Event.IsLocalPlayer and (not self.Properties.TriggerOnce or self.Properties.TriggerOnce and not self.alreadyTriggeredExit) then
    local children = TransformBus.Event.GetChildren(self.entityId)
    for i = 1, #children do
      local childEntityId = children[i]
      AudioTriggerComponentRequestBus.Event.Stop(childEntityId)
      AudioTriggerComponentRequestBus.Event.KillAllTriggers(childEntityId)
    end
    AudioTriggerComponentRequestBus.Event.Stop(self.entityId)
    if self.Properties.preloadName ~= "" then
      AudioPreloadComponentRequestBus.Event.UnloadPreload(self.entityId, self.Properties.preloadName)
    end
    self.alreadyTriggeredExit = true
  end
end
function ManyLoopsSoundScript:OnDeactivate()
  AudioTriggerComponentRequestBus.Event.KillAllTriggers(self.entityId)
  if self.Properties.preloadName ~= "" then
    AudioPreloadComponentRequestBus.Event.UnloadPreload(self.entityId, self.Properties.preloadName)
  end
  self.triggerAreaBusHandler:Disconnect()
end
return ManyLoopsSoundScript
