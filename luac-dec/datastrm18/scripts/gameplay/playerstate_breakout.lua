PlayerState_Breakout = {
  Properties = {
    Player = {
      default = EntityId()
    }
  },
  reactionCounter = 0,
  FX_01 = "cFX_Players.States.Breakout.Base_01",
  Joint_1 = "Spine2"
}
function PlayerState_Breakout:OnActivate()
  local dataLayer = RequireScript("LyShineUI.UiDataLayer")
  self.localPlayerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  self.currenttime = 0
  self.reactionNotificationBusHandler = ReactionEventBus.Connect(self, self.Properties.Player)
  self.isOnLocalPlayer = PlayerComponentRequestsBus.Event.IsLocalPlayer(self.Properties.Player) == true
end
function PlayerState_Breakout:OnDeactivate()
  if self.reactionNotificationBusHandler then
    self.reactionNotificationBusHandler:Disconnect()
    self.reactionNotificationBusHandler = nil
  end
end
function PlayerState_Breakout:OnExitReaction()
  self.reactionCounter = 0
  if self.reactionCounter <= 0 then
    MaterialOverrideBus.Event.StopOverride(self.Properties.Player, 3673996592)
    ParticleManagerBus.Broadcast.StopParticleAtJoint(self.Properties.Player, self.Joint_1, self.FX_01, true)
    if self.tickHandler ~= nil then
      self.tickHandler:Disconnect()
    end
  end
end
return PlayerState_Breakout
