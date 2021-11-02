PlayerState_LevelUp = {
  Properties = {
    Player = {
      default = EntityId()
    }
  },
  FX_01 = "cFX_Player_States.LevelUp_01",
  FX_02 = "cFX_Player_States.LevelUp_02",
  Joint_1 = "Xform",
  Joint_2 = "reference_look",
  SFXLocalEvent = "Play_GPUI_LevelUp",
  SFXRemoteEvent = "Play_GPUI_LevelUp_Remote",
  PreloadName = "GPUI_LevelUp"
}
function PlayerState_LevelUp:OnActivate()
  self.progressionBusHandler = ProgressionNotificationBus.Connect(self, self.Properties.Player)
  self.isOnLocalPlayer = PlayerComponentRequestsBus.Event.IsLocalPlayer(self.Properties.Player) == true
  AudioPreloadComponentRequestBus.Event.LoadPreload(self.Properties.Player, self.PreloadName)
end
function PlayerState_LevelUp:OnDeactivate()
  if self.progressionBusHandler then
    self.progressionBusHandler:Disconnect()
    self.progressionBusHandler = nil
  end
  AudioPreloadComponentRequestBus.Event.UnloadPreload(self.Properties.Player, self.PreloadName)
end
function PlayerState_LevelUp:OnPlayerLevelChanged(previousLevel, currentLevel)
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.Player, self.Joint_1, self.FX_01, Vector3(0, 0, 0), self.isOnLocalPlayer, EmitterFollow_IgnoreRotation)
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.Player, self.Joint_2, self.FX_02, Vector3(0, 0, 0), self.isOnLocalPlayer, EmitterFollow_IgnoreRotation)
  if self.isOnLocalPlayer then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.Player, self.SFXLocalEvent)
  else
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.Player, self.SFXRemoteEvent)
  end
end
return PlayerState_LevelUp
