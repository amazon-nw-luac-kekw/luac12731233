local LeaderboardManager = {
  Properties = {
    Icon = {
      default = EntityId(),
      order = 1
    },
    TypeText = {
      default = EntityId(),
      order = 2
    },
    TitleText = {
      default = EntityId(),
      order = 3
    },
    TimeRemainingLabelText = {
      default = EntityId(),
      order = 4
    },
    DayTimeRemainingText = {
      default = EntityId(),
      order = 5
    },
    SeasonTimeRemainingText = {
      default = EntityId(),
      order = 5
    },
    DayLeaderboard = {
      default = EntityId(),
      order = 6
    },
    SeasonLeaderboard = {
      default = EntityId(),
      order = 7
    },
    ButtonDayLeaderboard = {
      default = EntityId(),
      order = 8
    },
    ButtonSeasonLeaderboard = {
      default = EntityId(),
      order = 9
    },
    ButtonClose = {
      default = EntityId(),
      order = 10
    },
    ButtonContainer = {
      default = EntityId(),
      order = 11
    },
    Frame = {
      default = EntityId(),
      order = 12
    }
  },
  enableLeaderboards = false,
  isVisible = false,
  ownGuildId = nil,
  timer = 0,
  timerTick = 1
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(LeaderboardManager)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local socialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
function LeaderboardManager:OnInit()
  BaseElement.OnInit(self)
  self.panelTypes = mapTypes.panelTypes
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.Icon:SetIcon("LyShineUI\\Images\\Icons\\Misc\\icon_leaderboard.png", self.UIStyle.COLOR_TAN)
  self.DayLeaderboard:SetLeaderGuildCrestChangeCallback(self.OnDayLeaderCrestChanged, self)
  self.SeasonLeaderboard:SetLeaderGuildCrestChangeCallback(self.OnSeasonLeaderCrestChanged, self)
  self.ButtonClose:SetCallback(self.OnCloseLeaderboard, self)
  self.Frame:SetFrameStyle(self.Frame.FRAME_STYLE_SIDE_PANEL_LEFT)
  self.Frame:SetOffsets(0, 0, 15, 0)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_enableLeaderboards", function(self, enableLeaderboards)
    self.enableLeaderboards = enableLeaderboards
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.IsLandClaimManagerAvailable", function(self, isAvailable)
    if isAvailable == true then
      self:UpdateDayLeaderboard()
      local currentPeriod = LandClaimRequestBus.Broadcast.GetCurrentLeaderboardPeriod()
      self:OnLeaderboardPeriodChanged(currentPeriod)
      self:BusConnect(LandClaimNotificationBus)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.Id", function(self, guildId)
    if guildId and guildId:IsValid() then
      self.ownGuildId = guildId
      self:UpdateDayLeaderboard()
      self:UpdateSeasonLeaderboard()
    end
  end)
  DynamicBus.Map.Connect(self.entityId, self)
end
function LeaderboardManager:OnShutdown()
  DynamicBus.Map.Disconnect(self.entityId, self)
end
function LeaderboardManager:OnTick(deltaTime, timePoint)
  if not self.enableLeaderboards then
    return
  end
  self.timer = self.timer + deltaTime
  if self.timer >= self.timerTick then
    self.timer = self.timer - self.timerTick
    if self.periodEndTime then
      local now = timeHelpers:ServerNow()
      local timeRemaining = self.periodEndTime:Subtract(now):ToSeconds()
      local showZeroSeconds = false
      local skipSeconds = true
      local timeRemainingText = timeHelpers:ConvertToVerboseDurationString(timeRemaining, showZeroSeconds, skipSeconds)
      local timeText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_leaderboard_time_left", timeRemainingText)
      UiTextBus.Event.SetTextWithFlags(self.Properties.DayTimeRemainingText, timeRemainingText, eUiTextSet_SetLocalized)
      local skipLocalization = true
      self.ButtonDayLeaderboard:SetSubText(timeText, skipLocalization)
    end
  end
end
function LeaderboardManager:OnShowPanel(panelType, isDayLeaderboard)
  if panelType ~= self.panelTypes.Leaderboards then
    self:SetVisibility(false)
    return
  end
  self:SetVisibility(true, isDayLeaderboard)
end
function LeaderboardManager:SetVisibility(isVisible, isDayLeaderboard)
  if self.isVisible == isVisible then
    return
  end
  self.isVisible = isVisible
  if isVisible then
    self.tickBus = self:BusConnect(DynamicBus.UITickBus)
    UiElementBus.Event.SetIsEnabled(self.Properties.DayLeaderboard, isDayLeaderboard)
    UiElementBus.Event.SetIsEnabled(self.Properties.DayTimeRemainingText, isDayLeaderboard)
    UiElementBus.Event.SetIsEnabled(self.Properties.SeasonLeaderboard, not isDayLeaderboard)
    UiElementBus.Event.SetIsEnabled(self.Properties.SeasonTimeRemainingText, not isDayLeaderboard)
    local typeText = isDayLeaderboard and "@ui_leaderboard_day_title" or "@ui_leaderboard_season_title"
    UiTextBus.Event.SetTextWithFlags(self.Properties.TypeText, typeText, eUiTextSet_SetLocalized)
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    self.ScriptedEntityTweener:Play(self.entityId, 0.3, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.entityId, 0.3, {x = -600}, {x = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonContainer, 0.2, {opacity = 0, delay = 0.2})
  else
    if self.tickBus then
      self:BusDisconnect(self.tickBus)
      self.tickBus = nil
    end
    self.ScriptedEntityTweener:Play(self.entityId, 0.2, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.entityId, 0.5, {x = 0}, {
      x = -600,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.entityId, false)
      end
    })
    self.ScriptedEntityTweener:Play(self.Properties.ButtonContainer, 0.05, {opacity = 1})
  end
end
function LeaderboardManager:IsVisible()
  return self.isVisible
end
function LeaderboardManager:OnCloseLeaderboard()
  self:SetVisibility(false)
end
function LeaderboardManager:OnMapShown()
  self:UpdateSeasonLeaderboard()
end
function LeaderboardManager:OnMapHidden()
  self:OnCloseLeaderboard()
end
function LeaderboardManager:UpdateDayLeaderboard()
  if not self.enableLeaderboards then
    return
  end
  local dayEntries = LandClaimRequestBus.Broadcast.GetCurrentPeriodLeaderboard()
  dayEntries = dayEntries or {}
  self.DayLeaderboard:SetEntries(dayEntries)
  local dayOwnEntry
  for i = 1, #dayEntries do
    local entry = dayEntries[i]
    if entry.guildId == self.ownGuildId then
      dayOwnEntry = entry
    end
  end
  dayOwnEntry = dayOwnEntry or {
    position = #dayEntries + 1,
    totalSettlementDays = 0,
    totalScore = 0
  }
  self.DayLeaderboard:SetOwnEntry(dayOwnEntry)
end
function LeaderboardManager:UpdateSeasonLeaderboard()
  if not self.enableLeaderboards then
    return
  end
  local seasonEntries = LandClaimRequestBus.Broadcast.GetClaimsLeaderboard() or {}
  self.SeasonLeaderboard:SetEntries(seasonEntries)
  if self.ownGuildId and self.ownGuildId:IsValid() then
    socialDataHandler:RequestLandClaimScoreDataForGuild_ServerCall(self, self.ScoreDataForGuildSuccess, self.ScoreDataForGuildFailed, self.ownGuildId)
  end
end
function LeaderboardManager:ScoreDataForGuildSuccess(guildId, scoreData)
  self.SeasonLeaderboard:SetOwnEntry(scoreData)
end
function LeaderboardManager:ScoreDataForGuildFailed(reason)
  Debug.Log("Failed to get ScoreData for guild: " .. reason)
end
function LeaderboardManager:OnClaimOwnerChanged(claimKey, newOwnerData)
  if not self.enableLeaderboards then
    return
  end
  self:UpdateDayLeaderboard()
  self.SeasonLeaderboard:TryUpdateEntryForGuild(newOwnerData.guildId, newOwnerData)
end
function LeaderboardManager:OnLeaderboardPeriodChanged(currentPeriod)
  if not self.enableLeaderboards then
    return
  end
  self.periodEndTime = LandClaimRequestBus.Broadcast.GetLeaderboardPeriodEndTime()
  local periodsInSeason = LandClaimRequestBus.Broadcast.GetNumLeaderboardPeriodsInSeason() or 0
  self.periodsRemaining = periodsInSeason - currentPeriod + 1
  self:SetSeasonLeaderboardText(self.periodsRemaining)
  if not self.textSet then
    self.textSet = true
    self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Options.Localization.Language", function(self, setLang)
      self:SetSeasonLeaderboardText(self.periodsRemaining)
    end)
  end
  self:UpdateSeasonLeaderboard()
end
function LeaderboardManager:SetSeasonLeaderboardText(periodsRemaining)
  local timeRemainingText = timeHelpers:ConvertToLargestTimeEstimate(periodsRemaining * timeHelpers.secondsInDay)
  local timeText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_leaderboard_time_left", timeRemainingText)
  UiTextBus.Event.SetText(self.Properties.SeasonTimeRemainingText, timeRemainingText)
  local skipLocalization = true
  self.ButtonSeasonLeaderboard:SetSubText(timeText, skipLocalization)
end
function LeaderboardManager:OnDayLeaderCrestChanged(crestData)
  if crestData then
    self.ButtonDayLeaderboard:SetCrest(crestData)
  end
end
function LeaderboardManager:OnSeasonLeaderCrestChanged(crestData)
  if crestData then
    self.ButtonSeasonLeaderboard:SetCrest(crestData)
  end
end
return LeaderboardManager
