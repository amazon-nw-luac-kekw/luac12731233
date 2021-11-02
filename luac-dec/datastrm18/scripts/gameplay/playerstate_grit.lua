PlayerState_GRIT = {
  Properties = {
    Player = {
      default = EntityId()
    }
  },
  FX_01 = "cFX_Players.States.GRIT.Energy_01",
  FX_02 = "cFX_Players.States.GRIT.Energy_02",
  FX_03 = "cFX_Players.States.GRIT.Energy_Embers",
  FX_04 = "cFX_Players.States.GRIT.Energy_Bust_01",
  Joint_1 = "Forearm_roll_right",
  Joint_2 = "Forearm_roll_left",
  Joint_3 = "MidArm_right",
  Joint_4 = "MidArm_left",
  Joint_5 = "Neck"
}
function PlayerState_GRIT:OnActivate()
  self.currenttime = 0
  self.notificationBusHandler = GritEventBus.Connect(self, self.Properties.Player)
  self.isOnLocalPlayer = PlayerComponentRequestsBus.Event.IsLocalPlayer(self.Properties.Player) == true
end
function PlayerState_GRIT:OnDeactivate()
  self.notificationBusHandler:Disconnect()
end
function PlayerState_GRIT:OnTick(deltatime, time2)
end
function PlayerState_GRIT:OnGritActivated()
  self.tickHandler = TickBus.Connect(self)
  MaterialOverrideBus.Event.StartOverride(self.Properties.Player, 865585491)
  local ParticleNormal = Vector3(0, 0, 0)
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.Player, self.Joint_1, self.FX_01, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.Player, self.Joint_2, self.FX_01, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.Player, self.Joint_3, self.FX_02, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.Player, self.Joint_4, self.FX_02, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.Player, self.Joint_3, self.FX_03, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.Player, self.Joint_4, self.FX_03, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.Player, self.Joint_5, self.FX_04, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
end
function PlayerState_GRIT:OnGritDeactivated()
  MaterialOverrideBus.Event.StopOverride(self.Properties.Player, 865585491)
  ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.Player, self.Joint_1, self.FX_01, true)
  ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.Player, self.Joint_2, self.FX_01, true)
  ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.Player, self.Joint_3, self.FX_02, true)
  ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.Player, self.Joint_4, self.FX_02, true)
  ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.Player, self.Joint_3, self.FX_03, true)
  ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.Player, self.Joint_4, self.FX_03, true)
  ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.Player, self.Joint_5, self.FX_04, true)
  self.tickHandler:Disconnect()
end
function PlayerState_GRIT:OnGritBroken()
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.Properties.Player, "Play_GRIT_Break")
end
return PlayerState_GRIT
