local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local ClickRecognizer = RequireScript("LyShineUI._Common.ClickRecognizer")
local TradeScreen = {
  Properties = {
    Content = {
      default = EntityId(),
      order = 1
    },
    PlayerBackground = {
      default = EntityId(),
      order = 1
    },
    PlayerIcon = {
      default = EntityId(),
      order = 1
    },
    PlayerName = {
      default = EntityId(),
      order = 1
    },
    FrameHeader = {
      default = EntityId(),
      order = 1
    },
    SendTradeContainer = {
      default = EntityId(),
      order = 2
    },
    ReceiveTradeContainer = {
      default = EntityId(),
      order = 2
    },
    SendHeaderText = {
      default = EntityId(),
      order = 3
    },
    ReceiveHeaderText = {
      default = EntityId(),
      order = 3
    },
    SendDropTarget = {
      default = EntityId(),
      order = 4
    },
    SendTradeDynamicGrid = {
      default = EntityId(),
      order = 4
    },
    ReceiveTradeDynamicGrid = {
      default = EntityId(),
      order = 4
    },
    TradeItemPrototype = {
      default = EntityId(),
      order = 4
    },
    CancelButton = {
      default = EntityId(),
      order = 5
    },
    TradeButton = {
      default = EntityId(),
      order = 5
    },
    ConfirmButton = {
      default = EntityId(),
      order = 5
    },
    LineHorizontal = {
      default = EntityId(),
      order = 6
    }
  },
  MAX_SEND_ITEM_COUNT = 5,
  CONFIRM_DELAY_SECONDS = 0,
  timeUntilConfirm = 0,
  timer = 0,
  second = 1,
  tickHandler = nil,
  onCancelTradePopupEventId = "Popup_onCancelTrade",
  onDyedItemWarningPopupEventId = "Popup_onDyedItemWarning",
  sendItemElementList = {},
  receiveItemElementList = {},
  inTradeSession = false
}
BaseScreen:CreateNewScreen(TradeScreen)
function TradeScreen:OnInit()
  BaseScreen.OnInit(self)
  self.MAX_SEND_ITEM_COUNT = ConfigProviderEventBus.Broadcast.GetInt("javelin.p2p-trading-max-items-per-trade")
  self.CONFIRM_DELAY_SECONDS = ConfigProviderEventBus.Broadcast.GetInt("javelin.p2p-trading-confirm-countdown-seconds")
  self.timeUntilConfirm = self.CONFIRM_DELAY_SECONDS
  self.SendTradeContainer:SetIsReceiving(false)
  self.ReceiveTradeContainer:SetIsReceiving(true)
  ClickRecognizer:OnActivate(self, "ItemUpdateDragData", "ItemInteract", self.OnDoubleClick, nil, self.OnSingleClick)
  self.cachedSendItemSlots = {}
  self.SendDropTarget:SetCallback(self.OnTradeAreaDrop, self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, data)
    if not data then
      return
    end
    self.playerEntityId = data
    self.SendTradeDynamicGrid:Initialize(self.TradeItemPrototype, nil)
    self.ReceiveTradeDynamicGrid:Initialize(self.TradeItemPrototype, nil)
    if self.p2pTradeBus then
      self:BusDisconnect(self.p2pTradeBus)
    end
    self.p2pTradeBus = self:BusConnect(P2PTradeComponentNotificationBus, self.playerEntityId)
    self:RegisterObservers()
  end)
  local alphaLine = 0.7
  self.LineHorizontal:SetColor(self.UIStyle.COLOR_TAN_LIGHT)
  self.ScriptedEntityTweener:Set(self.Properties.LineHorizontal, {opacity = alphaLine})
  self.FrameHeader:SetText("@ui_trading_with")
  self.FrameHeader:SetTextStyle(self.UIStyle.FONT_STYLE_INVENTORY_PRIMARY_TITLE)
  self.FrameHeader:SetTextShrinkToFit(eUiTextShrinkToFit_None)
  self.CancelButton:SetText("@ui_trade_cancel")
  self.CancelButton:SetCallback(self.OnCancelButton, self)
  self.TradeButton:SetText("@ui_trade_lock_in")
  self.TradeButton:SetCallback(self.OnLockIn, self)
  self.TradeButton:SetTextStyle(self.UIStyle.FONT_STYLE_BUTTON_SIMPLE_CTA)
  self.TradeButton:SetTextColor(self.UIStyle.COLOR_BLACK)
  self.TradeButton:SetBackgroundColor(self.UIStyle.COLOR_BUTTON_SIMPLE_CTA)
  self.TradeButton:SetBackgroundOpacity(self.UIStyle.BUTTON_SIMPLE_CTA_OPACITY)
  self.TradeButton:SetButtonBgTexture(self.TradeButton.BG_TEXTURE_STYLE_COLOR_BACKGROUND)
  self.ConfirmButton:SetText("@ui_trade_confirm")
  self.ConfirmButton:SetCallback(self.OnConfirm, self)
  self.ConfirmButton:SetTextStyle(self.UIStyle.FONT_STYLE_BUTTON_SIMPLE_CTA)
  self.ConfirmButton:SetTextColor(self.UIStyle.COLOR_BLACK)
  self.ConfirmButton:SetBackgroundColor(self.UIStyle.COLOR_BUTTON_SIMPLE_TRADE)
  self.ConfirmButton:SetBackgroundOpacity(self.UIStyle.BUTTON_SIMPLE_CTA_OPACITY)
  self.ConfirmButton:SetButtonBgTexture(self.ConfirmButton.BG_TEXTURE_STYLE_COLOR_BACKGROUND)
  UiTextBus.Event.SetTextWithFlags(self.Properties.SendHeaderText, "@ui_trade_send_title", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ReceiveHeaderText, "@ui_trade_receive_title", eUiTextSet_SetLocalized)
  SetTextStyle(self.Properties.PlayerName, self.UIStyle.FONT_STYLE_PLAYER_NAME)
  SetTextStyle(self.Properties.SendHeaderText, self.UIStyle.FONT_STYLE_CONTAINER_HEADER)
  UiTextBus.Event.SetColor(self.Properties.SendHeaderText, self.UIStyle.COLOR_ORANGE_BRIGHTER)
  SetTextStyle(self.Properties.ReceiveHeaderText, self.UIStyle.FONT_STYLE_CONTAINER_HEADER)
  DynamicBus.TradeScreen.Connect(self.entityId, self)
end
function TradeScreen:OnShutddown()
  ClickRecognizer:OnDeactivate(self)
  if self.escapeKeyHandler then
    DynamicBus.EscapeKeyNotificationBus.Disconnect(self.entityId, self)
    self.escapeKeyHandler = nil
  end
  DynamicBus.TradeScreen.Disconnect(self.entityId, self)
  BaseScreen.OnShutdown(self)
end
function TradeScreen:RegisterObservers()
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.InventoryEntityId", function(self, data)
    if not data then
      return
    end
    if self.inventoryId then
      self:BusDisconnect(self.inventoryBus)
    end
    self.inventoryId = data
    self.inventoryBus = self:BusConnect(ContainerEventBus, self.inventoryId)
  end)
end
function TradeScreen:UnregisterObservers()
  if self.inventoryId then
    self:BusDisconnect(self.inventoryBus)
  end
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.HudComponent.InventoryEntityId")
end
function TradeScreen:OnTradeAreaDrop(containerId, slotId, containerType, stackSize)
  slotId = tonumber(slotId)
  if not self.inventoryId or not slotId then
    return
  end
  if containerType == eItemDragContext_TradeScreen then
    return
  end
  if containerId ~= self.inventoryId or containerType ~= eItemDragContext_Inventory then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@ui_p2ptrading_failmessage_additem_inventory_only"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    return
  end
  local targetItem = ContainerRequestBus.Event.GetSlot(self.inventoryId, slotId)
  local staticItemData = StaticItemDataManager:GetItem(targetItem:GetItemId())
  if staticItemData.nonremovable then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@ui_p2ptrading_failmessage_additem_restricted"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    return
  end
  if targetItem:IsBoundToPlayer() then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@ui_p2ptrading_failmessage_additem_bound"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    return
  end
  for _, itemEntry in ipairs(self.cachedSendItemSlots) do
    if itemEntry.slotId == slotId then
      if itemEntry.quantity ~= stackSize then
        itemEntry.quantity = stackSize
        self:UpdateOfferedItems()
        return
      else
        return
      end
    end
  end
  if #self.cachedSendItemSlots == self.MAX_SEND_ITEM_COUNT then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@ui_p2ptrading_failmessage_additem_maximum"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    return
  end
  if targetItem:HasDyeData() then
    self.popupData = {slotId = slotId, quantity = stackSize}
    PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_trade_dyed_item_warning_title", "@ui_trade_dyed_item_warning", self.onDyedItemWarningPopupEventId, self, self.OnPopupResult)
    return
  end
  self:CacheItemSlot(slotId, stackSize)
end
function TradeScreen:CacheItemSlot(slotId, quantity)
  local itemSlot = ContainerRequestBus.Event.GetSlot(self.inventoryId, slotId)
  itemSlot:PlayItemSound("AudioPlace")
  table.insert(self.cachedSendItemSlots, {slotId = slotId, quantity = quantity})
  self:UpdateOfferedItems()
end
function TradeScreen:UpdateOfferedItems()
  self:UpdateTradeItemList()
  local slotIds = vector_int()
  local quantities = vector_int()
  for _, itemEntry in ipairs(self.cachedSendItemSlots) do
    slotIds:push_back(itemEntry.slotId)
    quantities:push_back(itemEntry.quantity)
  end
  P2PTradeComponentRequestBus.Broadcast.UpdateOfferedItems(slotIds, quantities)
end
function TradeScreen:UpdateTradeItemList()
  self.sendItemElementList = {}
  local listData = {}
  for _, itemEntry in ipairs(self.cachedSendItemSlots) do
    slot = ContainerRequestBus.Event.GetSlot(self.inventoryId, itemEntry.slotId)
    if slot and slot:IsValid() then
      table.insert(listData, {
        callbackSelf = self,
        registerFunction = self.OnRegisterSendItem,
        slot = slot,
        slotId = itemEntry.slotId,
        quantity = itemEntry.quantity,
        isSending = true
      })
    end
  end
  local noItemsData
  if #self.cachedSendItemSlots > 0 then
    noItemsData = {
      label = "@ui_drag_to_trade"
    }
  end
  self.SendTradeDynamicGrid:OnListDataSet(listData, noItemsData)
  self.SendTradeContainer:SetEmptyContainerTextVisible(#listData == 0)
  self.SendTradeDynamicGrid:OnListDataSet(listData)
end
function TradeScreen:OnRegisterSendItem(itemElement)
  table.insert(self.sendItemElementList, itemElement)
end
function TradeScreen:OnRegisterReceiveItem(itemElement)
  table.insert(self.receiveItemElementList, itemElement)
end
function TradeScreen:AddItem(slotId)
  local targetItem = ContainerRequestBus.Event.GetSlot(self.inventoryId, slotId)
  self:OnTradeAreaDrop(self.inventoryId, slotId, eItemDragContext_Inventory, targetItem:GetStackSize())
end
function TradeScreen:RemoveItem(slotId)
  for _, itemEntry in ipairs(self.cachedSendItemSlots) do
    if itemEntry.slotId == slotId then
      table.remove(self.cachedSendItemSlots, _)
    end
  end
  DynamicBus.Inventory.Broadcast.SetItemSelectedForTrade(slotId, false)
  self:UpdateOfferedItems()
end
function TradeScreen:UpdateButtonsAndText()
  if not self.ownOfferLockedIn or not self.otherOfferLockedIn then
    self:CancelConfirmCountdown()
  end
  if self.ownTradeConfirmed then
    self:UpdateTradeButtons("@ui_trade_status_locked_in", false, "@ui_trade_waiting_for_lock_in", false)
  elseif self.ownOfferLockedIn then
    if self.otherOfferLockedIn then
      if not self.tickHandler and self.timeUntilConfirm > 0 then
        self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
      end
      if self.timeUntilConfirm > 0 then
        local countDownText = GetLocalizedReplacementText("@ui_trade_confirm_countdown", {
          remaining = self.timeUntilConfirm
        })
        local confirmText = GetLocalizedReplacementText("@ui_trade_status_confirm_in", {
          remaining = self.timeUntilConfirm
        })
        self:UpdateTradeButtons("@ui_trade_status_locked_in", false, confirmText, false)
        self.audioHelper:PlaySound(self.audioHelper.P2P_Tick)
      else
        self:UpdateTradeButtons("@ui_trade_status_locked_in", false, "@ui_trade_confirm", true)
        self.audioHelper:PlaySound(self.audioHelper.P2P_Tick)
      end
    else
      self:UpdateTradeButtons("@ui_trade_waiting_for_lock_in", false, "@ui_trade_confirm", false)
    end
  elseif not self.hasSendItems and not self.hasReceiveItems then
    self:UpdateTradeButtons("@ui_trade_lock_in", false, "@ui_trade_confirm", false)
    self.TradeButton:SetTooltip("@ui_trade_status_empty")
  else
    self:UpdateTradeButtons("@ui_trade_lock_in", true, "@ui_trade_confirm", false)
  end
end
function TradeScreen:CancelConfirmCountdown()
  if self.tickHandler then
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
  self.timeUntilConfirm = self.CONFIRM_DELAY_SECONDS
end
function TradeScreen:UpdateTradeButtons(tradeButtonText, isTradeButtonEnabled, confirmButtonText, isConfirmButtonEnabled)
  self.TradeButton:SetTooltip(nil)
  self.TradeButton:SetEnabled(isTradeButtonEnabled)
  self.ConfirmButton:SetEnabled(isConfirmButtonEnabled)
  if tradeButtonText then
    self.TradeButton:SetText(tradeButtonText)
  end
  if confirmButtonText then
    self.ConfirmButton:SetText(confirmButtonText)
  end
  if isTradeButtonEnabled then
    self.TradeButton:OnFocus()
  else
    self.TradeButton:OnUnfocus()
  end
  if isConfirmButtonEnabled then
    self.ConfirmButton:SetBackgroundOpacity(self.UIStyle.BUTTON_SIMPLE_CTA_OPACITY)
    self.ConfirmButton:OnFocus()
  else
    self.ConfirmButton:SetBackgroundOpacity(0.1)
    self.ConfirmButton:OnUnfocus()
  end
end
function TradeScreen:OnTick(deltaTime, timePoint)
  if self.timeUntilConfirm > 0 then
    if self.timer > self.second then
      self.timer = self.timer - self.second
      self.timeUntilConfirm = self.timeUntilConfirm - 1
      self:UpdateButtonsAndText()
    end
    self.timer = self.timer + deltaTime
  else
    self:UpdateButtonsAndText()
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
end
function TradeScreen:OnLockIn()
  P2PTradeComponentRequestBus.Broadcast.LockInOffer()
  self.audioHelper:PlaySound(self.audioHelper.P2P_TradeLockIn)
end
function TradeScreen:OnConfirm()
  self.ownTradeConfirmed = true
  P2PTradeComponentRequestBus.Broadcast.ConfirmTrade()
  self:UpdateButtonsAndText()
end
function TradeScreen:OnCancelButton()
  local confirmationText = GetLocalizedReplacementText("@ui_trade_cancel_popup_text", {
    playerName = self.otherPlayerName
  })
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_trade_cancel_popup_title", confirmationText, self.onCancelTradePopupEventId, self, self.OnPopupResult)
end
function TradeScreen:OnPopupResult(result, eventId)
  if result == ePopupResult_Yes then
    if eventId == self.onDyedItemWarningPopupEventId then
      self:CacheItemSlot(self.popupData.slotId, self.popupData.quantity)
    elseif eventId == self.onCancelTradePopupEventId then
      P2PTradeComponentRequestBus.Broadcast.CancelTrade()
      self:OnTradeSessionEnded(eP2PTradeFailure_TradeCanceled)
    end
  end
  self.popupData = nil
end
function TradeScreen:OnTradeSessionStarted(otherCharacterId)
  self.inTradeSession = true
  LyShineManagerBus.Broadcast.QueueState(2552344588)
  DynamicBus.Inventory.Broadcast.SetGroundDropTargetForceDisabled(true)
  DynamicBus.Inventory.Broadcast.UpdateSectionButtons()
  self.cachedSendItemSlots = {}
  self.ownOfferLockedIn = false
  self.otherOfferLockedIn = false
  self.timeUntilConfirm = self.CONFIRM_DELAY_SECONDS
  self.ownTradeConfirmed = false
  self.otherTradeConfirmed = false
  self.otherPlayerName = ""
  self.otherPlayerFaction = nil
  self.previousCoinAmount = 0
  UiTextBus.Event.SetText(self.Properties.PlayerName, "")
  UiElementBus.Event.SetIsEnabled(self.Properties.PlayerBackground, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.PlayerIcon, false)
  SocialDataHandler:GetPlayerIdentification_ServerCall(self, function(self, result)
    if 0 < #result then
      self.otherPlayerName = result[1].playerId.playerName
      UiTextBus.Event.SetText(self.Properties.PlayerName, self.otherPlayerName)
    end
  end, nil, otherCharacterId)
  SocialDataHandler:GetRemotePlayerFaction_ServerCall(self, function(self, result)
    if 0 < #result then
      self.otherPlayerFaction = result[1].playerFaction
      local factionBg = self.otherPlayerFaction and FactionCommon.factionInfoTable[self.otherPlayerFaction].crestBgColor or self.UIStyle.COLOR_GRAY_70
      UiImageBus.Event.SetColor(self.Properties.PlayerBackground, factionBg)
    else
      Log("ERR TradeScreen.lua - Could not retrieve faction info from playerId")
      return
    end
  end, function()
    Log("ERR TradeScreen.lua - Could not retrieve faction info from playerId")
  end, otherCharacterId)
  SocialDataHandler:GetRemotePlayerIconData_ServerCall(self, function(self, result)
    if #result == 0 then
      return
    end
    local playerIcon = result[1].playerIcon:Clone()
    self.PlayerIcon:SetIcon(playerIcon)
    UiElementBus.Event.SetIsEnabled(self.Properties.PlayerIcon, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.PlayerBackground, true)
  end, function()
  end, otherCharacterId)
  self:UpdateOfferedItems()
  self.SendTradeContainer:SetTradeStatus(self.ownOfferLockedIn, self.ownTradeConfirmed)
  self.ReceiveTradeContainer:SetTradeStatus(self.otherOfferLockedIn, self.otherTradeConfirmed)
  self:UpdateButtonsAndText()
end
function TradeScreen:OnOfferUpdated(isOwnOffer, itemSlots, coinAmount, isLockedIn)
  if isOwnOffer then
    self.cachedSendItemSlots = {}
    for i = 1, #itemSlots do
      local slot = itemSlots[i]
      local slotId = ContainerRequestBus.Event.GetSlotIdByItemInstanceId(self.inventoryId, slot:GetItemInstanceId())
      local stackSize = slot:GetStackSize()
      table.insert(self.cachedSendItemSlots, {slotId = slotId, quantity = stackSize})
      DynamicBus.Inventory.Broadcast.SetItemSelectedForTrade(slotId, true)
    end
    self:UpdateTradeItemList()
    self.SendTradeContainer:SetItemCount(#itemSlots, self.MAX_SEND_ITEM_COUNT)
    self.SendTradeContainer:SetCurrencyAmount(coinAmount)
    if self.ownOfferLockedIn ~= isLockedIn and isLockedIn then
      for i = 1, #self.sendItemElementList do
        local itemElement = self.sendItemElementList[i]
        itemElement.ItemDraggable.ItemLayout:OnItemMoved(true)
      end
    end
    self.hasSendSlots = 0 < #itemSlots
    self.hasSendItems = self.hasSendSlots or 0 < coinAmount
    self.ownOfferLockedIn = isLockedIn
  else
    self.receiveItemElementList = {}
    local listData = {}
    local lastSlot
    for i = 1, #itemSlots do
      local slot = itemSlots[i]
      if slot and slot:IsValid() then
        lastSlot = slot
        table.insert(listData, {
          callbackSelf = self,
          registerFunction = self.OnRegisterReceiveItem,
          slot = slot,
          quantity = slot:GetStackSize()
        })
      end
    end
    if lastSlot then
      lastSlot:PlayItemSound("AudioPlace")
    end
    if self.previousCoinAmount ~= coinAmount then
      self.audioHelper:PlaySound(self.audioHelper.Treasury_Deposit)
    end
    self.previousCoinAmount = coinAmount
    self.hasReceiveItems = 0 < #itemSlots or 0 < coinAmount
    self.ReceiveTradeDynamicGrid:OnListDataSet(listData)
    self.ReceiveTradeContainer:SetItemCount(#itemSlots, self.MAX_SEND_ITEM_COUNT)
    self.ReceiveTradeContainer:SetCurrencyAmount(coinAmount)
    if self.otherOfferLockedIn ~= isLockedIn and isLockedIn then
      for i = 1, #self.receiveItemElementList do
        local itemElement = self.receiveItemElementList[i]
        itemElement.ItemDraggable.ItemLayout:OnItemMoved(true)
      end
      self.audioHelper:PlaySound(self.audioHelper.P2P_TradeLockIn)
    end
    self.otherOfferLockedIn = isLockedIn
  end
  if not isLockedIn then
    self.ownTradeConfirmed = false
    self.otherTradeConfirmed = false
  end
  self.SendTradeContainer:SetTradeStatus(self.ownOfferLockedIn, self.ownTradeConfirmed)
  self.ReceiveTradeContainer:SetTradeStatus(self.otherOfferLockedIn, self.otherTradeConfirmed)
  self:UpdateButtonsAndText()
end
function TradeScreen:OnUpdateOfferedItemsResponse(failureReason)
  self:SendNotificationWithFailureMessage(failureReason)
  if failureReason ~= eP2PTradeFailure_None then
    local itemSlots = P2PTradeComponentRequestBus.Broadcast.GetOfferedItems(true)
    self.cachedSendItemSlots = {}
    for i = 1, #itemSlots do
      local slot = itemSlots[i]
      local slotId = ContainerRequestBus.Event.GetSlotIdByItemInstanceId(self.inventoryId, slot:GetItemInstanceId())
      if 0 <= slotId then
        local stackSize = slot:GetStackSize()
        table.insert(self.cachedSendItemSlots, {slotId = slotId, quantity = stackSize})
      end
    end
    self:UpdateTradeItemList()
  end
end
function TradeScreen:OnUpdateOfferedCoinResponse(failureReason)
  self:SendNotificationWithFailureMessage(failureReason)
  if failureReason ~= eP2PTradeFailure_None then
    local coinAmount = P2PTradeComponentRequestBus.Broadcast.GetOfferedCoin(true)
    self.SendTradeContainer:SetCurrencyAmount(coinAmount)
  end
end
function TradeScreen:OnLockInOfferResponse(failureReason)
  self:SendNotificationWithFailureMessage(failureReason)
end
function TradeScreen:OnConfirmTradeResponse(failureReason)
  self:SendNotificationWithFailureMessage(failureReason)
  if failureReason ~= eP2PTradeFailure_None and failureReason ~= eP2PTradeFailure_TradeAlreadyConfirmed then
    self.ownTradeConfirmed = false
    self:UpdateButtonsAndText()
  end
  self.SendTradeContainer:SetTradeStatus(self.ownOfferLockedIn, self.ownTradeConfirmed)
end
function TradeScreen:OnOtherPlayerConfirmed()
  self.otherTradeConfirmed = true
  self.ReceiveTradeContainer:SetTradeStatus(self.otherOfferLockedIn, self.otherTradeConfirmed)
end
function TradeScreen:OnTradeSessionEnded(failureReason)
  if failureReason == eP2PTradeFailure_None then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@ui_p2ptrading_trade_completed"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  else
    self:SendNotificationWithFailureMessage(failureReason)
  end
  self.inTradeSession = false
  LyShineManagerBus.Broadcast.ExitState(2552344588)
  DynamicBus.Inventory.Broadcast.SetGroundDropTargetForceDisabled(false)
  DynamicBus.Inventory.Broadcast.UpdateSectionButtons()
end
function TradeScreen:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  if not self.dataLayer:IsScreenOpen("NewInventory") then
    LocalPlayerUIRequestsBus.Broadcast.SetIsLookingThroughLoadout(true)
  end
  LocalPlayerUIRequestsBus.Broadcast.SendVirtualInput("Player_InteractingStorage", true, 0)
  self.ScriptedEntityTweener:PlayFromC(self.Properties.Content, 0.5, {opacity = 0}, tweenerCommon.fadeInQuadOut)
  self.LineHorizontal:SetVisible(true, 0.5, {delay = 0.4})
  local sendFrameDuration = math.random() * 1 + 0.5
  local receiveFrameDuration = math.random() * 1 + 1
  self.SendTradeContainer:SetFrameVisible(true, sendFrameDuration)
  self.ReceiveTradeContainer:SetFrameVisible(true, receiveFrameDuration)
  if not self.escapeKeyHandler then
    self.escapeKeyHandler = DynamicBus.EscapeKeyNotificationBus.Connect(self.entityId, self)
  end
end
function TradeScreen:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  LocalPlayerUIRequestsBus.Broadcast.SendVirtualInput("Player_InteractingStorage", false, 0)
  self.ScriptedEntityTweener:PlayC(self.Properties.Content, 0.5, tweenerCommon.fadeOutQuadIn)
  self.LineHorizontal:SetVisible(false, 0.1)
  self.SendTradeContainer:SetFrameVisible(false)
  self.ReceiveTradeContainer:SetFrameVisible(false)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  if self.escapeKeyHandler then
    DynamicBus.EscapeKeyNotificationBus.Disconnect(self.entityId, self)
    self.escapeKeyHandler = nil
  end
  if self.inTradeSession then
    P2PTradeComponentRequestBus.Broadcast.CancelTrade()
  end
  DynamicBus.Inventory.Broadcast.ClearItemsSelectedForTrade()
end
function TradeScreen:OnEscapeKeyPressed()
  self:OnCancelButton()
end
function TradeScreen:SendNotificationWithFailureMessage(failureReason)
  if not self.inTradeSession or failureReason == eP2PTradeFailure_None then
    return
  end
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = self:GetFailureReason(failureReason)
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function TradeScreen:GetFailureReason(failureReason)
  if failureReason == eP2PTradeFailure_None then
    return nil
  elseif failureReason == eP2PTradeFailure_InvalidItems then
    return "@ui_p2ptrading_failmessage_offerupdate_invaliditems"
  elseif failureReason == eP2PTradeFailure_MaxItemsExceeded then
    return "@ui_p2ptrading_failmessage_offerupdate_maxitemsexceeded"
  elseif failureReason == eP2PTradeFailure_InvalidCoinAmount then
    return "@ui_p2ptrading_failmessage_offerupdate_invalidcoinamount"
  elseif failureReason == eP2PTradeFailure_TradeAlreadyConfirmed then
    return "@ui_p2ptrading_failmessage_offerupdate_tradealreadyconfirmed"
  elseif failureReason == eP2PTradeFailure_BothPlayersNotLockedIn then
    return "@ui_p2ptrading_failmessage_tradeconfirmation_bothplayersnotlockedin"
  elseif failureReason == eP2PTradeFailure_ConfirmedTooSoon then
    return "@ui_p2ptrading_failmessage_tradeconfirmation_confirmedtoosoon"
  elseif failureReason == eP2PTradeFailure_TradeCanceled then
    return "@ui_p2ptrading_failmessage_transactionfailure_tradecanceled"
  elseif failureReason == eP2PTradeFailure_MaxCoinExceeded then
    return "@ui_p2ptrading_failmessage_atmaxcurrency"
  else
    Log("TradeScreen:GetFailureReason: Unhandled or non-user-facing failure (" .. tostring(failureReason) .. ").")
    return "@ui_p2ptrading_failmessage_somethingwentwrong"
  end
end
function TradeScreen:OnDoubleClick(entityId)
  local draggable = self.registrar:GetEntityTable(entityId)
  if draggable and draggable.Properties.ItemLayout then
    local slotId = draggable.ItemLayout:GetSlotName()
    self:RemoveItem(slotId)
  end
end
function TradeScreen:OnSingleClick(entityId)
  local isQuickMoveModifierActive = DynamicBus.Inventory.Broadcast.IsQuickMoveModifierActive()
  if isQuickMoveModifierActive then
    self:OnDoubleClick(entityId)
  end
end
function TradeScreen:IsInTradeSession()
  return self.inTradeSession
end
return TradeScreen
