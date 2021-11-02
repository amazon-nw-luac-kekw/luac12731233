local ContractBrowser_SellTab = {
  Properties = {
    ItemSearchBar = {
      default = EntityId(),
      order = 1
    },
    ItemFilter = {
      default = EntityId(),
      order = 1
    },
    ContractItemList = {
      default = EntityId(),
      order = 1
    },
    InventoryList = {
      default = EntityId(),
      order = 1
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
    ContractBrowser = {
      default = EntityId(),
      order = 10
    },
    SelectedItemInfo = {
      default = EntityId(),
      order = 3
    },
    ItemIcon = {
      default = EntityId(),
      order = 3
    },
    ItemIconBg = {
      default = EntityId(),
      order = 3
    },
    ItemName = {
      default = EntityId(),
      order = 3
    },
    ItemRarity = {
      default = EntityId(),
      order = 3
    },
    ItemDescription = {
      default = EntityId(),
      order = 3
    },
    ItemDetailsContainer = {
      default = EntityId(),
      order = 3
    },
    ItemTierText = {
      default = EntityId(),
      order = 3
    },
    ItemGearScoreText = {
      default = EntityId(),
      order = 3
    },
    ItemNoGemSocketText = {
      default = EntityId(),
      order = 3
    },
    ItemGemIcon = {
      default = EntityId(),
      order = 3
    },
    ItemGemNameText = {
      default = EntityId(),
      order = 3
    },
    ItemNoPerksText = {
      default = EntityId(),
      order = 3
    },
    ItemPerksContainer = {
      default = EntityId(),
      order = 3
    },
    ItemPerkIcons = {
      default = {
        EntityId()
      },
      order = 3
    },
    ItemPerkNames = {
      default = {
        EntityId()
      },
      order = 3
    },
    PlaceSellOrderButton = {
      default = EntityId(),
      order = 3
    },
    PlaceBuyOrderButton = {
      default = EntityId(),
      order = 3
    },
    AvailableBuyOrdersHeader = {
      default = EntityId(),
      order = 3
    },
    AvailableBuyOrdersSeperator = {
      default = EntityId(),
      order = 3
    },
    SelectItemText = {
      default = EntityId()
    },
    HiddenItemsText = {
      default = EntityId()
    },
    PageNumberContainer = {
      default = EntityId()
    },
    RefreshButton = {
      default = EntityId()
    },
    MasterContainerInventory = {
      default = EntityId(),
      order = 11
    },
    MasterContainerAllItems = {
      default = EntityId(),
      order = 11
    },
    ListHeader = {
      default = EntityId(),
      order = 11
    },
    SecondaryTabs = {
      default = EntityId(),
      order = 12
    },
    SecondaryInventoryTab = {
      default = EntityId(),
      order = 12
    },
    BigFrame = {
      default = EntityId(),
      order = 13
    },
    CashInAnimation = {
      default = EntityId(),
      order = 15
    },
    CashInAnimationGlow = {
      default = EntityId(),
      order = 15
    }
  },
  itemListIsSortingAsc = true,
  itemListCurrentSort = "Name",
  isSortingAsc = false,
  currentSort = eContractSortBy_Price,
  itemHiResPath = "LyShineUI\\Images\\Icons\\Items_HiRes\\",
  onDyedItemWarningPopupEventId = "Popup_onDyedItemWarning"
}
local contractsDataHandler = RequireScript("LyShineUI._Common.ContractsDataHandler")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local ItemCommon = RequireScript("LyShineUI._Common.ItemCommon")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local isPreviewDebug = false
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ContractBrowser_SellTab)
function ContractBrowser_SellTab:OnInit()
  BaseElement.OnInit(self)
  self.paginationStates = contractsDataHandler.paginationStates
  local numContractsPerPage = 10
  local numPagesPerRequest = 10
  self.paginationData = contractsDataHandler:GetPaginationData(numContractsPerPage, numPagesPerRequest)
  self.inventoryItems = {}
  self.perkEntityIds = {}
  for i = 0, #self.Properties.ItemPerkIcons do
    local iconEntityId = self.Properties.ItemPerkIcons[i]
    local nameEntityId = self.Properties.ItemPerkNames[i]
    if iconEntityId and nameEntityId then
      table.insert(self.perkEntityIds, {icon = iconEntityId, name = nameEntityId})
    end
  end
  self.ItemFilter:SelectAllCategory()
  self.PlaceBuyOrderButton:SetButtonStyle(self.PlaceBuyOrderButton.BUTTON_STYLE_CTA)
  self.PlaceSellOrderButton:SetButtonStyle(self.PlaceSellOrderButton.BUTTON_STYLE_CTA)
  self.PostOrderPopup:SetOnCloseCallback(self, self.FillInventoryList)
  if isPreviewDebug then
    self.contracts = {}
    for i = 1, 30 do
      table.insert(self.contracts, {
        name = "Contract " .. i,
        itemId = "1h Sword T5",
        iconPath = "LyshineUI\\Images\\items\\1hSwordT5.png",
        price = 5 + i,
        quantity = 10 + i,
        expiration = "1h25m",
        location = GetRandomString(10)
      })
    end
    if #self.inventoryItems == 0 then
      for i = 1, 6 do
        table.insert(self.inventoryItems, {
          name = "Iron straight sword",
          iconPath = "LyshineUI\\Images\\items\\1hSwordT5.png",
          price = 5 + i,
          quantity = 100 + i,
          category = "Weapons"
        })
      end
      for i = 1, 6 do
        table.insert(self.inventoryItems, {
          name = "Oricalcum Soldier's breatplate",
          iconPath = "LyshineUI\\Images\\items\\LightChestT1.png",
          price = 5 + i,
          quantity = 10 + i,
          category = "Apparel"
        })
      end
      for i = 1, 6 do
        table.insert(self.inventoryItems, {
          name = "Steel Kite Shield",
          iconPath = "LyshineUI\\Images\\items\\OreT1.png",
          price = 5 + i,
          quantity = 15 + i,
          category = "Resources"
        })
      end
    end
  end
  self.NextPageButton:SetCallback(function(self)
    self:RefreshCurrentList(self.paginationStates.forward)
  end, self)
  self.PrevPageButton:SetCallback(function(self)
    self:RefreshCurrentList(self.paginationStates.back)
  end, self)
  if self.Properties.ItemSearchBar:IsValid() then
    self.ItemSearchBar:SetSelectedCallback(function(self, filterItem)
      if filterItem then
        self.InventoryList:SetSpinnerShowing(true)
        contractsDataHandler:RequestInventoryItemData(self, function(self, inventoryItems, hiddenDamagedItems)
          self.inventoryItems = inventoryItems
          self.hiddenDamagedItems = hiddenDamagedItems
          local numItems = self.inventoryItems and #self.inventoryItems or 0
          for i = numItems, 1, -1 do
            local itemData = self.inventoryItems[i]
            if itemData.itemCrcId ~= filterItem.id then
              table.remove(self.inventoryItems, i)
            end
          end
          self:ProcessInventoryList()
          self.InventoryList:SetSpinnerShowing(false)
        end)
      end
    end, self)
    local function endEditCallback()
      self.ItemSearchBar:ClearSearchField()
    end
    self.ItemSearchBar:SetEndEditCallback(endEditCallback, self)
  end
  self.ItemFilter:SetCallback(self, self.SetCategory)
  self.RefreshButton:SetCallback(function(self)
    self:RefreshCurrentList()
  end, self)
  self.RefreshButton:SetButtonSingleIconPath("lyshineui/images/icons/misc/icon_refresh.dds")
  self.InventoryList:SetColumnHeaderData({
    {
      text = "@trade_column_name",
      callbackSelf = self,
      callbackFn = self:GetItemSortFunction("Name"),
      startAscending = true
    },
    {
      text = "@trade_column_inbag",
      callbackSelf = self,
      callbackFn = self:GetItemSortFunction("Quantity")
    }
  })
  self.InventoryList:SetColumnWidths({380, 100})
  self.ContractItemList:SetColumnHeaderData({
    {
      text = "@trade_column_name"
    },
    {
      text = "@trade_column_price",
      callbackSelf = self,
      callbackFn = contractsDataHandler:GetColumnSortFunc(eContractSortBy_Price)
    },
    {
      text = "@ui_avail",
      callbackSelf = self,
      callbackFn = contractsDataHandler:GetColumnSortFunc(eContractSortBy_Quantity)
    },
    {
      text = "@ui_contract_time",
      callbackSelf = self,
      callbackFn = contractsDataHandler:GetColumnSortFunc(eContractSortBy_ExpiresIn)
    },
    {
      text = "@trade_column_location"
    },
    {text = ""}
  })
  self.ContractItemList:SetColumnWidths({
    420,
    120,
    80,
    100,
    120,
    160
  })
end
function ContractBrowser_SellTab:SetTabVisibility(isVisible)
  if isVisible == self.isVisible then
    return
  end
  self.isVisible = isVisible
  if isVisible then
    self.ScriptedEntityTweener:Play(self.Properties.SecondaryTabs, 0.2, {opacity = 0}, {
      opacity = 1,
      delay = 0.1,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.BigFrame, 0.2, {opacity = 0}, {
      opacity = 1,
      delay = 0.1,
      ease = "QuadOut"
    })
    self:OnInventoryTabSelected()
    local shouldBeEnabled, disableReason = contractsDataHandler:CanPlaceBuyOrder()
    self.PlaceBuyOrderButton:SetEnabled(shouldBeEnabled)
    local tooltip
    if not shouldBeEnabled then
      tooltip = disableReason
    end
    self.PlaceBuyOrderButton:SetTooltip(tooltip)
  else
    if self.searchRequestId then
      contractsDataHandler:CancelRequest(self.searchRequestId)
      self.searchRequestId = nil
    end
    self.paginationData:ClearCachedContracts()
    UiElementBus.Event.SetIsEnabled(self.Properties.SelectedItemInfo, false)
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.ContractItemList, false)
end
function ContractBrowser_SellTab:SetupInventoryList()
  self.InventoryList:SetContractPressedCallback(self, self.OnInventoryItemSelected)
  self.InventoryList:SetShowSelectionState(true)
  self:FillInventoryList()
end
function ContractBrowser_SellTab:ProcessInventoryList()
  self.itemListData = {}
  local numItems = self.inventoryItems and #self.inventoryItems or 0
  for i = 1, numItems do
    local itemData = self.inventoryItems[i]
    if self.category == nil or itemData.category == self.category then
      table.insert(self.itemListData, {
        callbackData = i,
        itemDescriptor = itemData.descriptor,
        perkIcons = self:GetPerkIcons(itemData.descriptor),
        columnData = {
          itemData.name,
          tostring(itemData.quantity)
        }
      })
    end
  end
  self:SortItemList()
end
function ContractBrowser_SellTab:GetPerkIcons(descriptor)
  local numPerks = descriptor:GetPerkCount()
  if numPerks == 0 then
    return nil
  else
    local perkIcons = {}
    for i = 0, numPerks - 1 do
      local perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(descriptor:GetPerk(i))
      if perkData:IsValid() and perkData.perkType ~= ePerkType_Gem and perkData.iconPath and 0 < string.len(perkData.iconPath) then
        local perkIconPath = "lyshineui/images/" .. perkData.iconPath .. ".dds"
        table.insert(perkIcons, perkIconPath)
      end
    end
    if 0 < #perkIcons then
      return perkIcons
    else
      return nil
    end
  end
end
function ContractBrowser_SellTab:GetCurrentItemIfAvailable()
  if self.selectedItem and (self.category == nil or self.selectedItem.category == self.category) then
    local numItems = self.inventoryItems and #self.inventoryItems or 0
    for i = 1, numItems do
      local inventoryItem = self.inventoryItems[i]
      if inventoryItem.itemId == self.selectedItem.itemId and inventoryItem.descriptor.gearScore == self.selectedItem.descriptor.gearScore and self:ItemPerksMatch(inventoryItem.descriptor, self.selectedItem.descriptor) then
        self.selectedItem = inventoryItem
        return self.selectedItem
      end
    end
  end
  return nil
end
function ContractBrowser_SellTab:ItemPerksMatch(itemDescriptor1, itemDescriptor2)
  local numPerks1 = itemDescriptor1:GetPerkCount()
  local numPerks2 = itemDescriptor2:GetPerkCount()
  if numPerks1 ~= numPerks2 then
    return true
  end
  for i = 0, numPerks1 - 1 do
    local requiredPerkId = itemDescriptor1:GetPerk(i)
    local hasRequiredPerk = false
    for j = 0, numPerks2 - 1 do
      local perkId = itemDescriptor2:GetPerk(j)
      if perkId == requiredPerkId then
        hasRequiredPerk = true
        break
      end
    end
    if not hasRequiredPerk then
      return false
    end
  end
  return true
end
function ContractBrowser_SellTab:FillInventoryList(fromContainerChangedEvent)
  self:SetSelectedItem(nil)
  if isPreviewDebug then
    self:ProcessInventoryList()
  else
    self.InventoryList:SetSpinnerShowing(true)
    contractsDataHandler:RequestInventoryItemData(self, function(self, inventoryItems, hiddenDamagedItems)
      self.inventoryItems = inventoryItems
      self.hiddenDamagedItems = hiddenDamagedItems
      self:SetSelectedItem(self:GetCurrentItemIfAvailable())
      self:ProcessInventoryList()
      self.InventoryList:SetSpinnerShowing(false)
    end)
  end
end
function ContractBrowser_SellTab:GetItemSortFunction(key)
  return function(self, isSortingAsc)
    self.itemListCurrentSort = key
    self.itemListIsSortingAsc = isSortingAsc
    self:SortItemList()
  end
end
function ContractBrowser_SellTab:SortItemList()
  local noItemsData
  if #self.itemListData == 0 then
    noItemsData = {}
    noItemsData.label = "@ui_noinventory"
    noItemsData.button1Data = nil
    noItemsData.button2Data = nil
  else
    local function compare(a, b)
      local compareA, compareB
      if self.itemListCurrentSort == "Name" then
        compareA = string.lower(LyShineScriptBindRequestBus.Broadcast.LocalizeText(a.columnData[1]))
        compareB = string.lower(LyShineScriptBindRequestBus.Broadcast.LocalizeText(b.columnData[1]))
      else
        compareA = tonumber(a.columnData[2])
        compareB = tonumber(b.columnData[2])
      end
      if self.itemListIsSortingAsc then
        return compareA < compareB
      else
        return compareA > compareB
      end
    end
    table.sort(self.itemListData, compare)
  end
  self.InventoryList:OnListDataSet(self.itemListData, noItemsData)
  self:FillContractItemList()
  self:RefreshCurrentList()
end
function ContractBrowser_SellTab:SetCategory(category)
  self.category = category
  self:FillInventoryList()
end
function ContractBrowser_SellTab:SetupContractItemList()
  self.ContractItemList:SetContractPressedCallback(self, self.OnContractSelected)
  self:SetSelectedItem(self:GetCurrentItemIfAvailable())
  self:FillContractItemList()
end
function ContractBrowser_SellTab:FillContractItemList(contracts, noContractsTextOverride)
  local listData = {}
  local numContracts = contracts and #contracts or 0
  for i = 1, numContracts do
    local contractData = contracts[i]
    table.insert(listData, {
      callbackData = i,
      itemDescriptor = contractData.itemDescriptor,
      isDisabled = false,
      isLocalPlayerCreator = contractData.isLocalPlayerCreator,
      disableItemBackgrounds = contractData.contractType == eContractType_Buy,
      allowCompare = contractData.contractType == eContractType_Sell,
      columnData = {
        contractData.name,
        contractData:GetDisplayContractPrice(),
        tostring(contractData.quantity),
        contractData.expiration,
        contractData.location,
        " "
      }
    })
  end
  self.contracts = contracts
  local noContractsData
  if #listData == 0 then
    noContractsData = {}
    if noContractsTextOverride then
      noContractsData.label = noContractsTextOverride
    elseif self.selectedItem == nil then
      noContractsData.label = "@trade_noitemmessage"
    else
      noContractsData.label = "@ui_no_existing_buy_contracts"
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.ListHeader, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.PageNumberContainer, false)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.ListHeader, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.PageNumberContainer, true)
  end
  if self.selectedItem == nil then
  else
    self.ContractItemList:OnListDataSet(listData, noContractsData)
  end
end
function ContractBrowser_SellTab:SetSelectedItem(selectedItem)
  self.selectedItem = selectedItem
  if self.selectedItem then
    UiElementBus.Event.SetIsEnabled(self.Properties.SelectedItemInfo, true)
    self.ScriptedEntityTweener:Play(self.Properties.SelectedItemInfo, 0.4, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ContractItemList, 0.4, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    local item = self.selectedItem
    local hiResPath = self.itemHiResPath .. item.rawIconPath .. ".dds"
    UiImageBus.Event.SetSpritePathnameIfExists(self.Properties.ItemIcon, hiResPath)
    UiTextBus.Event.SetTextWithFlags(self.Properties.ItemName, item.name, eUiTextSet_SetLocalized)
    local canHavePerks = ItemDataManagerBus.Broadcast.CanHavePerks(item.itemCrcId)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemDetailsContainer, canHavePerks)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemDescription, not canHavePerks)
    local rarityLevel = item.descriptor:GetRarityLevel()
    local rarityColor = self.UIStyle["COLOR_RARITY_LEVEL_" .. rarityLevel]
    if canHavePerks then
      local tierNumber = ItemDataManagerBus.Broadcast.GetTierNumber(item.itemCrcId)
      UiTextBus.Event.SetTextWithFlags(self.Properties.ItemTierText, GetRomanFromNumber(tierNumber), eUiTextSet_SetAsIs)
      local gearScore = tostring(item.descriptor:GetGearScore())
      UiTextBus.Event.SetTextWithFlags(self.Properties.ItemGearScoreText, gearScore, eUiTextSet_SetAsIs)
      local rarityName = "@RarityLevel" .. rarityLevel .. "_DisplayName"
      UiTextBus.Event.SetTextWithFlags(self.Properties.ItemRarity, rarityName, eUiTextSet_SetLocalized)
      UiTextBus.Event.SetColor(self.Properties.ItemRarity, rarityColor)
      local hasGemSocket = false
      local nonGemPerkIndex = 1
      local numPerks = item.descriptor:GetPerkCount()
      local perkDataTable = {}
      for i = 0, numPerks - 1 do
        local perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(item.descriptor:GetPerk(i))
        table.insert(perkDataTable, perkData)
      end
      table.sort(perkDataTable, function(perk1, perk2)
        return perk1.perkType == ePerkType_Inherent
      end)
      for _, perkData in ipairs(perkDataTable) do
        local perkIconPath = "lyshineui/images/" .. perkData.iconPath .. ".dds"
        if perkData.perkType == ePerkType_Gem then
          hasGemSocket = true
          UiImageBus.Event.SetSpritePathnameIfExists(self.Properties.ItemGemIcon, perkIconPath)
          UiTextBus.Event.SetTextWithFlags(self.Properties.ItemGemNameText, perkData.displayName, eUiTextSet_SetLocalized)
        elseif perkData.perkType == ePerkType_Inherent then
          local itemTable = StaticItemDataManager:GetTooltipDisplayInfo(item.descriptor, nil)
          local attributes = {}
          local perkMultiplier = perkData:GetPerkMultiplier(itemTable.gearScore)
          for _, attributeData in ipairs(ItemCommon.AttributeDisplayOrder) do
            local statValue = perkData:GetAttributeBonus(attributeData.stat, itemTable.gearScoreRangeMod, perkMultiplier)
            if statValue ~= 0 then
              table.insert(attributes, {
                amount = statValue,
                name = attributeData.name
              })
            end
          end
          local attributeString = ""
          for i = 1, #attributes do
            if 1 < i then
              attributeString = attributeString .. ", "
            end
            attributeString = attributeString .. attributes[i].name
          end
          local perkEntityData = self.perkEntityIds[nonGemPerkIndex]
          if perkEntityData then
            UiImageBus.Event.SetSpritePathname(perkEntityData.icon, "lyshineui/images/icons/misc/icon_attribute_arrow.dds")
            UiElementBus.Event.SetIsEnabled(perkEntityData.icon, true)
            UiTextBus.Event.SetTextWithFlags(perkEntityData.name, attributeString, eUiTextSet_SetLocalized)
            UiElementBus.Event.SetIsEnabled(perkEntityData.name, true)
          end
          nonGemPerkIndex = nonGemPerkIndex + 1
        else
          local perkEntityData = self.perkEntityIds[nonGemPerkIndex]
          if perkEntityData then
            UiImageBus.Event.SetSpritePathnameIfExists(perkEntityData.icon, perkIconPath)
            UiElementBus.Event.SetIsEnabled(perkEntityData.icon, true)
            UiTextBus.Event.SetTextWithFlags(perkEntityData.name, perkData.displayName, eUiTextSet_SetLocalized)
            UiElementBus.Event.SetIsEnabled(perkEntityData.name, true)
          end
          nonGemPerkIndex = nonGemPerkIndex + 1
        end
      end
      local hasNonGemPerks = 1 < nonGemPerkIndex
      UiElementBus.Event.SetIsEnabled(self.Properties.ItemGemIcon, hasGemSocket)
      UiElementBus.Event.SetIsEnabled(self.Properties.ItemNoGemSocketText, not hasGemSocket)
      UiElementBus.Event.SetIsEnabled(self.Properties.ItemPerksContainer, hasNonGemPerks)
      UiElementBus.Event.SetIsEnabled(self.Properties.ItemNoPerksText, not hasNonGemPerks)
      if hasNonGemPerks then
        for i = nonGemPerkIndex, #self.perkEntityIds do
          local perkEntityData = self.perkEntityIds[i]
          UiElementBus.Event.SetIsEnabled(perkEntityData.icon, false)
          UiElementBus.Event.SetIsEnabled(perkEntityData.name, false)
        end
      end
    else
      UiTextBus.Event.SetTextWithFlags(self.Properties.ItemDescription, LyShineScriptBindRequestBus.Broadcast.LocalizeWithDataSheetData(item.description), eUiTextSet_SetLocalized)
    end
    UiImageBus.Event.SetColor(self.Properties.ItemIconBg, rarityColor)
    UiElementBus.Event.SetIsEnabled(self.Properties.SelectItemText, false)
    self:ToggleNpcItemDisplay(false)
  else
    self:ToggleNpcItemDisplay(false)
    UiElementBus.Event.SetIsEnabled(self.Properties.SelectItemText, true)
    if self.selectedItem ~= nil then
      self.selectedItem:SetSelectedVisualState(false)
    end
    local showHiddenItemsText = self.hiddenDamagedItems and 0 < self.hiddenDamagedItems or false
    if showHiddenItemsText then
      if 1 < self.hiddenDamagedItems then
        local hiddenItemsText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_selltab_hiddenDamagedItems", tostring(self.hiddenDamagedItems))
        UiTextBus.Event.SetTextWithFlags(self.Properties.HiddenItemsText, hiddenItemsText, eUiTextSet_SetAsIs)
      else
        UiTextBus.Event.SetTextWithFlags(self.Properties.HiddenItemsText, "@ui_selltab_hiddenDamagedItemSingular", eUiTextSet_SetLocalized)
      end
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.HiddenItemsText, showHiddenItemsText)
    UiElementBus.Event.SetIsEnabled(self.Properties.ContractItemList, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.SelectedItemInfo, false)
  end
end
function ContractBrowser_SellTab:ToggleNpcItemDisplay(isNpcSellableItem)
  UiElementBus.Event.SetIsEnabled(self.Properties.ContractItemList, not isNpcSellableItem)
  UiElementBus.Event.SetIsEnabled(self.Properties.PlaceSellOrderButton, not isNpcSellableItem)
  UiElementBus.Event.SetIsEnabled(self.Properties.PlaceBuyOrderButton, not isNpcSellableItem)
  UiElementBus.Event.SetIsEnabled(self.Properties.AvailableBuyOrdersHeader, not isNpcSellableItem)
  UiElementBus.Event.SetIsEnabled(self.Properties.AvailableBuyOrdersSeperator, not isNpcSellableItem)
end
function ContractBrowser_SellTab:OnInventoryItemSelected(index)
  self:SetSelectedItem(self.inventoryItems[index])
  self:RefreshCurrentList()
end
function ContractBrowser_SellTab:OnContractSelected(index)
  local contractData = self.contracts[index]
  if contractData then
    self.TransactionPopup:SetConfirmationData(false, contractData, self, self.OnTransactionConfirmed, self.selectedItem)
  end
end
function ContractBrowser_SellTab:OnTransactionConfirmed(contractData, quantity)
  contractsDataHandler:FulfillContract(contractData, quantity, self, function(self)
    self.TransactionPopup:SetConfirmPopupVisibility(false, true)
    self:RefreshCurrentList()
    self.audioHelper:PlaySound(self.audioHelper.Crafting_Inventory_Add)
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
  end, function(self, reason)
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = contractsDataHandler:FailureReasonToString(reason)
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    self.TransactionPopup:SetConfirmSpinnerShowing(false)
  end)
end
function ContractBrowser_SellTab:OnShutdown()
end
function ContractBrowser_SellTab:OnInventoryTabSelected(entityId)
  self.ItemFilter:SelectCategory(self.category)
  self:SetSelectedItem(nil)
  self:SetupInventoryList()
  self:SetupContractItemList()
  UiElementBus.Event.SetIsEnabled(self.Properties.SelectItemText, true)
  self.ScriptedEntityTweener:Play(self.Properties.MasterContainerInventory, 0.2, {opacity = 0}, {
    opacity = 1,
    delay = 0.05,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.ItemFilter, 0.2, {opacity = 0}, {
    opacity = 1,
    delay = 0.1,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.SelectedItemInfo, 0.2, {opacity = 0}, {
    opacity = 1,
    delay = 0.1,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.ContractItemList, 0.2, {opacity = 0}, {
    opacity = 1,
    delay = 0.15,
    ease = "QuadOut"
  })
  UiRadioButtonGroupCommunicationBus.Event.RequestRadioButtonStateChange(self.Properties.SecondaryTabs, self.Properties.SecondaryInventoryTab, true)
  self.MasterContainerAllItems:SetTabVisibility(false)
end
function ContractBrowser_SellTab:OnAllItemsTabSelected(entityId)
  self.MasterContainerAllItems:SetTabVisibility(true)
  self.ScriptedEntityTweener:Set(self.Properties.MasterContainerInventory, {opacity = 0})
  UiElementBus.Event.SetIsEnabled(self.Properties.SelectedItemInfo, false)
end
function ContractBrowser_SellTab:RefreshCurrentList(paginationState)
  if isPreviewDebug then
    local contracts = {}
    for i = 1, 30 do
      table.insert(contracts, {
        name = "Contract" .. i,
        iconPath = "LyshineUI\\Images\\items\\1hSwordT5.png",
        price = 5 + i,
        quantity = 10 + i,
        expiration = "1h25m",
        location = GetRandomString(10),
        itemId = "MediumHandsAT2"
      })
    end
    self:FillContractItemList(contracts)
    return
  end
  self.paginationData.paginationState = paginationState
  local inventoryItemData = self.selectedItem
  if not inventoryItemData then
    return
  end
  local filter = SearchContractsRequest()
  filter.contractType = eContractType_Buy
  filter.outposts:push_back(self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.OutpostId"))
  filter.minPrice = 0
  filter.countPerPage = self.paginationData:GetRequestSize()
  filter.sortOrder = self.currentSort
  filter.sortDescending = not self.isSortingAsc
  filter.itemName = self.selectedItem.itemId
  self.ContractItemList:SetSpinnerShowing(true)
  self.NextPageButton:SetIsClickable(false)
  self.PrevPageButton:SetIsClickable(false)
  if self.searchRequestId then
    contractsDataHandler:CancelRequest(self.searchRequestId)
  end
  self.searchRequestId = contractsDataHandler:RequestSearchContracts(self, function(self, response)
    local rawContracts = response.contracts
    if not rawContracts then
      self:OnSearchFail()
      return
    end
    local contracts = contractsDataHandler:ContractsVectorToTable(rawContracts)
    self:FillContractItemList(contracts)
    UiTextBus.Event.SetText(self.Properties.ShowingResultsText, self.paginationData:GetPaginationRangeText(#contracts, response.numTotalContracts))
    self.currentPage = self.paginationData:GetCurrentSearchPage()
    self.numPages = self.paginationData:GetNumTotalSearchPages()
    self.NextPageButton:SetIsClickable(self.currentPage < self.numPages)
    self.PrevPageButton:SetIsClickable(self.currentPage > 1)
    self.ContractItemList:SetSpinnerShowing(false)
  end, function(self, response)
    self:OnSearchFail(response)
  end, filter, self.paginationData)
end
function ContractBrowser_SellTab:OnSearchFail(response)
  local enableNextPage = false
  local enablePrevPage = false
  if self.currentPage and self.numPages then
    enableNextPage = self.currentPage < self.numPages
    enablePrevPage = self.currentPage > 0
  end
  self.NextPageButton:SetIsClickable(enableNextPage)
  self.PrevPageButton:SetIsClickable(enablePrevPage)
  self.ContractItemList:SetSpinnerShowing(false)
  local failReason = contractsDataHandler:FailureReasonToString(response)
  self:FillContractItemList(nil, failReason)
end
function ContractBrowser_SellTab:PostOrder()
  self:OpenPostOrderPopup(false)
end
function ContractBrowser_SellTab:PostBuyOrder()
  if self.PlaceBuyOrderButton.mIsEnabled then
    self:OpenPostOrderPopup(true)
  end
end
function ContractBrowser_SellTab:OpenPostOrderPopup(isBuyOrder)
  if self.selectedItem then
    if self.selectedItem.isDyed then
      self.popupData = {isBuyOrder = isBuyOrder}
      PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_selltab_dyed_item_warning_title", "@ui_selltab_dyed_item_warning_text", self.onDyedItemWarningPopupEventId, self, self.OnPopupResult)
      return
    end
    if isBuyOrder then
      local descriptor = ItemDescriptor()
      descriptor.itemId = self.selectedItem.descriptor.itemId
      descriptor.gearScore = self.selectedItem.descriptor.gearScore
      self.PostOrderPopup:SetPostOrderPopupData(isBuyOrder, descriptor)
    else
      self.PostOrderPopup:SetPostOrderPopupData(isBuyOrder, self.selectedItem.descriptor, {
        itemList = {
          self.selectedItem
        }
      })
    end
  end
end
function ContractBrowser_SellTab:OnPopupResult(result, eventId)
  if result == ePopupResult_Yes and eventId == self.onDyedItemWarningPopupEventId then
    self.PostOrderPopup:SetPostOrderPopupData(self.popupData.isBuyOrder, self.selectedItem.descriptor, {
      itemList = {
        self.selectedItem
      }
    })
  end
  self.popupData = nil
end
function ContractBrowser_SellTab:OnSellAll()
  local disableForNow = true
  if disableForNow then
    return
  end
  local inventoryItemData = self.selectedItem
  if not inventoryItemData then
    return
  end
  local filter = SearchContractsRequest()
  filter.contractType = eContractType_Buy
  filter.outposts:push_back(self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.OutpostId"))
  filter.countPerPage = 10
  filter.sortOrder = eContractSortBy_Price
  filter.sortDescending = true
  filter.itemName = inventoryItemData.itemId
  local quantityToSell = inventoryItemData.quantity
  contractsDataHandler:RequestSearchContracts(self, function(self, response)
    local rawContracts = response.contracts
    if not rawContracts then
      return
    end
    local contracts = contractsDataHandler:ContractsVectorToTable(rawContracts)
    local contractsToOperateOn = {}
    for _, contractData in ipairs(contracts) do
      local quantityToTakeFromThisContract = 0
      if 0 < contractData.quantity then
        if quantityToSell <= contractData.quantity then
          quantityToTakeFromThisContract = quantityToSell
        else
          quantityToTakeFromThisContract = contractData.quantity
        end
        table.insert(contractsToOperateOn, {contractData = contractData, quantity = quantityToTakeFromThisContract})
        quantityToSell = quantityToSell - quantityToTakeFromThisContract
        if quantityToSell <= 0 then
          break
        end
      end
    end
    local completedContractResponses = 0
    for _, operationData in pairs(contractsToOperateOn) do
      operationData.contractData.itemDescriptor = inventoryItemData.descriptor
      contractsDataHandler:FulfillContract(operationData.contractData, operationData.quantity, self, function(self, response)
        completedContractResponses = completedContractResponses + 1
        if completedContractResponses == #contractsToOperateOn then
          self:SetupInventoryList()
          self:SetupContractItemList()
        end
      end, function(self, response)
        completedContractResponses = completedContractResponses + 1
        if completedContractResponses == #contractsToOperateOn then
          self:SetupInventoryList()
          self:SetupContractItemList()
        end
      end)
    end
  end, nil, filter, nil)
end
return ContractBrowser_SellTab
