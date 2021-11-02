local PlayerVFX_FTUE_Respawn = {
  Properties = {
    Player = {
      default = EntityId()
    }
  },
  FX_01 = "FTUE_VFX.BeachWakeup_Azoth_1",
  FX_02 = "FTUE_VFX.BeachWakeup_Azoth_2",
  Joint_1 = "Spine1",
  Joint_2 = "Foot_Left",
  Joint_3 = "Foot_Right",
  Joint_4 = "Forearm_right",
  Joint_5 = "Forearm_left"
}
function PlayerVFX_FTUE_Respawn:OnActivate()
  self.trackEventHandler = SequenceComponentNotificationBus.Connect(self, self.entityId)
  self.dataLayer = RequireScript("LyShineUI.UiDataLayer")
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId ~= nil then
      self.playerEntityId = playerEntityId
    end
  end)
end
function PlayerVFX_FTUE_Respawn:OnDeactivate()
  if self.trackEventHandler ~= nil then
    self.trackEventHandler:Disconnect()
  end
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId")
  self.dataLayer = nil
end
function PlayerVFX_FTUE_Respawn:OnTrackEventTriggered(event, value)
  if event == "VFX_Start" and value == "VFX_BeachWakeUp" then
    local ParticleNormal = Vector3(0, 0, 0)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.playerEntityId, self.Joint_1, self.FX_01, ParticleNormal, self.isOnLocalPlayer, EmitterFollow_IgnoreRotation)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.playerEntityId, self.Joint_2, self.FX_02, ParticleNormal, self.isOnLocalPlayer, EmitterFollow_IgnoreRotation)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.playerEntityId, self.Joint_3, self.FX_02, ParticleNormal, self.isOnLocalPlayer, EmitterFollow_IgnoreRotation)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.playerEntityId, self.Joint_4, self.FX_02, ParticleNormal, self.isOnLocalPlayer, EmitterFollow_IgnoreRotation)
    ParticleManagerBus.Broadcast.SpawnParticleAtJoint(self.playerEntityId, self.Joint_5, self.FX_02, ParticleNormal, self.isOnLocalPlayer, EmitterFollow_IgnoreRotation)
  end
end
return PlayerVFX_FTUE_Respawn
