local WarHUD = {
  Properties = {
    WarHUDWidget = {
      default = EntityId()
    },
    Summary = {
      Holder = {
        default = EntityId(),
        order = 1
      },
      ObjectiveText = {
        default = EntityId(),
        order = 2
      },
      ObjectiveFlash = {
        default = EntityId(),
        order = 3
      },
      Timer = {
        default = EntityId(),
        order = 4
      },
      HowDoesWarWork = {
        default = EntityId(),
        order = 5
      },
      HowDoesWarWorkText = {
        default = EntityId(),
        order = 6
      },
      HowDoesWarWorkHint = {
        default = EntityId(),
        order = 7
      }
    },
    KeepHolder = {
      Holder = {
        default = EntityId(),
        order = 1
      }
    },
    ClaimPoints = {
      Holder = {
        default = EntityId(),
        order = 1
      },
      ClaimA = {
        default = EntityId(),
        order = 2
      },
      ClaimB = {
        default = EntityId(),
        order = 3
      },
      ClaimC = {
        default = EntityId(),
        order = 4
      },
      Keep = {
        default = EntityId(),
        order = 5
      },
      IsContesting = {
        default = EntityId(),
        order = 6
      },
      IsContestingText = {
        default = EntityId(),
        order = 7
      }
    },
    GatePoints = {
      Holder = {
        default = EntityId(),
        order = 1
      },
      GateA = {
        default = EntityId(),
        order = 2
      },
      GateB = {
        default = EntityId(),
        order = 3
      },
      GateC = {
        default = EntityId(),
        order = 4
      },
      GateD = {
        default = EntityId(),
        order = 5
      },
      GateE = {
        default = EntityId(),
        order = 6
      }
    },
    BattleTokens = {
      Holder = {
        default = EntityId(),
        order = 1
      },
      Title = {
        default = EntityId(),
        order = 2
      },
      Count = {
        default = EntityId(),
        order = 3
      },
      TickerItems = {
        default = {
          EntityId()
        },
        order = 4
      }
    },
    SiegeWeapons = {
      Holder = {
        default = EntityId(),
        order = 1
      },
      Title = {
        default = EntityId(),
        order = 2
      },
      Count = {
        default = EntityId(),
        order = 3
      }
    },
    Deployables = {
      Holder = {
        default = EntityId(),
        order = 1
      },
      Title = {
        default = EntityId(),
        order = 2
      },
      Count = {
        default = EntityId(),
        order = 3
      }
    },
    SiegeParts = {
      Holder = {
        default = EntityId(),
        order = 1
      },
      Title = {
        default = EntityId(),
        order = 2
      },
      InventoryTitle = {
        default = EntityId(),
        order = 3
      },
      InventoryCount = {
        default = EntityId(),
        order = 4
      }
    }
  },
  cachedTau = 2 * math.pi,
  cachedHalfPi = math.pi / 2,
  lastPlayerPosition = Vector3(0, 0, 0),
  lastCompassHeading = 0,
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
  gameEventsToShow = {
    [2024619528] = "@battletoken_minorkill",
    [3121659451] = "@battletoken_majorkill",
    [1322187932] = "@battletoken_specialkill",
    [3608691745] = "@battletoken_minorassist",
    [363185170] = "@battletoken_majorassist",
    [3126351072] = "@battletoken_specialassist",
    [2595444179] = "@battletoken_healally",
    [3100244289] = "@battletoken_repair",
    [2492793653] = "@battletoken_reload",
    [1778575544] = "@battletoken_tokengeneration",
    [142815582] = "@battletoken_initialaward"
  },
  BattleTokenGuildCRC = 1175253129,
  lootTickerIndex = 1,
  QUEUE_TIMER = 0.8,
  tickerQueue = {},
  battleTokenAmount = 0,
  warEndTime = nil,
  warTimeRemainingSeconds = 0,
  raidId = RaidId(),
  groupsNotificationBusHandler = nil,
  offenseSiegePosY = 175,
  defenseSiegePosY = 125,
  summaryOffsetGateHudPosY = 40,
  summaryOffsetTimerOnlyPosY = -25,
  brokenGates = {},
  playIntroMusic = false,
  playInvasionMusic = false,
  INVASION_MUSIC_TIME_REMAINING = 300,
  SIEGE_MUSIC_TIME_REMAINING = 300,
  NUM_CLAIM_POINTS = 3,
  CLAIM_POINT_RADIUS = 68.0625
}
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local TimeHelperFunctions = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local SiegeMarkerData = RequireScript("LyShineUI.Markers.SiegeMarkerData")
local GameModeCommon = RequireScript("LyShineUI._Common.GameModeCommon")
local BitwiseHelper = RequireScript("LyShineUI._Common.BitwiseHelpers")
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local Layouts = RequireScript("LyShineUI.Banner.Layouts")
BaseScreen:CreateNewScreen(WarHUD)
function WarHUD:OnInit()
  BaseScreen.OnInit(self)
  self.propsToHide = {
    self.Properties.ClaimPoints.Holder,
    self.Properties.GatePoints.Holder,
    self.Properties.KeepHolder.Holder
  }
  self.propsToFadeIn = {
    self.Properties.ClaimPoints.Holder,
    self.Properties.GatePoints.Holder,
    self.Properties.KeepHolder.Holder,
    self.Properties.Summary.Holder
  }
  self:BusConnect(GameEventUiNotificationBus)
  self:BusConnect(UiCanvasSizeNotificationBus, self.canvasId)
  DynamicBus.WarHUD.Connect(self.entityId, self)
  local keybinding = LyShineManagerBus.Broadcast.GetKeybind("openWarTutorial", "ui")
  self.Summary.HowDoesWarWorkHint:SetText(keybinding)
  self.siegePartDescriptor = ItemDescriptor()
  self.siegePartDescriptor.itemId = 1463456128
  self.siegeIcons = {}
  self.siegeIcons[eFortSpawnId_CapturePoint_A] = self.ClaimPoints.ClaimA
  self.siegeIcons[eFortSpawnId_CapturePoint_B] = self.ClaimPoints.ClaimB
  self.siegeIcons[eFortSpawnId_CapturePoint_C] = self.ClaimPoints.ClaimC
  self.siegeIcons[eFortSpawnId_CapturePoint_Claim] = self.ClaimPoints.Keep
  self.siegeIcons[eFortSpawnId_Gate_A] = self.GatePoints.GateA
  self.siegeIcons[eFortSpawnId_Gate_B] = self.GatePoints.GateB
  self.siegeIcons[eFortSpawnId_Gate_C] = self.GatePoints.GateC
  self.siegeIcons[eFortSpawnId_Gate_D] = self.GatePoints.GateD
  self.siegeIcons[eFortSpawnId_Gate_E] = self.GatePoints.GateE
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.InventoryEntityId", function(self, inventoryId)
    self.inventoryId = inventoryId
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Social.DataSynced", function(self, synced)
    if synced then
      self.resolutionDuration = Duration.FromHoursUnrounded(-WarRequestBus.Broadcast.GetWarPhaseDuration(eWarPhase_Resolution):ToHoursUnrounded())
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.IsWarDataServiceAvailable", function(self, isWarDataServiceAvailable)
    self.isWarDataServiceAvailable = isWarDataServiceAvailable
    if isWarDataServiceAvailable and self.raidId and self.raidId:IsValid() then
      self:UpdateRaidId()
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Raid.Id", function(self, raidId)
    if raidId and raidId:IsValid() then
      self.raidId = raidId
      if self.isWarDataServiceAvailable then
        self:UpdateRaidId()
      end
    else
      self:CleanupWarHUD()
      self:BusDisconnect(self.groupsNotificationBusHandler)
      self.groupsNotificationBusHandler = nil
      self:ShowTutorialHint(false)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Guild.LastModifiedGuildWarId", function(self, warId)
    if warId and self.raidId then
      local warDetails = WarDataClientRequestBus.Broadcast.GetWarDetails(warId)
      if warDetails and warDetails:IsRaidInWar(self.raidId) then
        self:UpdateRaidId()
      end
    end
  end)
  self:OnCanvasSizeOrScaleChange(self.canvasId)
  self:SetVisualElements()
  UiElementBus.Event.SetIsEnabled(self.Properties.ClaimPoints.IsContesting, false)
end
function WarHUD:UpdateRaidId()
  local warDetails = WarDataServiceBus.Broadcast.GetWarForRaid(self.raidId)
  if warDetails == nil or not warDetails:IsValid() then
    return
  end
  if self.groupsNotificationBusHandler then
    self:BusDisconnect(self.groupsNotificationBusHandler)
    self.groupsNotificationBusHandler = nil
  end
  self.groupsNotificationBusHandler = self:BusConnect(GroupsUINotificationBus)
  if not self.tickBusHandler then
    self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
  end
  self.queueTimer = nil
  local currentPhase = warDetails:GetWarPhase()
  local isInvasion = warDetails:IsInvasion()
  if isInvasion then
    UiTextBus.Event.SetTextWithFlags(self.Properties.Summary.HowDoesWarWorkText, "@ui_how_does_invasion_work", eUiTextSet_SetLocalized)
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.Summary.HowDoesWarWorkText, "@ui_how_does_war_work", eUiTextSet_SetLocalized)
  end
  self.showContestingText = false
  if currentPhase == eWarPhase_PreWar then
    self.warEndTime = warDetails:GetConquestStartTime()
    self:SetTimerText()
    self.playIntroMusic = true
    self.playInvasionMusic = warDetails:IsInvasion()
    self.isInvasion = warDetails:IsInvasion()
    self:SetOnlyTimerVisible()
    UiTextBus.Event.SetTextWithFlags(self.Properties.Summary.ObjectiveText, "@ui_siege_phase_preparation", eUiTextSet_SetLocalized)
    self:ShowTutorialHint(true)
    self:HideElementsForWarStart()
  elseif currentPhase == eWarPhase_Conquest then
    self:OnSiegeWarfareStarted(warDetails:GetWarId())
    self.showContestingText = true
    self:HideElementsWhileBannerDisplayed(self.isInvasion and Layouts.INVASION_BANNER_DISPLAY_DURATION or Layouts.WAR_BANNER_DISPLAY_DURATION)
  elseif currentPhase == eWarPhase_Resolution then
    self:OnSiegeWarfareEnded(warDetails:GetWarId())
  else
    self:ShowTutorialHint(false)
  end
end
function WarHUD:ShowTutorialHint(showHint)
  if showHint then
    UiElementBus.Event.SetIsEnabled(self.Properties.Summary.HowDoesWarWork, true)
    if not self.actionHandler then
      self.actionHandler = self:BusConnect(CryActionNotificationsBus, "openWarTutorial")
    end
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.Summary.HowDoesWarWork, false)
    if self.actionHandler then
      self:BusDisconnect(self.actionHandler)
      self.actionHandler = nil
    end
  end
end
function WarHUD:OnShutdown()
  DynamicBus.WarHUD.Disconnect(self.entityId, self)
end
function WarHUD:SetVisualElements()
  local hudPrimaryTitleStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_BOLD,
    fontSize = 18,
    fontColor = self.UIStyle.COLOR_WHITE
  }
  local hudSecondaryTitleStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_MEDIUM,
    fontSize = 18,
    fontColor = self.UIStyle.COLOR_GRAY_90
  }
  local hudCountStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_BOLD,
    fontSize = 24,
    fontColor = self.UIStyle.COLOR_GRAY_80
  }
  local objectiveTextStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_MEDIUM,
    fontSize = 22,
    fontColor = self.UIStyle.COLOR_WHITE
  }
  local objectiveTimerStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_BOLD,
    fontSize = 28,
    fontColor = self.UIStyle.COLOR_WHITE
  }
  SetTextStyle(self.Properties.BattleTokens.Title, hudPrimaryTitleStyle)
  SetTextStyle(self.Properties.BattleTokens.Count, hudCountStyle)
  SetTextStyle(self.Properties.SiegeWeapons.Title, hudPrimaryTitleStyle)
  SetTextStyle(self.Properties.SiegeWeapons.Count, hudCountStyle)
  SetTextStyle(self.Properties.Deployables.Title, hudPrimaryTitleStyle)
  SetTextStyle(self.Properties.Deployables.Count, hudCountStyle)
  SetTextStyle(self.Properties.SiegeParts.Title, hudPrimaryTitleStyle)
  SetTextStyle(self.Properties.SiegeParts.InventoryTitle, hudSecondaryTitleStyle)
  SetTextStyle(self.Properties.SiegeParts.InventoryCount, hudCountStyle)
  SetTextStyle(self.Properties.Summary.ObjectiveText, objectiveTextStyle)
  SetTextStyle(self.Properties.Summary.Timer, objectiveTimerStyle)
  UiTextBus.Event.SetTextWithFlags(self.Properties.BattleTokens.Title, "@ui_siege_hud_battle_tokens", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.SiegeWeapons.Title, "@ui_siege_hud_siege_weapons", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Deployables.Title, "@ui_siege_hud_deployables", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.SiegeParts.Title, "@ui_siege_hud_siege_parts", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.SiegeParts.InventoryTitle, "@ui_siege_hud_inventory", eUiTextSet_SetLocalized)
end
function WarHUD:HideElementsForWarStart()
  for i, prop in ipairs(self.propsToHide) do
    self.ScriptedEntityTweener:Set(prop, {opacity = 0})
  end
end
function WarHUD:HideElementsWhileBannerDisplayed(durationToHide)
  for i, prop in ipairs(self.propsToFadeIn) do
    if UiElementBus.Event.IsEnabled(prop) then
      self.ScriptedEntityTweener:Set(prop, {opacity = 0})
      TimingUtils:Delay(durationToHide, self, function()
        self.ScriptedEntityTweener:PlayC(prop, 0.5, tweenerCommon.fadeInQuadOut)
      end)
    end
  end
end
function WarHUD:GetClaimStartingColor()
  return self.claimStartingColor
end
function WarHUD:GetClaimTargetColor()
  return self.claimTargetColor
end
function WarHUD:OnSiegeWarfareStarted(warId)
  self.playIntroMusic = false
  if warId == nil or warId == self.warId then
    return
  end
  self.warId = warId
  local warDetails = WarDataClientRequestBus.Broadcast.GetWarDetails(warId)
  self:SetupWarHUD(warDetails)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.WarCacheUpdate", function(self, updated)
    if self.warId then
      local warDetails = WarDataClientRequestBus.Broadcast.GetWarDetails(self.warId)
      local currentPhase = warDetails:GetWarPhase()
      if currentPhase == eWarPhase_PreWar then
        self.warEndTime = warDetails:GetConquestStartTime()
      elseif currentPhase == eWarPhase_Conquest then
        self.warEndTime = warDetails:GetWarEndTime():AddDuration(self.resolutionDuration)
      else
        self.warEndTime = warDetails:GetWarEndTime()
      end
      self:SetTimerText()
      self.warId = nil
    end
  end)
  self.audioHelper:PlaySound(self.audioHelper.Banner_WarDeclared)
  if self.playInvasionMusic then
    self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Invasion, self.audioHelper.MusicState_InvasionStarted)
  else
    self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Siege, self.audioHelper.MusicState_SiegeStarted)
  end
  self:ShowTutorialHint(false)
end
function WarHUD:OnSiegeWarfareEnded(isWinner, resolutionPhaseEndTimePoint)
  self.playIntroMusic = false
  self:SetOnlyTimerVisible()
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.WarCacheUpdate")
  self.warId = nil
  if self.siegeWarfareBus then
    self:BusDisconnect(self.siegeWarfareBus)
    self.siegeWarfareBus = nil
  end
  if self.containerEventHandler then
    self:BusDisconnect(self.containerEventHandler)
    self.containerEventHandler = nil
  end
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Siege.SiegePhase", false)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Summary.ObjectiveText, "@ui_warnotification_resolution_phase_warning", eUiTextSet_SetLocalized)
  self.warEndTime = resolutionPhaseEndTimePoint
  self:SetTimerText()
  self.audioHelper:PlaySound(self.audioHelper.Banner_WarEnded)
  if self.playInvasionMusic then
    self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Invasion, self.audioHelper.MusicState_InvasionEnded)
  else
    self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Siege, self.audioHelper.MusicState_SiegeEnded)
  end
  self:ShowTutorialHint(false)
end
function WarHUD:OnSiegeWarfareCompleted(reason)
  self:CleanupWarHUD()
end
function WarHUD:SetOnlyTimerVisible()
  UiTransformBus.Event.SetLocalPositionY(self.Properties.Summary.Holder, self.summaryOffsetTimerOnlyPosY)
  UiElementBus.Event.SetIsEnabled(self.Properties.ClaimPoints.Holder, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.GatePoints.Holder, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.KeepHolder.Holder, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.BattleTokens.Holder, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.SiegeWeapons.Holder, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.Deployables.Holder, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.SiegeParts.Holder, false)
end
function WarHUD:IsPointsCaptured()
  return self.lockedPoints >= self.NUM_CLAIM_POINTS
end
function WarHUD:SetupWarHUD(warDetails)
  local attackingRaidId = warDetails:GetAttackerRaidId()
  self.isAttacking = self.raidId == attackingRaidId
  local limitData = PlayerDataManagerBus.Broadcast.GetWarDeployableLimitData(3278957618)
  self.maxSiegeWeapons = limitData:GetLimit(self.isAttacking, warDetails:GetWarCampTier())
  local deployableLimitData = PlayerDataManagerBus.Broadcast.GetWarDeployableLimitData(1478985693)
  self.maxDeployables = deployableLimitData:GetLimit(self.isAttacking, warDetails:GetWarCampTier())
  self.isInvasion = warDetails:IsInvasion()
  self.warEndTime = warDetails:GetWarEndTime():AddDuration(self.resolutionDuration)
  self:SetTimerText()
  self:SetObjectiveFlash()
  UiTransformBus.Event.SetLocalPositionY(self.Properties.Summary.Holder, 0)
  if self.isInvasion then
    UiTransformBus.Event.SetLocalPositionY(self.Properties.Summary.Holder, self.summaryOffsetGateHudPosY)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Summary.ObjectiveText, "@ui_siege_phase_destroy_gates_defender", eUiTextSet_SetLocalized)
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.Summary.ObjectiveText, self.isAttacking and "@ui_siege_phase_capture_points_attacker" or "@ui_siege_phase_capture_points_defender", eUiTextSet_SetLocalized)
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.Summary.Timer, "", eUiTextSet_SetAsIs)
  UiElementBus.Event.SetIsEnabled(self.Properties.ClaimPoints.Holder, not self.isInvasion)
  UiElementBus.Event.SetIsEnabled(self.Properties.GatePoints.Holder, self.isInvasion)
  UiElementBus.Event.SetIsEnabled(self.Properties.KeepHolder.Holder, self.isInvasion)
  self.claimStartingColor = self.isAttacking and self.UIStyle.COLOR_CONQUEST_RED or self.UIStyle.COLOR_CONQUEST_BLUE
  self.claimTargetColor = self.isAttacking and self.UIStyle.COLOR_CONQUEST_BLUE or self.UIStyle.COLOR_CONQUEST_RED
  for i = eFortSpawnId_CapturePoint_A, eFortSpawnId_CapturePoint_Claim do
    self.siegeIcons[i]:SetMeterColor(self.claimTargetColor)
    self.siegeIcons[i]:SetMeterBGColor(self.claimStartingColor)
  end
  for i = eFortSpawnId_Gate_A, eFortSpawnId_Gate_E do
    self.siegeIcons[i]:SetMeterColor(self.UIStyle.COLOR_BLACK, self.claimTargetColor)
    self.siegeIcons[i]:SetMeterBGColor(self.claimStartingColor)
  end
  if self.isInvasion then
    self.siegeIcons[eFortSpawnId_CapturePoint_Claim]:SetMeterColor(self.UIStyle.COLOR_BLACK)
    self.siegeIcons[eFortSpawnId_CapturePoint_Claim]:SetMeterBGColor(self.claimStartingColor)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.SiegeWeapons.Holder, self.isAttacking)
  UiElementBus.Event.SetIsEnabled(self.Properties.Deployables.Holder, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.SiegeParts.Holder, true)
  local siegeOffsetPosY = self.isAttacking and self.offenseSiegePosY or self.defenseSiegePosY
  UiTransformBus.Event.SetLocalPositionY(self.Properties.SiegeParts.Holder, siegeOffsetPosY)
  self.containerEventHandler = self:BusConnect(ContainerEventBus, self.inventoryId)
  if self.isAttacking then
    UiTextBus.Event.SetTextWithFlags(self.Properties.SiegeWeapons.Count, "0/" .. tostring(self.maxSiegeWeapons), eUiTextSet_SetAsIs)
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.Deployables.Count, "0/" .. tostring(self.maxDeployables), eUiTextSet_SetAsIs)
  local siegeSupply = ContainerRequestBus.Event.GetItemCount(self.inventoryId, self.siegePartDescriptor, false, true, false)
  UiTextBus.Event.SetTextWithFlags(self.Properties.SiegeParts.InventoryCount, GetLocalizedNumber(siegeSupply), eUiTextSet_SetAsIs)
  self.battleTokenAmount = 0
  UiTextBus.Event.SetTextWithFlags(self.Properties.BattleTokens.Count, 0, eUiTextSet_SetAsIs)
  UiElementBus.Event.SetIsEnabled(self.Properties.BattleTokens.Holder, true)
  self.categoricalProgressionHandler = self:BusConnect(CategoricalProgressionNotificationBus, self.playerEntityId)
  if not self.tickBusHandler then
    self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
  end
  self.queueTimer = 0
  UiElementBus.Event.SetIsEnabled(self.Properties.WarHUDWidget, true)
  self.siegeStructures = {}
  self.capturePointCount = 0
  self.lockedPoints = 0
  if self.siegeWarfareBus then
    SiegeWarfareDataComponentRequestBus.Broadcast.RequestExistingStateNotifications()
  else
    self.siegeWarfareBus = self:BusConnect(SiegeWarfareDataComponentNotificationBus)
  end
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Siege.SiegePhase", true)
  UiElementBus.Event.SetIsEnabled(self.Properties.ClaimPoints.IsContesting, false)
  if not self.isInvasion then
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Position", function(self, position)
      self.localPlayerPosition = position
      if not self.localPlayerPosition or not self.warId then
        return
      end
      local isContesting = false
      local isPointLocked = false
      for index, markerData in pairs(self.siegeStructures) do
        if markerData.fortSpawnId <= eFortSpawnId_CapturePoint_Claim then
          local worldPos = markerData.position
          if self.localPlayerPosition:GetDistanceSq(worldPos) < self.CLAIM_POINT_RADIUS then
            isContesting = true
            isPointLocked = BitwiseHelper:And(markerData.state, eCapturePointStateFlag_Locked) > 0
            break
          end
        end
      end
      UiElementBus.Event.SetIsEnabled(self.Properties.ClaimPoints.IsContesting, isContesting and self.showContestingText)
      if isContesting then
        local isContestingText = isPointLocked and "@ui_point_taken" or "@ui_contesting"
        UiTextBus.Event.SetTextWithFlags(self.Properties.ClaimPoints.IsContestingText, isContestingText, eUiTextSet_SetLocalized)
      end
    end)
  end
end
function WarHUD:CleanupWarHUD(warDetails)
  if self.playInvasionMusic then
    self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Invasion, self.audioHelper.MusicState_InvasionNone)
  else
    self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Siege, self.audioHelper.MusicState_SiegeNone)
  end
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.WarCacheUpdate")
  self.warId = nil
  UiElementBus.Event.SetIsEnabled(self.Properties.WarHUDWidget, false)
  if self.tickBusHandler then
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
  end
  if self.containerEventHandler then
    self:BusDisconnect(self.containerEventHandler)
    self.containerEventHandler = nil
  end
  if self.siegeWarfareBus then
    self:BusDisconnect(self.siegeWarfareBus)
    self.siegeWarfareBus = nil
  end
  self.raidId:Reset()
  if self.groupsNotificationBusHandler then
    self:BusDisconnect(self.groupsNotificationBusHandler)
    self.groupsNotificationBusHandler = nil
  end
  if self.categoricalProgressionHandler then
    self:BusDisconnect(self.categoricalProgressionHandler)
    self.categoricalProgressionHandler = nil
  end
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Siege.SiegePhase", false)
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Position")
  UiElementBus.Event.SetIsEnabled(self.Properties.ClaimPoints.IsContesting, false)
end
function WarHUD:OnCapturePointStateChange(entityId, capturePointState)
  if not self.siegeIcons[capturePointState.fortSpawnId] then
    return
  end
  local wasPointsCaptured = self:IsPointsCaptured()
  local index = capturePointState.fortSpawnId
  if not self.siegeStructures[index] then
    local markerData = {
      position = Vector3(0, 0, 0),
      state = 0,
      fillPct = -1,
      hudMarker = self.siegeIcons[capturePointState.fortSpawnId],
      index = self.capturePointCount + 1,
      fortSpawnId = capturePointState.fortSpawnId
    }
    local initDataPath = "Hud.LocalPlayer.Siege.ClaimPoints." .. tostring(markerData.index) .. "."
    markerData.hudMarker:Reset()
    LyShineDataLayerBus.Broadcast.SetData(initDataPath .. "Reset", true)
    if SiegeMarkerData.siegeData[capturePointState.fortSpawnId].text ~= nil then
      markerData.name = SiegeMarkerData.siegeData[capturePointState.fortSpawnId].text
      markerData.hudMarker:SetName(markerData.name)
      LyShineDataLayerBus.Broadcast.SetData(initDataPath .. "Name", markerData.name)
    elseif SiegeMarkerData.siegeData[capturePointState.fortSpawnId].icon ~= nil then
      markerData.icon = SiegeMarkerData.siegeData[capturePointState.fortSpawnId].icon
      markerData.hudMarker:SetIcon(markerData.icon)
      LyShineDataLayerBus.Broadcast.SetData(initDataPath .. "Icon", markerData.icon)
    end
    self.siegeStructures[index] = markerData
    self.capturePointCount = CountAssociativeTable(self.siegeStructures)
    self.siegeStructures[index].position = capturePointState.worldPos
    LyShineDataLayerBus.Broadcast.SetData(initDataPath .. "WorldPosition", self.siegeStructures[index].position)
    LyShineDataLayerBus.Broadcast.SetData(initDataPath .. "Type", self.siegeStructures[index].fortSpawnId)
    LyShineDataLayerBus.Broadcast.SetData(initDataPath .. "Enabled", SiegeMarkerData.USAGE_SIEGE)
  end
  local dataPath = "Hud.LocalPlayer.Siege.ClaimPoints." .. tostring(self.siegeStructures[index].index) .. "."
  if self.siegeStructures[index].state ~= capturePointState.stateFlags then
    if BitwiseHelper:And(self.siegeStructures[index].state, eCapturePointStateFlag_Locked) == 0 and 0 < BitwiseHelper:And(capturePointState.stateFlags, eCapturePointStateFlag_Locked) then
      self.lockedPoints = self.lockedPoints + 1
      if self.isAttacking then
        self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Siege, self.audioHelper.MusicState_Siege_Capture_Point)
        self.audioHelper:PlaySound(self.audioHelper.War_PointTaken_Attackers)
      else
        self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Siege, self.audioHelper.MusicState_Siege_Lose_Point)
        self.audioHelper:PlaySound(self.audioHelper.War_PointTaken_Defenders)
      end
    end
    self.siegeStructures[index].state = capturePointState.stateFlags
    self.siegeStructures[index].hudMarker:SetState(self.siegeStructures[index].state)
    LyShineDataLayerBus.Broadcast.SetData(dataPath .. "State", self.siegeStructures[index].state)
  end
  if self.siegeStructures[index].fillPct ~= capturePointState.fillPct then
    self.siegeStructures[index].fillPct = capturePointState.fillPct
    self.siegeStructures[index].hudMarker:SetProgress(self.siegeStructures[index].fillPct)
    LyShineDataLayerBus.Broadcast.SetData(dataPath .. "Progress", self.siegeStructures[index].fillPct)
  end
  local isPointsCaptured = self:IsPointsCaptured()
  if wasPointsCaptured ~= isPointsCaptured then
    self:SetObjectiveFlash()
    UiTransformBus.Event.SetLocalPositionY(self.Properties.Summary.Holder, self.summaryOffsetGateHudPosY)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Summary.ObjectiveText, self.isAttacking and "@ui_siege_phase_destroy_gates_attacker" or "@ui_siege_phase_destroy_gates_defender", eUiTextSet_SetLocalized)
    UiElementBus.Event.SetIsEnabled(self.Properties.ClaimPoints.Holder, not isPointsCaptured)
    UiElementBus.Event.SetIsEnabled(self.Properties.GatePoints.Holder, isPointsCaptured)
    UiElementBus.Event.SetIsEnabled(self.Properties.KeepHolder.Holder, true)
    self.ScriptedEntityTweener:Set(self.Properties.GatePoints.Holder, {opacity = 1})
    self.ScriptedEntityTweener:Set(self.Properties.KeepHolder.Holder, {opacity = 1})
    for key, value in pairs(self.siegeStructures) do
      local isEnabled = value.fortSpawnId >= eFortSpawnId_CapturePoint_Claim
      if isEnabled then
        LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Siege.ClaimPoints." .. tostring(value.index) .. ".Enabled", SiegeMarkerData.USAGE_SIEGE)
      else
        LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Siege.ClaimPoints." .. tostring(value.index) .. ".Disabled", SiegeMarkerData.USAGE_SIEGE)
      end
    end
  end
end
function WarHUD:OnFortMajorStructureStateChange(entityId, fortMajorStructureState)
  if not self.siegeIcons[fortMajorStructureState.fortSpawnId] then
    return
  end
  local index = fortMajorStructureState.fortSpawnId
  if not self.siegeStructures[index] then
    local markerData = {
      position = Vector3(0, 0, 0),
      state = -1,
      fillPct = -1,
      hudMarker = self.siegeIcons[fortMajorStructureState.fortSpawnId],
      index = self.capturePointCount + 1,
      fortSpawnId = fortMajorStructureState.fortSpawnId
    }
    local initDataPath = "Hud.LocalPlayer.Siege.ClaimPoints." .. tostring(markerData.index) .. "."
    markerData.hudMarker:Reset()
    LyShineDataLayerBus.Broadcast.SetData(initDataPath .. "Reset", true)
    if SiegeMarkerData.siegeData[fortMajorStructureState.fortSpawnId].text ~= nil then
      markerData.name = SiegeMarkerData.siegeData[fortMajorStructureState.fortSpawnId].text
      markerData.hudMarker:SetName(markerData.name)
      LyShineDataLayerBus.Broadcast.SetData(initDataPath .. "Name", markerData.name)
    elseif SiegeMarkerData.siegeData[fortMajorStructureState.fortSpawnId].icon ~= nil then
      markerData.icon = SiegeMarkerData.siegeData[fortMajorStructureState.fortSpawnId].icon
      markerData.hudMarker:SetIcon(markerData.icon)
      LyShineDataLayerBus.Broadcast.SetData(initDataPath .. "Icon", markerData.icon)
    end
    self.siegeStructures[index] = markerData
    self.capturePointCount = CountAssociativeTable(self.siegeStructures)
    self.siegeStructures[index].position = fortMajorStructureState.worldPos
    LyShineDataLayerBus.Broadcast.SetData(initDataPath .. "WorldPosition", self.siegeStructures[index].position)
    LyShineDataLayerBus.Broadcast.SetData(initDataPath .. "Type", self.siegeStructures[index].fortSpawnId)
    local enable = self.isInvasion or self:IsPointsCaptured()
    if enable then
      LyShineDataLayerBus.Broadcast.SetData(initDataPath .. "Enabled", SiegeMarkerData.USAGE_SIEGE)
    else
      LyShineDataLayerBus.Broadcast.SetData(initDataPath .. "Disabled", SiegeMarkerData.USAGE_SIEGE)
    end
  end
  local dataPath = "Hud.LocalPlayer.Siege.ClaimPoints." .. tostring(self.siegeStructures[index].index) .. "."
  local buildableState = fortMajorStructureState:GetBuildableState()
  local healthPct = fortMajorStructureState:GetHealthPct()
  if buildableState == eBuildableState_Ruin then
    healthPct = 0
  end
  if self.siegeStructures[index].fillPct ~= healthPct then
    self.siegeStructures[index].fillPct = healthPct
    self.siegeStructures[index].hudMarker:SetProgress(1 - self.siegeStructures[index].fillPct)
    LyShineDataLayerBus.Broadcast.SetData(dataPath .. "Progress", 1 - self.siegeStructures[index].fillPct)
    if self.isInvasion or self:IsPointsCaptured() then
      local updateObjective = false
      if 0 >= self.siegeStructures[index].fillPct then
        table.insert(self.brokenGates, index)
        updateObjective = true
      elseif self.siegeStructures[index].fillPct >= 1 then
        updateObjective = true
        for i = 1, #self.brokenGates do
          if self.brokenGates[i] == index then
            table.remove(self.brokenGates, i)
            break
          end
        end
      end
      if updateObjective then
        if 0 < #self.brokenGates then
          if self.isAttacking then
            self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Siege, self.audioHelper.MusicState_Siege_Capture_Point)
            self.audioHelper:PlaySound(self.audioHelper.War_GateBreached_Attackers)
          else
            self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Siege, self.audioHelper.MusicState_Siege_Lose_Point)
            self.audioHelper:PlaySound(self.audioHelper.War_GateBreached_Defenders)
          end
          UiTextBus.Event.SetTextWithFlags(self.Properties.Summary.ObjectiveText, self.isAttacking and "@ui_siege_phase_capture_fort_attacker" or "@ui_siege_phase_capture_fort_defender", eUiTextSet_SetLocalized)
        else
          UiTextBus.Event.SetTextWithFlags(self.Properties.Summary.ObjectiveText, self.isAttacking and "@ui_siege_phase_destroy_gates_attacker" or "@ui_siege_phase_destroy_gates_defender", eUiTextSet_SetLocalized)
        end
      end
    end
  end
end
function WarHUD:OnBuildableCountsChanged()
  if self.isAttacking then
    local curCount = SiegeWarfareDataComponentRequestBus.Broadcast.GetNumBuildablesBoundByTeamLimit(self.isAttacking, 3278957618)
    UiTextBus.Event.SetTextWithFlags(self.Properties.SiegeWeapons.Count, tostring(curCount) .. "/" .. tostring(self.maxSiegeWeapons), eUiTextSet_SetAsIs)
  end
  local deployableCount = SiegeWarfareDataComponentRequestBus.Broadcast.GetNumBuildablesBoundByTeamLimit(self.isAttacking, 1478985693)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Deployables.Count, tostring(deployableCount) .. "/" .. tostring(self.maxDeployables), eUiTextSet_SetAsIs)
end
function WarHUD:OnCategoricalProgressionPointsChanged(guildCRC, oldPoints, newPoints)
  if guildCRC == self.BattleTokenGuildCRC and newPoints < oldPoints then
    self:SetBattleTokensToCurrent()
  end
end
function WarHUD:SetObjectiveFlash()
  UiElementBus.Event.SetIsEnabled(self.Properties.Summary.ObjectiveFlash, true)
  self.ScriptedEntityTweener:Set(self.Properties.Summary.ObjectiveFlash, {
    imgFill = 0,
    imgColor = self.UIStyle.COLOR_YELLOW_GOLD,
    opacity = 0.7,
    scaleY = 1
  })
  self.ScriptedEntityTweener:Play(self.Properties.Summary.ObjectiveFlash, 1, {
    scaleY = 0.3,
    ease = "Linear",
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.Properties.Summary.ObjectiveFlash, false)
    end
  })
  self.ScriptedEntityTweener:PlayC(self.Properties.Summary.ObjectiveFlash, 0.3, tweenerCommon.imgFillTo1)
  self.ScriptedEntityTweener:PlayC(self.Properties.Summary.ObjectiveFlash, 0.15, tweenerCommon.objectiveFlash1)
  self.ScriptedEntityTweener:PlayC(self.Properties.Summary.ObjectiveFlash, 0.2, tweenerCommon.objectiveFlash2, 0.2)
  self.ScriptedEntityTweener:PlayC(self.Properties.Summary.ObjectiveFlash, 0.2, tweenerCommon.objectiveFlash3, 0.4)
end
function WarHUD:AddBattleTokens(amount)
  self.battleTokenAmount = self.battleTokenAmount + amount
  UiTextBus.Event.SetTextWithFlags(self.Properties.BattleTokens.Count, GetLocalizedNumber(self.battleTokenAmount), eUiTextSet_SetAsIs)
end
function WarHUD:SetBattleTokensToCurrent()
  self.battleTokenAmount = CategoricalProgressionRequestBus.Event.GetProgression(self.playerEntityId, self.BattleTokenGuildCRC)
  UiTextBus.Event.SetTextWithFlags(self.Properties.BattleTokens.Count, GetLocalizedNumber(self.battleTokenAmount), eUiTextSet_SetAsIs)
end
function WarHUD:SetTimerText()
  if not self.warEndTime then
    return
  end
  local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
  local warTimeRemaining = self.warEndTime:SubtractSeconds(now):ToSeconds()
  if self.warTimeRemainingSeconds ~= warTimeRemaining then
    if self.playIntroMusic then
      if self.playInvasionMusic and warTimeRemaining < self.INVASION_MUSIC_TIME_REMAINING then
        self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Invasion, self.audioHelper.MusicState_InvasionTimer)
        self.playIntroMusic = false
      elseif not self.playInvasionMusic and warTimeRemaining < self.SIEGE_MUSIC_TIME_REMAINING then
        self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Siege, self.audioHelper.MusicState_SiegeTimer)
        self.playIntroMusic = false
      end
    end
    self.warTimeRemainingSeconds = warTimeRemaining
    local _, _, minutes, seconds = TimeHelperFunctions:ConvertSecondsToDaysHoursMinutesSeconds(warTimeRemaining)
    local timeText = string.format("%d:%02d", minutes, seconds)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Summary.Timer, timeText, eUiTextSet_SetAsIs)
  end
end
function WarHUD:OnTick(deltaTime, timePoint)
  if self.queueTimer and self.queueTimer >= 0 then
    self.queueTimer = self.queueTimer - deltaTime
    if self.queueTimer < 0 and 0 < #self.tickerQueue then
      self.queueTimer = self.QUEUE_TIMER
      do
        local reward = table.remove(self.tickerQueue, 1)
        UiTextBus.Event.SetTextWithFlags(self.Properties.BattleTokens.TickerItems[self.lootTickerIndex], reward.text, eUiTextSet_SetAsIs)
        self.ScriptedEntityTweener:PlayFromC(self.Properties.BattleTokens.TickerItems[self.lootTickerIndex], 0.1, {opacity = 0}, tweenerCommon.tokenFadeIn)
        self.ScriptedEntityTweener:PlayFromC(self.Properties.BattleTokens.TickerItems[self.lootTickerIndex], 0.1, {opacity = 1}, tweenerCommon.tokenFadeOut, 2)
        self.ScriptedEntityTweener:PlayFromC(self.Properties.BattleTokens.TickerItems[self.lootTickerIndex], 2.1, {x = 0, y = 60}, tweenerCommon.tokenMoveIn)
        self.ScriptedEntityTweener:Play(self.Properties.BattleTokens.TickerItems[self.lootTickerIndex], 0.1, {x = 0}, {
          delay = 2,
          x = 100,
          ease = "QuadIn",
          onComplete = function()
            if #self.tickerQueue > 0 then
              self:AddBattleTokens(reward.amount)
            else
              self:SetBattleTokensToCurrent()
            end
          end
        })
        self.lootTickerIndex = self.lootTickerIndex + 1
        if self.lootTickerIndex > #self.Properties.BattleTokens.TickerItems then
          self.lootTickerIndex = 1
        end
      end
    end
  end
  if self.warEndTime then
    self:SetTimerText()
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.WarHUDWidget, true)
end
function WarHUD:OnUiGameEvent(gameEventId, modifier)
  if self.gameEventsToShow[gameEventId] then
    local gameEventData = GameEventRequestBus.Broadcast.GetGameSystemData(gameEventId)
    if gameEventData.isValid then
      local amount = math.floor(gameEventData.categoricalProgressionReward * modifier)
      local rewardString = GetLocalizedReplacementText(self.gameEventsToShow[gameEventId], {
        tokenCount = tostring(amount)
      })
      self.queueTimer = 0
      table.insert(self.tickerQueue, {text = rewardString, amount = amount})
    end
  end
end
function WarHUD:OnContainerChanged()
  local siegeSupply = ContainerRequestBus.Event.GetItemCount(self.inventoryId, self.siegePartDescriptor, false, true, false)
  UiTextBus.Event.SetTextWithFlags(self.Properties.SiegeParts.InventoryCount, GetLocalizedNumber(siegeSupply), eUiTextSet_SetAsIs)
end
function WarHUD:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  if self.screenStatesToDisable[toState] then
    UiCanvasBus.Event.SetEnabled(self.canvasId, false)
  end
end
function WarHUD:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  if self.screenStatesToDisable[fromState] then
    UiCanvasBus.Event.SetEnabled(self.canvasId, true)
  end
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function WarHUD:OnCanvasSizeOrScaleChange(canvasId)
  if self.canvasId == canvasId then
    AdjustElementToCanvasSize(self.entityId, self.canvasId)
  end
end
function WarHUD:OnCryAction(actionName, value)
  if actionName == "openWarTutorial" then
    self:OnShowWarTutorial()
  end
end
function WarHUD:OnShowWarTutorial()
  local gameMode = self.isInvasion and GameModeCommon.GAMEMODE_INVASION or GameModeCommon.GAMEMODE_WAR
  DynamicBus.WarTutorialPopup.Broadcast.ShowWarTutorialPopup(gameMode)
end
return WarHUD
