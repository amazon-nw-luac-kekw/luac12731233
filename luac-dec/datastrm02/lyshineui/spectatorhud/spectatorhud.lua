local SpectatorHUD = {
  Properties = {
    NextPlayerTitle = {
      default = EntityId()
    },
    PrevPlayerTitle = {
      default = EntityId()
    },
    CurrPlayerTitle = {
      default = EntityId()
    },
    CurrPlayerName = {
      default = EntityId()
    },
    RespawnTitle = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    }
  }
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(SpectatorHUD)
function SpectatorHUD:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  UiTextBus.Event.SetTextWithFlags(self.Properties.NextPlayerTitle, "@ui_spectate_nextplayer", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.CurrPlayerTitle, "@ui_spectate_currplayer", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.PrevPlayerTitle, "@ui_spectate_prevplayer", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.RespawnTitle, "@ui_respawn", eUiTextSet_SetLocalized)
  self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
end
function SpectatorHUD:OnTick()
  UiTextBus.Event.SetText(self.Properties.CurrPlayerName, SpectatorUIRequestBus.Broadcast.GetFocusedPlayerName())
end
function SpectatorHUD:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  self:BusDisconnect(self.tickHandler)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
return SpectatorHUD
