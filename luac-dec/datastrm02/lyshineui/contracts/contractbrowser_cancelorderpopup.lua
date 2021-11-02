local ContractBrowser_CancelOrderPopup = {
  Properties = {
    ContractItemList = {
      default = EntityId(),
      order = 1
    },
    AdditionalInfo1 = {
      default = EntityId(),
      order = 3
    },
    AdditionalInfo2 = {
      default = EntityId(),
      order = 3
    },
    ConfirmationLabel = {
      default = EntityId(),
      order = 5
    },
    ReturnOrderLabel = {
      default = EntityId(),
      order = 5
    },
    YesButton = {
      default = EntityId(),
      order = 6
    },
    NoButton = {
      default = EntityId(),
      order = 6
    },
    MasterContainer = {
      default = EntityId(),
      order = 7
    },
    BlackBackground = {
      default = EntityId(),
      order = 8
    },
    FrameHeader = {
      default = EntityId(),
      order = 9
    },
    ButtonClose = {
      default = EntityId(),
      order = 10
    }
  },
  contractId = "",
  callbackSelf = nil,
  callbackFn = nil
}
local isPreviewDebug = false
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ContractBrowser_CancelOrderPopup)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local contractsDataHandler = RequireScript("LyShineUI._Common.ContractsDataHandler")
function ContractBrowser_CancelOrderPopup:OnInit()
  BaseElement.OnInit(self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.enable-buy-order-restrictions", function(self, enableBuyOrderRestrictions)
    self.enableBuyOrderRestrictions = enableBuyOrderRestrictions
  end)
  self.YesButton:SetText("@ui_yes")
  self.YesButton:SetCallback(self.OnAccept, self)
  self.YesButton:SetButtonStyle(self.YesButton.BUTTON_STYLE_CTA)
  self.NoButton:SetText("@ui_no")
  self.NoButton:SetCallback(self.OnClose, self)
  self.ButtonClose:SetCallback(self.OnClose, self)
  if isPreviewDebug then
    local isBuyOrder = true
    local contractData = {}
    contractData.iconPath = "LyShineUI\\Images\\Icons\\Items\\Consumable\\Meal3T2.png"
    contractData.itemId = "1hSwordT5"
    contractData.name = "1hSwordT5"
    contractData.price = 100
    contractData.quantity = 10
    contractData.bought = 7
    contractData.expiration = "7h 32min"
    contractData.location = "Irvine Outpost"
    local callbackFn = function()
      Debug.Log("Cancel confirmed")
    end
    self:SetCancellationData(isBuyOrder, contractData, self, callbackFn)
  end
end
function ContractBrowser_CancelOrderPopup:SetCancellationData(isBuyTransaction, contractData, callbackSelf, callbackFn)
  local headerText = isBuyTransaction and "@ui_cancel_buy" or "@ui_cancel_sell"
  self.FrameHeader:SetText(headerText)
  self.callbackFn = callbackFn
  self.callbackSelf = callbackSelf
  self:SetupItemDetail(contractData, isBuyTransaction)
  local returnedText = ""
  if isBuyTransaction then
    returnedText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_returnorder_buyconfirmation", GetLocalizedCurrency(contractData.price * contractData.quantity))
  else
    returnedText = GetLocalizedReplacementText("@ui_returnorder_sellconfirmation", {
      count = contractData.quantity
    })
  end
  UiTextBus.Event.SetText(self.Properties.ReturnOrderLabel, returnedText)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ConfirmationLabel, "@ui_cancelorder_confirmation", eUiTextSet_SetLocalized)
  self:SetAdditionalInfo(isBuyTransaction, contractData)
  self:SetVisibility(true)
end
function ContractBrowser_CancelOrderPopup:SetAdditionalInfo(isBuyTransaction, contractData)
  if isBuyTransaction then
    local height = 640
    if self.enableBuyOrderRestrictions then
      local numAdditionalInfoTexts = contractsDataHandler:SetAdditionalInfo(self.AdditionalInfo1, self.AdditionalInfo2, contractData)
      if numAdditionalInfoTexts == 0 then
        height = 463
        self.AdditionalInfo1:SetAdditionalInfo(false)
        self.AdditionalInfo2:SetAdditionalInfo(false)
      end
    else
      self.AdditionalInfo1:SetAdditionalInfo(false)
      self.AdditionalInfo2:SetAdditionalInfo(false)
    end
    self.ScriptedEntityTweener:Set(self.Properties.MasterContainer, {h = height, w = 1030})
  else
    self.AdditionalInfo1:SetAdditionalInfo(false)
    self.AdditionalInfo2:SetAdditionalInfo(false)
    self.ScriptedEntityTweener:Set(self.Properties.MasterContainer, {h = 463, w = 1162})
  end
end
function ContractBrowser_CancelOrderPopup:SetupItemDetail(contractData, isBuyTransaction)
  local listData = {}
  if not isBuyTransaction then
    self.ContractItemList:SetColumnHeaderData({
      {
        text = "@trade_column_name"
      },
      {
        text = "@trade_column_price"
      },
      {text = "@ui_avail"},
      {
        text = "@trade_column_sold"
      },
      {
        text = "@ui_contract_time"
      },
      {text = "@cr_tier"},
      {
        text = "@ui_contract_gearscore"
      },
      {
        text = "@trade_column_location"
      }
    })
    listData[1] = {
      itemDescriptor = contractData.itemDescriptor,
      disableItemBackgrounds = contractData.contractType == eContractType_Buy,
      columnData = {
        contractData.name,
        contractData:GetDisplayContractPrice(),
        tostring(contractData.quantity),
        tostring(contractData.bought),
        contractData.expiration,
        contractData:GetDisplayTier(),
        contractData:GetDisplayGearScore(),
        contractData.location
      }
    }
    self.ContractItemList:SetColumnWidths({
      340,
      100,
      95,
      100,
      85,
      85,
      110,
      115
    })
  else
    self.ContractItemList:SetColumnHeaderData({
      {
        text = "@trade_column_name"
      },
      {
        text = "@trade_column_price"
      },
      {text = "@ui_avail"},
      {text = "@ui_bought"},
      {
        text = "@ui_contract_time"
      },
      {
        text = "@trade_column_location"
      }
    })
    listData[1] = {
      itemDescriptor = contractData.itemDescriptor,
      disableItemBackgrounds = contractData.contractType == eContractType_Buy,
      allowCompare = contractData.contractType == eContractType_Sell,
      columnData = {
        contractData.name,
        contractData:GetDisplayContractPrice(),
        tostring(contractData.quantity),
        tostring(contractData.bought),
        contractData.expiration,
        contractData.location
      },
      self.ContractItemList:SetColumnWidths({
        350,
        100,
        90,
        120,
        130,
        180,
        0,
        0
      })
    }
  end
  self.ContractItemList:OnListDataSet(listData)
  self.contractData = contractData
end
function ContractBrowser_CancelOrderPopup:SetVisibility(isVisible)
  self.YesButton:SetBlockingSpinnerShowing(false)
  self.isVisible = isVisible
  UiElementBus.Event.SetIsEnabled(self.entityId, isVisible)
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
        UiElementBus.Event.SetIsEnabled(self.entityId, false)
        UiElementBus.Event.SetIsEnabled(self.Properties.BlackBackground, false)
      end
    })
    DynamicBus.StationPropertiesBus.Broadcast.SetTransparent(false)
    DynamicBus.StationPropertiesBus.Broadcast.SetBackgroundTransparent(false)
  end
end
function ContractBrowser_CancelOrderPopup:IsVisible()
  return self.isVisible
end
function ContractBrowser_CancelOrderPopup:OnAccept()
  self.YesButton:SetBlockingSpinnerShowing(true)
  local completionParams = ContractCompletionParams()
  completionParams.type = self.contractData.contractType
  completionParams.count = self.contractData.quantity
  completionParams.reason = eContractCompletionReason_Canceled
  contractsDataHandler:CompleteContract(self, function(self, response)
    if self.callbackFn and self.callbackSelf then
      self.callbackFn(self.callbackSelf, true)
    end
    self:SetVisibility(false)
    local notificationData = NotificationData()
    if self.contractData.contractType == eContractType_Sell then
      local cancelDesc = GetLocalizedReplacementText("@ui_returnorder_sell_desc", {
        quantity = self.contractData.quantity,
        itemName = self.contractData.name
      })
      notificationData.type = "Social"
      notificationData.icon = self.contractData.iconPath
      notificationData.title = "@ui_returnorder_sell_title"
      notificationData.text = cancelDesc
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    else
      notificationData.type = "Minor"
      notificationData.text = "@ui_returnorder_sell_title"
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    end
  end, function(self, reason)
    if self.callbackFn and self.callbackSelf then
      self.callbackFn(self.callbackSelf, false)
    end
    self:SetVisibility(false)
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = contractsDataHandler:FailureReasonToString(reason)
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end, self.contractData.contractId, completionParams)
end
function ContractBrowser_CancelOrderPopup:OnClose()
  self:SetVisibility(false)
end
return ContractBrowser_CancelOrderPopup
