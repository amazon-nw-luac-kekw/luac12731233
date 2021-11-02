local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local OmniDataHandler = RequireScript("LyShineUI._Common.OmniDataHandler")
local EntitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
local FictionalCurrencyPopup = {
  Properties = {
    ContextMessage = {
      default = EntityId()
    },
    ProductsList = {
      default = EntityId()
    },
    CloseButton = {
      default = EntityId()
    },
    FrameHeader = {
      default = EntityId()
    },
    CancelButton = {
      default = EntityId()
    },
    PopupBackground = {
      default = EntityId()
    },
    MasterContainer = {
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
  },
  SUGGESTED_ITEM_HEIGHT_ADJUST = 50
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FictionalCurrencyPopup)
function FictionalCurrencyPopup:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.Properties.ContextMessage, self.UIStyle.FONT_STYLE_STORE_CONTEXT_TEXT)
  SetTextStyle(self.Properties.CurrentBalanceTextLabel, self.UIStyle.FONT_STYLE_STORE_POPUP_NEW_BALANCE_LABEL)
  SetTextStyle(self.Properties.CurrentBalance, self.UIStyle.FONT_STYLE_STORE_POPUP_NEW_BALANCE)
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  self.CloseButton:SetCallback(self.OnCloseButton, self)
  self.FrameHeader:SetText("@ui_marks_of_fortune")
  self.FrameHeader:SetTextAlignment(self.FrameHeader.TEXT_ALIGN_CENTER)
  self.CancelButton:SetCallback(self.OnCloseButton, self)
  self.CancelButton:SetButtonStyle(self.CancelButton.BUTTON_STYLE_CTA)
  self.CancelButton:SetText("@ui_cancel")
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.AccountLocked", function(self, locked)
    self.accountLocked = locked
  end)
  self.originalContainerHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.MasterContainer)
end
function FictionalCurrencyPopup:OnShutdown()
end
function FictionalCurrencyPopup:Invoke(originProductOffer, context, offerClickedCallback)
  local creditBalance = OmniDataHandler:GetEntitlementBalance(OmniDataHandler.FICTIONAL_CURRENCY_ENTITLEMENT_ID)
  UiTextBus.Event.SetTextWithFlags(self.Properties.CurrentBalance, GetFormattedNumber(creditBalance, 0), eUiTextSet_SetAsIs)
  local currentIconWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.CurrentBalanceIcon)
  local currentBalanceTextWidth = UiTextBus.Event.GetTextSize(self.Properties.CurrentBalance).x
  local currentLabelTextWidth = UiTextBus.Event.GetTextSize(self.Properties.CurrentBalanceTextLabel).x
  local spacing = 12
  local totalWidth = currentIconWidth + currentBalanceTextWidth + currentLabelTextWidth + spacing - 2
  UiTransformBus.Event.SetLocalPositionX(self.Properties.CurrentBalanceIcon, totalWidth / 2)
  self.neededCurrency = 0
  if originProductOffer then
    self.neededCurrency = originProductOffer.offer:GetActualPrice() - creditBalance
    UiElementBus.Event.SetIsEnabled(self.Properties.ContextMessage, true)
    UiTextBus.Event.SetTextWithFlags(self.Properties.ContextMessage, GetLocalizedReplacementText("@ui_credit_purchase_suggest", {
      amount = GetLocalizedNumber(self.neededCurrency),
      product = originProductOffer.offer.productData.displayName
    }), eUiTextSet_SetAsIs)
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.MasterContainer, self.originalContainerHeight + self.SUGGESTED_ITEM_HEIGHT_ADJUST)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.ContextMessage, false)
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.MasterContainer, self.originalContainerHeight)
  end
  self.context = context
  self.offerClickedCallback = offerClickedCallback
  UiDynamicLayoutBus.Event.SetNumChildElements(self.Properties.ProductsList, 1)
  local blankStoreProduct = self.registrar:GetEntityTable(UiElementBus.Event.GetChild(self.Properties.ProductsList, 0))
  blankStoreProduct:SetSpinnerShowing(true)
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.3, {opacity = 0, y = -10}, {
    opacity = 1,
    y = 0,
    ease = "QuadOut",
    delay = 0.2
  })
end
function FictionalCurrencyPopup:OnCloseButton()
  self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.25, {opacity = 1}, {
    opacity = 0,
    ease = "QuadOut",
    delay = 0.1,
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.entityId, false)
    end
  })
  self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.2, {opacity = 1, y = 0}, {
    opacity = 0,
    y = -10,
    ease = "QuadOut"
  })
end
function FictionalCurrencyPopup:OnOffersReceived(offers)
  UiDynamicLayoutBus.Event.SetNumChildElements(self.Properties.ProductsList, #offers)
  local suggestedOfferElement, minAmount
  table.sort(offers, function(a, b)
    return a.offer:GetActualPrice() < b.offer:GetActualPrice()
  end)
  for i, offer in ipairs(offers) do
    offer.context = self
    offer.cb = self.OnOfferClick
    offer.showPrice = true
    local storeProductElement = self.registrar:GetEntityTable(UiElementBus.Event.GetChild(self.Properties.ProductsList, i - 1))
    if self.neededCurrency > 0 then
      local rewards = EntitlementsDataHandler:GetRewardsForOffer(offer.offer)
      for _, reward in ipairs(rewards) do
        if reward.rewardType == eRewardTypeFictionalCurrency and reward.amount >= self.neededCurrency then
          if suggestedOfferElement then
            if minAmount > reward.amount then
              suggestedOfferElement = storeProductElement
              minAmount = reward.amount
            end
          else
            suggestedOfferElement = storeProductElement
            minAmount = reward.amount
          end
        end
      end
    end
    storeProductElement:ShowSuggestedOfferIndicator(false)
    storeProductElement:SetSpinnerShowing(false)
    storeProductElement:SetStoreProductData(offer, "Portrait")
    storeProductElement:StyleFeaturedElementByType(nil, "Portrait")
  end
  if suggestedOfferElement then
    suggestedOfferElement:ShowSuggestedOfferIndicator(true)
  end
end
function FictionalCurrencyPopup:OnOfferClick(productElement)
  if self.accountLocked then
    UiPopupBus.Broadcast.ShowPopup(ePopupButtons_OK, "@ui_locked_account_title", "@ui_locked_account_description", "AccountLockedPopup")
    return
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  self.offerClickedCallback(self.context, productElement)
end
return FictionalCurrencyPopup
