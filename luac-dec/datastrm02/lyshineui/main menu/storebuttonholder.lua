local EntitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
local OmniDataHandler = RequireScript("LyShineUI._Common.OmniDataHandler")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local StoreButtonHolder = {
  Properties = {
    FeaturedProductButton = {
      default = EntityId()
    },
    ButtonTooltipSetter = {
      default = EntityId()
    },
    SteamStoreButton = {
      default = EntityId()
    },
    ViewArtButton = {
      default = EntityId()
    },
    BalanceText = {
      default = EntityId()
    },
    MarksOfFortuneIcon = {
      default = EntityId()
    },
    NoFeaturedButton = {
      default = EntityId()
    }
  },
  enableBalanceText = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
BaseElement:CreateNewElement(StoreButtonHolder)
function StoreButtonHolder:OnInit()
  BaseElement.OnInit(self)
  self.isInGame = false
  self.isVisible = false
  self.enableEntitlements = false
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableEntitlements", function(self, enable)
    enable = enable and ConfigProviderEventBus.Broadcast.GetBool("javelin.use-omni-entitlements")
    self.enableEntitlements = enable
    if self.Properties.SteamStoreButton:IsValid() then
      self.SteamStoreButton:SetText("@ui_browse_shop")
      self.SteamStoreButton:SetTextAlignment(self.SteamStoreButton.TEXT_ALIGN_LEFT)
      self.SteamStoreButton:SetSoundOnFocus(self.audioHelper.OnHover_EscapeMenu)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.SteamStoreButton, enable)
    if self.Properties.ViewArtButton:IsValid() then
      self.ViewArtButton:SetText("@ui_artbook")
      self.ViewArtButton:SetTextAlignment(self.ViewArtButton.TEXT_ALIGN_LEFT)
      self.ViewArtButton:SetSoundOnFocus(self.audioHelper.OnHover_EscapeMenu)
      UiElementBus.Event.SetIsEnabled(self.Properties.ViewArtButton, false)
    end
    if not enable then
      return
    end
    self:BusConnect(EntitlementNotificationBus)
    if self.Properties.SteamStoreButton:IsValid() then
      self.SteamStoreButton:SetCallback(function(self)
        DynamicBus.StoreScreenBus.Broadcast.InvokeStoreFromButton("escape_menu")
      end, self)
    end
  end)
end
function StoreButtonHolder:OnShutdown()
end
function StoreButtonHolder:OnFeaturedProductClick(featuredProductElement)
  DynamicBus.StoreScreenBus.Broadcast.InvokeStoreWithOffer(featuredProductElement.storeProductData.offer)
end
function StoreButtonHolder:OnOfferExpired(featuredProductElement)
  self:UpdateButtons()
end
function StoreButtonHolder:OnCatalogReceived(offers)
  if self:ValidFeaturedProduct() then
    self.FeaturedProductButton:SetSpinnerShowing(false)
  end
  if 0 < #offers then
    UiElementBus.Event.SetIsEnabled(self.Properties.FeaturedProductButton, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.NoFeaturedButton, false)
    local product = offers[1]
    product.context = self
    product.cb = self.OnFeaturedProductClick
    product.offerExpiredCb = self.OnOfferExpired
    product.isUnlocked = false
    product.canUnlock = true
    product.showPrice = true
    self.FeaturedProductButton:SetStoreProductData(product, "EscapeMenu")
    local buttonWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.FeaturedProductButton)
    self.FeaturedProductButton:StyleFeaturedElementByType(buttonWidth, "EscapeMenu")
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.FeaturedProductButton, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.NoFeaturedButton, true)
  end
end
function StoreButtonHolder:OnEntitlementsChange()
  if self.isVisible then
    self:UpdateButtons()
    return
  end
end
function StoreButtonHolder:SetInGame(isInGame)
  self.isInGame = isInGame
end
function StoreButtonHolder:OnSetVisible(isVisible)
  self.isVisible = isVisible
  if isVisible then
    self:UpdateButtons()
  end
end
function StoreButtonHolder:SetIsHandlingEvents(isHandlingEvents)
  local tooltip = ""
  if not isHandlingEvents then
    if FtueSystemRequestBus.Broadcast.IsFtue() then
      tooltip = "@ftue_action_unavailable"
    else
      tooltip = "@ui_button_disabled_dead"
    end
  end
  if self.Properties.FeaturedProductButton:IsValid() then
    self.FeaturedProductButton:SetTooltip(tooltip)
    self.FeaturedProductButton:SetIsEnabled(isHandlingEvents)
    local fadeValue = isHandlingEvents and 1 or 0.5
    UiFaderBus.Event.SetFadeValue(self.Properties.FeaturedProductButton, fadeValue)
  end
  if self.Properties.SteamStoreButton:IsValid() then
    self.SteamStoreButton:SetTooltip(tooltip)
    self.SteamStoreButton:SetEnabled(isHandlingEvents)
  end
  if self.Properties.ViewArtButton:IsValid() then
    UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ViewArtButton, isHandlingEvents)
  end
end
function StoreButtonHolder:UpdateButtons()
  if self:ValidFeaturedProduct() then
    self.FeaturedProductButton:SetSpinnerShowing(true)
  end
  OmniDataHandler:GetOmniOffersByFilter(eStoreTabFeaturedDeals, self, self.OnCatalogReceived)
  local fictionalBalance = OmniDataHandler:GetEntitlementBalance(OmniDataHandler.FICTIONAL_CURRENCY_ENTITLEMENT_ID)
  local balanceText = GetFormattedNumber(fictionalBalance, 0)
  local hasCurrency = 0 < fictionalBalance
  if self.Properties.BalanceText:IsValid() then
    UiElementBus.Event.SetIsEnabled(self.Properties.BalanceText, self.enableBalanceText and hasCurrency)
    UiTextBus.Event.SetText(self.Properties.BalanceText, balanceText)
  end
  if self.Properties.MarksOfFortuneIcon:IsValid() then
    UiElementBus.Event.SetIsEnabled(self.Properties.MarksOfFortuneIcon, self.enableBalanceText and hasCurrency)
  end
  TimingUtils:Delay(0.25, self, function(self)
    if self.Properties.ViewArtButton:IsValid() then
      if EntitlementRequestBus.Broadcast.IsEntryIdOfRewardTypeEntitled(eRewardTypeMisc, 280235719) then
        UiElementBus.Event.SetIsEnabled(self.Properties.ViewArtButton, true)
        self.ViewArtButton:SetCallback(function(self)
          OptionsDataBus.Broadcast.OpenFolderWithArtBook()
        end, self)
      else
        UiElementBus.Event.SetIsEnabled(self.Properties.ViewArtButton, false)
      end
    end
  end)
end
function StoreButtonHolder:ValidFeaturedProduct()
  if self.Properties.FeaturedProductButton:IsValid() and self.FeaturedProductButton and type(self.FeaturedProductButton) == "table" and self.FeaturedProductButton.SetSpinnerShowing then
    return true
  end
  return false
end
function StoreButtonHolder:OnHoverNoFeaturedButton()
  local hover = UiElementBus.Event.FindChildByName(self.Properties.NoFeaturedButton, "Hover")
  self.ScriptedEntityTweener:Play(hover, 0.15, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
end
function StoreButtonHolder:OnUnhoverNoFeaturedButton()
  local hover = UiElementBus.Event.FindChildByName(self.Properties.NoFeaturedButton, "Hover")
  self.ScriptedEntityTweener:Play(hover, 0.15, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
end
function StoreButtonHolder:OnPressNoFeaturedButton()
  DynamicBus.StoreScreenBus.Broadcast.InvokeStoreFromButton("equipment_screen")
end
return StoreButtonHolder
