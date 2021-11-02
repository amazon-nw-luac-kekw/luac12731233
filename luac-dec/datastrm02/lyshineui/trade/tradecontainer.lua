local TradeContainer = {
  Properties = {
    FrameHeader = {
      default = EntityId(),
      order = 1
    },
    ItemCount = {
      default = EntityId(),
      order = 2
    },
    ItemContainer = {
      default = EntityId(),
      order = 3
    },
    CurrencyInput = {
      default = EntityId(),
      order = 4
    },
    CurrencyConfirmButton = {
      default = EntityId(),
      order = 5
    },
    TradeStatus = {
      default = EntityId(),
      order = 6
    },
    Frame = {
      default = EntityId(),
      order = 7
    },
    Highlight = {
      default = EntityId(),
      order = 8
    },
    EmptyContainerText = {
      default = EntityId(),
      order = 9
    },
    MaxCoinWarning = {
      default = EntityId(),
      order = 10
    },
    CurrencyText = {
      default = EntityId(),
      order = 11
    }
  },
  isReceiving = false,
  coinAmount = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TradeContainer)
function TradeContainer:OnInit()
  BaseElement.OnInit(self)
  self.playerWalletCap = ConfigProviderEventBus.Broadcast.GetUInt64("javelin.wallet-cap-player")
  local coinCappedTooltip = GetLocalizedReplacementText("@ui_coin_max_trade_tooltip", {
    amount = GetLocalizedCurrency(self.playerWalletCap)
  })
  self.MaxCoinWarning:SetSimpleTooltip(coinCappedTooltip)
  self.CurrencyInput:SetCallback(self, self.OnCurrencyChanged)
  self.CurrencyInput:SetOnChangeCallback(self, self.OnCurrencyChanged)
  self.CurrencyInput:SetInputValue(GetLocalizedCurrency(self.coinAmount))
  self.CurrencyConfirmButton:SetText("@ui_trade_confirm_currency")
  self.CurrencyConfirmButton:SetCallback(self.OnConfirmCurrencyButton, self)
  UiElementBus.Event.SetIsEnabled(self.Properties.CurrencyConfirmButton, false)
  self.FrameHeader:SetBgAlpha(0.6)
  SetTextStyle(self.Properties.ItemCount, self.UIStyle.FONT_STYLE_P2P_ITEM_COUNT)
  SetTextStyle(self.Properties.TradeStatus, self.UIStyle.FONT_STYLE_P2P_ITEM_STATUS)
  SetTextStyle(self.Properties.EmptyContainerText, self.UIStyle.FONT_STYLE_EMPTY_CONTAINER_TEXT)
  self:SetItemCount(0, 5)
end
function TradeContainer:SetTradeStatus(isLockedIn, isConfirmed)
  local locString
  local color = self.UIStyle.COLOR_GRAY_60
  local opacity = 0
  local duration = 0
  if isConfirmed then
    locString = "@ui_trade_status_confirmed"
    color = self.UIStyle.COLOR_GREEN
    opacity = 1
  elseif isLockedIn then
    locString = "@ui_trade_status_locked_in"
    self.ScriptedEntityTweener:Play(self.Properties.TradeStatus, 0.3, {opacity = 1, ease = "QuadOut"})
    color = self.UIStyle.COLOR_WHITE
    opacity = 1
  end
  if locString then
    UiTextBus.Event.SetTextWithFlags(self.Properties.TradeStatus, locString, eUiTextSet_SetLocalized)
  end
  UiTextBus.Event.SetColor(self.Properties.TradeStatus, color)
  self.ScriptedEntityTweener:Play(self.Properties.TradeStatus, 0.3, {opacity = opacity, ease = "QuadOut"})
  if isConfirmed then
    self:SetEmptyContainerTextVisible(false)
  end
  self:SetHighlight(isLockedIn, isConfirmed)
end
function TradeContainer:SetItemCount(count, total)
  local color = 0 < count and self.UIStyle.COLOR_WHITE or self.UIStyle.COLOR_GRAY_80
  local countText = GetLocalizedReplacementText("@ui_trade_item_count", {
    color = ColorRgbaToHexString(color),
    count = count,
    total = total
  })
  UiTextBus.Event.SetTextWithFlags(self.Properties.ItemCount, countText, eUiTextSet_SetAsIs)
end
function TradeContainer:SetIsReceiving(isReceiving)
  self.isReceiving = isReceiving
  self.CurrencyInput:SetIsInteractable(not isReceiving)
end
function TradeContainer:SetCurrencyAmount(amount)
  self.coinAmount = amount
  local showWarning = false
  if self.isReceiving then
    local playerWalletAmount = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.Amount")
    if self.coinAmount + playerWalletAmount > self.playerWalletCap then
      self.coinAmount = self.playerWalletCap - playerWalletAmount
      showWarning = true
    end
  end
  if not self.isEditing then
    self.CurrencyInput:SetInputValue(GetLocalizedCurrency(self.coinAmount))
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.MaxCoinWarning, showWarning)
  UiTextBus.Event.SetColor(self.Properties.CurrencyText, showWarning and self.UIStyle.COLOR_GREEN_BRIGHT or self.UIStyle.COLOR_GRAY_80)
end
function TradeContainer:SetEmptyContainerTextVisible(isVisible)
  local duration = isVisible and 0.3 or 0
  self.ScriptedEntityTweener:Play(self.Properties.EmptyContainerText, duration, {
    opacity = isVisible and 1 or 0
  })
end
function TradeContainer:OnCurrencyChanged(input, enterPressed)
  if self.isReceiving then
    return
  end
  local amount = GetCurrencyValueFromLocalized(input)
  self.isEditing = amount and amount ~= self.coinAmount
  UiElementBus.Event.SetIsEnabled(self.Properties.CurrencyConfirmButton, self.isEditing)
  if self.isEditing and enterPressed then
    self:OnConfirmCurrencyButton()
  end
end
function TradeContainer:OnConfirmCurrencyButton()
  self.isEditing = false
  UiElementBus.Event.SetIsEnabled(self.Properties.CurrencyConfirmButton, false)
  local amount = GetCurrencyValueFromLocalized(self.CurrencyInput:GetInputValue())
  if type(amount) ~= "number" then
    amount = 0
  end
  if amount then
    local max = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.Amount")
    self.coinAmount = Math.Clamp(amount, 0, max)
    self.CurrencyInput:SetInputValue(GetLocalizedCurrency(self.coinAmount))
    P2PTradeComponentRequestBus.Broadcast.UpdateOfferedCoin(self.coinAmount)
    self.audioHelper:PlaySound(self.audioHelper.Treasury_Deposit)
  end
end
function TradeContainer:SetHighlight(isVisible, isConfirmed)
  local color = isConfirmed and self.UIStyle.COLOR_GREEN or self.UIStyle.COLOR_WHITE
  local opacity = isVisible and 1 or 0
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, 1, {
    opacity = opacity,
    imgColor = color,
    ease = "QuadOut"
  })
end
function TradeContainer:SetFrameVisible(isVisible, duration)
  self.Frame:SetLineVisible(isVisible, duration)
  self.Frame:SetFrameTextureVisible(false)
  self.Frame:SetFillAlpha(0)
  self.Frame:SetLineColor(self.UIStyle.COLOR_TAN)
end
return TradeContainer
