local audio_triggers = {}
function audio_triggers:OnActivate()
  self.trackEventHandler = SequenceComponentNotificationBus.Connect(self, self.entityId)
  self.mainMenuBusHandler = UiMainMenuBus.Connect(self, self.entityId)
  UiMainMenuRequestBus.Broadcast.RequestCustomizableCharacterEntityId()
end
function audio_triggers:SetCustomizableCharacterEntityId(entityId)
  self.characterEntityId = entityId
  self.playerGender = nil
end
function audio_triggers:OnTrackEventTriggered(event, value)
  if event ~= nil and value ~= nil and event ~= "Music_FTUE" then
    if event == "AudioQTE" then
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, tostring(value))
    elseif event == "AudioStart" or event == "AudioStop" then
      if self.characterEntityId ~= nil and self.playerGender == nil then
        self.playerGender = CustomizableCharacterRequestBus.Event.GetGender(self.characterEntityId)
        AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState("Gender", self.playerGender)
      end
      AudioUtilsBus.Broadcast.ExecuteGlobalAudioTrigger(tostring(value), true, EntityId())
    end
  end
end
function audio_triggers:OnDeactivate()
  if self.trackEventHandler ~= nil then
    self.trackEventHandler:Disconnect()
  end
  if self.mainMenuBusHandler then
    self.mainMenuBusHandler:Disconnect()
    self.mainMenuBusHandler = nil
  end
end
return audio_triggers
