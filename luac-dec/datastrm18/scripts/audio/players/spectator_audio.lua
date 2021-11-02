local SpectatorScript = {
  Properties = {}
}
function SpectatorScript:OnActivate()
  self.dataLayer = RequireScript("LyShineUI.UiDataLayer")
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId ~= nil then
      self.playerEntityId = playerEntityId
    end
  end)
  DynamicBus.SpectatorBus.Event.onSpectatorChanged(self.playerEntityId, 1, self.entityId)
end
function SpectatorScript:OnDeactivate()
  DynamicBus.SpectatorBus.Event.onSpectatorChanged(self.playerEntityId, 0, self.entityId)
  if self.dataLayer then
    self.dataLayer:UnregisterObservers(self)
    self.dataLayer = nil
  end
end
return SpectatorScript
