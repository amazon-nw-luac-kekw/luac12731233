local SubtitleNPC_Audio = {
  Properties = {
    duration = {
      default = {"5"},
      description = "change the duration of the subtitles displayed on screen",
      order = 1
    },
    characterEventTable = {
      default = {""},
      description = "Name of the character event to listen for",
      order = 2
    },
    locKeyTable = {
      default = {
        "simongrey_intro_line1"
      },
      description = "locKeyTable or Localization key found in the xml files",
      order = 3
    },
    area_trigger_entity = {
      default = EntityId(),
      description = "Entity with the audio trigger component",
      order = 4
    }
  }
}
function SubtitleNPC_Audio:OnActivate()
  if self.Properties.characterEventTable == "" or self.Properties.characterEventTable == nil then
    Debug.Log("##### - SubtitleNPC_Audio characterEventTable is nil")
    return
  end
  if self.Properties.locKeyTable == "" or self.Properties.locKeyTable == nil then
    Debug.Log("##### - SubtitleNPC_Audio locKeyTable is nil")
    return
  end
  self.isInside = nil
  self.characterEventBusHandler = CharacterEventBus.Connect(self, self.entityId)
  if self.Properties.area_trigger_entity ~= nil then
    self.triggerAreaBusHandler = TriggerAreaNotificationBus.Connect(self, self.Properties.area_trigger_entity)
  end
end
function SubtitleNPC_Audio:OnTriggerAreaEntered(entityId)
  if TagComponentRequestBus.Event.HasTag(entityId, 2866540111) and PlayerComponentRequestsBus.Event.IsLocalPlayer then
    self.isInside = true
  end
end
function SubtitleNPC_Audio:OnTriggerAreaExited(entityId)
  if TagComponentRequestBus.Event.HasTag(entityId, 2866540111) and PlayerComponentRequestsBus.Event.IsLocalPlayer then
    self.isInside = false
  end
end
function SubtitleNPC_Audio:TriggerCharacterEvent(eventName, shouldPlay)
  if self.isInside ~= false and shouldPlay then
    for i = 1, #self.Properties.characterEventTable do
      if self.Properties.characterEventTable[i] == eventName then
        local locKey = "@" .. tostring(self.Properties.locKeyTable[i])
        local notificationData = NotificationData()
        local speaker = LyShineScriptBindRequestBus.Broadcast.GetAttributeValueForKey(locKey, "speaker")
        notificationData.type = "Subtitle"
        notificationData.title = speaker
        notificationData.text = locKey
        notificationData.maximumDuration = 5
        UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
      end
    end
  end
end
function SubtitleNPC_Audio:DisconnectHandlers()
  if self.characterEventBusHandler ~= nil then
    self.characterEventBusHandler:Disconnect()
    self.characterEventBusHandler = nil
  end
  if self.triggerAreaBusHandler ~= nil then
    self.triggerAreaBusHandler:Disconnect()
    self.triggerAreaBusHandler = nil
  end
end
function SubtitleNPC_Audio:OnDeactivate()
  self:DisconnectHandlers()
end
return SubtitleNPC_Audio
