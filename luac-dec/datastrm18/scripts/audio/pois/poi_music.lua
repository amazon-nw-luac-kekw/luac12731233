require("Scripts.Utils.TimingUtils")
local POIMusic = {
  Properties = {
    poiMusicTag = {
      default = "AncientLighthouse",
      description = "String used to tell the Music system what slice this is"
    }
  }
}
function POIMusic:OnActivate()
  self:RegisterLocalPlayer()
  if self.audioAITrackerBusHandler == nil then
    self.audioAITrackerBusHandler = DynamicBus.audioAITrackerBus.Connect(self.entityId, self)
  end
end
function POIMusic:RegisterLocalPlayer()
  TimingUtils:Delay(self.entityId, 8, function()
    self.dataLayer = RequireScript("LyShineUI.UiDataLayer")
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
      if playerEntityId ~= nil then
        self.playerEntityId = playerEntityId
      end
      DynamicBus.audioAITrackerBus.Event.OnPOIMusicActivated(self.playerEntityId, self.entityId, self.Properties.poiMusicTag)
    end)
  end)
end
function POIMusic:OnDeactivate()
  DynamicBus.audioAITrackerBus.Event.OnPOIMusicDeactivated(self.playerEntityId, self.entityId, self.Properties.poiMusicTag)
  if self.dataLayer then
    self.dataLayer:UnregisterObservers(self)
    self.dataLayer = nil
  end
end
return POIMusic
