local FTUE_Beach_Audio = {
  Properties = {}
}
function FTUE_Beach_Audio:OnActivate()
  AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState("Music_Shell", "Mx_Shell_FTUE")
  if self.Properties.preloadNames ~= nil then
    for idx, preloadName in pairs(self.Properties.preloadNames) do
      AudioPreloadComponentRequestBus.Event.LoadPreload(self.entityId, preloadName)
    end
  end
end
function FTUE_Beach_Audio:OnDeactivate()
  if self.Properties.preloadNames ~= nil then
    for idx, preloadName in pairs(self.Properties.preloadNames) do
      AudioPreloadComponentRequestBus.Event.UnloadPreload(self.entityId, preloadName)
    end
  end
end
return FTUE_Beach_Audio
