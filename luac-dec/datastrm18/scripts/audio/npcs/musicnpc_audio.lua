local MusicNPC_Audio = {
  Properties = {
    characterEventTable = {
      default = {""},
      description = "Name of the character event to listen for",
      order = 1
    },
    musicGroup = {
      default = {""},
      description = "Name of the music group",
      order = 2
    },
    musicState = {
      default = {""},
      description = "Name of the music state",
      order = 3
    }
  }
}
function MusicNPC_Audio:OnActivate()
  if self.Properties.characterEventTable == "" or self.Properties.characterEventTable == nil then
    Debug.Log("##### - MusicNPC_Audio characterEventTable is nil")
    return
  end
  if self.Properties.musicGroup == "" or self.Properties.musicGroup == nil then
    Debug.Log("##### - MusicNPC_Audio musicGroup is nil")
    return
  end
  if self.Properties.musicState == "" or self.Properties.musicState == nil then
    Debug.Log("##### - MusicNPC_Audio musicState is nil")
    return
  end
  self.dataLayer = RequireScript("LyShineUI.UiDataLayer")
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId ~= nil then
      self.playerEntityId = playerEntityId
    end
  end)
  self.characterEventBusHandler = CharacterEventBus.Connect(self, self.entityId)
end
function MusicNPC_Audio:TriggerCharacterEvent(eventName, shouldPlay)
  if string.match(eventName, "MX_") and shouldPlay then
    for i = 1, #self.Properties.characterEventTable do
      if self.Properties.characterEventTable[i] == eventName then
        DynamicBus.switchMusicBus.Event.SwitchMusicDB(self.playerEntityId, self.Properties.musicGroup[i], self.Properties.musicState[i])
      end
    end
  end
end
function MusicNPC_Audio:OnDeactivate()
  if self.characterEventBusHandler ~= nil then
    self.characterEventBusHandler:Disconnect()
    self.characterEventBusHandler = nil
  end
  if self.dataLayer then
    self.dataLayer:UnregisterObservers(self)
    self.dataLayer = nil
  end
end
return MusicNPC_Audio
