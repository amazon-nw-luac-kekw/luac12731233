require("Scripts.Utils.TimingUtils")
local dialogueNPC_audio = {
  Properties = {
    area_trigger_entity = {
      default = EntityId(),
      description = "Interact area trigger entity used to detect player entering and exiting the NPC area shape",
      order = 1
    },
    dialogue_entity = {
      default = EntityId(),
      description = "Entity with the audio trigger component to play the dialogue from",
      order = 2
    }
  }
}
function dialogueNPC_audio:OnActivate()
  self.voTag = nil
  self.characterName = nil
  self.isVoPlaying = false
  self.triggerAreaBusHandler = TriggerAreaNotificationBus.Connect(self, self.Properties.area_trigger_entity)
  if self.npcDialogueBusHandler == nil then
    self.npcDialogueBusHandler = DynamicBus.npcDialogueBus.Connect(self.entityId, self)
  end
end
function dialogueNPC_audio:OnTriggerAreaEntered(entityId)
  if TagComponentRequestBus.Event.HasTag(entityId, 2866540111) and PlayerComponentRequestsBus.Event.IsLocalPlayer then
    LookAtTargetComponentRequestBus.Event.SetLookTarget(self.Properties.area_trigger_entity, entityId)
  end
end
function dialogueNPC_audio:OnDialogueTriggered(voTag, characterName)
  if self.isVoPlaying then
    self:OnDialogueStopped(self.voTag)
  end
  if characterName ~= nil and characterName ~= "" then
    self.characterName = characterName
  else
    Debug.Log("##### name is missing from the VO loc sheet")
  end
  self.voTag = voTag
  local eventName = "Play_" .. voTag
  self.audioTriggerBusHandlerForDialogueEntity = AudioTriggerComponentNotificationBus.Connect(self, self.Properties.dialogue_entity)
  TimelineControllerComponentRequestBus.Event.TriggerTimelineOverrideForCrc(self.Properties.area_trigger_entity, 3853627462, 171732436, Math.CreateCrc32(self.voTag))
  self.isVoPlaying = true
end
function dialogueNPC_audio:OnDialogueStopped(voTag)
  self:DisconnectHandlers()
  local eventName = "Stop_" .. voTag
  self.isVoPlaying = false
end
function dialogueNPC_audio:OnDialogueInterrupted()
  if self.isVoPlaying then
    self:OnDialogueStopped(self.voTag)
    local eventName = self.characterName and "Play_" .. self.characterName .. "_Interrupt"
  end
end
function dialogueNPC_audio:DisconnectHandlers()
  if self.audioTriggerBusHandlerForDialogueEntity ~= nil then
    self.audioTriggerBusHandlerForDialogueEntity:Disconnect()
    self.audioTriggerBusHandlerForDialogueEntity = nil
  end
end
function dialogueNPC_audio:OnTriggerAreaExited(entityId)
  if TagComponentRequestBus.Event.HasTag(entityId, 2866540111) and PlayerComponentRequestsBus.Event.IsLocalPlayer then
    LookAtTargetComponentRequestBus.Event.ClearLookTarget(self.Properties.area_trigger_entity)
    self:OnDialogueInterrupted()
  end
end
function dialogueNPC_audio:OnTriggerFinishedCallbackId(callbackId)
  if string.match(callbackId, self.voTag) then
    self.isVoPlaying = false
  end
end
function dialogueNPC_audio:OnDeactivate()
  if self.triggerAreaBusHandler ~= nil then
    self.triggerAreaBusHandler:Disconnect()
    self.triggerAreaBusHandler = nil
  end
  self:DisconnectHandlers()
  AudioTriggerComponentRequestBus.Event.KillAllTriggers(self.Properties.dialogue_entity)
end
return dialogueNPC_audio
