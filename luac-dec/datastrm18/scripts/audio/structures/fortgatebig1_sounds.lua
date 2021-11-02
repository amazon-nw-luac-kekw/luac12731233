local FortGateBig1Script = {
  Properties = {
    rootEntity = {
      default = EntityId(),
      description = "Root EntityId",
      order = 1
    },
    doorBaseEntityA = {
      default = EntityId(),
      description = "Door base EntityId",
      order = 2
    },
    doorBaseEntityB = {
      default = EntityId(),
      description = "Door base EntityId",
      order = 3
    },
    doorDragEntityA = {
      default = EntityId(),
      description = "Door drag EntityId",
      order = 4
    },
    doorDragEntityB = {
      default = EntityId(),
      description = "Door drag EntityId",
      order = 5
    }
  }
}
function FortGateBig1Script:OnActivate()
  self.DoorEventsHandler = DoorEventsBus.Connect(self, self.Properties.rootEntity)
  AudioTriggerComponentRequestBus.Event.Play(self.entityId)
  AudioTriggerComponentRequestBus.Event.Play(self.Properties.doorBaseEntityA)
  AudioTriggerComponentRequestBus.Event.Play(self.Properties.doorBaseEntityB)
  AudioTriggerComponentRequestBus.Event.Play(self.Properties.doorDragEntityA)
  AudioTriggerComponentRequestBus.Event.Play(self.Properties.doorDragEntityB)
end
function FortGateBig1Script:OnSetEnvironment()
  AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.entityId, "ENV_INT_01_Medium", 1)
  AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.Properties.doorBaseEntityA, "ENV_INT_01_Medium", 1)
  AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.Properties.doorBaseEntityB, "ENV_INT_01_Medium", 1)
  AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.Properties.doorDragEntityA, "ENV_INT_01_Medium", 1)
  AudioEnvironmentComponentRequestBus.Event.SetEnvironmentAmount(self.Properties.doorDragEntityB, "ENV_INT_01_Medium", 1)
end
function FortGateBig1Script:OnStartDoorRotation(rootEntityId, doorEntityId, direction)
  self:OnSetEnvironment()
  if direction == 0 then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, "Play_Gate_Big1_Open_Start")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Play_Gate_Creaks_Big1_Lp")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.doorDragEntityA, "Play_Gate_Drag_Big1_Lp")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.doorDragEntityB, "Play_Gate_Drag_Big1_Lp")
  else
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Play_Gate_Creaks_Big1_Lp")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.doorDragEntityA, "Play_Gate_Drag_Big1_Lp")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.doorDragEntityB, "Play_Gate_Drag_Big1_Lp")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, "Play_Gate_Big1_Close_Start")
  end
end
function FortGateBig1Script:OnEndDoorRotation(rootEntityId, doorEntityId, direction)
  self:OnSetEnvironment()
  if direction == 0 then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, "Stop_Gate_Big1_Open_Start")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Stop_Gate_Creaks_Big1_Lp")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.doorDragEntityA, "Play_Gate_Big1_Open_Stop")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.doorDragEntityB, "Play_Gate_Big1_Open_Stop")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.doorDragEntityA, "Stop_Gate_Drag_Big1_Lp")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.doorDragEntityB, "Stop_Gate_Drag_Big1_Lp")
  else
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, "Play_Gate_Big1_Close_Stop")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, "Stop_Gate_Big1_Close_Start")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Stop_Gate_Creaks_Big1_Lp")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.doorDragEntityA, "Stop_Gate_Drag_Big1_Lp")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.doorDragEntityB, "Stop_Gate_Drag_Big1_Lp")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, "Stop_Gate_Big1_Close_Start")
  end
end
function FortGateBig1Script:OnDoorSpeedChanged(rootEntityId, doorEntityId, speed)
  if doorEntityId ~= nil then
    AudioRtpcComponentRequestBus.Event.SetRtpcValue(doorEntityId, "door_speed", speed)
    AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.Properties.doorDragEntityA, "door_speed", speed)
    AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.Properties.doorDragEntityB, "door_speed", speed)
  end
end
function FortGateBig1Script:OnDeactivate()
  if self.DoorEventsHandler ~= nil then
    self.DoorEventsHandler:Disconnect()
  end
end
return FortGateBig1Script
