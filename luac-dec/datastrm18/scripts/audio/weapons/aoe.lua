local AOE = {
  Properties = {
    TriggerAreaEntityId = {
      default = EntityId(),
      description = "Trigger Area EntityId",
      order = 2
    },
    OnActivate_AudioShapeTriggerName = {
      default = "",
      description = "Name of the ATL event to play when the AOE slice activates",
      order = 3
    },
    Global_State_Name = {
      default = "",
      description = "Name of the state changing when the player enters and leaves the AOE slice",
      order = 4
    },
    Global_State_Value_Inside = {
      default = "",
      description = "Inside the AOE state value",
      order = 5
    },
    Global_State_Value_Outside = {
      default = "",
      description = "Outside the AOE state value",
      order = 6
    },
    TriggerAreaEntity_Switch_Name = {
      default = "",
      description = "Name of the switch changing on the trigger area entity",
      order = 7
    },
    TriggerAreaEntity_Switch_Value_Inside = {
      default = "",
      description = "trigger area entity inside switch value",
      order = 8
    },
    TriggerAreaEntity_Switch_Value_Outside = {
      default = "",
      description = "trigger area entity outside switch value",
      order = 9
    },
    Entity_Switch_Name = {
      default = "",
      description = "Name of the switch changing on the entity entering and leaving the AOE slice",
      order = 10
    },
    Entity_Switch_Value_Inside = {
      default = "",
      description = "Inside the AOE switch value",
      order = 11
    },
    Entity_Switch_Value_Outside = {
      default = "",
      description = "Outside the AOE switch value",
      order = 12
    },
    RTPC_Name = {
      default = "",
      description = "Name of the RTPC changing inside and outside the AOE slice",
      order = 13
    },
    RTPC_Inside_AOE_Value = {
      default = "",
      description = "Inside the AOE rtpc value",
      order = 14
    },
    RTPC_Outside_AOE_Value = {
      default = "",
      description = "Outside the AOE rtpc value",
      order = 15
    },
    OnEnter_AudioTriggerName = {
      default = "",
      description = "Name of the ATL event playing when going inside the AOE slice",
      order = 16
    },
    OnExit_AudioTriggerName = {
      default = "",
      description = "Name of the ATL event playing when going outside the AOE slice",
      order = 17
    }
  }
}
function AOE:OnActivate()
  if self.triggerAreaBusHandler == nil then
    self.triggerAreaBusHandler = TriggerAreaNotificationBus.Connect(self, self.Properties.TriggerAreaEntityId)
  end
  self.dataLayer = RequireScript("LyShineUI.UiDataLayer")
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId ~= nil then
      self.playerEntityId = playerEntityId
      self.playerInsideAOE = nil
    end
  end)
end
function AOE:OnTriggerAreaActivated(entityId)
  if entityId == self.Properties.TriggerAreaEntityId and self.Properties.OnActivate_AudioShapeTriggerName ~= "" then
    AudioTriggerComponentRequestBus.Event.SetAudioContinuesToPlayAfterEntityDestruction(self.Properties.TriggerAreaEntityId, 1)
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.TriggerAreaEntityId, tostring(self.Properties.OnActivate_AudioShapeTriggerName))
  end
end
function AOE:OnTriggerAreaEntered(entityId)
  if entityId == self.playerEntityId then
    self.playerInsideAOE = true
    if self.Properties.TriggerAreaEntity_Switch_Name ~= "" and self.Properties.TriggerAreaEntity_Switch_Value_Inside ~= "" then
      AudioSwitchComponentRequestBus.Event.SetSwitchState(self.Properties.TriggerAreaEntityId, tostring(self.Properties.TriggerAreaEntity_Switch_Name), tostring(self.Properties.TriggerAreaEntity_Switch_Value_Inside))
    end
    if self.Properties.Global_State_Name ~= "" and self.Properties.Global_State_Value_Inside ~= "" then
      AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState(tostring(self.Properties.Global_State_Name), tostring(self.Properties.Global_State_Value_Inside))
    end
    if self.Properties.Entity_Switch_Name ~= "" and self.Properties.Entity_Switch_Value_Inside ~= "" then
      AudioSwitchComponentRequestBus.Event.SetSwitchState(entityId, tostring(self.Properties.Entity_Switch_Name), tostring(self.Properties.Entity_Switch_Value_Inside))
    end
    if self.Properties.OnEnter_AudioTriggerName ~= "" then
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(entityId, tostring(self.Properties.OnEnter_AudioTriggerName))
    end
    if self.Properties.RTPC_Name ~= "" and self.Properties.RTPC_Inside_AOE_Value ~= "" then
      AudioRtpcComponentRequestBus.Event.SetRtpcValue(entityId, tostring(self.Properties.RTPC_Name), tostring(self.Properties.RTPC_Inside_AOE_Value))
    end
    DynamicBus.AOE.Event.onAOE_Entered(entityId, true)
  end
end
function AOE:OnTriggerAreaExited(entityId)
  if entityId == self.playerEntityId then
    self.playerInsideAOE = false
    if self.Properties.TriggerAreaEntity_Switch_Name ~= "" and self.Properties.TriggerAreaEntity_Switch_Value_Outside ~= "" then
      AudioSwitchComponentRequestBus.Event.SetSwitchState(self.Properties.TriggerAreaEntityId, tostring(self.Properties.TriggerAreaEntity_Switch_Name), tostring(self.Properties.TriggerAreaEntity_Switch_Value_Outside))
    end
    if self.Properties.Global_State_Name ~= "" and self.Properties.Global_State_Value_Outside ~= "" then
      AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState(tostring(self.Properties.Global_State_Name), tostring(self.Properties.Global_State_Value_Outside))
    end
    if self.Properties.Entity_Switch_Name ~= "" and self.Properties.Entity_Switch_Value_Outside ~= "" then
      AudioSwitchComponentRequestBus.Event.SetSwitchState(entityId, tostring(self.Properties.Entity_Switch_Name), tostring(self.Properties.Entity_Switch_Value_Outside))
    end
    if self.Properties.OnExit_AudioTriggerName ~= "" then
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(entityId, tostring(self.Properties.OnExit_AudioTriggerName))
    end
    if self.Properties.RTPC_Name ~= "" and self.Properties.RTPC_Outside_AOE_Value ~= "" then
      AudioRtpcComponentRequestBus.Event.SetRtpcValue(entityId, tostring(self.Properties.RTPC_Name), tostring(self.Properties.RTPC_Outside_AOE_Value))
    end
    DynamicBus.AOE.Event.onAOE_Entered(entityId, false)
  end
end
function AOE:OnDeactivate()
  if self.playerInsideAOE == true and self.Properties.Global_State_Name ~= "" and self.Properties.Global_State_Value_Outside ~= "" then
    AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState(tostring(self.Properties.Global_State_Name), tostring(self.Properties.Global_State_Value_Outside))
  end
  if self.Properties.TriggerAreaEntityId ~= "" then
    AudioTriggerComponentRequestBus.Event.Stop(self.Properties.TriggerAreaEntityId)
  end
  if self.triggerAreaBusHandler ~= nil then
    self.triggerAreaBusHandler:Disconnect()
    self.triggerAreaBusHandler = nil
  end
  if self.dataLayer then
    self.dataLayer:UnregisterObservers(self)
    self.dataLayer = nil
  end
end
return AOE
