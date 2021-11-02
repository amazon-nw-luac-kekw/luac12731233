local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
local SlashCommands = RequireScript("LyShineUI.SlashCommands")
local GameModeHud = {
  Properties = {
    Title = {
      default = EntityId()
    }
  },
  activeGameModes = {},
  dataLayer_stateId = "State",
  dataLayer_winningTeamIdxId = tostring(1116393986),
  dataLayer_countdownTimerId = "Timer_" .. tostring(4179687204)
}
BaseScreen:CreateNewScreen(GameModeHud)
function GameModeHud:OnInit()
  BaseScreen.OnInit(self)
  SlashCommands:RegisterSlashCommand("gamemode", self.OnSlashGameMode, self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, rootEntityId)
    if rootEntityId then
      self.localPlayerEntityId = rootEntityId
      if self.participantBusHandler then
        self.participantBusHandler:Disconnect()
        self.participantBusHandler = nil
      end
      self.participantBusHandler = GameModeParticipantComponentNotificationBus.Connect(self, rootEntityId)
    end
  end)
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
end
function GameModeHud:OnShutdown()
  if self.participantBusHandler then
    self.participantBusHandler:Disconnect()
    self.participantBusHandler = nil
  end
end
function GameModeHud:OnSlashGameMode(args)
end
function GameModeHud:DebugUpdateTitle()
  local title = "GameModes: "
  for k, gameMode in pairs(self.activeGameModes) do
    title = title .. tostring(gameMode.gameModeId) .. " "
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.Title, title, eUiTextSet_SetAsIs)
end
function GameModeHud:GetGameModeDataPath(gameModeEntityId, valueName)
  return "GameMode." .. tostring(gameModeEntityId) .. "." .. valueName
end
function GameModeHud:OnEnteredGameMode(gameModeEntityId, gameModeId)
  self.activeGameModes[gameModeEntityId.value] = {gameModeId = gameModeId}
  UiTextBus.Event.SetTextWithFlags(self.Properties.Title, "", eUiTextSet_SetAsIs)
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
end
function GameModeHud:OnExitedGameMode(gameModeEntityId)
  self.activeGameModes[gameModeEntityId.value] = nil
  if not next(self.activeGameModes) then
    UiElementBus.Event.SetIsEnabled(self.entityId, false)
  end
end
return GameModeHud
