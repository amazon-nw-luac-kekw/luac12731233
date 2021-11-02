local ContractBrowser_ConfirmTransactionPopup = {
  Properties = {
    BlackBackground = {
      default = EntityId()
    },
    MasterContainer = {
      default = EntityId()
    },
    ContractItemList = {
      default = EntityId(),
      order = 1
    },
    SliderWithTextInput = {
      default = EntityId()
    },
    TotalCostCurrencyDisplay = {
      default = EntityId()
    },
    NewBalanceCurrencyDisplay = {
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
    FrameHeader = {
      default = EntityId()
    },
    FeeLabel = {
      default = EntityId()
    },
    ItemToSellListContainer = {
      default = EntityId()
    },
    TransactionDetails = {
      default = EntityId()
    },
    ItemsToSellList = {
      default = EntityId()
    },
    OrderDetailsLabel = {
      default = EntityId()
    },
    AdditionalInfo1 = {
      default = EntityId()
    },
    AdditionalInfo2 = {
      default = EntityId()
    },
    minusButton = {
      default = EntityId()
    },
    plusButton = {
      default = EntityId()
    },
    BuyRow = {
      default = EntityId()
    },
    DetailColumns = {
      default = EntityId()
    },
    CurrencyDisplayContainer = {
      default = EntityId()
    },
    TextInputContainer = {
      default = EntityId()
    },
    MinValueText = {
      default = EntityId()
    },
    PriceHelpIcon = {
      default = EntityId()
    },
    ErrorText = {
      default = EntityId()
    }
  },
  quantity = 1,
  additionalInfoTexts = {}
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ContractBrowser_ConfirmTransactionPopup)
local contractsDataHandler = RequireScript("LyShineUI._Common.ContractsDataHandler")
local itemCommon = RequireScript("LyShineUI._Common.ItemCommon")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local TooltipCommon = RequireScript("LyShineUI._Common.TooltipCommon")
function ContractBrowser_ConfirmTransactionPopup:OnInit()
  BaseElement.OnInit(self)
  self.CancelButton:SetText("@ui_cancel")
  self.ContractItemList:SetColumnHeaderData({
    {
      text = "@trade_column_name"
    },
    {
      text = "@trade_column_price"
    },
    {text = "@ui_avail"},
    {
      text = "@trade_column_inbag"
    },
    {
      text = "@ui_contract_time"
    },
    {
      text = "@trade_column_location"
    }
  })
  self.ContractItemList:SetColumnWidths({
    300,
    75,
    30,
    30,
    75,
    90,
    60,
    75
  })
  self.ConfirmButton:SetButtonStyle(self.ConfirmButton.BUTTON_STYLE_CTA)
  self.minusButton:SetIconPath("lyshineui/images/icons/crafting/icon_crafting_minus.png", true)
  self.plusButton:SetIconPath("lyshineui/images/icons/crafting/icon_crafting_plus.png", true)
  self.plusButton:SetCallback("IncrementSlider", self)
  self.minusButton:SetCallback("DecrementSlider", self)
  self.ItemsToSellList:SetColumnHeaderData({
    {
      text = "@trade_column_name"
    },
    {
      text = "@trade_column_inbag"
    }
  })
  self.ItemsToSellList:SetColumnWidths({390, 80})
  self.ItemsToSellList:SetShowSelectionState(true)
  self.PriceHelpIcon:SetButtonStyle(self.PriceHelpIcon.BUTTON_STYLE_QUESTION_MARK)
  self.PriceHelpIcon:SetFocusCallback(self.OnPriceHelpFocus, self)
  self.PriceHelpIcon:SetUnfocusCallback(self.OnPriceHelpUnfocus, self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.enable-buy-order-restrictions", function(self, enableBuyOrderRestrictions)
    self.enableBuyOrderRestrictions = enableBuyOrderRestrictions
  end)
end
function ContractBrowser_ConfirmTransactionPopup:DoesItemHaveRequiredPerks(inventoryItemDescriptor, contractData)
  local numSpecificPerks = contractData.itemPerks and #contractData.itemPerks or 0
  local numRequiredPerks = contractData.perkCount
  local requiresGemSocket = 0 < contractData.gemPerkCount
  local specificGemPerkData
  if requiresGemSocket then
    local hasGemPerks = false
    for i = 1, numSpecificPerks do
      local perkId = contractData.itemPerks[i]
      local perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(perkId)
      if perkData:IsValid() and perkData.perkType == ePerkType_Gem then
        specificGemPerkData = perkData
      end
    end
    for j = 0, inventoryItemDescriptor:GetPerkCount() - 1 do
      local inventoryPerkId = inventoryItemDescriptor:GetPerk(j)
      local perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(inventoryPerkId)
      if perkData:IsValid() and perkData.perkType == ePerkType_Gem and (specificGemPerkData == nil or specificGemPerkData.id == inventoryPerkId) then
        hasGemPerks = true
      end
    end
    if not hasGemPerks then
      return false
    end
  end
  if 0 < numRequiredPerks then
    local numGeneratedPerks = inventoryItemDescriptor:GetPerkCount() - (requiresGemSocket and 1 or 0)
    if numRequiredPerks <= numGeneratedPerks then
      for i = 1, numSpecificPerks do
        local perkId = contractData.itemPerks[i]
        if perkId and perkId ~= 0 then
          local perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(perkId)
          if perkData:IsValid() and perkData.perkType ~= ePerkType_Gem then
            Debug.Log("[ConfirmTransactionPopup:DoesItemHaveRequiredPerks] Item needs perk " .. tostring(perkId))
            local hasSpecificPerk = false
            for j = 0, inventoryItemDescriptor:GetPerkCount() - 1 do
              local inventoryPerkId = inventoryItemDescriptor:GetPerk(j)
              if inventoryPerkId == perkId then
                hasSpecificPerk = true
              end
            end
            if not hasSpecificPerk then
              return false
            end
          end
        end
      end
      return true
    else
      return false
    end
  end
  return true
end
function ContractBrowser_ConfirmTransactionPopup:SetConfirmationData(isBuyTransaction, contractData, callbackSelf, callbackFn, ownedItemToSell)
  self.isBuyTransaction = isBuyTransaction
  local headerText = isBuyTransaction and "@ui_buyFromOrder" or "@ui_sellToOrder"
  self.FrameHeader:SetText(headerText)
  self.ConfirmButton:SetText(isBuyTransaction and "@ui_buynow" or "@ui_sellnow")
  self.SliderWithTextInput:SetLabel(isBuyTransaction and "@ui_howManyBuying" or "@ui_howManySelling")
  self.isNpcItem = contractData.isNpcItem
  self.unitPrice = contractData.price
  self.contractOutpostId = contractData.outpostId
  self.localOutpostId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.OutpostId")
  local myMoney = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.Amount") or 0
  local maxValue = math.floor(myMoney / self.unitPrice)
  self.quantity = 0 < maxValue and 1 or 0
  self:OnQuantityChanged({
    GetValue = function()
      return self.quantity
    end
  }, true)
  if isBuyTransaction then
    self.SliderWithTextInput:SetSliderText(self.quantity)
    self.SliderWithTextInput:SetCallback(self.OnQuantityChanged, self)
    local sliderMaxValue = maxValue
    if not contractData.isNpcItem then
      sliderMaxValue = math.min(maxValue, contractData.quantity)
    end
    self.SliderWithTextInput:SetSliderMinValue(self.quantity)
    self.SliderWithTextInput:SetSliderMaxValue(sliderMaxValue)
    self.SliderWithTextInput:SetSliderValue(self.quantity)
  else
    self.SliderWithTextInput:SetSliderMinValue(0)
    self.SliderWithTextInput:SetSliderMaxValue(0)
    self.SliderWithTextInput:SetSliderValue(0)
    self.SliderWithTextInput:SetSliderText(0)
  end
  self:SetupItemDetail(contractData, contractData.isNpcItem)
  self.ConfirmButton:SetCallback(function()
    self:SetConfirmSpinnerShowing(true)
    if self.isVisible then
      if self.isBuyTransaction and not contractData:CanEquipItem() then
        do
          local popupId = "confirmBuyUnequippableItem"
          PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@confirm_buy_unequippable", "@confirm_buy_unequippable_body", popupId, self, function(self, result, eventId)
            if popupId ~= eventId then
              return
            end
            if result == ePopupResult_Yes then
              callbackFn(callbackSelf, contractData, self.quantity)
            else
              self:SetConfirmSpinnerShowing(false)
            end
          end)
        end
      else
        callbackFn(callbackSelf, contractData, self.quantity)
      end
    end
  end, self)
  self.CancelButton:SetCallback(function(self)
    if self.isVisible then
      self:SetConfirmPopupVisibility(false)
    end
  end, self)
  self.ButtonClose:SetCallback(function(self)
    if self.isVisible then
      self:SetConfirmPopupVisibility(false)
    end
  end, self)
  self:SetConfirmPopupVisibility(true)
  if isBuyTransaction then
    self:UpdateConfirmationAvailability()
  else
    self.hasItems = false
    if ownedItemToSell then
      self.hasItems = true
      self:PopulateItemList(contractData, {ownedItemToSell})
    else
      do
        local itemId = contractData.itemId
        self.ItemsToSellList:SetSpinnerShowing(true)
        contractsDataHandler:RequestInventoryItemData(self, function(self, inventoryItems)
          self.ItemsToSellList:SetSpinnerShowing(false)
          local relevantItems = {}
          for _, itemData in pairs(inventoryItems) do
            if itemData.itemCrcId == itemId then
              local inventoryItemDescriptor = itemData.descriptor
              local contractItemDescriptor = contractData.itemDescriptor
              local hasGearScore = contractData.gearScore == 0 or inventoryItemDescriptor.gearScore >= contractData.gearScore
              local hasPerks = self:DoesItemHaveRequiredPerks(inventoryItemDescriptor, contractData)
              if contractData.isNpcItem or hasGearScore and hasPerks then
                table.insert(relevantItems, itemData)
              end
            end
          end
          self.hasItems = 0 < #relevantItems
          if not self.hasItems then
            self.ItemsToSellList:OnListDataSet(nil, {
              label = "@ui_cant_fulfill_buy_order"
            })
            self:UpdateConfirmationAvailability()
          else
            self:PopulateItemList(contractData, relevantItems)
          end
        end)
      end
    end
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.OrderDetailsLabel, not isBuyTransaction)
  UiElementBus.Event.SetIsEnabled(self.Properties.ItemToSellListContainer, not isBuyTransaction)
  if not isBuyTransaction then
    self.ScriptedEntityTweener:Set(self.Properties.MasterContainer, {w = 1540, h = 800})
    self.ScriptedEntityTweener:Set(self.Properties.TransactionDetails, {
      x = 790,
      y = 57,
      w = 700
    })
    self.ScriptedEntityTweener:Set(self.Properties.ContractItemList, {x = 0})
    self.ScriptedEntityTweener:Set(self.Properties.BuyRow, {x = -22, y = 432})
    self.ScriptedEntityTweener:Set(self.Properties.DetailColumns, {x = 0, w = 700})
    self.ScriptedEntityTweener:Set(self.Properties.CurrencyDisplayContainer, {y = 0, h = 120})
    self.ScriptedEntityTweener:Set(self.Properties.SliderWithTextInput, {y = 206})
    self.ScriptedEntityTweener:Set(self.SliderWithTextInput.Label, {y = -40})
    self.ScriptedEntityTweener:Set(self.SliderWithTextInput.Slider.entityId, {w = 554, x = 30})
    self.SliderWithTextInput.Slider:SetWidth(554)
    self.ScriptedEntityTweener:Set(self.Properties.TextInputContainer, {
      x = -309,
      y = -10,
      scaleX = 0.8,
      scaleY = 0.8
    })
    UiElementBus.Event.SetIsEnabled(self.Properties.plusButton, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.minusButton, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.MinValueText, false)
    self.ContractItemList:SetColumnHeaderData({
      {
        text = "@trade_column_name"
      },
      {
        text = "@trade_column_price"
      },
      {text = "@ui_quant"},
      {
        text = "@ui_contract_time"
      }
    })
    self.ContractItemList:SetContractItemListWidth(700)
    self.ContractItemList:SetColumnWidths({
      300,
      80,
      80,
      125
    })
  else
    self.ScriptedEntityTweener:Set(self.Properties.MasterContainer, {w = 1168, h = 654})
    self.ScriptedEntityTweener:Set(self.Properties.TransactionDetails, {
      x = 0,
      y = 0,
      w = 1168
    })
    self.ScriptedEntityTweener:Set(self.Properties.ContractItemList, {x = 50})
    self.ScriptedEntityTweener:Set(self.Properties.BuyRow, {x = 529, y = 346})
    self.ScriptedEntityTweener:Set(self.Properties.DetailColumns, {x = 50, w = 1058})
    self.ScriptedEntityTweener:Set(self.Properties.CurrencyDisplayContainer, {y = -86, h = 120})
    self.ScriptedEntityTweener:Set(self.Properties.SliderWithTextInput, {y = 104})
    self.ScriptedEntityTweener:Set(self.SliderWithTextInput.Label, {y = -104})
    self.ScriptedEntityTweener:Set(self.SliderWithTextInput.Slider.entityId, {w = 452, x = 0})
    self.SliderWithTextInput.Slider:SetWidth(452)
    self.ScriptedEntityTweener:Set(self.Properties.TextInputContainer, {
      x = 0,
      y = -66,
      scaleX = 1,
      scaleY = 1
    })
    UiElementBus.Event.SetIsEnabled(self.Properties.plusButton, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.minusButton, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.MinValueText, true)
    self.ContractItemList:SetColumnHeaderData({
      {
        text = "@trade_column_name"
      },
      {
        text = "@trade_column_price"
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
        text = "@ui_contract_time"
      },
      {text = "@ui_avail"},
      {
        text = "@trade_column_inbag"
      },
      {
        text = "@trade_column_location"
      }
    })
    self.ContractItemList:SetContractItemListWidth(1068)
    self.ContractItemList:SetColumnWidths({
      320,
      100,
      60,
      60,
      60,
      118,
      90,
      70,
      50,
      50,
      100
    })
  end
  if not isBuyTransaction then
    if self.enableBuyOrderRestrictions then
      contractsDataHandler:SetAdditionalInfo(self.AdditionalInfo1, self.AdditionalInfo2, contractData)
    else
      self.AdditionalInfo1:SetAdditionalInfo(false)
      self.AdditionalInfo2:SetAdditionalInfo(false)
      self.ScriptedEntityTweener:Set(self.Properties.SliderWithTextInput, {y = 120})
      self.ScriptedEntityTweener:Set(self.SliderWithTextInput.Label, {y = -110})
      UiElementBus.Event.SetIsEnabled(self.Properties.plusButton, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.minusButton, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.MinValueText, true)
      self.ScriptedEntityTweener:Set(self.Properties.TextInputContainer, {
        x = 0,
        y = -66,
        scaleX = 1,
        scaleY = 1
      })
      self.ScriptedEntityTweener:Set(self.SliderWithTextInput.Slider.entityId, {w = 554, x = 0})
      self.SliderWithTextInput.Slider:SetWidth(554)
      self.ScriptedEntityTweener:Set(self.Properties.CurrencyDisplayContainer, {h = 170})
    end
  else
    self.AdditionalInfo1:SetAdditionalInfo(false)
    self.AdditionalInfo2:SetAdditionalInfo(false)
    self:UpdateConfirmationAvailability()
  end
end
function ContractBrowser_ConfirmTransactionPopup:SetupSlider(numItems, isNpcItem)
  self.SliderWithTextInput:SetSliderText(1)
  self.SliderWithTextInput:SetCallback(self.OnQuantityChanged, self)
  local sliderMaxValue = numItems
  if self.isBuyTransaction and not isNpcItem then
    local myMoney = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.Amount") or 0
    local maxValue = math.floor((myMoney - self.fee) / self.unitPrice)
    sliderMaxValue = math.min(maxValue, numItems)
  end
  self.SliderWithTextInput:SetSliderMinValue(1)
  self.SliderWithTextInput:SetSliderMaxValue(sliderMaxValue)
  self:OnQuantityChanged({
    GetValue = function()
      return numItems
    end
  }, true)
  self.SliderWithTextInput:SetSliderValue(1)
end
function ContractBrowser_ConfirmTransactionPopup:PopulateItemList(contractData, relevantItems)
  local listData = {}
  for i, itemData in ipairs(relevantItems) do
    table.insert(listData, {
      callbackData = i,
      itemDescriptor = itemData.descriptor,
      columnData = {
        itemData.name,
        tostring(itemData.quantity)
      }
    })
  end
  contractData.itemDescriptor = relevantItems[1].descriptor
  local contractQuantity = tonumber(contractData.quantity)
  if contractQuantity then
    self:SetupSlider(math.min(relevantItems[1].quantity, tonumber(contractData.quantity)), contractData.isNpcItem)
  else
    self:SetupSlider(relevantItems[1].quantity, contractData.isNpcItem)
  end
  self.ItemsToSellList:SetContractPressedCallback(self, function(self, selectedContractIndex)
    local selectedItemToSell = relevantItems[selectedContractIndex]
    contractData.itemDescriptor = selectedItemToSell.descriptor
    if contractQuantity then
      self:SetupSlider(math.min(selectedItemToSell.quantity, tonumber(contractData.quantity)), contractData.isNpcItem)
    else
      self:SetupSlider(relevantItems[1].quantity, contractData.isNpcItem)
    end
    self:UpdateConfirmationAvailability()
  end)
  self.ItemsToSellList:OnListDataSet(listData, nil)
  self:UpdateConfirmationAvailability()
end
function ContractBrowser_ConfirmTransactionPopup:SetupItemDetail(contractData, skipLookup)
  if not skipLookup then
    contractsDataHandler:LookupContracts(self, function(self, response)
      local responseContractData
      if response and 0 < #response then
        contracts = contractsDataHandler:ContractsVectorToTable(response)
        responseContractData = contracts[1]
      end
      if responseContractData then
        responseContractData.numInBag = contractData.numInBag
        self:SetupItemDetail(responseContractData, true)
      end
    end, function(self, reason)
      local notificationData = NotificationData()
      notificationData.type = "Minor"
      notificationData.text = contractsDataHandler:FailureReasonToString(reason)
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    end, {
      contractData.contractId
    })
  end
  self.isContractAvailable = contractData.statusEnum == eContractStatus_Available or contractData.isNpcItem
  local listData = {}
  listData[1] = {
    isDisabled = not self.isContractAvailable,
    itemDescriptor = contractData.itemDescriptor,
    disableItemBackgrounds = contractData.contractType == eContractType_Buy,
    allowCompare = contractData.contractType == eContractType_Sell,
    columnData = {}
  }
  table.insert(listData[1].columnData, contractData.name)
  table.insert(listData[1].columnData, contractData:GetDisplayContractPrice(self.isBuyTransaction))
  if self.isBuyTransaction then
    table.insert(listData[1].columnData, contractData:GetDisplayTier())
    table.insert(listData[1].columnData, contractData:GetDisplayGearScore())
    table.insert(listData[1].columnData, contractData:GetDisplaySocket())
    table.insert(listData[1].columnData, contractData:GetDisplayPerks())
    table.insert(listData[1].columnData, contractData:GetDisplayRarity())
    table.insert(listData[1].columnData, contractData.expiration)
    table.insert(listData[1].columnData, tostring(contractData.quantity))
    table.insert(listData[1].columnData, tostring(contractData.numInBag))
    table.insert(listData[1].columnData, contractData.location)
  else
    table.insert(listData[1].columnData, tostring(contractData.quantity))
    table.insert(listData[1].columnData, contractData.expiration)
  end
  self.ContractItemList:OnListDataSet(listData)
end
function ContractBrowser_ConfirmTransactionPopup:OnQuantityChanged(slider, force)
  local quantity = slider:GetValue()
  if quantity then
    quantity = math.floor(quantity)
    if quantity ~= self.quantity or force then
      if self.isBuyTransaction and quantity == 0 then
        quantity = 1
      end
      self.quantity = quantity
      local totalCost = self.unitPrice * self.quantity
      self.totalCost = totalCost
      UiElementBus.Event.SetIsEnabled(self.Properties.FeeLabel, not self.isNpcItem)
      if self.isNpcItem then
        self.fee = 0
      else
        local taxModifier = self.isBuyTransaction and ContractsRequestBus.Broadcast.GetBuyContractTransactionTax() or ContractsRequestBus.Broadcast.GetSellContractTransactionTax()
        self.fee = math.floor(self.unitPrice * self.quantity * taxModifier)
        local text = GetLocalizedReplacementText(self.isBuyTransaction and "@ui_plusfee" or "@ui_minusfee", {
          total = GetLocalizedCurrency(totalCost),
          fee = GetLocalizedCurrency(self.fee)
        })
        local baseTaxModifier = self.isBuyTransaction and ContractsRequestBus.Broadcast.GetBaseBuyTax() or ContractsRequestBus.Broadcast.GetBaseSellTax()
        self.baseFee = math.floor(self.unitPrice * self.quantity * baseTaxModifier)
        UiTextBus.Event.SetText(self.Properties.FeeLabel, text)
      end
      local totalCostWithFee = totalCost + self.fee * (self.isBuyTransaction and 1 or -1)
      self.TotalCostCurrencyDisplay:SetCurrencyAmount(totalCostWithFee)
      totalCost = totalCost + self.fee * (self.isBuyTransaction and 1 or -1)
      local newBalance = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.Amount") + totalCost * (self.isBuyTransaction and -1 or 1)
      self.NewBalanceCurrencyDisplay:SetCurrencyAmount(math.max(newBalance, 0))
      self:UpdateConfirmationAvailability()
    end
  end
end
function ContractBrowser_ConfirmTransactionPopup:SetConfirmPopupVisibility(isVisible, closeForResponse)
  self.isVisible = isVisible
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
        UiElementBus.Event.SetIsEnabled(self.entityId, false)
        UiElementBus.Event.SetIsEnabled(self.Properties.BlackBackground, false)
      end
    })
    DynamicBus.StationPropertiesBus.Broadcast.SetTransparent(false)
    DynamicBus.StationPropertiesBus.Broadcast.SetBackgroundTransparent(false)
  end
end
function ContractBrowser_ConfirmTransactionPopup:IsVisible()
  return self.isVisible
end
function ContractBrowser_ConfirmTransactionPopup:SetConfirmSpinnerShowing(isShowing)
  self.ConfirmButton:SetBlockingSpinnerShowing(isShowing)
end
function ContractBrowser_ConfirmTransactionPopup:DisableConfirmButton(errorText, descErrorText)
  self.ConfirmButton:SetEnabled(false)
  self.ConfirmButton:SetText(errorText)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ErrorText, descErrorText, eUiTextSet_SetLocalized)
end
function ContractBrowser_ConfirmTransactionPopup:UpdateConfirmationAvailability()
  if not self.isContractAvailable then
    self:DisableConfirmButton("@ui_orderNotAvailable", "@ui_orderNotAvailable_desc")
    return
  end
  if self.contractOutpostId and self.contractOutpostId ~= self.localOutpostId then
    self:DisableConfirmButton("@ui_contract_failure_invalid_outpost", "@ui_contract_failure_invalid_outpost_desc")
    return
  end
  if self.isBuyTransaction then
    local totalCost = self.unitPrice * self.quantity + self.fee
    local currencyAmount = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.Amount")
    if totalCost > currencyAmount then
      self:DisableConfirmButton("@ui_contract_failure_insufficient_gold", "@ui_contract_failure_insufficient_gold_desc")
      return
    end
  elseif not self.hasItems then
    self:DisableConfirmButton("@ui_noItemAvailable", "@ui_noItemAvailable_desc")
    return
  end
  if self.quantity == 0 then
    self:DisableConfirmButton(self.isBuyTransaction and "@ui_buynow" or "@ui_sellnow", "@ui_contract_failure_no_quantity_selected")
    return
  end
  self.ConfirmButton:SetEnabled(true)
  self.ConfirmButton:SetText(self.isBuyTransaction and "@ui_buynow" or "@ui_sellnow")
  UiTextBus.Event.SetText(self.Properties.ErrorText, "")
end
function ContractBrowser_ConfirmTransactionPopup:IncrementSlider()
  self.SliderWithTextInput:SetSliderValue(self.SliderWithTextInput.Slider:GetValue() + 1, nil, nil, nil, true)
end
function ContractBrowser_ConfirmTransactionPopup:DecrementSlider()
  self.SliderWithTextInput:SetSliderValue(self.SliderWithTextInput.Slider:GetValue() - 1, nil, nil, nil, true)
end
function ContractBrowser_ConfirmTransactionPopup:OnShutdown()
end
function ContractBrowser_ConfirmTransactionPopup:OnPriceHelpFocus()
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
        cost = self.totalCost
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
function ContractBrowser_ConfirmTransactionPopup:OnPriceHelpUnfocus()
  DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
end
return ContractBrowser_ConfirmTransactionPopup
