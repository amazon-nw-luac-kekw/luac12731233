local MusicTriggersDarkness = {
  Properties = {
    switch = {
      default = "",
      description = "The State Group to trigger on activate. We will use 'MX_Darkness' for Darkness events",
      order = 1
    },
    state = {
      default = "",
      description = "The State Group to trigger on activate.",
      order = 2
    },
    wwiseEvent = {
      default = "",
      description = "Event to trigger, if we need one",
      order = 3
    },
    entityToRegister = {
      default = EntityId(),
      description = "Using this to validate that the player is in a specific area",
      order = 4
    }
  }
}
function MusicTriggersDarkness:OnActivate()
  self.dataLayer = RequireScript("LyShineUI.UiDataLayer")
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId ~= nil then
      self.playerEntityId = playerEntityId
    end
  end)
  if self.audioDarknessMusicBusHandler == nil then
    self.audioDarknessMusicBusHandler = DynamicBus.audioDarknessMusicBus.Connect(self.entityId, self)
  end
  DynamicBus.audioDarknessMusicBus.Event.DarknessMusicEventDB(self.playerEntityId, self.Properties.switch, self.Properties.state, self.Properties.wwiseEvent, self.Properties.entityToRegister)
end
function MusicTriggersDarkness:OnDeactvate()
  if self.dataLayer then
    self.dataLayer:UnregisterObservers(self)
    self.dataLayer = nil
  end
end
return MusicTriggersDarkness
