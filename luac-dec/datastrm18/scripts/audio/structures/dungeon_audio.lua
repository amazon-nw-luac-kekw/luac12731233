local Dungeon_Script = {
  Properties = {
    startMusic = {
      default = false,
      description = "If checked in, music will start when the script gets activated",
      order = 1
    },
    dungeon_name = {
      default = "Windsward_Dun01",
      description = "Reekwater_Dun01, Edengrove_Dun01, Everfall_Dun01, Shattered_Mountain_Dun01 etc.",
      order = 2
    },
    Music_group = {
      default = "Music_Dungeon",
      description = "Name of the Music state group",
      order = 3
    },
    Ambient_group = {
      default = "",
      description = "Name of the Ambient state group",
      order = 4
    },
    Switch_name = {
      default = "",
      description = "Name of the switch group",
      order = 5
    },
    RTPC_name = {
      default = "",
      description = "Name of the RTPC name",
      order = 6
    },
    enter_Music_state = {
      default = "",
      description = "Value set on Enter",
      order = 7
    },
    enter_Ambient_state = {
      default = "",
      description = "Value set on Enter",
      order = 8
    },
    enter_Switch_value = {
      default = "",
      description = "Value set on Enter",
      order = 9
    },
    enter_RTPC_value = {
      default = "",
      description = "Value set on Enter",
      order = 10
    },
    exit_Music_state = {
      default = "",
      description = "Value set on Exit",
      order = 11
    },
    exit_Ambient_state = {
      default = "",
      description = "Value set on Exit",
      order = 12
    },
    exit_Switch_value = {
      default = "",
      description = "Value set on Exit",
      order = 13
    },
    exit_RTPC_value = {
      default = "",
      description = "Value set on Exit",
      order = 14
    }
  }
}
function Dungeon_Script:OnActivate()
  self.triggerAreaBusHandler = TriggerAreaNotificationBus.Connect(self, self.entityId)
  self.dataLayer = RequireScript("LyShineUI.UiDataLayer")
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId ~= nil then
      self.playerEntityId = playerEntityId
    end
  end)
  if self.Properties.startMusic then
    DynamicBus.dungeonAudioBus.Event.onDungeon_Started(self.playerEntityId, self.Properties.dungeon_name)
  end
end
function Dungeon_Script:OnTriggerAreaEntered(entityId)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer then
    DynamicBus.dungeonAudioBus.Event.onDungeonArea_Interact(self.playerEntityId, self.Properties.dungeon_name, self.Properties.Music_group, self.Properties.enter_Music_state, false)
  end
end
function Dungeon_Script:OnTriggerAreaExited(entityId)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer then
    DynamicBus.dungeonAudioBus.Event.onDungeonArea_Interact(self.playerEntityId, self.Properties.dungeon_name, self.Properties.Music_group, self.Properties.exit_Music_state, true)
  end
end
function Dungeon_Script:OnDeactivate()
  if self.triggerAreaBusHandler ~= nil then
    self.triggerAreaBusHandler:Disconnect()
    self.triggerAreaBusHandler = nil
  end
  if self.dataLayer then
    self.dataLayer:UnregisterObservers(self)
    self.dataLayer = nil
  end
end
return Dungeon_Script
