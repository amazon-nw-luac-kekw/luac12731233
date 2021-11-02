local TimeHelperFunctions = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local TerritoryInfoTab = {
  Properties = {
    UpkeepDueInTime = {
      default = EntityId()
    },
    UpkeepAmountDue = {
      default = EntityId()
    },
    AmountDueCoinIcon = {
      default = EntityId()
    },
    NextPaymentAmount = {
      default = EntityId()
    },
    DueInLabel = {
      default = EntityId()
    },
    PayUpkeepButton = {
      default = EntityId()
    },
    StartTime = {
      default = EntityId()
    },
    RecentIncomeAmount = {
      default = EntityId()
    },
    ViewStatementButton = {
      default = EntityId()
    },
    PaycheckPopup = {
      default = EntityId()
    },
    PayUpkeepPopup = {
      default = EntityId()
    },
    SelectPaymentPopup = {
      default = EntityId()
    },
    PaymentSuccessfulPopup = {
      default = EntityId()
    },
    GuildName = {
      default = EntityId()
    },
    GuildNameLabel = {
      default = EntityId()
    },
    SinceDate = {
      default = EntityId()
    },
    SinceDateLabel = {
      default = EntityId()
    },
    UpgradesLabel = {
      default = EntityId()
    },
    PropertyTaxSlider = {
      default = EntityId()
    },
    TradingTaxSlider = {
      default = EntityId()
    },
    CraftingFeeSlider = {
      default = EntityId()
    },
    RefiningFeeSlider = {
      default = EntityId()
    },
    CrestIcon = {
      default = EntityId()
    },
    AmountDueLabel = {
      default = EntityId()
    },
    OverdueIndicator = {
      default = EntityId()
    },
    UpkeepImage = {
      default = EntityId()
    },
    DowngradeImage = {
      default = EntityId()
    },
    DowngradeLabel = {
      default = EntityId()
    },
    BarFill = {
      default = EntityId()
    },
    OverdueLabel = {
      default = EntityId()
    },
    TerritoryUpkeepDesc = {
      default = EntityId()
    },
    UpkeepOverdueContainer = {
      default = EntityId()
    },
    NoUpgradeContainer = {
      default = EntityId()
    },
    RightSideContainer = {
      default = EntityId()
    },
    ChangeButton = {
      default = EntityId()
    },
    TaxAndFeePopup = {
      default = EntityId()
    },
    TaxAndFeePopupContainer = {
      default = EntityId()
    },
    PopupBackground = {
      default = EntityId()
    },
    TaxAndFeeCloseButton = {
      default = EntityId()
    },
    PropertyTaxText = {
      default = EntityId()
    },
    TradingTaxText = {
      default = EntityId()
    },
    CraftingFeeText = {
      default = EntityId()
    },
    RefiningFeeText = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TerritoryInfoTab)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function TerritoryInfoTab:OnInit()
  BaseElement.OnInit(self)
  self.originalSinceLabelY = UiTransformBus.Event.GetLocalPositionY(self.Properties.SinceDateLabel)
  self.originalUpgradesLabelY = UiTransformBus.Event.GetLocalPositionY(self.Properties.UpgradesLabel)
  self.ViewStatementButton:SetCallback(self.OnShowPaycheck, self)
  self.PayUpkeepButton:SetCallback(self.OnPayUpkeep, self)
  self.ChangeButton:SetCallback(self.OnShowTaxFeePopup, self)
  self.ViewStatementButton:SetText("@ui_view_statement", false, true)
  self.ChangeButton:SetText("@ui_change", false, true)
  self.ViewStatementButton:SetButtonStyle(self.ViewStatementButton.BUTTON_STYLE_CTA)
  self.PayUpkeepButton:SetButtonStyle(self.PayUpkeepButton.BUTTON_STYLE_CTA)
  self.ChangeButton:SetButtonStyle(self.ChangeButton.BUTTON_STYLE_CTA)
  self.TaxAndFeeCloseButton:SetCallback(self.OnCloseTaxFeePopup, self)
  self.sliderInfos = {}
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.TerritoryInteractorComponentReady", function(self, ready)
    if ready then
      self.sliderInfos = {
        {
          slider = self.PropertyTaxSlider,
          taxId = eTaxOrFee_PropertyTax,
          max = TerritoryGovernanceRequestBus.Broadcast.GetMaxTaxOrFeeRate(eTaxOrFee_PropertyTax),
          min = TerritoryGovernanceRequestBus.Broadcast.GetMinTaxOrFeeRate(eTaxOrFee_PropertyTax)
        },
        {
          slider = self.TradingTaxSlider,
          taxId = eTaxOrFee_TradingTax,
          max = TerritoryGovernanceRequestBus.Broadcast.GetMaxTaxOrFeeRate(eTaxOrFee_TradingTax),
          min = TerritoryGovernanceRequestBus.Broadcast.GetMinTaxOrFeeRate(eTaxOrFee_TradingTax)
        },
        {
          slider = self.CraftingFeeSlider,
          taxId = eTaxOrFee_CraftingFee,
          max = TerritoryGovernanceRequestBus.Broadcast.GetMaxTaxOrFeeRate(eTaxOrFee_CraftingFee),
          min = TerritoryGovernanceRequestBus.Broadcast.GetMinTaxOrFeeRate(eTaxOrFee_CraftingFee)
        },
        {
          slider = self.RefiningFeeSlider,
          taxId = eTaxOrFee_RefiningFee,
          max = TerritoryGovernanceRequestBus.Broadcast.GetMaxTaxOrFeeRate(eTaxOrFee_RefiningFee),
          min = TerritoryGovernanceRequestBus.Broadcast.GetMinTaxOrFeeRate(eTaxOrFee_RefiningFee)
        }
      }
    end
  end)
  self.editingSlider = false
end
function TerritoryInfoTab:OnShutdown()
end
function TerritoryInfoTab:OnShowTaxFeePopup()
  UiElementBus.Event.SetIsEnabled(self.Properties.TaxAndFeePopup, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.PopupBackground, true)
  self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.TaxAndFeePopupContainer, 0.3, {opacity = 0, y = -10}, {
    opacity = 1,
    y = 0,
    ease = "QuadOut",
    delay = 0.2
  })
end
function TerritoryInfoTab:OnCloseTaxFeePopup()
  if self.IsClosing then
    return
  end
  self.IsClosing = true
  self.ScriptedEntityTweener:Play(self.Properties.TaxAndFeePopupContainer, 0.3, {opacity = 1, y = 0}, {
    opacity = 0,
    y = -10,
    ease = "QuadOut",
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.TaxAndFeePopup, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.PopupBackground, false)
      self.IsClosing = false
    end
  })
  self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.3, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  self:CancelEditModeOnSliders()
end
function TerritoryInfoTab:OnShowPaycheck()
  local earningsData = TerritoryDataHandler:GetCompanyEarningsData(self.territoryId)
  self.PaycheckPopup:OpenPaycheckPopup(earningsData, self.Properties.PopupBackground)
end
function TerritoryInfoTab:OnPayUpkeep()
  local now = timeHelpers:ServerNow()
  local dueTime = TerritoryDataHandler:GetUpkeepDueTime(self.territoryId) or now
  local canPayTime = TerritoryDataHandler:GetUpkeepCanPayTime(self.territoryId)
  local penaltyTime = TerritoryDataHandler:GetUpkeepPenaltyTime(self.territoryId)
  self.amountDue = TerritoryDataHandler:GetUpkeepCost(self.territoryId)
  self.PayUpkeepPopup:ShowPayUpkeepPopup(canPayTime, dueTime, penaltyTime, false, self.amountDue, self.OnSelectPaymentClicked, self)
end
function TerritoryInfoTab:OnSelectPaymentClicked()
  local amountDue = TerritoryDataHandler:GetUpkeepCost(self.territoryId)
  if amountDue ~= self.amountDue then
    return
  end
  self.SelectPaymentPopup:ShowPaymentOptionPopup(self.amountDue, self.OnConfirmPayout, self)
end
function TerritoryInfoTab:OnConfirmPayout(useCompanyWallet)
  TerritoryDataHandler:PayUpkeepCost(self.territoryId, useCompanyWallet)
  local viewLogFn
  if self.territoryInfoScreen.logTabEnabled then
    viewLogFn = self.OnViewLogs
  end
  self.PaymentSuccessfulPopup:ShowPaymentSuccessfulPopup(self.territoryId, self.amountDue, viewLogFn, self)
end
function TerritoryInfoTab:OnViewLogs()
  if self.territoryInfoScreen.logTabEnabled then
    self.territoryInfoScreen:OnLogTab()
  end
end
function TerritoryInfoTab:OnScreenOpened()
  self.territoryManagerEntityId = self.territoryInfoScreen.territoryManagerEntityId
  self.territoryId = self.territoryInfoScreen.territoryId
  self:UpdatePanes()
  self:UpdateSliders()
end
function TerritoryInfoTab:CancelEditModeOnSliders()
  for _, sliderInfo in ipairs(self.sliderInfos) do
    sliderInfo.slider:OnCancel()
  end
end
function TerritoryInfoTab:UpdateSliders()
  local hasPermissions = not self.editingSlider
  hasPermissions = hasPermissions and TerritoryGovernanceRequestBus.Broadcast.CanModifyTaxRates(self.territoryId)
  for _, sliderInfo in ipairs(self.sliderInfos) do
    local value = TerritoryDataHandler:GetTaxOrFeeAmount(self.territoryId, sliderInfo.taxId)
    local canEditTime = TerritoryDataHandler:GetTaxOrFeeCanChange(self.territoryId, sliderInfo.taxId)
    local avg = TerritoryDataHandler:GetAverageTaxOrFeeAmount(sliderInfo.taxId)
    sliderInfo.slider:SetTaxAndFeeInfo(self.territoryInfoScreen.v2enabled, sliderInfo.taxId, value, sliderInfo.min, sliderInfo.max, avg or 0, hasPermissions, canEditTime, self.OnSliderBeginEdit, self.OnSliderEndEdit, self)
  end
  local propertyTaxValue = TerritoryDataHandler:GetTaxOrFeeAmount(self.territoryId, eTaxOrFee_PropertyTax)
  local tradingTaxValue = TerritoryDataHandler:GetTaxOrFeeAmount(self.territoryId, eTaxOrFee_TradingTax)
  local craftingFeeValue = TerritoryDataHandler:GetTaxOrFeeAmount(self.territoryId, eTaxOrFee_CraftingFee)
  local refiningFeeValue = TerritoryDataHandler:GetTaxOrFeeAmount(self.territoryId, eTaxOrFee_RefiningFee)
  UiTextBus.Event.SetText(self.Properties.PropertyTaxText, TerritoryDataHandler:GetTaxOrFeeDisplayText(propertyTaxValue, eTaxOrFee_PropertyTax))
  UiTextBus.Event.SetText(self.Properties.TradingTaxText, TerritoryDataHandler:GetTaxOrFeeDisplayText(tradingTaxValue, eTaxOrFee_TradingTax))
  UiTextBus.Event.SetText(self.Properties.CraftingFeeText, TerritoryDataHandler:GetTaxOrFeeDisplayText(craftingFeeValue, eTaxOrFee_CraftingFee))
  UiTextBus.Event.SetText(self.Properties.RefiningFeeText, TerritoryDataHandler:GetTaxOrFeeDisplayText(refiningFeeValue, eTaxOrFee_RefiningFee))
end
function TerritoryInfoTab:OnSliderBeginEdit(slider)
  self.editingSlider = true
  self:UpdateSliders()
end
function TerritoryInfoTab:OnSliderEndEdit(slider, accept, amount)
  self.editingSlider = false
  if accept then
    DynamicBus.FullScreenSpinner.Broadcast.SetFullscreenSpinnerVisible(true, 2)
    TerritoryDataHandler:SetTaxOrFee(self.territoryId, slider.taxId, amount)
  end
end
function TerritoryInfoTab:SetGuildData(guildData)
  if guildData and guildData:IsValid() then
    self.CrestIcon:SetIcon(guildData.crestData)
    UiTextBus.Event.SetText(self.Properties.GuildName, guildData.guildName)
    UiTextBus.Event.SetTextWithFlags(self.Properties.GuildNameLabel, "@ui_fortressinfo_governedby", eUiTextSet_SetLocalized)
    UiElementBus.Event.SetIsEnabled(self.Properties.UpgradesLabel, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.GuildName, true)
    local since = TerritoryDataHandler:GetGoverningSince(self.territoryInfoScreen.territoryId)
    local isValid = not since:IsZero()
    UiElementBus.Event.SetIsEnabled(self.Properties.SinceDateLabel, isValid)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.UpgradesLabel, isValid and self.originalUpgradesLabelY or self.originalSinceLabelY)
    if isValid then
      local startDateText = TimeHelperFunctions:GetLocalizedAbbrevDate(since:GetTimeSinceEpoc():ToSeconds())
      UiTextBus.Event.SetText(self.Properties.SinceDate, startDateText)
    end
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.GuildNameLabel, "@ui_settlementinfo_notclaimed", eUiTextSet_SetLocalized)
    UiElementBus.Event.SetIsEnabled(self.Properties.SinceDateLabel, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.UpgradesLabel, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.GuildName, false)
  end
end
function TerritoryInfoTab:OnSecondTick()
  self:UpdatePanes()
  self:UpdateSliders()
  if UiElementBus.Event.IsEnabled(self.Properties.PayUpkeepPopup) then
    self.PayUpkeepPopup:OnSecondTick()
  end
end
function TerritoryInfoTab:UpdatePanes()
  local now = timeHelpers:ServerNow()
  local amountDue = GetLocalizedCurrency(TerritoryDataHandler:GetUpkeepCost(self.territoryId))
  local canPayTime = TerritoryDataHandler:GetUpkeepCanPayTime(self.territoryId)
  local dueTime = TerritoryDataHandler:GetUpkeepDueTime(self.territoryId) or now
  local amountDue = TerritoryDataHandler:GetUpkeepCost(self.territoryId)
  if amountDue ~= self.amountDue then
    self.amountDue = amountDue
    if UiElementBus.Event.IsEnabled(self.Properties.PayUpkeepPopup) then
      self.PayUpkeepPopup:UpdateAmountDue(amountDue)
    end
    if UiElementBus.Event.IsEnabled(self.Properties.SelectPaymentPopup) then
      self.SelectPaymentPopup:UpdateAmountDue(amountDue)
    end
  end
  local penaltyTime = TerritoryDataHandler:GetUpkeepPenaltyTime(self.territoryId)
  local timeText = ""
  local color = self.UIStyle.COLOR_GRAY_90
  local labelColor = self.UIStyle.COLOR_GRAY_60
  local completedUpgrades = TerritoryGovernanceRequestBus.Broadcast.GetCompletedTerritoryUpgrades()
  local timeLeft = dueTime:Subtract(now):ToSeconds()
  local upkeepDuration = dueTime:Subtract(canPayTime):ToSeconds()
  local percentage = timeLeft / upkeepDuration
  local timeLeftUntilPenalty = penaltyTime:Subtract(now):ToSeconds()
  local penaltyTimeMinutes = ConfigProviderEventBus.Broadcast.GetInt("javelin.territory-governance-reoccuring-upkeep-penalty-time-m")
  local penaltyDuration = penaltyTimeMinutes * 60
  local penaltyPercentage = timeLeftUntilPenalty / penaltyDuration
  if 1 < percentage then
    UiImageBus.Event.SetFillAmount(self.Properties.BarFill, 1)
    UiTextBus.Event.SetTextWithFlags(self.Properties.DueInLabel, "@ui_next_payment", eUiTextSet_SetLocalized)
  elseif percentage < 1 and 0 < percentage then
    UiImageBus.Event.SetFillAmount(self.Properties.BarFill, percentage)
    UiTextBus.Event.SetTextWithFlags(self.Properties.DueInLabel, "@ui_due_in", eUiTextSet_SetLocalized)
  elseif percentage < 0 then
    UiImageBus.Event.SetFillAmount(self.Properties.BarFill, penaltyPercentage)
    UiTextBus.Event.SetTextWithFlags(self.Properties.DueInLabel, "@ui_next_penalty", eUiTextSet_SetLocalized)
  end
  if now > dueTime then
    if completedUpgrades == 0 then
      UiElementBus.Event.SetIsEnabled(self.Properties.NoUpgradeContainer, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.UpkeepOverdueContainer, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.RightSideContainer, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.DueInLabel, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.TerritoryUpkeepDesc, false)
      self.ScriptedEntityTweener:Set(self.Properties.UpkeepDueInTime, {opacity = 0})
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.NoUpgradeContainer, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.UpkeepOverdueContainer, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.RightSideContainer, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.DueInLabel, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.TerritoryUpkeepDesc, false)
      self.ScriptedEntityTweener:Set(self.Properties.UpkeepDueInTime, {opacity = 1})
    end
    if now > penaltyTime then
      timeText = "00 : 00 : 00 : 00"
    else
      local durationUntilPenalty = penaltyTime:Subtract(now):ToSeconds()
      local days, hours, minutes, seconds = TimeHelperFunctions:ConvertSecondsToDaysHoursMinutesSeconds(durationUntilPenalty)
      timeText = string.format("%02d : %02d : %02d : %02d", days, hours, minutes, seconds)
      color = self.UIStyle.COLOR_GRAY_90
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.OverdueIndicator, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.OverdueLabel, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.AmountDueLabel, false)
    UiImageBus.Event.SetSpritePathname(self.Properties.UpkeepImage, "LyShineUI/Images/territory/territory_upkeep_overdue.png")
    labelColor = self.UIStyle.COLOR_RED_MEDIUM
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.NoUpgradeContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.UpkeepOverdueContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.RightSideContainer, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.DueInLabel, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.TerritoryUpkeepDesc, true)
    self.ScriptedEntityTweener:Set(self.Properties.UpkeepDueInTime, {opacity = 1})
    local duration = dueTime:Subtract(now):ToSeconds()
    local days, hours, minutes, seconds = TimeHelperFunctions:ConvertSecondsToDaysHoursMinutesSeconds(duration)
    timeText = string.format("%02d : %02d : %02d : %02d", days, hours, minutes, seconds)
    UiElementBus.Event.SetIsEnabled(self.Properties.OverdueIndicator, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.OverdueLabel, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.AmountDueLabel, true)
    UiImageBus.Event.SetSpritePathname(self.Properties.UpkeepImage, "LyShineUI/Images/territory/territory_upkeep_default.png")
    self.ScriptedEntityTweener:Set(self.Properties.TerritoryUpkeepDesc, {opacity = 1})
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.UpkeepDueInTime, timeText, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetColor(self.Properties.UpkeepAmountDue, color)
  UiTextBus.Event.SetColor(self.Properties.UpkeepDueInTime, color)
  UiTextBus.Event.SetColor(self.Properties.AmountDueLabel, labelColor)
  UiTextBus.Event.SetColor(self.Properties.DueInLabel, labelColor)
  if not canPayTime then
    return
  end
  if now > canPayTime then
    local territoryOwnerGuildId = TerritoryDataHandler:GetGoverningGuildId(self.territoryId)
    local isClaimedTerritory = territoryOwnerGuildId and territoryOwnerGuildId:IsValid()
    local hasPermissions = TerritoryGovernanceRequestBus.Broadcast.CanModifyTaxRates(self.territoryId)
    self.PayUpkeepButton:SetText("@ui_pay_territory_upkeep", false, true)
    self.PayUpkeepButton:SetEnabled(hasPermissions)
    if not isClaimedTerritory then
      self.PayUpkeepButton:SetTooltip("@ui_project_territory_not_claimed")
    else
      self.PayUpkeepButton:SetTooltip(hasPermissions and "" or "@ui_no_tax_permission")
    end
    UiTextBus.Event.SetText(self.Properties.UpkeepAmountDue, GetLocalizedCurrency(amountDue))
    UiElementBus.Event.SetIsEnabled(self.Properties.NextPaymentAmount, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.UpkeepDueInTime, true)
    UiImageBus.Event.SetSpritePathname(self.Properties.DowngradeImage, "LyShineUI/Images/territory/territory_downgradeImage_default.png")
    UiTextBus.Event.SetTextWithFlags(self.Properties.DowngradeLabel, "@ui_territory_downgrade", eUiTextSet_SetLocalized)
    UiTextBus.Event.SetColor(self.Properties.DowngradeLabel, self.UIStyle.COLOR_RED_MEDIUM)
    UiImageBus.Event.SetColor(self.Properties.BarFill, self.UIStyle.COLOR_RED_MEDIUM)
  else
    local duration = canPayTime:Subtract(now):ToSeconds()
    local canPayTimeText = GetLocalizedReplacementText("@ui_can_pay_in_time", {
      time = TimeHelperFunctions:ConvertToVerboseDurationString(duration, false, true)
    })
    self.PayUpkeepButton:SetText(canPayTimeText, false, true)
    self.PayUpkeepButton:SetEnabled(false)
    self.PayUpkeepButton:SetTooltip(nil)
    UiTextBus.Event.SetText(self.Properties.UpkeepAmountDue, "0")
    UiElementBus.Event.SetIsEnabled(self.Properties.NextPaymentAmount, true)
    UiTextBus.Event.SetText(self.Properties.NextPaymentAmount, GetLocalizedCurrency(amountDue))
    UiElementBus.Event.SetIsEnabled(self.Properties.UpkeepDueInTime, false)
    UiImageBus.Event.SetSpritePathname(self.Properties.DowngradeImage, "LyShineUI/Images/territory/territory_downgradeImage_paid.png")
    UiTextBus.Event.SetTextWithFlags(self.Properties.DowngradeLabel, "@ui_payment_not_required", eUiTextSet_SetLocalized)
    UiTextBus.Event.SetColor(self.Properties.DowngradeLabel, self.UIStyle.COLOR_GREEN)
    UiImageBus.Event.SetColor(self.Properties.BarFill, self.UIStyle.COLOR_GREEN)
  end
  local earningsData = TerritoryDataHandler:GetCompanyEarningsData(self.territoryId)
  local paycheck = earningsData.currentPeriod
  UiTextBus.Event.SetTextWithFlags(self.Properties.StartTime, "@ui_current_period", eUiTextSet_SetLocalized)
  local total = paycheck.totalEarnings
  local totalText = GetLocalizedCurrency(total)
  UiTextBus.Event.SetText(self.Properties.RecentIncomeAmount, totalText)
end
function TerritoryInfoTab:OnEscapeKeyPressed()
  local popups = {
    self.SelectPaymentPopup,
    self.PaycheckPopup,
    self.PayUpkeepPopup,
    self.PaymentSuccessfulPopup
  }
  for _, popup in pairs(popups) do
    local isPopupEnabled = UiElementBus.Event.IsEnabled(popup.entityId)
    if isPopupEnabled then
      popup:OnClose()
      return true
    end
  end
  LyShineManagerBus.Broadcast.SetState(2702338936)
end
return TerritoryInfoTab
