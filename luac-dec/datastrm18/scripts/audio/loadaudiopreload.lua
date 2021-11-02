local LoadAudioPreload = {
  Properties = {
    preloadNames = {
      default = {""},
      description = "List of preload names to load."
    }
  }
}
function LoadAudioPreload:OnActivate()
  for idx, preloadName in pairs(self.Properties.preloadNames) do
    AudioPreloadComponentRequestBus.Event.LoadPreload(self.entityId, preloadName)
  end
end
function LoadAudioPreload:OnDeactivate()
  for idx, preloadName in pairs(self.Properties.preloadNames) do
    AudioPreloadComponentRequestBus.Event.UnloadPreload(self.entityId, preloadName)
  end
end
return LoadAudioPreload
