local StructureScript = {
  Properties = {
    TriggerOnce = {default = false}
  }
}
function StructureScript:OnActivate()
  self.alreadyTriggeredEnter = false
  self.alreadyTriggeredExit = false
  self.triggerAreaBusHandler = TriggerAreaNotificationBus.Connect(self, self.entityId)
end
function StructureScript:OnTriggerAreaEntered(entityId)
  if (not self.Properties.TriggerOnce or self.Properties.TriggerOnce and not self.alreadyTriggeredEnter) and TagComponentRequestBus.Event.HasTag(entityId, 2866540111) and PlayerComponentRequestsBus.Event.IsLocalPlayer then
    local children = TransformBus.Event.GetChildren(self.entityId)
    for i = 1, #children do
      local childEntityId = children[i]
      AudioTriggerComponentRequestBus.Event.Play(childEntityId)
    end
    self.alreadyTriggeredEnter = true
  end
end
function StructureScript:OnTriggerAreaExited(entityId)
  if (not self.Properties.TriggerOnce or self.Properties.TriggerOnce and not self.alreadyTriggeredExit) and TagComponentRequestBus.Event.HasTag(entityId, 2866540111) and PlayerComponentRequestsBus.Event.IsLocalPlayer then
    local children = TransformBus.Event.GetChildren(self.entityId)
    for i = 1, #children do
      local childEntityId = children[i]
      AudioTriggerComponentRequestBus.Event.Stop(childEntityId)
      AudioTriggerComponentRequestBus.Event.KillAllTriggers(childEntityId)
    end
    self.alreadyTriggeredExit = true
  end
end
function StructureScript:OnDeactivate()
  AudioTriggerComponentRequestBus.Event.KillAllTriggers(self.entityId)
  self.triggerAreaBusHandler:Disconnect()
end
return StructureScript
