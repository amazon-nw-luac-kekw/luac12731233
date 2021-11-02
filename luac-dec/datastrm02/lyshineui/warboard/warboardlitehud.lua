local WarboardLiteHUD = {
  Properties = {
    ActionMapActivator = {
      default = "toggleWarboardInGame"
    },
    LiteHUDWidget = {
      default = EntityId()
    },
    Header = {
      Score = {
        default = EntityId()
      },
      Rank = {
        default = EntityId()
      }
    },
    Stats = {
      Kills = {
        default = EntityId()
      },
      Deaths = {
        default = EntityId()
      },
      Assists = {
        default = EntityId()
      },
      WarboardHint = {
        default = EntityId()
      }
    }
  }
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(WarboardLiteHUD)
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
function WarboardLiteHUD:OnInit()
  BaseScreen.OnInit(self)
  self.warId = nil
  self.raidId = nil
  self.playerRank = 0
  self.statNames = {}
  self.localPlayerStats = {}
  self.Stats.WarboardHint:SetKeybindMapping("toggleWarboardInGame")
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.PlayerName", function(self, playerName)
    self.playerName = playerName
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if not playerEntityId then
      return
    end
    self.playerEntityId = playerEntityId
    self.playerId = PlayerComponentRequestsBus.Event.GetPlayerIdentification(playerEntityId)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Raid.Id", function(self, raidId)
    self.raidId = raidId
    if self.raidId and self.raidId:IsValid() and self.warId then
      self:OnSiegeWarfareStarted(self.warId)
    else
      self:Cleanup()
    end
  end)
  self:BusConnect(UiCanvasSizeNotificationBus, self.canvasId)
  self.warboardLiteHUDBusHandler = DynamicBus.WarboardLiteHUDBus.Connect(self.entityId, self)
  self:BusConnect(GroupsUINotificationBus)
  self:OnCanvasSizeOrScaleChange(self.canvasId)
end
function WarboardLiteHUD:OnShutdown()
  BaseScreen.OnShutdown(self)
  if self.warboardLiteHUDBusHandler then
    DynamicBus.WarboardLiteHUDBus.Disconnect(self.entityId, self)
    self.warboardLiteHUDBusHandler = nil
  end
end
function WarboardLiteHUD:OnTransitionIn(fromState, fromLevel, toState, toLevel)
end
function WarboardLiteHUD:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function WarboardLiteHUD:OnCanvasSizeOrScaleChange(canvasId)
  if self.canvasId == canvasId then
    AdjustElementToCanvasSize(self.entityId, self.canvasId)
  end
end
function WarboardLiteHUD:GetStat(StatEnumIndex, StatTable)
  return math.modf(StatTable:GetStatEntryValue(StatEnumIndex))
end
function WarboardLiteHUD:SetupPlayerHeader(statTable)
  self.Header.Rank:SetData("@ui_war_rank", self.playerRank)
  self.Header.Score:SetData("@ui_war_score", self:GetStat(WarboardStatsEntry.eWarboardStatType_Score, statTable))
end
function WarboardLiteHUD:SetupPlayerStats(statTable)
  local statIds = {
    WarboardStatsEntry.eWarboardStatType_Kills,
    WarboardStatsEntry.eWarboardStatType_Deaths,
    WarboardStatsEntry.eWarboardStatType_Assists
  }
  local statLines = {
    self.Stats.Kills,
    self.Stats.Deaths,
    self.Stats.Assists
  }
  for i = 1, #statLines do
    local statName = self.statNames[statIds[i] + 1]
    local statValue = self:GetStat(statIds[i], statTable)
    statLines[i]:SetData(statName, statValue)
  end
end
function WarboardLiteHUD:OnCryAction(actionName)
  if UiElementBus.Event.IsEnabled(self.Properties.LiteHUDWidget) then
    LyShineManagerBus.Broadcast.ToggleState(3160088100)
  else
    LyShineManagerBus.Broadcast.ExitState(3160088100)
  end
end
function WarboardLiteHUD:OnSiegeWarfareStarted(warId)
  if warId == nil then
    return
  end
  self.warId = warId
  local warDetails = WarDataClientRequestBus.Broadcast.GetWarDetails(warId)
  if warDetails and warDetails:IsValid() and self.raidId and self.raidId:IsValid() then
    local isAttacker = warDetails:IsAttackingRaid(self.raidId)
    local isInvasion = not warDetails:GetAttackerGuildId():IsValid()
    self.isAttacker = isAttacker
    self.isInvasion = isInvasion
    self:SetupLiteHUD()
    UiElementBus.Event.SetIsEnabled(self.Properties.LiteHUDWidget, true)
  end
end
function WarboardLiteHUD:FetchWarboardStats()
  local warboardStats = WarboardDataServiceBus.Broadcast.GetWarboardStats()
  if warboardStats and warboardStats:IsValid() then
    if #self.statNames == 0 then
      self.statNames = warboardStats:GetStatNames()
    end
    self.playerRank = warboardStats:GetLocalPlayerRank()
    self.localPlayerStats = warboardStats:GetLocalPlayerStats()
    self:SetupLiteHUD(self.localPlayerStats)
  end
end
function WarboardLiteHUD:OnSiegeWarfareEnded(isWinner, resolutionPhaseEndTimePoint)
  self:Cleanup()
end
function WarboardLiteHUD:OnSiegeWarfareCompleted(reason)
end
function WarboardLiteHUD:SetupLiteHUD(statTable)
  if statTable then
    self:SetupPlayerHeader(statTable)
    self:SetupPlayerStats(statTable)
  end
  if not self.actionHandler then
    self.actionHandler = self:BusConnect(CryActionNotificationsBus, self.Properties.ActionMapActivator)
  end
end
function WarboardLiteHUD:Cleanup()
  UiElementBus.Event.SetIsEnabled(self.Properties.LiteHUDWidget, false)
  self.warId = nil
  if self.actionHandler then
    self:BusDisconnect(self.actionHandler)
    self.actionHandler = nil
  end
end
return WarboardLiteHUD
