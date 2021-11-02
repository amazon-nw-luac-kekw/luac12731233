local cuttrunkScript = {
  Properties = {
    Root_Entity = {
      default = EntityId(),
      description = "Root entity for the tree slice",
      order = 0
    },
    TreeSliding_Audio = {
      default = EntityId(),
      description = "Entity for the tree sliding sound",
      order = 1
    },
    EarlyImpactTimeout = {
      default = 0.5,
      description = "Timeout to ignore first collision",
      order = 2
    }
  }
}
function cuttrunkScript:OnActivate()
  self.TreeHits = 0
  self.deltaTime = 0
  if self.PhysicsComponentBusHandler == nil then
    self.PhysicsComponentBusHandler = PhysicsComponentNotificationBus.Connect(self, self.Properties.Root_Entity)
  end
  if not self.tickBusHandler then
    self.tickBusHandler = TickBus.Connect(self)
  end
end
function cuttrunkScript:OnCollision(Collision)
  if self.deltaTime >= self.Properties.EarlyImpactTimeout then
    if self.TreeHits == 0 then
      AudioTriggerComponentRequestBus.Event.Stop(self.entityId)
      AudioSwitchComponentRequestBus.Event.SetSwitchState(self.Properties.TreeSliding_Audio, "object_velocity_tracking", "on")
    end
    self.TreeHits = self.TreeHits + 1
  end
end
function cuttrunkScript:OnTick(deltaTime, timePoint)
  self.deltaTime = self.deltaTime + deltaTime
end
function cuttrunkScript:OnDeactivate()
  self.TreeHits = 0
  if self.PhysicsComponentBusHandler ~= nil then
    self.PhysicsComponentBusHandler:Disconnect()
    self.PhysicsComponentBusHandler = nil
  end
  if self.tickBusHandler then
    self.tickBusHandler:Disconnect()
    self.tickBusHandler = nil
  end
end
return cuttrunkScript
