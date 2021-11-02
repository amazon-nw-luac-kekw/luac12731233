local Raid = {
  Properties = {
    ScreenHeader = {
      default = EntityId()
    },
    RaidPanel = {
      default = EntityId()
    },
    DOFTweenDummyElement = {
      default = EntityId()
    },
    EmblemBackground = {
      default = EntityId()
    },
    EmblemForeground = {
      default = EntityId()
    },
    GuildName = {
      default = EntityId()
    },
    SideText = {
      default = EntityId()
    },
    SideIcon = {
      default = EntityId()
    },
    WarDateText = {
      default = EntityId()
    },
    WarTimeText = {
      default = EntityId()
    },
    WarTimeLabel = {
      default = EntityId()
    },
    InvitationTimeText = {
      default = EntityId()
    },
    LocationText = {
      default = EntityId()
    },
    TimeUntilSiegeText = {
      default = EntityId()
    },
    InvasionFooter = {
      default = EntityId()
    },
    InvasionEmblem = {
      default = EntityId()
    },
    NumPlayerSelectionsRemainingText = {
      default = EntityId()
    },
    AutoSelectCountdownText = {
      default = EntityId()
    },
    BannerMask = {
      default = EntityId()
    },
    BannerImage = {
      default = EntityId()
    },
    CrestGlow = {
      default = EntityId()
    },
    FactionName = {
      default = EntityId()
    },
    StatusText = {
      default = EntityId()
    },
    StatusDescription = {
      default = EntityId()
    },
    StatusBg = {
      default = EntityId()
    },
    LeaveRaidButton = {
      default = EntityId()
    },
    HowDoesWarWorkText = {
      default = EntityId()
    }
  },
  NUM_GROUPS = 10,
  NUM_PLAYERS_IN_GROUP = 5,
  panelEnabled = false,
  timer = 0,
  second = 1,
  tickHandler = nil,
  territoryId = 0,
  remainingSelections = 0,
  totalSelections = 0
}
local BaseScreen = RequireScript("LyShineUI/_Common/BaseScreen")
BaseScreen:CreateNewScreen(Raid)
local socialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local dominionCommon = RequireScript("LyShineUI._Common.DominionCommon")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local GameModeCommon = RequireScript("LyShineUI._Common.GameModeCommon")
function Raid:OnInit()
  BaseScreen.OnInit(self)
  self.minutesBeforeSiegeToSendInvites = ConfigProviderEventBus.Broadcast.GetInt("javelin.social.minutes-before-siege-to-send-invites")
  self.totalSelections = ConfigProviderEventBus.Broadcast.GetInt("javelin.social.invasion-num-signup-selections-allowed")
  if not self.cryActionHandler then
    self.cryActionHandler = self:BusConnect(CryActionNotificationsBus, "toggleRaidWindow")
  end
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  self.ScreenHeader:SetText("@ui_raid_war_header")
  self.ScreenHeader:SetHintCallback(self.OnExit, self)
  self.raidSetupBusHandler = self:BusConnect(RaidSetupNotificationBus)
  self.raidDynamicBusHandler = DynamicBus.Raid.Connect(self.entityId, self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Raid.Id", function(self, raidId)
    if raidId and raidId:IsValid() then
      self.raidId = raidId
      if raidId and raidId:IsValid() then
        local warDetails = WarDataServiceBus.Broadcast.GetWarForRaid(raidId)
        local inWarRaid = warDetails and warDetails:IsValid()
        if inWarRaid then
          self:OnExit()
        end
      end
    else
      self.raidId = nil
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.CharacterId", function(self, characterId)
    self.characterId = characterId
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, data)
    if data then
      self:BusConnect(PlayerComponentNotificationsBus, data)
    end
  end)
end
function Raid:OnShutdown()
  if self.raidDynamicBusHandler then
    DynamicBus.Raid.Disconnect(self.entityId, self)
    self.raidDynamicBusHandler = nil
  end
  BaseScreen.OnShutdown(self)
end
function Raid:OnCryAction(actionName, value)
  if actionName == "toggleRaidWindow" then
    local localPlayerRaidId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Raid.Id")
    if localPlayerRaidId and localPlayerRaidId:IsValid() then
      local warDetails = WarDataServiceBus.Broadcast.GetWarForRaid(localPlayerRaidId)
      if warDetails:IsValid() then
        local side = eRaidSide_None
        if localPlayerRaidId == warDetails:GetAttackerRaidId() then
          side = eRaidSide_Attacker
        elseif localPlayerRaidId == warDetails:GetDefenderRaidId() then
          side = eRaidSide_Defender
        end
        LyShineManagerBus.Broadcast.ToggleState(1468490675)
        RaidSetupRequestBus.Broadcast.RequestRemoteInteract(warDetails:GetTerritoryId())
        DynamicBus.Raid.Broadcast.SetIsRemoteInteract(true)
        DynamicBus.Raid.Broadcast.SetData(warDetails:GetTerritoryId(), side, true)
      end
    end
  end
end
function Raid:UpdateStatusText()
  local signupStatus = RaidSetupRequestBus.Broadcast.GetSignupStatus(self.territoryId)
  local statusText = "@ui_signup_not_signed_up"
  local statusTextColor = self.UIStyle.COLOR_GRAY_90
  local statusBgColor = self.UIStyle.COLOR_GRAY_50
  local allowRemoteSignup = ConfigProviderEventBus.Broadcast.GetBool("javelin.social.enable-war-signup-from-map")
  local statusDescription = not (not allowRemoteSignup and self.isRemoteInteract) and "@ui_raid_not_signedup_description" or "@ui_raid_not_signedup_remote_description"
  local leaveButtonText = "@ui_raid_leave_standby_button"
  local playerLevel = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Progression.Level")
  local minLevel = ConfigProviderEventBus.Broadcast.GetInt("javelin.social.invasion-min-level") + 1
  if self.RaidPanel.isInvasion and playerLevel < minLevel then
    local signupLevelReqText = GetLocalizedReplacementText("@ui_signup_level_requirement", {level = minLevel})
    statusDescription = signupLevelReqText
  elseif signupStatus then
    if signupStatus.selected then
      statusText = "@ui_signup_selected"
      statusDescription = self.warDateTimeTextForSelected
      statusTextColor = self.UIStyle.COLOR_GREEN_BRIGHT
      statusBgColor = self.UIStyle.COLOR_GREEN_MEDIUM
      leaveButtonText = "@ui_raid_leave_button"
    elseif signupStatus.side ~= eRaidSide_None then
      statusText = "@ui_signup_standby"
      statusDescription = "@ui_raid_standby_description"
      statusTextColor = self.UIStyle.COLOR_YELLOW_GOLD
      statusBgColor = self.UIStyle.COLOR_YELLOW_DARK
    end
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.StatusText, statusText, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.StatusDescription, statusDescription, eUiTextSet_SetLocalized)
  UiImageBus.Event.SetColor(self.Properties.StatusBg, statusBgColor)
  UiTextBus.Event.SetColor(self.Properties.StatusText, statusTextColor)
  self.LeaveRaidButton:SetText(leaveButtonText)
end
function Raid:OnSignupResponseReceived(success, failureReason)
  self.RaidPanel:OnSignupResponseReceived(success, failureReason)
  if success then
    UiTextBus.Event.SetTextWithFlags(self.Properties.StatusText, "@ui_signup_standby", eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.StatusDescription, "@ui_raid_standby_description", eUiTextSet_SetLocalized)
    UiImageBus.Event.SetColor(self.Properties.StatusBg, self.UIStyle.COLOR_YELLOW_DARK)
    UiTextBus.Event.SetColor(self.Properties.StatusText, self.UIStyle.COLOR_YELLOW_GOLD)
    self.LeaveRaidButton:SetText("@ui_raid_leave_standby_button")
  end
end
function Raid:OnRosterChanged(roster)
  self.RaidPanel:OnRosterChanged(roster)
  self.remainingSelections = self.totalSelections - roster:NumManuallySelectedMembers()
  self:UpdateStatusText()
  self:SetSelectionsRemaining()
end
function Raid:OnSetRosterResponseReceived(success, failureReason)
  self.RaidPanel:OnSetRosterResponseReceived(success, failureReason)
end
function Raid:OnSignupListReceived(pageNum, totalPages, list)
  self.RaidPanel:OnSignupListReceived(pageNum, totalPages, list)
end
function Raid:OnLeaveResponseReceived(territoryId, success, failureReason)
  self.RaidPanel:OnLeaveResponseReceived(territoryId, success, failureReason)
  if self.territoryId == territoryId and success then
    UiTextBus.Event.SetTextWithFlags(self.Properties.StatusText, "@ui_signup_not_signed_up", eUiTextSet_SetLocalized)
    local allowRemoteSignup = ConfigProviderEventBus.Broadcast.GetBool("javelin.social.enable-war-signup-from-map")
    local statusDescription = not (not allowRemoteSignup and self.isRemoteInteract) and "@ui_raid_not_signedup_description" or "@ui_raid_not_signedup_remote_description"
    UiTextBus.Event.SetTextWithFlags(self.Properties.StatusDescription, statusDescription, eUiTextSet_SetLocalized)
    UiImageBus.Event.SetColor(self.Properties.StatusBg, self.UIStyle.COLOR_GRAY_50)
    UiTextBus.Event.SetColor(self.Properties.StatusText, self.UIStyle.COLOR_GRAY_90)
    self:OnExit()
  end
end
function Raid:OnSetBackfillEnabledResponseReceived(success, backfillEnabled, failureReason)
  self.RaidPanel:OnSetBackfillEnabledResponseReceived(success, backfillEnabled, failureReason)
end
function Raid:OnSignupStatusChanged(territoryId, signupStatus)
  self:UpdateStatusText()
  self.RaidPanel:OnSignupStatusChanged(territoryId, signupStatus)
end
function Raid:SetData(territoryId, side, isShowingRoster)
  self.side = side
  self.territoryId = territoryId
  if side == eRaidSide_None then
    return
  end
  local warDetails = WarDataServiceBus.Broadcast.GetWarForTerritory(territoryId)
  if warDetails:IsValid() == false or warDetails:IsWarActive() == false then
    return
  end
  self.isInvasion = warDetails:IsInvasion()
  local guildId
  local defendingGuildId = warDetails:GetDefenderGuildId()
  if self.isInvasion then
    UiTextBus.Event.SetTextWithFlags(self.Properties.SideText, "@ui_invasion_at", eUiTextSet_SetLocalized)
    UiElementBus.Event.SetIsEnabled(self.Properties.InvasionFooter, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.SideIcon, false)
    guildId = warDetails:GetDefenderGuildId()
  elseif side == eRaidSide_Attacker then
    UiTextBus.Event.SetTextWithFlags(self.Properties.SideText, "@ui_signup_attacker", eUiTextSet_SetLocalized)
    UiElementBus.Event.SetIsEnabled(self.Properties.InvasionFooter, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.SideIcon, true)
    UiImageBus.Event.SetSpritePathname(self.Properties.SideIcon, "lyshineui/images/icons/raid/icon_attacker.dds")
    guildId = warDetails:GetAttackerGuildId()
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.SideText, "@ui_signup_defender", eUiTextSet_SetLocalized)
    UiElementBus.Event.SetIsEnabled(self.Properties.InvasionFooter, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.SideIcon, true)
    UiImageBus.Event.SetSpritePathname(self.Properties.SideIcon, "lyshineui/images/icons/raid/icon_defender.dds")
    guildId = warDetails:GetDefenderGuildId()
  end
  socialDataHandler:GetGuildDetailedData_ServerCall(self, function(self, result)
    local guildData
    if 0 < #result then
      guildData = type(result[1]) == "table" and result[1].guildData or result[1]
    else
      Log("ERR - Raid:SetData: GuildData request returned with no data")
      return
    end
    if guildData and guildData:IsValid() then
      UiTextBus.Event.SetText(self.Properties.GuildName, guildData.guildName)
      local factionData = guildData.faction
      local factionBgColor = self.UIStyle["COLOR_FACTION_BG_" .. tostring(factionData)]
      local factionName = FactionCommon.factionInfoTable[factionData].factionName
      if self.isInvasion then
        UiElementBus.Event.SetIsEnabled(self.Properties.InvasionEmblem, true)
        UiElementBus.Event.SetIsEnabled(self.Properties.EmblemBackground, false)
        UiImageBus.Event.SetColor(self.Properties.BannerImage, self.UIStyle.COLOR_RED_DARK)
        UiImageBus.Event.SetColor(self.Properties.CrestGlow, self.UIStyle.COLOR_RED)
        UiTextBus.Event.SetColor(self.Properties.FactionName, self.UIStyle.COLOR_WHITE)
        territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(self.territoryId)
        UiTextBus.Event.SetTextWithFlags(self.Properties.FactionName, territoryName, eUiTextSet_SetLocalized)
        UiTextBus.Event.SetTextWithFlags(self.Properties.WarTimeLabel, "@ui_siege_signup_invasiontime", eUiTextSet_SetLocalized)
      else
        UiImageBus.Event.SetColor(self.Properties.EmblemBackground, guildData.crestData.backgroundColor)
        UiImageBus.Event.SetColor(self.Properties.EmblemForeground, guildData.crestData.foregroundColor)
        UiImageBus.Event.SetSpritePathname(self.Properties.EmblemBackground, guildData.crestData.backgroundImagePath)
        UiImageBus.Event.SetSpritePathname(self.Properties.EmblemForeground, guildData.crestData.foregroundImagePath)
        UiElementBus.Event.SetIsEnabled(self.Properties.EmblemBackground, true)
        UiElementBus.Event.SetIsEnabled(self.Properties.InvasionEmblem, false)
        UiImageBus.Event.SetColor(self.Properties.BannerImage, factionBgColor)
        UiImageBus.Event.SetColor(self.Properties.CrestGlow, factionBgColor)
        UiTextBus.Event.SetColor(self.Properties.FactionName, factionBgColor)
        UiTextBus.Event.SetTextWithFlags(self.Properties.FactionName, factionName, eUiTextSet_SetLocalized)
        UiTextBus.Event.SetTextWithFlags(self.Properties.WarTimeLabel, "@ui_wartime", eUiTextSet_SetLocalized)
      end
      if not self.raidId then
        self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
      end
    end
  end, nil, guildId)
  socialDataHandler:GetGuildDetailedData_ServerCall(self, function(self, result)
    local guildData
    if 0 < #result then
      guildData = type(result[1]) == "table" and result[1].guildData or result[1]
    else
      Log("ERR - Raid:SetData: GuildData request returned with no data")
      return
    end
    local warDetails = WarDataServiceBus.Broadcast.GetWarForTerritory(territoryId)
    if guildData and guildData:IsValid() then
      siegeWindow = guildData.siegeWindow
      siegeStartTime = warDetails:GetConquestStartTime():Subtract(WallClockTimePoint()):ToSecondsRoundedUp()
      local inviteTime = siegeStartTime - self.minutesBeforeSiegeToSendInvites * timeHelpers.secondsInMinute
      local duration = WarRequestBus.Broadcast.GetWarPhaseDuration(eWarPhase_Conquest):ToHours()
      local warDateText = timeHelpers:GetLocalizedAbbrevDate(siegeStartTime)
      UiTextBus.Event.SetTextWithFlags(self.Properties.WarDateText, warDateText, eUiTextSet_SetAsIs)
      local warTimeText = dominionCommon:GetSiegeWindowText(siegeWindow, true, false)
      UiTextBus.Event.SetTextWithFlags(self.Properties.WarTimeText, warTimeText, eUiTextSet_SetAsIs)
      self.warDateTimeTextForSelected = GetLocalizedReplacementText("@ui_raid_selected_description", {
        time = timeHelpers:GetLocalizedServerTime(inviteTime),
        date = warDateText
      })
      local invitationText = GetLocalizedReplacementText("@ui_invitation_time", {
        time = timeHelpers:GetLocalizedServerTime(inviteTime)
      })
      UiTextBus.Event.SetTextWithFlags(self.Properties.InvitationTimeText, invitationText, eUiTextSet_SetAsIs)
      local locationText = GetLocalizedReplacementText("@ui_siege_signup_fortressname", {
        territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(self.territoryId)
      })
      UiTextBus.Event.SetTextWithFlags(self.Properties.LocationText, locationText, eUiTextSet_SetAsIs)
      self.conquestStartTime = warDetails:GetConquestStartTime()
      self:SetTimeUntilSiege()
    end
  end, nil, defendingGuildId)
  local roster = RaidSetupRequestBus.Broadcast.GetRoster()
  self:OnRosterChanged(roster)
  RaidSetupRequestBus.Broadcast.RequestRoster()
  RaidSetupRequestBus.Broadcast.RequestSignupList(1)
  if self.isInvasion then
    UiTextBus.Event.SetTextWithFlags(self.Properties.HowDoesWarWorkText, "@ui_how_does_invasion_work", eUiTextSet_SetLocalized)
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.HowDoesWarWorkText, "@ui_how_does_war_work", eUiTextSet_SetLocalized)
  end
end
function Raid:SetIsRemoteInteract(isRemoteInteract)
  self.isRemoteInteract = isRemoteInteract
end
function Raid:IsRemoteInteract()
  return self.isRemoteInteract
end
function Raid:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  self.RaidPanel:SetEnabled(true)
  JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(false)
  JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_Raid", 0.5)
  self.ScriptedEntityTweener:Play(self.entityId, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  self.targetDOFDistance = 0
  self.targetDOFBlur = 0.95
  self.ScriptedEntityTweener:StartAnimation({
    id = self.DOFTweenDummyElement,
    easeMethod = ScriptedEntityTweenerEasingMethod_Cubic,
    duration = 1.2,
    opacity = 1,
    onUpdate = function(currentValue, currentProgressPercent)
      self:UpdateDepthOfField(currentValue)
    end
  })
  UiMaskBus.Event.SetIsMaskingEnabled(self.Properties.BannerMask, true)
  UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.BannerMask, 0)
  UiFlipbookAnimationBus.Event.Start(self.Properties.BannerMask)
end
function Raid:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  local interactorEntityNode = self.dataLayer:GetDataNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
  if interactorEntityNode then
    local interactorEntity = interactorEntityNode:GetData()
    UiInteractorComponentRequestsBus.Event.RequestCancelCommittedInteraction(interactorEntity)
  end
  DynamicBus.Raid.Broadcast.SetIsRemoteInteract(false)
  self.ScriptedEntityTweener:Stop(self.Properties.BannerImage)
  UiMaskBus.Event.SetIsMaskingEnabled(self.Properties.BannerMask, false)
  UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.BannerMask, 0)
  UiFlipbookAnimationBus.Event.Stop(self.Properties.BannerMask)
  self.RaidPanel:SetEnabled(false)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(true)
  JavCameraControllerRequestBus.Broadcast.RestoreCameraState("UI_Raid", 0.5)
  self.ScriptedEntityTweener:Play(self.entityId, 0.1, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  local durationOut = 0.2
  self.ScriptedEntityTweener:StartAnimation({
    id = self.DOFTweenDummyElement,
    easeMethod = ScriptedEntityTweenerEasingMethod_Cubic,
    duration = durationOut,
    opacity = 0,
    onComplete = function()
      JavelinCameraRequestBus.Broadcast.ResetDepthOfField()
    end
  })
  if self.tickHandler then
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
end
function Raid:OnTick(deltaTime, timePoint)
  if self.conquestStartTime then
    if self.timer > self.second then
      self.timer = self.timer - self.second
      self:SetTimeUntilSiege()
      self:SetAutoSelectCountdown()
    end
    self.timer = self.timer + deltaTime
  end
end
function Raid:SetTimeUntilSiege()
  local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
  local timeRemainingToInvites = self.conquestStartTime:Subtract(now):ToSeconds() - self.minutesBeforeSiegeToSendInvites * timeHelpers.secondsInMinute
  local timeRemaining = GetLocalizedReplacementText("@ui_raid_time_remaining", {
    time = timeHelpers:ConvertSecondsToHrsMinSecString(timeRemainingToInvites, false, false)
  })
  UiTextBus.Event.SetTextWithFlags(self.Properties.TimeUntilSiegeText, timeRemaining, eUiTextSet_SetAsIs)
end
function Raid:SetSelectionsRemaining()
  local raidSelectionsRemainingText = GetLocalizedReplacementText("@ui_raid_selections_remaining", {
    totalSelections = self.totalSelections
  })
  UiTextBus.Event.SetTextWithFlags(self.Properties.NumPlayerSelectionsRemainingText, raidSelectionsRemainingText, eUiTextSet_SetAsIs)
end
function Raid:SetAutoSelectCountdown()
  local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
  local raidAutoSelectCountdownText = GetLocalizedReplacementText("@ui_raid_auto_select_countdown", {
    totalAutoSelections = self.NUM_GROUPS * self.NUM_PLAYERS_IN_GROUP - self.totalSelections,
    timeRemaining = timeHelpers:ConvertToVerboseDurationString(self.conquestStartTime:Subtract(now):ToSeconds() - self.minutesBeforeSiegeToSendInvites * 60, true, false)
  })
  UiTextBus.Event.SetTextWithFlags(self.Properties.AutoSelectCountdownText, raidAutoSelectCountdownText, eUiTextSet_SetAsIs)
end
function Raid:UpdateDepthOfField(currentValue)
  local currentDistance = self.previousDOFDistance + (self.targetDOFDistance - self.previousDOFDistance) * currentValue
  local currentBlur = self.previousDOFBlur + (self.targetDOFBlur - self.previousDOFBlur) * currentValue
  JavelinCameraRequestBus.Broadcast.SetDepthOfField(currentDistance, currentBlur, 0, 0, self.UIStyle.RANGE_DEPTH_OF_FIELD)
end
function Raid:OnExit()
  LyShineManagerBus.Broadcast.ExitState(1468490675)
end
function Raid:OnShowWarTutorial()
  local gameMode = self.isInvasion and GameModeCommon.GAMEMODE_INVASION or GameModeCommon.GAMEMODE_WAR
  DynamicBus.WarTutorialPopup.Broadcast.ShowWarTutorialPopup(gameMode)
end
function Raid:OnPlayerTeleportCompleted()
  self:OnExit()
end
return Raid
