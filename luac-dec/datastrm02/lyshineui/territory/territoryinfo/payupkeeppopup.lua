local TimeHelperFunctions = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local PayUpkeepPopup = {
  Properties = {
    CloseButton = {
      default = EntityId()
    },
    SelectPaymentOptionButton = {
      default = EntityId()
    },
    AmountDue = {
      default = EntityId()
    },
    AmountDueLabel = {
      default = EntityId()
    },
    PopupBackground = {
      default = EntityId()
    },
    MasterContainer = {
      default = EntityId()
    },
    TimeRemainingDay = {
      default = EntityId()
    },
    TimeRemainingHour = {
      default = EntityId()
    },
    TimeRemainingMinute = {
      default = EntityId()
    },
    TimeRemainingSecond = {
      default = EntityId()
    },
    BarFill = {
      default = EntityId()
    },
    UpkeepImage = {
      default = EntityId()
    },
    OverdueLabel = {
      default = EntityId()
    },
    TimeRemainingLabel = {
      default = EntityId()
    },
    LeftSideContainer = {
      default = EntityId()
    },
    Title = {
      default = EntityId()
    },
    Description = {
      default = EntityId()
    },
    DescriptionNoUpgrade = {
      default = EntityId()
    },
    DividerTop1 = {
      default = EntityId()
    },
    DividerTop2 = {
      default = EntityId()
    },
    AmountDueNoUpgrade = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    }
  },
  xOffset = 300
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(PayUpkeepPopup)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function PayUpkeepPopup:OnInit()
  BaseElement.OnInit(self)
  self.CloseButton:SetCallback(self.OnClose, self)
  self.SelectPaymentOptionButton:SetCallback(self.OnSelectPaymentOption, self)
  self.SelectPaymentOptionButton:SetButtonStyle(self.SelectPaymentOptionButton.BUTTON_STYLE_CTA)
  self.SelectPaymentOptionButton:SetText("@ui_select_payment_option")
  self.initialTitleSize = UiTransform2dBus.Event.GetLocalWidth(self.Properties.Title)
end
function PayUpkeepPopup:ShowPayUpkeepPopup(startTime, dueTime, penaltyTime, overdue, amount, callback, context)
  self.startTime = startTime
  self.dueTime = dueTime
  self.overdue = overdue
  self:UpdateAmountDue(amount)
  self.callback = callback
  self.context = context
  self.penaltyTime = penaltyTime
  self:OnSecondTick()
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.PopupBackground, true)
  self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.3, {opacity = 0, y = -10}, {
    opacity = 1,
    y = 0,
    ease = "QuadOut",
    delay = 0.2
  })
end
function PayUpkeepPopup:UpdateAmountDue(amount)
  self.amount = amount
  UiTextBus.Event.SetText(self.Properties.AmountDue, GetLocalizedCurrency(self.amount))
  UiTextBus.Event.SetText(self.Properties.AmountDueNoUpgrade, GetLocalizedCurrency(self.amount))
end
function PayUpkeepPopup:OnSecondTick()
  local timeText = ""
  local color = self.UIStyle.COLOR_GRAY_90
  local now = timeHelpers:ServerNow()
  local completedUpgrades = TerritoryGovernanceRequestBus.Broadcast.GetCompletedTerritoryUpgrades()
  local timeLeft = self.dueTime:Subtract(now):ToSeconds()
  local upkeepDuration = self.dueTime:Subtract(self.startTime):ToSeconds()
  local percentage = timeLeft / upkeepDuration
  local timeLeftUntilPenalty = self.penaltyTime:Subtract(now):ToSeconds()
  local penaltyTimeMinutes = ConfigProviderEventBus.Broadcast.GetInt("javelin.territory-governance-reoccuring-upkeep-penalty-time-m")
  local penaltyDuration = penaltyTimeMinutes * 60
  local penaltyPercentage = timeLeftUntilPenalty / penaltyDuration
  if 1 < percentage then
    UiImageBus.Event.SetFillAmount(self.Properties.BarFill, 1)
  elseif percentage < 1 and 0 < percentage then
    UiImageBus.Event.SetFillAmount(self.Properties.BarFill, percentage)
  elseif percentage < 0 then
    UiImageBus.Event.SetFillAmount(self.Properties.BarFill, penaltyPercentage)
  end
  if now > self.dueTime then
    if completedUpgrades == 0 then
      UiElementBus.Event.SetIsEnabled(self.Properties.LeftSideContainer, false)
      UiTextBus.Event.SetHorizontalTextAlignment(self.Properties.Title, self.UIStyle.TEXT_HALIGN_CENTER)
      self.ScriptedEntityTweener:Set(self.Properties.Title, {x = 0})
      UiElementBus.Event.SetIsEnabled(self.Properties.TimeRemainingLabel, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.TimeRemainingDay, false)
      self.ScriptedEntityTweener:Set(self.Properties.DividerTop1, {x = 70, w = 676})
      UiElementBus.Event.SetIsEnabled(self.Properties.DividerTop2, false)
      UiTextBus.Event.SetHorizontalTextAlignment(self.Properties.AmountDueLabel, self.UIStyle.TEXT_HALIGN_CENTER)
      self.ScriptedEntityTweener:Set(self.Properties.AmountDueLabel, {x = 0})
      UiElementBus.Event.SetIsEnabled(self.Properties.AmountDue, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.AmountDueNoUpgrade, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.Description, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.DescriptionNoUpgrade, true)
      self.ScriptedEntityTweener:Set(self.Properties.MasterContainer, {h = 670})
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.LeftSideContainer, true)
      UiTextBus.Event.SetHorizontalTextAlignment(self.Properties.Title, self.UIStyle.TEXT_HALIGN_LEFT)
      self.ScriptedEntityTweener:Set(self.Properties.Title, {
        x = self.xOffset
      })
      UiElementBus.Event.SetIsEnabled(self.Properties.TimeRemainingLabel, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.TimeRemainingDay, true)
      self.ScriptedEntityTweener:Set(self.Properties.DividerTop1, {
        x = self.xOffset,
        w = 444
      })
      UiElementBus.Event.SetIsEnabled(self.Properties.DividerTop2, true)
      UiTextBus.Event.SetHorizontalTextAlignment(self.Properties.AmountDueLabel, self.UIStyle.TEXT_HALIGN_LEFT)
      self.ScriptedEntityTweener:Set(self.Properties.AmountDueLabel, {
        x = self.xOffset
      })
      UiElementBus.Event.SetIsEnabled(self.Properties.AmountDue, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.AmountDueNoUpgrade, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.Description, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.DescriptionNoUpgrade, false)
      self.ScriptedEntityTweener:Set(self.Properties.MasterContainer, {h = 914})
    end
    color = self.UIStyle.COLOR_RED_MEDIUM
    UiImageBus.Event.SetSpritePathname(self.Properties.UpkeepImage, "LyShineUI/Images/territory/territory_upkeep_overdue.png")
    UiTextBus.Event.SetTextWithFlags(self.Properties.Description, "@ui_territoryupkeep_overdue_desc", eUiTextSet_SetLocalized)
    UiElementBus.Event.SetIsEnabled(self.Properties.OverdueLabel, true)
    UiTextBus.Event.SetTextWithFlags(self.Properties.TimeRemainingLabel, "@ui_next_penalty", eUiTextSet_SetLocalized)
    UiTextBus.Event.SetColor(self.Properties.TimeRemainingLabel, self.UIStyle.COLOR_RED_MEDIUM)
    UiTextBus.Event.SetColor(self.Properties.Description, self.UIStyle.COLOR_RED_MEDIUM)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.Title, self.initialTitleSize)
    if now > self.penaltyTime then
      UiTextBus.Event.SetText(self.Properties.TimeRemainingDay, "00")
      UiTextBus.Event.SetText(self.Properties.TimeRemainingHour, "00")
      UiTextBus.Event.SetText(self.Properties.TimeRemainingMinute, "00")
      UiTextBus.Event.SetText(self.Properties.TimeRemainingSecond, "00")
    else
      local durationUntilPenalty = self.penaltyTime:Subtract(now):ToSeconds()
      local days, hours, minutes, seconds = TimeHelperFunctions:ConvertSecondsToDaysHoursMinutesSeconds(durationUntilPenalty)
      local dayText = string.format("%02d ", days)
      local hourText = string.format("%02d ", hours)
      local minuteText = string.format("%02d ", minutes)
      local secondText = string.format("%02d ", seconds)
      UiTextBus.Event.SetText(self.Properties.TimeRemainingDay, dayText)
      UiTextBus.Event.SetText(self.Properties.TimeRemainingHour, hourText)
      UiTextBus.Event.SetText(self.Properties.TimeRemainingMinute, minuteText)
      UiTextBus.Event.SetText(self.Properties.TimeRemainingSecond, secondText)
    end
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.LeftSideContainer, true)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.Title, self.initialTitleSize - self.xOffset)
    UiTextBus.Event.SetHorizontalTextAlignment(self.Properties.Title, self.UIStyle.TEXT_HALIGN_LEFT)
    self.ScriptedEntityTweener:Set(self.Properties.Title, {
      x = self.xOffset
    })
    UiElementBus.Event.SetIsEnabled(self.Properties.TimeRemainingLabel, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.TimeRemainingDay, true)
    self.ScriptedEntityTweener:Set(self.Properties.DividerTop1, {
      x = self.xOffset,
      w = 444
    })
    UiElementBus.Event.SetIsEnabled(self.Properties.DividerTop2, true)
    UiTextBus.Event.SetHorizontalTextAlignment(self.Properties.AmountDueLabel, self.UIStyle.TEXT_HALIGN_LEFT)
    self.ScriptedEntityTweener:Set(self.Properties.AmountDueLabel, {
      x = self.xOffset
    })
    UiElementBus.Event.SetIsEnabled(self.Properties.AmountDue, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.AmountDueNoUpgrade, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.Description, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.DescriptionNoUpgrade, false)
    self.ScriptedEntityTweener:Set(self.Properties.MasterContainer, {h = 914})
    UiImageBus.Event.SetSpritePathname(self.Properties.UpkeepImage, "LyShineUI/Images/territory/territory_upkeep_default.png")
    UiTextBus.Event.SetTextWithFlags(self.Properties.Description, "@ui_territoryupkeep_desc", eUiTextSet_SetLocalized)
    UiElementBus.Event.SetIsEnabled(self.Properties.OverdueLabel, false)
    UiTextBus.Event.SetTextWithFlags(self.Properties.TimeRemainingLabel, "@ui_time_remaining", eUiTextSet_SetLocalized)
    UiTextBus.Event.SetColor(self.Properties.TimeRemainingLabel, self.UIStyle.COLOR_TAN_MEDIUM)
    UiTextBus.Event.SetColor(self.Properties.Description, self.UIStyle.COLOR_TAN_MEDIUM)
    local duration = self.dueTime:Subtract(now):ToSeconds()
    local days, hours, minutes, seconds = TimeHelperFunctions:ConvertSecondsToDaysHoursMinutesSeconds(duration)
    local dayText = string.format("%02d ", days)
    local hourText = string.format("%02d ", hours)
    local minuteText = string.format("%02d ", minutes)
    local secondText = string.format("%02d ", seconds)
    UiTextBus.Event.SetText(self.Properties.TimeRemainingDay, dayText)
    UiTextBus.Event.SetText(self.Properties.TimeRemainingHour, hourText)
    UiTextBus.Event.SetText(self.Properties.TimeRemainingMinute, minuteText)
    UiTextBus.Event.SetText(self.Properties.TimeRemainingSecond, secondText)
  end
  UiTextBus.Event.SetColor(self.Properties.TimeRemainingDay, color)
  UiTextBus.Event.SetColor(self.Properties.TimeRemainingHour, color)
  UiTextBus.Event.SetColor(self.Properties.TimeRemainingMinute, color)
  UiTextBus.Event.SetColor(self.Properties.TimeRemainingSecond, color)
end
function PayUpkeepPopup:OnClose()
  if self.IsClosing then
    return
  end
  self.IsClosing = true
  self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.3, {opacity = 1, y = 0}, {
    opacity = 0,
    y = -10,
    ease = "QuadOut",
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.entityId, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.PopupBackground, false)
      self.IsClosing = false
    end
  })
  self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.3, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
end
function PayUpkeepPopup:OnSelectPaymentOption()
  if self.IsClosing then
    return
  end
  self.IsClosing = true
  self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.2, {opacity = 1}, {
    opacity = 0,
    ease = "QuadOut",
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.entityId, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.PopupBackground, false)
      self.IsClosing = false
    end
  })
  self.callback(self.context)
end
return PayUpkeepPopup
