local BoneAudio = {
  Properties = {
    audioEntity = {
      default = {
        EntityId()
      },
      description = "Entities you want to send sound to, put these in the same order as the events you are listening for",
      order = 1
    },
    characterEventName = {
      default = {""},
      description = "Name of the CE to listen for",
      order = 2
    },
    wwiseEvent = {
      default = {""},
      description = "Name of the CE to listen for",
      order = 3
    },
    spawnSound = {
      default = false,
      description = "should we spawn a sound at a location, or keep it attached to the bone? If true, make sure preload is set to audioload in the ATL!",
      order = 4
    }
  }
}
function BoneAudio:OnActivate()
  if self.Properties.audioEntity == "" or self.Properties.audioEntity == nil then
    Debug.Log("##### - BoneAudio audioEntity is nil")
    return
  end
  if self.Properties.characterEventName == "" or self.Properties.characterEventName == nil then
    Debug.Log("##### - BoneAudio characterEventName is nil")
    return
  end
  if self.Properties.wwiseEvent == "" or self.Properties.wwiseEvent == nil then
    Debug.Log("##### - BoneAudio wwiseEvent is nil")
    return
  end
  self.characterEventBusHandler = CharacterEventBus.Connect(self, self.entityId)
end
function BoneAudio:TriggerCharacterEvent(string, bool)
  if bool == true then
    for key, event in pairs(self.Properties.characterEventName) do
      if self.Properties.characterEventName[key] == string then
        local audioEntityKey = key - 1
        if not self.Properties.spawnSound then
          AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.audioEntity[audioEntityKey], self.Properties.wwiseEvent[key])
        else
          local audioOptions = AudioTriggerOptions()
          audioOptions.obstructionType = eAudioObstructionType_SingleRay
          local impactPos = TransformBus.Event.GetWorldTranslation(self.Properties.audioEntity[audioEntityKey])
          AudioUtilsBus.Broadcast.ExecuteAudioTriggerAtPositionWithOptions(self.Properties.wwiseEvent[key], impactPos, audioOptions)
        end
      end
    end
  end
  if string == self.Properties.characterEventName and bool == true then
    if not self.Properties.spawnSound then
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.audioEntity, self.Properties.wwiseEvent)
    else
      local audioOptions = AudioTriggerOptions()
      audioOptions.obstructionType = eAudioObstructionType_SingleRay
      local impactPos = TransformBus.Event.GetWorldTranslation(self.Properties.audioEntity)
      AudioUtilsBus.Broadcast.ExecuteAudioTriggerAtPositionWithOptions(self.Properties.wwiseEvent, impactPos, audioOptions)
    end
  end
end
function BoneAudio:OnDeactivate()
  if self.characterEventBusHandler ~= nil then
    self.characterEventBusHandler:Disconnect()
    self.characterEventBusHandler = nil
  end
end
return BoneAudio
