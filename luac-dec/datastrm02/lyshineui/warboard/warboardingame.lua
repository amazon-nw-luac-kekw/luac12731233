local WarboardInGame = {
  Properties = {
    WarboardInGamePanelContainer = {
      default = EntityId()
    },
    WarboardRankingsTable = {
      default = EntityId()
    },
    PrimaryTabLine = {
      default = EntityId()
    },
    LocalRankListItem = {
      default = EntityId()
    },
    RankTableWidget = {
      default = EntityId()
    },
    ButtonClose = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    OutpostRushObjectives = {
      Panel = {
        default = EntityId(),
        order = 1
      },
      BossTime = {
        default = EntityId(),
        order = 2
      },
      PortalScore = {
        default = EntityId(),
        order = 3
      }
    }
  },
  PANEL_TYPE_WARBOARD_INGAME = 0,
  panels = {},
  screenStatesToDisable = {
    [2478623298] = true,
    [3901667439] = true,
    [3777009031] = true,
    [3766762380] = true,
    [1967160747] = true,
    [3576764016] = true,
    [1643432462] = true,
    [3493198471] = true,
    [898756891] = true,
    [3525919832] = true,
    [2815678723] = true,
    [3175660710] = true,
    [1823500652] = true,
    [156281203] = true,
    [3784122317] = true,
    [849925872] = true,
    [640726528] = true,
    [3370453353] = true,
    [2896319374] = true,
    [828869394] = true,
    [3211015753] = true,
    [2640373987] = true,
    [1319313135] = true,
    [1468490675] = true,
    [1101180544] = true,
    [1634988588] = true,
    [319051850] = true,
    [921202721] = true
  },
  timer = 0,
  second = 1,
  gameMode = 0
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(WarboardInGame)
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local factionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local warboardCommon = RequireScript("LyShineUI.Warboard.WarboardCommon")
local TimeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local gamemodeCommon = RequireScript("LyShineUI._Common.GameModeCommon")
function WarboardInGame:OnInit()
  BaseScreen.OnInit(self)
  self.socialDataHandler = SocialDataHandler
  self.socialDataHandler:OnActivate()
  self.panelTypes = {
    {
      panelType = self.PANEL_TYPE_WARBOARD_INGAME,
      container = self.Properties.WarboardInGamePanelContainer
    }
  }
  self.warboardInGameBusHandler = DynamicBus.WarboardInGameBus.Connect(self.entityId, self)
  self:BusConnect(GroupsUINotificationBus)
  self.alliedPlayerData = {}
  self.enemyPlayerData = {}
  self.allPlayerData = {}
  self.playerRank = 0
  self.alliedStats = {}
  self.enemyStats = {}
  self.localPlayerStats = {}
  self.members = {}
  self.alliedColor = nil
  self.enemyColor = nil
  self.raidId = nil
  self.warId = nil
  self:SetVisualElements()
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.PlayerName", function(self, playerName)
    self.playerName = playerName
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if not playerEntityId then
      return
    end
    self.playerEntityId = playerEntityId
    self.playerId = PlayerComponentRequestsBus.Event.GetPlayerIdentification(playerEntityId)
    self:BusDisconnect(self.participantBusHandler)
    self.participantBusHandler = self:BusConnect(GameModeParticipantComponentNotificationBus, playerEntityId)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Raid.Id", function(self, raidId)
    self.raidId = raidId
    if self.raidId and self.raidId:IsValid() and self.warId then
      self:OnSiegeWarfareStarted(self.warId)
    end
  end)
  UiElementBus.Event.SetIsEnabled(self.Properties.WarboardInGamePanelContainer, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.OutpostRushObjectives.Panel, false)
end
function WarboardInGame:OnShutdown()
  BaseScreen.OnShutdown(self)
  if self.warboardInGameBusHandler then
    DynamicBus.WarboardInGameBus.Disconnect(self.entityId, self)
    self.warboardInGameBusHandler = nil
  end
  self.socialDataHandler:OnDeactivate()
end
function WarboardInGame:SetVisualElements()
  self.Frame:SetFrameStyle(self.Frame.FRAME_STYLE_HORIZONTAL_LIST_COMBO)
  self.ButtonClose:SetCallback(self.OnEscapeKeyPressed, self)
end
function WarboardInGame:GetGameModeDataPath(valueName)
  return "GameMode." .. tostring(self.gameModeEntityId) .. "." .. valueName
end
function WarboardInGame:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  if self.screenStatesToDisable[toState] then
    UiCanvasBus.Event.SetEnabled(self.canvasId, false)
  end
  local isOutpostRush = self.gameMode == 2444859928
  UiElementBus.Event.SetIsEnabled(self.Properties.OutpostRushObjectives.Panel, false)
  if isOutpostRush and self.gameModeEntityId then
    self.dataLayer:RegisterAndExecuteDataObserver(self, self:GetGameModeDataPath("State"), function(self, state)
      local showObjectiveHud = state == 2231901092
      UiElementBus.Event.SetIsEnabled(self.Properties.OutpostRushObjectives.Panel, showObjectiveHud)
    end)
    self.dataLayer:RegisterAndExecuteDataObserver(self, self:GetGameModeDataPath("LocalPlayer.teamIdx"), function(self, teamIndex)
      self.portalScoreKey = self:GetGameModeDataPath(tostring(Math.CreateCrc32("PortalTeam" .. tostring(teamIndex + 1))))
      self.dataLayer:RegisterAndExecuteDataObserver(self, self.portalScoreKey, function(self, score)
        self:UpdatePortalScore(score and score or 0)
      end)
    end)
    self.bossTimerKey = self:GetGameModeDataPath("Timer_" .. tostring(3888164413))
    self.dataLayer:RegisterAndExecuteDataObserver(self, self.bossTimerKey, function(self, time)
      self:UpdateBossTimer(time and time or 0)
    end)
  end
  local data = {
    panelType = self.PANEL_TYPE_WARBOARD_INGAME,
    setState = false
  }
  self:ShowWarboardInGame(data)
  if not self.escapeKeyHandler then
    self.escapeKeyHandler = DynamicBus.EscapeKeyNotificationBus.Connect(self.entityId, self)
  end
  if self.warId then
    self.timer = 0
    self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function WarboardInGame:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  if self.screenStatesToDisable[fromState] then
    UiCanvasBus.Event.SetEnabled(self.canvasId, true)
  end
  local isOutpostRush = self.gameMode == 2444859928
  if isOutpostRush then
    self.dataLayer:UnregisterObserver(self, self.bossTimerKey)
    self.dataLayer:UnregisterObserver(self, self.portalScoreKey)
    self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath("LocalPlayer.teamIdx"))
    self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath("State"))
  end
  self:HideWarboardInGame()
  if self.escapeKeyHandler then
    DynamicBus.EscapeKeyNotificationBus.Disconnect(self.entityId, self)
    self.escapeKeyHandler = nil
  end
  if self.tickBusHandler then
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
  end
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function WarboardInGame:ShowWarboardInGame(data)
  local container
  for _, typeData in ipairs(self.panelTypes) do
    local matchesType = typeData.panelType == data.panelType
    UiElementBus.Event.SetIsEnabled(typeData.container, matchesType)
    if matchesType then
      container = typeData.container
    end
  end
  if not container then
    Log("[WarboardInGame] Error: data is not associated with any panels")
    return
  end
  ClearTable(self.panels)
  local children = UiElementBus.Event.GetChildren(container)
  self.numPanels = #children
  for i = 1, self.numPanels do
    local entityId = children[i]
    local entityTable = self.registrar:GetEntityTable(entityId)
    table.insert(self.panels, entityTable)
    UiElementBus.Event.SetIsEnabled(entityId, i == 1)
  end
  self:FetchWarboardStats()
  self.ScriptedEntityTweener:Play(self.entityId, 0.3, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
end
function WarboardInGame:HideWarboardInGame()
  local container = self.Properties.WarboardInGamePanelContainer
  local children = UiElementBus.Event.GetChildren(container)
  for i = 1, #children do
    UiElementBus.Event.SetIsEnabled(children[i], false)
  end
end
function WarboardInGame:SelectAllFilterTab()
  self.WarboardRankingsTable:SelectAllFilterTab()
end
function WarboardInGame:OnFilterTabSelected(entityId)
  self.WarboardRankingsTable:OnFilterTabSelected(entityId)
end
function WarboardInGame:GetStat(StatEnumIndex, StatTable)
  return math.modf(StatTable:GetStatEntryValue(StatEnumIndex))
end
function WarboardInGame:FillTablesWithStatsData()
  ClearTable(self.alliedPlayerData)
  ClearTable(self.enemyPlayerData)
  ClearTable(self.allPlayerData)
  for i = 1, #self.alliedStats do
    local k = self.alliedStats[i]
    local playerData = {
      allied = true,
      highlight = false,
      playerId = self:GetMemberPlayerId(k.characterId),
      isConnected = k.isConnected
    }
    self:AddValuesToEntry(playerData, -1, self:GetMemberName(k.characterId), k)
    if playerData.playerId and self.playerId then
      if playerData.playerId:GetCharacterIdString() == self.playerId:GetCharacterIdString() then
        playerData.highlight = true
      end
      table.insert(self.alliedPlayerData, playerData)
    end
  end
  for i = 1, #self.enemyStats do
    local k = self.enemyStats[i]
    local playerData = {
      allied = false,
      highlight = false,
      playerId = self:GetMemberPlayerId(k.characterId),
      isConnected = k.isConnected
    }
    self:AddValuesToEntry(playerData, -1, self:GetMemberName(k.characterId), k)
    if playerData.playerId then
      table.insert(self.enemyPlayerData, playerData)
    end
  end
  for _, v in ipairs(self.alliedPlayerData) do
    table.insert(self.allPlayerData, v)
  end
  for _, v in ipairs(self.enemyPlayerData) do
    table.insert(self.allPlayerData, v)
  end
  if self.gameMode == gamemodeCommon.GAMEMODE_OUTPOST_RUSH then
    self.alliedColor = self.UIStyle.COLOR_BLUE
    self.enemyColor = self.UIStyle.COLOR_RED_DARK
  end
  self.WarboardRankingsTable:SetDataSources(self.alliedPlayerData, self.enemyPlayerData, self.allPlayerData, self.alliedColor, self.enemyColor, warboardCommon.statsShown[self.gameMode])
  local k = self.localPlayerStats
  local listItemData = {
    playerId = self.playerId,
    color = self.UIStyle.COLOR_WHITE,
    isConnected = true
  }
  self:AddValuesToEntry(listItemData, self.playerRank, self.playerName, k)
  self.LocalRankListItem:SetData(listItemData)
end
function WarboardInGame:GetGuildDetailedDataFailure(reason)
  if reason == eSocialRequestFailureReasonThrottled then
    Log("ERR - GuildMenu:OnShowWarNotification: GuildData request throttled")
  elseif reason == eSocialRequestFailureReasonTimeout then
    Log("ERR - GuildMenu:OnShowWarNotification: GuildData request timed out")
  end
end
function WarboardInGame:OnSiegeWarfareStarted(warId)
  if warId == nil then
    return
  end
  self.warId = warId
  local warDetails = WarDataClientRequestBus.Broadcast.GetWarDetails(warId)
  if warDetails and warDetails:IsValid() and self.raidId and self.raidId:IsValid() then
    local isAttacker = warDetails:IsAttackingRaid(self.raidId)
    local isInvasion = not warDetails:GetAttackerGuildId():IsValid()
    local guildId = isAttacker and warDetails:GetAttackerGuildId() or warDetails:GetDefenderGuildId()
    self.guildId = guildId
    self.isAttacker = isAttacker
    self.isInvasion = isInvasion
    local function successCallback(self, result)
      local guildData
      if 0 < #result then
        guildData = type(result[1]) == "table" and result[1].guildData or result[1]
      else
        Log("ERR - WarboardInGame:OnSiegeWarfareStarted: GuildData request returned with no data")
        return
      end
      if guildData and guildData:IsValid() then
        local factionColor = factionCommon.factionInfoTable[guildData.faction].crestBgColorLight
        if guildData.guildId == self.guildId then
          self.alliedColor = factionColor
        else
          self.enemyColor = factionColor
        end
      end
    end
    self.socialDataHandler:GetGuildDetailedData_ServerCall(self, successCallback, self.GetGuildDetailedDataFailure, self.guildId)
    if not self.isInvasion then
      local attackingGuildId = warDetails:GetAttackerGuildId()
      local otherGuildId = self.guildId == attackingGuildId and warDetails:GetDefenderGuildId() or attackingGuildId
      self.socialDataHandler:GetGuildDetailedData_ServerCall(self, successCallback, self.GetGuildDetailedDataFailure, otherGuildId)
    end
    self:SetElements(self.isInvasion)
    self:FetchWarboardStats()
    self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.WarboardCacheUpdate", function(self, updated)
      if updated and LyShineManagerBus.Broadcast.IsInState(3160088100) then
        self:FetchWarboardStats()
      end
    end)
  end
end
function WarboardInGame:OnTick(deltaTime, timePoint)
  if self.timer >= self.second then
    self.timer = self.timer - self.second
    if #self.members > 0 then
      local warboardStats = WarboardDataServiceBus.Broadcast.GetWarboardStats()
      if warboardStats and warboardStats:IsValid() then
        local allPlayers = warboardStats:GetActivePlayersCount()
        if #self.members ~= allPlayers then
          Log("[WarboardInGame] Warning: mismatch of returned members to all players with stats - updating again.")
          self:FetchWarboardStats()
        end
      end
    end
  end
  self.timer = self.timer + deltaTime
end
function WarboardInGame:FetchWarboardStats()
  local warboardStats = WarboardDataServiceBus.Broadcast.GetWarboardStats()
  if warboardStats and warboardStats:IsValid() then
    local allPlayers = warboardStats:GetActivePlayersCount()
    local defenderStats = warboardStats:GetDefenderStatValues()
    local attackerStats = warboardStats:GetAttackerStatValues()
    self.localPlayerStats = warboardStats:GetLocalPlayerStats()
    self.playerRank = warboardStats:GetLocalPlayerRank()
    if self.isAttacker then
      self.alliedStats = attackerStats
      self.enemyStats = defenderStats
    else
      self.alliedStats = defenderStats
      self.enemyStats = attackerStats
    end
    if #self.members ~= allPlayers then
      self:UpdateAllMembers()
    else
      self:FillTablesWithStatsData()
    end
  end
end
function WarboardInGame:OnSiegeWarfareEnded(isWinner, resolutionPhaseEndTimePoint)
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.WarboardCacheUpdate")
  LyShineManagerBus.Broadcast.ExitState(3160088100)
  self.warId = nil
end
function WarboardInGame:OnSiegeWarfareCompleted(reason)
end
function WarboardInGame:SetElements(isInvasion)
  self.WarboardRankingsTable:SetInvasionMode(isInvasion)
end
function WarboardInGame:UpdateAllMembers()
  local memberCharacterIds = {}
  for i = 1, #self.alliedStats do
    local k = self.alliedStats[i]
    table.insert(memberCharacterIds, k.characterId)
  end
  for i = 1, #self.enemyStats do
    local k = self.enemyStats[i]
    table.insert(memberCharacterIds, k.characterId)
  end
  if 0 < #memberCharacterIds then
    self.socialDataHandler:GetPlayers_ServerCall(self, self.UpdateMembers_OnGetMemberData, self.UpdateMembers_OnGetMemberDataFailed, memberCharacterIds)
  end
end
function WarboardInGame:UpdateMembers_OnGetMemberData(memberResults)
  self.members = {}
  if memberResults then
    for i = 1, #memberResults do
      local memberResult = memberResults[i]
      if memberResult then
        table.insert(self.members, {playerId = memberResult})
      end
    end
  end
  self:FillTablesWithStatsData()
end
function WarboardInGame:UpdateMembers_OnGetMemberDataFailed(reason, memberResults)
  self:UpdateMembers_OnGetMemberData(memberResults)
end
function WarboardInGame:GetMemberName(memberCharacterId)
  for index, value in ipairs(self.members) do
    local memberPlayerId = value.playerId
    if memberPlayerId:GetCharacterIdString() == memberCharacterId then
      return memberPlayerId.playerName
    end
  end
  return ""
end
function WarboardInGame:GetMemberPlayerId(memberCharacterId)
  for index, value in ipairs(self.members) do
    local memberPlayerId = value.playerId
    if memberPlayerId:GetCharacterIdString() == memberCharacterId then
      return memberPlayerId
    end
  end
  return nil
end
function WarboardInGame:OnEscapeKeyPressed()
  local currentState = LyShineManagerBus.Broadcast.GetCurrentState()
  if currentState == 3160088100 then
    LyShineManagerBus.Broadcast.ExitState(3160088100)
  end
end
function WarboardInGame:SetGameMode(gameMode)
  self.gameMode = gameMode
end
function WarboardInGame:SetGameModeEntityId(gameModeEntityId)
  self.gameModeEntityId = gameModeEntityId
  if self.gameMode == gamemodeCommon.GAMEMODE_OUTPOST_RUSH then
    self.dataLayer:RegisterAndExecuteDataObserver(self, self:GetGameModeDataPath("AzothPortalTotal"), function(self, total)
      self.portalTotal = total
    end)
  end
end
function WarboardInGame:SetPlayerTeamIndex(playerTeamIndex)
  self.playerTeamIndex = playerTeamIndex
  if self.gameMode == gamemodeCommon.GAMEMODE_OUTPOST_RUSH then
    self.isAttacker = playerTeamIndex == 0
  end
end
function WarboardInGame:AddValuesToEntry(entry, rank, name, statsTable)
  if not entry then
    return
  end
  entry.values = {}
  entry.values[warboardCommon.rankIndex] = rank
  entry.values[warboardCommon.nameIndex] = name
  for i = 1, #warboardCommon.statsShown[self.gameMode] do
    local stat = warboardCommon.statsShown[self.gameMode][i].stat
    if stat then
      local value = self:GetStat(stat, statsTable)
      table.insert(entry.values, value)
    end
  end
end
function WarboardInGame:UpdatePortalScore(score)
  local scoreText = GetLocalizedReplacementText("@ui_outpost_rush_portal_score", {
    current = tostring(score),
    total = self.portalTotal
  })
  UiTextBus.Event.SetTextWithFlags(self.Properties.OutpostRushObjectives.PortalScore, scoreText, eUiTextSet_SetAsIs)
end
function WarboardInGame:UpdateBossTimer(timeRemaining)
  local secondsRemaining = math.max(math.ceil(timeRemaining / 1000), 0)
  if 0 < secondsRemaining then
    local _, _, minutes, seconds = TimeHelpers:ConvertSecondsToDaysHoursMinutesSeconds(secondsRemaining)
    local timerText = string.format("%d:%02d", minutes, seconds)
    UiTextBus.Event.SetTextWithFlags(self.Properties.OutpostRushObjectives.BossTime, timerText, eUiTextSet_SetAsIs)
    UiTextBus.Event.SetColor(self.Properties.OutpostRushObjectives.BossTime, self.UIStyle.COLOR_WHITE)
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.OutpostRushObjectives.BossTime, "@ui_outpost_rush_boss_alive", eUiTextSet_SetLocalized)
    UiTextBus.Event.SetColor(self.Properties.OutpostRushObjectives.BossTime, self.UIStyle.COLOR_GREEN_BRIGHT)
  end
end
return WarboardInGame
