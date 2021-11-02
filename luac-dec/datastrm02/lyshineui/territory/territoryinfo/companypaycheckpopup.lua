local TimeHelperFunctions = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local CompanyPaycheckPopup = {
  Properties = {
    PropertyTaxItem = {
      default = EntityId()
    },
    TradingTaxItem = {
      default = EntityId()
    },
    CraftingFeeItem = {
      default = EntityId()
    },
    RefiningFeeItem = {
      default = EntityId()
    },
    TotalAmount = {
      default = EntityId()
    },
    TotalLabel = {
      default = EntityId()
    },
    CloseButton = {
      default = EntityId()
    },
    MasterContainer = {
      default = EntityId()
    },
    PopupBackground = {
      default = EntityId()
    },
    ContentContainer = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    TabbedList = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CompanyPaycheckPopup)
function CompanyPaycheckPopup:OnInit()
  BaseElement.OnInit(self)
  self.taxIdToItem = {
    [eTaxOrFee_PropertyTax] = self.PropertyTaxItem,
    [eTaxOrFee_TradingTax] = self.TradingTaxItem,
    [eTaxOrFee_CraftingFee] = self.CraftingFeeItem,
    [eTaxOrFee_RefiningFee] = self.RefiningFeeItem
  }
  self.CloseButton:SetCallback(self.OnClose, self)
end
function CompanyPaycheckPopup:OnClose()
  if self.IsClosing then
    return
  end
  self.IsClosing = true
  self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.3, {opacity = 1, y = 0}, {
    opacity = 0,
    y = -10,
    ease = "QuadOut",
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.entityId, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.PopupBackground, false)
      self.IsClosing = false
    end
  })
  self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.3, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
end
function CompanyPaycheckPopup:ButtonIdxToPaycheckIdx(previousPeriodCount, buttonIdx)
  return previousPeriodCount - (buttonIdx - 2)
end
function CompanyPaycheckPopup:OpenPaycheckPopup(earningsData, popupBackground)
  self.earningsData = earningsData
  local listData = {
    {
      text = "@ui_current_period",
      callback = self.OnDateSelected
    }
  }
  for idx = 1, #self.earningsData.previousPeriods do
    local payPeriod = self.earningsData.previousPeriods[idx]
    local dateText = TimeHelperFunctions:GetLocalizedAbbrevDate(payPeriod.endTime:GetTimeSinceEpoc():ToSeconds())
    table.insert(listData, {
      text = dateText,
      callback = self.OnDateSelected
    })
  end
  self.TabbedList:SetListData(listData, self)
  self.TabbedList:SetUnselected()
  self.TabbedList:SetSelected(1)
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.PopupBackground, true)
  self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.3, {opacity = 0, y = -10}, {
    opacity = 1,
    y = 0,
    ease = "QuadOut",
    delay = 0.2
  })
end
function CompanyPaycheckPopup:OnDateSelected(entity)
  local index = entity:GetIndex()
  local paycheck
  if index == 1 then
    paycheck = self.earningsData.currentPeriod
  elseif index - 1 <= #self.earningsData.previousPeriods then
    paycheck = self.earningsData.previousPeriods[index - 1]
  end
  if not paycheck then
    return
  end
  for _, element in pairs(self.taxIdToItem) do
    element:SetItem(0, 0)
  end
  for i = 1, #paycheck.statements do
    local statement = paycheck.statements[i]
    local element = self.taxIdToItem[statement.taxId]
    element:SetItem(statement.transactionCount, statement.currencyAmount)
  end
  UiTextBus.Event.SetText(self.Properties.TotalAmount, GetLocalizedCurrency(paycheck.totalEarnings))
  self.ScriptedEntityTweener:Play(self.Properties.ContentContainer, 0.5, {opacity = 0}, {
    opacity = 1,
    ease = "QuadOut",
    delay = 0.2
  })
end
return CompanyPaycheckPopup
