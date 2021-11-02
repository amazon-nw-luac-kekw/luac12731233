local GhostScript = {
  Properties = {}
}
function GhostScript:OnActivate()
  if self.triggerAreaBusHandler == nil then
    self.triggerAreaBusHandler = TriggerAreaNotificationBus.Connect(self, self.entityId)
  end
  if self.VitalsComponentBusHandler == nil then
    self.VitalsComponentBusHandler = VitalsComponentNotificationBus.Connect(self, self.entityId)
  end
  self.dataLayer = require("LyShineUI.UiDataLayer")
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId ~= nil then
      self.playerEntityId = playerEntityId
    end
  end)
end
function GhostScript:OnTriggerAreaEntered(entityId)
  if entityId == self.playerEntityId then
    DynamicBus.ghostZoneBus.Event.onEnterGhostzone(entityId, self.entityId)
  end
end
function GhostScript:OnTriggerAreaExited(entityId)
  if entityId == self.playerEntityId then
    DynamicBus.ghostZoneBus.Event.onExitGhostzone(entityId, self.entityId)
  end
end
function GhostScript:OnDeath()
  DynamicBus.ghostZoneBus.Event.onExitGhostzone(self.playerEntityId, self.entityId)
end
function GhostScript:OnDeactivate()
  if self.triggerAreaBusHandler ~= nil then
    self.triggerAreaBusHandler:Disconnect()
    self.triggerAreaBusHandler = nil
  end
  if self.VitalsComponentBusHandler ~= nil then
    self.VitalsComponentBusHandler:Disconnect()
    self.VitalsComponentBusHandler = nil
  end
  if self.dataLayer then
    self.dataLayer:UnregisterObservers(self)
    self.dataLayer = nil
  end
end
return GhostScript
