NPC_Base_Idle = {
  Properties = {
    NPC = {
      default = EntityId()
    }
  }
}
function NPC_Base_Idle:OnActivate()
  self.meshNotificiationHandler = MeshComponentNotificationBus.Connect(self, self.Properties.NPC)
end
function NPC_Base_Idle:OnDeactivate()
  if self.meshNotificiationHandler then
    self.meshNotificiationHandler:Disconnect()
    self.meshNotificiationHandler = nil
  end
  if self.transformNotificationHandler then
    self.transformNotificationHandler:Disconnect()
    self.transformNotificationHandler = nil
  end
  self:VFX_Off()
end
function NPC_Base_Idle:OnMeshCreated()
  if self:IsTransformValid() then
    self:VFX_On()
  else
    self.transformNotificationHandler = TransformNotificationBus.Connect(self, self.Properties.NPC)
  end
end
function NPC_Base_Idle:OnTransformChanged(localTm, worldTm)
  if self.transformNotificationHandler then
    self.transformNotificationHandler:Disconnect()
    self.transformNotificationHandler = nil
  end
  self:VFX_On()
end
function NPC_Base_Idle:IsTransformValid()
  local pos = TransformBus.Event.GetWorldTranslation(self.entityId)
  return pos:IsZero() == false
end
return NPC_Base_Idle
