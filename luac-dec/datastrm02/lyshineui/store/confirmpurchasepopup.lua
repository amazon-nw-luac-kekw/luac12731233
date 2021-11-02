local EntitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
local OmniDataHandler = RequireScript("LyShineUI._Common.OmniDataHandler")
local ConfirmPurchasePopup = {
  Properties = {
    StoreProductElement = {
      default = EntityId()
    },
    Balance = {
      default = EntityId()
    },
    CancelButton = {
      default = EntityId()
    },
    ConfirmButton = {
      default = EntityId()
    },
    FrameHeader = {
      default = EntityId()
    },
    CloseButton = {
      default = EntityId()
    },
    PopupBackground = {
      default = EntityId()
    },
    MasterContainer = {
      default = EntityId()
    },
    NewBalanceTextLabel = {
      default = EntityId()
    },
    CurrencyIcon = {
      default = EntityId()
    },
    InitialPrice = {
      default = EntityId()
    },
    CurrencyIconInitialPrice = {
      default = EntityId()
    },
    InitialPriceSingle = {
      default = EntityId()
    },
    RefundText = {
      default = EntityId()
    },
    DisclaimerText = {
      default = EntityId()
    },
    ButtonsContainer = {
      default = EntityId()
    },
    RewardsList = {
      default = EntityId()
    },
    RewardPrototype = {
      default = EntityId()
    },
    CurrentBalance = {
      default = EntityId()
    },
    CurrentBalanceTextLabel = {
      default = EntityId()
    },
    CurrentBalanceIcon = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ConfirmPurchasePopup)
function ConfirmPurchasePopup:OnInit()
  BaseElement.OnInit(self)
  self.CancelButton:SetCallback(self.OnCancel, self)
  self.CancelButton:SetButtonStyle(self.CancelButton.BUTTON_STYLE_DEFAULT)
  self.CancelButton:SetText("@ui_cancel")
  self.ConfirmButton:SetButtonStyle(self.ConfirmButton.BUTTON_STYLE_CTA)
  self.ConfirmButton:SetEnabled(true)
  self.ConfirmButton:SetCallback(self.OnConfirm, self)
  self.FrameHeader:SetText("@ui_confirm_purchase")
  self.FrameHeader:SetTextAlignment(self.FrameHeader.TEXT_ALIGN_CENTER)
  self.CloseButton:SetCallback(self.OnCancel, self)
  SetTextStyle(self.Properties.NewBalanceTextLabel, self.UIStyle.FONT_STYLE_STORE_POPUP_NEW_BALANCE_LABEL)
  SetTextStyle(self.Properties.CurrentBalanceTextLabel, self.UIStyle.FONT_STYLE_STORE_POPUP_NEW_BALANCE_LABEL)
  SetTextStyle(self.Properties.Balance, self.UIStyle.FONT_STYLE_STORE_POPUP_NEW_BALANCE)
  SetTextStyle(self.Properties.CurrentBalance, self.UIStyle.FONT_STYLE_STORE_POPUP_NEW_BALANCE)
  SetTextStyle(self.Properties.RefundText, self.UIStyle.FONT_STYLE_STORE_REFUND_TEXT)
  SetTextStyle(self.Properties.DisclaimerText, self.UIStyle.FONT_STYLE_STORE_DISCLAIMER_TEXT)
  self.RewardsList:Initialize(self.RewardPrototype)
  self.RewardsList:OnListDataSet(nil)
end
function ConfirmPurchasePopup:OnShutdown()
end
function ConfirmPurchasePopup:OnConfirm()
  if self.confirmPushed then
    return
  end
  self.confirmPushed = true
  self.onConfirmCallback(self.context, self.StoreProductElement.storeProductData)
  self.CancelButton:SetEnabled(false)
end
function ConfirmPurchasePopup:Invoke(storeProductData, balance, context, onConfirmCallback, onCancelCallback)
  self.StoreProductElement:SetStoreProductData(storeProductData, "Popup")
  self.StoreProductElement:StyleFeaturedElementByType(nil, "Popup")
  self.confirmPushed = false
  local fictionalBalance = OmniDataHandler:GetEntitlementBalance(OmniDataHandler.FICTIONAL_CURRENCY_ENTITLEMENT_ID)
  UiTextBus.Event.SetTextWithFlags(self.Properties.CurrentBalance, GetFormattedNumber(fictionalBalance, 0), eUiTextSet_SetAsIs)
  local currentIconWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.CurrentBalanceIcon)
  local currentBalanceTextWidth = UiTextBus.Event.GetTextSize(self.Properties.CurrentBalance).x
  local currentLabelTextWidth = UiTextBus.Event.GetTextSize(self.Properties.CurrentBalanceTextLabel).x
  local spacing = 12
  local totalWidth = currentIconWidth + currentBalanceTextWidth + currentLabelTextWidth + spacing - 2
  UiTransformBus.Event.SetLocalPositionX(self.Properties.CurrentBalanceIcon, totalWidth / 2)
  local final = ""
  local original = ""
  local newBalance = balance - storeProductData.offer:GetActualPrice()
  UiTextBus.Event.SetTextWithFlags(self.Properties.Balance, GetLocalizedNumber(newBalance), eUiTextSet_SetLocalized)
  if storeProductData.offer.isFictional then
    final = GetLocalizedNumber(storeProductData.offer:GetActualPrice())
    original = GetLocalizedNumber(storeProductData.offer.originalPrice)
  else
    final = GetLocalizedRealWorldCurrency(storeProductData.offer:GetActualPrice(), storeProductData.offer.currencyCode)
    original = GetLocalizedRealWorldCurrency(storeProductData.offer.originalPrice, storeProductData.offer.currencyCode)
  end
  local buttonText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_unlock_for", final)
  self.ConfirmButton:SetText(buttonText)
  self.context = context
  self.onConfirmCallback = onConfirmCallback
  self.onCancelCallback = onCancelCallback
  local currencyIconWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.CurrencyIcon)
  local balanceTextWidth = UiTextBus.Event.GetTextSize(self.Properties.Balance).x
  local labelTextWidth = UiTextBus.Event.GetTextSize(self.Properties.NewBalanceTextLabel).x
  local totalWidth = currencyIconWidth + balanceTextWidth + labelTextWidth + spacing - 2
  UiTransformBus.Event.SetLocalPositionX(self.Properties.CurrencyIcon, totalWidth / 2)
  local rewards = EntitlementsDataHandler:GetRewardsForOffer(storeProductData.offer)
  local productType = EntitlementsDataHandler:GetProductTypeText(rewards)
  self.rewards = {}
  local singleReward = #rewards == 1 and true or false
  local hasCrestReward = false
  for i, reward in ipairs(rewards) do
    table.insert(self.rewards, {
      rewardInfo = reward,
      cbContext = self,
      cb = self.OnRewardClick,
      cbHoverBegin = self.OnRewardHoverBegin,
      cbHoverEnd = self.OnRewardHoverEnd,
      isSingleReward = singleReward
    })
    if rewards[i].rewardType == eRewardTypeGuildBackgroundColor or rewards[i].rewardType == eRewardTypeGuildCrest or rewards[i].rewardType == eRewardTypeGuildForegroundColor then
      hasCrestReward = true
    end
  end
  if #rewards == 1 then
    self.RewardsList:OnListDataSet(self.rewards)
    UiElementBus.Event.SetIsEnabled(self.Properties.RewardsList, true)
    if final == original then
      UiElementBus.Event.SetIsEnabled(self.Properties.InitialPriceSingle, false)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.InitialPriceSingle, true)
      UiTextBus.Event.SetText(self.Properties.InitialPriceSingle, original)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.CurrencyIconInitialPrice, false)
    if hasCrestReward then
      UiTransform2dBus.Event.SetLocalHeight(self.Properties.MasterContainer, 500)
      UiElementBus.Event.SetIsEnabled(self.Properties.DisclaimerText, true)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.ButtonsContainer, -90)
    else
      UiTransform2dBus.Event.SetLocalHeight(self.Properties.MasterContainer, 440)
      UiElementBus.Event.SetIsEnabled(self.Properties.DisclaimerText, false)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.ButtonsContainer, -60)
    end
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.RewardsList, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.InitialPriceSingle, false)
    if hasCrestReward then
      UiTransform2dBus.Event.SetLocalHeight(self.Properties.MasterContainer, 560)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.ButtonsContainer, -60)
      UiElementBus.Event.SetIsEnabled(self.Properties.DisclaimerText, true)
    else
      UiTransform2dBus.Event.SetLocalHeight(self.Properties.MasterContainer, 500)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.ButtonsContainer, -30)
      UiElementBus.Event.SetIsEnabled(self.Properties.DisclaimerText, false)
    end
    if final == original then
      UiElementBus.Event.SetIsEnabled(self.Properties.CurrencyIconInitialPrice, false)
    else
      UiTextBus.Event.SetText(self.Properties.InitialPrice, original)
      local currencyIconInitialPriceWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.CurrencyIconInitialPrice)
      local initialPriceTextWidth = UiTextBus.Event.GetTextSize(self.Properties.InitialPrice).x
      local spacing = 4
      local initialPriceTotalWidth = currencyIconInitialPriceWidth + initialPriceTextWidth + spacing - 2
      UiTransformBus.Event.SetLocalPositionX(self.Properties.CurrencyIconInitialPrice, initialPriceTotalWidth / 2)
      UiElementBus.Event.SetIsEnabled(self.Properties.CurrencyIconInitialPrice, true)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.InitialPriceSingle, false)
  end
  self:SetIsEnabled(true)
end
function ConfirmPurchasePopup:IsEnabled()
  return UiElementBus.Event.IsEnabled(self.entityId)
end
function ConfirmPurchasePopup:SetIsEnabled(isEnabled)
  if not isEnabled then
  end
  if self:IsEnabled() == isEnabled then
    return
  end
  if isEnabled then
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    self.ConfirmButton:SetEnabled(true)
    self.CancelButton:SetEnabled(true)
    self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.3, {opacity = 0, y = -10}, {
      opacity = 1,
      y = 0,
      ease = "QuadOut",
      delay = 0.2
    })
  else
    if self.context and type(self.onCancelCallback) == "function" then
      self.onCancelCallback(self.context)
    end
    self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.15, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.1, {opacity = 1, y = 0}, {
      opacity = 0,
      y = -10,
      ease = "QuadOut",
      delay = 0.15,
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.entityId, false)
      end
    })
  end
end
function ConfirmPurchasePopup:OnCancel()
  self.ConfirmButton:SetEnabled(false)
  self:SetIsEnabled(false)
end
return ConfirmPurchasePopup
