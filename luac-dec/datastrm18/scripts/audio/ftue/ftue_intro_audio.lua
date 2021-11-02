local FTUE_Intro_Audio = {
  Properties = {
    preloadNames = {
      default = {""},
      description = "Preload name to load."
    }
  }
}
function FTUE_Intro_Audio:OnActivate()
  if self.Properties.preloadNames ~= nil then
    for idx, preloadName in pairs(self.Properties.preloadNames) do
      AudioPreloadComponentRequestBus.Event.LoadPreload(self.entityId, preloadName)
    end
  end
end
function FTUE_Intro_Audio:OnDeactivate()
  if self.Properties.preloadNames ~= nil then
    for idx, preloadName in pairs(self.Properties.preloadNames) do
      AudioPreloadComponentRequestBus.Event.UnloadPreload(self.entityId, preloadName)
    end
  end
end
return FTUE_Intro_Audio
