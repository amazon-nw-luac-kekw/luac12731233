local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local SiegeWindowTab = {
  Properties = {
    CurrentSiegeWindowText = {
      default = EntityId()
    },
    Slider = {
      default = EntityId()
    },
    SliderText = {
      default = EntityId()
    },
    ClaimsIcon = {
      default = EntityId()
    },
    ClaimsText = {
      default = EntityId()
    },
    ClaimsCount = {
      default = EntityId()
    },
    NoClaimContainer = {
      default = EntityId()
    },
    ClaimsHeader = {
      default = EntityId()
    },
    AcceptButton = {
      default = EntityId()
    },
    Tab = {
      default = EntityId()
    },
    RuneA = {
      default = EntityId()
    },
    RuneB = {
      default = EntityId()
    },
    RuneC = {
      default = EntityId()
    },
    ChangeToHeader = {
      default = EntityId()
    },
    ChangeToText = {
      default = EntityId()
    },
    ChangeEffect = {
      default = EntityId()
    },
    SelectionBlocker1 = {
      default = EntityId()
    },
    SelectionBlocker2 = {
      default = EntityId()
    },
    MaintenanceWindowIndicator = {
      default = EntityId()
    }
  },
  currentSiegeWindow = 0,
  timer = 0,
  timerTickSeconds = 1,
  setSiegeWindowPopupTitle = "@ui_setsiegeswindowpopup_title",
  changeSiegeWindowPopupEventId = "Popup_ChangeSiegeWindow",
  defaultMaxSlider = 23,
  siegeWindowRoundingHours = 1,
  tickUnits = 35,
  maxMaintenanceWindowId = 2
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(SiegeWindowTab)
local dominionCommon = RequireScript("LyShineUI._Common.DominionCommon")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function SiegeWindowTab:OnInit()
  BaseElement.OnInit(self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Social.DataSynced", function(self, synced)
    if synced then
      self.siegeDuration = WarRequestBus.Broadcast.GetWarPhaseDuration(eWarPhase_Conquest):ToHours()
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.Enabled", function(self, enabled)
    if enabled then
      self.startTime = self:ConvertFromUtc(GuildsComponentBus.Broadcast.GetValidSiegeWindowStartHour())
      self.endTime = self:ConvertFromUtc(GuildsComponentBus.Broadcast.GetValidSiegeWindowEndHour())
    end
  end)
  self.Slider:SetCallback(self.OnSliderChanged, self)
  self.Slider:SetSliderTextVisible(false)
  self.Slider:SetMaxValue(self.defaultMaxSlider)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.SiegeWindowRoundingHours", function(self, value)
    if value then
      self.siegeWindowRoundingHours = value
      local maxValue = self.defaultMaxSlider
      if self.siegeWindowRoundingHours > 0 then
        maxValue = 24 / self.siegeWindowRoundingHours - 1
      end
      self.Slider:SetMaxValue(maxValue)
      if self.endTime == self.startTime then
        UiElementBus.Event.SetIsEnabled(self.Properties.SelectionBlocker1, false)
        UiElementBus.Event.SetIsEnabled(self.Properties.SelectionBlocker2, false)
      elseif self.endTime > self.startTime then
        UiTransformBus.Event.SetLocalPositionX(self.Properties.SelectionBlocker1, 0)
        local selectionBlocker1Width = self.startTime * self.tickUnits
        UiTransform2dBus.Event.SetLocalWidth(self.Properties.SelectionBlocker1, selectionBlocker1Width)
        local selectionBlocker2X = (self.endTime + value) * self.tickUnits
        local selectionBlocker2Width = (24 - self.endTime - value) * self.tickUnits
        UiTransformBus.Event.SetLocalPositionX(self.Properties.SelectionBlocker2, selectionBlocker2X)
        UiTransform2dBus.Event.SetLocalWidth(self.Properties.SelectionBlocker2, selectionBlocker2Width)
        UiElementBus.Event.SetIsEnabled(self.Properties.SelectionBlocker1, true)
        UiElementBus.Event.SetIsEnabled(self.Properties.SelectionBlocker2, true)
      else
        local selectionBlockerX = (self.endTime + value) * self.tickUnits
        local selectionBlockerWidth = (self.startTime - self.endTime - value) * self.tickUnits
        UiTransformBus.Event.SetLocalPositionX(self.Properties.SelectionBlocker1, selectionBlockerX)
        UiTransform2dBus.Event.SetLocalWidth(self.Properties.SelectionBlocker1, selectionBlockerWidth)
        UiElementBus.Event.SetIsEnabled(self.Properties.SelectionBlocker1, true)
      end
    end
  end)
  self.AcceptButton:SetCallback(self.OnAccept, self)
  self.AcceptButton:SetText("@ui_changesiegewindow")
  self.AcceptButton:SetButtonStyle(self.AcceptButton.BUTTON_STYLE_CTA)
  self.ClaimsIcon:SetPath("lyshineui/images/icons/misc/icon_exclamation_white.png")
end
function SiegeWindowTab:OnShutdown()
  self.dataLayer:UnregisterObservers(self)
end
function SiegeWindowTab:RegisterObservers()
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.SiegeWindow", function(self, siegeWindow)
    if siegeWindow then
      self.currentSiegeWindow = siegeWindow
      local siegeWindowText = dominionCommon:GetSiegeWindowText(siegeWindow, self.siegeDuration)
      UiTextBus.Event.SetText(self.CurrentSiegeWindowText, siegeWindowText)
      self:UpdateAcceptButton()
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.NumClaims", function(self, numClaims)
    if numClaims then
      local color = 0 < numClaims and self.UIStyle.COLOR_TAN or self.UIStyle.COLOR_RED
      UiTextBus.Event.SetColor(self.ClaimsCount, color)
      UiTextBus.Event.SetColor(self.ClaimsHeader, color)
      UiTextBus.Event.SetText(self.ClaimsCount, numClaims)
      UiTextBus.Event.SetTextWithFlags(self.ClaimsHeader, numClaims == 1 and "@ui_guildoneclaimowned" or "@ui_guildclaimsowned", eUiTextSet_SetLocalized)
      local text = "@ui_siegenoclaimsowned"
      if 0 < numClaims then
        text = GetLocalizedReplacementText("@ui_siegeclaimsowned", {numClaims = numClaims})
        UiElementBus.Event.SetIsEnabled(self.NoClaimContainer, false)
        UiTransformBus.Event.SetLocalPositionY(self.ClaimsHeader, 122)
        UiTransformBus.Event.SetLocalPositionY(self.ClaimsCount, -36)
        UiTextBus.Event.SetFontSize(self.ClaimsHeader, 30)
        UiTextBus.Event.SetFontSize(self.ClaimsCount, 72)
      else
        UiElementBus.Event.SetIsEnabled(self.NoClaimContainer, true)
        UiTransformBus.Event.SetLocalPositionY(self.ClaimsHeader, 64)
        UiTransformBus.Event.SetLocalPositionY(self.ClaimsCount, -16)
        UiTextBus.Event.SetFontSize(self.ClaimsHeader, 22)
        UiTextBus.Event.SetFontSize(self.ClaimsCount, 54)
      end
    end
  end)
  self.dataLayer:RegisterCallback(self, "Hud.LocalPlayer.Guild.Rank", self.UpdateAcceptButton)
  self.dataLayer:RegisterCallback(self, "Hud.LocalPlayer.Guild.LastModifiedGuildWarId", self.UpdateAcceptButton)
end
function SiegeWindowTab:UnregisterObservers()
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Guild.SiegeWindow")
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Guild.NumClaims")
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Guild.Rank")
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Guild.LastModifiedGuildWarId")
end
function SiegeWindowTab:StartTick()
  if not self.tickHandler then
    self.timer = 0
    self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function SiegeWindowTab:StopTick()
  if not self.tickHandler then
    return
  end
  self:BusDisconnect(self.tickHandler)
  self.tickHandler = nil
end
function SiegeWindowTab:OnTick(deltaTime, timePoint)
  self.timer = self.timer + deltaTime
  if self.timer >= self.timerTickSeconds then
    self.timer = self.timer - self.timerTickSeconds
    local disabledSeconds = GuildsComponentBus.Broadcast.GetGuildSetSiegeDisabledDuration():ToSecondsUnrounded()
    if disabledSeconds <= 0 then
      self:StopTick()
      self:UpdateAcceptButton()
    else
      self.lastDisabledSeconds = disabledSeconds
      self:SetAcceptButtonText(self.lastHasPermission, self.lastIsAtWar, disabledSeconds)
    end
  end
end
function SiegeWindowTab:SetVisible(isVisible)
  if isVisible == self.isVisible then
    return
  end
  self.isVisible = isVisible
  if isVisible then
    self:RegisterObservers()
    self:SetSliderValue(self.currentSiegeWindow)
    UiTextBus.Event.SetText(self.SliderText, dominionCommon:GetSiegeWindowText(self.currentSiegeWindow, self.siegeDuration))
    UiTextBus.Event.SetText(self.ChangeToText, dominionCommon:GetSiegeWindowText(self.currentSiegeWindow, self.siegeDuration))
    self:RefreshMaintenanceWindowDisplays()
    self.ScriptedEntityTweener:Play(self.Properties.RuneA, 20, {rotation = 0}, {timesToPlay = -1, rotation = 359})
    self.ScriptedEntityTweener:Play(self.Properties.RuneB, 20, {rotation = 0}, {timesToPlay = -1, rotation = 359})
    self.ScriptedEntityTweener:Play(self.Properties.RuneC, 20, {rotation = 0}, {timesToPlay = -1, rotation = -359})
    self.ScriptedEntityTweener:Play(self.entityId, 0.4, {opacity = 0}, {opacity = 1})
  else
    self:UnregisterObservers()
    self:StopTick()
    UiElementBus.Event.SetIsEnabled(self.ChangeToHeader, false)
    self.ScriptedEntityTweener:Play(self.entityId, 0.4, {opacity = 1}, {opacity = 0})
  end
end
function SiegeWindowTab:ConvertToUtc(value)
  local date = os.date("*t", timeHelpers:GetUtcStartOfDay())
  date.hour = math.floor(value)
  date.min = (value - date.hour) * timeHelpers.minutesInHour
  return os.time(date) % timeHelpers.secondsInDay
end
function SiegeWindowTab:ConvertFromUtc(utcValue, skipRounding)
  local startOfDay = timeHelpers:GetUtcStartOfDay()
  local date = os.date("*t", startOfDay + utcValue * timeHelpers.secondsInHour)
  local hours = date.hour + date.min / timeHelpers.minutesInHour + date.sec
  if skipRounding then
    return hours
  else
    return hours / self.siegeWindowRoundingHours
  end
end
function SiegeWindowTab:SetSliderValue(utcHours)
  local value = self:ConvertFromUtc(utcHours)
  self.lastValidSliderValue = value
  self.Slider:SetSliderValue(value)
end
function SiegeWindowTab:GetSliderValue()
  local adjustedValue = self.Slider:GetValue() * self.siegeWindowRoundingHours
  local utcValue = self:ConvertToUtc(adjustedValue)
  return utcValue / timeHelpers.secondsInHour
end
function SiegeWindowTab:OnSliderChanged(slider)
  self:ValidateSlider()
  local value = self:GetSliderValue()
  UiTextBus.Event.SetText(self.SliderText, dominionCommon:GetSiegeWindowText(value, self.siegeDuration))
  UiTextBus.Event.SetText(self.ChangeToText, dominionCommon:GetSiegeWindowText(value, self.siegeDuration))
  self:UpdateAcceptButton()
  if value ~= self.currentSiegeWindow then
    UiElementBus.Event.SetIsEnabled(self.ChangeToHeader, true)
  else
    UiElementBus.Event.SetIsEnabled(self.ChangeToHeader, false)
  end
end
function SiegeWindowTab:ValidateSlider()
  if self.startTime == self.endTime then
    return
  end
  local rawValue = self.Slider:GetValue()
  local adjustedValue = rawValue * self.siegeWindowRoundingHours
  local isValid = false
  if self.startTime > self.endTime then
    isValid = adjustedValue <= self.endTime or adjustedValue >= self.startTime
  else
    isValid = adjustedValue >= self.startTime and adjustedValue <= self.endTime
  end
  if isValid then
    self.lastValidSliderValue = tonumber(rawValue)
  else
    self.Slider:SetSliderValue(self.lastValidSliderValue, true, true, 0)
  end
end
function SiegeWindowTab:OnPopupResult(result, eventId)
  if result ~= ePopupResult_Yes then
    return
  end
  if eventId == self.changeSiegeWindowPopupEventId then
    local siegeWindow = self:GetSliderValue()
    GuildsComponentBus.Broadcast.RequestSetGuildSiegeWindow(siegeWindow)
    UiElementBus.Event.SetIsEnabled(self.ChangeEffect, true)
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.ChangeEffect, 0)
    UiFlipbookAnimationBus.Event.Start(self.ChangeEffect)
    self.audioHelper:PlaySound(self.audioHelper.Screen_SiegeWindowSet)
  end
end
function SiegeWindowTab:UpdateAcceptButton()
  local hasPermission = GuildsComponentBus.Broadcast.HasPrivilege(eGuildPrivilegeId_Declare_War)
  local isAtWar = WarDataClientRequestBus.Broadcast.IsAtWar()
  local disabledSeconds = GuildsComponentBus.Broadcast.GetGuildSetSiegeDisabledDuration():ToSecondsUnrounded()
  local hasChanged = hasPermission ~= self.lastHasPermission or isAtWar ~= self.lastIsAtWar or disabledSeconds ~= self.lastDisabledSeconds
  if hasChanged then
    local buttonEnabled = hasPermission and not isAtWar and disabledSeconds <= 0
    self.AcceptButton:SetEnabled(buttonEnabled)
    self:SetAcceptButtonText(hasPermission, isAtWar, disabledSeconds)
    self:SetAcceptButtonTooltip(hasPermission, isAtWar, disabledSeconds)
    if 0 < disabledSeconds then
      self:StartTick()
    else
      self:StopTick()
    end
    self.AcceptButton:SetEnabled(buttonEnabled)
    self.lastHasPermission = hasPermission
    self.lastDisabledSeconds = disabledSeconds
    self.lastIsAtWar = isAtWar
  end
end
function SiegeWindowTab:SetAcceptButtonText(hasPermission, isAtWar, disabledSeconds)
  local buttonText = "@ui_setsiegebutton_canchange"
  if not hasPermission then
    buttonText = "@ui_setsiegebutton_nopermission"
  elseif isAtWar then
    buttonText = "@ui_setsiegebutton_atwar"
  elseif 0 < disabledSeconds then
    buttonText = GetLocalizedReplacementText("@ui_setsiegebutton_changein", {
      timeRemaining = timeHelpers:ConvertSecondsToHrsMinSecString(disabledSeconds)
    })
  end
  self.AcceptButton:SetText(buttonText)
end
function SiegeWindowTab:SetAcceptButtonTooltip(hasPermission, isAtWar, disabledSeconds)
  local tooltipText = ""
  if not hasPermission then
    local rankName = GuildsComponentBus.Broadcast.GetPlayerRankName()
    tooltipText = GetLocalizedReplacementText("@ui_siegewindow_tooltip_nopermission", {rankName = rankName})
  end
  if isAtWar then
    if 0 < #tooltipText then
      tooltipText = tooltipText .. [[


]]
    end
    tooltipText = tooltipText .. "@ui_siegewindow_tooltip_atwar"
  end
  if 0 < disabledSeconds then
    if 0 < #tooltipText then
      tooltipText = tooltipText .. [[


]]
    end
    tooltipText = tooltipText .. GetLocalizedReplacementText("@ui_siegewindow_tooltip_disabled", {
      timeRemaining = timeHelpers:ConvertSecondsToHrsMinSecString(disabledSeconds)
    })
  end
  if 0 < #tooltipText then
    tooltipText = AddTextColorMarkup(tooltipText, self.UIStyle.COLOR_RED)
  end
  self.AcceptButton:SetTooltip(tooltipText)
end
function SiegeWindowTab:GetMaintenanceWindowText(maintStart, maintEnd)
  local startOfDay = timeHelpers:GetUtcStartOfDay()
  local startTime = startOfDay + maintStart * timeHelpers.secondsInHour
  local endTime = startOfDay + maintEnd * timeHelpers.secondsInHour
  local timeIntervalString = GetLocalizedReplacementText("@ui_time_interval_format", {
    startTime = timeHelpers:GetLocalizedServerTime(startTime, false),
    endTime = timeHelpers:GetLocalizedServerTime(endTime, true)
  })
  return timeIntervalString
end
function SiegeWindowTab:RefreshMaintenanceWindowDisplays()
  local noMaintenanceHour = -1
  if self.maintenanceWindowEntities then
    for _, indicator in ipairs(self.maintenanceWindowEntities) do
      UiElementBus.Event.SetIsEnabled(indicator, false)
    end
  end
  local entityIndex = 1
  for i = 0, self.maxMaintenanceWindowId do
    local startHour = GuildsComponentBus.Broadcast.GetMaintenanceWindowStartHour(i)
    local endHour = GuildsComponentBus.Broadcast.GetMaintenanceWindowEndHour(i)
    if startHour ~= noMaintenanceHour and endHour ~= noMaintenanceHour then
      local indicatorEntity = self:GetMaintenanceWindowEntity(entityIndex)
      entityIndex = entityIndex + 1
      local startHourSliderUnits = self:ConvertFromUtc(startHour, true)
      local endHourSliderUnits = self:ConvertFromUtc(endHour, true)
      if startHourSliderUnits > endHourSliderUnits then
        self:UpdateMaintenanceWindowEntityDisplay(indicatorEntity, startHourSliderUnits, 23)
        indicatorEntity = self:GetMaintenanceWindowEntity(entityIndex)
        entityIndex = entityIndex + 1
        self:UpdateMaintenanceWindowEntityDisplay(indicatorEntity, 0, endHourSliderUnits)
      else
        self:UpdateMaintenanceWindowEntityDisplay(indicatorEntity, startHourSliderUnits, endHourSliderUnits)
      end
    end
  end
end
function SiegeWindowTab:GetMaintenanceWindowEntity(entityIndex)
  if not self.maintenanceWindowEntities then
    self.maintenanceWindowEntities = {
      self.Properties.MaintenanceWindowIndicator
    }
  end
  local indicatorEntity = self.maintenanceWindowEntities[entityIndex]
  if not indicatorEntity then
    local prototype = self.maintenanceWindowEntities[1]
    local parent = UiElementBus.Event.GetParent(prototype)
    local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
    indicatorEntity = CloneUiElement(canvasId, self.registrar, prototype, parent, true)
    self.maintenanceWindowEntities[entityIndex] = indicatorEntity
  end
  return indicatorEntity
end
function SiegeWindowTab:UpdateMaintenanceWindowEntityDisplay(indicatorEntity, startHourSliderUnits, endHourSliderUnits)
  local indicatorX = startHourSliderUnits * self.tickUnits
  local width = (endHourSliderUnits - startHourSliderUnits) * self.tickUnits
  UiTransformBus.Event.SetLocalPositionX(indicatorEntity, indicatorX)
  UiTransform2dBus.Event.SetLocalWidth(indicatorEntity, width)
  UiElementBus.Event.SetIsEnabled(indicatorEntity, true)
end
function SiegeWindowTab:OnAccept()
  local siegeWindow = self:GetSliderValue()
  local siegeWindowHr = math.floor(siegeWindow + 0.5)
  local maintenanceWindowOverlap = GuildsComponentBus.Broadcast.OverlapsWithMaintenanceWindows(siegeWindowHr)
  if 0 < maintenanceWindowOverlap then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = GetLocalizedReplacementText("@ui_siegewindow_notification_maintenance", {
      maintWindow = self:GetMaintenanceWindowText(GuildsComponentBus.Broadcast.GetMaintenanceWindowStartHour(maintenanceWindowOverlap), GuildsComponentBus.Broadcast.GetMaintenanceWindowEndHour(maintenanceWindowOverlap))
    })
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  elseif siegeWindow == self.currentSiegeWindow then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@ui_siegewindow_notification_selectnewvalue"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  else
    local message = GetLocalizedReplacementText("@ui_setsiegeswindowpopup_message", {
      siegeWindow = dominionCommon:GetSiegeWindowText(siegeWindow, self.siegeDuration),
      cooldownTime = timeHelpers:ConvertToVerboseDurationString(GuildsComponentBus.Broadcast.GetGuildSiegeWindowCooldownDuration():ToSeconds())
    })
    PopupWrapper:RequestPopup(ePopupButtons_YesNo, self.setSiegeWindowPopupTitle, message, self.changeSiegeWindowPopupEventId, self, self.OnPopupResult)
  end
end
return SiegeWindowTab
