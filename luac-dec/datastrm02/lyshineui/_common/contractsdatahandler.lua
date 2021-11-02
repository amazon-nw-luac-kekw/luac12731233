local UIStyle = RequireScript("LyShineUI._Common.UIStyle")
local ContractsDataHandler = {
  RESPONSE_REASON_CLIENT_THROTTLED = "ClientThrottled",
  RETRY_BASE_TIME = 1,
  pendingOutpostIds = {},
  retryRequests = {},
  REQUEST_DELAY_TIME = 1,
  myActiveContractCount = 0,
  additionalInfoTexts = {},
  anyPerkIconPath = "lyshineui/images/icons/misc/icon_question.dds",
  attributeIconPath = "lyshineui/images/icons/misc/icon_attribute_arrow.dds"
}
local itemIconPath = "LyShineUI\\Images\\Icons\\Items\\%s.dds"
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local inventoryCommon = RequireScript("LyShineUI._Common.InventoryCommon")
local itemCommon = RequireScript("LyShineUI._Common.ItemCommon")
ContractsDataHandler.paginationStates = {
  reset = 1,
  forward = 2,
  back = 3
}
function ContractsDataHandler:OnActivate()
  if not self.contractsDataNotificationHandler then
    self.contractsDataNotificationHandler = ContractsNotificationBus.Connect(self)
    self.callbacks = {}
    self.updatedContractQuantities = {}
    local maxActionsPerSec = ConfigProviderEventBus.Broadcast.GetInt("javelin.contracts.maxClientContractActionRequestsPerSecond")
    self.REQUEST_DELAY_TIME = 0 < maxActionsPerSec and 1 / maxActionsPerSec or 1
  end
end
function ContractsDataHandler:OnDeactivate()
  if self.contractsDataNotificationHandler then
    self.contractsDataNotificationHandler:Disconnect()
    self.contractsDataNotificationHandler = nil
    ClearTable(self.callbacks)
    ClearTable(self.updatedContractQuantities)
  end
  if self.storageNotificationHandler then
    self.storageNotificationHandler:Disconnect()
    self.storageNotificationHandler = nil
  end
  if self.tickBusHandler then
    self.tickBusHandler:Disconnect()
    self.tickBusHandler = nil
  end
  self.doStorageTick = false
  self.doRetryTick = false
  self.doDelayTick = false
  self:CancelAllRequests()
  ClearTable(self.pendingOutpostIds)
  if self.updatedContractQuantities then
    ClearTable(self.updatedContractQuantities)
  end
  self.myActiveContractCount = 0
  self.outpostList = nil
end
function ContractsDataHandler:Reset()
  self:OnDeactivate()
end
function ContractsDataHandler:OnTick(deltaTime, timePoint)
  if self.doStorageTick then
    self:OnRequestStorageTick(deltaTime)
  end
  if self.doRetryTick then
    self:OnRetryTick(deltaTime)
  end
  if self.doDelayTick then
    self:OnDelayTick(deltaTime)
  end
  if not self.doStorageTick and not self.doRetryTick and not self.doDelayTick then
    self.tickBusHandler:Disconnect()
    self.tickBusHandler = nil
  end
end
function ContractsDataHandler:SetUpdatedQuantity(contractData, quantity)
  if not self.updatedContractQuantities then
    self.updatedContractQuantities = {}
  end
  local contractIdString = tostring(contractData.contractId)
  local existingOverride = self.updatedContractQuantities[contractIdString] or contractData.quantity
  self.updatedContractQuantities[contractIdString] = math.min(quantity, existingOverride)
end
function ContractsDataHandler:ConfirmContractQuantity(contractData)
  if contractData.isNpcItem then
    return
  end
  local contractIdString = tostring(contractData.contractId)
  if not self.updatedContractQuantities then
    self.updatedContractQuantities = {}
  end
  local existingOverride = self.updatedContractQuantities[contractIdString]
  if not existingOverride then
    return
  end
  if existingOverride > contractData.quantity then
    self.updatedContractQuantities[contractIdString] = nil
    return
  end
  contractData.quantity = existingOverride
end
function ContractsDataHandler:ClearQuantitiesCache()
  if self.updatedContractQuantities then
    ClearTable(self.updatedContractQuantities)
  end
end
function ContractsDataHandler:CreateRetryRequest(requestCb, cb, failedCb, maxRetries, delay)
  maxRetries = maxRetries or 5
  delay = delay or self.REQUEST_DELAY_TIME
  local requestId = Uuid:Create()
  local function retryCb(callingSelf, response)
    if not self.retryRequests[requestId] then
      return
    end
    if self:IsReasonToRetry(response) and self.retryRequests[requestId].numRetries < self.retryRequests[requestId].maxRetries then
      self.retryRequests[requestId].timeToNextRetry = self.retryRequests[requestId].currentRetryTime
      self.retryRequests[requestId].currentRetryTime = self.retryRequests[requestId].currentRetryTime * 2
      self.retryRequests[requestId].numRetries = self.retryRequests[requestId].numRetries + 1
      self.doRetryTick = true
      if not self.tickBusHandler then
        self.tickBusHandler = TickBus.Connect(self)
      end
    else
      failedCb(callingSelf, response)
      self.retryRequests[requestId] = nil
    end
  end
  local function successCb(callingSelf, response)
    if not self.retryRequests[requestId] then
      return
    end
    cb(callingSelf, response)
    self.retryRequests[requestId] = nil
  end
  self.retryRequests[requestId] = {
    maxRetries = maxRetries,
    numRetries = 0,
    timeToNextRetry = delay,
    currentRetryTime = self.RETRY_BASE_TIME,
    retryCb = retryCb,
    successCb = successCb,
    requestCb = requestCb
  }
  if delay == 0 then
    requestCb(successCb, retryCb)
  else
    self.doRetryTick = true
    if not self.tickBusHandler then
      self.tickBusHandler = TickBus.Connect(self)
    end
  end
  return requestId
end
function ContractsDataHandler:CancelRequest(requestId)
  self.retryRequests[requestId] = nil
end
function ContractsDataHandler:CancelAllRequests()
  self.retryRequests = {}
end
function ContractsDataHandler:OnRetryTick(deltaTime)
  local pendingCount = 0
  for id, retryRequest in pairs(self.retryRequests) do
    pendingCount = pendingCount + 1
    if 0 < retryRequest.timeToNextRetry then
      self.retryRequests[id].timeToNextRetry = retryRequest.timeToNextRetry - deltaTime
      if 0 >= self.retryRequests[id].timeToNextRetry then
        self.retryRequests[id].requestCb(retryRequest.successCb, retryRequest.retryCb)
      end
    end
  end
  if pendingCount == 0 then
    self.doRetryTick = false
  end
end
function ContractsDataHandler:RequestSearchContractsInternal(callingSelf, cb, failedCb, filter, paginationData)
  if not self.contractsDataNotificationHandler then
    self:OnActivate()
  end
  local requestId
  if paginationData then
    do
      local paginationState = paginationData.paginationState
      if not paginationState or paginationState == self.paginationStates.reset then
        requestId = ContractsRequestBus.Broadcast.StartPaginatedSearchRequest(filter)
      elseif paginationState == self.paginationStates.forward then
        requestId = ContractsRequestBus.Broadcast.NextSearchPageRequest(paginationData.lastRequestId)
      else
        requestId = ContractsRequestBus.Broadcast.PrevSearchPageRequest(paginationData.lastRequestId)
      end
      if not requestId:IsNull() then
        paginationData.lastRequestId = requestId
        if paginationData.pagesPerRequest > 1 then
          local function requestCb(self, response)
            if #response.contracts == 0 then
              cb(callingSelf, response)
              return
            end
            ClearTable(paginationData.cachedContracts)
            paginationData.currentPageInRequest = paginationState == self.paginationStates.back and paginationData.pagesPerRequest or 1
            paginationData.numTotalContracts = response.numTotalContracts
            local currentPage = 1
            local currentPageCount = 0
            for i = 1, #response.contracts do
              if not paginationData.cachedContracts[currentPage] then
                paginationData.cachedContracts[currentPage] = {}
              end
              table.insert(paginationData.cachedContracts[currentPage], response.contracts[i])
              currentPageCount = currentPageCount + 1
              if currentPageCount == paginationData.contractsPerPage then
                currentPage = currentPage + 1
                currentPageCount = 0
              end
            end
            local callbackResponse = {
              contracts = paginationData.cachedContracts[paginationData.currentPageInRequest],
              numTotalContracts = paginationData.numTotalContracts
            }
            cb(callingSelf, callbackResponse)
          end
          self:MapRequestIdToCallbacks(requestId, self, requestCb, failedCb)
          return
        end
      end
    end
  else
    requestId = ContractsRequestBus.Broadcast.StartNonPaginatedSearchRequest(filter)
  end
  self:MapRequestIdToCallbacks(requestId, callingSelf, cb, failedCb)
end
function ContractsDataHandler:RequestSearchContracts(callingSelf, cb, failedCb, filter, paginationData)
  if paginationData then
    local paginationState = paginationData.paginationState
    if paginationState == self.paginationStates.forward or paginationState == self.paginationStates.back then
      if self.callbacks[tostring(paginationData.lastRequestId)] then
        if failedCb then
          failedCb(callingSelf, self.RESPONSE_REASON_CLIENT_THROTTLED)
        end
        return
      end
      if paginationData.pagesPerRequest > 1 then
        local cachedPageAvailable = false
        if paginationState == self.paginationStates.forward and paginationData.currentPageInRequest < paginationData.pagesPerRequest then
          paginationData.currentPageInRequest = paginationData.currentPageInRequest + 1
          cachedPageAvailable = true
        end
        if paginationState == self.paginationStates.back and 1 < paginationData.currentPageInRequest then
          paginationData.currentPageInRequest = paginationData.currentPageInRequest - 1
          cachedPageAvailable = true
        end
        if cachedPageAvailable then
          local response = {
            contracts = paginationData.cachedContracts[paginationData.currentPageInRequest],
            numTotalContracts = paginationData.numTotalContracts
          }
          cb(callingSelf, response)
          return
        end
      end
    end
  end
  local function requestCb(cb, failedCb)
    self:RequestSearchContractsInternal(callingSelf, cb, failedCb, filter, paginationData)
  end
  return self:CreateRetryRequest(requestCb, cb, failedCb)
end
function ContractsDataHandler:LookupContractsInternal(callingSelf, cb, failedCb, filterTable)
  if not self.contractsDataNotificationHandler then
    self:OnActivate()
  end
  if not self.contractIdVector then
    self.contractIdVector = vector_AZ_Uuid()
  else
    self.contractIdVector:clear()
  end
  for _, contractId in ipairs(filterTable) do
    self.contractIdVector:push_back(contractId)
  end
  local requestId = ContractsRequestBus.Broadcast.LookupContracts(self.contractIdVector)
  self:MapRequestIdToCallbacks(requestId, callingSelf, cb, failedCb)
end
function ContractsDataHandler:LookupContracts(callingSelf, cb, failedCb, filterTable)
  local function requestCb(cb, failedCb)
    self:LookupContractsInternal(callingSelf, cb, failedCb, filterTable)
  end
  return self:CreateRetryRequest(requestCb, cb, failedCb)
end
function ContractsDataHandler:LookupContractsForLocalPlayerInternal(callingSelf, cb, failedCb, openFilter, roleFilter, countPerPage, paginationData)
  if not self.contractsDataNotificationHandler then
    self:OnActivate()
  end
  local requestId
  if paginationData then
    local paginationState = paginationData.paginationState
    if (paginationState == self.paginationStates.forward or paginationState == self.paginationStates.back) and self.callbacks[tostring(paginationData.lastRequestId)] then
      if failedCb then
        failedCb(callingSelf, self.RESPONSE_REASON_CLIENT_THROTTLED)
      end
      return
    end
    if not paginationState or paginationState == self.paginationStates.reset then
      requestId = ContractsRequestBus.Broadcast.LookupContractsForLocalPlayer(openFilter, roleFilter, countPerPage)
    elseif paginationState == self.paginationStates.forward then
      requestId = ContractsRequestBus.Broadcast.NextLookupByParticipantPageRequest(paginationData.lastRequestId)
    else
      requestId = ContractsRequestBus.Broadcast.PrevLookupByParticipantPageRequest(paginationData.lastRequestId)
    end
    if not requestId:IsNull() then
      paginationData.lastRequestId = requestId
    end
  else
    requestId = ContractsRequestBus.Broadcast.LookupContractsForLocalPlayer(openFilter, roleFilter, countPerPage)
  end
  self:MapRequestIdToCallbacks(requestId, callingSelf, cb, failedCb)
end
function ContractsDataHandler:LookupContractsForLocalPlayer(callingSelf, cb, failedCb, openFilter, roleFilter, countPerPage, paginationData)
  local function requestCb(cb, failedCb)
    self:LookupContractsForLocalPlayerInternal(callingSelf, cb, failedCb, openFilter, roleFilter, countPerPage, paginationData)
  end
  return self:CreateRetryRequest(requestCb, cb, failedCb)
end
function ContractsDataHandler:CreateContractInternal(callingSelf, cb, failedCb, params)
  if not self.contractsDataNotificationHandler then
    self:OnActivate()
  end
  local requestId = ContractsRequestBus.Broadcast.CreateContract(params)
  self:MapRequestIdToCallbacks(requestId, callingSelf, cb, failedCb)
end
function ContractsDataHandler:CreateContract(callingSelf, cb, failedCb, params)
  local function requestCb(cb, failedCb)
    self:CreateContractInternal(callingSelf, cb, failedCb, params)
  end
  return self:CreateRetryRequest(requestCb, cb, failedCb)
end
function ContractsDataHandler:CompleteContractInternal(callingSelf, cb, failedCb, contractId, params)
  if not self.contractsDataNotificationHandler then
    self:OnActivate()
  end
  local requestId = ContractsRequestBus.Broadcast.CompleteContract(contractId, params)
  self:MapRequestIdToCallbacks(requestId, callingSelf, cb, failedCb)
end
function ContractsDataHandler:CompleteContract(callingSelf, cb, failedCb, contractId, params)
  local function requestCb(cb, failedCb)
    self:CompleteContractInternal(callingSelf, cb, failedCb, contractId, params)
  end
  return self:CreateRetryRequest(requestCb, cb, failedCb)
end
function ContractsDataHandler:MapRequestIdToCallbacks(requestId, callingSelf, cb, failedCb)
  if requestId:IsNull() then
    if failedCb then
      failedCb(callingSelf, self.RESPONSE_REASON_CLIENT_THROTTLED)
    end
    return
  end
  self.callbacks[tostring(requestId)] = {
    callingSelf = callingSelf,
    cb = cb,
    failedCb = failedCb
  }
end
function ContractsDataHandler:GetNumItemContracts(callingSelf, cb, failedCb, filterTable)
  if not self.contractsDataNotificationHandler then
    self:OnActivate()
  end
  local outputString = ""
  local outpostId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.OutpostId")
  local numSelectedOutposts = filterTable.outposts and #filterTable.outposts or 0
  if numSelectedOutposts == 0 or numSelectedOutposts == 1 and filterTable.outposts[1] == outpostId then
    local tradingPostId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.TradingPostId")
    local countThresholdEnum = TradingPostRequestBus.Event.GetItemCountThreshold(tradingPostId, filterTable.contractType == eContractType_Buy, filterTable.itemCategory, filterTable.itemFamily, filterTable.itemGroup, filterTable.itemId)
    local locStrings = {
      "@ui_contract_count_none",
      "@ui_contract_count_less_10",
      "@ui_contract_count_less_25",
      "@ui_contract_count_less_50",
      "@ui_contract_count_less_100",
      "@ui_contract_count_less_500",
      "@ui_contract_count_less_1000",
      "@ui_contract_count_many"
    }
    outputString = locStrings[countThresholdEnum + 1]
  end
  cb(callingSelf, outputString)
end
function ContractsDataHandler:ExecuteCallback(requestId, response, isSuccess)
  local cb = self.callbacks[tostring(requestId)]
  if cb then
    local callbackFuncToUse
    if isSuccess then
      callbackFuncToUse = cb.cb
    else
      callbackFuncToUse = cb.failedCb
    end
    if callbackFuncToUse then
      callbackFuncToUse(cb.callingSelf, response)
    end
  end
  self.callbacks[tostring(requestId)] = nil
end
function ContractsDataHandler:OnSearchContractsResultsReceived(requestId, response)
  self:ExecuteCallback(requestId, response, true)
end
function ContractsDataHandler:OnLookupResultsReceived(requestId, response)
  self:ExecuteCallback(requestId, response, true)
end
function ContractsDataHandler:OnCreateContract(requestId, response)
  self:ExecuteCallback(requestId, response, true)
  DynamicBus.ContractBrowser.Broadcast.OnMyOrdersUpdate()
end
function ContractsDataHandler:OnContractActionFailed(requestId, response)
  self:ExecuteCallback(requestId, response, false)
end
function ContractsDataHandler:OnMyContractCanceled(requestId, response)
  self:ExecuteCallback(requestId, response, true)
  DynamicBus.ContractBrowser.Broadcast.OnMyOrdersUpdate()
end
function ContractsDataHandler:OnMyContractFailed(requestId, response)
  self:ExecuteCallback(requestId, response, false)
  DynamicBus.ContractBrowser.Broadcast.OnMyOrdersUpdate()
end
function ContractsDataHandler:OnMyContractExpired(requestId, rawContract)
  local contractTypeIsBuy = rawContract:GetType() == eContractType_Buy
  self:EnqueueTradeContractNofification(rawContract, contractTypeIsBuy and "@ui_buy_order_expired_title" or "@ui_sell_order_expired_title", contractTypeIsBuy and "@ui_buy_order_expired_desc" or "@ui_sell_order_expired_desc")
  DynamicBus.ContractBrowser.Broadcast.OnMyOrdersUpdate()
end
function ContractsDataHandler:OnMyContractUpdated(requestId, rawContract, completionCount)
  local contractTypeIsBuy = rawContract:GetType() == eContractType_Buy
  if contractTypeIsBuy then
    self:EnqueueTradeContractNofification(rawContract, "@ui_buy_order_updated", "@ui_buy_order_updated_desc", completionCount)
  else
    local notificationText = self:GetDescNotificationText(rawContract, "@ui_sell_order_updated_desc", completionCount)
    DynamicBus.EncumbranceBus.Broadcast.PlayCraftAnimation(notificationText, 2)
  end
  DynamicBus.ContractBrowser.Broadcast.OnMyOrdersUpdate()
end
function ContractsDataHandler:OnResolveContract(requestId, response)
  self:ExecuteCallback(requestId, response, true)
end
function ContractsDataHandler:OnMyContractFulfilled(requestId, rawContract, completionCount)
  local contractTypeIsBuy = rawContract:GetType() == eContractType_Buy
  self:EnqueueTradeContractNofification(rawContract, contractTypeIsBuy and "@ui_buy_order_fulfilled_title" or "@ui_sell_order_fulfilled_title", contractTypeIsBuy and "@ui_buy_order_fulfilled_desc" or "@ui_sell_order_fulfillled_desc", completionCount)
  DynamicBus.ContractBrowser.Broadcast.OnMyOrdersUpdate()
end
function ContractsDataHandler:GetDescNotificationText(rawContract, descKey, countOverride)
  local quantity = countOverride and countOverride or tostring(rawContract:GetCount())
  local contractItemData = rawContract:GetItem()
  local itemData = ItemDataManagerBus.Broadcast.GetItemData(contractItemData.itemId)
  local itemName = itemData.displayName
  local location = rawContract:GetOutpostLocation()
  local perContractGold = rawContract:GetGold()
  local isSellContract = rawContract:GetType() == eContractType_Sell
  if isSellContract then
    local transactionFee = ContractsRequestBus.Broadcast.CalculateContractCompletionFee(perContractGold, rawContract:GetType())
    perContractGold = perContractGold - transactionFee
  end
  local gold = GetLocalizedCurrency(perContractGold * quantity)
  local itemIcon = string.format(itemIconPath, itemData.itemType .. "/" .. itemData.icon)
  local text = GetLocalizedReplacementText(descKey, {
    quantity = quantity,
    itemName = itemName,
    location = location,
    gold = gold
  })
  return text, itemIcon
end
function ContractsDataHandler:EnqueueTradeContractNofification(rawContract, title, descKey, countOverride)
  local notificationText, itemIcon = self:GetDescNotificationText(rawContract, descKey, countOverride)
  local notificationData = NotificationData()
  notificationData.type = "Social"
  notificationData.icon = itemIcon
  notificationData.title = title
  notificationData.text = notificationText
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function ContractsDataHandler:ContractStatusToString(contractStatus)
  if not self.statusToLocTag then
    self.statusToLocTag = {
      [eContractStatus_Available] = "@ui_contract_status_available",
      [eContractStatus_Unavailable] = "@ui_contract_status_unavailable",
      [eContractStatus_Accepted] = "@ui_contract_status_accepted",
      [eContractStatus_Completed] = "@ui_contract_status_completed",
      [eContractStatus_Resolved] = "@ui_contract_status_resolved"
    }
  end
  return self.statusToLocTag[contractStatus] or ""
end
function ContractsDataHandler:ContractReasonToString(contractReason)
  if not self.reasonToLocTag then
    self.reasonToLocTag = {
      [eContractCompletionReason_Succeeded] = "@ui_contract_reason_succeeded",
      [eContractCompletionReason_Failed] = "@ui_contract_reason_failed",
      [eContractCompletionReason_Canceled] = "@ui_contract_reason_cancelled",
      [eContractCompletionReason_Expired] = "@ui_contract_reason_expired"
    }
  end
  return self.reasonToLocTag[contractReason] or ""
end
function ContractsDataHandler:FailureReasonToString(failureReason)
  if not self.failureToLocTag then
    self.failureToLocTag = {
      [eContractFailureReason_Unknown] = "@ui_contract_failure_generic",
      [eContractFailureReason_InvalidOutpostId] = "@ui_contract_failure_invalid_outpost",
      [eContractFailureReason_MaximumContractsCreated] = "@ui_contract_failure_maximum_contracts",
      [eContractFailureReason_InsufficientGold] = "@ui_contract_failure_insufficient_gold",
      [eContractFailureReason_InsufficientItems] = "@ui_contract_failure_insufficient_items",
      [eContractFailureReason_OutpostStorageFull] = "@ui_contract_failure_outpost_storage_full",
      [eContractFailureReason_ServerError] = "@ui_contract_failure_generic",
      [eContractFailureReason_CreatorCannotComplete] = "@ui_contract_failure_creator_cannot_complete",
      [eContractFailureReason_Throttled] = "@ui_contract_failure_throttled",
      [eContractFailureReason_InvalidRequest] = "@ui_contract_failure_invalid_request",
      [eContractFailureReason_InventoryFull] = "@ui_contract_failure_inventory_full",
      [eContractFailureReason_CoinTransferalDisabled] = "@ui_contract_failure_coin_transferal_disabled",
      [eContractFailureReason_TradingPostDisabled] = "@ui_contract_failure_trading_post_disabled",
      [eContractFailureReason_FailedToCreateTransaction] = "@ui_contract_failure_generic",
      [eContractFailureReason_NoContractsService] = "@ui_contract_failure_generic",
      [eContractFailureReason_InvalidDuration] = "@ui_contract_failure_generic",
      [eContractFailureReason_AlreadyResolved] = "@ui_contract_failure_generic",
      [eContractFailureReason_UnableToResolve] = "@ui_contract_failure_generic",
      [eContractFailureReason_AbortingContract] = "@ui_contract_failure_generic"
    }
  end
  if type(failureReason) == "number" then
    return self.failureToLocTag[failureReason] or "@ui_contract_failure_generic"
  elseif failureReason and failureReason == self.RESPONSE_REASON_CLIENT_THROTTLED then
    return "@ui_contract_failure_throttled"
  end
  return "@ui_contract_failure_generic"
end
function ContractsDataHandler:IsReasonToRetry(failureReason)
  return type(failureReason) == "number" and failureReason == eContractFailureReason_Throttled or failureReason == self.RESPONSE_REASON_CLIENT_THROTTLED
end
function ContractsDataHandler:GetDisplayContractPrice(checkAffordable)
  local displayPrice = self.price
  if not self.isNpcItem and self.contractType == eContractType_Sell then
    local fee = math.floor(self.price * (1 - ContractsRequestBus.Broadcast.GetSellContractTransactionTax())) * (self.contractType == eContractType_Buy and -1 or 1)
    displayPrice = self.price
  end
  local localizedPrice = GetLocalizedCurrency(displayPrice)
  if checkAffordable then
    local playerWallet = dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.Amount") or 0
    if displayPrice > playerWallet then
      return GetLocalizedReplacementText("@ui_invalid_price_markup", {price = localizedPrice})
    end
  end
  return localizedPrice
end
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function ContractsDataHandler:ContractsVectorToTable(rawContracts)
  local contracts = {}
  local localOutpostId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.OutpostId")
  for i = 1, #rawContracts do
    local rawContract = rawContracts[i]
    local contractItemData = rawContract:GetItem()
    local itemData = ItemDataManagerBus.Broadcast.GetItemData(contractItemData.itemId)
    local outpostLoc = rawContract:GetOutpostLocation()
    local outpostId = rawContract:GetOutpostId()
    local contractAtThisOutpost = localOutpostId ~= outpostId
    if contractAtThisOutpost then
      outpostLoc = GetLocalizedReplacementText("@ui_invalid_outpost_markup", {outpostName = outpostLoc})
    end
    local expirationDurationSec = rawContract:GetExpirationDate():Subtract(timeHelpers:ServerNow()):ToSeconds()
    local perks
    local numPerks = contractItemData:GetPerksVectorSize()
    if 0 < numPerks then
      perks = {}
      for i = 0, numPerks - 1 do
        table.insert(perks, contractItemData:GetPerk(i))
      end
    end
    local contract = {
      name = itemData.displayName,
      iconPath = string.format(itemIconPath, itemData.itemType .. "/" .. itemData.icon),
      price = rawContract:GetGold(),
      quantity = rawContract:GetCount(),
      expiration = timeHelpers:ConvertToShorthandString(expirationDurationSec, nil, true),
      expirationSec = expirationDurationSec,
      contractAtThisOutpost = contractAtThisOutpost,
      location = outpostLoc,
      itemId = contractItemData.itemId,
      contractId = rawContract:GetId(),
      contractType = rawContract:GetType(),
      reason = self:ContractReasonToString(rawContract:GetReason()),
      status = self:ContractStatusToString(rawContract:GetStatus()),
      statusEnum = rawContract:GetStatus(),
      duration = rawContract:GetPostingDuration():ToHours() / timeHelpers.hoursInDay,
      bought = rawContract:GetCreationEvent():GetCompletionCount() - rawContract:GetCount(),
      itemDescriptor = ItemDescriptor(),
      outpostId = rawContract:GetOutpostId(),
      isLocalPlayerCreator = rawContract:IsLocalPlayerCreator(),
      CanCompleteContract = self.CanCompleteContract,
      GetDisplayContractPrice = self.GetDisplayContractPrice,
      GetDisplayGearScore = self.GetDisplayGearScore,
      GetDisplayRarity = self.GetDisplayRarity,
      GetDisplayTier = self.GetDisplayTier,
      gearScore = contractItemData.gearScore,
      perkCount = contractItemData.perkCount,
      gemPerkCount = contractItemData.gemPerkCount,
      tier = contractItemData.tier,
      itemPerks = perks,
      GetDisplayPerks = self.GetDisplayPerks,
      GetDisplaySocket = self.GetDisplaySocket,
      CanEquipItem = self.CanEquipItem
    }
    self:ConfirmContractQuantity(contract)
    contract.itemDescriptor.itemId = contract.itemId
    if contract.contractType == eContractType_Sell then
      contract.itemDescriptor.gearScore = contractItemData.gearScore
      contract.itemDescriptor:SetPerks(itemCommon:GetPerks(contractItemData, true))
    end
    if 0 < contract.quantity or contract.statusEnum == eContractStatus_Resolved or contract.statusEnum == eContractStatus_Completed then
      table.insert(contracts, contract)
    end
  end
  return contracts
end
function ContractsDataHandler:GetDisplayGearScore()
  if self.gearScore == 0 then
    return "\226\128\148"
  else
    return tostring(self.gearScore)
  end
end
function ContractsDataHandler:GetDisplayRarity()
  local raritySuffix = tostring(self.itemDescriptor:GetRarityLevel())
  return itemCommon:GetDisplayRarity(raritySuffix)
end
function ContractsDataHandler:GetDisplayTier()
  return GetRomanFromNumber(self.tier or 1)
end
function ContractsDataHandler:GetDisplayPerks()
  local canHavePerks = ItemDataManagerBus.Broadcast.CanHavePerks(self.itemId)
  if not canHavePerks then
    return "\226\128\148"
  end
  local enableBuyOrderRestrictions = dataLayer:GetDataFromNode("UIFeatures.enable-buy-order-restrictions")
  local useBuyOrderRestrictions = enableBuyOrderRestrictions and self.contractType == eContractType_Buy
  local raritySuffix = useBuyOrderRestrictions and self.perkCount or tostring(self.itemDescriptor:GetRarityLevel())
  if self.itemPerks == nil then
    return "\226\128\148"
  else
    local perkIconStr = ""
    local numPerks = 0
    local itemPerksDataTable = {}
    for _, perkId in pairs(self.itemPerks) do
      local perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(perkId)
      if perkData:IsValid() and perkData.perkType ~= ePerkType_Gem then
        table.insert(itemPerksDataTable, perkData)
      end
    end
    table.sort(itemPerksDataTable, function(perk1, perk2)
      return perk1.perkType == ePerkType_Inherent
    end)
    for _, perkData in ipairs(itemPerksDataTable) do
      local perkIconPath = "lyshineui/images/" .. perkData.iconPath .. ".dds"
      local markupStr = string.format("<img src=\"%s\" xPadding=\"0\" scale=\"2\"> </img>", perkIconPath)
      if perkData.perkType == ePerkType_Inherent then
        perkIconPath = ContractsDataHandler.attributeIconPath
        markupStr = string.format("<img src=\"%s\" xPadding=\"0\" yOffset=\"-3\" scale=\"1.5\"> </img>", perkIconPath)
      end
      perkIconStr = perkIconStr .. markupStr
      numPerks = numPerks + 1
    end
    if useBuyOrderRestrictions and numPerks < self.perkCount then
      for i = numPerks + 1, self.perkCount do
        local markupStr = string.format("<img src=\"%s\" xPadding=\"0\" scale=\"1.5\"> </img>", ContractsDataHandler.anyPerkIconPath)
        perkIconStr = perkIconStr .. markupStr
      end
    end
    return 0 < numPerks and perkIconStr or "\226\128\148"
  end
end
function ContractsDataHandler:GetDisplaySocket()
  local canHavePerks = ItemDataManagerBus.Broadcast.CanHavePerks(self.itemId)
  if not canHavePerks then
    return "\226\128\148"
  end
  if self.itemPerks then
    for _, perkId in pairs(self.itemPerks) do
      local perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(perkId)
      if perkData:IsValid() and perkData.perkType == ePerkType_Gem then
        local perkIconPath = "lyshineui/images/" .. perkData.iconPath .. ".dds"
        local markupStr = string.format("<img src=\"%s\" xPadding=\"0\" scale=\"3\"></img>", perkIconPath)
        return markupStr
      end
    end
  end
  if self.gemPerkCount > 0 then
    return "@ui_any"
  end
  return "\226\128\148"
end
function ContractsDataHandler:CanEquipItem()
  local playerLevel = dataLayer:GetDataFromNode("Hud.LocalPlayer.Progression.Level")
  return playerLevel > self.itemDescriptor:GetLevelRequirement()
end
function ContractsDataHandler:CurrencyConversionToContracts(getSellToList)
  if not self.npcSellToList then
    local currencyConversionEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.CurrencyConversionEntityId")
    if currencyConversionEntityId then
      self.npcSellToList = {}
      self.npcBuyFromList = {}
      local tradeEntryList = CurrencyConversionRequestBus.Event.GetConversionList(currencyConversionEntityId)
      for i = 1, #tradeEntryList do
        local tradeEntry = tradeEntryList[i]
        local conversionId = tradeEntry.conversionID
        if conversionId and tradeEntry.showInContracts then
          local itemDescriptor = tradeEntry.itemDescriptor
          local itemData = ItemDataManagerBus.Broadcast.GetItemData(itemDescriptor.itemId)
          local contractData = {
            name = itemDescriptor:GetDisplayName(),
            iconPath = string.format(itemIconPath, itemData.itemType .. "/" .. itemData.icon),
            price = tradeEntry.currencyPrice,
            quantity = "@ui_infinite",
            expiration = "@ui_infiniteBigger",
            location = "@ui_alloutposts",
            itemId = itemDescriptor.itemId,
            contractId = tradeEntry.conversionID,
            isNpcItem = true,
            itemDescriptor = tradeEntry.itemDescriptor,
            CanCompleteContract = self.CanCompleteContract,
            GetDisplayContractPrice = self.GetDisplayContractPrice,
            GetDisplayGearScore = self.GetDisplayGearScore,
            GetDisplayTier = self.GetDisplayTier,
            gearScore = itemData.gearScoreRange,
            tier = itemData.tier,
            GetDisplayPerks = self.GetDisplayPerks,
            GetDisplaySocket = self.GetDisplaySocket
          }
          if tradeEntry.canBeSold or tradeEntry.canBeBoughtAndSold then
            contractData.contractType = eContractType_Buy
            self.npcSellToList[contractData.itemId] = contractData
          end
          if tradeEntry.canBeBought or tradeEntry.canBeBoughtAndSold then
            contractData.contractType = eContractType_Sell
            self.npcBuyFromList[contractData.itemId] = contractData
          end
        end
      end
    else
      return {}
    end
  end
  if getSellToList then
    return self.npcSellToList
  else
    return self.npcBuyFromList
  end
end
function ContractsDataHandler:GetPaginationData(contractsPerPage, pagesPerRequest)
  return {
    paginationState = self.paginationStates.reset,
    contractsPerPage = contractsPerPage,
    pagesPerRequest = pagesPerRequest or 1,
    numTotalContracts = 0,
    currentPageInRequest = 1,
    cachedContracts = {},
    GetRequestSize = function(self)
      return self.contractsPerPage * self.pagesPerRequest
    end,
    GetCurrentSearchPage = function(self)
      local currentPage = ContractsRequestBus.Broadcast.GetCurrentSearchPage() + 1
      if 1 < self.pagesPerRequest then
        return self.currentPageInRequest + self.pagesPerRequest * (currentPage - 1)
      end
      return currentPage
    end,
    GetNumTotalSearchPages = function(self)
      if self.pagesPerRequest > 1 and self.contractsPerPage > 0 then
        return math.ceil(self.numTotalContracts / self.contractsPerPage)
      end
      return ContractsRequestBus.Broadcast.GetNumTotalSearchPages()
    end,
    GetPaginationRangeText = function(self, showingResults, totalResults)
      local currentPage = self:GetCurrentSearchPage()
      local totalPages = self:GetNumTotalSearchPages()
      local resultStartIndex = self.contractsPerPage * (currentPage - 1) + 1
      local resultEndIndex = resultStartIndex + showingResults - 1
      return GetLocalizedReplacementText("@ui_showing_result_range", {
        resultStartIndex = tostring(resultStartIndex),
        resultEndIndex = tostring(resultEndIndex),
        totalResults = tostring(totalResults),
        start = tostring(currentPage),
        ["end"] = tostring(totalPages)
      })
    end,
    GetPaginationText = function(self, showingResults, totalResults)
      local currentPage = self:GetCurrentSearchPage()
      local totalPages = self:GetNumTotalSearchPages()
      return GetLocalizedReplacementText("@ui_showing_result", {
        start = tostring(currentPage),
        ["end"] = tostring(totalPages)
      })
    end,
    ClearCachedContracts = function(self)
      ClearTable(self.cachedContracts)
    end
  }
end
function ContractsDataHandler:GetColumnSortFunc(sortEnum)
  return function(self, isSortingAsc)
    self.isSortingAsc = isSortingAsc
    self.currentSort = sortEnum
    self:RefreshCurrentList(self.paginationStates.reset)
  end
end
function ContractsDataHandler:FulfillContract(contractData, quantity, callbackSelf, completeCallback, failedCallback, skipNotification)
  local function ShowSuccessNotification()
    if not skipNotification then
      do
        local contractType = contractData:GetType()
        local notificationContractData = {
          GetCount = function()
            return quantity
          end,
          GetItem = function()
            return contractData.itemDescriptor
          end,
          GetOutpostLocation = function()
            return "@ui_inventory"
          end,
          GetGold = function()
            return contractData.price
          end,
          GetType = function()
            return contractType
          end
        }
        local isBuyingItem = contractType == eContractType_Sell
        self:EnqueueTradeContractNofification(notificationContractData, isBuyingItem and "@ui_buy_order_updated" or "@ui_sell_order_fulfilled_title", isBuyingItem and "@ui_buy_order_updated_desc" or "@ui_sell_order_updated_desc")
      end
    end
  end
  if contractData.isNpcItem then
    LocalPlayerUIRequestsBus.Broadcast.ExecuteTradingPostTransaction(contractData.contractId, quantity, contractData.contractType == eContractType_Sell, contractData.price)
    if callbackSelf and completeCallback then
      completeCallback(callbackSelf)
    end
    ShowSuccessNotification()
  else
    local completionParams = ContractCompletionParams()
    completionParams.reason = eContractCompletionReason_Succeeded
    completionParams.type = contractData.contractType
    completionParams.count = quantity
    if contractData.itemDescriptor then
      completionParams.itemDescriptor = contractData.itemDescriptor
      local descriptor = completionParams.itemDescriptor
      descriptor.quantity = quantity
      completionParams.itemDescriptor = descriptor
    end
    return self:CompleteContract(self, function(self, response)
      if completeCallback and callbackSelf then
        completeCallback(callbackSelf)
        ShowSuccessNotification()
      end
    end, function(self, response)
      if failedCallback and callbackSelf then
        failedCallback(callbackSelf, response)
      end
    end, contractData.contractId, completionParams)
  end
end
function ContractsDataHandler:InternalRequestStorageData(outpostId, request)
  if not self.storageNotificationHandler then
    self.inventoryId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
    self.storageNotificationHandler = GlobalStorageNotificationBus.Connect(self, self.inventoryId)
  end
  if not self.pendingOutpostIds[tostring(outpostId)] then
    self.pendingOutpostIds[tostring(outpostId)] = {}
  end
  table.insert(self.pendingOutpostIds[tostring(outpostId)], request)
  self:RequestReplicateStorage(outpostId)
  self.timeToWait = 1
  self.doStorageTick = true
  if not self.tickBusHandler then
    self.tickBusHandler = TickBus.Connect(self)
  end
end
function ContractsDataHandler:RequestStorageData(outpostId, callingSelf, cb, cbFail)
  local request = {
    callingSelf = callingSelf,
    cb = cb,
    cbFail = cbFail or cb,
    includeInventory = false,
    outpostId = outpostId
  }
  self:InternalRequestStorageData(outpostId, request)
end
function ContractsDataHandler:RequestInventoryItemData(callingSelf, cb, cbFail)
  local outpostId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.OutpostId")
  if outpostId and string.len(outpostId) > 0 then
    local request = {
      callingSelf = callingSelf,
      cb = cb,
      cbFail = cbFail or cb,
      includeInventory = true,
      outpostId = outpostId
    }
    self:InternalRequestStorageData(outpostId, request)
  else
    local request = {
      callingSelf = callingSelf,
      cb = cb,
      cbFail = cbFail or cb,
      includeInventory = true
    }
    self:CompleteInventoryRequest(request, true)
  end
end
function ContractsDataHandler:RequestReplicateStorage(outpostId)
  local outposts = vector_basic_string_char_char_traits_char()
  outposts:push_back(outpostId)
  local playerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  GlobalStorageRequestBus.Event.RequestReplicateStorage(playerEntityId, outposts)
end
function ContractsDataHandler:OnRequestStorageTick(deltaTime, timePoint)
  self.timeToWait = self.timeToWait - deltaTime
  if self.timeToWait <= 0 then
    for k, storageRequestList in pairs(self.pendingOutpostIds) do
      for _, request in ipairs(storageRequestList) do
        self:CompleteInventoryRequest(request, false)
      end
    end
    if self.storageNotificationHandler then
      self.storageNotificationHandler:Disconnect()
      self.storageNotificationHandler = nil
    end
    ClearTable(self.pendingOutpostIds)
    self.doStorageTick = false
  end
end
function ContractsDataHandler:OnReplicatedStorageUpdated(outpostIds)
  for k = 1, #outpostIds do
    local outpostId = outpostIds[k]
    if self.pendingOutpostIds[tostring(outpostId)] then
      for _, request in ipairs(self.pendingOutpostIds[tostring(outpostId)]) do
        self:CompleteInventoryRequest(request, true)
      end
      ClearTable(self.pendingOutpostIds[tostring(outpostId)])
      self.pendingOutpostIds[tostring(outpostId)] = nil
    end
  end
  if not next(self.pendingOutpostIds) then
    self.storageNotificationHandler:Disconnect()
    self.storageNotificationHandler = nil
    self.doStorageTick = false
  end
end
function ContractsDataHandler:CompleteInventoryRequest(request, success)
  local inventoryItems, hiddenDamagedItems = self:GetInventoryItemData(request.includeInventory, request.outpostId)
  if success then
    request.cb(request.callingSelf, inventoryItems, hiddenDamagedItems)
  else
    request.cbFail(request.callingSelf, inventoryItems, hiddenDamagedItems)
  end
end
function ContractsDataHandler:GetInventoryItemData(includeInventory, outpostId)
  local inventoryItems = {}
  local uniqueItems = {}
  if not self.inventoryId then
    self.inventoryId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
  end
  if self.inventoryId and includeInventory then
    local numSlots = ContainerRequestBus.Event.GetNumSlots(self.inventoryId) or 0
    for slotId = 0, numSlots - 1 do
      local slot = ContainerRequestBus.Event.GetSlotRef(self.inventoryId, slotId)
      if slot and slot:IsValid() then
        local sellableSuffix = not slot:IsSellable() and "_NOSELL" or ""
        local slotFullName = slot:GetItemDescriptor():GetFullName() .. sellableSuffix
        if not uniqueItems[slotFullName] then
          uniqueItems[slotFullName] = {}
        end
        table.insert(uniqueItems[slotFullName], slot)
      end
    end
  end
  if outpostId and 0 < string.len(outpostId) then
    local playerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    local itemSlots = GlobalStorageRequestBus.Event.GetStorageContents(playerEntityId, outpostId)
    for k = 1, #itemSlots do
      local slot = itemSlots[k]
      if slot and slot:IsValid() then
        local sellableSuffix = not slot:IsSellable() and "_NOSELL" or ""
        local slotFullName = slot:GetItemDescriptor():GetFullName() .. sellableSuffix
        if not uniqueItems[slotFullName] then
          uniqueItems[slotFullName] = {}
        end
        table.insert(uniqueItems[slotFullName], slot)
      end
    end
  end
  local hiddenDamagedItems = 0
  for _, uniqueItemSlots in pairs(uniqueItems) do
    local count = 0
    local itemSlot
    for _, slot in pairs(uniqueItemSlots) do
      count = count + slot:GetStackSize()
      itemSlot = itemSlot or slot
    end
    local itemData = ItemDataManagerBus.Broadcast.GetItemData(itemSlot:GetItemId())
    local isSellable = itemSlot:IsSellable()
    if isSellable then
      table.insert(inventoryItems, {
        name = itemData.displayName,
        itemId = itemData.key,
        itemCrcId = itemData.id,
        iconPath = string.format(itemIconPath, itemSlot:GetItemType() .. "/" .. itemSlot:GetIconPath()),
        rawIconPath = itemSlot:GetIconPath(),
        quantity = count,
        category = itemData.category,
        description = itemData.description,
        descriptor = itemSlot:GetItemDescriptor(),
        isDyed = itemSlot:HasDyeData()
      })
    else
      hiddenDamagedItems = hiddenDamagedItems + count
    end
  end
  return inventoryItems, hiddenDamagedItems
end
function ContractsDataHandler:CanCompleteContract()
  if not self.isNpcItem then
    local curOutpostId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.OutpostId")
    if curOutpostId ~= self.outpostId then
      return false
    end
  end
  if self.type == eContractType_Buy then
    if inventoryCommon:GetInventoryItemCount(self.itemDescriptor) == 0 then
      return false
    end
  elseif self.price > dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.Amount") then
    return false
  end
  return true
end
function ContractsDataHandler:SetOutstandingContractCount(count)
  self.myActiveContractCount = count
end
function ContractsDataHandler:GetOutstandingContractCount()
  return self.myActiveContractCount
end
function ContractsDataHandler:CanPlaceBuyOrder()
  local hasReachedContractLimit = self.myActiveContractCount >= Contract.GetMaxOpenContractsPerPlayer()
  if hasReachedContractLimit then
    return false, "@ui_contract_failure_maximum_contracts"
  end
  local curOutpostId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.OutpostId")
  local playerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  return GlobalStorageRequestBus.Event.CanAcceptItems(playerEntityId, curOutpostId), "@ui_contract_failure_outpost_storage_full"
end
function ContractsDataHandler:InsertCapitalsData(capitalsData, currentOutpostId, outpostList)
  local tempDistanceText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_distanceMeters", "0")
  for i = 1, #capitalsData do
    local outpostId = capitalsData[i].id
    local outpostLoc = capitalsData[i].nameLocalizationKey
    local locKey = outpostId == currentOutpostId and "@ui_current_outpost_label" or "@ui_invalid_outpost_markup"
    outpostLoc = GetLocalizedReplacementText(locKey, {outpostName = outpostLoc})
    table.insert(outpostList, {
      text = outpostLoc,
      textRight = tempDistanceText,
      outpostId = outpostId,
      position = capitalsData[i].worldPosition
    })
  end
end
function ContractsDataHandler:GetOutpostList()
  local outpostsAndSettlements = ObjectiveInteractorRequestBus.Broadcast.GetOutpostDestinations()
  if not outpostsAndSettlements or #outpostsAndSettlements == 0 then
    return {}
  end
  local currentOutpostId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.OutpostId")
  self.outpostList = {}
  self:InsertCapitalsData(outpostsAndSettlements, currentOutpostId, self.outpostList)
  table.sort(self.outpostList, function(a, b)
    return a.text:lower() < b.text:lower()
  end)
  table.insert(self.outpostList, 1, {
    text = "@ui_selectallouposts"
  })
  return self.outpostList
end
function ContractsDataHandler:SetAdditionalInfo(additionalInfo1, additionalInfo2, contractData)
  local itemId = contractData.itemId
  local itemData = ItemDataManagerBus.Broadcast.GetItemData(itemId)
  local additionalInfo1Text = ""
  local additionalInfo2Text = ""
  local rarityIndex = 0
  ClearTable(self.additionalInfoTexts)
  if 0 < contractData.tier then
    table.insert(self.additionalInfoTexts, "@ui_buyorder_tier_label " .. contractData:GetDisplayTier())
  end
  local maxGearScore = itemData.gearScoreRange.maxValue
  local usesGearScore = maxGearScore ~= 0
  if usesGearScore then
    table.insert(self.additionalInfoTexts, "@ui_buyorder_gear_score_label " .. tostring(contractData.gearScore) .. " - " .. tostring(maxGearScore))
  end
  if itemData.canHavePerks then
    local numSpecificPerks = contractData.itemPerks and #contractData.itemPerks or 0
    local numRequiredPerks = contractData.perkCount
    local requiresGemSocket = 0 < contractData.gemPerkCount
    local specificGemPerkData
    for i = 1, numSpecificPerks do
      local perkId = contractData.itemPerks[i]
      local perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(perkId)
      if perkData:IsValid() and perkData.perkType == ePerkType_Gem then
        specificGemPerkData = perkData
      end
    end
    if requiresGemSocket then
      if specificGemPerkData then
        table.insert(self.additionalInfoTexts, "@ui_buyorder_gem_socket_label " .. specificGemPerkData.displayName)
      else
        table.insert(self.additionalInfoTexts, "@ui_buyorder_gem_socket_label @ui_buyorder_any_gem")
      end
    end
    local rarity = numRequiredPerks
    table.insert(self.additionalInfoTexts, "@ui_buyorder_rarity_label " .. itemCommon:GetDisplayRarity(rarity))
    rarityIndex = #self.additionalInfoTexts
    if 0 < numRequiredPerks then
      local perksUsed = 0
      for i = 1, numSpecificPerks do
        local perkId = contractData.itemPerks[i]
        if perkId and perkId ~= 0 then
          local perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(perkId)
          if perkData:IsValid() and perkData.perkType ~= ePerkType_Gem then
            table.insert(self.additionalInfoTexts, "@ui_buyorder_perk_label " .. perkData.displayName)
            perksUsed = perksUsed + 1
          end
        end
      end
      if numRequiredPerks > perksUsed then
        for i = perksUsed + 1, numRequiredPerks do
          table.insert(self.additionalInfoTexts, "@ui_buyorder_perk_label @ui_buyorder_any_perk")
        end
      end
    end
  end
  local numTexts = #self.additionalInfoTexts
  if numTexts <= 5 then
    for i = 1, numTexts do
      if additionalInfo1Text ~= "" then
        additionalInfo1Text = additionalInfo1Text .. "\n"
      end
      additionalInfo1Text = additionalInfo1Text .. self.additionalInfoTexts[i]
    end
  else
    for i = 1, rarityIndex - 1 do
      if additionalInfo1Text ~= "" then
        additionalInfo1Text = additionalInfo1Text .. "\n"
      end
      additionalInfo1Text = additionalInfo1Text .. self.additionalInfoTexts[i]
    end
    for i = rarityIndex, numTexts do
      if additionalInfo2Text ~= "" then
        additionalInfo2Text = additionalInfo2Text .. "\n"
      end
      additionalInfo2Text = additionalInfo2Text .. self.additionalInfoTexts[i]
    end
  end
  additionalInfo1:SetAdditionalInfo(true, "@ui_buyorder_has_these_properties", additionalInfo1Text)
  if additionalInfo2Text == "" then
    additionalInfo2:SetAdditionalInfo(false)
  else
    additionalInfo2:SetAdditionalInfo(true, "", additionalInfo2Text)
  end
  return #self.additionalInfoTexts
end
return ContractsDataHandler
