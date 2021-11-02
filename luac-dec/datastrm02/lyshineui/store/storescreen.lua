local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local OmniDataHandler = RequireScript("LyShineUI._Common.OmniDataHandler")
local EntitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local TimeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local StoreScreen = {
  Properties = {
    ActionMapActivator = {
      default = "toggleStoreScreen"
    },
    MasterContainer = {
      default = EntityId()
    },
    AddFictionalCurrencyButton = {
      default = EntityId()
    },
    AddFictionalCurrencyButtonPopup = {
      default = EntityId()
    },
    StorePage = {
      default = EntityId()
    },
    ItemSearchInput = {
      default = EntityId()
    },
    ListContentsTitle = {
      default = EntityId()
    },
    FeaturedDealsPane = {
      default = EntityId()
    },
    GenericItemsPane = {
      default = EntityId()
    },
    GenericItemsGrid = {
      default = EntityId()
    },
    StoreGridItemPrototype = {
      default = EntityId()
    },
    Layouts = {
      default = EntityId()
    },
    FeaturedStoreItem1 = {
      default = EntityId()
    },
    FeaturedStoreItem2 = {
      default = EntityId()
    },
    FeaturedStoreItem3 = {
      default = EntityId()
    },
    FeaturedStoreItem4 = {
      default = EntityId()
    },
    FeaturedStoreItem5 = {
      default = EntityId()
    },
    FeaturedStoreItem6 = {
      default = EntityId()
    },
    FeaturedStoreItem7 = {
      default = EntityId()
    },
    FeaturedStoreItem8 = {
      default = EntityId()
    },
    FictionalCurrencyPopup = {
      default = EntityId()
    },
    StoreProductPopup = {
      default = EntityId()
    },
    ConfirmPurchasePopup = {
      default = EntityId()
    },
    TransactionStatusPopup = {
      default = EntityId()
    },
    ProductRewardsTooltip = {
      default = EntityId()
    },
    PurchaseCelebrationPopup = {
      default = EntityId()
    },
    WorldTransferPopup = {
      default = EntityId()
    },
    StoreBackground = {
      default = EntityId()
    },
    ScreenDarkener = {
      default = EntityId()
    },
    OrderHistoryButton = {
      default = EntityId()
    },
    AddFictionalCurrencyButtonBig = {
      default = EntityId()
    },
    FeaturedTitle = {
      default = EntityId()
    },
    MenuHolder = {
      default = EntityId()
    },
    ShowPurchasedCheckbox = {
      default = EntityId()
    },
    SearchText = {
      default = EntityId()
    },
    SortDropdown = {
      default = EntityId()
    },
    OrderHistoryPopup = {
      default = EntityId()
    }
  },
  storeScreenName = "Store",
  onLeavePopupEventId = "Popup_OnLeave",
  onForcedRenamePopupEventId = "Popup_OnForcedRename",
  primaryScreenTransitionOutTime = 0.1,
  primaryScreenTransitionInTime = 0.2,
  storePageTransitionOutTime = 0.1,
  storePageTransitionInTime = 0.2,
  currentPrimaryTabId = nil,
  currentPrimaryScreen = nil,
  LAYOUT_AREA_WIDTH = 1170,
  LAYOUT_AREA_HEIGHT = 678,
  SORT_BY_RELEASE_DATE = 1,
  SORT_BY_NAME = 2,
  SORT_BY_PRICE = 3,
  SERVER_TRANSFER_PENDING = 1,
  OMNI_TIMEOUT_SECONDS = 15,
  showEntitlementsNotification = false,
  loadingSpinnerOpacity = 0.7
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(StoreScreen)
function StoreScreen:OnInit()
  BaseScreen.OnInit(self)
  self.storeScreenBusHandler = DynamicBus.StoreScreenBus.Connect(self.entityId, self)
  self.dataLayer:RegisterOpenEvent(self.storeScreenName, self.canvasId)
  self:BusConnect(CryActionNotificationsBus, self.ActionMapActivator)
  self.sortBy = self.SORT_BY_RELEASE_DATE
  self.timeHelpers = timeHelpers
  self.showPurchased = true
  self.storeTab = 1
  self.expectedPurchases = {}
  self.MenuButtonData = {
    {
      text = "@ui_featureddeals",
      callback = self.SetSelectedScreenVisible
    },
    {
      text = "@ui_consumables",
      callback = self.SetSelectedScreenVisible
    },
    {
      text = "@ui_emotes",
      callback = self.SetSelectedScreenVisible
    },
    {
      text = "@ui_armorskins",
      callback = self.SetSelectedScreenVisible
    },
    {
      text = "@ui_weaponskins",
      callback = self.SetSelectedScreenVisible
    },
    {
      text = "@ui_housingitems",
      callback = self.SetSelectedScreenVisible
    },
    {
      text = "@ui_guildcrestcolors",
      callback = self.SetSelectedScreenVisible
    },
    {
      text = "@ui_bundles",
      callback = self.SetSelectedScreenVisible
    },
    {
      text = "@ui_world_transfer_mtx",
      callback = self.SetSelectedScreenVisible
    }
  }
  self.MenuHolder:SetListData(self.MenuButtonData, self)
  self.featuredDealsElements = {
    self.FeaturedStoreItem1,
    self.FeaturedStoreItem2,
    self.FeaturedStoreItem3,
    self.FeaturedStoreItem4,
    self.FeaturedStoreItem5,
    self.FeaturedStoreItem6,
    self.FeaturedStoreItem7,
    self.FeaturedStoreItem8
  }
  self.GenericItemsGrid:Initialize(self.StoreGridItemPrototype)
  self.AddFictionalCurrencyButtonBig:SetCallback(self.OnAddFictionalCurrency, self)
  self.AddFictionalCurrencyButton:SetCallback(self.OnAddFictionalCurrency, self)
  self.AddFictionalCurrencyButtonPopup:SetCallback(self.OnAddFictionalCurrency, self)
  self.AddFictionalCurrencyButtonBig:SetTextStyle(self.UIStyle.FONT_STYLE_STORE_ADD_BUTTON)
  self.AddFictionalCurrencyButtonBig:SetText("@ui_add_more_fictional_currency")
  self.AddFictionalCurrencyButtonBig:SetIsMarkupEnabled(true)
  self.AddFictionalCurrencyButtonBig:SetTextAlignment(self.AddFictionalCurrencyButtonBig.TEXT_ALIGN_LEFT)
  self.AddFictionalCurrencyButtonBig:SetBackgroundColor(self.UIStyle.COLOR_BUTTON_SIMPLE_CTA)
  self.AddFictionalCurrencyButtonBig:SetBackgroundOpacity(self.UIStyle.BUTTON_SIMPLE_CTA_OPACITY)
  self.StoreProductPopup:SetCloseCallback(self.OnStoreProductClosed, self)
  self.ItemSearchInput:SetEditChangeCallback(self.OnSearchTextChanged, self)
  self:FinalizeFeaturedLayout(1)
  self.OrderHistoryButton:SetTextStyle(self.UIStyle.FONT_STYLE_STORE_ORDER_HISTORY_BUTTON)
  self.OrderHistoryButton:SetText("@ui_orderhistory")
  self.OrderHistoryButton:SetCallback("ShowOrderHistory", self)
  self.OrderHistoryButton:SetTextAlignment(self.OrderHistoryButton.TEXT_ALIGN_LEFT)
  self.FeaturedTitle:SetTextStyle(self.UIStyle.FONT_STYLE_STORE_FEATURED_TITLE)
  self.FeaturedTitle:SetDividerColor(self.UIStyle.COLOR_GRAY_50)
  self.FeaturedTitle:SetText("@ui_featured")
  self.ListContentsTitle:SetTextStyle(self.UIStyle.FONT_STYLE_STORE_FEATURED_TITLE)
  self.ListContentsTitle:SetDividerColor(self.UIStyle.COLOR_GRAY_50)
  self.ShowPurchasedCheckbox:SetText("@ui_show_purchased")
  self.ShowPurchasedCheckbox:SetState(self.showPurchased)
  self.ShowPurchasedCheckbox:SetCallback(self, self.OnShowPurchased)
  SetTextStyle(self.Properties.SearchText, self.UIStyle.FONT_STYLE_STORE_SEARCH_TEXT)
  local dropdownData = {
    {
      text = "@ui_release_date",
      id = self.SORT_BY_RELEASE_DATE
    },
    {
      text = "@ui_name",
      id = self.SORT_BY_NAME
    },
    {
      text = "@ui_price",
      id = self.SORT_BY_PRICE
    }
  }
  self.SortDropdown:SetDropdownScreenCanvasId(self.Properties.MasterContainer)
  self.SortDropdown:SetListData(dropdownData)
  self.SortDropdown:SetDropdownListHeightByRows(math.min(4, #dropdownData))
  self.SortDropdown:SetSelectedItemData(dropdownData[1])
  self.SortDropdown:SetCallback(self.OnSortSelect, self)
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  self.enablePopupEntitlements = self.dataLayer:GetDataFromNode("UIFeatures.g_uiEnableTwitchPopupInMainMenu")
end
function StoreScreen:OnSortSelect(listItem, listItemData)
  self.sortBy = listItemData.id
  self.MenuHolder:SetSelected(self.storeTab)
end
function StoreScreen:OnShutdown()
  if self.escapeKeyHandler then
    DynamicBus.EscapeKeyNotificationBus.Disconnect(self.entityId, self)
    self.escapeKeyHandler = nil
  end
  BaseScreen.OnShutdown(self)
end
function StoreScreen:OnAction(entityId, actionName)
  BaseScreen.OnAction(self, entityId, actionName)
  if type(self[actionName]) == "function" then
    self[actionName](self, entityId, actionName)
  end
end
function StoreScreen:OnCameraPressed(entityId)
  UiInteractableBus.Event.SetStayActiveAfterRelease(entityId, true)
  UIInputRequestsBus.Broadcast.SetActionMapEnabled("camera", true)
  JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(true)
end
function StoreScreen:OnCameraReleased(entityId)
  UiInteractableBus.Event.SetStayActiveAfterRelease(entityId, false)
  JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(false)
  UIInputRequestsBus.Broadcast.SetActionMapEnabled("camera", false)
end
function StoreScreen:RegisterObservers()
end
function StoreScreen:UnregisterObservers()
end
function StoreScreen:OnShowPurchased(isChecked)
  self.showPurchased = isChecked
  self.MenuHolder:SetSelected(self.storeTab)
end
function StoreScreen:OnAddFictionalCurrency()
  self.FictionalCurrencyPopup:Invoke(nil, self, self.OnFictionalCurrencyProductClick)
  OmniDataHandler:GetRealMoneyOffers(self, self.OnRealMoneyOffersReceived)
  self.SortDropdown:Collapse()
end
function StoreScreen:OnRealMoneyOffersReceived(offers)
  self.FictionalCurrencyPopup:OnOffersReceived(offers)
end
function StoreScreen:OnSearchTextChanged(searchText)
  if string.len(searchText) > 0 then
    UiElementBus.Event.SetIsEnabled(self.Properties.FeaturedDealsPane, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.GenericItemsPane, true)
    self.ListContentsTitle:SetText("@ui_searchresult")
    self.MenuHolder:SetUnselected()
    self.GenericItemsGrid:SetSpinnerShowing(true)
    self.isSearching = true
    self.searchText = searchText
    self:RequestCatalog(searchText)
  else
    self.isSearching = false
    self.searchText = nil
    self:SetSelectedScreenVisible(self.selectedEntity)
    self.MenuHolder:SetSelected(self.storeTab)
  end
end
function StoreScreen:OnTransitionIn(fromStateName, fromLevelName, toStateName, toLevelName)
  self.isVisible = true
  local event = UiAnalyticsEvent("enter_store")
  self.sessionId = tostring(Uuid:Create())
  event:AddAttribute("origin", self.origin or "")
  event:AddAttribute("session_id", tostring(self.sessionId))
  event:AddMetric("fictional_currency_balance", OmniDataHandler:GetEntitlementBalance(OmniDataHandler.FICTIONAL_CURRENCY_ENTITLEMENT_ID))
  event:Send()
  LocalPlayerUIRequestsBus.Broadcast.SetIsInStore(true)
  self.returningToMainMenu = toStateName == 2648673335
  if self.enablePopupEntitlements and self.returningToMainMenu then
    self.SetupForTwitchPopup()
    return
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.MasterContainer, not self.autoStoreProductData)
  UiElementBus.Event.SetIsEnabled(self.Properties.StorePage, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.OrderHistoryPopup, false)
  self.MenuHolder:SetSelected(1)
  self.ItemSearchInput:ClearSearchField()
  self:OnSearchTextChanged("")
  self.closeStoreOnProductExit = self.autoStoreProductData ~= nil
  self.ScriptedEntityTweener:Play(self.Properties.MenuHolder, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.StorePage, 0.5, {opacity = 0}, {
    opacity = 1,
    ease = "QuadOut",
    onComplete = function()
      if self.autoStoreProductData then
        self.StoreProductPopup:Invoke(self.autoStoreProductData, self, self.OnPurchaseProduct, self.sessionId, self.origin)
        JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_StorePreview", 0.5)
        UiElementBus.Event.SetIsEnabled(self.Properties.MasterContainer, false)
        self.autoStoreProductData = nil
      end
    end
  })
  if not self.autoStoreProductData then
    JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
    self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
    self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
    self.targetDOFDistance = 0
    self.targetDOFBlur = 0.95
    TimingUtils:UpdateForDuration(0.5, self, function(self, currentValue)
      self:UpdateDepthOfField(currentValue)
    end)
  end
  if not self.escapeKeyHandler then
    self.escapeKeyHandler = DynamicBus.EscapeKeyNotificationBus.Connect(self.entityId, self)
  end
  self.entitlementBus = self:BusConnect(EntitlementNotificationBus)
  EntitlementRequestBus.Broadcast.SyncEntitlements()
  self:OnEntitlementsChange()
  if not self.vitalsNotification then
    local vitalsId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
    self.vitalsNotification = self:BusConnect(VitalsComponentNotificationBus, vitalsId)
  end
end
function StoreScreen:OnTransitionOut(stateName, levelName)
  self.isVisible = false
  LocalPlayerUIRequestsBus.Broadcast.SetIsInStore(false)
  local event = UiAnalyticsEvent("exit_the_store")
  event:AddAttribute("session_id", tostring(self.sessionId))
  event:AddMetric("fictional_currency_balance", OmniDataHandler:GetEntitlementBalance(OmniDataHandler.FICTIONAL_CURRENCY_ENTITLEMENT_ID))
  event:Send()
  self.sessionId = nil
  self:UnregisterObservers()
  UIInputRequestsBus.Broadcast.SetActionMapEnabled("camera", false)
  if self.StoreProductPopup:IsEnabled() then
    self.StoreProductPopup:SetIsEnabled(false)
  end
  if self.escapeKeyHandler then
    DynamicBus.EscapeKeyNotificationBus.Disconnect(self.entityId, self)
    self.escapeKeyHandler = nil
  end
  self.MenuHolder:SetUnselected()
  local durationOut = 0.2
  TimingUtils:Delay(durationOut, self, function()
    JavelinCameraRequestBus.Broadcast.ResetDepthOfField()
  end)
  UiContextMenuBus.Broadcast.SetEnabled(false)
  if self.returningToMainMenu then
  else
    self.ScriptedEntityTweener:Play(self.Properties.MenuHolder, durationOut, {opacity = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.StorePage, durationOut, {opacity = 0, ease = "QuadOut"})
  end
  self:BusDisconnect(self.entitlementBus)
  self.entitlementBus = nil
  self:BusDisconnect(self.vitalsNotification)
  self.vitalsNotification = nil
  self.WorldTransferPopup:OnStoreTransitionOut()
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function StoreScreen:OnExit()
  LyShineManagerBus.Broadcast.ExitState(4283914359)
end
function StoreScreen:ExitToMainMenu()
  LyShineManagerBus.Broadcast.ExitState(2648673335)
  LyShineManagerBus.Broadcast.SetState(3881446394)
end
function StoreScreen:StartTick()
  if not self.tickHandler then
    self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function StoreScreen:StopTick()
  if self.tickHandler then
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
end
function StoreScreen:OnTick(delta, timePoint)
  if UiElementBus.Event.IsEnabled(self.Properties.ProductRewardsTooltip) then
    local desiredViewportPos = CursorBus.Broadcast.GetCursorPosition()
    PositionEntityOnScreen(self.Properties.ProductRewardsTooltip, desiredViewportPos)
  end
end
function StoreScreen:OnCryAction(actionName)
end
function StoreScreen:OnPopupResult(result, eventId)
  if eventId ~= self.onLeavePopupEventId or result == ePopupResult_Yes then
  end
end
function StoreScreen:ShowMinorNotification(message)
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = message
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function StoreScreen:OnEscapeKeyPressed()
  if self.waitingForServerTransferResponse then
    return
  end
  if self.WorldTransferPopup:HandleEscPressed() then
    return
  elseif UiElementBus.Event.IsEnabled(self.Properties.FictionalCurrencyPopup) then
    UiElementBus.Event.SetIsEnabled(self.Properties.FictionalCurrencyPopup, false)
  elseif self.PurchaseCelebrationPopup:IsEnabled() then
    if self.closeStoreOnProductExit then
      self:OnClose()
    end
    self.PurchaseCelebrationPopup:OnCancel()
  elseif self.ConfirmPurchasePopup:IsEnabled() then
    self.ConfirmPurchasePopup:SetIsEnabled(false)
  elseif self.StoreProductPopup:IsEnabled() then
    if self.closeStoreOnProductExit then
      self:OnClose()
    end
    self.StoreProductPopup:SetIsEnabled(false)
  else
    self:OnClose()
  end
end
function StoreScreen:SetSelectedScreenVisible(entity)
  self.selectedEntity = entity
  if self.searchText ~= nil and string.len(self.searchText) > 0 then
    self.ItemSearchInput:ClearSearchField()
    self:OnSearchTextChanged("")
  end
  local selectedTabIndex = entity:GetIndex()
  self.storeTab = selectedTabIndex
  if selectedTabIndex == 1 then
    UiElementBus.Event.SetIsEnabled(self.Properties.FeaturedDealsPane, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.GenericItemsPane, false)
    self:LoadFeaturedDeals()
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.FeaturedDealsPane, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.GenericItemsPane, true)
    self.ListContentsTitle:SetText(self.MenuButtonData[selectedTabIndex].text)
    self.GenericItemsGrid:SetSpinnerShowing(true)
  end
  self:RequestCatalog(selectedTabIndex)
  self.audioHelper:PlaySound(self.audioHelper.Guild_MyTabSelected)
  UiElementBus.Event.SetIsEnabled(self.Properties.StorePage, true)
end
function StoreScreen:OnRetryTransaction()
  self.TransactionStatusPopup:SetTransactionInProgress()
  self.tryPurchaseFunction()
  TimingUtils:Delay(self.OMNI_TIMEOUT_SECONDS, self, self.OnTransactionTimeout)
end
function StoreScreen:OnDeclineRetry()
  local skippedPurchases = {}
  for i, expectedPurchase in ipairs(self.expectedPurchases) do
    if expectedPurchase.requestId ~= self.currentTransactionId then
      table.insert(skippedPurchases, expectedPurchase)
    end
  end
  self.currentTransactionId = nil
  self.TransactionStatusPopup:SetIsEnabled(false)
  self.expectedPurchases = skippedPurchases
  self.tryPurchaseFunction = nil
end
function StoreScreen:OnTransactionTimeout()
  self.TransactionStatusPopup:SetTransactionTimedOut()
end
function StoreScreen:OnSteamTransactionTimeout()
  if self.activeSteamRequestId then
    self:OnEntitlementError(self.activeSteamRequestId, 408)
  end
end
function StoreScreen:AddExpectedPurchase(balance, product, request, tryPurchaseFunction)
  table.insert(self.expectedPurchases, {
    product = product,
    requestId = request.requestId
  })
  self.currentTransactionId = request.requestId
  self.ConfirmPurchasePopup:SetIsEnabled(false)
  self.TransactionStatusPopup:Invoke(self, nil, self.OnRetryTransaction, self.OnDeclineRetry)
  if request.transactionType ~= eEntitlementTransactionType_SteamMTXPurchase then
    self.tryPurchaseFunction = tryPurchaseFunction
    TimingUtils:Delay(3, self, self.OnTransactionTimeout)
  end
  self:FillStoreProductFlags(balance, product)
  product.countBefore = product.consumableCount
  product.wasUnlocked = product.isUnlocked
end
function StoreScreen:FillStoreProductFlags(fictionalBalance, product)
  product.consumableCount = 0
  product.isUnlocked = false
  product.hasDurables = false
  for k, entitlement in ipairs(product.offer.entitlements) do
    if entitlement.isConsumable then
      product.consumableCount = product.consumableCount + OmniDataHandler:GetEntitlementBalance(entitlement.entitlementId)
    else
      product.hasDurables = true
      if EntitlementRequestBus.Broadcast.IsEntryIdOfRewardTypeEntitled(eRewardTypeEntitlement, entitlement.entitlementId) then
        product.isUnlocked = true
      end
    end
  end
  product.canUnlock = (not product.hasDurables or not product.isUnlocked) and fictionalBalance >= product.offer:GetActualPrice() and product.offer.isFictional
  product.showPrice = not product.hasDurables or not product.isUnlocked
  product.canPurchase = not product.offer.isFictional
  if product.offer.productStartValid and product.offer.productStart > TimeHelpers:ServerNow() then
    product.comingSoon = true
    product.canPurchase = false
    product.canUnlock = false
  end
end
function StoreScreen:OnCatalogReceived(offers)
  self.currentRequest = nil
  local balance = OmniDataHandler:GetEntitlementBalance(OmniDataHandler.FICTIONAL_CURRENCY_ENTITLEMENT_ID)
  for i, product in ipairs(offers) do
    product.context = self
    product.cb = self.OnOfferClick
    product.hoverStartCb = self.OnOfferHoverStart
    product.hoverEndCb = self.OnOfferHoverEnd
    product.offerExpiredCb = self.OnOfferExpired
    self:FillStoreProductFlags(balance, product)
  end
  if self.storeTab == eStoreTabFeaturedDeals and not self.isSearching then
    self:FinalizeFeaturedLayout(#offers)
    for i, featuredStoreItem in pairs(self.featuredDealsElements) do
      featuredStoreItem:SetSpinnerShowing(false)
      featuredStoreItem:SetStoreProductData(offers[i], "Featured")
    end
  else
    local filtered = offers
    if not self.showPurchased then
      filtered = {}
      for i, offer in ipairs(offers) do
        if not offer.isUnlocked or not offer.hasDurables then
          table.insert(filtered, offer)
        end
      end
    end
    table.sort(filtered, function(a, b)
      if self.sortBy == self.SORT_BY_RELEASE_DATE and a.offer.productStartDate ~= b.offer.productStartDate then
        return a.offer.productStartDate > b.offer.productStartDate
      end
      if self.sortBy == self.SORT_BY_PRICE then
        if a.offer.isFictional and not b.offer.isFictional then
          return true
        end
        if b.offer.isFictional and not a.offer.isFictional then
          return false
        end
        if a.offer:GetActualPrice() ~= b.offer:GetActualPrice() then
          return a.offer:GetActualPrice() < b.offer:GetActualPrice()
        end
      end
      return a.offer.productData.displayName < b.offer.productData.displayName
    end)
    if self.storeTab == eStoreTabServices then
      for _, product in ipairs(filtered) do
        local isServerTransfer = self:IsProductServerTransfer(product)
        if isServerTransfer then
          product.context = self
          product.cb = self.OnOfferClick
          product.hoverStartCb = self.OnOfferHoverStart
          product.hoverEndCb = self.OnOfferHoverEnd
          product.offerExpiredCb = self.OnOfferExpired
          product.onPurchaseClick = self.OnServerTransferOfferPurchase
        end
      end
      local showWorldTransfer = self.dataLayer:GetDataFromNode("UIFeatures.mtxWorldTransferRCFree")
      local hasFreeWorldTransferAvailable = EntitlementRequestBus.Broadcast.GetEntitlementBalance(2190549628) > 0
      if hasFreeWorldTransferAvailable and showWorldTransfer then
        local serverTransferOffer = {}
        serverTransferOffer.offerId = "Server_Transfer"
        serverTransferOffer.omniProductId = "Server_Transfer"
        serverTransferOffer.productId = "Server_Transfer"
        serverTransferOffer.discountStartDate = WallClockTimePoint()
        serverTransferOffer.discountStart = WallClockTimePoint()
        serverTransferOffer.discountEndDate = WallClockTimePoint()
        serverTransferOffer.discountExpiration = WallClockTimePoint()
        serverTransferOffer.productStartDate = WallClockTimePoint()
        serverTransferOffer.productStart = WallClockTimePoint()
        serverTransferOffer.productEndDate = WallClockTimePoint()
        serverTransferOffer.productExpiration = WallClockTimePoint()
        serverTransferOffer.description = "Server transfer"
        serverTransferOffer.isStandalone = true
        serverTransferOffer.price = {
          countryCode = "",
          currencyCode = "",
          originalPrice = 0,
          salesPrice = 0,
          discountPercent = 0
        }
        serverTransferOffer.entitlements = {
          {
            alias = "Server_Transfer",
            id = "Server_Transfer",
            amount = 1,
            bonusAmount = 0,
            isConsumable = true
          }
        }
        serverTransferOffer.metadata = "{\"priceOverrideText\":\"@ui_free\",\"popupInfoOverride\":\"@server_transfer_extra_detail\"}"
        local product = {
          offer = EntitlementsDataHandler:ConvertOfferToTable(serverTransferOffer)
        }
        product.context = self
        product.cb = self.OnOfferClick
        product.hoverStartCb = self.OnOfferHoverStart
        product.hoverEndCb = self.OnOfferHoverEnd
        product.offerExpiredCb = self.OnOfferExpired
        product.onPurchaseClick = self.OnServerTransferOfferPurchase
        local balance = 100
        self:FillStoreProductFlags(balance, product)
        table.insert(filtered, product)
      end
    end
    self.GenericItemsGrid:SetSpinnerShowing(false)
    self.GenericItemsGrid:OnListDataSet(filtered)
  end
end
function StoreScreen:IsProductServerTransfer(product)
  local entitlements = product.offer.entitlements
  for _, entitle in ipairs(entitlements) do
    if entitle.entitlementId == 2190549628 then
      return true
    end
  end
  return false
end
function StoreScreen:BuySteamProduct(storeProductData)
  if not self.steamNotificationBus then
    self.steamNotificationBus = self:BusConnect(SteamNotificationBus)
  end
  local request = InitializeEntitlementTransactionRequest()
  request.transactionType = eEntitlementTransactionType_SteamMTXPurchase
  request.productId = storeProductData.offer.productIdText
  request.offerId = storeProductData.offer.offerIdText
  EntitlementRequestBus.Broadcast.RequestTransaction(request, false)
  self.activeSteamRequestId = request.requestId
  TimingUtils:Delay(self.OMNI_TIMEOUT_SECONDS, self, self.OnSteamTransactionTimeout)
  local balance = OmniDataHandler:GetEntitlementBalance(OmniDataHandler.FICTIONAL_CURRENCY_ENTITLEMENT_ID)
  local event = UiAnalyticsEvent("store_attempt_steam_purchase")
  event:AddAttribute("session_id", tostring(self.sessionId))
  event:AddMetric("fictional_currency_balance", balance)
  event:AddAttribute("transaction_id", tostring(request.requestId))
  if storeProductData.offer then
    event:AddAttribute("product-description", storeProductData.offer.description)
    event:AddAttribute("productId", storeProductData.offer.productIdText)
    event:AddAttribute("offerId", storeProductData.offer.offerIdText)
    event:AddMetric("initialPrice", storeProductData.offer.originalPrice)
    event:AddMetric("finalPrice", storeProductData.offer:GetActualPrice())
    event:AddAttribute("currency", storeProductData.offer.currencyCode)
  end
  event:Send()
  self:AddExpectedPurchase(0, storeProductData, request)
end
function StoreScreen:OnFictionalCurrencyProductClick(storeProductElement)
  local rewards = EntitlementsDataHandler:GetRewardsForOffer(storeProductElement.storeProductData.offer)
  if #rewards == 1 then
    if EntitlementsDataHandler:IsRealWorldCurrencyPurchasingEnabled() then
      self:BuySteamProduct(storeProductElement.storeProductData)
    end
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.MasterContainer, false)
    self.StoreProductPopup:Invoke(storeProductElement.storeProductData, self, self.OnPurchaseProduct, self.sessionId, "bundle_with_fictional_currency")
    JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_StorePreview", 0.5)
  end
end
function StoreScreen:OnOfferExpired(storeProductElement)
  if self.StoreProductPopup:IsEnabled() then
    if storeProductElement.storeProductData.offerId == storeProductElement.storeProductData.offerId then
      self.StoreProductPopup:SetIsEnabled(false)
    end
    return
  end
  self:SetSelectedScreenVisible(self.selectedEntity)
end
function StoreScreen:OnOfferClick(storeProductElement)
  UiElementBus.Event.SetIsEnabled(self.Properties.MasterContainer, false)
  local origin = "featured_products_tab"
  if self.searchText and string.len(self.searchText) > 0 then
    origin = string.format("search_results: %s", self.searchText)
  elseif self.storeTab > 1 then
    origin = string.format("store_tab_%d", self.storeTab)
  end
  local onPurchaseClick = self.OnPurchaseProduct
  if storeProductElement.storeProductData.onPurchaseClick then
    onPurchaseClick = storeProductElement.storeProductData.onPurchaseClick
  end
  self.StoreProductPopup:Invoke(storeProductElement.storeProductData, self, onPurchaseClick, self.sessionId, origin)
  JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_StorePreview", 0.5)
  JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  self.targetDOFDistance = 50
  self.targetDOFBlur = 0.5
  TimingUtils:UpdateForDuration(0.3, self, function(self, currentValue)
    self:UpdateDepthOfField(currentValue)
  end)
end
function StoreScreen:OnOfferHoverStart(storeProductElement)
  if self.showProductRewardsTooltip then
    UiElementBus.Event.SetIsEnabled(self.Properties.ProductRewardsTooltip, true)
    self.ProductRewardsTooltip:SetProductData(storeProductElement.storeProductData, self.searchText)
    self:StartTick()
  end
end
function StoreScreen:OnOfferHoverEnd(storeProductElement)
  if self.showProductRewardsTooltip then
    UiElementBus.Event.SetIsEnabled(self.Properties.ProductRewardsTooltip, false)
    self:StopTick()
  end
end
function StoreScreen:IsExpectingPurchase()
  return #self.expectedPurchases > 0
end
function StoreScreen:OnServerTransferOfferPurchase(storeProductData)
  local isPurchase = storeProductData.offer.originalPrice ~= 0 or storeProductData.offer.finalPrice ~= 0
  self.WorldTransferPopup:OnRequestWorldTransferPopup(isPurchase, self, function(self, selectedWorldId)
    self.lastSelectedWorldTransferWorldId = selectedWorldId
    if isPurchase then
      self:OnPurchaseProduct(storeProductData)
    else
      self:RequestServerTransfer(storeProductData)
    end
  end)
end
function StoreScreen:RequestServerTransfer(storeProductData)
  SetActionmapsForTextInput(self.canvasId, true)
  EntitlementRequestBus.Broadcast.RequestTransferCharacter(self.lastSelectedWorldTransferWorldId)
  self.waitingForServerTransferResponse = self.SERVER_TRANSFER_PENDING
  DynamicBus.FullScreenSpinner.Broadcast.SetFullscreenSpinnerVisible(true, 90, self, function(self)
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@mm_rejected_Server_Crash"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    SetActionmapsForTextInput(self.canvasId, false)
    GameRequestsBus.Broadcast.RequestDisconnect(eExitGameDestination_MainMenu)
    self.waitingForServerTransferResponse = nil
  end)
end
function StoreScreen:OnTransferCharacterResponse(success)
  if not success then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@mm_rejected_Server_Crash"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
  self.waitingForServerTransferResponse = nil
  DynamicBus.FullScreenSpinner.Broadcast.SetFullscreenSpinnerVisible(false)
  SetActionmapsForTextInput(self.canvasId, false)
end
function StoreScreen:OnPurchaseProduct(storeProductData)
  if self:IsExpectingPurchase() then
    Log("Warning: Attempt to purchase product while another purchase is outstanding")
    return
  end
  if storeProductData.offer.isFictional then
    if EntitlementsDataHandler:IsFictionalCurrencyPurchasingEnabled() then
      do
        local balance = OmniDataHandler:GetEntitlementBalance(OmniDataHandler.FICTIONAL_CURRENCY_ENTITLEMENT_ID)
        if balance >= storeProductData.offer:GetActualPrice() then
          if storeProductData.canUnlock then
            self.ConfirmPurchasePopup:Invoke(storeProductData, balance, self, function()
              local request = InitializeEntitlementTransactionRequest()
              request.transactionType = eEntitlementTransactionType_ExchangeEntitlementsPurchase
              request.productId = storeProductData.offer.productIdText
              request.offerId = storeProductData.offer.offerIdText
              request.inGameCurrencyAlias = OmniDataHandler.FICTIONAL_CURRENCY_ENTITLEMENT_ALIAS
              request.expectedAmount = storeProductData.offer:GetActualPrice()
              local function tryPurchase()
                EntitlementRequestBus.Broadcast.RequestTransaction(request, true)
                local event = UiAnalyticsEvent("store_attempt_purchase")
                event:AddAttribute("session_id", tostring(self.sessionId))
                event:AddAttribute("transaction_id", tostring(request.requestId))
                event:AddMetric("fictional_currency_balance", balance)
                if storeProductData.offer then
                  event:AddAttribute("product-description", storeProductData.offer.description)
                  event:AddAttribute("productId", storeProductData.offer.productIdText)
                  event:AddAttribute("offerId", storeProductData.offer.offerIdText)
                  event:AddMetric("initialPrice", storeProductData.offer.originalPrice)
                  event:AddMetric("finalPrice", storeProductData.offer:GetActualPrice())
                  event:AddAttribute("currency", storeProductData.offer.currencyCode)
                end
                event:Send()
              end
              tryPurchase()
              self:AddExpectedPurchase(balance, storeProductData, request, tryPurchase)
              EntitlementRequestBus.Broadcast.SyncEntitlements()
            end, function()
            end)
          else
            Log("Error: Unlock button was enabled for non-consumable product that is already unlocked.")
          end
        else
          self.FictionalCurrencyPopup:Invoke(storeProductData, self, self.OnFictionalCurrencyProductClick)
          OmniDataHandler:GetRealMoneyOffers(self, self.OnRealMoneyOffersReceived)
        end
      end
    end
  elseif EntitlementsDataHandler:IsRealWorldCurrencyPurchasingEnabled() then
    self:BuySteamProduct(storeProductData)
  end
end
function StoreScreen:OnStoreProductClosed()
  if self.closeStoreOnProductExit and self.returningToMainMenu then
    self.closeStoreOnProductExit = false
    self.ExitToMainMenu()
    return
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.MasterContainer, true)
  UIInputRequestsBus.Broadcast.SetActionMapEnabled("camera", false)
  JavCameraControllerRequestBus.Broadcast.RestoreCameraState("UI_StorePreview", 0.5)
  JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  self.targetDOFDistance = 0
  self.targetDOFBlur = 0.95
  if self.closeStoreOnProductExit then
    self.closeStoreOnProductExit = false
  end
  TimingUtils:UpdateForDuration(0.3, self, function(self, currentValue)
    self:UpdateDepthOfField(currentValue)
  end)
end
function StoreScreen:FinalizeFeaturedLayout(count)
  if 8 < count then
    count = 8
  end
  for i = count + 1, 8 do
    UiElementBus.Event.SetIsEnabled(self.featuredDealsElements[i].entityId, false)
  end
  local layoutElement = UiElementBus.Event.FindChildByName(self.Properties.Layouts, string.format("Layout%d", count))
  if not layoutElement then
    Log("Error: No valid Layout defined for %d items", count)
    return
  end
  for i = 1, count do
    local placeholder = UiElementBus.Event.FindChildByName(layoutElement, string.format("ItemLocation%d", i))
    if placeholder then
      local placeholderWidth = UiTransform2dBus.Event.GetLocalWidth(placeholder)
      local placeholderHeight = UiTransform2dBus.Event.GetLocalHeight(placeholder)
      local placeholderX = UiTransformBus.Event.GetLocalPositionX(placeholder)
      local placeholderY = UiTransformBus.Event.GetLocalPositionY(placeholder)
      UiElementBus.Event.SetIsEnabled(self.featuredDealsElements[i].entityId, true)
      UiTransform2dBus.Event.SetLocalWidth(self.featuredDealsElements[i].entityId, placeholderWidth)
      UiTransform2dBus.Event.SetLocalHeight(self.featuredDealsElements[i].entityId, placeholderHeight)
      UiTransformBus.Event.SetLocalPosition(self.featuredDealsElements[i].entityId, Vector2(placeholderX, placeholderY))
      self.featuredDealsElements[i]:StyleFeaturedElementByType(placeholderWidth, "Featured")
    else
      Log("Error: Missing ItemLocation%d element in Layout%d.", i, count)
    end
  end
end
function StoreScreen:LoadFeaturedDeals()
  for i, featuredStoreItem in ipairs(self.featuredDealsElements) do
    featuredStoreItem:SetSpinnerShowing(true)
  end
end
function StoreScreen:OnUpperTabsSelected()
  self.audioHelper:PlaySound(self.audioHelper.Guild_UpperTabSelected)
end
function StoreScreen:HideAllInputs()
  UiElementBus.Event.SetIsEnabled(self.Properties.ItemSearchInput, false)
end
function StoreScreen:OnClose()
  LyShineManagerBus.Broadcast.ExitState(4283914359)
  JavCameraControllerRequestBus.Broadcast.RestoreCameraState("UI_StorePreview", 0.5)
end
function StoreScreen:RequestCatalog(searchParam)
  if not self.currentRequest then
    self.currentRequest = OmniDataHandler:GetOmniOffersByFilter(searchParam, self, self.OnCatalogReceived, self.OnNoCatalog)
    if self.currentRequest and self.currentRequest.completed then
      self.currentRequest = nil
    end
  else
    self.currentRequest.filter = searchParam
  end
end
function StoreScreen:OnNoCatalog()
  self.currentRequest = nil
  PopupWrapper:RequestPopup(ePopupButtons_OK, "@ui_store", "@ui_store_unavailable", "NoCatalogPopup", self, function(self, result, eventId)
    self:OnClose()
  end)
end
function StoreScreen:OnDamage(attackerEntityId, healthPercentageLost, positionOfAttack, damageAngle, isSelfDamage, damageByType, isFromStatusEffect, cancelTargetHoming)
  if healthPercentageLost < GetEpsilon() then
    return
  end
  if positionOfAttack ~= nil then
    self:OnClose()
  end
end
function StoreScreen:OnOverlayActivated(active)
  if self.activeSteamRequestId and active then
    TimingUtils:StopDelay(self, self.OnSteamTransactionTimeout)
  end
  if self.activeSteamRequestId and not active then
    TimingUtils:Delay(self.OMNI_TIMEOUT_SECONDS, self, self.OnSteamTransactionTimeout)
    self:BusDisconnect(self.steamNotificationBus)
    self.steamNotificationBus = nil
  end
end
function StoreScreen:OnEntitlementsChange()
  if self.showEntitlementsNotification and not self.isVisible then
    if self.notification then
      UiNotificationsBus.Broadcast.RescindNotification(self.notification, true, true)
    end
    local notificationData = NotificationData()
    notificationData.type = "Generic"
    notificationData.text = "@ui_items_have_changed_msg"
    notificationData.title = "@ui_account_items_changed"
    notificationData.hasChoice = true
    notificationData.acceptTextOverride = "@ui_view_items"
    notificationData.declineTextOverride = "@ui_dismiss"
    notificationData.contextId = self.entityId
    notificationData.callbackName = "OnShowPurchasesFromNotification"
    self.notification = UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
  local fictionalBalance = OmniDataHandler:GetEntitlementBalance(OmniDataHandler.FICTIONAL_CURRENCY_ENTITLEMENT_ID)
  self.AddFictionalCurrencyButton:SetValue(GetFormattedNumber(fictionalBalance, 0))
  self.AddFictionalCurrencyButtonPopup:SetValue(GetFormattedNumber(fictionalBalance, 0))
  if self.searchText then
    self:OnSearchTextChanged(self.searchText)
  else
    self:RequestCatalog(self.storeTab)
  end
  self:CheckCelebrations()
end
function StoreScreen:OnEntitlementError(transactionId, error)
  if self.activeSteamRequestId and (not transactionId or transactionId:IsNull()) then
    transactionId = self.activeSteamRequestId
    TimingUtils:StopDelay(self, self.OnSteamTransactionTimeout)
    self.activeSteamRequestId = nil
    self:BusDisconnect(self.steamNotificationBus)
    self.steamNotificationBus = nil
  end
  local skippedPurchases = {}
  for i, expectedPurchase in ipairs(self.expectedPurchases) do
    local product = expectedPurchase.product
    if expectedPurchase.requestId == transactionId then
      local event = UiAnalyticsEvent("store_purchase_error")
      event:AddAttribute("session_id", tostring(self.sessionId))
      event:AddAttribute("transaction_id", tostring(transactionId))
      event:AddMetric("fictional_currency_balance", OmniDataHandler:GetEntitlementBalance(OmniDataHandler.FICTIONAL_CURRENCY_ENTITLEMENT_ID))
      event:AddAttribute("error", tostring(error))
      if product.offer then
        event:AddAttribute("product-description", product.offer.description)
        event:AddAttribute("productId", product.offer.productIdText)
        event:AddAttribute("offerId", product.offer.offerIdText)
        event:AddMetric("initialPrice", product.offer.originalPrice)
        event:AddMetric("finalPrice", product.offer:GetActualPrice())
        event:AddAttribute("currency", product.offer.currencyCode)
      end
      event:Send()
      if expectedPurchase.requestId == self.activeSteamRequestId then
        TimingUtils:StopDelay(self, self.OnSteamTransactionTimeout)
        self.activeSteamRequestId = nil
        self:BusDisconnect(self.steamNotificationBus)
        self.steamNotificationBus = nil
      end
      self.TransactionStatusPopup:SetTransactionFailed(GetLocalizedReplacementText("@ui_transaction_failed_code", {
        code = tostring(error)
      }))
      TimingUtils:StopDelay(self, self.OnTransactionTimeout)
    else
      table.insert(skippedPurchases, expectedPurchase)
    end
  end
  self.expectedPurchases = skippedPurchases
end
function StoreScreen:CheckCelebrations()
  local skippedPurchases = {}
  local balance = OmniDataHandler:GetEntitlementBalance(OmniDataHandler.FICTIONAL_CURRENCY_ENTITLEMENT_ID)
  for i, expectedPurchase in ipairs(self.expectedPurchases) do
    local product = expectedPurchase.product
    self:FillStoreProductFlags(balance, product)
    if not (not product.isUnlocked or product.wasUnlocked) or product.consumableCount > product.countBefore then
      local event = UiAnalyticsEvent("store_successful_purchase")
      event:AddAttribute("session_id", tostring(self.sessionId))
      event:AddMetric("fictional_currency_balance", balance)
      if product.offer then
        event:AddAttribute("product-description", product.offer.description)
        event:AddAttribute("productId", product.offer.productIdText)
        event:AddAttribute("offerId", product.offer.offerIdText)
        event:AddAttribute("transaction_id", tostring(expectedPurchase.requestId))
        event:AddMetric("initialPrice", product.offer.originalPrice)
        event:AddMetric("finalPrice", product.offer:GetActualPrice())
        event:AddAttribute("currency", product.offer.currencyCode)
      end
      event:Send()
      if expectedPurchase.requestId == self.activeSteamRequestId then
        TimingUtils:StopDelay(self, self.OnSteamTransactionTimeout)
        self.activeSteamRequestId = nil
        self:BusDisconnect(self.steamNotificationBus)
        self.steamNotificationBus = nil
      end
      self.TransactionStatusPopup:SetTransactionSuccess()
      TimingUtils:StopDelay(self, self.OnTransactionTimeout)
      self.tryPurchaseFunction = nil
      self.currentTransactionId = nil
      if self:IsProductServerTransfer(product) then
        self:RequestServerTransfer(product)
      else
        self.PurchaseCelebrationPopup:AddCelebration(product)
      end
    else
      table.insert(skippedPurchases, expectedPurchase)
    end
  end
  self.expectedPurchases = skippedPurchases
end
function StoreScreen:ShowOrderHistory()
  self.OrderHistoryPopup:Invoke()
  self.SortDropdown:Collapse()
end
function StoreScreen:UpdateDepthOfField(currentValue)
  local currentDistance = self.previousDOFDistance + (self.targetDOFDistance - self.previousDOFDistance) * currentValue
  local currentBlur = self.previousDOFBlur + (self.targetDOFBlur - self.previousDOFBlur) * currentValue
  JavelinCameraRequestBus.Broadcast.SetDepthOfField(currentDistance, currentBlur, 0, 0, self.UIStyle.RANGE_DEPTH_OF_FIELD)
end
function StoreScreen:InvokeStoreFromButton(origin)
  if EntitlementsDataHandler:IsStoreEnabled() then
    self.autoStoreProductData = nil
    self.origin = origin
    LyShineManagerBus.Broadcast.SetState(4283914359)
  end
end
function StoreScreen:InvokeStoreWithOffer(offer, origin)
  if EntitlementsDataHandler:IsStoreEnabled() then
    self.origin = origin
    self.autoStoreProductData = {
      context = self,
      cb = self.OnOfferClick,
      hoverStartCb = self.OnOfferHoverStart,
      hoverEndCb = self.OnOfferHoverEnd,
      offer = offer
    }
    local balance = OmniDataHandler:GetEntitlementBalance(OmniDataHandler.FICTIONAL_CURRENCY_ENTITLEMENT_ID)
    self:FillStoreProductFlags(balance, self.autoStoreProductData)
    LyShineManagerBus.Broadcast.SetState(4283914359)
  end
end
function StoreScreen:SetupForTwitchPopup()
  UiElementBus.Event.SetIsEnabled(self.Properties.ScreenHeader, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.StorePage, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.MasterContainer, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.OrderHistoryPopup, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.AddFictionalCurrencyButton, false)
  self.closeStoreOnProductExit = true
  self.escapeKeyHandlers = {
    self:BusConnect(CryActionNotificationsBus, "toggleMenuComponent"),
    self:BusConnect(CryActionNotificationsBus, "ui_cancel")
  }
  self:CheckCelebrations()
end
function StoreScreen:InvokeStoreWithEntitlements(entitlementIds)
  if self.enablePopupEntitlements and EntitlementsDataHandler:IsStoreEnabled() then
    self.autoStoreProductData = nil
    LyShineManagerBus.Broadcast.SetState(2648673335)
    for i = 1, #entitlementIds do
      local offer = {
        entitlements = {},
        productData = nil,
        isFictional = true,
        finalPrice = 0,
        originalPrice = 0,
        showPrice = false,
        productExpirationValid = false,
        discountExpirationValid = false
      }
      local entitlement = {
        entitlementId = entitlementIds[i],
        amount = 1
      }
      local entitlementProductData = {offer = offer}
      entitlementProductData.offer.productData = EntitlementRequestBus.Broadcast.GetStoreProductData(entitlementIds[i])
      table.insert(entitlementProductData.offer.entitlements, entitlement)
      self.PurchaseCelebrationPopup:AddCelebration(entitlementProductData)
    end
  end
end
function StoreScreen:OnWorldTransferFaq()
  OptionsDataBus.Broadcast.OpenWorldTransferFaq()
end
return StoreScreen
