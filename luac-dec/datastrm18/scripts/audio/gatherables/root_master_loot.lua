local rootmasterloot = {
  Properties = {
    Root_Entity = {
      default = EntityId(),
      description = "Root entity",
      order = 1
    },
    DepletedSFX_Entity = {
      default = EntityId(),
      description = "Root entity",
      order = 2
    },
    TriggerArea_Entity = {
      default = EntityId(),
      description = "Select the entity containing the area trigger component",
      order = 3
    },
    OnEnter_StateValue = {
      default = "",
      description = "State to be set on the player when entering the shape",
      order = 4
    },
    OnExit_StateValue = {
      default = "",
      description = "State to be set on the player when leaving the shape",
      order = 5
    },
    StateName = {
      default = "LootTickerType",
      description = "Name of the state group",
      order = 6
    }
  }
}
function rootmasterloot:OnActivate()
  self.dataLayer = RequireScript("LyShineUI.UiDataLayer")
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId ~= nil then
      self.playerEntityId = playerEntityId
    end
  end)
  if self.triggerAreaBusHandler == nil then
    self.triggerAreaBusHandler = TriggerAreaNotificationBus.Connect(self, self.Properties.TriggerArea_Entity)
  end
end
function rootmasterloot:OnTriggerAreaEntered(entityId)
  if entityId == self.playerEntityId then
    AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState(self.Properties.StateName, self.Properties.OnEnter_StateValue)
    AudioSwitchComponentRequestBus.Event.SetSwitchState(self.playerEntityId, self.Properties.StateName, self.Properties.OnEnter_StateValue)
  end
end
function rootmasterloot:OnTriggerAreaExited(entityId)
  if entityId == self.playerEntityId then
    AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState(self.Properties.StateName, self.Properties.OnExit_StateValue)
    AudioSwitchComponentRequestBus.Event.SetSwitchState(self.playerEntityId, self.Properties.StateName, self.Properties.OnExit_StateValue)
  end
end
function rootmasterloot:OnDeactivate()
  if self.triggerAreaBusHandler ~= nil then
    self.triggerAreaBusHandler:Disconnect()
    self.triggerAreaBusHandler = nil
  end
  if self.dataLayer then
    self.dataLayer:UnregisterObservers(self)
    self.dataLayer = nil
  end
end
return rootmasterloot
