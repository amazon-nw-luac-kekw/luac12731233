require("Scripts.Utils.TimingUtils")
local RTPCSpline = {
  Properties = {
    AudioTrigger = {
      default = EntityId(),
      description = "AudioTrigger entity."
    },
    RTPC = {
      default = EntityId(),
      description = "RTPCComponent entity."
    },
    RTPCEvent = {
      default = "",
      description = "The RPTC value to update."
    },
    TriggerArea = {
      default = EntityId(),
      description = "Trigger area that enables/disables this script."
    },
    Spline = {
      default = EntityId(),
      description = "Spline entity to sample."
    }
  }
}
function RTPCSpline:OnActivate()
  if self.tickBusHandler == nil then
    self.triggerAreaBusHandler = TriggerAreaNotificationBus.Connect(self, self.Properties.TriggerArea)
  end
  self.deltaTime = 0
  if self.Properties.Preloader == EntityId() then
    self.Properties.Preloader = self.entityId
  end
  if self.Properties.AudioTrigger == EntityId() then
    self.Properties.AudioTrigger = self.entityId
  end
  if self.Properties.Spline == EntityId() then
    self.Properties.Spline = self.entityId
  end
  if self.Properties.TriggerArea == EntityId() then
    self.Properties.TriggerArea = self.entityId
  end
  if self.Properties.RTPC == EntityId() then
    self.Properties.RTPC = self.entityId
  end
end
function RTPCSpline:OnTriggerAreaEntered(entityId)
  if TagComponentRequestBus.Event.HasTag(entityId, 2866540111) then
    AudioTriggerComponentRequestBus.Event.Play(self.Properties.AudioTrigger)
    self.playerEntity = entityId
    if self.tickBusHandler == nil then
      self.tickBusHandler = TickBus.Connect(self)
    end
  end
end
function RTPCSpline:OnTriggerAreaExited(entityId)
  if TagComponentRequestBus.Event.HasTag(entityId, 2866540111) then
    if self.tickBusHandler ~= nil then
      self.tickBusHandler:Disconnect()
      self.tickBusHandler = nil
    end
    AudioTriggerComponentRequestBus.Event.KillAllTriggers(self.Properties.AudioTrigger)
    AudioTriggerComponentRequestBus.Event.Stop(self.Properties.AudioTrigger)
  end
end
function RTPCSpline:OnTick(deltaTime, timePoint)
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
    local splineLength = spline:GetSplineLength()
    local distAlongSpline = splineLength - spline:GetLength(splineAddr)
    local normDist = 1 - distAlongSpline / splineLength
    AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.Properties.RTPC, self.Properties.RTPCEvent, normDist)
    self.deltaTime = 0
  end
end
function RTPCSpline:OnDeactivate()
  if self.tickBusHandler ~= nil then
    self.tickBusHandler:Disconnect()
    self.tickBusHandler = nil
  end
  if self.triggerAreaBusHandler ~= nil then
    self.triggerAreaBusHandler:Disconnect()
    self.triggerAreaBusHandler = nil
  end
end
return RTPCSpline
