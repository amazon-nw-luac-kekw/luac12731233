local SetRTPCValueDistanceMoved = {
  Properties = {
    rtpcNames = {
      default = {""},
      description = "List of RTPC names to set the value of."
    },
    scalar = {
      default = 1,
      description = "Number to multiple the distance by before setting as the RTPC value."
    }
  }
}
function SetRTPCValueDistanceMoved:StartSettingRtpcValue()
  if not self.tickBusHandler then
    self.tickBusHandler = TickBus.Connect(self)
  end
end
function SetRTPCValueDistanceMoved:StopSettingRtpcValue()
  if self.tickBusHandler then
    self.tickBusHandler:Disconnect()
    self.tickBusHandler = nil
  end
end
function SetRTPCValueDistanceMoved:OnDeactivate()
  self:StopSettingRtpcValue()
end
function SetRTPCValueDistanceMoved:OnTick(deltaTime, timePoint)
  local localTranslation = TransformBus.Event.GetLocalTranslation(self.entityId)
  if not self.lastFrameTranslation then
    self.lastFrameTranslation = localTranslation
  end
  local deltaTranslation = localTranslation - self.lastFrameTranslation
  local deltaDistance = Vector3.GetLength(deltaTranslation)
  local rtpcValue = deltaDistance * self.Properties.scalar
  self.lastFrameTranslation = localTranslation
  for idx, rtpcName in pairs(self.Properties.rtpcNames) do
    AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.entityId, rtpcName, rtpcValue)
  end
end
return SetRTPCValueDistanceMoved
