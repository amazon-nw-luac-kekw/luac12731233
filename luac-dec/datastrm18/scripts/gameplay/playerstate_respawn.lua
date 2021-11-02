PlayerState_Respawn = {
  Properties = {
    Player = {
      default = EntityId()
    }
  },
  respawnEffectTimer = 0,
  respawnEffectMaxTime = 2,
  FX_01 = "cFX_Player_States.Respawn",
  FX_02 = "cFX_Player_States.FastTravel_Azoth_01",
  Joint_1 = "Xform",
  Joint_2 = "Hand_right"
}
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
function PlayerState_Respawn:OnActivate()
  self.respawnEffectTimer = 0
  self.isOnLocalPlayer = PlayerComponentRequestsBus.Event.IsLocalPlayer(self.Properties.Player) == true
  if self.playerSpawningBusHandler == nil then
    self.playerSpawningBusHandler = DynamicBus.playerSpawningBus.Connect(self.Properties.Player, self)
  end
end
function PlayerState_Respawn:OnDeactivate()
  if self.playerSpawningBusHandler then
    DynamicBus.playerSpawningBus.Disconnect(self.Properties.Player, self)
    self.playerSpawningBusHandler = nil
  end
end
function PlayerState_Respawn:onPlayerSpawned()
  if self.isOnLocalPlayer then
    local showRespawnEffects = dataLayer:GetDataFromNode("Hud.LocalPlayer.Vitals.ShowRespawnEffects")
    if showRespawnEffects then
      self:OnRespawnActivated()
    end
  end
end
function PlayerState_Respawn:OnTick(deltatime, time2)
  if self.respawnEffectTimer > 0 then
    self.respawnEffectTimer = self.respawnEffectTimer - deltatime
    if self.respawnEffectTimer < 0 then
      self:OnRespawnDeactivated()
    end
  end
end
function PlayerState_Respawn:OnRespawnActivated()
  self.respawnEffectTimer = self.respawnEffectMaxTime
  self.tickHandler = TickBus.Connect(self)
  MaterialOverrideBus.Event.StartOverride(self.Properties.Player, 3901667439)
  local ParticleNormal = Vector3(0, 0, 0)
  ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.Properties.Player, self.Joint_1, self.FX_01, ParticleNormal, self.isOnLocalPlayer, EmitterFollow)
end
function PlayerState_Respawn:OnRespawnDeactivated()
  MaterialOverrideBus.Event.StopOverride(self.Properties.Player, 3901667439)
  ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.Player, self.Joint_1, self.FX_01, false)
  self.tickHandler:Disconnect()
  self.tickHandler = nil
end
return PlayerState_Respawn
