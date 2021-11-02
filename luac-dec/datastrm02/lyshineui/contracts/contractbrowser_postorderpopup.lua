local DEFAULT_UNIT_PRICE = 10000
local ContractBrowser_PostOrderPopup = {
  Properties = {
    FrameHeader = {
      default = EntityId()
    },
    ContractItemList = {
      default = EntityId()
    },
    BuyOrderRestrictionsContainer = {
      default = EntityId()
    },
    MinGearScoreLabel = {
      default = EntityId()
    },
    MinGearScoreText = {
      default = EntityId()
    },
    MinGearScoreSlider = {
      default = EntityId()
    },
    PerkSelectionContainer = {
      default = EntityId()
    },
    PerkSelectorsContainer = {
      default = EntityId()
    },
    PerkSelectionPopup = {
      default = EntityId()
    },
    PerksLabel = {
      default = EntityId()
    },
    RarityText = {
      default = EntityId()
    },
    GemSelector = {
      default = EntityId()
    },
    QuantityLabel = {
      default = EntityId()
    },
    QuantitySlider = {
      default = EntityId()
    },
    DurationDropdown = {
      default = EntityId()
    },
    DurationLabel = {
      default = EntityId()
    },
    UnitPriceLabelWithTextInput = {
      default = EntityId()
    },
    BuyFeeText = {
      default = EntityId()
    },
    SellFeeText = {
      default = EntityId()
    },
    TotalText = {
      default = EntityId()
    },
    TotalLabel = {
      default = EntityId()
    },
    BalanceText = {
      default = EntityId()
    },
    MaxCoinWarning = {
      default = EntityId()
    },
    MaxCoinWarningTooltip = {
      default = EntityId()
    },
    DividerTop = {
      default = EntityId()
    },
    DividerBottom = {
      default = EntityId()
    },
    ConfirmButton = {
      default = EntityId()
    },
    CancelButton = {
      default = EntityId()
    },
    ButtonClose = {
      default = EntityId()
    },
    ErrorText = {
      default = EntityId()
    },
    SellersLabel = {
      default = EntityId()
    },
    ListingFeeLabel = {
      default = EntityId()
    },
    SellersItemList = {
      default = EntityId()
    },
    SellersItemListContainer = {
      default = EntityId()
    },
    BuyersLabel = {
      default = EntityId()
    },
    BuyersItemList = {
      default = EntityId()
    },
    BuyersItemListContainer = {
      default = EntityId()
    },
    PriceHelpIcon = {
      default = EntityId()
    },
    MasterContainer = {
      default = EntityId()
    },
    BlackBackground = {
      default = EntityId()
    },
    BalanceContainer = {
      default = EntityId()
    },
    ButtonContainer = {
      default = EntityId()
    },
    InfoContainer = {
      default = EntityId()
    },
    InventoryItemBg = {
      default = EntityId()
    },
    InstantTransaction = {
      Label = {
        default = EntityId()
      },
      Button = {
        default = EntityId()
      },
      Header = {
        default = EntityId()
      },
      CenterLine = {
        default = EntityId()
      }
    },
    AdjustedPriceContainer = {
      default = EntityId()
    },
    AdjustedPriceFee = {
      default = EntityId()
    },
    AdjustedPriceEarnings = {
      default = EntityId()
    }
  },
  currency = 0,
  quantity = 0,
  maxQuantity = 0,
  unitPrice = DEFAULT_UNIT_PRICE,
  numInBag = 0,
  duration = 0,
  fee = 0,
  icon = "",
  iconPath = "LyshineUI\\Images\\icons\\items\\%s.png",
  itemDescriptor = ItemDescriptor(),
  searchRequests = {},
  enableInstantTransaction = false
}
local isPreviewDebug = false
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ContractBrowser_PostOrderPopup)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local contractsDataHandler = RequireScript("LyShineUI._Common.ContractsDataHandler")
local inventoryCommon = RequireScript("LyShineUI._Common.InventoryCommon")
local popupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local itemCommon = RequireScript("LyShineUI._Common.ItemCommon")
local TooltipCommon = RequireScript("LyShineUI._Common.TooltipCommon")
function ContractBrowser_PostOrderPopup:OnInit()
  BaseElement.OnInit(self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.enable-buy-order-restrictions", function(self, enableBuyOrderRestrictions)
    self.enableBuyOrderRestrictions = enableBuyOrderRestrictions
    UiElementBus.Event.SetIsEnabled(self.Properties.BuyOrderRestrictionsContainer, enableBuyOrderRestrictions)
  end)
  self.playerWalletCap = ConfigProviderEventBus.Broadcast.GetUInt64("javelin.wallet-cap-player")
  self.ConfirmButton:SetText("@ui_placeorder")
  self.ConfirmButton:SetCallback(self.OnAccept, self)
  self.ConfirmButton:SetButtonStyle(self.ConfirmButton.BUTTON_STYLE_CTA)
  self.CancelButton:SetText("@ui_cancel")
  self.CancelButton:SetCallback(self.OnClose, self)
  self.ButtonClose:SetCallback(self.OnClose, self)
  self.InstantTransaction.Button:SetButtonStyle(self.InstantTransaction.Button.BUTTON_STYLE_CTA)
  self.MinGearScoreSlider:HideCrownIcons()
  self.MinGearScoreSlider:SetCallback(self.OnMinGearScoreSliderChanged, self)
  self.QuantitySlider:HideCrownIcons()
  self.QuantitySlider:SetCallback(self.OnQuantityChanged, self)
  self.UnitPriceLabelWithTextInput:SetLabel("@ui_unitprice")
  self.UnitPriceLabelWithTextInput:SetOnChangeCallback(self, self.OnUnitPriceChanged)
  self.UnitPriceLabelWithTextInput:SetCallback(self, function(self, currentText)
    local success = false
    currentText, success = GetCurrencyValueFromLocalized(currentText)
    if not success then
      currentText = 0
      self.unitPrice = 0
      self:UpdateTotalValue()
    end
    self.UnitPriceLabelWithTextInput:SetInputValue(GetLocalizedCurrency(currentText, true))
  end)
  self.UnitPriceLabelWithTextInput:SetMaxStringLength(20)
  self.perkSelectors = {}
  local children = UiElementBus.Event.GetChildren(self.Properties.PerkSelectorsContainer)
  for i = 1, #children do
    local perkSelector = self.registrar:GetEntityTable(children[i])
    perkSelector:SetCallbacks(self.OnPerkSelectorSelect, self.OnPerkSelectorRemove, self)
    table.insert(self.perkSelectors, perkSelector)
  end
  self.GemSelector:SetIsGemSelector(true)
  self.GemSelector:SetCallbacks(self.OnGemSelectorSelect, self.OnGemSelectorRemove, self)
  self.DurationDropdown:SetWidth(380)
  self.DurationDropdown:SetDropdownScreenCanvasId(self.entityId)
  self.DurationDropdown:SetCallback("OnDurationChanged", self)
  self.QuantitySlider:SetSliderMinValue(1)
  self.PriceHelpIcon:SetButtonStyle(self.PriceHelpIcon.BUTTON_STYLE_QUESTION_MARK)
  self.PriceHelpIcon:SetFocusCallback(self.OnPriceHelpFocus, self)
  self.PriceHelpIcon:SetUnfocusCallback(self.OnPriceHelpUnfocus, self)
  local coinCappedTooltip = GetLocalizedReplacementText("@ui_coin_max_sellorder_tooltip", {
    amount = GetLocalizedCurrency(self.playerWalletCap)
  })
  self.MaxCoinWarningTooltip:SetButtonStyle(self.MaxCoinWarningTooltip.BUTTON_STYLE_QUESTION_MARK)
  self.MaxCoinWarningTooltip:SetTooltip(coinCappedTooltip)
  if isPreviewDebug then
    self.currency = 134567
    local isBuyOrder = true
    local itemDescriptor = ItemDescriptor()
    itemDescriptor.itemId = 2675973976
    self:SetPostOrderPopupData(isBuyOrder, itemDescriptor)
  end
end
function ContractBrowser_PostOrderPopup:SetPostOrderPopupData(isBuyOrder, itemDescriptor, optionalParams)
  optionalParams = optionalParams or {}
  local quantity = tonumber(optionalParams.quantity) or 1
  local unitPrice = optionalParams.unitPrice or self.unitPrice
  unitPrice = unitPrice or DEFAULT_UNIT_PRICE
  local duration = optionalParams.duration
  local itemList = optionalParams.itemList
  self.currency = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.Amount")
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Currency.Amount", function(self, currencyAmount)
    self.currency = currencyAmount
    self:UpdateNewBalance()
    self:ValidateConfirmButton()
  end)
  self.isBuyOrder = isBuyOrder
  self.UnitPriceLabelWithTextInput:SetLabel(self.isBuyOrder and "@ui_unitprice" or "@ui_listingunitprice")
  self.quantity = quantity
  self.unitPrice = unitPrice
  self.UnitPriceLabelWithTextInput:SetInputValue(GetLocalizedCurrency(self.unitPrice, true))
  self.numInBag = inventoryCommon:GetInventoryItemCount(itemDescriptor)
  if isPreviewDebug then
    self.numInBag = 7
  end
  self.itemDescriptor.itemId = itemDescriptor.itemId
  self.itemDescriptor.gearScore = itemDescriptor.gearScore
  self.itemDescriptor:SetPerks(itemCommon:GetPerks(itemDescriptor))
  local itemData = ItemDataManagerBus.Broadcast.GetItemData(self.itemDescriptor.itemId)
  self.icon = itemData.itemType .. "/" .. itemData.icon
  if self.enableBuyOrderRestrictions then
    local maxGearScore = 0
    local usesGearScore = isBuyOrder and itemDescriptor:UsesGearScore()
    UiElementBus.Event.SetIsEnabled(self.Properties.MinGearScoreLabel, usesGearScore)
    if usesGearScore then
      local gearScoreRange = itemData.gearScoreRange
      local minGearScore = gearScoreRange.minValue
      maxGearScore = gearScoreRange.maxValue
      if minGearScore > self.itemDescriptor.gearScore then
        self.itemDescriptor.gearScore = minGearScore
      end
      local rangeIsZero = minGearScore == maxGearScore
      UiElementBus.Event.SetIsEnabled(self.Properties.MinGearScoreText, rangeIsZero)
      UiElementBus.Event.SetIsEnabled(self.Properties.MinGearScoreSlider, not rangeIsZero)
      if rangeIsZero then
        UiTextBus.Event.SetTextWithFlags(self.Properties.MinGearScoreText, tostring(self.itemDescriptor.gearScore), eUiTextSet_SetAsIs)
      else
        self.MinGearScoreSlider:SetSliderMinValue(minGearScore)
        self.MinGearScoreSlider:SetSliderMaxValue(maxGearScore)
        self.MinGearScoreSlider:SetSliderValue(self.itemDescriptor.gearScore)
      end
    end
    local inherentPerks = itemData:GetNumPossibleInherentPerks()
    local perkTierData = LocalPlayerUIRequestsBus.Broadcast.GetPerkTierData(itemData.tier)
    self.maxPerks = perkTierData:GetMaxPerksForGearScore(maxGearScore, false) - inherentPerks
    self.maxPerkChannel = perkTierData.maxPerkChannel
    local isNamedItem = 0 < itemData:GetPerkCount() and itemData:GetPerkBucketCount() == 0
    self.canHavePerks = isBuyOrder and itemData.canHavePerks
    local showOnlyGem = isNamedItem and itemData:HasGem()
    self.itemPerkCount = itemData:GetPerkCount()
    UiElementBus.Event.SetIsEnabled(self.Properties.PerkSelectionContainer, self.canHavePerks and (isNamedItem and showOnlyGem or not isNamedItem))
    UiElementBus.Event.SetIsEnabled(self.Properties.PerkSelectorsContainer, not showOnlyGem)
    UiElementBus.Event.SetIsEnabled(self.Properties.PerksLabel, not showOnlyGem)
    if self.canHavePerks then
      self:SetRarityText(0)
      self.GemSelector:SetPerkSelectorData(self.GemSelector.SELECT_BUTTON_ID)
      self:ResetPerkSelectors()
    end
    if showOnlyGem then
      local rarity = PlayerDataManagerBus.Broadcast.GetItemRarityLevel(itemData:GetPerkCount())
      self:SetRarityText(rarity)
    end
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.BuyFeeText, isBuyOrder)
  UiElementBus.Event.SetIsEnabled(self.Properties.ListingFeeLabel, not isBuyOrder)
  UiElementBus.Event.SetIsEnabled(self.Properties.TotalLabel, isBuyOrder)
  UiTransformBus.Event.SetLocalPositionY(self.Properties.SellersLabel, isBuyOrder and 290 or 2)
  UiTransformBus.Event.SetLocalPositionY(self.Properties.SellersItemListContainer, isBuyOrder and 343 or 40)
  UiTransformBus.Event.SetLocalPositionY(self.Properties.BuyersLabel, isBuyOrder and 2 or 290)
  UiTransformBus.Event.SetLocalPositionY(self.Properties.BuyersItemListContainer, isBuyOrder and 56 or 343)
  local noContractsData = {}
  noContractsData.label = "@ui_no_existing_sell_contracts"
  self.SellersItemList:OnListDataSet(nil, noContractsData)
  noContractsData.label = "@ui_no_existing_buy_contracts"
  self.BuyersItemList:OnListDataSet(nil, noContractsData)
  local headerTag = isBuyOrder and "@ui_placebuyorder" or "@ui_placesellorder"
  self.FrameHeader:SetText(headerTag)
  UiElementBus.Event.SetIsEnabled(self.Properties.InventoryItemBg, not isBuyOrder)
  UiElementBus.Event.SetIsEnabled(self.Properties.AdjustedPriceContainer, not isBuyOrder)
  if isBuyOrder then
    UiTransformBus.Event.SetLocalPositionY(self.Properties.InfoContainer, 214)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.QuantityLabel, 88)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.DurationLabel, 158)
  else
    UiTransformBus.Event.SetLocalPositionY(self.Properties.InfoContainer, 307)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.QuantityLabel, 224)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.DurationLabel, 300)
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.QuantityLabel, isBuyOrder and "@ui_howmany" or "@ui_quantity", eUiTextSet_SetLocalized)
  self.QuantitySlider:SetSliderValue(self.quantity)
  self.UnitPriceLabelWithTextInput:SetInputValue(GetLocalizedCurrency(self.unitPrice, true))
  self.userChangedUnitPrice = false
  local durationsList = {}
  local durations
  if isPreviewDebug then
    durations = {
      1,
      3,
      5,
      10
    }
  else
    durations = Contract.GetValidContractDurations(self.isBuyOrder and eContractType_Buy or eContractType_Sell)
  end
  local daysToSecondsConst = timeHelpers.hoursInDay * timeHelpers.minutesInHour * timeHelpers.secondsInMinute
  local defaultDuration = Contract.GetDefaultContractDurationDays()
  local defaultDurationIndex = 0
  for i = 1, #durations do
    local duration = durations[i]
    table.insert(durationsList, {
      duration = duration,
      text = LyShineScriptBindRequestBus.Broadcast.LocalizeText(timeHelpers:ConvertToVerboseDurationString(duration * daysToSecondsConst))
    })
    if duration == defaultDuration then
      defaultDurationIndex = i
    end
  end
  if defaultDurationIndex == 0 then
    Log("Warning: Contract.GetDefaultContractDurationDays() did not return a valid duration!")
    defaultDurationIndex = 1
  end
  self.DurationDropdown:SetListData(durationsList)
  self.DurationDropdown:SetSelectedItemData(durationsList[defaultDurationIndex])
  if duration == nil or duration == 0 then
    self.duration = durationsList[defaultDurationIndex].duration
  else
    self.duration = duration
  end
  self:SetupItemDetail(itemDescriptor, itemList)
  self:UpdateTotalValue()
  self:UpdateMaxQuantity()
  self:SetupOtherList(true)
  self:SetupOtherList(false)
  self:SetVisibility(true)
end
function ContractBrowser_PostOrderPopup:SetVisibility(isVisible, closeForResponse)
  self.isVisible = isVisible
  local isEnabled = UiElementBus.Event.IsEnabled(self.entityId)
  if isEnabled ~= isVisible then
    if isVisible then
      self.audioHelper:PlaySound(self.audioHelper.Contracts_Popup_Show)
      UiElementBus.Event.SetIsEnabled(self.entityId, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.BlackBackground, true)
      self.ScriptedEntityTweener:Play(self.Properties.BlackBackground, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
      self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.3, {opacity = 0, y = -10}, {
        opacity = 1,
        y = 0,
        ease = "QuadOut",
        delay = 0.2
      })
      DynamicBus.StationPropertiesBus.Broadcast.SetTransparent(true)
      DynamicBus.StationPropertiesBus.Broadcast.SetBackgroundTransparent(true)
      self:SetConfirmSpinnerShowing(false)
    else
      for key, requestId in pairs(self.searchRequests) do
        contractsDataHandler:CancelRequest(requestId)
        self.searchRequests[key] = nil
      end
      self.isClosing = true
      self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.3, {opacity = 1, y = 0}, {
        opacity = 0,
        y = -10,
        ease = "QuadOut"
      })
      self.ScriptedEntityTweener:Play(self.Properties.BlackBackground, 0.3, {opacity = 1}, {
        opacity = 0,
        ease = "QuadOut",
        onComplete = function()
          if closeForResponse then
            self:SetConfirmSpinnerShowing(false)
          end
          UiElementBus.Event.SetIsEnabled(self.Properties.BlackBackground, false)
          UiElementBus.Event.SetIsEnabled(self.entityId, false)
          self.isClosing = false
        end
      })
      DynamicBus.StationPropertiesBus.Broadcast.SetTransparent(false)
      DynamicBus.StationPropertiesBus.Broadcast.SetBackgroundTransparent(false)
      UiDropdownBus.Event.Collapse(self.Properties.DurationDropdown)
      if not closeForResponse then
        self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Currency.Amount")
      end
      DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
    end
    if isVisible == false and self.onCloseCallbackData then
      self.onCloseCallbackData.callbackFn(self.onCloseCallbackData.callbackSelf)
    end
    self.PerkSelectionPopup:SetPerkSelectionPopupVisibility(false)
  end
end
function ContractBrowser_PostOrderPopup:IsVisible()
  return self.isVisible
end
function ContractBrowser_PostOrderPopup:UpdateGemAndAddPerkButtons()
  local numSelectedGems = self.GemSelector:HasSelection() and 1 or 0
  local maxPerksSelectors = self.maxPerks - numSelectedGems
  local addPerkButton
  local numSelectedPerks = 0
  for i, perkSelector in ipairs(self.perkSelectors) do
    if perkSelector:HasSelection() then
      numSelectedPerks = numSelectedPerks + 1
    elseif perkSelector:IsSelectButton() then
      addPerkButton = perkSelector
    end
  end
  if not addPerkButton and maxPerksSelectors > numSelectedPerks then
    local newAddPerkButtonIndex = numSelectedPerks + 1
    local nextPerkSelector = self.perkSelectors[newAddPerkButtonIndex]
    if nextPerkSelector and not nextPerkSelector:IsSelectButton() then
      nextPerkSelector:SetPerkSelectorData(nextPerkSelector.SELECT_BUTTON_ID)
    end
    addPerkButton = nextPerkSelector
  end
  if numSelectedGems + numSelectedPerks == self.maxPerks then
    if 0 < numSelectedGems then
      if addPerkButton then
        addPerkButton:SetEnabled(false)
      end
    else
      self.GemSelector:SetEnabled(false)
    end
  else
    self.GemSelector:SetEnabled(true)
    if addPerkButton then
      addPerkButton:SetEnabled(true)
    end
  end
end
function ContractBrowser_PostOrderPopup:UpdateRarityText()
  local numPerks = self.itemPerkCount
  if numPerks == 0 then
    if self.GemSelector:HasSelection() then
      numPerks = numPerks + 1
    end
    for i = 1, #self.perkSelectors do
      local perkSelector = self.perkSelectors[i]
      if perkSelector:HasSelection() then
        numPerks = numPerks + 1
      end
    end
  end
  local rarity = PlayerDataManagerBus.Broadcast.GetItemRarityLevel(numPerks)
  self:SetRarityText(rarity)
end
function ContractBrowser_PostOrderPopup:SetRarityText(rarity)
  local displayName = "@RarityLevel" .. rarity .. "_DisplayName"
  local colorName = string.format("COLOR_RARITY_LEVEL_%s", rarity)
  local color = self.UIStyle[colorName]
  UiTextBus.Event.SetTextWithFlags(self.Properties.RarityText, displayName, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetColor(self.Properties.RarityText, color)
end
function ContractBrowser_PostOrderPopup:SetupItemDetail(itemDescriptor, itemList)
  self.ContractItemList:SetShowSelectionState(not self.isBuyOrder)
  if self.isBuyOrder then
    local columnHeaderData = {
      {
        text = "@trade_column_name"
      }
    }
    local listData = {}
    local columnWidths = {736}
    listData[1] = {
      iconPath = string.format(self.iconPath, self.icon),
      itemDescriptor = itemDescriptor,
      columnData = {
        itemDescriptor:GetItemDisplayName()
      }
    }
    self.ContractItemList:SetContractPressedCallback(nil, nil)
    self.ContractItemList:SetColumnHeaderData(columnHeaderData)
    self.ContractItemList:OnListDataSet(listData)
    self.ContractItemList:SetColumnWidths(columnWidths)
  else
    local columnHeaderData = {
      {
        text = "@trade_column_name"
      },
      {text = "@cr_tier"},
      {
        text = "@ui_contract_gearscore"
      },
      {
        text = "@ui_gemsocket"
      },
      {
        text = "@crafting_perklabel"
      },
      {
        text = "@trade_column_rarity"
      },
      {
        text = "@trade_column_inbag"
      }
    }
    self.ContractItemList:SetColumnHeaderData(columnHeaderData)
    if itemList then
      self:PopulateItemList(itemList)
    else
      do
        local itemId = itemDescriptor.itemId
        self.ContractItemList:OnListDataSet(nil)
        self.ContractItemList:SetSpinnerShowing(true)
        contractsDataHandler:RequestInventoryItemData(self, function(self, inventoryItems)
          self.ContractItemList:SetSpinnerShowing(false)
          local relevantItems = {}
          for _, itemData in pairs(inventoryItems) do
            if itemData.itemCrcId == itemId then
              table.insert(relevantItems, itemData)
            end
          end
          local hasItems = 0 < #relevantItems
          if not hasItems then
            self.ContractItemList:OnListDataSet(nil, {
              label = "@ui_postordererror_noItems"
            })
          else
            self:PopulateItemList(relevantItems)
          end
        end)
      end
    end
  end
end
function ContractBrowser_PostOrderPopup:PopulateItemList(relevantItems)
  local listData = {}
  for i, itemData in ipairs(relevantItems) do
    local descriptor = itemData.descriptor
    table.insert(listData, {
      callbackData = i,
      itemDescriptor = descriptor,
      columnData = {
        itemData.name,
        itemCommon:GetDisplayTier(descriptor),
        itemCommon:GetDisplayGearScore(descriptor),
        itemCommon:GetDisplaySocket(descriptor),
        itemCommon:GetDisplayPerks(descriptor),
        itemCommon:GetDisplayRarity(tostring(descriptor:GetRarityLevel())),
        tostring(itemData.quantity)
      }
    })
  end
  self.ContractItemList.lastSelectedIndex = 1
  self:SelectItemToSell(relevantItems[1])
  self.ContractItemList:SetContractPressedCallback(self, function(self, selectedContractIndex)
    self:SelectItemToSell(relevantItems[selectedContractIndex])
  end)
  self.ContractItemList:OnListDataSet(listData)
  self.ContractItemList:SetColumnWidths({
    290,
    60,
    60,
    60,
    120,
    90,
    60
  })
end
function ContractBrowser_PostOrderPopup:SelectItemToSell(selectedItem)
  local descriptor = selectedItem.descriptor
  self.itemDescriptor.gearScore = descriptor.gearScore
  self.itemDescriptor:SetPerks(itemCommon:GetPerks(descriptor))
  self.numInBag = selectedItem.quantity
  self:UpdateMaxQuantity()
end
function ContractBrowser_PostOrderPopup:GetTotalCost(excludeFee)
  return self.unitPrice * self.quantity + (excludeFee and 0 or self.fee)
end
function ContractBrowser_PostOrderPopup:UpdateTotalValue()
  self:UpdateFee()
  if self.isBuyOrder then
    local totalSum = self.fee + self:GetTotalCost(true)
    local text = GetLocalizedCurrency(totalSum)
    UiTextBus.Event.SetText(self.Properties.TotalText, text)
  end
  self:ValidateConfirmButton()
  self:UpdateNewBalance()
  self:UpdateInstantTransactionInfo()
end
function ContractBrowser_PostOrderPopup:UpdateFee()
  if isPreviewDebug then
    self.fee = 200
  else
    self.fee = ContractsRequestBus.Broadcast.CalculateContractPostingFee(Duration.FromHoursUnrounded(self.duration * timeHelpers.hoursInDay), self.unitPrice, self.quantity, self.isBuyOrder and eContractType_Buy or eContractType_Sell)
    self.baseFee = ContractsRequestBus.Broadcast.GetUnmodifiedContractPostingFee(Duration.FromHoursUnrounded(self.duration * timeHelpers.hoursInDay), self.unitPrice, self.quantity, self.isBuyOrder and eContractType_Buy or eContractType_Sell)
    if not self.isBuyOrder then
      local adjustedPrice = self:GetAdjustedUnitPrice(self.unitPrice)
      UiTextBus.Event.SetText(self.Properties.AdjustedPriceFee, GetLocalizedCurrency(adjustedPrice - self.unitPrice))
      UiTextBus.Event.SetText(self.Properties.AdjustedPriceEarnings, GetLocalizedCurrency(adjustedPrice))
    end
  end
  local feeText = GetLocalizedCurrency(self.fee)
  local text = GetLocalizedReplacementText("@ui_buyOrderFee", {
    total = GetLocalizedCurrency(self:GetTotalCost(true)),
    fee = feeText
  })
  UiTextBus.Event.SetText(self.Properties.BuyFeeText, text)
  UiTextBus.Event.SetText(self.Properties.SellFeeText, feeText)
  self:UpdateNewBalance()
end
function ContractBrowser_PostOrderPopup:ResetPerkSelectors()
  for i, perkSelector in ipairs(self.perkSelectors) do
    if i == 1 then
      perkSelector:SetPerkSelectorData(perkSelector.SELECT_BUTTON_ID)
    else
      perkSelector:SetPerkSelectorData()
    end
  end
end
function ContractBrowser_PostOrderPopup:OnPerkSelectorSelect(perkSelector)
  self.currentPerkSelector = perkSelector
  local selectedPerks = {}
  for _, perkSelector in ipairs(self.perkSelectors) do
    if perkSelector:HasSpecificSelection() then
      selectedPerks[perkSelector.perkId] = true
    end
  end
  self.PerkSelectionPopup:SetPerkSelectionPopupData({
    itemId = self.itemDescriptor.itemId,
    maxPerkChannel = self.maxPerkChannel,
    isSelectingGem = false,
    selectedPerks = selectedPerks,
    callbackFunction = self.OnPerkSelected,
    callbackSelf = self,
    restoreHeader = false
  })
end
function ContractBrowser_PostOrderPopup:OnPerkSelectorRemove(perkSelectorToRemove)
  local selectorFound = false
  local numPerkSelectors = #self.perkSelectors
  for i = 1, numPerkSelectors do
    local perkSelector = self.perkSelectors[i]
    if not selectorFound and perkSelector.entityId == perkSelectorToRemove.entityId then
      selectorFound = true
    end
    if i < numPerkSelectors then
      if selectorFound then
        local nextSelector = self.perkSelectors[i + 1]
        perkSelector:SetPerkSelectorData(nextSelector.perkId)
        if not nextSelector.perkId then
          break
        end
      end
    else
      perkSelector:SetPerkSelectorData()
    end
  end
  self:UpdateGemAndAddPerkButtons()
  self:UpdateRarityText()
end
function ContractBrowser_PostOrderPopup:OnGemSelectorSelect(gemSelector)
  local selectedGem = self.GemSelector:HasSelection() and self.GemSelector.perkId or nil
  self.PerkSelectionPopup:SetPerkSelectionPopupData({
    itemId = self.itemDescriptor.itemId,
    maxPerkChannel = self.maxPerkChannel,
    isSelectingGem = true,
    selectedGem = selectedGem,
    callbackFunction = self.OnPerkSelected,
    callbackSelf = self,
    restoreHeader = false
  })
end
function ContractBrowser_PostOrderPopup:OnGemSelectorRemove(gemSelector)
  self.GemSelector:SetPerkSelectorData(self.GemSelector.SELECT_BUTTON_ID)
  self:UpdateGemAndAddPerkButtons()
  self:UpdateRarityText()
end
function ContractBrowser_PostOrderPopup:OnPerkSelected(isSelectingGem, perkId)
  if isSelectingGem then
    self.GemSelector:SetPerkSelectorData(perkId)
    self:UpdateGemAndAddPerkButtons()
    self:UpdateRarityText()
    self.PerkSelectionPopup:SetPerkSelectionPopupVisibility(false)
  else
    local newPerkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(perkId)
    local hasExclusivePerk = false
    for _, perkSelector in ipairs(self.perkSelectors) do
      if perkSelector:HasSpecificSelection() and newPerkData:HasExclusiveLabel(perkSelector.exclusiveLabels) then
        hasExclusivePerk = true
        popupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_exclusive_perk_popup_title", "@ui_exclusive_perk_popup_message", "ExclusivePerkSelectedUniqueId", self, function(self, result, eventId)
          if result == ePopupResult_Yes then
            perkSelector:SetPerkSelectorData(perkId)
            self.PerkSelectionPopup:SetPerkSelectionPopupVisibility(false)
          end
        end)
      end
    end
    if not hasExclusivePerk then
      self.currentPerkSelector:SetPerkSelectorData(perkId)
      local children = UiElementBus.Event.GetChildren(self.Properties.PerkSelectorsContainer)
      for i = 1, #children do
        local perkSelector = self.registrar:GetEntityTable(children[i])
      end
      self:UpdateGemAndAddPerkButtons()
      self:UpdateRarityText()
      self.PerkSelectionPopup:SetPerkSelectionPopupVisibility(false)
    end
  end
end
function ContractBrowser_PostOrderPopup:UpdateMaxQuantity()
  local maxQuantity = self.numInBag
  if self.isBuyOrder then
    if self.unitPrice > 0 then
      maxQuantity = ContractsRequestBus.Broadcast.CalculateMaxContractPostingQuantity(Duration.FromHoursUnrounded(self.duration * timeHelpers.hoursInDay), self.unitPrice, eContractType_Buy, self.currency)
    else
      maxQuantity = 0
    end
  end
  local itemData = ItemDataManagerBus.Broadcast.GetItemData(self.itemDescriptor.itemId)
  maxQuantity = Math.Clamp(maxQuantity, 0, itemData.maxStackSize)
  self.maxQuantity = maxQuantity
  self.QuantitySlider:SetSliderMaxValue(maxQuantity)
  local currentValue = self.QuantitySlider:GetSliderValue()
  if maxQuantity < currentValue then
    currentValue = maxQuantity
  end
  if 0 < maxQuantity and currentValue <= 0 then
    currentValue = 1
  end
  self.QuantitySlider:SetSliderValue(currentValue)
  self:ValidateConfirmButton()
end
function ContractBrowser_PostOrderPopup:ValidateConfirmButton()
  local errorMessage
  local errorButtonMessage = "@ui_placeorder"
  local npcContracts = contractsDataHandler:CurrencyConversionToContracts(true)
  if npcContracts[self.itemDescriptor:GetItemKey()] then
    errorMessage = "@ui_postordererror_npcItem"
  end
  if not errorMessage then
    if self.unitPrice <= 0 then
      errorMessage = "@ui_postordererror_noUnitPrice"
    elseif 0 > self:GetNewBalance() or 0 >= self.maxQuantity then
      errorMessage = self.isBuyOrder and "@ui_postordererror_buy_notenoughmoney" or "@ui_postordererror_sell_notenoughmoney"
      errorButtonMessage = "@ui_postordererror_buy_notenoughmoney_button"
    elseif 0 >= self.quantity then
      errorMessage = "@ui_postordererror_noQuantity"
    end
    if not errorMessage and self.isBuyOrder then
      local outpostFull = false
      if outpostFull then
        errorMessage = "@ui_postordererror_outpostfull"
        errorButtonMessage = "@ui_postordererror_outpostfull_button"
      elseif self.currency < self:GetTotalCost() then
        errorMessage = "@ui_postordererror_notenoughmoney"
        errorButtonMessage = "@ui_postordererror_buy_notenoughmoney_button"
      end
    end
  end
  if errorMessage then
    UiTextBus.Event.SetTextWithFlags(self.Properties.ErrorText, errorMessage, eUiTextSet_SetLocalized)
    self:DisableConfirmButton(true, errorButtonMessage)
  else
    self:DisableConfirmButton(false, errorButtonMessage)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.ErrorText, errorMessage ~= nil)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ConfirmButton, errorMessage == nil)
end
function ContractBrowser_PostOrderPopup:SetupOtherContractList(contracts, isSellers, itemList)
  itemList:SetColumnHeaderData({
    {text = ""},
    {
      text = "@trade_column_price"
    },
    {
      text = "@trade_column_rarity"
    },
    {
      text = isSellers and "@trade_column_available" or "@ui_quantity"
    }
  })
  local listData = {}
  local numContracts = contracts and #contracts or 0
  for i = 1, numContracts do
    local contractData = contracts[i]
    table.insert(listData, {
      contractData = contractData,
      itemDescriptor = contractData.itemDescriptor,
      disableItemBackgrounds = contractData.contractType == eContractType_Buy,
      allowCompare = contractData.contractType == eContractType_Sell,
      isLocalPlayerCreator = contractData.isLocalPlayerCreator,
      columnData = {
        "",
        contractData:GetDisplayContractPrice(),
        contractData:GetDisplayRarity(),
        tostring(contractData.quantity)
      }
    })
  end
  local noContractsData
  if numContracts == 0 then
    noContractsData = {}
    noContractsData.label = not isSellers and "@ui_no_existing_buy_contracts" or "@ui_no_existing_sell_contracts"
  end
  itemList:OnListDataSet(listData, noContractsData)
  itemList:SetColumnWidths({
    120,
    150,
    124,
    124
  })
end
function ContractBrowser_PostOrderPopup:SetupOtherList(isSeller)
  local itemList = isSeller and self.SellersItemList or self.BuyersItemList
  if isPreviewDebug then
    local contracts = {}
    local itemDescriptor = ItemDescriptor()
    itemDescriptor.itemId = 2270771442
    for i = 1, 5 do
      table.insert(contracts, {
        name = "Contract" .. i,
        iconPath = "LyshineUI\\Images\\items\\weapon\\1hSwordT5.png",
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
    self:SetupOtherContractList(contracts, isSeller, itemList)
    return
  end
  local function onResponseUpdate(unitPrice)
    self.searchRequests[tostring(isSeller)] = nil
    itemList:SetSpinnerShowing(false)
    if self.isBuyOrder == not isSeller and not self.userChangedUnitPrice then
      if unitPrice == nil then
        self.UnitPriceLabelWithTextInput:SetInputValue(GetLocalizedCurrency(DEFAULT_UNIT_PRICE, true))
      else
        self.UnitPriceLabelWithTextInput:SetInputValue(GetLocalizedCurrency(unitPrice, true))
      end
    end
    self:UpdateInstantTransactionInfo()
  end
  itemList:SetSpinnerShowing(true)
  local filter = SearchContractsRequest()
  filter.contractType = isSeller and eContractType_Sell or eContractType_Buy
  local outpostId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.OutpostId")
  filter.outposts:push_back(outpostId)
  filter.countPerPage = 5
  filter.sortOrder = eContractSortBy_Price
  filter.sortDescending = not isSeller
  filter.itemName = self.itemDescriptor:GetItemKey()
  if self.searchRequests[tostring(isSeller)] then
    contractsDataHandler:CancelRequest(self.searchRequests[tostring(isSeller)])
    self.searchRequests[tostring(isSeller)] = nil
  end
  self.searchRequests[tostring(isSeller)] = contractsDataHandler:RequestSearchContracts(self, function(self, response)
    local rawContracts = response.contracts
    if not rawContracts then
      onResponseUpdate()
      return
    end
    local contracts = contractsDataHandler:ContractsVectorToTable(rawContracts)
    self:SetupOtherContractList(contracts, isSeller, itemList)
    local topPrice
    if 0 < #contracts then
      topPrice = contracts[1].price
    end
    onResponseUpdate(topPrice)
  end, function(self, reason)
    local noContractsData = {}
    noContractsData.label = contractsDataHandler:FailureReasonToString(reason)
    noContractsData.button1Data = {
      text = "@ui_refreshpage",
      callbackFn = function()
        self:SetupOtherList(isSeller)
      end,
      callbackSelf = self
    }
    itemList:OnListDataSet(nil, noContractsData)
    onResponseUpdate()
  end, filter, nil)
end
function ContractBrowser_PostOrderPopup:OnMinGearScoreSliderChanged(slider)
  local value = slider:GetValue()
  if value then
    self.itemDescriptor.gearScore = value
  end
end
function ContractBrowser_PostOrderPopup:OnQuantityChanged(slider)
  local quantity = tonumber(slider:GetValue())
  if quantity and quantity ~= self.quantity then
    self.quantity = tonumber(quantity)
    self:UpdateTotalValue()
  end
end
function ContractBrowser_PostOrderPopup:IsUnitPriceTextValid(unitPriceText)
  local firstChar = string.sub(unitPriceText, 1, 1)
  if firstChar == "+" or firstChar == "-" then
    return false
  end
  return true
end
function ContractBrowser_PostOrderPopup:OnUnitPriceChanged(unitPriceText)
  self.userChangedUnitPrice = true
  local success = false
  local unitPrice, success = GetCurrencyValueFromLocalized(unitPriceText)
  if not success or unitPrice < 0 or not self:IsUnitPriceTextValid(unitPriceText) then
    if unitPriceText == "" then
      self.unitPrice = 0
      self:UpdateTotalValue()
    else
      self.UnitPriceLabelWithTextInput:SetInputValue(GetLocalizedCurrency(self.unitPrice, true))
    end
    return
  end
  if unitPrice and unitPrice ~= self.unitPrice then
    self.unitPrice = unitPrice
    self:UpdateTotalValue()
    if self.isBuyOrder then
      self:UpdateMaxQuantity()
    end
  end
end
function ContractBrowser_PostOrderPopup:OnDurationChanged(entityId, data)
  self.duration = data.duration
  self:UpdateTotalValue()
  if self.isBuyOrder then
    self:UpdateMaxQuantity()
  end
end
function ContractBrowser_PostOrderPopup:GetNewBalance()
  local totalCost = 0
  if self.isBuyOrder then
    totalCost = self.quantity * self.unitPrice + self.fee
  else
    totalCost = self.fee
  end
  return self.currency - totalCost
end
function ContractBrowser_PostOrderPopup:UpdateNewBalance()
  if not self.isClosing then
    local text = GetLocalizedCurrency(math.max(self:GetNewBalance(), 0))
    UiTextBus.Event.SetText(self.Properties.BalanceText, text)
    local showCoinWarning = false
    if not self.isBuyOrder then
      local potentialCurrencyTotal = self.currency + self.quantity * self.unitPrice - self.fee
      showCoinWarning = potentialCurrencyTotal > self.playerWalletCap
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.MaxCoinWarning, showCoinWarning)
  end
end
function ContractBrowser_PostOrderPopup:UpdateInstantTransactionInfo()
  local itemList = self.isBuyOrder and self.SellersItemList or self.BuyersItemList
  local hasListData = itemList.listData and #itemList.listData > 0
  local shouldShowInstantTransaction = self.enableInstantTransaction and hasListData
  UiElementBus.Event.SetIsEnabled(self.Properties.InstantTransaction.Header, shouldShowInstantTransaction)
  UiElementBus.Event.SetIsEnabled(self.Properties.InstantTransaction.Button, shouldShowInstantTransaction)
  UiElementBus.Event.SetIsEnabled(self.Properties.InstantTransaction.CenterLine, shouldShowInstantTransaction)
  if shouldShowInstantTransaction then
    self.ScriptedEntityTweener:Set(self.Properties.BalanceContainer, {x = 0})
    self.ScriptedEntityTweener:Set(self.Properties.ButtonContainer, {x = 0})
  else
    self.ScriptedEntityTweener:Set(self.Properties.BalanceContainer, {x = 282})
    self.ScriptedEntityTweener:Set(self.Properties.ButtonContainer, {x = 282})
  end
  if shouldShowInstantTransaction then
    do
      local contractsToOperateOn = {}
      local totalInstantPrice = 0
      local contractsListData = itemList.listData
      local quantityToOperateOn = 0
      for _, listData in ipairs(contractsListData) do
        if quantityToOperateOn >= self.quantity then
          break
        end
        local contractData = listData.contractData
        local desiredQuantity = self.quantity - quantityToOperateOn
        local quantityToTakeFromThisContract = 0
        if desiredQuantity <= contractData.quantity then
          quantityToTakeFromThisContract = desiredQuantity
        else
          quantityToTakeFromThisContract = contractData.quantity
        end
        table.insert(contractsToOperateOn, {contractData = contractData, quantity = quantityToTakeFromThisContract})
        local totalContractPrice = contractData.price * quantityToTakeFromThisContract
        local transactionFee = ContractsRequestBus.Broadcast.CalculateContractCompletionFee(totalContractPrice, contractData.contractType)
        totalInstantPrice = totalInstantPrice + totalContractPrice + transactionFee * (self.isBuyOrder and 1 or -1)
        quantityToOperateOn = quantityToOperateOn + quantityToTakeFromThisContract
      end
      UiTextBus.Event.SetTextWithFlags(self.Properties.InstantTransaction.Header, not self.isBuyOrder and "@ui_sell_instant_price" or "@ui_buy_instant_price", eUiTextSet_SetLocalized)
      UiTextBus.Event.SetText(self.Properties.InstantTransaction.Label, GetLocalizedCurrency(totalInstantPrice))
      self.InstantTransaction.Button:SetText(GetLocalizedReplacementText(not self.isBuyOrder and "@ui_sell_instant_quantity" or "@ui_buy_instant_quantity", {quantity = quantityToOperateOn}), true)
      self.InstantTransaction.Button:SetCallback(function(self, data)
        self:SetInstantTransactionSpinnerShowing(true)
        local completedContractResponses = 0
        local totalPurchasedQuantity = 0
        local totalPurchasePrice = 0
        local function OnTransactionDone(contractData)
          self:SetInstantTransactionSpinnerShowing(false)
          if 0 < totalPurchasedQuantity then
            local notificationContractData = {
              GetCount = function()
                return totalPurchasedQuantity
              end,
              GetItem = function()
                return contractData.itemDescriptor
              end,
              GetOutpostLocation = function()
                return "@ui_inventory"
              end,
              GetGold = function()
                return totalPurchasePrice / totalPurchasedQuantity
              end
            }
            contractsDataHandler:EnqueueTradeContractNofification(notificationContractData, self.isBuyOrder and "@ui_buy_order_updated" or "@ui_sell_order_fulfilled_title", self.isBuyOrder and "@ui_buy_order_updated_desc" or "@ui_sell_order_updated_desc")
            self:SetPostOrderPopupData(self.isBuyOrder, self.itemDescriptor, {
              quantity = self.quantity
            })
          else
            local notificationData = NotificationData()
            notificationData.type = "Minor"
            notificationData.text = self.isBuyOrder and "@ui_instant_buy_failed" or "@ui_instant_sell_failed"
            UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
          end
        end
        for _, operationData in pairs(contractsToOperateOn) do
          operationData.contractData.itemDescriptor = self.itemDescriptor
          contractsDataHandler:FulfillContract(operationData.contractData, operationData.quantity, self, function(self, response)
            totalPurchasedQuantity = totalPurchasedQuantity + operationData.quantity
            totalPurchasePrice = totalPurchasePrice + operationData.quantity * operationData.contractData.price
            completedContractResponses = completedContractResponses + 1
            if completedContractResponses == #contractsToOperateOn then
              OnTransactionDone(operationData.contractData)
            end
          end, function(self, response)
            completedContractResponses = completedContractResponses + 1
            if completedContractResponses == #contractsToOperateOn then
              OnTransactionDone(operationData.contractData)
            end
          end, true)
        end
      end, self)
      if self.isBuyOrder then
        local isAffordable = 0 < self.currency - totalInstantPrice
        if not isAffordable then
          self.InstantTransaction.Button:SetText("@ui_contract_failure_insufficient_gold")
        end
        self.InstantTransaction.Button:SetButtonStyle(self.InstantTransaction.Button.BUTTON_STYLE_CTA)
        self.InstantTransaction.Button:SetEnabled(isAffordable)
      end
    end
  end
end
function ContractBrowser_PostOrderPopup:SetInstantTransactionSpinnerShowing(isShowing)
  self.InstantTransaction.Button:SetBlockingSpinnerShowing(isShowing)
end
function ContractBrowser_PostOrderPopup:SetConfirmSpinnerShowing(isShowing)
  self.ConfirmButton:SetBlockingSpinnerShowing(isShowing)
end
function ContractBrowser_PostOrderPopup:GetAdjustedUnitPrice(unitPrice)
  if not self.isBuyOrder then
    return unitPrice - ContractsRequestBus.Broadcast.CalculateContractCompletionFee(unitPrice, eContractType_Sell)
  end
  return unitPrice
end
function ContractBrowser_PostOrderPopup:OnAccept()
  if not self.isVisible then
    return
  end
  if self.quantity <= 0 or 0 >= self.unitPrice then
    return
  end
  self:SetConfirmSpinnerShowing(true)
  local params = ContractCreationParams()
  params.type = self.isBuyOrder and eContractType_Buy or eContractType_Sell
  params.gold = self.unitPrice
  params.count = self.quantity
  params.postingDuration = self.duration
  if self.isBuyOrder then
    params.rarity = 0
  else
    params.rarity = self.itemDescriptor:GetRarityLevel()
  end
  params.itemId = self.itemDescriptor.itemId
  params.gearScore = self.itemDescriptor.gearScore
  local useNewBuyOrderMechanics = self.enableBuyOrderRestrictions and self.isBuyOrder
  if useNewBuyOrderMechanics then
    if self.canHavePerks then
      local gemPerkCount = 0
      local perkCount = 0
      local perks = vector_Crc32()
      if self.GemSelector:HasSelection() then
        gemPerkCount = 1
        if self.GemSelector:HasSpecificSelection() then
          perks:push_back(self.GemSelector.perkId)
        end
      end
      for _, perkSelector in ipairs(self.perkSelectors) do
        if perkSelector:HasSelection() then
          perkCount = perkCount + 1
          if perkSelector:HasSpecificSelection() then
            perks:push_back(perkSelector.perkId)
          end
        end
      end
      params.gemPerkCount = gemPerkCount
      params.perkCount = perkCount
      params:SetPerks(perks)
    end
  else
    params:SetPerks(itemCommon:GetPerks(self.itemDescriptor))
  end
  if not self.isBuyOrder and self.unitPrice * self.quantity < self.fee then
    popupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_postOrder", "@ui_postOrderAtLossWarning", "PostOrderPopupUniqueId", self, function(self, result, eventId)
      if result == ePopupResult_Yes then
        self:PostOrder(params)
      else
        self:SetConfirmSpinnerShowing(false)
      end
    end)
  else
    self:PostOrder(params)
  end
end
function ContractBrowser_PostOrderPopup:PostOrder(params)
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Currency.Amount")
  contractsDataHandler:CreateContract(self, function(self, response)
    local notificationData = NotificationData()
    notificationData.type = "Social"
    notificationData.icon = self.ContractItemList.listData[1].iconPath
    notificationData.title = self.isBuyOrder and "@ui_buy_order_placed" or "@ui_sell_order_placed"
    notificationData.text = GetLocalizedReplacementText(self.isBuyOrder and "@ui_buy_order_placed_detail" or "@ui_sell_order_placed_detail", {
      itemName = self.itemDescriptor:GetItemDisplayName(),
      quantity = tostring(self.quantity)
    })
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    self:SetVisibility(false, true)
  end, function(self, reason)
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = contractsDataHandler:FailureReasonToString(reason)
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    self:SetConfirmSpinnerShowing(false)
  end, params)
end
function ContractBrowser_PostOrderPopup:OnClose()
  if self.isVisible then
    self:SetVisibility(false)
  end
end
function ContractBrowser_PostOrderPopup:SetOnCloseCallback(callbackSelf, callbackFn)
  self.onCloseCallbackData = {callbackSelf = callbackSelf, callbackFn = callbackFn}
end
function ContractBrowser_PostOrderPopup:DisableConfirmButton(isDisabled, buttonText)
  self.ConfirmButton:SetEnabled(not isDisabled)
  self.ConfirmButton:SetText(buttonText)
end
function ContractBrowser_PostOrderPopup:OnPriceHelpFocus()
  local territoryStandingDiscountPct = ContractsRequestBus.Broadcast.GetTerritoryStandingDiscountPct() * 100
  local companyDiscountPct = ContractsRequestBus.Broadcast.GetCompanyDiscountPct() * 100
  local listingFeeText = GetLocalizedReplacementText("@ui_tooltip_listing_fee", {
    quantity = self.quantity
  })
  local tooltipInfo = {
    isDiscount = true,
    name = "@ui_tooltip_cost",
    useLocalizedCurrency = true,
    costEntries = {
      {
        name = "@ui_tooltip_order_price",
        type = TooltipCommon.DiscountEntryTypes.Cost,
        cost = self:GetTotalCost(true)
      },
      {
        name = listingFeeText,
        type = TooltipCommon.DiscountEntryTypes.Fee,
        cost = self.baseFee
      }
    },
    discountEntries = {
      {
        name = "@ui_tooltip_standing_discount",
        type = TooltipCommon.DiscountEntryTypes.TerritoryStanding,
        applyOnFeeOnly = true,
        discountPct = territoryStandingDiscountPct,
        hasDiscount = 0.1 < territoryStandingDiscountPct
      },
      {
        name = "@ui_tooltip_company_discount",
        type = TooltipCommon.DiscountEntryTypes.Company,
        applyOnFeeOnly = true,
        discountPct = companyDiscountPct,
        hasDiscount = 0.1 < companyDiscountPct
      }
    }
  }
  DynamicBus.TooltipsRequestBus.Broadcast.ShowTooltip(tooltipInfo, self, nil)
end
function ContractBrowser_PostOrderPopup:OnPriceHelpUnfocus()
  DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
end
return ContractBrowser_PostOrderPopup
