local ContractBrowser_BrowseTab = {
  Properties = {
    ShowBuyContracts = {default = false, order = 1},
    ItemFilter = {
      default = EntityId(),
      order = 2
    },
    ContractItemList = {
      default = EntityId(),
      order = 2
    },
    ContractItemGrid = {
      default = EntityId(),
      order = 2
    },
    ContractGridItemPrototype = {
      default = EntityId(),
      order = 2
    },
    SellersCheckboxContainer = {
      default = EntityId(),
      order = 3
    },
    BuyersCheckboxContainer = {
      default = EntityId(),
      order = 3
    },
    CanEquipCheckbox = {
      default = EntityId(),
      order = 4
    },
    CanFilterCheckbox = {
      default = EntityId(),
      order = 4
    },
    CanSellCheckbox = {
      default = EntityId(),
      order = 4
    },
    GemSelectionButton = {
      default = EntityId(),
      order = 4
    },
    PerkSelectionButton = {
      default = EntityId(),
      order = 4
    },
    PerkSelectionPopup = {
      default = EntityId(),
      order = 4
    },
    ShowingResultsText = {
      default = EntityId(),
      order = 5
    },
    NextPageButton = {
      default = EntityId(),
      order = 5
    },
    PrevPageButton = {
      default = EntityId(),
      order = 5
    },
    TransactionPopup = {
      default = EntityId(),
      order = 6
    },
    PostOrderPopup = {
      default = EntityId(),
      order = 7
    },
    ItemSearchBar = {
      default = EntityId(),
      order = 8
    },
    ContractBrowser = {
      default = EntityId(),
      order = 10
    },
    RefreshButton = {
      default = EntityId(),
      order = 11
    },
    PageNumberContainer = {
      default = EntityId(),
      order = 12
    },
    FilterCheckboxes = {
      default = EntityId(),
      order = 13
    },
    MasterContainer = {
      default = EntityId(),
      order = 14
    },
    CashInAnimation = {
      default = EntityId(),
      order = 15
    },
    CashInAnimationGlow = {
      default = EntityId(),
      order = 15
    },
    IsSellTabAllItems = {default = false}
  },
  isShowingBuyContracts = false,
  canAfford = false,
  canEquip = false,
  canSell = false,
  isSortingAsc = true,
  currentSort = eContractSortBy_Price
}
local isPreviewDebug = false
local contractsDataHandler = RequireScript("LyShineUI._Common.ContractsDataHandler")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ContractBrowser_BrowseTab)
function ContractBrowser_BrowseTab:OnInit()
  BaseElement.OnInit(self)
  DynamicBus.ContractBrowser_BrowseTab.Connect(self.entityId, self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  if not self.ContractBrowser or type(self.ContractBrowser) ~= table then
    local id = UiCanvasBus.Event.FindElementByName(self.canvasId, "ContractList")
    self.ContractBrowser = self.registrar:GetEntityTable(id)
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_enableContractsV2", function(self, enableV2Contracts)
    self.enableContractsGrid = enableV2Contracts
    UiElementBus.Event.SetIsEnabled(self.Properties.ContractItemGrid, self.enableContractsGrid)
    UiElementBus.Event.SetIsEnabled(self.Properties.ContractItemList, not self.enableContractsGrid)
    if self.enableContractsGrid and type(self.ContractItemGrid) == "table" then
      self.ContractItemGrid:Initialize(self.ContractGridItemPrototype, false)
    end
  end)
  self.paginationStates = contractsDataHandler.paginationStates
  local numContractsPerPage = 20
  local numPagesPerRequest = 5
  self.paginationData = contractsDataHandler:GetPaginationData(numContractsPerPage, numPagesPerRequest)
  self.CanEquipCheckbox:SetCallback(self, function(self, isChecked)
    self.canEquip = isChecked
    self:RefreshCurrentList()
  end)
  self.CanFilterCheckbox:SetCallback(self, function(self, isChecked)
    self.canAfford = isChecked
    self:RefreshCurrentList()
  end)
  UiElementBus.Event.SetIsEnabled(self.Properties.CanSellCheckbox, false)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.enable-buy-order-restrictions", function(self, enableBuyOrderRestrictions)
    self.enableBuyOrderRestrictions = enableBuyOrderRestrictions
  end)
  self.GemSelectionButton:SetCallback(self.OpenGemSelectionPopup, self)
  self.GemSelectionButton:SetTextStyle(self.UIStyle.FONT_STYLE_CONTRACTS_REFRESH)
  self.GemSelectionButton:SetOverflowMode(self.GemSelectionButton.OVERFLOW_ELLIPSIS)
  self:UpdateGemSelectionButtonText()
  self.selectedPerks = {}
  self.PerkSelectionButton:SetCallback(self.OpenPerkSelectionPopup, self)
  self.PerkSelectionButton:SetTextStyle(self.UIStyle.FONT_STYLE_CONTRACTS_REFRESH)
  self.PerkSelectionButton:SetOverflowMode(self.PerkSelectionButton.OVERFLOW_ELLIPSIS)
  self:UpdatePerkSelectionButtonText()
  self.NextPageButton:SetCallback(function(self)
    self:RefreshCurrentList(self.paginationStates.forward)
  end, self)
  self.PrevPageButton:SetCallback(function(self)
    self:RefreshCurrentList(self.paginationStates.back)
  end, self)
  self.isSortingAsc = not self.Properties.ShowBuyContracts
  self.ItemSearchBar:SetSelectedCallback(self.OnSearchItemSelected, self)
  self.ItemFilter:SetCallback(self, function(self)
    self:UpdatePerkSelectionFilters()
    self:RefreshCurrentList()
  end)
  self.PostOrderPopup:SetOnCloseCallback(self, function(self)
    self:RefreshCurrentList()
  end)
  self.RefreshButton:SetCallback(function(self)
    self:RefreshCurrentList()
  end, self)
  self.RefreshButton:SetButtonSingleIconPath("lyshineui/images/icons/misc/icon_refresh.dds")
end
function ContractBrowser_BrowseTab:SetTabVisibility(isVisible, onScreenOpen)
  if isVisible == self.isVisible and not onScreenOpen then
    return
  end
  self.isVisible = isVisible
  if isVisible then
    self.isShowingBuyContracts = self.ShowBuyContracts
    UiElementBus.Event.SetIsEnabled(self.Properties.BuyersCheckboxContainer, self.isShowingBuyContracts)
    UiElementBus.Event.SetIsEnabled(self.Properties.SellersCheckboxContainer, not self.isShowingBuyContracts)
    self.ItemFilter:SetVisible(onScreenOpen)
    self.ScriptedEntityTweener:Play(self.Properties.ItemSearchBar, 0.2, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.2, {opacity = 0}, {
      opacity = 1,
      delay = 0.05,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.ItemFilter, 0.2, {opacity = 0}, {
      opacity = 1,
      delay = 0.1,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.ContractItemList, 0.2, {opacity = 0}, {
      opacity = 1,
      delay = 0.15,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.ContractItemGrid, 0.2, {opacity = 0}, {
      opacity = 1,
      delay = 0.15,
      ease = "QuadOut"
    })
  else
    if self.searchRequestId then
      contractsDataHandler:CancelRequest(self.searchRequestId)
    end
    self.paginationData:ClearCachedContracts()
    self.PerkSelectionPopup:SetPerkSelectionPopupVisibility(false)
    self.ItemSearchBar:ClearSearchField()
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, isVisible)
end
function ContractBrowser_BrowseTab:SetupContractItemList(contracts, noContractsTextOverride)
  self.contracts = contracts
  if self.enableContractsGrid then
    local numContracts = self.contracts and #self.contracts or 0
    local itemDescriptor = ItemDescriptor()
    for i = 1, numContracts do
      local contractData = self.contracts[i]
      contractData.numInBag = 0
      if contractData.itemId then
        local inventoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
        itemDescriptor.itemId = contractData.itemId
        if self.isShowingBuyContracts then
          contractData.numInBag = ContainerRequestBus.Event.GetItemCount(inventoryId, itemDescriptor, false, true, true)
        else
          contractData.numInBag = ContainerRequestBus.Event.GetItemCount(inventoryId, contractData.itemDescriptor, true, true, true)
        end
      end
      if not contractData.callbackSelf then
        contractData.callbackSelf = self
        contractData.callbackFn = self.OnContractSelected
        contractData.callbackData = i
      end
    end
    local noContractsData
    if numContracts == 0 then
      noContractsData = {}
      if noContractsTextOverride then
        noContractsData.label = noContractsTextOverride
      else
        noContractsData.label = self.isShowingBuyContracts and "@ui_no_existing_buy_contracts" or "@ui_no_existing_sell_contracts"
      end
      noContractsData.button1Data = {
        text = "@ui_refreshpage",
        callbackFn = self.RefreshCurrentList,
        callbackSelf = self
      }
      UiElementBus.Event.SetIsEnabled(self.Properties.PageNumberContainer, false)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.PageNumberContainer, true)
    end
    self.ContractItemGrid:OnListDataSet(self.contracts, noContractsData)
    return
  end
  self.ContractItemList:SetColumnHeaderData({
    {
      text = "@trade_column_name"
    },
    {
      text = "@trade_column_price",
      callbackSelf = self,
      callbackFn = contractsDataHandler:GetColumnSortFunc(eContractSortBy_Price),
      startAscending = self.currentSort == eContractSortBy_Price and self.isSortingAsc or nil
    },
    {
      text = "@cr_tier",
      callbackSelf = self,
      callbackFn = contractsDataHandler:GetColumnSortFunc(eContractSortBy_Tier),
      startAscending = self.currentSort == eContractSortBy_Tier and self.isSortingAsc or nil
    },
    {
      text = "@ui_contract_gearscore",
      callbackSelf = self,
      callbackFn = contractsDataHandler:GetColumnSortFunc(eContractSortBy_GearScore),
      startAscending = self.currentSort == eContractSortBy_GearScore and self.isSortingAsc or nil
    },
    {
      text = "@ui_gemsocket"
    },
    {
      text = "@crafting_perklabel"
    },
    {
      text = "@trade_column_rarity",
      callbackSelf = self,
      callbackFn = contractsDataHandler:GetColumnSortFunc(eContractSortBy_Rarity),
      startAscending = self.currentSort == eContractSortBy_Rarity and self.isSortingAsc or nil
    },
    {
      text = self.isShowingBuyContracts and "@ui_quant" or "@ui_avail",
      callbackSelf = self,
      callbackFn = contractsDataHandler:GetColumnSortFunc(eContractSortBy_Quantity),
      startAscending = self.currentSort == eContractSortBy_Quantity and self.isSortingAsc or nil
    },
    {
      text = "@trade_column_inbag"
    },
    {
      text = "@ui_contract_time",
      callbackSelf = self,
      callbackFn = contractsDataHandler:GetColumnSortFunc(eContractSortBy_ExpiresIn),
      startAscending = self.currentSort == eContractSortBy_ExpiresIn and self.isSortingAsc or nil
    },
    {
      text = "@trade_column_location"
    }
  })
  self.ContractItemList:SetContractPressedCallback(self, self.OnContractSelected)
  local listData = {}
  local numContracts = self.contracts and #self.contracts or 0
  local itemDescriptor = ItemDescriptor()
  for i = 1, numContracts do
    local contractData = self.contracts[i]
    contractData.numInBag = 0
    if contractData.itemId then
      local inventoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
      itemDescriptor.itemId = contractData.itemId
      if self.isShowingBuyContracts then
        contractData.numInBag = ContainerRequestBus.Event.GetItemCount(inventoryId, itemDescriptor, false, true, true)
      else
        contractData.numInBag = ContainerRequestBus.Event.GetItemCount(inventoryId, contractData.itemDescriptor, true, true, true)
      end
    end
    table.insert(listData, {
      callbackData = i,
      itemDescriptor = contractData.itemDescriptor,
      isDisabled = false,
      isLocalPlayerCreator = contractData.isLocalPlayerCreator,
      disableItemBackgrounds = contractData.contractType == eContractType_Buy,
      allowCompare = contractData.contractType == eContractType_Sell,
      tintColor = not contractData:CanEquipItem() and self.UIStyle.COLOR_RED or nil,
      columnData = {
        contractData.name,
        contractData:GetDisplayContractPrice(not self.isShowingBuyContracts),
        contractData:GetDisplayTier(),
        contractData:GetDisplayGearScore(),
        contractData:GetDisplaySocket(),
        contractData:GetDisplayPerks(),
        contractData:GetDisplayRarity(),
        tostring(contractData.quantity),
        tostring(contractData.numInBag),
        contractData.expiration,
        contractData.location
      }
    })
  end
  local noContractsData
  if numContracts == 0 then
    noContractsData = {}
    if noContractsTextOverride then
      noContractsData.label = noContractsTextOverride
    else
      noContractsData.label = self.isShowingBuyContracts and "@ui_no_existing_buy_contracts" or "@ui_no_existing_sell_contracts"
    end
    noContractsData.button1Data = {
      text = "@ui_refreshpage",
      callbackFn = self.RefreshCurrentList,
      callbackSelf = self
    }
    UiElementBus.Event.SetIsEnabled(self.Properties.PageNumberContainer, false)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.PageNumberContainer, true)
  end
  if self.Properties.IsSellTabAllItems then
    self.ContractItemList:SetColumnWidths({
      320,
      100,
      60,
      62,
      68,
      118,
      92,
      64,
      68,
      66,
      114
    })
  else
    self.ContractItemList:SetColumnWidths({
      354,
      144,
      60,
      62,
      68,
      118,
      92,
      64,
      68,
      66,
      114
    })
  end
  self.ContractItemList:OnListDataSet(listData, noContractsData)
end
function ContractBrowser_BrowseTab:OnContractSelected(index)
  local contractData = self.contracts[index]
  if contractData then
    self.TransactionPopup:SetConfirmationData(not self.isShowingBuyContracts, contractData, self, self.OnTransactionConfirmed)
  end
end
function ContractBrowser_BrowseTab:OnTransactionConfirmed(contractData, quantity)
  contractsDataHandler:FulfillContract(contractData, quantity, self, function(self)
    if not contractData.isNpcItem then
      contractsDataHandler:SetUpdatedQuantity(contractData, contractData.quantity - quantity)
      for i = #self.lastContracts, 1, -1 do
        local oldContractData = self.lastContracts[i]
        if oldContractData.contractId == contractData.contractId then
          oldContractData.quantity = oldContractData.quantity - quantity
          if oldContractData.quantity == 0 then
            table.remove(self.lastContracts, i)
          end
        end
      end
      self:SetupContractItemList(self.lastContracts)
    end
    self.TransactionPopup:SetConfirmPopupVisibility(false, true)
    local isSellContract = contractData.contractType == eContractType_Sell
    if isSellContract then
      DynamicBus.EncumbranceBus.Broadcast.PlayCraftAnimation("@ui_added_to_inventory", 3, contractData.itemDescriptor, quantity)
      self.audioHelper:PlaySound(self.audioHelper.Crafting_Inventory_Add)
    else
      self.audioHelper:PlaySound(self.audioHelper.Contracts_Sell)
      UiElementBus.Event.SetIsEnabled(self.Properties.CashInAnimation, true)
      UiFlipbookAnimationBus.Event.Start(self.Properties.CashInAnimation)
      self.ScriptedEntityTweener:Play(self.Properties.CashInAnimation, 0.3, {
        scaleX = 1,
        onComplete = function()
          self.ScriptedEntityTweener:Play(self.Properties.CashInAnimationGlow, 0.3, {
            opacity = 0,
            scaleY = 0,
            x = 40
          }, {
            opacity = 1,
            scaleY = 1,
            x = 17,
            delay = 0
          })
          self.ScriptedEntityTweener:Play(self.Properties.CashInAnimationGlow, 1, {opacity = 1}, {opacity = 0, delay = 0.1})
        end
      })
      self.ScriptedEntityTweener:Play(self.Properties.CashInAnimation, 1, {
        scaleY = 1,
        onComplete = function()
          UiElementBus.Event.SetIsEnabled(self.Properties.CashInAnimation, false)
        end
      })
    end
  end, function(self, reason)
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = contractsDataHandler:FailureReasonToString(reason)
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    self.TransactionPopup:SetConfirmSpinnerShowing(false)
  end)
end
function ContractBrowser_BrowseTab:OnSearchItemSelected(itemData)
  self.ItemFilter:SetSpecificItem(itemData)
end
function ContractBrowser_BrowseTab:OnShutdown()
  DynamicBus.ContractBrowser_BrowseTab.Disconnect(self.entityId, self)
end
function ContractBrowser_BrowseTab:RefreshCurrentList(paginationState, refreshingFromOutpostChange)
  if isPreviewDebug then
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Currency.Amount", 100000)
    local contracts = {}
    local itemDescriptor = ItemDescriptor()
    itemDescriptor.itemId = 2270771442
    for i = 1, 30 do
      table.insert(contracts, {
        name = "Contract" .. i,
        iconPath = "LyshineUI\\Images\\items\\1hSwordT5.png",
        price = 5 + i,
        quantity = 10 + i,
        expiration = "1h25m",
        location = GetRandomString(10),
        CanCompleteContract = function()
          return true
        end,
        isNpcItem = true
      })
    end
    self:SetupContractItemList(contracts)
    return
  end
  if refreshingFromOutpostChange then
    self.ItemFilter:SetFilter(self.ItemFilter.categoryKey, self.ItemFilter.familyKey, self.ItemFilter.groupKey, self.ItemFilter.tierKey, nil, self.ItemFilter.specificItem)
    return
  end
  self.paginationData.paginationState = paginationState
  local filter = SearchContractsRequest()
  filter.contractType = self.isShowingBuyContracts and eContractType_Buy or eContractType_Sell
  local outpostList = self.ContractBrowser:GetSelectedOutposts()
  for _, outpostId in pairs(outpostList) do
    filter.outposts:push_back(outpostId)
  end
  filter.countPerPage = self.paginationData:GetRequestSize()
  filter.sortOrder = self.currentSort
  filter.sortDescending = not self.isSortingAsc
  if self.ItemFilter:IsAtDeepestLevel() then
    local itemData = self.ItemFilter:GetFilterItem()
    filter.itemName = itemData.key
  end
  if self.selectedGem or self.selectedPerks then
    local perks = vector_basic_string_char_char_traits_char()
    if self.selectedGem then
      local perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(self.selectedGem)
      perks:push_back(perkData.key)
    end
    if self.selectedPerks then
      for perkId, _ in pairs(self.selectedPerks) do
        local perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(perkId)
        perks:push_back(perkData.key)
      end
    end
    filter:SetPerks(perks)
  end
  local currentKeys = self.ItemFilter:GetKeys()
  if currentKeys then
    filter.itemCategory = currentKeys[2]
    filter.itemFamily = currentKeys[3]
    filter.itemGroup = currentKeys[4]
    local tierNumber = tonumber(currentKeys[5])
    filter.itemTier = tierNumber ~= nil and tierNumber or -1
  end
  if not self.isShowingBuyContracts then
    if self.canAfford then
      local playerCurrency = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.Amount") or 0
      local maxPrice = math.ceil(playerCurrency / (1 + ContractsRequestBus.Broadcast.GetSellContractTransactionTax()))
      if maxPrice < GetMaxInt() then
        filter.maxPrice = maxPrice
      end
    end
    if self.canEquip then
      local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
      filter.maxGearScoresByRarity = ContractsRequestBus.Broadcast.GetMaxGearScoreForRarityFilterForPlayer()
    end
  elseif self.canSell then
  end
  self.ContractItemList:SetSpinnerShowing(true)
  if self.enableContractsGrid then
    self.ContractItemGrid:SetSpinnerShowing(true)
  end
  self.NextPageButton:SetIsClickable(false)
  self.PrevPageButton:SetIsClickable(false)
  if self.searchRequestId then
    contractsDataHandler:CancelRequest(self.searchRequestId)
    self.searchRequestId = nil
  end
  self.searchRequestId = contractsDataHandler:RequestSearchContracts(self, function(self, response)
    local rawContracts = response.contracts
    if not rawContracts then
      self:OnSearchFail()
      return
    end
    local contracts = contractsDataHandler:ContractsVectorToTable(rawContracts)
    self.lastContracts = contracts
    self:SetupContractItemList(contracts)
    UiTextBus.Event.SetText(self.Properties.ShowingResultsText, self.paginationData:GetPaginationText(#contracts, response.numTotalContracts))
    self.currentPage = self.paginationData:GetCurrentSearchPage()
    self.numPages = self.paginationData:GetNumTotalSearchPages()
    self.NextPageButton:SetIsClickable(self.currentPage < self.numPages)
    self.PrevPageButton:SetIsClickable(self.currentPage > 1)
  end, function(self, response)
    self:OnSearchFail(response)
  end, filter, self.paginationData)
end
function ContractBrowser_BrowseTab:InsertNpcContract(contracts, npcContract)
  table.insert(contracts, npcContract)
end
function ContractBrowser_BrowseTab:OnSearchFail(response)
  local enableNextPage = false
  local enablePrevPage = false
  if self.currentPage and self.numPages then
    enableNextPage = self.currentPage < self.numPages
    enablePrevPage = self.currentPage > 0
  end
  self.NextPageButton:SetIsClickable(enableNextPage)
  self.PrevPageButton:SetIsClickable(enablePrevPage)
  self.ContractItemList:SetSpinnerShowing(false)
  if self.enableContractsGrid then
    self.ContractItemGrid:SetSpinnerShowing(false)
  end
  local failReason = contractsDataHandler:FailureReasonToString(response)
  self:SetupContractItemList(nil, failReason)
end
function ContractBrowser_BrowseTab:PostOrder()
  self.ItemFilter:OpenOrderPopup(self.isShowingBuyContracts)
end
function ContractBrowser_BrowseTab:UpdatePerkSelectionFilters()
  if not self.enableBuyOrderRestrictions then
    return
  end
  if self.ItemFilter:IsAtDeepestLevel() then
    local itemData = self.ItemFilter:GetFilterItem()
    self.itemId = itemData.id
    local perkTierData = LocalPlayerUIRequestsBus.Broadcast.GetPerkTierData(itemData.tier)
    self.maxPerks = perkTierData:GetMaxPerksForGearScore(itemData.gearScoreRange.maxValue, false)
    self.maxPerkChannel = perkTierData.maxPerkChannel
  else
    self.itemId = nil
    self.maxPerks = nil
    self.maxPerkChannel = nil
  end
end
function ContractBrowser_BrowseTab:UpdateGemSelectionButtonText()
  if not self.selectedGem then
    self.GemSelectionButton:SetText("@ui_gem_selection_button_none")
  else
    local perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(self.selectedGem)
    local text = GetLocalizedReplacementText("@ui_gem_selection_button_specific", {
      name = perkData.displayName
    })
    self.GemSelectionButton:SetText(text, true)
  end
end
function ContractBrowser_BrowseTab:UpdatePerkSelectionButtonText()
  local numSelected = CountAssociativeTable(self.selectedPerks)
  if numSelected == 0 then
    self.PerkSelectionButton:SetText("@ui_perk_selection_button_none")
  else
    local text = GetLocalizedReplacementText("@ui_perk_selection_button_some", {number = numSelected})
    self.PerkSelectionButton:SetText(text, true)
  end
end
function ContractBrowser_BrowseTab:OpenGemSelectionPopup()
  self.PerkSelectionPopup:SetPerkSelectionPopupData({
    itemId = self.itemId,
    showAllPerks = true,
    maxPerkChannel = self.maxPerkChannel,
    selectedGem = self.selectedGem,
    showSelected = true,
    isSelectingGem = true,
    hideAny = true,
    callbackFunction = self.OnPerkSelected,
    callbackSelf = self,
    restoreHeader = true
  })
end
function ContractBrowser_BrowseTab:OpenPerkSelectionPopup()
  self.PerkSelectionPopup:SetPerkSelectionPopupData({
    itemId = self.itemId,
    showAllPerks = true,
    maxPerkChannel = self.maxPerkChannel,
    maxPerks = self.maxPerks,
    isMultiSelect = true,
    selectedPerks = self.selectedPerks,
    showSelected = true,
    isSelectingGem = false,
    hideAny = true,
    callbackFunction = self.OnPerkSelected,
    callbackSelf = self,
    restoreHeader = true
  })
end
function ContractBrowser_BrowseTab:OnPerkSelected(isSelectingGem, perkId)
  if isSelectingGem then
    if self.selectedGem == perkId then
      self.selectedGem = nil
    else
      self.selectedGem = perkId
    end
    self:UpdateGemSelectionButtonText()
  else
    self:UpdatePerkSelectionButtonText()
  end
  self.PerkSelectionPopup:SetPerkSelectionPopupVisibility(false)
  self:RefreshCurrentList()
end
return ContractBrowser_BrowseTab
