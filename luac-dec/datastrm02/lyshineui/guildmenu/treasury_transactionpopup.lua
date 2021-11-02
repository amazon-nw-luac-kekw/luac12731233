local Treasury_TransactionPopup = {
  Properties = {
    PopupHolder = {
      default = EntityId(),
      order = 1
    },
    SubHeaderLabel = {
      default = EntityId(),
      order = 2
    },
    BalanceAmount = {
      default = EntityId(),
      order = 3
    },
    DailyLimitContainer = {
      default = EntityId(),
      order = 4
    },
    DailyLimitAmount = {
      default = EntityId(),
      order = 5
    },
    AvailableAmount = {
      default = EntityId(),
      order = 6
    },
    PopupDivider = {
      default = EntityId(),
      order = 7
    },
    Frame = {
      default = EntityId(),
      order = 8
    },
    FrameHeader = {
      default = EntityId(),
      order = 9
    },
    ScreenScrim = {
      default = EntityId(),
      order = 10
    },
    CurrencySlider = {
      default = EntityId(),
      order = 11
    },
    ButtonAccept = {
      default = EntityId(),
      order = 12
    },
    ButtonCancel = {
      default = EntityId(),
      order = 13
    },
    ButtonClose = {
      default = EntityId(),
      order = 14
    },
    DepositLimit = {
      default = EntityId(),
      order = 15
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(Treasury_TransactionPopup)
local socialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
function Treasury_TransactionPopup:OnInit()
  BaseElement.OnInit(self)
  socialDataHandler:OnActivate()
  self.dataLayer = dataLayer
  self.playerWalletCap = ConfigProviderEventBus.Broadcast.GetUInt64("javelin.wallet-cap-player")
  self.treasuryWalletCap = ConfigProviderEventBus.Broadcast.GetUInt64("javelin.wallet-cap-company")
  SetTextStyle(self.Properties.SubHeaderLabel, self.UIStyle.FONT_STYLE_HEADER_SECONDARY)
  self.FrameHeader:SetTextAlignment(self.FrameHeader.TEXT_ALIGN_CENTER)
  self.FrameHeader:SetText()
  self.ButtonAccept:SetText("@ui_trade_send_title")
  self.ButtonAccept:SetCallback(self.OnAccept, self)
  self.ButtonAccept:SetButtonStyle(self.ButtonAccept.BUTTON_STYLE_CTA)
  self.ButtonCancel:SetText("@ui_cancel")
  self.ButtonCancel:SetCallback(self.OnCancel, self)
  self.ButtonCancel:SetButtonStyle(self.ButtonCancel.BUTTON_STYLE_DEFAULT)
  self.ButtonClose:SetCallback(self.OnCancel, self)
  self.CurrencySlider:SetCallback(self.OnCurrencySliderChanged, self)
  self.CurrencySlider:SetCurrencyDisplay(true)
  self.CurrencySlider:SetSliderStyle(self.CurrencySlider.SLIDER_STYLE_1)
  self.DepositLimit:SetButtonStyle(self.DepositLimit.BUTTON_STYLE_QUESTION_MARK)
  self.ScriptedEntityTweener:Set(self.PopupDivider.entityId, {opacity = 0.5})
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self:BusConnect(UiCanvasSizeNotificationBus, self.canvasId)
  self:OnCanvasSizeOrScaleChange(self.canvasId)
end
function Treasury_TransactionPopup:OnShutdown()
  socialDataHandler:OnDeactivate()
  self.dataLayer:UnregisterObservers(self)
end
function Treasury_TransactionPopup:OnCanvasSizeOrScaleChange(canvasId)
  if self.canvasId == canvasId then
    AdjustElementToCanvasSize(self.Properties.ScreenScrim, self.canvasId)
  end
end
function Treasury_TransactionPopup:SetTransactionPopupData(isDeposit, treasuryData)
  self.isDeposit = isDeposit
  if self.isDeposit then
    local coinCappedTooltip = GetLocalizedReplacementText("@ui_coin_max_deposit_tooltip", {
      amount = GetLocalizedCurrency(self.treasuryWalletCap)
    })
    self.DepositLimit:SetTooltip(coinCappedTooltip)
    self.ButtonAccept:SetText("@ui_trade_send_title")
    self.FrameHeader:SetText("@ui_treasury_deposit")
    UiTextBus.Event.SetTextWithFlags(self.SubHeaderLabel, "@ui_treasury_popup_tocompanytreasury", eUiTextSet_SetLocalized)
  else
    local coinCappedTooltip = GetLocalizedReplacementText("@ui_coin_max_withdrawal_tooltip", {
      amount = GetLocalizedCurrency(self.playerWalletCap)
    })
    self.DepositLimit:SetTooltip(coinCappedTooltip)
    self.ButtonAccept:SetText("@ui_treasury_withdraw")
    self.FrameHeader:SetText("@ui_treasury_withdrawal")
    UiTextBus.Event.SetTextWithFlags(self.SubHeaderLabel, "@ui_treasury_popup_fromcompanytreasury", eUiTextSet_SetLocalized)
  end
  self.playerCurrency = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.Amount")
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Currency.Amount", self.UpdatePlayerCurrency)
  self.CurrencySlider:SetSliderValue(0)
  self:UpdateTreasuryData(treasuryData)
  socialDataHandler:GetTreasuryData_ServerCall(self, function(self, treasuryData)
    self:UpdateTreasuryData(treasuryData)
  end, nil)
  self:SetVisibility(true)
end
function Treasury_TransactionPopup:SetVisibility(isVisible)
  if self.isVisible == isVisible then
    return
  end
  self.isVisible = isVisible
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    self.ScriptedEntityTweener:Play(self.PopupHolder, 0.8, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.ScreenScrim, 0.5, {opacity = 0}, {opacity = 0.8, ease = "QuadOut"})
    self.PopupDivider:SetVisible(true, 1.5, {delay = 0.2})
  else
    self.treasuryData = nil
    self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Currency.Amount")
    self.PopupDivider:SetVisible(false, 0.1)
    UiElementBus.Event.SetIsEnabled(self.entityId, false)
  end
end
function Treasury_TransactionPopup:IsVisible()
  return self.isVisible
end
function Treasury_TransactionPopup:IsWithdrawalPopupVisible()
  return self.isVisible and not self.isDeposit
end
function Treasury_TransactionPopup:UpdateTreasuryData(treasuryData)
  if not treasuryData then
    return
  end
  if self.treasuryData and treasuryData.currentFunds == self.treasuryData.currentFunds and treasuryData.dailyWithdrawalLimit == self.treasuryData.dailyWithdrawalLimit and treasuryData.totalWithdrawnToday == self.treasuryData.totalWithdrawnToday then
    return
  end
  self.treasuryData = treasuryData
  local unlimited = GuildsComponentBus.Broadcast.HasPrivilege(eGuildPrivilegeId_Treasury_Withdraw_Unlimited)
  self:UpdateCurrencySliderMaxQuantity(unlimited)
  local showDailyLimit = not self.isDeposit and not unlimited and treasuryData.dailyWithdrawalLimit > 0
  UiElementBus.Event.SetIsEnabled(self.DailyLimitContainer, showDailyLimit)
  if showDailyLimit then
    UiTextBus.Event.SetText(self.DailyLimitAmount, GetLocalizedCurrency(treasuryData.dailyWithdrawalLimit))
    local availableLimit = math.max(treasuryData.dailyWithdrawalLimit - treasuryData.totalWithdrawnToday, 0)
    UiTextBus.Event.SetText(self.AvailableAmount, GetLocalizedCurrency(availableLimit))
  end
end
function Treasury_TransactionPopup:UpdateCurrencySliderMaxQuantity(isGovernor)
  local remainingTreasuryCap = self.treasuryWalletCap - self.treasuryData.currentFunds
  local maxQuantity = math.min(self.playerCurrency, remainingTreasuryCap)
  if not self.isDeposit then
    if self.treasuryData.dailyWithdrawalLimit > 0 and not isGovernor then
      local availableLimit = math.max(self.treasuryData.dailyWithdrawalLimit - self.treasuryData.totalWithdrawnToday, 0)
      maxQuantity = math.min(availableLimit, self.treasuryData.currentFunds)
    else
      maxQuantity = self.treasuryData.currentFunds
    end
    local remainingPlayerCap = self.playerWalletCap - self.playerCurrency
    maxQuantity = math.min(maxQuantity, remainingPlayerCap)
  end
  self.CurrencySlider:SetSliderMaxValue(maxQuantity)
  local currentValue = math.min(self.CurrencySlider:GetSliderValue(), maxQuantity)
  self.CurrencySlider:SetSliderValue(currentValue)
end
function Treasury_TransactionPopup:UpdatePlayerCurrency(amount)
  self.playerCurrency = amount
  if self.isDeposit then
    self:UpdateCurrencySliderMaxQuantity()
  end
end
function Treasury_TransactionPopup:OnCurrencySliderChanged(slider)
  if self.treasuryData then
    local delta = self.isDeposit and slider:GetValue() or slider:GetValue() * -1
    local newBalance = self.treasuryData.currentFunds + delta
    UiTextBus.Event.SetText(self.BalanceAmount, GetLocalizedCurrency(newBalance))
  end
end
function Treasury_TransactionPopup:ShowErrorNotification(message)
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = message
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function Treasury_TransactionPopup:OnAccept()
  if not self.isVisible then
    return
  end
  local currencyAmount = self.CurrencySlider:GetSliderValue()
  if currencyAmount == 0 then
    self:ShowErrorNotification("@ui_treasury_popup_invalidamount")
    return
  end
  if self.isDeposit then
    GuildsComponentBus.Broadcast.RequestDepositGuildTreasuryFunds(currencyAmount)
  else
    GuildsComponentBus.Broadcast.RequestWithdrawGuildTreasuryFunds(currencyAmount)
  end
  self:SetVisibility(false)
end
function Treasury_TransactionPopup:OnCancel()
  if not self.isVisible then
    return
  end
  self:SetVisibility(false)
end
return Treasury_TransactionPopup
