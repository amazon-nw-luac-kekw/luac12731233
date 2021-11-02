local WarboardEndOfMatch = {
  Properties = {
    WarboardPanelContainer = {
      default = EntityId()
    },
    PlayerHeaderPanel = {
      Icon = {
        default = EntityId()
      },
      Name = {
        default = EntityId()
      },
      Score = {
        default = EntityId()
      }
    },
    NavBar = {
      NarBarHolder = {
        default = EntityId()
      },
      TabbedListMenuHolder = {
        default = EntityId()
      },
      ScreenHeader = {
        default = EntityId()
      }
    },
    TabContent = {
      Overview = {
        default = EntityId()
      },
      Performance = {
        default = EntityId()
      },
      Rankings = {
        default = EntityId()
      }
    },
    TimerRemaining = {
      default = EntityId()
    },
    ExitButton = {
      default = EntityId()
    },
    WarboardPanel = {
      default = EntityId()
    },
    PlayerHeader = {
      default = EntityId()
    },
    PerformancePlayerName = {
      default = EntityId()
    },
    PerformancePlayerScore = {
      default = EntityId()
    },
    LocalPlayerStandout = {
      default = EntityId()
    },
    PlayerStandoutHeaders = {
      War = {
        default = EntityId()
      },
      Invasion = {
        default = EntityId()
      }
    },
    Tables = {
      Stats = {
        default = EntityId()
      },
      Performance = {
        default = EntityId()
      },
      Allied = {
        default = EntityId()
      },
      Enemy = {
        default = EntityId()
      }
    },
    WarboardRankingsTable = {
      default = EntityId()
    },
    PrimaryTabLineRight = {
      default = EntityId()
    },
    LocalRankListItem = {
      default = EntityId()
    },
    CrestBanner = {
      Left = {
        default = EntityId()
      },
      Right = {
        default = EntityId()
      }
    },
    TimerProgressBar = {
      default = EntityId()
    }
  },
  STATE_NAME_WARBOARD = 921202721,
  PANEL_TYPE_WARBOARD = 0,
  panels = {},
  timer = 0,
  second = 1,
  isWin = false,
  maxRetries = 2,
  currentSelectedScreen = nil,
  currentTabContainer = nil,
  currentFilter = nil,
  gameMode = 0
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(WarboardEndOfMatch)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local factionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local warboardCommon = RequireScript("LyShineUI.Warboard.WarboardCommon")
local GameModeCommon = RequireScript("LyShineUI._Common.GameModeCommon")
local BitwiseHelper = RequireScript("LyShineUI._Common.BitwiseHelpers")
function WarboardEndOfMatch:OnInit()
  BaseScreen.OnInit(self)
  self:InitializeMembers()
  self.socialDataHandler = SocialDataHandler
  self.socialDataHandler:OnActivate()
  self.alliedColor = Color(0, 0, 0, 0)
  self.enemyColor = Color(0, 0, 0, 0)
  self:SetupVisuals()
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if not playerEntityId then
      return
    end
    self.playerEntityId = playerEntityId
    self.playerId = PlayerComponentRequestsBus.Event.GetPlayerIdentification(playerEntityId)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.PlayerName", function(self, playerName)
    self.playerName = playerName
  end)
  self.panelTypes = {
    {
      panelType = self.PANEL_TYPE_WARBOARD,
      container = self.Properties.WarboardPanelContainer
    },
    {
      panelType = self.PANEL_TYPE_OUTPOSTRUSH,
      container = self.Properties.WarboardPanelContainer
    }
  }
  self:SetupBusConnections()
  self:SetupExitButton()
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Raid.Id", function(self, raidId)
    self.raidId = raidId
    if not raidId or not raidId:IsValid() then
      local currentState = LyShineManagerBus.Broadcast.GetCurrentState()
      if currentState == 921202721 then
        LyShineManagerBus.Broadcast.ExitState(921202721)
      end
    end
  end)
  self:ConstructNavMenu()
  self:SetScreenVisible(false)
  SetTextStyle(self.Properties.TimerRemaining, self.UIStyle.FONT_STYLE_WARBOARD_COUNTDOWN_TIMER)
  SetTextStyle(self.Properties.PlayerHeaderPanel.Name, self.UIStyle.FONT_STYLE_WARBOARD_PLAYERHEADER_NAME)
  SetTextStyle(self.Properties.PlayerHeaderPanel.Score, self.UIStyle.FONT_STYLE_WARBOARD_PLAYERHEADER_SCORE)
  SetTextStyle(self.Properties.PerformancePlayerName, self.UIStyle.FONT_STYLE_WARBOARD_PERFORMANCE_PLAYERNAME)
  SetTextStyle(self.Properties.PerformancePlayerScore, self.UIStyle.FONT_STYLE_WARBOARD_PERFORMANCE_PLAYERSCORE)
end
function WarboardEndOfMatch:OnShutdown()
  DynamicBus.WarboardEndOfMatch.Disconnect(self.entityId, self)
  BaseScreen.OnShutdown(self)
  self.socialDataHandler:OnDeactivate()
end
function WarboardEndOfMatch:InitializeMembers()
  self.playerName = ""
  self.isWin = false
  self.guildId = 0
  self.isAttacker = false
  self.isInvasion = false
  self.isOutpostRush = false
  self.playerRank = 0
  self.statNames = {}
  self.alliedStats = {}
  self.enemyStats = {}
  self.localPlayerStats = {}
  self.statsTable = {}
  self.performanceTable = {}
  self.alliedTable = {}
  self.enemyTable = {}
  self.members = {}
  self.alliedPlayerData = {}
  self.enemyPlayerData = {}
  self.allPlayerData = {}
  self.leftBannerColor = nil
  self.rightBannerColor = nil
  self.playerId = nil
  self.tempMemberId = nil
  self.leftBannerRetryCount = 0
  self.rightBannerRetryCount = 0
end
function WarboardEndOfMatch:GetStat(StatEnumIndex, StatTable)
  return math.modf(StatTable:GetStatEntryValue(StatEnumIndex))
end
function WarboardEndOfMatch:SetupVisuals()
  self.PrimaryTabLineRight:SetColor(self.UIStyle.COLOR_TAN)
end
function WarboardEndOfMatch:SetupPlayerPanel(playerData)
  local playerData = {
    name = self.playerName,
    score = self:GetStat(WarboardStatsEntry.eWarboardStatType_Score, self.localPlayerStats)
  }
  UiTextBus.Event.SetText(self.Properties.PlayerHeaderPanel.Name, playerData.name)
  UiTextBus.Event.SetText(self.Properties.PlayerHeaderPanel.Score, playerData.score)
  UiTextBus.Event.SetText(self.Properties.PerformancePlayerName, playerData.name)
  UiTextBus.Event.SetText(self.Properties.PerformancePlayerScore, playerData.score)
end
function WarboardEndOfMatch:SetupBusConnections()
  DynamicBus.WarboardEndOfMatch.Connect(self.entityId, self)
  self:BusConnect(GroupsUINotificationBus)
  self:BusConnect(UiDynamicScrollBoxDataBus, self.Tables.Stats)
  self:BusConnect(UiDynamicScrollBoxElementNotificationBus, self.Tables.Stats)
  self:BusConnect(UiDynamicScrollBoxDataBus, self.Tables.Performance)
  self:BusConnect(UiDynamicScrollBoxElementNotificationBus, self.Tables.Performance)
  self:BusConnect(UiDynamicScrollBoxDataBus, self.Tables.Allied)
  self:BusConnect(UiDynamicScrollBoxElementNotificationBus, self.Tables.Allied)
  self:BusConnect(UiDynamicScrollBoxDataBus, self.Tables.Enemy)
  self:BusConnect(UiDynamicScrollBoxElementNotificationBus, self.Tables.Enemy)
end
function WarboardEndOfMatch:SetupExitButton()
  self.ExitButton:SetText("@ui_continue")
  self.ExitButton:SetButtonStyle(self.ExitButton.BUTTON_STYLE_HERO)
  self.ExitButton:SetCallback(self.OnLeave, self)
  self.ExitButton:SetSoundOnFocus(self.audioHelper.FrontEnd_OnPlayHover)
  self.ExitButton:SetSoundOnPress(self.audioHelper.FrontEnd_OnPlayPress)
end
function WarboardEndOfMatch:ConstructNavMenu()
  self.MenuButtonData = {
    {
      screen = self.Properties.TabContent.Overview,
      text = "@ui_war_eom_overview_tab",
      callback = self.SetSelectedScreenVisible
    },
    {
      screen = self.Properties.TabContent.Performance,
      text = "@ui_war_eom_performance_tab",
      callback = self.SetSelectedScreenVisible
    },
    {
      screen = self.Properties.TabContent.Rankings,
      text = "@ui_war_eom_rankings_tab",
      callback = self.SetSelectedScreenVisible
    }
  }
  self.NavBar.TabbedListMenuHolder:SetListData(self.MenuButtonData, self)
  self.NavBar.ScreenHeader:SetHintCallback(self.OnLeave, self)
end
function WarboardEndOfMatch:FillTablesWithStatsData()
  self.PlayerHeaderPanel.Icon:SetPlayerId(self.playerId)
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
    if playerData.playerId and self.playerId and playerData.playerId:GetCharacterIdString() == self.playerId:GetCharacterIdString() then
      playerData.highlight = true
    end
    table.insert(self.alliedPlayerData, playerData)
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
  if self.gameMode == GameModeCommon.GAMEMODE_OUTPOST_RUSH then
    self.alliedColor = self.UIStyle.COLOR_BLUE
    self.enemyColor = self.UIStyle.COLOR_RED_DARK
    self.leftBannerColor = self.UIStyle.COLOR_BLUE
    self.rightBannerColor = self.UIStyle.COLOR_RED_DARK
  end
  self.WarboardRankingsTable:SetDataSources(self.alliedPlayerData, self.enemyPlayerData, self.allPlayerData, self.alliedColor, self.enemyColor, warboardCommon.statsShown[self.gameMode])
  local k = self.localPlayerStats
  local listItemData = {
    playerId = self.playerId,
    color = self.UIStyle.COLOR_WHITE,
    isConnected = true
  }
  self:AddValuesToEntry(listItemData, self.playerRank, self:GetMemberName(k.characterId), k)
  self.LocalRankListItem:SetData(listItemData)
  ClearTable(self.alliedTable)
  table.sort(self.alliedPlayerData, function(a, b)
    return b.values[warboardCommon.firstStatIndex] < a.values[warboardCommon.firstStatIndex]
  end)
  local i = 1
  for _, v in pairs(self.alliedPlayerData) do
    local playerData = {
      values = v.values,
      playerId = v.playerId,
      color = self.leftBannerColor,
      isConnected = v.isConnected
    }
    playerData.values[warboardCommon.rankIndex] = i
    if i <= 5 then
      table.insert(self.alliedTable, playerData)
    else
      break
    end
    i = i + 1
  end
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.Tables.Allied)
  ClearTable(self.enemyTable)
  table.sort(self.enemyPlayerData, function(a, b)
    return b.values[warboardCommon.firstStatIndex] < a.values[warboardCommon.firstStatIndex]
  end)
  local i = 1
  for _, v in pairs(self.enemyPlayerData) do
    local playerData = {
      values = v.values,
      playerId = v.playerId,
      color = self.rightBannerColor,
      isConnected = v.isConnected
    }
    playerData.values[warboardCommon.rankIndex] = i
    if i <= 5 then
      table.insert(self.enemyTable, playerData)
    else
      break
    end
    i = i + 1
  end
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.Tables.Enemy)
  ClearTable(self.statsTable)
  local statLabels = warboardCommon.topStats[self.gameMode]
  for i = 1, #statLabels do
    local statData = {
      statName = self.statNames[statLabels[i] + 1],
      statValue = self:GetStat(statLabels[i], self.localPlayerStats),
      color = self.leftBannerColor
    }
    table.insert(self.statsTable, statData)
  end
  local healingDone = self:GetStat(WarboardStatsEntry.eWarboardStatType_HealingDone, self.localPlayerStats)
  local totalDamageDealt = self:GetStat(WarboardStatsEntry.eWarboardStatType_TotalDamageDealt, self.localPlayerStats)
  local higherStat = totalDamageDealt
  local statLabel = self.statNames[WarboardStatsEntry.eWarboardStatType_TotalDamageDealt + 1]
  if healingDone > totalDamageDealt then
    statLabel = self.statNames[WarboardStatsEntry.eWarboardStatType_HealingDone + 1]
    higherStat = healingDone
  end
  local statData = {
    statName = statLabel,
    statValue = higherStat,
    color = self.leftBannerColor
  }
  table.insert(self.statsTable, statData)
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.Tables.Stats)
  ClearTable(self.performanceTable)
  local warboardOnlyStats = warboardCommon.performanceStats[self.gameMode]
  for i = 1, #warboardOnlyStats do
    local entryId = warboardOnlyStats[i]
    local performanceData = {
      statName = self.statNames[entryId + 1],
      statValue = self:GetStat(entryId, self.localPlayerStats),
      statIndex = entryId + 1,
      color = self.leftBannerColor
    }
    table.insert(self.performanceTable, performanceData)
  end
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.Tables.Performance)
  self:SetupPlayerPanel()
  local playerStandout = {
    playerId = self.playerId,
    color = self.leftBannerColor,
    highlight = true,
    factionColorLight = self.leftFactionColorLight,
    isInvasion = self.isInvasion,
    isConnected = true
  }
  self:AddValuesToEntry(playerStandout, self.playerRank, self.playerName, self.localPlayerStats)
  self.LocalPlayerStandout:SetData(playerStandout)
end
function WarboardEndOfMatch:ShowWarboardEndOfMatch(data)
  local container
  for _, typeData in ipairs(self.panelTypes) do
    local matchesType = typeData.panelType == data.panelType
    if container ~= typeData.container then
      UiElementBus.Event.SetIsEnabled(typeData.container, matchesType)
    end
    if matchesType then
      container = typeData.container
    end
  end
  if not container then
    Log("[WarboardEndOfMatch] Error: data is not associated with any panels")
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
  if not self.isOutpostRush then
    local resultLeftText = "@ui_siege_loss"
    local leftColor = self.UIStyle.COLOR_WARBOARD_DEFEAT
    local resultRightText = "@ui_siege_win"
    local rightColor = self.UIStyle.COLOR_WARBOARD_VICTORY
    if self.isWin then
      resultLeftText = "@ui_siege_win"
      leftColor = self.UIStyle.COLOR_WARBOARD_VICTORY
      resultRightText = "@ui_siege_loss"
      rightColor = self.UIStyle.COLOR_WARBOARD_DEFEAT
    end
    self.CrestBanner.Left:SetResult(resultLeftText, leftColor)
    self.CrestBanner.Right:SetResult(resultRightText, rightColor)
    local roleLeftText = "@ui_siege_structure_defenders"
    local roleRightText = "@ui_siege_structure_attackers"
    if self.isAttacker then
      roleLeftText = "@ui_siege_structure_attackers"
      roleRightText = "@ui_siege_structure_defenders"
    end
    self.CrestBanner.Left:SetRole(roleLeftText)
    self.CrestBanner.Right:SetRole(roleRightText)
  end
  self.currentPanelIndex = 1
  self.hasSeenLastPanel = self.numPanels == 1
  UiElementBus.Event.SetIsEnabled(self.Properties.ExitButton, self.numPanels == 1)
  if data.setState then
    LyShineManagerBus.Broadcast.SetState(921202721)
  end
end
function WarboardEndOfMatch:OnSiegeWarfareStarted(warId)
end
function WarboardEndOfMatch:OnSiegeWarfareEnded(isWin, resolutionPhaseEndTimePoint)
  self.leftBannerRetryCount = 0
  self.rightBannerRetryCount = 0
  if not self.raidId or not self.raidId:IsValid() then
    return
  end
  self.theWarDetails = WarDataServiceBus.Broadcast.GetWarForRaid(self.raidId)
  local warDetails = self.theWarDetails
  if warDetails:IsValid() then
    local isAttacker = warDetails:IsAttackingRaid(self.raidId)
    local guildId = isAttacker and warDetails:GetAttackerGuildId() or warDetails:GetDefenderGuildId()
    local isInvasion = not warDetails:GetAttackerGuildId():IsValid()
    self.isWin = isWin
    self.guildId = guildId
    self.isAttacker = isAttacker
    self.isInvasion = isInvasion
    self.socialDataHandler:GetGuildDetailedData_ServerCall(self, self.GetGuildDetailedDataSuccess, self.GetLeftGuildDetailedDataFailure, self.guildId)
    self:SetElements(self.isInvasion)
    UiElementBus.Event.SetIsEnabled(self.Properties.PlayerStandoutHeaders.War, not self.isInvasion)
    UiElementBus.Event.SetIsEnabled(self.Properties.PlayerStandoutHeaders.Invasion, self.isInvasion)
    self.CrestBanner.Left:SetupOutpostRushVisuals(false)
    self.CrestBanner.Right:SetupOutpostRushVisuals(false)
    if self.isInvasion then
      UiElementBus.Event.SetIsEnabled(self.Properties.Tables.Enemy, false)
      self.CrestBanner.Right:SetupInvasionVisuals(true)
      self.CrestBanner.Right:DisableRoleIcon()
      local territoryId = warDetails:GetTerritoryId()
      local locationText = GetLocalizedReplacementText("@ui_siege_signup_fortressname", {
        territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(territoryId)
      })
      self.CrestBanner.Right:SetInvasionLocationLocalized(locationText)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.Tables.Enemy, true)
      self.CrestBanner.Right:SetupInvasionVisuals(false)
      local attackingGuildId = warDetails:GetAttackerGuildId()
      self.otherGuildId = self.guildId == attackingGuildId and warDetails:GetDefenderGuildId() or attackingGuildId
      self.socialDataHandler:GetGuildDetailedData_ServerCall(self, self.GetGuildDetailedDataSuccess, self.GetRightGuildDetailedDataFailure, self.otherGuildId)
    end
    local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
    self.resolutionEndPoint = resolutionPhaseEndTimePoint
    self.totalWaitTimeInSeconds = self.resolutionEndPoint:Subtract(now):ToSeconds()
    self.tickBusHandler = nil
    self:FetchWarboardStats()
    self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.WarboardCacheUpdate", function(self, updated)
      if updated then
        self:FetchWarboardStats()
      end
    end)
    self.timer = self.second
  end
end
function WarboardEndOfMatch:FetchWarboardStats()
  local warboardStats = WarboardDataServiceBus.Broadcast.GetWarboardStats()
  if warboardStats and warboardStats:IsValid() then
    local allPlayers = warboardStats:GetActivePlayersCount()
    local defenderStats = warboardStats:GetDefenderStatValues()
    local attackerStats = warboardStats:GetAttackerStatValues()
    self.localPlayerStats = warboardStats:GetLocalPlayerStats()
    self.playerRank = warboardStats:GetLocalPlayerRank()
    self.statNames = warboardStats:GetStatNames()
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
    if self.isOutpostRush then
      local outpostApoints = self.dataLayer:GetDataFromNode(self:GetGameModeDataPath(2314274524))
      local outpostBpoints = self.dataLayer:GetDataFromNode(self:GetGameModeDataPath(4119864071))
      local outpostCpoints = self.dataLayer:GetDataFromNode(self:GetGameModeDataPath(1755300465))
      local team0outpostAPoints = BitwiseHelper:And(outpostApoints, OutpostRush_CaptureCountMask)
      local team1outpostAPoints = BitwiseHelper:RShift(outpostApoints, OutpostRush_CaptureCountBitsPerTeam)
      local team0outpostBPoints = BitwiseHelper:And(outpostBpoints, OutpostRush_CaptureCountMask)
      local team1outpostBPoints = BitwiseHelper:RShift(outpostBpoints, OutpostRush_CaptureCountBitsPerTeam)
      local team0outpostCPoints = BitwiseHelper:And(outpostCpoints, OutpostRush_CaptureCountMask)
      local team1outpostCPoints = BitwiseHelper:RShift(outpostCpoints, OutpostRush_CaptureCountBitsPerTeam)
      local team0killPoints = 0
      local team1killPoints = 0
      for i = 1, #attackerStats do
        team0killPoints = team0killPoints + math.modf(attackerStats[i]:GetStatEntryValue(WarboardStatsEntry.eWarboardStatType_PlayerKills))
      end
      for i = 1, #defenderStats do
        team1killPoints = team1killPoints + math.modf(defenderStats[i]:GetStatEntryValue(WarboardStatsEntry.eWarboardStatType_PlayerKills))
      end
      if self.playerTeamIndex == 0 then
        self.CrestBanner.Left:SetORPoints(team0outpostAPoints, team0outpostBPoints, team0outpostCPoints, team0killPoints)
        self.CrestBanner.Right:SetORPoints(team1outpostAPoints, team1outpostBPoints, team1outpostCPoints, team1killPoints)
      else
        self.CrestBanner.Left:SetORPoints(team1outpostAPoints, team1outpostBPoints, team1outpostCPoints, team1killPoints)
        self.CrestBanner.Right:SetORPoints(team0outpostAPoints, team0outpostBPoints, team0outpostCPoints, team0killPoints)
      end
    end
  end
end
function WarboardEndOfMatch:GetGameModeDataPath(valueName)
  return "GameMode." .. tostring(self.gameModeEntityId) .. "." .. valueName
end
function WarboardEndOfMatch:OnTick(deltaTime, timePoint)
  if self.resolutionEndPoint then
    if self.timer >= self.second then
      self.timer = self.timer - self.second
      local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
      local secondsLeft = self.resolutionEndPoint:Subtract(now):ToSeconds()
      local secondsToString = timeHelpers:ConvertSecondsToHrsMinSecString(secondsLeft, false, false, false)
      UiTextBus.Event.SetText(self.Properties.TimerRemaining, secondsToString)
      local progress = secondsLeft / self.totalWaitTimeInSeconds
      self.TimerProgressBar:SetProgressPercent(progress)
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
end
function WarboardEndOfMatch:OnLeave()
  LyShineManagerBus.Broadcast.ExitState(921202721)
end
function WarboardEndOfMatch:SetElements(isInvasion)
  self.WarboardRankingsTable:SetInvasionMode(isInvasion)
end
function WarboardEndOfMatch:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  if self.isOutpostRush then
    self.NavBar.ScreenHeader:SetText("@ui_outpost_rush_signup_title")
  else
    self.NavBar.ScreenHeader:SetText("@ui_war_eom_war_results")
  end
  self:SetScreenVisible(true)
  self.PrimaryTabLineRight:SetVisible(false, 0)
  self.PrimaryTabLineRight:SetVisible(true, 0.8)
  local data = {
    panelType = self.PANEL_TYPE_WARBOARD,
    setState = false
  }
  if self.isOutpostRush then
    data.panelType = self.PANEL_TYPE_OUTPOSTRUSH
    self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_OutpostRush, self.audioHelper.MusicState_OR_ScoreBoard)
  else
    self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_OutpostRush, self.audioHelper.MusicState_SiegeEnded)
  end
  self:ShowWarboardEndOfMatch(data)
  JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
  JavelinCameraRequestBus.Broadcast.SetDepthOfField(self.UIStyle.BLUR_DEPTH_OF_FIELD, self.UIStyle.BLUR_AMOUNT, self.UIStyle.BLUR_NEAR_DISTANCE, self.UIStyle.BLUR_NEAR_SCALE, self.UIStyle.RANGE_DEPTH_OF_FIELD)
  self.ExitButton:StartStopImageSequence(true)
  self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
end
function WarboardEndOfMatch:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  self:SetScreenVisible(false)
  JavelinCameraRequestBus.Broadcast.ResetDepthOfField()
  if self.gameMode == GameModeCommon.GAMEMODE_OUTPOST_RUSH then
    GameModeParticipantComponentRequestsBus.Event.SendClientEvent(self.playerEntityId, 2612035792)
    self.gameMode = 0
  else
    GroupsRequestBus.Broadcast.RequestLeaveGroup()
  end
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  self.ExitButton:StartStopImageSequence(false)
  if self.tickBusHandler then
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
  end
end
function WarboardEndOfMatch:SelectAllFilterTab()
  self.WarboardRankingsTable:SelectAllFilterTab()
end
function WarboardEndOfMatch:OnFilterTabSelected(entityId)
  self.WarboardRankingsTable:OnFilterTabSelected(entityId)
end
function WarboardEndOfMatch:GetLeftGuildDetailedDataFailure(reason)
  if reason == eSocialRequestFailureReasonThrottled then
    Log("ERR - WarboardEndOfMatch:OnSiegeWarfareEnded: GuildData request throttled")
  elseif reason == eSocialRequestFailureReasonTimeout then
    Log("WARN - WarboardEndOfMatch:OnSiegeWarfareEnded: GuildData request timed out")
    if self.leftBannerRetryCount < self.maxRetries and self.raidId then
      self.leftBannerRetryCount = self.leftBannerRetryCount + 1
      self.socialDataHandler:GetGuildDetailedData_ServerCall(self, self.GetGuildDetailedDataSuccess, self.GetLeftGuildDetailedDataFailure, self.guildId)
    end
  end
end
function WarboardEndOfMatch:GetRightGuildDetailedDataFailure(reason)
  if reason == eSocialRequestFailureReasonThrottled then
    Log("ERR - WarboardEndOfMatch:OnSiegeWarfareEnded: GuildData request throttled")
  elseif reason == eSocialRequestFailureReasonTimeout then
    Log("WARN - WarboardEndOfMatch:OnSiegeWarfareEnded: GuildData request timed out")
    if self.rightBannerRetryCount < self.maxRetries and self.raidId then
      self.rightBannerRetryCount = self.rightBannerRetryCount + 1
      self.socialDataHandler:GetGuildDetailedData_ServerCall(self, self.GetGuildDetailedDataSuccess, self.GetRightGuildDetailedDataFailure, self.otherGuildId)
    end
  end
end
function WarboardEndOfMatch:GetGuildDetailedDataSuccess(result)
  local guildData
  if 0 < #result then
    guildData = type(result[1]) == "table" and result[1].guildData or result[1]
  else
    Log("ERR - WarboardEndOfMatch:OnSiegeWarfareEnded: GuildData request returned with no data")
    return
  end
  if guildData and guildData:IsValid() then
    local factionName = factionCommon.factionInfoTable[guildData.faction].factionName
    local factionColor = factionCommon.factionInfoTable[guildData.faction].crestBgColorLight
    if guildData.guildId == self.guildId then
      self.CrestBanner.Left:SetCompanyName(guildData.guildName)
      self.CrestBanner.Left:UpdateIcon(guildData.crestData)
      self.leftBannerColor = guildData.crestData.backgroundColor
      self.leftFactionColorLight = factionColor
      self.CrestBanner.Left:SetBannerColor(self.leftBannerColor)
      self.CrestBanner.Left:SetFactionName(factionName, factionColor)
      self.alliedColor = factionColor
      if self.isInvasion then
        self.CrestBanner.Left:SetAttackerIcon(false)
      else
        self.CrestBanner.Left:SetAttackerIcon(self.isAttacker)
      end
    else
      self.CrestBanner.Right:SetCompanyName(guildData.guildName)
      self.CrestBanner.Right:UpdateIcon(guildData.crestData)
      self.rightBannerColor = guildData.crestData.backgroundColor
      self.rightFactionColorLight = factionColor
      self.CrestBanner.Right:SetBannerColor(self.rightBannerColor)
      self.CrestBanner.Right:SetFactionName(factionName, factionColor)
      self.CrestBanner.Right:SetAttackerIcon(guildData.guildId == self.theWarDetails:GetAttackerGuildId())
      self.enemyColor = factionColor
    end
  end
end
function WarboardEndOfMatch:GetNumElements()
  local busId = UiDynamicScrollBoxDataBus.GetCurrentBusId()
  if busId == self.Properties.Tables.Stats then
    return #self.statsTable
  elseif busId == self.Properties.Tables.Performance then
    return #self.performanceTable
  elseif busId == self.Properties.Tables.Allied then
    return #self.alliedTable
  elseif busId == self.Properties.Tables.Enemy then
    return #self.enemyTable
  else
    Log("WarboardEndOfMatch: GetNumElements requested from unrecognized scroll box")
    return 0
  end
end
function WarboardEndOfMatch:OnElementBecomingVisible(rootEntity, index)
  local function updateItem(self, dataTable, i)
    local currentData = dataTable[i + 1]
    if currentData then
      local listItem = self.registrar:GetEntityTable(rootEntity)
      if listItem ~= nil then
        local listItemData = {
          statName = currentData.statName,
          statValue = currentData.statValue,
          statIndex = currentData.statIndex,
          color = currentData.color,
          isConnected = currentData.isConnected
        }
        listItem:SetData(listItemData)
      end
    end
  end
  local function updateStandoutListItem(self, dataTable, i, isAllied)
    local currentData = dataTable[i + 1]
    if currentData then
      local listItem = self.registrar:GetEntityTable(rootEntity)
      local lightColor = self.leftFactionColorLight
      if not isAllied then
        lightColor = self.rightFactionColorLight
      end
      if listItem ~= nil then
        local listItemData = {
          playerId = currentData.playerId,
          color = currentData.color,
          isInvasion = self.isInvasion,
          factionColorLight = lightColor,
          values = currentData.values,
          isConnected = currentData.isConnected
        }
        listItem:SetData(listItemData)
      end
    end
  end
  local busId = UiDynamicScrollBoxElementNotificationBus.GetCurrentBusId()
  if busId == self.Properties.Tables.Stats then
    updateItem(self, self.statsTable, index)
  elseif busId == self.Properties.Tables.Performance then
    updateItem(self, self.performanceTable, index)
  elseif busId == self.Properties.Tables.Allied then
    updateStandoutListItem(self, self.alliedTable, index, true)
  elseif busId == self.Properties.Tables.Enemy then
    updateStandoutListItem(self, self.enemyTable, index, false)
  else
    Log("WarboardEndOfMatch: OnElementBecomingVisible requested from unrecognized scroll box")
  end
end
function WarboardEndOfMatch:UpdateAllMembers()
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
function WarboardEndOfMatch:UpdateMembers_OnGetMemberData(memberResults)
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
function WarboardEndOfMatch:UpdateMembers_OnGetMemberDataFailed(reason, memberResults)
  self:UpdateMembers_OnGetMemberData(memberResults)
end
function WarboardEndOfMatch:GetMemberName(memberCharacterId)
  for index, value in ipairs(self.members) do
    local memberPlayerId = value.playerId
    if memberPlayerId:GetCharacterIdString() == memberCharacterId then
      return memberPlayerId.playerName
    end
  end
  return ""
end
function WarboardEndOfMatch:GetMemberPlayerId(memberCharacterId)
  for index, value in ipairs(self.members) do
    local memberPlayerId = value.playerId
    if memberPlayerId:GetCharacterIdString() == memberCharacterId then
      return memberPlayerId
    end
  end
  return nil
end
function WarboardEndOfMatch:SetSelectedScreenVisible(entity)
  if self.currentSelectedScreen then
    UiElementBus.Event.SetIsEnabled(self.currentSelectedScreen, false)
  end
  local buttonIndex = entity:GetIndex()
  local showPlayerHeader = true
  if buttonIndex == 2 or buttonIndex == 3 then
    showPlayerHeader = false
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.PlayerHeader, showPlayerHeader)
  local screenToShow = self.MenuButtonData[buttonIndex].screen
  self.currentSelectedScreen = screenToShow
  UiElementBus.Event.SetIsEnabled(screenToShow, true)
  self.ScriptedEntityTweener:Play(screenToShow, 0.3, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
end
function WarboardEndOfMatch:SetScreenVisible(isVisible)
  local animDuration = 0.8
  if isVisible then
    self.ScriptedEntityTweener:Play(self.entityId, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.NavBar.NarBarHolder, 0.3, {opacity = 0, y = 30}, {
      opacity = 1,
      y = 0,
      ease = "QuadOut",
      delay = 0.3
    })
    self.NavBar.TabbedListMenuHolder:SetSelected(1)
    self.CrestBanner.Left:SetBannerVisible()
    self.CrestBanner.Right:SetBannerVisible()
  else
    self.NavBar.TabbedListMenuHolder:SetUnselected()
  end
end
function WarboardEndOfMatch:AddValuesToEntry(entry, rank, name, statsTable)
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
function WarboardEndOfMatch:SetGameMode(gamemode)
  self.gameMode = gamemode
end
function WarboardEndOfMatch:GetGameMode()
  return self.gameMode
end
function WarboardEndOfMatch:OnOutpostRushMatchEnded(gameModeEntityId, data)
  self.isDraw = data.isDraw
  self.isWin = data.playerWin
  self.isInvasion = false
  self.isOutpostRush = true
  self.playerTeamIndex = data.playerTeamIndex
  self.isAttacker = data.playerTeamIndex == 0
  self.gameModeEntityId = gameModeEntityId
  self:SetElements(self.isInvasion)
  UiElementBus.Event.SetIsEnabled(self.Properties.PlayerStandoutHeaders.War, not self.isInvasion)
  UiElementBus.Event.SetIsEnabled(self.Properties.PlayerStandoutHeaders.Invasion, self.isInvasion)
  UiElementBus.Event.SetIsEnabled(self.Properties.Tables.Enemy, true)
  self.CrestBanner.Right:SetupInvasionVisuals(false)
  local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
  self.resolutionEndPoint = data.cleanupTimepoint
  self.totalWaitTimeInSeconds = self.resolutionEndPoint:Subtract(now):ToSeconds()
  self.CrestBanner.Left:SetupOutpostRushVisuals(true, data.ownTeamScore)
  self.CrestBanner.Left:SetBannerColor(self.UIStyle.COLOR_BLUE)
  self.CrestBanner.Right:SetupOutpostRushVisuals(true, data.enemyTeamScore)
  self.CrestBanner.Right:SetBannerColor(self.UIStyle.COLOR_RED_DARK)
  self.CrestBanner.Left:SetTeamName("@ui_your_team")
  self.CrestBanner.Right:SetTeamName("@ui_enemy_team")
  local resultLeftText = "@ui_siege_loss"
  local leftColor = self.UIStyle.COLOR_WARBOARD_DEFEAT
  local resultRightText = "@ui_siege_win"
  local rightColor = self.UIStyle.COLOR_WARBOARD_VICTORY
  if self.isDraw then
    resultLeftText = "@ui_siege_draw"
    leftColor = self.UIStyle.COLOR_GRAY_80
    resultRightText = "@ui_siege_draw"
    rightColor = self.UIStyle.COLOR_GRAY_80
  elseif self.isWin then
    resultLeftText = "@ui_siege_win"
    leftColor = self.UIStyle.COLOR_WARBOARD_VICTORY
    resultRightText = "@ui_siege_loss"
    rightColor = self.UIStyle.COLOR_WARBOARD_DEFEAT
  end
  self.CrestBanner.Left:SetResult(resultLeftText, leftColor)
  self.CrestBanner.Right:SetResult(resultRightText, rightColor)
  self.currentPanelIndex = 1
  self.hasSeenLastPanel = self.numPanels == 1
  self:FetchWarboardStats()
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.WarboardCacheUpdate", function(self, updated)
    if updated then
      self:FetchWarboardStats()
    end
  end)
end
return WarboardEndOfMatch
