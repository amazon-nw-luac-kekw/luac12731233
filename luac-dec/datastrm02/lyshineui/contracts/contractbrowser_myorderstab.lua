local ContractBrowser_MyOrdersTab = {
  Properties = {
    ContractItemList = {
      default = EntityId(),
      order = 1
    },
    ActiveTab = {
      default = EntityId(),
      order = 2
    },
    EndedTab = {
      default = EntityId(),
      order = 2
    },
    BuyTab = {
      default = EntityId(),
      order = 3
    },
    SellTab = {
      default = EntityId(),
      order = 3
    },
    ShowingResultsText = {
      default = EntityId(),
      order = 4
    },
    NextPageButton = {
      default = EntityId(),
      order = 4
    },
    PrevPageButton = {
      default = EntityId(),
      order = 4
    },
    RefreshButton = {
      default = EntityId(),
      order = 4
    },
    OrderPopup = {
      default = EntityId(),
      order = 5
    },
    CancelPopup = {
      default = EntityId(),
      order = 5
    },
    Header = {
      default = EntityId(),
      order = 6
    },
    MasterParent = {
      default = EntityId(),
      order = 6
    },
    TertiaryTabs = {
      default = EntityId(),
      order = 7
    },
    OrderCountText = {
      default = EntityId(),
      order = 10
    }
  },
  timer = 0,
  requestDelay = 10,
  isAllowedToRefresh = true,
  isViewingCompletedTab = false,
  isViewingBuyTab = false,
  sortKey = "expiration",
  isSortingAsc = true,
  contractsPerPage = 10,
  currentContracts = nil,
  headerData = {},
  pageRangeStart = 1,
  itemDescriptor = ItemDescriptor()
}
local isPreviewDebug = false
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ContractBrowser_MyOrdersTab)
local contractsDataHandler = RequireScript("LyShineUI._Common.ContractsDataHandler")
local itemCommon = RequireScript("LyShineUI._Common.ItemCommon")
function ContractBrowser_MyOrdersTab:OnInit()
  BaseElement.OnInit(self)
  self.pendingBuyContracts = {}
  self.pendingSellContracts = {}
  self.completedBuyContracts = {}
  self.completedSellContracts = {}
  self.paginationStates = contractsDataHandler.paginationStates
  local numContractsPerPage = Contract.GetMaxOpenContractsPerPlayer()
  self.paginationData = contractsDataHandler:GetPaginationData(numContractsPerPage)
  UiElementBus.Event.SetIsEnabled(self.Properties.NextPageButton, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.PrevPageButton, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.OrderCountText, false)
  self.NextPageButton:SetCallback(function(self)
    self:RefreshCurrentList(self.paginationStates.forward)
  end, self)
  self.PrevPageButton:SetCallback(function(self)
    self:RefreshCurrentList(self.paginationStates.back)
  end, self)
  self.OrderPopup:SetOnCloseCallback(self, self.RefreshCurrentList)
  self.RefreshButton:SetButtonSingleIconPath("lyshineui/images/icons/misc/icon_refresh.dds")
  self.RefreshButton:SetCallback(function(self)
    self:TryRefresh()
  end, self)
end
function ContractBrowser_MyOrdersTab:OnTransitionIn()
  self:TryRefresh()
end
function ContractBrowser_MyOrdersTab:TryRefresh()
  if self.isAllowedToRefresh then
    if self.tickHandler == nil then
      self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
    end
    self:RefreshCurrentList()
    UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.RefreshButton, false)
  end
end
function ContractBrowser_MyOrdersTab:OnTick(deltaTime, timePoint)
  self.timer = self.timer + deltaTime
  if self.timer > self.requestDelay then
    self.isAllowedToRefresh = true
    UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.RefreshButton, true)
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
    self.timer = 0
  end
end
function ContractBrowser_MyOrdersTab:SortMyContractItemList(sortKey, isSortingAsc)
  self.sortKey = sortKey
  self.isSortingAsc = isSortingAsc
  local function compare(a, b)
    if self.isSortingAsc then
      return a[self.sortKey] > b[self.sortKey]
    else
      return a[self.sortKey] < b[self.sortKey]
    end
  end
  table.sort(self.currentContracts, compare)
  self:SetupMyContractItemList()
end
function ContractBrowser_MyOrdersTab:SetTabVisibility(isVisible)
  if isVisible == self.isVisible then
    return
  end
  self.isVisible = isVisible
  if isVisible then
    self:RefreshCurrentList()
    self.ScriptedEntityTweener:Play(self.Properties.Header, 0.1, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.MasterParent, 0.2, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.TertiaryTabs, 0.2, {opacity = 0}, {
      opacity = 1,
      delay = 0.1,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.ContractItemList, 0.3, {opacity = 0}, {
      opacity = 1,
      delay = 0.2,
      ease = "QuadOut"
    })
  else
    if self.searchRequestId then
      contractsDataHandler:CancelRequest(self.searchRequestId)
      self.searchRequestId = nil
    end
    self.paginationData:ClearCachedContracts()
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, isVisible)
end
function ContractBrowser_MyOrdersTab:GetSortFunction(key)
  return function(self, isSortingAsc)
    self:SortMyContractItemList(key, isSortingAsc)
  end
end
function ContractBrowser_MyOrdersTab:SetupContractHeaders()
  local headerData = {}
  local headerWidths = {
    300,
    75,
    75,
    75,
    75,
    75,
    75,
    75,
    118,
    100
  }
  if self.isViewingCompletedTab then
    headerWidths = {
      300,
      75,
      75,
      75,
      75,
      75,
      75,
      118,
      125,
      100
    }
  end
  table.insert(headerData, {
    text = "@trade_column_name",
    key = "name",
    callbackSelf = self,
    callbackFn = self:GetSortFunction("name")
  })
  table.insert(headerData, {
    text = "@trade_column_price",
    key = "price",
    conversionFn = "GetDisplayContractPrice",
    callbackSelf = self,
    callbackFn = self:GetSortFunction("price")
  })
  if not self.isViewingCompletedTab then
    local expirationHeader = {
      text = "@ui_contract_time",
      key = "expiration",
      callbackSelf = self,
      callbackFn = self:GetSortFunction("expiration")
    }
    if expirationHeader.key == self.sortKey then
      expirationHeader.startAscending = self.isSortingAsc
    end
    table.insert(headerData, expirationHeader)
  end
  table.insert(headerData, {
    text = "@ui_quant",
    key = "quantity",
    callbackSelf = self,
    callbackFn = self:GetSortFunction("quantity")
  })
  if self.isViewingBuyTab then
    table.insert(headerData, {
      text = "@ui_bought",
      key = "bought",
      callbackSelf = self,
      callbackFn = self:GetSortFunction("bought")
    })
  else
    table.insert(headerData, {
      text = "@trade_column_sold",
      key = "bought",
      callbackSelf = self,
      callbackFn = self:GetSortFunction("bought")
    })
  end
  table.insert(headerData, {
    text = "@cr_tier",
    key = "tier",
    conversionFn = "GetDisplayTier"
  })
  table.insert(headerData, {
    text = "@ui_contract_gearscore",
    key = "gearscore",
    conversionFn = "GetDisplayGearScore"
  })
  table.insert(headerData, {
    text = "@ui_gemsocket",
    key = "gemsocket",
    conversionFn = "GetDisplaySocket"
  })
  table.insert(headerData, {
    text = "@crafting_perklabel",
    key = "perks",
    conversionFn = "GetDisplayPerks"
  })
  table.insert(headerData, {
    text = "@trade_column_rarity",
    key = "rarity",
    conversionFn = "GetDisplayRarity"
  })
  table.insert(headerData, {
    text = "@trade_column_location",
    key = "location",
    callbackSelf = self,
    callbackFn = self:GetSortFunction("location")
  })
  if self.isViewingCompletedTab then
    table.insert(headerData, {
      text = "@trade_column_status",
      key = "reason",
      callbackSelf = self,
      callbackFn = self:GetSortFunction("reason")
    })
  end
  return headerData, headerWidths
end
function ContractBrowser_MyOrdersTab:SetupMyContractItemList(noContractsTextOverride)
  local headerData, headerWidths = self:SetupContractHeaders()
  local listData = {}
  for key, contractData in pairs(self.currentContracts) do
    local rowData = {
      callbackData = key,
      itemDescriptor = contractData.itemDescriptor,
      disableItemBackgrounds = contractData.contractType == eContractType_Buy,
      allowCompare = contractData.contractType == eContractType_Sell,
      isLocalPlayerCreator = true,
      columnData = {}
    }
    for i = 1, #headerData do
      if headerData[i].key then
        local value = contractData[headerData[i].key]
        if headerData[i].conversionFn then
          value = contractData[headerData[i].conversionFn](contractData)
        end
        table.insert(rowData.columnData, tostring(value))
      end
    end
    table.insert(listData, rowData)
  end
  local noContractsData
  if not self.currentContracts or #self.currentContracts == 0 then
    noContractsData = {}
    if noContractsTextOverride then
      noContractsData.label = noContractsTextOverride
    else
      noContractsData.label = self.isViewingCompletedTab and "@ui_no_existing_ended_contracts" or "@ui_no_existing_active_contracts"
    end
  end
  self.ContractItemList:SetContractPressedCallback(self, self.OnContractSelected)
  self.ContractItemList:OnListDataSet(listData, noContractsData)
  self.ContractItemList:SetColumnWidths(headerWidths)
  self.ContractItemList:SetColumnHeaderData(headerData)
  UiElementBus.Event.SetIsEnabled(self.Properties.ShowingResultsText, false)
end
function ContractBrowser_MyOrdersTab:OnContractSelected(key)
  local contractData = self.currentContracts[key]
  if contractData then
    if self.isViewingCompletedTab then
      self.itemDescriptor.itemId = contractData.itemId
      self.itemDescriptor.gearScore = contractData.itemDescriptor.gearScore
      self.itemDescriptor:SetPerks(itemCommon:GetPerks(contractData.itemDescriptor))
      local orderParams = {
        quantity = contractData.quantity,
        unitPrice = contractData.price,
        duration = contractData.duration
      }
      self.OrderPopup:SetPostOrderPopupData(self.isViewingBuyTab, self.itemDescriptor, orderParams)
    else
      self.CancelPopup:SetCancellationData(self.isViewingBuyTab, contractData, self, function(self)
        self:RefreshCurrentList()
      end)
    end
  end
end
function ContractBrowser_MyOrdersTab:SetOrderCount()
  local text = GetLocalizedReplacementText("@ui_myorders_with_count_max", {
    count = GetLocalizedNumber(#self.pendingBuyContracts + #self.pendingSellContracts),
    max = GetLocalizedNumber(Contract.GetMaxOpenContractsPerPlayer())
  })
  UiTextBus.Event.SetText(self.Properties.OrderCountText, text)
  UiElementBus.Event.SetIsEnabled(self.Properties.OrderCountText, true)
end
function ContractBrowser_MyOrdersTab:SetPagination()
  if self.currentContracts and #self.currentContracts > 1 then
    local function compare(a, b)
      if self.isSortingAsc then
        return a[self.sortKey] > b[self.sortKey]
      else
        return a[self.sortKey] < b[self.sortKey]
      end
    end
    table.sort(self.currentContracts, compare)
  end
  self:SetupMyContractItemList()
end
function ContractBrowser_MyOrdersTab:OnBuyTabSelected(entityId)
  self.isViewingBuyTab = true
  if self.isViewingCompletedTab then
    self.currentContracts = self.completedBuyContracts
  else
    self.currentContracts = self.pendingBuyContracts
  end
  self:SetOrderCount()
  self:SetPagination()
end
function ContractBrowser_MyOrdersTab:OnSellTabSelected(entityId)
  self.isViewingBuyTab = false
  if self.isViewingCompletedTab then
    self.currentContracts = self.completedSellContracts
  else
    self.currentContracts = self.pendingSellContracts
  end
  self:SetOrderCount()
  self:SetPagination()
end
function ContractBrowser_MyOrdersTab:OnActiveTabSelected(entityId)
  self.isViewingCompletedTab = false
  if self.isViewingBuyTab then
    self.currentContracts = self.pendingBuyContracts
  else
    self.currentContracts = self.pendingSellContracts
  end
  self:SetOrderCount()
  self:SetPagination()
end
function ContractBrowser_MyOrdersTab:OnEndedTabSelected(entityId)
  self.isViewingCompletedTab = true
  if self.isViewingBuyTab then
    self.currentContracts = self.completedBuyContracts
  else
    self.currentContracts = self.completedSellContracts
  end
  self:SetOrderCount()
  self:SetPagination()
end
function ContractBrowser_MyOrdersTab:RefreshCurrentList(paginationState)
  if isPreviewDebug then
    local targetPageRangeEnd = self.pageRangeStart + self.contractsPerPage - 1
    self.currentContracts = self:DebugGetMyContracts(self.pageRangeStart, targetPageRangeEnd, self.sortKey, self.isSortingAsc)
    self:SetupMyContractItemList()
  else
    self.paginationData.paginationState = paginationState
    self.ContractItemList:SetSpinnerShowing(true)
    do
      local function onResponseFailFunc(response)
        self.ContractItemList:SetSpinnerShowing(false)
        local failReason = contractsDataHandler:FailureReasonToString(response)
        ClearTable(self.currentContracts)
        self:SetupMyContractItemList(failReason)
      end
      ClearTable(self.pendingSellContracts)
      ClearTable(self.pendingBuyContracts)
      ClearTable(self.completedBuyContracts)
      ClearTable(self.completedSellContracts)
      if not self.currentContracts then
        self.currentContracts = self.pendingSellContracts
      end
      if self.searchRequestId then
        contractsDataHandler:CancelRequest(self.searchRequestId)
        self.searchRequestId = nil
      end
      self.searchRequestId = contractsDataHandler:LookupContractsForLocalPlayer(self, function(self, response)
        local rawContracts = response
        if not rawContracts then
          onResponseFailFunc()
          return
        end
        local contracts = contractsDataHandler:ContractsVectorToTable(rawContracts)
        self.currentContractCount = #contracts
        for i = #contracts, 1, -1 do
          local contractData = contracts[i]
          if contractData.statusEnum == eContractStatus_Resolved or contractData.statusEnum == eContractStatus_Completed then
            if contractData.contractType == eContractType_Buy then
              table.insert(self.completedBuyContracts, contractData)
            elseif contractData.contractType == eContractType_Sell then
              table.insert(self.completedSellContracts, contractData)
            end
          elseif contractData.contractType == eContractType_Buy then
            table.insert(self.pendingBuyContracts, contractData)
          elseif contractData.contractType == eContractType_Sell then
            table.insert(self.pendingSellContracts, contractData)
          end
        end
        if self.isViewingCompletedTab then
          if self.isViewingBuyTab then
            self.currentContracts = self.completedBuyContracts
          else
            self.currentContracts = self.completedSellContracts
          end
        elseif self.isViewingBuyTab then
          self.currentContracts = self.pendingBuyContracts
        else
          self.currentContracts = self.pendingSellContracts
        end
        contractsDataHandler:SetOutstandingContractCount(#self.pendingBuyContracts + #self.pendingSellContracts)
        self:SetOrderCount()
        self:SetPagination()
        UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.RefreshButton, true)
      end, function(self, response)
        onResponseFailFunc(response)
      end, eContractEventOpenFilter_All, eContractEventRoleFilter_Creator, self.paginationData.contractsPerPage, self.paginationData)
    end
  end
  self.pageRangeEnd = self.pageRangeStart + #self.currentContracts - 1
end
function ContractBrowser_MyOrdersTab:DebugGetMyContracts(pageRangeStart, pageRangeEnd, sortKey, isSortingAsc)
  if not self.debugContracts then
    self.debugContracts = {}
    for i = 1, 100 do
      table.insert(self.debugContracts, {
        name = "Contract" .. i,
        iconPath = "LyshineUI\\Images\\items\\1hSwordT5.png",
        price = 5 + i,
        quantity = (10 + i) % 5,
        bought = (5 + i) % 7,
        expiration = "1h25m",
        duration = 1,
        location = GetRandomString(10),
        reason = "Completed"
      })
    end
  end
  local function compare(a, b)
    if not a or not b then
      return false
    end
    if isSortingAsc then
      return a[sortKey] > b[sortKey]
    else
      return a[sortKey] < b[sortKey]
    end
  end
  table.sort(self.debugContracts, compare)
  local contracts = {}
  if 0 < pageRangeStart and pageRangeEnd <= #self.debugContracts then
    for i = pageRangeStart, pageRangeEnd do
      table.insert(contracts, self.debugContracts[i])
    end
  end
  return contracts
end
return ContractBrowser_MyOrdersTab
