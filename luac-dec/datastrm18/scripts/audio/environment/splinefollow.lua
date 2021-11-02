local SplineFollow = {
  Properties = {
    Follower = {
      default = EntityId(),
      description = "Entity to follow the spline."
    },
    Spline = {
      default = EntityId(),
      description = "Spline entity to sample."
    },
    delay = {
      default = 0,
      description = "Delay in seconds before audio trigger is executed."
    }
  }
}
function SplineFollow:OnActivate()
  if self.tickBusHandler == nil then
    self.triggerAreaBusHandler = TriggerAreaNotificationBus.Connect(self, self.Properties.Follower)
  end
  self.deltaTime = 0
end
function SplineFollow:OnTriggerAreaEntered(entityId)
  if TagComponentRequestBus.Event.HasTag(entityId, 2866540111) and PlayerComponentRequestsBus.Event.IsLocalPlayer then
    AudioPreloadComponentRequestBus.Event.LoadPreload(self.Properties.Follower, "Waterfall_Large")
    AudioTriggerComponentRequestBus.Event.Play(self.Properties.Follower)
    self.playerEntity = entityId
    self.tickBusHandler = TickBus.Connect(self)
  end
end
function SplineFollow:OnTriggerAreaExited(entityId)
  if TagComponentRequestBus.Event.HasTag(entityId, 2866540111) and PlayerComponentRequestsBus.Event.IsLocalPlayer then
    if self.tickBusHandler ~= nil then
      self.tickBusHandler:Disconnect()
      self.tickBusHandler = nil
    end
    AudioTriggerComponentRequestBus.Event.KillAllTriggers(self.Properties.Follower)
    AudioTriggerComponentRequestBus.Event.Stop(self.Properties.Follower)
    AudioPreloadComponentRequestBus.Event.UnloadPreload(self.Properties.Follower, "Waterfall_Large")
  end
end
function SplineFollow:OnTick(deltaTime, timePoint)
  self.deltaTime = self.deltaTime + deltaTime
  if self.deltaTime > 0.2 then
    local spline = SplineComponentRequestBus.Event.GetSpline(self.Properties.Spline)
    if spline == nil then
      Debug.Log("no spline")
      return Vector3.CreateZero()
    end
    local splineTransform = TransformBus.Event.GetWorldTM(self.Properties.Spline)
    local playerTransform = TransformBus.Event.GetWorldTM(self.playerEntity)
    local playerTransformLocal = splineTransform:GetInverseFast() * playerTransform
    local queryResult = spline:GetNearestAddressPosition(playerTransformLocal:GetTranslation())
    local splineAddr = queryResult.splineAddress
    local splinePosition = spline:GetPosition(splineAddr)
    splinePosition = splineTransform * splinePosition
    local newTransform = TransformBus.Event.GetWorldTM(self.Properties.Follower)
    newTransform:SetTranslation(splinePosition)
    TransformBus.Event.SetWorldTM(self.Properties.Follower, newTransform)
    self.deltaTime = 0
  end
end
function SplineFollow:OnDeactivate()
  if self.tickBusHandler ~= nil then
    self.tickBusHandler:Disconnect()
    self.tickBusHandler = nil
  end
  if self.triggerAreaBusHandler ~= nil then
    self.triggerAreaBusHandler:Disconnect()
    self.triggerAreaBusHandler = nil
  end
end
return SplineFollow
