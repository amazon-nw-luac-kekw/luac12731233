local TimeHelperFunctions = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local jsonParser = RequireScript("LyShineUI.json")
local EntitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
local OrderHistoryPopup = {
  Properties = {
    FrameHeader = {
      default = EntityId()
    },
    CloseButton = {
      default = EntityId()
    },
    PopupBackground = {
      default = EntityId()
    },
    MasterContainer = {
      default = EntityId()
    },
    CancelButton = {
      default = EntityId()
    },
    TransactionList = {
      default = EntityId()
    },
    TransactionPrototype = {
      default = EntityId()
    }
  },
  expandedProducts = {}
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(OrderHistoryPopup)
function OrderHistoryPopup:OnInit()
  BaseElement.OnInit(self)
  self.FrameHeader:SetText("@ui_orderhistory")
  self.FrameHeader:SetTextAlignment(self.FrameHeader.TEXT_ALIGN_CENTER)
  self.CloseButton:SetCallback(self.OnCancel, self)
  self.TransactionList:Initialize(self.TransactionPrototype)
  self.TransactionList:OnListDataSet(nil)
  self.CancelButton:SetCallback(self.OnCancel, self)
  self.CancelButton:SetButtonStyle(self.CancelButton.BUTTON_STYLE_CTA)
  self.CancelButton:SetText("@ui_close")
  DynamicBus.OrderHistoryPopup.Connect(self.entityId, self)
end
function OrderHistoryPopup:OnShutdown()
end
function OrderHistoryPopup:Invoke()
  self:SetIsEnabled(true)
  self.TransactionList:SetSpinnerShowing(true)
  EntitlementRequestBus.Broadcast.FetchTransactions()
  self.dataLayer:RegisterAndExecuteDataCallback(self, "InGameStore.Transactions.Length", function(self, count)
    if not count then
      return
    end
    self.index = 0
    self.transactions = {}
    for i = 1, count do
      local node = self.dataLayer:GetDataNode(string.format("InGameStore.Transactions.%i", i))
      local type = node.type:GetData()
      local date = node.date:GetData()
      local dateText = TimeHelperFunctions:GetLocalizedDate(date:GetTimeSinceEpoc():ToSeconds())
      local state = node.state:GetData()
      local json = node.context:GetData()
      local t = jsonParser.decode(json)
      self.index = self.index + 1
      local transactionData = {
        type = "",
        name = "",
        date = dateText,
        spritePath = "",
        amount = "",
        showMarksOfFortuneIcon = false,
        index = i,
        tooltip = ""
      }
      local product = t.products and t.products[1]
      if product then
        transactionData.productId = product.productAlias
        transactionData.isExpanded = self.expandedProducts[product.productAlias]
        local productData = EntitlementRequestBus.Broadcast.GetStoreProductData(Math.CreateCrc32(product.productAlias))
        if productData and productData.isEnabled then
          transactionData.name = productData.displayName
          transactionData.spritePath = productData.thumbnailImage
        else
          transactionData.name = product.name
          transactionData.spritePath = "lyshineui/images/mtx/storeItem_default.dds"
        end
        local rewards
        if product.entitlements then
          local offer = {
            entitlements = {}
          }
          for k, v in ipairs(product.entitlements) do
            table.insert(offer.entitlements, {
              entitlementId = Math.CreateCrc32(v.alias)
            })
          end
          rewards = EntitlementsDataHandler:GetRewardsForOffer(offer)
          transactionData.type = EntitlementsDataHandler:GetProductTypeText(rewards)
          transactionData.tooltip = EntitlementsDataHandler:GetProductTypeTooltipText(rewards)
          transactionData.isBundle = 1 < #rewards
        end
        if product.price then
          transactionData.amount = GetLocalizedRealWorldCurrency(product.price, t.currencyCode)
        end
        if product.currencyEntitlement then
          if product.currencyEntitlement.amount and 0 < product.currencyEntitlement.amount then
            transactionData.amount = GetLocalizedNumber(product.currencyEntitlement.amount)
            transactionData.showMarksOfFortuneIcon = true
          else
            transactionData.amount = "@ui_free"
          end
        end
        table.insert(self.transactions, transactionData)
        if rewards and self.expandedProducts[product.productAlias] then
          for _, reward in pairs(rewards) do
            local rewardsDisplayInfo = EntitlementsDataHandler:GetRewardDisplayInfo(reward)
            local rewardTypeTooltip = rewardsDisplayInfo.tooltip
            local bundleItemData = {
              name = rewardsDisplayInfo.itemDescription,
              spritePath = rewardsDisplayInfo.spritePath,
              type = rewardsDisplayInfo.typeString,
              isBundleItem = true,
              index = i,
              tooltip = rewardTypeTooltip
            }
            table.insert(self.transactions, bundleItemData)
          end
        end
      end
    end
    self.TransactionList:SetSpinnerShowing(false)
    self.TransactionList:OnListDataSet(self.transactions)
  end)
  UiElementBus.Event.SetIsEnabled(self.Properties.TransactionList, true)
  self:SetIsEnabled(true)
end
function OrderHistoryPopup:SetProductExpanded(productAlias, expanded)
  self.expandedProducts[productAlias] = expanded or nil
  self:Invoke()
end
function OrderHistoryPopup:IsEnabled()
  return UiElementBus.Event.IsEnabled(self.entityId)
end
function OrderHistoryPopup:SetIsEnabled(isEnabled)
  if not isEnabled then
  end
  if self:IsEnabled() == isEnabled then
    return
  end
  self.expandedProducts = {}
  if isEnabled then
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.3, {opacity = 0, y = -10}, {
      opacity = 1,
      y = 0,
      ease = "QuadOut",
      delay = 0.2
    })
  else
    if self.context and type(self.onCancelCallback) == "function" then
      self.onCancelCallback(self.context)
    end
    self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.15, {opacity = 1, y = 0}, {
      opacity = 0,
      y = -10,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.1, {opacity = 1}, {
      opacity = 0,
      ease = "QuadOut",
      delay = 0.15,
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.entityId, false)
      end
    })
  end
end
function OrderHistoryPopup:OnCancel()
  self:SetIsEnabled(false)
end
return OrderHistoryPopup
