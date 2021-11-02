local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
local TimeHelperFunctions = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local layouts = RequireScript("LyShineUI.Banner.Layouts")
local BitwiseHelper = RequireScript("LyShineUI._Common.BitwiseHelpers")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local GameModeCommon = RequireScript("LyShineUI._Common.GameModeCommon")
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
local SiegeMarkerData = RequireScript("LyShineUI.Markers.SiegeMarkerData")
local OutpostRushHud = {
  Properties = {
    Timer = {
      default = EntityId()
    },
    BannerFrame = {
      default = EntityId()
    },
    ClaimPointHolder = {
      default = EntityId()
    },
    ClaimPointIconA = {
      default = EntityId()
    },
    ClaimPointIconB = {
      default = EntityId()
    },
    ClaimPointIconC = {
      default = EntityId()
    },
    TeamScore_Friendly = {
      default = EntityId()
    },
    TeamScore_FriendlyBar = {
      default = EntityId()
    },
    TeamScore_FriendlyBarGlintHolder = {
      default = EntityId()
    },
    TeamScore_FriendlyBarGlint = {
      default = EntityId()
    },
    TeamScore_FriendlyFrozenEffect1 = {
      default = EntityId()
    },
    TeamScore_FriendlyFrozenEffect2 = {
      default = EntityId()
    },
    TeamScore_FriendlyFrozenLockedText = {
      default = EntityId()
    },
    TeamScore_FriendlyScoreIncreaseEffect = {
      default = EntityId()
    },
    TeamScore_Enemy = {
      default = EntityId()
    },
    TeamScore_EnemyBar = {
      default = EntityId()
    },
    TeamScore_EnemyBarGlintHolder = {
      default = EntityId()
    },
    TeamScore_EnemyBarGlint = {
      default = EntityId()
    },
    TeamScore_EnemyFrozenEffect1 = {
      default = EntityId()
    },
    TeamScore_EnemyFrozenEffect2 = {
      default = EntityId()
    },
    TeamScore_EnemyFrozenLockedText = {
      default = EntityId()
    },
    TeamScore_EnemyScoreIncreaseEffect = {
      default = EntityId()
    },
    ResourceTray = {
      default = EntityId()
    },
    ResourceItems = {
      default = {
        EntityId()
      }
    },
    ScoreToWinText = {
      default = EntityId()
    },
    PreGameContainer = {
      default = EntityId()
    },
    PreGameText = {
      default = EntityId()
    },
    PreGameTimer = {
      default = EntityId()
    },
    PregameTutorialHintHolder = {
      default = EntityId()
    },
    PregameTutorialHintText = {
      default = EntityId()
    },
    PregameTutorialHint = {
      default = EntityId()
    },
    BossTimerContainer = {
      default = EntityId()
    },
    BossIcon = {
      default = EntityId()
    },
    BossName = {
      default = EntityId()
    },
    BossTimer = {
      default = EntityId()
    },
    WarboardHint = {
      default = EntityId()
    },
    ORContextualNotifications = {
      default = EntityId()
    }
  },
  screenStatesToDisable = {
    [2478623298] = true,
    [3901667439] = true,
    [3777009031] = true,
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
    [1468490675] = true,
    [1101180544] = true,
    [1634988588] = true,
    [921202721] = true,
    [4241440342] = true,
    [2972535350] = true,
    [3349343259] = true,
    [2552344588] = true,
    [2477632187] = true,
    [3160088100] = true
  },
  dataLayer_stateId = "State",
  dataLayer_localPlayerTeamIdx = "LocalPlayer.teamIdx",
  dataLayer_winningTeamIdxId = tostring(1116393986),
  dataLayer_teamScores = 1248760450,
  dataLayer_timeLimitTimerId = "Timer_" .. tostring(2400096598),
  dataLayer_timeLimitPreGame = "Timer_" .. tostring(4109808926),
  dataLayer_timeLimitCleanup = "Timer_" .. tostring(3393729753),
  dataLayer_timerBoss = "Timer_" .. tostring(3888164413),
  dataLayer_frozenTeamIdx = 3604328411,
  dataLayer_scorePerOutpostClaimed = 3884730614,
  scoreToWin = nil,
  markerBasePath = "Hud.LocalPlayer.Siege.ClaimPoints.",
  teamScoreBarWidth = 311,
  teamScoreGlintWidth = 40,
  isInScoreboard = false,
  INVALID_TEAM_ID = 255,
  DRAW_TEAM_ID = 2,
  startingUVSpeed = 0.2,
  incrementSpeed = 0.1,
  currentSpeed = 0.2,
  maxUVSpeed = 0.4,
  teamWithSlaughter = 255,
  slaughterEffectEntity = nil,
  UVsToScroll = nil
}
BaseScreen:CreateNewScreen(OutpostRushHud)
function OutpostRushHud:OnInit()
  BaseScreen.OnInit(self)
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  self.itemsForResourceTray = {
    469492035,
    3074244685,
    3954961784,
    324048019
  }
  self.isMusicEnding = false
  self.bannerColors = {
    DEFAULT = 1,
    RED = 2,
    BLUE = 3
  }
  self.outposts = {
    A = 0,
    B = 1,
    C = 2
  }
  self.markerType = {CAPTUREPOINT = 1, GATE = 2}
  self.markerData = {
    {
      crc = 2266539104,
      dataLayerId = 3289490575,
      name = "A",
      enum = ORStructure_Gate1,
      type = self.markerType.GATE,
      index = 1
    },
    {
      crc = 504493530,
      dataLayerId = 3094380884,
      name = "A",
      enum = ORStructure_Gate2,
      type = self.markerType.GATE,
      index = 2
    },
    {
      crc = 2889217955,
      dataLayerId = 3580677878,
      name = "B",
      enum = ORStructure_Gate1,
      type = self.markerType.GATE,
      index = 3
    },
    {
      crc = 893167129,
      dataLayerId = 2836261677,
      name = "B",
      enum = ORStructure_Gate2,
      type = self.markerType.GATE,
      index = 4
    },
    {
      crc = 3039741666,
      dataLayerId = 1821840670,
      name = "C",
      enum = ORStructure_Gate1,
      type = self.markerType.GATE,
      index = 5
    },
    {
      crc = 740792152,
      dataLayerId = 284569797,
      name = "C",
      enum = ORStructure_Gate2,
      type = self.markerType.GATE,
      index = 6
    },
    {
      crc = 3862203027,
      dataLayerId = nil,
      name = "A",
      type = self.markerType.CAPTUREPOINT,
      index = 7
    },
    {
      crc = 2134760233,
      dataLayerId = nil,
      name = "B",
      type = self.markerType.CAPTUREPOINT,
      index = 8
    },
    {
      crc = 138079167,
      dataLayerId = nil,
      name = "C",
      type = self.markerType.CAPTUREPOINT,
      index = 9
    }
  }
  self.compassData = {
    {
      crc = 2717090594,
      imagePath = "lyshineui/images/hud/outpostrush/iconportal.dds"
    },
    {
      crc = 184469958,
      imagePath = "lyshineui/images/hud/outpostrush/iconiceboss.dds"
    }
  }
  self.capturePointInfo = {
    {
      statusDataLayerId = tostring(1150146850),
      claimPointIcon = self.ClaimPointIconA
    },
    {
      statusDataLayerId = tostring(3389185729),
      claimPointIcon = self.ClaimPointIconB
    },
    {
      statusDataLayerId = tostring(111730271),
      claimPointIcon = self.ClaimPointIconC
    }
  }
  for i = 1, #self.itemsForResourceTray do
    if self.ResourceItems[i - 1] then
      self.ResourceItems[i - 1]:SetItem(StaticItemDataManager:GetItem(self.itemsForResourceTray[i]))
    end
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.InventoryEntityId", function(self, inventoryId)
    if inventoryId then
      self.inventoryId = inventoryId
      if self.localPlayerTeamIdx then
        self:BusDisconnect(self.containerEventHandler)
        self.containerEventHandler = self:BusConnect(ContainerEventBus, self.inventoryId)
      end
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, rootEntityId)
    if rootEntityId then
      self.localPlayerEntityId = rootEntityId
      self:BusDisconnect(self.participantBusHandler)
      self.participantBusHandler = self:BusConnect(GameModeParticipantComponentNotificationBus, rootEntityId)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Raid.Id", function(self, raidId)
    self.localPlayerRaidId = raidId
    if self.localPlayerRaidId ~= nil and self.localPlayerRaidId:IsValid() and self.gameModeEntityId ~= nil then
      UiElementBus.Event.SetIsEnabled(self.entityId, true)
      UiFaderBus.Event.SetFadeValue(self.entityId, 1)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Map.InitCount", function(self, count)
    if not count or count < 2 then
      return
    end
    self.mapIsReady = true
    self:UpdateMap()
  end)
  self.friendlyUVs = {
    1,
    1,
    0,
    0
  }
  self.enemyUVs = {
    0,
    0,
    1,
    1
  }
  UiImageBus.Event.SetUVOverrides(self.Properties.TeamScore_FriendlyScoreIncreaseEffect, self.friendlyUVs[1], self.friendlyUVs[2], self.friendlyUVs[3], self.friendlyUVs[4])
  self:SetVisualElements()
end
function OutpostRushHud:OnShutdown()
  BaseScreen.OnShutdown(self)
  if self.outpostRushHandler then
    DynamicBus.OutpostRush.Disconnect(self.entityId, self)
    self.outpostRushHandler = nil
  end
end
function OutpostRushHud:SetVisualElements()
  local preGameTextStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_MEDIUM,
    fontSize = 22,
    fontColor = self.UIStyle.COLOR_WHITE
  }
  local preGameTimerStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_BOLD,
    fontSize = 28,
    fontColor = self.UIStyle.COLOR_WHITE
  }
  local frozenLockedTextStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = 28,
    fontColor = self.UIStyle.COLOR_WHITE,
    characterSpacing = 100
  }
  SetTextStyle(self.Properties.PreGameText, preGameTextStyle)
  SetTextStyle(self.Properties.PreGameTimer, preGameTimerStyle)
  SetTextStyle(self.Properties.PregameTutorialHintText, self.UIStyle.FONT_STYLE_HINT_LABEL)
  SetTextStyle(self.Properties.TeamScore_FriendlyFrozenLockedText, frozenLockedTextStyle)
  SetTextStyle(self.Properties.TeamScore_EnemyFrozenLockedText, frozenLockedTextStyle)
  UiTextBus.Event.SetTextWithFlags(self.Properties.PreGameText, "@ui_outpost_rush_prepare", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.PregameTutorialHintText, "@ui_outpost_rush_tutorial_how_it_works", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.TeamScore_FriendlyFrozenLockedText, "@ui_outpost_rush_locked", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.TeamScore_EnemyFrozenLockedText, "@ui_outpost_rush_locked", eUiTextSet_SetLocalized)
  self.PregameTutorialHint:SetKeybindMapping("openWarTutorial")
  UiTransformBus.Event.SetScaleX(self.Properties.TeamScore_FriendlyBarGlint, -1)
end
function OutpostRushHud:GetGameModeDataPath(valueName)
  return "GameMode." .. tostring(self.gameModeEntityId) .. "." .. valueName
end
function OutpostRushHud:GetReplicatedValueAsEntityId(id)
  if id then
    return GameModeComponentRequestBus.Event.GetReplicatedValueAsEntityId(self.gameModeEntityId, id)
  end
  return nil
end
function OutpostRushHud:GetIsLocalPlayerTeamIdx()
  return self.isLocalPlayerTeamIdx
end
function OutpostRushHud:OnEnteredGameMode(gameModeEntityId, gameModeId)
  if gameModeId ~= GameModeCommon.GAMEMODE_OUTPOST_RUSH then
    return
  end
  self.gameModeEntityId = gameModeEntityId
  self.inPreGameState = true
  self.WarboardHint:SetKeybindMapping("toggleWarboardInGame")
  if self.localPlayerRaidId ~= nil and self.localPlayerRaidId:IsValid() then
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    UiFaderBus.Event.SetFadeValue(self.entityId, 1)
  end
  self.ORContextualNotifications:EnteredGameMode(gameModeEntityId)
  DynamicBus.WarboardInGameBus.Broadcast.SetGameMode(GameModeCommon.GAMEMODE_OUTPOST_RUSH)
  DynamicBus.WarboardInGameBus.Broadcast.SetGameModeEntityId(gameModeEntityId)
  DynamicBus.WarboardEndOfMatch.Broadcast.SetGameMode(GameModeCommon.GAMEMODE_OUTPOST_RUSH)
  self:UpdateMap()
  self.actionHandler = self:BusConnect(CryActionNotificationsBus, "toggleWarboardInGame")
  self.outpostRushHandler = DynamicBus.OutpostRush.Connect(self.entityId, self)
  self.localPlayerEventsBusHandler = self:BusConnect(LocalPlayerEventsBus)
  for key, index in pairs(self.outposts) do
    self["ClaimPointIcon" .. key]:SetName(key, nil, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
    self.dataLayer:RegisterAndExecuteDataObserver(self, self:GetGameModeDataPath(Math.CreateCrc32("OutpostStructureStatuses" .. key)), function(self, status)
      self:OnStructureStatusChanged(key, status)
    end)
  end
  self.ClaimPointIconA:SetDisplayName("@ui_or_outpost_a")
  self.ClaimPointIconB:SetDisplayName("@ui_or_outpost_b")
  self.ClaimPointIconC:SetDisplayName("@ui_or_outpost_c")
  UiTextBus.Event.SetTextWithFlags(self.Properties.TeamScore_Friendly, "0", eUiTextSet_SetAsIs)
  UiTextBus.Event.SetTextWithFlags(self.Properties.TeamScore_Enemy, "0", eUiTextSet_SetAsIs)
  UiProgressBarBus.Event.SetProgressPercent(self.Properties.TeamScore_FriendlyBar, 0)
  UiProgressBarBus.Event.SetProgressPercent(self.Properties.TeamScore_EnemyBar, 0)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.TeamScore_FriendlyBarGlintHolder, 0)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.TeamScore_EnemyBarGlintHolder, 0)
  self.ScriptedEntityTweener:Set(self.Properties.TeamScore_FriendlyBar, {opacity = 1})
  self.ScriptedEntityTweener:Set(self.Properties.TeamScore_FriendlyBarGlint, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.TeamScore_FriendlyFrozenEffect1, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.TeamScore_FriendlyFrozenEffect2, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.TeamScore_FriendlyFrozenLockedText, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.TeamScore_EnemyBar, {opacity = 1})
  self.ScriptedEntityTweener:Set(self.Properties.TeamScore_EnemyBarGlint, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.TeamScore_EnemyFrozenEffect1, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.TeamScore_EnemyFrozenEffect2, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.TeamScore_EnemyFrozenLockedText, {opacity = 0})
  self.dataLayer:RegisterAndExecuteDataObserver(self, self:GetGameModeDataPath(self.dataLayer_localPlayerTeamIdx), function(self, localPlayerTeamIdx)
    if self.localPlayerTeamIdx ~= nil then
      return
    end
    self.localPlayerTeamIdx = localPlayerTeamIdx
    self.ORContextualNotifications:SetPlayerTeamIndex(localPlayerTeamIdx)
    self.frozenTeamIdx = self.INVALID_TEAM_ID
    if self.localPlayerTeamIdx then
      DynamicBus.WarboardInGameBus.Broadcast.SetPlayerTeamIndex(self.localPlayerTeamIdx)
      self.dataLayer:RegisterAndExecuteDataObserver(self, self:GetGameModeDataPath("ScoreNeededToWin"), function(self, scoreNeededToWin)
        if scoreNeededToWin and 0 < scoreNeededToWin then
          self.scoreToWin = scoreNeededToWin
          UiTextBus.Event.SetText(self.Properties.ScoreToWinText, GetLocalizedReplacementText("@ui_outpost_rush_score_to_win", {
            value = self.scoreToWin
          }))
        end
      end)
      self.dataLayer:RegisterAndExecuteDataObserver(self, self:GetGameModeDataPath(self.dataLayer_teamScores), function(self, score)
        if score and self.scoreToWin then
          local scoreTeam0 = BitwiseHelper:And(score, OutpostRush_ScoreMask)
          local scoreTeam1 = BitwiseHelper:RShift(score, OutpostRush_ScoreBitsPerTeam)
          self:UpdateTeamScore(0, scoreTeam0)
          self:UpdateTeamScore(1, scoreTeam1)
        end
      end)
      self.dataLayer:RegisterAndExecuteDataObserver(self, self:GetGameModeDataPath(self.dataLayer_stateId), function(self, state)
        if state then
          if state == 2493811998 then
            self:ShowPreGame(true)
            self:ShowGameHud(false)
            self.dataLayer:RegisterDataObserver(self, self:GetGameModeDataPath(self.dataLayer_timeLimitPreGame), function(self, timeRemaining)
              if timeRemaining then
                local secondsRemaining = math.max(math.ceil(timeRemaining / 1000), 0)
                local _, _, minutes, seconds = TimeHelperFunctions:ConvertSecondsToDaysHoursMinutesSeconds(secondsRemaining)
                local timerText = string.format("%d:%02d", minutes, seconds)
                UiTextBus.Event.SetText(self.Properties.PreGameTimer, timerText)
              end
            end)
            self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_OutpostRush, self.audioHelper.MusicState_OR_WarmUp)
          elseif state == 2231901092 then
            self:ShowPreGame(false)
            self:ShowGameHud(true)
            self:ShowBanner("@ui_outpost_rush_match_started", GetLocalizedReplacementText("@ui_outpost_rush_match_started_desc", {
              value = self.scoreToWin
            }), self.bannerColors.DEFAULT)
            self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_OutpostRush, self.audioHelper.MusicState_OR_Start)
            self.ORContextualNotifications:ShowTutorialNotification(ORTutorialEvent_Rules_Win)
          end
        end
      end)
      self.dataLayer:RegisterAndExecuteDataObserver(self, self:GetGameModeDataPath(self.dataLayer_frozenTeamIdx), function(self, frozenTeamIdx)
        frozenTeamIdx = frozenTeamIdx and frozenTeamIdx or self.INVALID_TEAM_ID
        self:UpdateFrozenAnimations(frozenTeamIdx)
      end)
      self.dataLayer:RegisterAndExecuteDataObserver(self, self:GetGameModeDataPath(self.dataLayer_scorePerOutpostClaimed), function(self, scorePerOutpost)
        if scorePerOutpost then
          if 1 < scorePerOutpost then
            self.teamWithSlaughter = self.capturePointInfo[1].claimPointIcon.teamIdx
            self.slaughterEffectEntity = self.Properties.TeamScore_FriendlyScoreIncreaseEffect
            self.UVsToScroll = self.friendlyUVs
            if self.teamWithSlaughter ~= self.localPlayerTeamIdx then
              self.slaughterEffectEntity = self.Properties.TeamScore_EnemyScoreIncreaseEffect
              self.UVsToScroll = self.enemyUVs
            end
            if UiElementBus.Event.IsEnabled(self.slaughterEffectEntity) == false then
              UiElementBus.Event.SetIsEnabled(self.slaughterEffectEntity, true)
              self.ScriptedEntityTweener:PlayFromC(self.slaughterEffectEntity, 0.3, {opacity = 0}, tweenerCommon.opacityTo30)
              self.currentSpeed = self.startingUVSpeed
            else
              self.currentSpeed = self.currentSpeed + self.incrementSpeed
              self.currentSpeed = Clamp(self.currentSpeed, self.startingUVSpeed, self.maxUVSpeed)
            end
            if not self.tickHandler then
              self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
            end
          else
            self:StopUVScroll()
          end
        end
      end)
      for i = 1, #self.compassData do
        self.dataLayer:RegisterAndExecuteDataObserver(self, self:GetGameModeDataPath(tostring(self.compassData[i].crc) .. ".Position"), function(self, position)
          if position then
            DynamicBus.Compass.Broadcast.AddMarkerDataForDisplay(position, Color(1, 1, 1), mapTypes.iconTypes.OutpostRushMarkers, self.compassData[i].imagePath)
          end
        end)
      end
      DynamicBus.Compass.Broadcast.RemoveAllMarkersOfType(mapTypes.iconTypes.TrackedObjective)
      if self.inventoryId then
        self:BusDisconnect(self.containerEventHandler)
        self.containerEventHandler = self:BusConnect(ContainerEventBus, self.inventoryId)
      end
      self:BusDisconnect(self.gameModeEventHandler)
      self.gameModeEventHandler = self:BusConnect(GameModeComponentNotificationBus, self.gameModeEntityId)
      for i = 1, #self.markerData do
        self.dataLayer:RegisterAndExecuteDataObserver(self, self:GetGameModeDataPath(tostring(self.markerData[i].crc) .. ".Position"), function(self, position)
          if position then
            local dataPath = self.markerBasePath .. tostring(self.markerData[i].index) .. "."
            LyShineDataLayerBus.Broadcast.SetData(dataPath .. "WorldPosition", position)
            if self.markerData[i].type == self.markerType.CAPTUREPOINT then
              LyShineDataLayerBus.Broadcast.SetData(dataPath .. "Name", self.markerData[i].name)
              LyShineDataLayerBus.Broadcast.SetData(dataPath .. "Enabled", SiegeMarkerData.USAGE_OR)
              LyShineDataLayerBus.Broadcast.SetData(dataPath .. "BGColor", self.UIStyle.COLOR_GRAY_50)
            elseif self.markerData[i].type == self.markerType.GATE then
              LyShineDataLayerBus.Broadcast.SetData(dataPath .. "Icon", self.markerType.GATE)
              LyShineDataLayerBus.Broadcast.SetData(dataPath .. "ReplicatedId", self.markerData[i].dataLayerId)
              LyShineDataLayerBus.Broadcast.SetData(dataPath .. "VitalsDataPath", self:GetGameModeDataPath(tostring(self.markerData[i].dataLayerId)))
              LyShineDataLayerBus.Broadcast.SetData(dataPath .. "BGColor", self.UIStyle.COLOR_GRAY_50)
              LyShineDataLayerBus.Broadcast.SetData(dataPath .. "SetMarkerToFade", true)
            end
          end
        end)
      end
      for i = 1, #self.capturePointInfo do
        self.capturePointInfo[i].claimPointIcon:SetName(self.capturePointInfo[i].claimPointIcon.name, nil, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
        self.capturePointInfo[i].claimPointIcon:SetMeterBGColor(self.UIStyle.COLOR_GRAY_50)
        self.capturePointInfo[i].claimPointIcon:SetProgress(0)
        self.capturePointInfo[i].claimPointIcon.teamIdx = nil
        self.dataLayer:RegisterAndExecuteDataObserver(self, self:GetGameModeDataPath(self.capturePointInfo[i].statusDataLayerId), function(self, status)
          if status then
            local owningTeamIdx = BitwiseHelper:And(status, OutpostRush_CapturePointStatusMask)
            if owningTeamIdx == 0 or owningTeamIdx == 1 then
              self:UpdateCapturePointOwningTeamIdx(self.capturePointInfo[i].claimPointIcon, owningTeamIdx)
            end
            local contestingTeamIdx = BitwiseHelper:And(BitwiseHelper:RShift(status, OutpostRush_CapturePointStatusBitsPerField), OutpostRush_CapturePointStatusMask)
            self:UpdateCapturePointContestingTeamIdx(self.capturePointInfo[i], contestingTeamIdx)
            local fillValue = BitwiseHelper:And(BitwiseHelper:RShift(status, OutpostRush_CapturePointStatusBitsPerField * 2), OutpostRush_CapturePointStatusMask)
            if 0 <= fillValue and fillValue <= 100 then
              self:UpdateCapturePointFillPct(self.capturePointInfo[i].claimPointIcon, fillValue)
            end
          end
        end)
      end
    end
  end)
  UiFaderBus.Event.SetFadeValue(self.Properties.BannerFrame, 0)
  UiTransformBus.Event.SetScale(self.Properties.BannerFrame, Vector2(0, 1))
  self.ScriptedEntityTweener:Play(self.Properties.BannerFrame, 0.5, {
    delay = 0,
    scaleX = 1,
    opacity = 1,
    ease = "QuadInOut"
  })
  self.dataLayer:RegisterDataObserver(self, self:GetGameModeDataPath(self.dataLayer_winningTeamIdxId), function(self, winningTeamIdx)
    self.winningTeamIdx = winningTeamIdx
    self:ShowRewardsScreen()
  end)
  self.dataLayer:RegisterDataObserver(self, self:GetGameModeDataPath(self.dataLayer_timeLimitTimerId), function(self, timeRemaining)
    local secondsRemaining = math.max(math.ceil(timeRemaining / 1000), 0)
    local _, _, minutes, seconds = TimeHelperFunctions:ConvertSecondsToDaysHoursMinutesSeconds(secondsRemaining)
    local timerText = string.format("%d:%02d", minutes, seconds)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Timer, timerText, eUiTextSet_SetAsIs)
  end)
  self.dataLayer:RegisterDataObserver(self, self:GetGameModeDataPath(self.dataLayer_timerBoss), function(self, timeRemaining)
    if timeRemaining then
      local secondsRemaining = math.max(math.ceil(timeRemaining / 1000), 0)
      if 0 < secondsRemaining then
        local _, _, minutes, seconds = TimeHelperFunctions:ConvertSecondsToDaysHoursMinutesSeconds(secondsRemaining)
        local timerText = string.format("%d:%02d", minutes, seconds)
        UiTextBus.Event.SetTextWithFlags(self.Properties.BossTimer, timerText, eUiTextSet_SetAsIs)
        UiTextBus.Event.SetColor(self.Properties.BossTimer, self.UIStyle.COLOR_WHITE)
        UiTextBus.Event.SetTextWithFlags(self.Properties.BossName, "@ui_outpost_rush_boss_alive_in", eUiTextSet_SetLocalized)
      else
        UiTextBus.Event.SetTextWithFlags(self.Properties.BossTimer, "@ui_outpost_rush_boss_alive", eUiTextSet_SetLocalized)
        UiTextBus.Event.SetColor(self.Properties.BossTimer, self.UIStyle.COLOR_GREEN_BRIGHT)
        UiTextBus.Event.SetTextWithFlags(self.Properties.BossName, "@ui_outpost_rush_boss", eUiTextSet_SetLocalized)
      end
    end
  end)
  self.dataLayer:RegisterDataObserver(self, self:GetGameModeDataPath(self.dataLayer_timeLimitCleanup), function(self, timeRemaining)
    if not self.cleanupTimepoint then
      local secondsRemaining = math.max(math.ceil(timeRemaining / 1000), 0)
      self.cleanupTimepoint = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime():AddDuration(Duration.FromSecondsUnrounded(secondsRemaining))
      self:ShowRewardsScreen()
    end
  end)
end
function OutpostRushHud:OnSlotUpdate(localSlotId, slot, updateReason)
  if not slot then
    return
  end
  local itemDescriptor = ItemDescriptor()
  for i = 1, #self.itemsForResourceTray do
    itemDescriptor.itemId = self.itemsForResourceTray[i]
    local count = ContainerRequestBus.Event.GetItemCount(self.inventoryId, itemDescriptor, true, true, false)
    self.ResourceItems[i - 1]:UpdateCount(count)
  end
end
function OutpostRushHud:OnItemDroppedOnDeath(slot)
  self:OnSlotUpdate(nil, slot, eItemContainerSync_DroppedOnDeath)
end
function OutpostRushHud:OnExitedGameMode(gameModeEntityId)
  if gameModeEntityId ~= self.gameModeEntityId then
    return
  end
  DynamicBus.WorldMapDataBus.Broadcast.SetDefaultWorld()
  if self.outpostRushHandler then
    DynamicBus.OutpostRush.Disconnect(self.entityId, self)
    self.outpostRushHandler = nil
  end
  self.ORContextualNotifications:ExitedGameMode()
  DynamicBus.WarboardInGameBus.Broadcast.SetGameMode(0)
  DynamicBus.WarboardInGameBus.Broadcast.SetGameEntityId()
  DynamicBus.WarboardEndOfMatch.Broadcast.SetGameMode(0)
  DynamicBus.Compass.Broadcast.RemoveAllMarkersOfType(mapTypes.iconTypes.OutpostRushMarkers)
  if self.actionHandler then
    self:BusDisconnect(self.actionHandler)
    self.actionHandler = nil
  end
  if self.actionHandlerTutorial then
    self:BusDisconnect(self.actionHandlerTutorial)
    self.actionHandlerTutorial = nil
  end
  if self.localPlayerEventsBusHandler then
    self:BusDisconnect(self.localPlayerEventsBusHandler)
    self.localPlayerEventsBusHandler = nil
  end
  self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(self.dataLayer_stateId))
  self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(self.dataLayer_localPlayerTeamIdx))
  self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(self.dataLayer_winningTeamIdxId))
  self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(self.dataLayer_teamScores))
  self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(self.dataLayer_timeLimitTimerId))
  self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(self.dataLayer_timeLimitPreGame))
  self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(self.dataLayer_timeLimitCleanup))
  self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(self.dataLayer_timerBoss))
  self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(self.dataLayer_frozenTeamIdx))
  self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(self.dataLayer_scorePerOutpostClaimed))
  for i = 1, #self.capturePointInfo do
    self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(self.capturePointInfo[i].statusDataLayerId))
  end
  for i = 1, #self.markerData do
    self.dataLayer:UnregisterObserver(self, self:GetGameModeDataPath(tostring(self.markerData[i].crc) .. ".Position"))
    local dataPath = self.markerBasePath .. tostring(self.markerData[i].index) .. "."
    LyShineDataLayerBus.Broadcast.SetData(dataPath .. "Disabled", SiegeMarkerData.USAGE_OR)
    LyShineDataLayerBus.Broadcast.SetData(dataPath .. "SetMarkerToFade", false)
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  self.gameModeEntityId = nil
  self.localPlayerTeamIdx = nil
  self.cleanupTimepoint = nil
  self.winningTeamIdx = nil
  self.isLocalPlayerTeamIdx = nil
  self:BusDisconnect(self.containerEventHandler)
  self:BusDisconnect(self.categoricalProgressionHandler)
  self:BusDisconnect(self.gameModeEventHandler)
end
function OutpostRushHud:OnReceivedEventFromServer(gameModeEntityId, eventId, value)
  if gameModeEntityId ~= self.gameModeEntityId then
    return
  end
  if eventId == 1009153453 then
    self:ShowBanner("@ui_outpost_rush_boss_spawned", "", self.bannerColors.DEFAULT)
    self.audioHelper:PlaySound(self.audioHelper.Trigger_OR_BossSpawn)
    self.ORContextualNotifications:ShowTutorialNotification(ORTutorialEvent_Boss_Spawn)
  elseif eventId == 2372928083 then
    local outpost = self:GetOutpostTable(value)
    if outpost and outpost.teamIdx == self.localPlayerTeamIdx then
      self:ShowMinorNotification(GetLocalizedReplacementText("@ui_outpost_rush_outpost_under_attack", {
        value = outpost.displayName
      }))
    end
  elseif eventId == 3731096690 then
    self.audioHelper:PlaySound(self.audioHelper.Trigger_OR_BossDeath)
    if self.localPlayerTeamIdx == value then
      self:ShowBanner("@ui_outpost_rush_boss_killed", "@ui_outpost_rush_ally_buff", self.bannerColors.BLUE, "lyshineui/images/hud/outpostrush/frozenLockBanner.dds")
    else
      self:ShowBanner("@ui_outpost_rush_boss_killed", "@ui_outpost_rush_enemy_buff", self.bannerColors.BLUE, "lyshineui/images/hud/outpostrush/frozenLockBanner.dds")
    end
  elseif eventId == 2640966140 then
    local outpost = self:GetOutpostTable(value)
    if outpost and outpost.teamIdx == self.localPlayerTeamIdx then
      self:ShowMinorNotification(GetLocalizedReplacementText("@ui_outpost_rush_armory_built", {
        value = outpost.displayName
      }))
    end
  elseif eventId == 592144734 then
    local outpost = self:GetOutpostTable(value)
    if outpost and outpost.teamIdx == self.localPlayerTeamIdx then
      self:ShowMinorNotification(GetLocalizedReplacementText("@ui_outpost_rush_command_post_built", {
        value = outpost.displayName
      }))
    end
  elseif eventId == 2005021577 then
    local outpostValue = BitwiseHelper:And(value, 65535)
    local upgradeTier = BitwiseHelper:RShift(value, 16)
    local outpost = self:GetOutpostTable(outpostValue)
    if outpost and outpost.teamIdx == self.localPlayerTeamIdx then
      self:ShowMinorNotification(GetLocalizedReplacementText("@ui_outpost_rush_command_post_upgrade", {
        value = outpost.displayName,
        tier = upgradeTier
      }))
    end
  end
end
function OutpostRushHud:UpdateCapturePointOwningTeamIdx(claimPointIcon, teamIdx)
  if teamIdx == claimPointIcon.teamIdx then
    return
  end
  local color = self.UIStyle.COLOR_BLACK
  self.isLocalPlayerTeamIdx = self.localPlayerTeamIdx == teamIdx
  if self.isLocalPlayerTeamIdx then
    color = self.UIStyle.COLOR_BLUE
    self:ShowMinorNotification(GetLocalizedReplacementText("@ui_outpost_rush_outpost_captured", {
      value = claimPointIcon.displayName
    }))
  else
    color = self.UIStyle.COLOR_RED
    self:ShowMinorNotification(GetLocalizedReplacementText("@ui_outpost_rush_outpost_lost", {
      value = claimPointIcon.displayName
    }))
  end
  self:SetGateColor(claimPointIcon.name, color)
  claimPointIcon:SetMeterBGColor(color)
  claimPointIcon:SetName(claimPointIcon.name, self.isLocalPlayerTeamIdx, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
  claimPointIcon.teamIdx = teamIdx
  local dataPath = self.markerBasePath .. tostring(self:GetClaimPointMarkerIndex(claimPointIcon)) .. ".BGColor"
  LyShineDataLayerBus.Broadcast.SetData(dataPath, color)
end
function OutpostRushHud:UpdateCapturePointContestingTeamIdx(capturePointInfo, teamIdx)
  local claimPointIcon = capturePointInfo.claimPointIcon
  local isNewContestingTeamIdxValid = teamIdx == 0 or teamIdx == 1
  if isNewContestingTeamIdxValid then
    local color = self.localPlayerTeamIdx == teamIdx and self.UIStyle.COLOR_BLUE or self.UIStyle.COLOR_RED
    claimPointIcon:SetMeterColor(color)
    local dataPath = self.markerBasePath .. tostring(self:GetClaimPointMarkerIndex(claimPointIcon)) .. ".Color"
    LyShineDataLayerBus.Broadcast.SetData(dataPath, color)
    local contestingTeamIdxChanged = teamIdx ~= capturePointInfo.contestingTeamIdx
    if contestingTeamIdxChanged and isNewContestingTeamIdxValid and not self.inPreGameState then
      self:ShowMinorNotification(GetLocalizedReplacementText("@ui_outpost_rush_outpost_contested", {
        value = claimPointIcon.displayName
      }))
    end
  end
  capturePointInfo.contestingTeamIdx = teamIdx
end
function OutpostRushHud:UpdateCapturePointFillPct(claimPointIcon, fillValue)
  local pct = fillValue / 100
  claimPointIcon:SetProgress(pct)
  local dataPath = self.markerBasePath .. tostring(self:GetClaimPointMarkerIndex(claimPointIcon)) .. ".Progress"
  LyShineDataLayerBus.Broadcast.SetData(dataPath, pct)
end
function OutpostRushHud:UpdateTeamScore(teamIdx, score)
  local isLocalPlayerTeam = self.localPlayerTeamIdx == teamIdx
  local textToUpdateEntityId, barToUpdateEntityId, glintToUpdateEntityId, holderToUpdateEntityId, playAnim, animPosX
  if isLocalPlayerTeam then
    playAnim = self.ownTeamScore and self.ownTeamScore ~= score
    self.ownTeamScore = score
    textToUpdateEntityId = self.Properties.TeamScore_Friendly
    barToUpdateEntityId = self.Properties.TeamScore_FriendlyBar
    glintToUpdateEntityId = self.Properties.TeamScore_FriendlyBarGlint
    holderToUpdateEntityId = self.Properties.TeamScore_FriendlyBarGlintHolder
    animPosX = self.teamScoreBarWidth + self.teamScoreGlintWidth
  else
    playAnim = self.enemyTeamScore and self.enemyTeamScore ~= score
    self.enemyTeamScore = score
    textToUpdateEntityId = self.Properties.TeamScore_Enemy
    barToUpdateEntityId = self.Properties.TeamScore_EnemyBar
    glintToUpdateEntityId = self.Properties.TeamScore_EnemyBarGlint
    holderToUpdateEntityId = self.Properties.TeamScore_EnemyBarGlintHolder
    animPosX = -(self.teamScoreBarWidth + self.teamScoreGlintWidth)
  end
  UiTextBus.Event.SetTextWithFlags(textToUpdateEntityId, tostring(score), eUiTextSet_SetAsIs)
  if not self.isMusicEnding and self.ownTeamScore ~= nil and self.enemyTeamScore ~= nil and (self.ownTeamScore >= 950 or self.enemyTeamScore >= 950) then
    self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_OutpostRush, self.audioHelper.MusicState_OR_Conclusion_Start)
    self.isMusicEnding = true
  elseif self.isMusicEnding and self.ownTeamScore ~= nil and self.enemyTeamScore ~= nil and self.ownTeamScore < 950 and self.enemyTeamScore < 950 then
    self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_OutpostRush, self.audioHelper.MusicState_OR_Conclusion_Stop)
    self.isMusicEnding = false
  end
  local scorePercent = score / self.scoreToWin
  local fillWidth = self.teamScoreBarWidth * scorePercent
  UiProgressBarBus.Event.SetProgressPercent(barToUpdateEntityId, scorePercent)
  UiTransform2dBus.Event.SetLocalWidth(holderToUpdateEntityId, fillWidth)
  if playAnim then
    self.ScriptedEntityTweener:Play(glintToUpdateEntityId, 1, {x = 0, opacity = 1}, {
      x = animPosX,
      opacity = 0,
      ease = "QuadIn"
    })
  end
end
function OutpostRushHud:ShowBanner(titleText, descriptionText, color, icon)
  local bannerData = {
    WarCard1 = {
      warTitleText = titleText,
      warDetailText = descriptionText,
      isInvasion = false,
      isSiegeState = true,
      offsetY = 100,
      noIcons = icon == nil and true or false,
      bannerColor = color,
      customIcon = icon
    }
  }
  local bannerDisplayTime = 5
  local priority = 3
  DynamicBus.Banner.Broadcast.EnqueueBanner(layouts.LAYOUT_WAR_CARD, bannerData, bannerDisplayTime, nil, nil, false, priority, layouts.WAR_BANNER_DRAW_ORDER)
end
function OutpostRushHud:ShowMinorNotification(text)
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = text
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function OutpostRushHud:UpdateFrozenAnimations(frozenTeamIdx)
  local animationEntityId1, animationEntityId2, frozenTextEntityId, scoreBarEntityId
  local frozenTeam = frozenTeamIdx == self.INVALID_TEAM_ID and self.frozenTeamIdx or frozenTeamIdx
  if frozenTeam == self.localPlayerTeamIdx then
    animationEntityId1 = self.Properties.TeamScore_FriendlyFrozenEffect1
    animationEntityId2 = self.Properties.TeamScore_FriendlyFrozenEffect2
    frozenTextEntityId = self.Properties.TeamScore_FriendlyFrozenLockedText
    scoreBarEntityId = self.Properties.TeamScore_FriendlyBar
  else
    animationEntityId1 = self.Properties.TeamScore_EnemyFrozenEffect1
    animationEntityId2 = self.Properties.TeamScore_EnemyFrozenEffect2
    frozenTextEntityId = self.Properties.TeamScore_EnemyFrozenLockedText
    scoreBarEntityId = self.Properties.TeamScore_EnemyBar
  end
  if self.frozenTeamIdx == self.INVALID_TEAM_ID and frozenTeamIdx ~= self.INVALID_TEAM_ID then
    self.ScriptedEntityTweener:Set(animationEntityId1, {opacity = 1})
    self.ScriptedEntityTweener:Set(animationEntityId2, {opacity = 1})
    UiFlipbookAnimationBus.Event.SetCurrentFrame(animationEntityId1, 0)
    UiFlipbookAnimationBus.Event.SetCurrentFrame(animationEntityId2, 0)
    UiFlipbookAnimationBus.Event.Start(animationEntityId1)
    UiFlipbookAnimationBus.Event.Start(animationEntityId2)
    self.ScriptedEntityTweener:PlayFromC(frozenTextEntityId, 0.3, {scaleX = 1.75, scaleY = 1.75}, tweenerCommon.scaleTo1)
    self.ScriptedEntityTweener:PlayFromC(frozenTextEntityId, 0.3, {opacity = 0}, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:PlayC(scoreBarEntityId, 0.3, tweenerCommon.opacityTo50, 0.5)
    self.audioHelper:PlaySound(self.audioHelper.FrozenScoreActivated)
  else
    self.ScriptedEntityTweener:PlayC(scoreBarEntityId, 0.3, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:PlayC(animationEntityId1, 0.3, tweenerCommon.fadeOutQuadOut)
    self.ScriptedEntityTweener:PlayC(animationEntityId2, 0.3, tweenerCommon.fadeOutQuadOut)
    self.ScriptedEntityTweener:PlayC(frozenTextEntityId, 0.3, tweenerCommon.fadeOutQuadOut, 0.31, function()
      UiFlipbookAnimationBus.Event.Stop(animationEntityId1)
      UiFlipbookAnimationBus.Event.Stop(animationEntityId2)
    end)
    self.audioHelper:PlaySound(self.audioHelper.FrozenScoreDeactivated)
  end
  self.frozenTeamIdx = frozenTeamIdx
end
function OutpostRushHud:GetOutpostTable(index)
  local outpost
  if index == self.outposts.A then
    outpost = self.ClaimPointIconA
  elseif index == self.outposts.B then
    outpost = self.ClaimPointIconB
  elseif index == self.outposts.C then
    outpost = self.ClaimPointIconC
  end
  return outpost
end
function OutpostRushHud:ShowPreGame(show)
  UiElementBus.Event.SetIsEnabled(self.Properties.PreGameContainer, show)
  self.inPreGameState = show
  if show then
    if not self.actionHandlerTutorial then
      self.actionHandlerTutorial = self:BusConnect(CryActionNotificationsBus, "openWarTutorial")
    end
  elseif self.actionHandlerTutorial then
    self:BusDisconnect(self.actionHandlerTutorial)
    self.actionHandlerTutorial = nil
  end
end
function OutpostRushHud:ShowGameHud(show)
  UiElementBus.Event.SetIsEnabled(self.Properties.BannerFrame, show)
  UiElementBus.Event.SetIsEnabled(self.Properties.ScoreToWinText, show)
  UiElementBus.Event.SetIsEnabled(self.Properties.ClaimPointHolder, show)
  UiElementBus.Event.SetIsEnabled(self.Properties.ResourceTray, show)
end
function OutpostRushHud:GetClaimPointMarkerIndex(claimIcon)
  local markerIndex = 1
  for i = 1, #self.markerData do
    if claimIcon.name == self.markerData[i].name and self.markerData[i].type == self.markerType.CAPTUREPOINT then
      markerIndex = i
      break
    end
  end
  return markerIndex
end
function OutpostRushHud:SetGateColor(outpostName, color)
  for i = 1, #self.markerData do
    if self.markerData[i].name == outpostName and self.markerData[i].type == self.markerType.GATE then
      local dataPath = self.markerBasePath .. tostring(self.markerData[i].index) .. ".Color"
      LyShineDataLayerBus.Broadcast.SetData(dataPath, color)
    end
  end
end
function OutpostRushHud:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  if self.screenStatesToDisable[toState] then
    UiCanvasBus.Event.SetEnabled(self.canvasId, false)
  elseif toState == 3766762380 then
    self.ScriptedEntityTweener:Play(self.entityId, 0.5, {y = 70, ease = "QuadInOut"})
  end
end
function OutpostRushHud:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  if self.screenStatesToDisable[fromState] then
    UiCanvasBus.Event.SetEnabled(self.canvasId, true)
  elseif fromState == 3766762380 then
    self.ScriptedEntityTweener:Play(self.entityId, 0.5, {y = 0, ease = "QuadInOut"})
  end
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function OutpostRushHud:OnCryAction(actionName)
  if actionName == "toggleWarboardInGame" then
    if not self.isInScoreboard then
      LyShineManagerBus.Broadcast.ToggleState(3160088100)
    else
      LyShineManagerBus.Broadcast.ExitState(3160088100)
    end
    self.isInScoreboard = not self.isInScoreboard
  end
  if actionName == "openWarTutorial" then
    DynamicBus.WarTutorialPopup.Broadcast.ShowWarTutorialPopup(GameModeCommon.GAMEMODE_OUTPOST_RUSH)
  end
end
function OutpostRushHud:ShowRewardsScreen()
  if not self.cleanupTimepoint or not self.winningTeamIdx then
    return
  end
  self:ShowGameHud(false)
  local playerTeam = GameModeComponentRequestBus.Event.GetParticipantTeamIdx(self.gameModeEntityId, self.localPlayerEntityId)
  local playerWin = playerTeam == self.winningTeamIdx
  local isDraw = self.winningTeamIdx == self.DRAW_TEAM_ID
  if playerWin then
    self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_OutpostRush, self.audioHelper.MusicState_OR_Victory)
  else
    self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_OutpostRush, self.audioHelper.MusicState_OR_Defeat)
  end
  self.audioHelper:onUIStateChanged(self.audioHelper.UIState_Scoreboard)
  local data = {
    playerTeamIndex = playerTeam,
    ownTeamScore = self.ownTeamScore,
    enemyTeamScore = self.enemyTeamScore,
    winningTeamIdx = self.winningTeamIdx,
    cleanupTimepoint = self.cleanupTimepoint,
    playerWin = playerWin,
    isDraw = isDraw
  }
  DynamicBus.RespawnScreen.Broadcast.OnOutpostRushMatchEnded()
  DynamicBus.RewardScreen.Broadcast.OnOutpostRushMatchEnded(data)
  DynamicBus.WarboardEndOfMatch.Broadcast.OnOutpostRushMatchEnded(self.gameModeEntityId, data)
end
function OutpostRushHud:UpdateMap()
  if self.mapIsReady and self.gameModeEntityId then
    DynamicBus.WorldMapDataBus.Broadcast.SetWorldMapDataById("OutpostRush")
  end
end
function OutpostRushHud:OnStructureStatusChanged(outpost, status)
  if not status then
    return
  end
  for i = 1, #self.markerData do
    if outpost == self.markerData[i].name and self.markerData[i].enum then
      local shiftBits = self.markerData[i].enum * OutpostRush_StructureStatusShiftPerStructures
      local tier = BitwiseHelper:And(BitwiseHelper:RShift(status, shiftBits), OutpostRush_StructureStatusMaskTier)
      local ruin = BitwiseHelper:And(BitwiseHelper:RShift(status, shiftBits), OutpostRush_StructureStatusMaskRuin)
      local enabled = false
      if 0 < tier and ruin == 0 then
        enabled = true
      end
      local dataPath = self.markerBasePath .. tostring(self.markerData[i].index) .. ".Enabled"
      if enabled == false then
        dataPath = self.markerBasePath .. tostring(self.markerData[i].index) .. ".Disabled"
      end
      LyShineDataLayerBus.Broadcast.SetData(dataPath, SiegeMarkerData.USAGE_OR)
    end
  end
end
function OutpostRushHud:RegisterPurchase()
  self.ORContextualNotifications:CheckSpendEssence(true)
end
function OutpostRushHud:OnTick(deltaTime, timePoint)
  if not (self.teamWithSlaughter ~= self.INVALID_TEAM_ID and self.slaughterEffectEntity) or not self.UVsToScroll then
    self:StopUVScroll()
    return
  end
  UiImageBus.Event.SetUVOverrides(self.slaughterEffectEntity, self.UVsToScroll[1], self.UVsToScroll[2], self.UVsToScroll[3], self.UVsToScroll[4])
  local increase = self.currentSpeed * deltaTime
  self.UVsToScroll[1] = self.UVsToScroll[1] + increase
  self.UVsToScroll[3] = self.UVsToScroll[3] + increase
  if 1 < self.UVsToScroll[1] and 1 < self.UVsToScroll[3] then
    self.UVsToScroll[1] = self.UVsToScroll[1] - 1
    self.UVsToScroll[3] = self.UVsToScroll[3] - 1
  end
end
function OutpostRushHud:StopUVScroll()
  self.teamWithSlaughter = self.INVALID_TEAM_ID
  self.UVsToScroll = nil
  if self.slaughterEffectEntity then
    UiElementBus.Event.SetIsEnabled(self.slaughterEffectEntity, false)
  end
  self.slaughterEffectEntity = nil
  if self.tickHandler then
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
end
return OutpostRushHud
