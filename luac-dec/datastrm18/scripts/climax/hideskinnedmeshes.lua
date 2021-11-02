local AdjustSkinnedMeshesVisibility = {
  Properties = {
    Meshes = {
      default = {
        EntityId()
      }
    },
    Show = {default = false},
    Trigger = {
      default = EntityId(),
      description = "If trigger is set, it means this is triggered off of enter"
    }
  },
  meshNotifications = {},
  triggerAreaHandler = nil
}
function AdjustSkinnedMeshesVisibility:OnActivate()
  if self.Properties.Trigger:IsValid() then
    self.triggerAreaHandler = TriggerAreaNotificationBus.Connect(self, self.Properties.Trigger)
  else
    for i = 0, #self.Properties.Meshes do
      self.meshNotifications[self.Properties.Meshes[i]] = MeshComponentNotificationBus.Connect(self, self.Properties.Meshes[i])
    end
  end
end
function AdjustSkinnedMeshesVisibility:OnTriggerAreaEntered(enteringEntityId)
  self:ShowMeshes(self.Properties.Show)
  if self.triggerAreaHandler ~= nil then
    self.triggerAreaHandler:Disconnect()
    self.triggerAreaHandler = nil
  end
end
function AdjustSkinnedMeshesVisibility:OnDeactivate()
  if self.triggerAreaHandler ~= nil then
    self.triggerAreaHandler:Disconnect()
    self.triggerAreaHandler = nil
  end
  for entityId, handler in pairs(self.meshNotifications) do
    handler:Disconnect()
    self.meshNotifications[entityId] = nil
  end
  self.meshNotifications = {}
end
function AdjustSkinnedMeshesVisibility:OnMeshCreated()
  local entityId = MeshComponentNotificationBus.GetCurrentBusId()
  MeshComponentRequestBus.Event.SetVisibility(entityId, self.Properties.Show)
  ParticleComponentRequestBus.Event.Enable(entityId, self.Properties.Show)
end
function AdjustSkinnedMeshesVisibility:ShowMeshes(show)
  for _, entityId in pairs(self.Properties.Meshes) do
    MeshComponentRequestBus.Event.SetVisibility(entityId, show)
    ParticleComponentRequestBus.Event.Enable(entityId, show)
  end
end
return AdjustSkinnedMeshesVisibility
