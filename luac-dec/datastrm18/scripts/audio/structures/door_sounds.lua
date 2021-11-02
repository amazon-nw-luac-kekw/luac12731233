local DoorScript = {
  Properties = {
    rootEntity = {
      default = EntityId(),
      description = "Root EntityId",
      order = 1
    },
    doorDragEntityA = {
      default = EntityId(),
      description = "Door EntityId",
      order = 2
    },
    doorDragEntityB = {
      default = EntityId(),
      description = "Door EntityId",
      order = 3
    }
  }
}
function DoorScript:OnActivate()
  self.DoorEventsHandler = DoorEventsBus.Connect(self, self.Properties.rootEntity)
  self.entityName = GameEntityContextRequestBus.Broadcast.GetEntityName(self.Properties.rootEntity)
  self.doorSize = nil
  if self.entityName == "Structure_Wall_T1_Gate" then
    self.doorSize = "Small1"
    AudioPreloadComponentRequestBus.Event.LoadPreload(self.entityId, "Struct_Gate_Small_01")
    AudioPreloadComponentRequestBus.Event.LoadPreload(self.entityId, "Struct_Gate_Small_Shared")
  elseif self.entityName == "Structure_Wall_T2_Gate" then
    self.doorSize = "Med1"
    AudioPreloadComponentRequestBus.Event.LoadPreload(self.entityId, "Struct_Gate_Med_00")
    AudioPreloadComponentRequestBus.Event.LoadPreload(self.entityId, "Struct_Gate_Med_Shared")
  else
    self.doorSize = "Big1"
    AudioPreloadComponentRequestBus.Event.LoadPreload(self.entityId, "Struct_Gate_Med_00")
    AudioPreloadComponentRequestBus.Event.LoadPreload(self.entityId, "Struct_Gate_Med_Shared")
    AudioPreloadComponentRequestBus.Event.LoadPreload(self.entityId, "Struct_Gate_Big_00")
    AudioPreloadComponentRequestBus.Event.LoadPreload(self.entityId, "Struct_Gate_Big_Shared")
  end
end
function DoorScript:OnStartDoorRotation(rootEntityId, doorEntityId, direction)
  AudioTriggerComponentRequestBus.Event.Play(doorEntityId)
  local startchildren = TransformBus.Event.GetChildren(doorEntityId)
  if startchildren ~= nil then
    for i = 1, #startchildren do
      self.startChildEntityId = startchildren[i]
      AudioTriggerComponentRequestBus.Event.Play(self.startChildEntityId)
    end
  end
  if direction == 0 then
    if self.doorSize == "Small1" then
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Play_Gate_" .. tostring(self.doorSize) .. "_Open_Start")
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.startChildEntityId, "Play_Gate_Drag_" .. tostring(self.doorSize) .. "_Lp")
    elseif self.doorSize == "Med1" then
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Play_Gate_" .. tostring(self.doorSize) .. "_Open_Start")
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.startChildEntityId, "Play_Gate_Drag_" .. tostring(self.doorSize) .. "_Lp")
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Play_Gate_Creaks_Med1_Lp")
    elseif self.doorSize == "Big1" then
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Play_Gate_Med1_Open_Start")
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Play_Gate_Creaks_Med1_Lp")
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.startChildEntityId, "Play_Gate_Drag_" .. tostring(self.doorSize) .. "_Lp")
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.startChildEntityId, "Play_Gate_" .. tostring(self.doorSize) .. "_Open_Start")
    end
  elseif self.doorSize == "Small1" then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Play_Gate_" .. tostring(self.doorSize) .. "_Close_Start")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.startChildEntityId, "Play_Gate_Drag_" .. tostring(self.doorSize) .. "_Lp")
  elseif self.doorSize == "Med1" then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Play_Gate_" .. tostring(self.doorSize) .. "_Close_Start")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.startChildEntityId, "Play_Gate_Drag_" .. tostring(self.doorSize) .. "_Lp")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Play_Gate_Creaks_Med1_Lp")
  elseif self.doorSize == "Big1" then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Play_Gate_Med1_Close_Start")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Play_Gate_Creaks_Med1_Lp")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.startChildEntityId, "Play_Gate_Drag_" .. tostring(self.doorSize) .. "_Lp")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Play_Gate_" .. tostring(self.doorSize) .. "_Close_Start")
  end
end
function DoorScript:OnEndDoorRotation(rootEntityId, doorEntityId, direction)
  AudioTriggerComponentRequestBus.Event.Play(doorEntityId)
  local endchildren = TransformBus.Event.GetChildren(doorEntityId)
  if endchildren ~= nil then
    for i = 1, #endchildren do
      self.endChildEntityId = endchildren[i]
      AudioTriggerComponentRequestBus.Event.Play(self.endChildEntityId)
    end
  end
  if direction == 0 then
    if self.doorSize == "Small1" then
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.endChildEntityId, "Play_Gate_" .. tostring(self.doorSize) .. "_Open_Stop")
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Stop_Gate_" .. tostring(self.doorSize) .. "_Open_Start")
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.endChildEntityId, "Stop_Gate_Drag_" .. tostring(self.doorSize) .. "_Lp")
    elseif self.doorSize == "Med1" then
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.endChildEntityId, "Play_Gate_" .. tostring(self.doorSize) .. "_Open_Stop")
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Stop_Gate_" .. tostring(self.doorSize) .. "_Open_Start")
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.endChildEntityId, "Stop_Gate_Drag_" .. tostring(self.doorSize) .. "_Lp")
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Stop_Gate_Creaks_Med1_Lp")
    elseif self.doorSize == "Big1" then
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.endChildEntityId, "Play_Gate_Med1_Open_Stop")
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Stop_Gate_Med1_Open_Start")
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Stop_Gate_Creaks_Med1_Lp")
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.endChildEntityId, "Stop_Gate_Drag_" .. tostring(self.doorSize) .. "_Lp")
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Stop_Gate_" .. tostring(self.doorSize) .. "_Open_Start")
    end
  elseif self.doorSize == "Small1" then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.endChildEntityId, "Play_Gate_" .. tostring(self.doorSize) .. "_Close_Stop")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Stop_Gate_" .. tostring(self.doorSize) .. "_Close_Start")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.endChildEntityId, "Stop_Gate_Drag_" .. tostring(self.doorSize) .. "_Lp")
  elseif self.doorSize == "Med1" then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.endChildEntityId, "Play_Gate_" .. tostring(self.doorSize) .. "_Close_Stop")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Stop_Gate_" .. tostring(self.doorSize) .. "_Close_Start")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.endChildEntityId, "Stop_Gate_Drag_" .. tostring(self.doorSize) .. "_Lp")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Stop_Gate_Creaks_Med1_Lp")
  elseif self.doorSize == "Big1" then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.endChildEntityId, "Play_Gate_Med1_Close_Stop")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.endChildEntityId, "Play_Gate_" .. tostring(self.doorSize) .. "_Close_Stop")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Stop_Gate_Med1_Close_Start")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Stop_Gate_Creaks_Med1_Lp")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.endChildEntityId, "Stop_Gate_Drag_" .. tostring(self.doorSize) .. "_Lp")
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(doorEntityId, "Stop_Gate_" .. tostring(self.doorSize) .. "_Close_Start")
  end
end
function DoorScript:OnDoorSpeedChanged(rootEntityId, doorEntityId, speed)
  if doorEntityId ~= nil then
    AudioRtpcComponentRequestBus.Event.SetRtpcValue(doorEntityId, "door_speed", speed)
    AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.Properties.doorDragEntityA, "door_speed", speed)
    AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.Properties.doorDragEntityB, "door_speed", speed)
  end
end
function DoorScript:OnDeactivate()
  if self.DoorEventsHandler ~= nil then
    self.DoorEventsHandler:Disconnect()
  end
  if self.doorSize == "Small1" then
    AudioPreloadComponentRequestBus.Event.UnloadPreload(self.entityId, "Struct_Gate_Small_01")
    AudioPreloadComponentRequestBus.Event.UnloadPreload(self.entityId, "Struct_Gate_Small_Shared")
  elseif self.doorSize == "Med1" then
    AudioPreloadComponentRequestBus.Event.UnloadPreload(self.entityId, "Struct_Gate_Med_00")
    AudioPreloadComponentRequestBus.Event.UnloadPreload(self.entityId, "Struct_Gate_Med_Shared")
  elseif self.doorSize == "Big1" then
    AudioPreloadComponentRequestBus.Event.UnloadPreload(self.entityId, "Struct_Gate_Med_00")
    AudioPreloadComponentRequestBus.Event.UnloadPreload(self.entityId, "Struct_Gate_Med_Shared")
    AudioPreloadComponentRequestBus.Event.UnloadPreload(self.entityId, "Struct_Gate_Big_00")
    AudioPreloadComponentRequestBus.Event.UnloadPreload(self.entityId, "Struct_Gate_Big_Shared")
  end
end
return DoorScript
