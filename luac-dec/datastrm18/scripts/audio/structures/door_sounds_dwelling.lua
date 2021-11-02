local DoorDwellingScript = {
  Properties = {
    rootEntity = {
      default = EntityId(),
      description = "Root EntityId",
      order = 1
    },
    doorDragEntity = {
      default = EntityId(),
      description = "Door EntityId",
      order = 2
    }
  }
}
function DoorDwellingScript:OnActivate()
  self.DoorEventsHandler = DoorEventsBus.Connect(self, self.Properties.rootEntity)
  AudioPreloadComponentRequestBus.Event.LoadPreload(self.entityId, "Struct_Gate_Small_01")
  AudioPreloadComponentRequestBus.Event.LoadPreload(self.entityId, "Struct_Gate_Small_Shared")
end
function DoorDwellingScript:OnStartDoorRotation(rootEntityId, doorEntityId, direction)
  if doorEntityId == self.entityId then
    if direction == 0 then
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Play_Gate_Small1a_Open_Start")
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.doorDragEntity, "Play_Gate_Drag_Small1a_Dirt_Lp")
    else
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Play_Gate_Small1a_Close_Start")
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.doorDragEntity, "Play_Gate_Drag_Small1a_Dirt_Lp")
    end
  end
end
function DoorDwellingScript:OnEndDoorRotation(rootEntityId, doorEntityId, direction)
  if doorEntityId == self.entityId then
    if direction == 0 then
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.doorDragEntity, "Play_Gate_Small1a_Open_Stop")
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Stop_Gate_Small1a_Open_Start")
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.doorDragEntity, "Stop_Gate_Drag_Small1a_Dirt_Lp")
    else
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.doorDragEntity, "Play_Gate_Small1a_Close_Stop")
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Stop_Gate_Small1a_Close_Start")
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.doorDragEntity, "Stop_Gate_Drag_Small1a_Dirt_Lp")
    end
  end
end
function DoorDwellingScript:OnDoorSpeedChanged(rootEntityId, doorEntityId, speed)
  AudioRtpcComponentRequestBus.Event.SetRtpcValue(doorEntityId, "door_speed", speed)
  AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.Properties.doorDragEntity, "door_speed", speed)
end
function DoorDwellingScript:OnDeactivate()
  if self.DoorEventsHandler ~= nil then
    self.DoorEventsHandler:Disconnect()
  end
  AudioPreloadComponentRequestBus.Event.UnloadPreload(self.entityId, "Struct_Gate_Small_01")
  AudioPreloadComponentRequestBus.Event.UnloadPreload(self.entityId, "Struct_Gate_Small_Shared")
end
return DoorDwellingScript
