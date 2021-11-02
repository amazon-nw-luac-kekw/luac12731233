local Structure_Enter_Exit = {
  Properties = {
    area_trigger_entity = {
      default = EntityId(),
      description = "Main area trigger entity used to detect player entering and exiting",
      order = 1
    },
    Enabled_3D = {
      default = true,
      description = "Won't play the 3D sounds bellow if disabled",
      order = 2
    },
    Enabled_2D = {
      default = false,
      description = "Will play the 2D sounds bellow if enabled",
      order = 3
    },
    onEnter_audio_entity = {
      default = EntityId(),
      description = "Bell Trigger Entity",
      order = 4
    },
    onEnter_3D_audio_ATL_name = {
      default = "",
      description = "Name of the sound to play on enter at location",
      order = 5
    },
    onExit_audio_entity = {
      default = EntityId(),
      description = "Bell Trigger Entity",
      order = 6
    },
    onExit_3D_audio_ATL_name = {
      default = "",
      description = "Name of the sound to play on exit at location",
      order = 7
    },
    onEnter_2D_audio_ATL_name = {
      default = "",
      description = "Name of the sound to play on enter in 2D only for local player",
      order = 8
    },
    onExit_2D_audio_ATL_name = {
      default = "",
      description = "Name of the sound to play on exit in 2D only for local player",
      order = 9
    },
    LocalPlayerOnly = {
      default = true,
      description = "Script will only work for local player. If disabled, any players can use it",
      order = 10
    }
  }
}
function Structure_Enter_Exit:OnActivate()
  self.triggerAreaBusHandler = TriggerAreaNotificationBus.Connect(self, self.Properties.area_trigger_entity)
  self.dataLayer = RequireScript("LyShineUI.UiDataLayer")
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId ~= nil then
      self.playerEntityId = playerEntityId
    end
  end)
end
function Structure_Enter_Exit:OnTriggerAreaEntered(entityId)
  if self.playerEntityId == entityId and self.Properties.LocalPlayerOnly then
    self:PlaySoundsOnEnter(self.playerEntityId)
  else
    self:PlaySoundsOnEnter(entityId)
  end
end
function Structure_Enter_Exit:OnTriggerAreaExited(entityId)
  if self.playerEntityId == entityId and self.Properties.LocalPlayerOnly then
    self:PlaySoundsOnExit(self.playerEntityId)
  else
    self:PlaySoundsOnExit(entityId)
  end
end
function Structure_Enter_Exit:PlaySoundsOnEnter(entityId)
  if TagComponentRequestBus.Event.HasTag(entityId, 2866540111) then
    if self.Properties.onEnter_audio_entity ~= nil and self.Properties.Enabled_3D == true and self.Properties.onEnter_3D_audio_ATL_name ~= nil then
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.onEnter_audio_entity, self.Properties.onEnter_3D_audio_ATL_name)
    end
    if self.Properties.Enabled_2D == true and self.Properties.onEnter_2D_audio_ATL_name ~= nil then
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.onEnter_audio_entity, self.Properties.onEnter_2D_audio_ATL_name)
    end
  end
end
function Structure_Enter_Exit:PlaySoundsOnExit(entityId)
  if TagComponentRequestBus.Event.HasTag(entityId, 2866540111) then
    if self.Properties.onExit_audio_entity ~= nil and self.Properties.Enabled_3D == true and self.Properties.onExit_3D_audio_ATL_name ~= nil then
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.onExit_audio_entity, self.Properties.onExit_3D_audio_ATL_name)
    end
    if self.Properties.Enabled_2D == true and self.Properties.onExit_2D_audio_ATL_name ~= nil then
      AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.onExit_audio_entity, self.Properties.onExit_2D_audio_ATL_name)
    end
  end
end
function Structure_Enter_Exit:OnDeactivate()
  if self.triggerAreaBusHandler ~= nil then
    self.triggerAreaBusHandler:Disconnect()
    self.triggerAreaBusHandler = nil
  end
  if self.dataLayer then
    self.dataLayer:UnregisterObservers(self)
    self.dataLayer = nil
  end
end
return Structure_Enter_Exit
